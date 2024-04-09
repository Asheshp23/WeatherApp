import SwiftUI
import WidgetKit
import Intents

struct WeatherWidgetEntryView: View {
  var entry: Provider.Entry
  
  var body: some View {
    ZStack {
      ContainerRelativeShape()
        .fill(Color.indigo.opacity(0.5))
      VStack {
        if let weatherData = entry.weatherData {
          Text("\(weatherData.location.name)")
            .font(.title3.bold())
            .foregroundColor(.white.adaptedTextColor())
          Text("\(weatherData.current.tempC, specifier: "%.0f")°C")
            .font(.title2.bold())
            .foregroundColor(.white.adaptedTextColor())
          Text("\(weatherData.current.condition.text)")
            .font(.callout.bold())
            .foregroundColor(.white.adaptedTextColor())
        } else {
          Text("Toronto")
            .font(.title3.bold())
            .foregroundColor(.white.adaptedTextColor())
          Text("\(12.0, specifier: "%.0f")°C")
            .font(.title2.bold())
            .foregroundColor(.white.adaptedTextColor())
          Text("Sunny")
            .font(.callout.bold())
            .foregroundColor(.white.adaptedTextColor())
        }
      }
    }
    .widgetBackground(Color.indigo.opacity(0.5))
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
