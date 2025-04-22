//
//  ContentView.swift
//  Market Mastery
//
//  Created by Kashyap Kannajyosula on 4/7/25.
//

import SwiftUI

struct market: Codable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let current_price: Double
    let price_change_percentage_24h: Double
    let price_change_24h: Double?
    let price_change_percentage_30d_in_currency: Double?
    let price_change_percentage_1y_in_currency: Double?
}

struct marketCard: View {
    let market: market
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: market.image)) { image in
                image.resizable().frame(width: 100, height: 100)
            } placeholder: {
                ProgressView()
            }
            Text(market.name).font(.headline).foregroundColor(.white)
            Text(String(format: "$%.2f", market.current_price)).font(.subheadline).foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

class marketManager {
    static func fetchTopmarket(completion: @escaping ([market]) -> Void) {
        let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&price_change_percentage=30d,1y")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                let markets = try? JSONDecoder().decode([market].self, from: data)
                DispatchQueue.main.async {
                    completion(markets ?? [])
                }
            }
        }.resume()
    }
}

struct GameSettings {
    var timer: Int? = nil
    var lives: Int = 3
}

class GameViewModel: ObservableObject {
    @Published var markets: [market] = []
    @Published var currentmarket: market?
    @Published var score = 0
    @Published var highScore = 0
    @Published var isGameOver = false
    @Published var playerName: String = ""
    @Published var showResult = false
    @Published var playingHistory: [String] = []
    @Published var showMenu = false
    @Published var streak = 0
    @Published var multiplier = 1
    @Published var settings = GameSettings()
    @Published var lives = 3
    @Published var remainingTime: Int?

    var timer: Timer?

    func startGame() {
        if score > highScore {
            highScore = score
        }
        score = 0
        streak = 0
        multiplier = 1
        lives = settings.lives
        isGameOver = false
        showResult = false
        playingHistory.removeAll()
        remainingTime = settings.timer
        timer?.invalidate()
        if let time = remainingTime {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if self.remainingTime! > 0 {
                    self.remainingTime! -= 1
                } else {
                    self.isGameOver = true
                    self.timer?.invalidate()
                }
            }
        }
        marketManager.fetchTopmarket { markets in
            self.markets = markets
            self.nextRound()
        }
    }

    func nextRound() {
        showResult = false
        if let random = markets.randomElement() {
            currentmarket = random
        }
    }

    func makeGuess(_ guessUp: Bool) {
        guard let change = currentmarket?.price_change_percentage_24h, let market = currentmarket else { return }
        let correct = (change >= 0 && guessUp) || (change < 0 && !guessUp)
        if correct {
            streak += 1
            multiplier = streak >= 5 ? 5 : streak >= 3 ? 3 : streak >= 2 ? 2 : 1
            score += multiplier
        } else {
            streak = 0
            multiplier = 1
            lives -= 1
            if lives <= 0 {
                isGameOver = true
                timer?.invalidate()
            }
        }
        let trend = change >= 0 ? "🔼 Rising" : "🔽 Falling"
        let advice = change >= 5 ? "Strong Buy 💰" : change >= 0 ? "Consider Buying ✅" : change >= -5 ? "Hold 🤔" : "Avoid 🚫"
        playingHistory.append("\(market.name): \(trend) | \(advice)")
        showResult = true
    }
}

struct HomeScreenView: View {
    @Binding var isGameStarted: Bool
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Market Mastery").font(.largeTitle).bold().foregroundColor(.white)
            Picker("Timer", selection: $viewModel.settings.timer) {
                Text("1 Min").tag(Optional(60))
                Text("2 Min").tag(Optional(120))
                Text("Unlimited").tag(nil as Int?)
            }.pickerStyle(SegmentedPickerStyle())

            Picker("Lives", selection: $viewModel.settings.lives) {
                Text("1 Life").tag(1)
                Text("3 Lives").tag(3)
                Text("5 Lives").tag(5)
            }.pickerStyle(SegmentedPickerStyle())

