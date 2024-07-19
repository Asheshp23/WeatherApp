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
              
              Image(systemName: "location.fill")
              
            }
            Text("\(weatherData.current.tempC, specifier: "%.0f")°C")
              .font(.title2.bold())
            
            if let image = entry.conditionImage {
              image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
            }
            Text("\(weatherData.current.condition.text)")
              .font(.callout.bold())
            
          } else {
            Text("Toronto")
              .font(.title3.bold())
            
            Text("\(12.0, specifier: "%.0f")°C")
              .font(.title2.bold())
            
            Text("Sunny")
              .font(.callout.bold())
          }
        }
      }
    }
    .widgetBackground(Color.white.opacity(0.5))
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
