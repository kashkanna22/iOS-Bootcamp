//
//  ContentView.swift
//  NBA API App
//
//  Created by Kashyap Kannajyosula on 4/15/25.
//

//  ContentView.swift
//  NBA API App

//  ContentView.swift
//  NBA API App

import SwiftUI

struct ContentView: View {
    @State private var games: [Game] = []
    @State private var selectedDate = Date()
    @State private var selectedGame: Game? = nil
    @State private var playerStats: [PlayerStat] = []
    @State private var selectedPlayer: PlayerStat? = nil
    @State private var playerAverages: PlayerAverage?

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(nbaSeason, id: \..self) { date in
                            Text(dateFormatted(date))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .white : .primary)
                                .cornerRadius(10)
                                .onTapGesture {
                                    selectedDate = date
                                    fetchGames(for: date)
                                }
                        }
                    }
                    .padding(.horizontal)
                }

                List(games) { game in
                    VStack(alignment: .leading) {
                        Text("\(game.teams.home.name) vs \(game.teams.visitors.name)")
                            .font(.headline)
                        Text("Score: \(game.scores.home.points ?? 0) - \(game.scores.visitors.points ?? 0)")
                        Text("Status: \(game.status.long)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                    .onTapGesture {
                        selectedGame = game
                        fetchGameStats(for: game.idReal)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("NBA Scores")
            .onAppear {
                fetchGames(for: selectedDate)
            }
            .sheet(item: $selectedGame) { game in
                VStack(spacing: 16) {
                    Text("\(game.teams.home.name) vs \(game.teams.visitors.name)")
                        .font(.title2)
                    Text("Score: \(game.scores.home.points ?? 0) - \(game.scores.visitors.points ?? 0)")
                        .font(.headline)
                    Text("Game Status: \(game.status.long)")
                        .foregroundColor(.gray)
                    List(playerStats) { player in
                        Text("\(player.name): \(player.points ?? 0) PTS")
                            .onTapGesture {
                                selectedPlayer = player
                                fetchPlayerAverages(player.idReal)
                            }
                    }
                    Spacer()
                }
                .padding()
            }
            .sheet(item: $selectedPlayer) { player in
                VStack(spacing: 12) {
                    Text(player.name).font(.title2)
                    if let avg = playerAverages {
                        Text("Season Avg: \(avg.points) PTS, \(avg.rebounds) REB, \(avg.assists) AST")
                    } else {
                        ProgressView("Loading...")
                    }
                }.onTapGesture { selectedPlayer = nil }
            }
        }
    }

    var nbaSeason: [Date] {
        (0..<133).map { Calendar.current.date(byAdding: .day, value: -$0, to: Date())! }.reversed()
    }

    func dateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    func fetchGames(for date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        guard let url = URL(string: "https://api-nba-v1.p.rapidapi.com/games?date=\(dateString)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("60de8933bamshef72ea1a0df5539p1dd149jsnc407e57a5746", forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("api-nba-v1.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(Response<Game>.self, from: data) {
                    DispatchQueue.main.async {
                        self.games = decoded.response
                    }
                }
            }
        }.resume()
    }

    func fetchGameStats(for gameId: Int?) {
        guard let gameId = gameId,
              let url = URL(string: "https://api-nba-v1.p.rapidapi.com/players/statistics?game=\(gameId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("60de8933bamshef72ea1a0df5539p1dd149jsnc407e57a5746", forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("api-nba-v1.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(Response<PlayerStat>.self, from: data) {
                    DispatchQueue.main.async {
                        self.playerStats = decoded.response
                    }
                }
            }
        }.resume()
    }

    func fetchPlayerAverages(_ playerId: Int?) {
        guard let playerId = playerId,
              let url = URL(string: "https://api-nba-v1.p.rapidapi.com/players/season-average?season=2024&id=\(playerId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("60de8933bamshef72ea1a0df5539p1dd149jsnc407e57a5746", forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("api-nba-v1.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(Response<PlayerAverage>.self, from: data) {
                    DispatchQueue.main.async {
                        self.playerAverages = decoded.response.first
                    }
                }
            }
        }.resume()
    }

    struct Response<T: Decodable>: Decodable {
        let response: [T]
    }

    struct Game: Decodable, Identifiable {
        var id: UUID { UUID() }
        let idReal: Int?
        let teams: Teams
        let scores: Scores
        let status: Status

        struct Teams: Decodable {
            let home: Team
            let visitors: Team
            struct Team: Decodable {
                let name: String
            }
        }

        struct Scores: Decodable {
            let home: Points
            let visitors: Points
            struct Points: Decodable {
                let points: Int?
            }
        }

        struct Status: Decodable {
            let long: String
        }
    }

    struct PlayerStat: Identifiable, Decodable {
        let id = UUID()
        let idReal: Int?
        let name: String
        let points: Int?

        enum CodingKeys: String, CodingKey {
            case idReal = "playerId"
            case name = "player"
            case points = "points"
        }
    }

    struct PlayerAverage: Decodable {
        let points: Double
        let rebounds: Double
        let assists: Double
    }
}

#Preview {
    ContentView()
}
#Preview {
    ContentView()
}
