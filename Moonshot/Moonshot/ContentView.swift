//
//  ContentView.swift
//  Moonshot
//
//  Created by Kashyap Kannajyosula on 4/1/25.
//

import SwiftUI
import Foundation
struct Astronaut: Identifiable, Codable {
    let id: String
    let name: String
    let dateOfBirth: String
    let dateOfDeath: String?
    let bio: String
}

struct Mission: Identifiable, Codable {
    let id: String
    let name: String
    let launchDate: String
    let crew: [CrewMember]
    
    struct CrewMember: Codable {
        let name: String
        let role: String
    }
}
extension Bundle {
    func decode<T: Codable>(_ type: T.Type, from file: String) -> T {
        let decoder = JSONDecoder()
        
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        guard let decodedData = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(file) from bundle.")
        }
        return decodedData
    }
}
struct MissionView: View {
    let mission: Mission
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(mission.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Launch Date: \(mission.launchDate)")
                    .font(.subheadline)
                    .padding(.top, 5)
                
                ForEach(mission.crew, id: \.name) { crewMember in
                    Text("\(crewMember.name) - \(crewMember.role)")
                        .font(.body)
                        .padding(.top, 5)
                }
            }
            .padding()
        }
    }
}
struct AstronautView: View {
    let astronaut: Astronaut
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(astronaut.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Date of Birth: \(astronaut.dateOfBirth)")
                    .font(.subheadline)
                if let dateOfDeath = astronaut.dateOfDeath {
                    Text("Date of Death: \(dateOfDeath)")
                        .font(.subheadline)
                }
                Text(astronaut.bio)
                    .font(.body)
                    .padding(.top, 5)
            }
            .padding()
        }
    }
}
struct ContentView: View {
    @State private var missions: [Mission] = []
    var body: some View {
        NavigationView {
            List(missions) { mission in
                NavigationLink(destination: MissionView(mission: mission)) {
                    Text(mission.name)
                }
            }
            .navigationTitle("Moonshot Missions")
        }
        .onAppear {
            let missionsData: [Mission] = Bundle.main.decode([Mission].self, from: "missions.json")
            self.missions = missionsData
        }
    }
}

#Preview {
    ContentView()
}
