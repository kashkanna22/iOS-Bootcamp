//
//  ContentView.swift
//  Countey
//
//  Created by Kashyap Kannajyosula on 4/1/25.
//

import SwiftUI

struct ContentView: View {
    @State private var count = 0
    @State private var backgroundOpacity: Double = 0.5
    @State private var isRed = true

    var body: some View {
        NavigationStack {
            ZStack {
                // Background color with changing opacity
                Color(isRed ? .red : .blue)
                    .opacity(backgroundOpacity)
                    .ignoresSafeArea()
                
                VStack {
                    Text("Counter: \(count)")
                        .font(.largeTitle)
                        .padding()
                    
                    // Stepper for incrementing count
                    Stepper("Increase Count", value: $count, in: 0...100)
                        .padding()
                    
                    HStack {
                        // Button to toggle color
                        Button(action: {
                            isRed.toggle()
                        }) {
                            Text("Toggle Color")
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                        
                        // Button to adjust opacity
                        Button(action: {
                            backgroundOpacity = backgroundOpacity == 0.5 ? 1.0 : 0.5
                        }) {
                            Text("Adjust Opacity")
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                    }
                    
                    NavigationLink("Go to Settings") {
                        SettingsView(count: $count)
                    }
                    .padding()
                }
            }
            .navigationTitle("Countey")
        }
    }
}

struct SettingsView: View {
    @Binding var count: Int  // This allows us to modify the count in the parent view
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
            
            // Stepper for incrementing count
            Stepper("Increase Count in Settings", value: $count, in: 0...100)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Settings")
    }
}
#Preview {
    ContentView()
}
