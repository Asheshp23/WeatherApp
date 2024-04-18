import SwiftUI
import WidgetKit
import Intents

struct WeatherWidgetEntryView: View {
  var entry: Provider.Entry
  
  var body: some View {
    GeometryReader { reader in
      ZStack {
        VStack(alignment: .leading) {
          if let weatherData = entry.weatherData {
            HStack {
              Text("\(weatherData.location.name)")
                .font(.title3.bold())
                .foregroundColor(.white)
              Image(systemName: "location.fill")
                .foregroundColor(.white)
            }
            Text("\(weatherData.current.tempC, specifier: "%.0f")°C")
              .font(.title2.bold())
              .foregroundColor(.white)
            if let image = entry.conditionImage {
              image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
            }
            Text("\(weatherData.current.condition.text)")
              .font(.callout.bold())
              .foregroundColor(.white)
          } else {
            Text("Toronto")
              .font(.title3.bold())
              .foregroundColor(.white)
            Text("\(12.0, specifier: "%.0f")°C")
              .font(.title2.bold())
              .foregroundColor(.white)
            Text("Sunny")
              .font(.callout.bold())
              .foregroundColor(.white)
          }
        }
      }
    }
    .widgetBackground(Color.gray)
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
