import WidgetKit
import SwiftUI
import Intents

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
      IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider(weatherService: WeatherDataService())) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall])
    }
}

struct WeatherWidget_Previews: PreviewProvider {
    static var previews: some View {
      WeatherWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), weatherData: nil, backgroundColor: .gray))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
