import SwiftUI
import WidgetKit
import Intents

struct WeatherWidgetEntryView: View {
  var entry: Provider.Entry
  
  var body: some View {
    ZStack {
      ContainerRelativeShape()
        .fill(Color.indigo.gradient)
      VStack {
        if let weatherData = entry.weatherData {
          Text("\(weatherData.location.name)")
            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/.bold())
            .foregroundColor(.white)
          Text("\(weatherData.current.feelslikeC, specifier: "%.1f")°C")
            .font(.title2.bold())
            .foregroundColor(.white)
        }
      }
    }
  }
}