            Button("Start Game") {
                isGameStarted = true
                viewModel.startGame()
            }
            .padding()
        }
        .padding()
    }
}

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var isGameStarted = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.4), .purple.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            if isGameStarted {
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Button(action: {
                                viewModel.showMenu.toggle()
                            }) {
                                Image(systemName: "line.horizontal.3")
                                    .foregroundColor(.white)
                                    .font(.title)
                            }
                            Spacer()
                            if let time = viewModel.remainingTime {
                                Text("Time: \(time)s")
                                    .foregroundColor(.white)
                            }
                            Text("Lives: \(viewModel.lives)")
                                .foregroundColor(.white)
                        }
                        .padding()

                        Text("Streak: \(viewModel.streak) \(viewModel.streak >= 2 ? "🔥" : "") | Multiplier: \(viewModel.multiplier)x")
                            .foregroundColor(.white)

                        if let market = viewModel.currentmarket {
                            marketCard(market: market)

                            if !viewModel.showResult {
                                Text("Guess if the price went Higher or Lower in 24h")
                                    .foregroundColor(.white)
                                HStack {
                                    Button("Higher") {
                                        viewModel.makeGuess(true)
                                    }
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)

                                    Button("Lower") {
                                        viewModel.makeGuess(false)
                                    }
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            } else {
                                let change = market.price_change_percentage_24h
                                let trend = change >= 0 ? "🔼 Rising" : "🔽 Falling"
                                let advice = change >= 5 ? "Strong Buy 💰" : change >= 0 ? "Consider Buying ✅" : change >= -5 ? "Hold 🤔" : "Avoid 🚫"
                                let priceChange24h = market.price_change_24h ?? 0.0
                                let pct30d = market.price_change_percentage_30d_in_currency ?? 0.0
                                let pct1y = market.price_change_percentage_1y_in_currency ?? 0.0

                                VStack(spacing: 10) {
                                    Text("Current Price: $\(market.current_price, specifier: "%.2f")")
                                    Text("Change (24h): \(priceChange24h >= 0 ? "+" : "")\(String(format: "%.2f", priceChange24h))")
                                    Text("Change (30d): \(pct30d >= 0 ? "+" : "")\(String(format: "%.2f", pct30d))%")
                                    Text("Change (1y): \(pct1y >= 0 ? "+" : "")\(String(format: "%.2f", pct1y))%")
                                    Text("Trend: \(trend)")
                                    Text("Advice: \(advice)")
                                    if !viewModel.isGameOver {
                                        Button("Next") {
                                            viewModel.nextRound()
                                        }
                                        .padding()
                                        .background(Color.orange)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    }
                                }
                                .foregroundColor(.white)
                            }
                            Text("Score: \(viewModel.score)")
                                .foregroundColor(.white)
                        }

                        if viewModel.isGameOver {
                            Text("Game Over").font(.title).foregroundColor(.red)
                            Text("Your Score: \(viewModel.score)").foregroundColor(.white)
                            Text("Highest Score: \(viewModel.highScore)").foregroundColor(.white)
                            Button("Restart") {
    isGameStarted = false
}.padding()
                        }

                        Spacer()

                        if viewModel.showMenu {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("History:")
                                    .font(.headline)
                                    .padding(.bottom, 2)

                                ScrollView {
                                    VStack(alignment: .leading, spacing: 5) {
                                        ForEach(viewModel.playingHistory.reversed(), id: \.self) { item in
                                            Text(item)
                                                .font(.caption)
                                                .padding(.vertical, 2)
                                        }
                                    }
                                }
                                .frame(height: 120)
                                .scrollIndicators(.visible)

                                Button("Restart Game") {
    isGameStarted = false
}
                                .padding(.top)
                            }
                            .padding()
                            .background(Color.white.opacity(0.85))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
            } else {
                HomeScreenView(isGameStarted: $isGameStarted, viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
