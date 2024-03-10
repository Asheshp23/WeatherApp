import SwiftUI
import WidgetKit
import Intents

struct WeatherWidgetEntryView: View {
  var entry: Provider.Entry
  
  var body: some View {
    ZStack {
      ContainerRelativeShape()
        .fill(Gradient(colors: [.yellow, .orange.opacity(0.5)]))
      VStack {
        if let weatherData = entry.weatherData {
          Text("\(weatherData.location.name)")
            .font(.title3.bold())
            .foregroundColor(.white)
          Text("\(weatherData.current.feelslikeC, specifier: "%.0f")°C")
            .font(.title2.bold())
            .foregroundColor(.white)
        }
      }
    }
  }
}
