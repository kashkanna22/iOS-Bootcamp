import SwiftUI

struct ContentView: View {
    @State private var isPlaying = false
    @State private var isShuffled = false
    @State private var isRepeated = false
    @State private var progress: Double = 0.0
    let songDuration: Double = 225.0 // Example duration (3:45)
    @State private var timer: Timer? = nil

    var body: some View {
        VStack(spacing: 20) {
            // Display the album cover with fallback color in case image is missing
            Image("HurryUpTmw") // Corrected image name here
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .cornerRadius(15)
                .background(Color.gray) // Fallback color to indicate image loading issues
            
            Text("Cry For Me")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("The Weeknd")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Display the time
            HStack {
                Text(timeString(from: progress))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(timeString(from: songDuration))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // Slider for progress
            Slider(value: $progress, in: 0...songDuration, onEditingChanged: { _ in
                // Update time dynamically as the user changes the slider
            })
            .accentColor(.green)
            
            HStack {
                Button(action: {
                    isShuffled.toggle()
                }) {
                    Image(systemName: "shuffle")
                        .foregroundColor(isShuffled ? .green : .primary)
                }
                
                Spacer()
                
                Button(action: {
                    // Previous track action
                }) {
                    Image(systemName: "backward.fill")
                }
                
                Spacer()
                
                Button(action: {
                    if isPlaying {
                        // Stop the timer and music
                        timer?.invalidate()
                    } else {
                        // Start playing music and the timer
                        startTimer()
                    }
                    isPlaying.toggle()
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                }
                
                Spacer()
                
                Button(action: {
                    // Next track action
                }) {
                    Image(systemName: "forward.fill")
                }
                
                Spacer()
                
                Button(action: {
                    isRepeated.toggle()
                }) {
                    Image(systemName: "repeat")
                        .foregroundColor(isRepeated ? .green : .primary)
                }
            }
            .font(.title)
            .padding(.horizontal, 40)
        }
        .padding()
    }
    
    // Function to format time in "mm:ss"
    func timeString(from time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Function to start the timer
    func startTimer() {
        // Start a timer that updates the progress every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if progress < songDuration {
                progress += 1.0
            } else {
                timer?.invalidate() // Stop timer when song finishes
                isPlaying = false // Stop music when song finishes
            }
        }
    }
}

struct MusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
