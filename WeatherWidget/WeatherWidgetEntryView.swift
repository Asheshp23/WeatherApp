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
          Text("\(weatherData.current.tempC, specifier: "%.0f")°C")
            .font(.title2.bold())
            .foregroundColor(.white)
          Text("\(weatherData.current.condition.text)")
            .font(.callout.bold())
            .foregroundColor(.white)
        } else {
          Text("Loading...")
            .font(.title3.bold())
            .foregroundColor(.white)
            .padding(.top, 20)
        }
      }
    }
    .widgetBackground(entry.backgroundColor)
  }
}

extension View {
  func widgetBackground(_ backgroundView: some View) -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      return containerBackground(for: .widget) {
        backgroundView
      }
    } else {
      return background(backgroundView)
    }
  }
}
