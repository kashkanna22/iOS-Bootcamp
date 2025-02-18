import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.gray]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                CurrentWeatherView()
                HourlyForecastView()
                WeeklyForecastView()
            }
            .padding()
        }
    }
}

struct CurrentWeatherView: View {
    var body: some View {
        VStack(spacing: 5) {
            Text("📍Home")
                .font(.system(size:20, weight: .bold))
                .foregroundColor(.white)
            Text("Chapel Hill")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Image(systemName: "cloud.sun.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.yellow)
            
            Text(" 72°")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.white)
            Text("Partly Cloudy")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.blue)
            Text("H: 72° L: 58°")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct HourlyForecastView: View {
    let hours = ["Now", "2PM", "3PM", "4PM", "5PM"]
    let temperatures = [72, 68, 65, 70, 67]
    let icons = ["cloud.sun.fill", "cloud.rain.fill", "cloud.sun.fill", "cloud.bolt.fill", "sun.max.fill"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(0..<hours.count, id: \.self) { index in
                    HourlyRowView(time: hours[index], icon: icons[index], temp: temperatures[index])
                }
            }
        }
        .padding()
    }
}

struct HourlyRowView: View {
    let time: String
    let icon: String
    let temp: Int
    
    var body: some View {
        VStack {
            Text(time)
                .foregroundColor(.white)
            
            Image(systemName: icon)
                .foregroundColor(icon.contains("rain") ? .blue : icon.contains("snow") ? .white : icon.contains("bolt") ? .yellow : .yellow)
            
            Text("\(temp)°")
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
    }
}

struct WeeklyForecastView: View {
    let days = ["Mon", "Tue", "Wed", "Thu", "Fri"]
    let temperatures = [(72, 58), (68, 55), (30, 25), (70, 60), (67, 53)] // Sub-freezing temps for snow
    let icons = ["cloud.sun.fill", "cloud.rain.fill", "cloud.snow.fill", "cloud.bolt.fill", "sun.max.fill"]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("5-Day Forecast")
                .foregroundColor(.white)
                .font(.headline)
                .padding(.bottom, 5)
            
            ForEach(0..<days.count, id: \.self) { index in
                WeeklyRowView(day: days[index], icon: icons[index], high: temperatures[index].0, low: temperatures[index].1)
            }
        }
    }
}

struct WeeklyRowView: View {
    let day: String
    let icon: String
    let high: Int
    let low: Int
    
    var body: some View {
        HStack {
            Text(day)
                .foregroundColor(.white)
                .frame(width: 50, alignment: .leading)
            
            Image(systemName: icon)
                .foregroundColor(icon.contains("rain") ? .blue : icon.contains("snow") ? .white : icon.contains("bolt") ? .yellow : .yellow)
                .frame(width: 50)
            
            Spacer()
            
            Text("\(high)°")
                .foregroundColor(.white)
                .frame(width: 50)
            
            TemperatureBarView(high: high, low: low)
                .frame(height: 10)
                .padding(.horizontal, 10)
            
            Text("\(low)°")
                .foregroundColor(.white)
                .frame(width: 50, alignment: .trailing)
        }
        .padding(.vertical, 5)
    }
}

struct TemperatureBarView: View {
    let high: Int
    let low: Int
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background bar (full width)
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: geo.size.width)
                
                
                let minTemp: CGFloat = 0
                let maxTemp: CGFloat = 100
                
                let lowPosition = CGFloat(low - Int(minTemp)) / (maxTemp - minTemp) * geo.size.width
                let highPosition = CGFloat(high - Int(minTemp)) / (maxTemp - minTemp) * geo.size.width
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                    .frame(width: highPosition - lowPosition)
                    .offset(x: lowPosition)
            }
        }
    }
}

#Preview {
    ContentView()
}
