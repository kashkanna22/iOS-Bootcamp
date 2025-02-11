import SwiftUI

struct ContentView: View {
    @State private var isPlaying = false
    @State private var isShuffled = false
    @State private var isRepeated = false
    @State private var progress: Double = 0.0
    let songDuration: Double = 225.0 // Cry for Me by The Weeknd (3 minutes 45 seconds)

    var body: some View {
        VStack(spacing: 20) {
            Image("cry_for_me_album_cover")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .cornerRadius(15)
            
            Text("Cry for Me")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("The Weeknd")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Slider(value: $progress, in: 0...songDuration)
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
}

struct MusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
