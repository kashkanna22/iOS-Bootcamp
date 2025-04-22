//
//  ContentView.swift
//  ChatPrototype
//
//  Created by Kashyap Kannajyosula on 2/4/25.
//

import SwiftUI

struct WordView: View {
    @State var words: [String]? = nil
    @State var errorMessage: String? = nil
    
    var body: some View {
        List {
            Button("Refresh words") {
                getWords()
            }
            
            Section {
                if let words = words {
                    ForEach(words, id: \.self) { word in
                        Text(word)
                    }
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    Text("Loading words...")
                }
            }
        }
        .onAppear { getWords() }
    }
    
    private func getWords() {
        Task {
            do {
                let result = try await WordService.fetchWords()
                words = result
                errorMessage = nil
            } catch {
                errorMessage = "Failed to fetch words: \(error.localizedDescription)"
                print(error)
            }
        }
    }
}

class WordService {
    static func fetchWords() async throws -> [String] {
        let urlString = "https://random-word-api.vercel.app/api?words=10"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let words = try JSONDecoder().decode([String].self, from: data)
        return words
    }
}

#Preview {
    WordView()
}

