import WidgetKit
import Intents
import SwiftUI

class Provider: IntentTimelineProvider {
    private let weatherService = WeatherData.shared
    @StateObject var locationManager = LocationManager()
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), weatherData: nil)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, weatherData: nil)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        Task {
            if let weatherData = await self.weatherService.getWeather(city: "Brampton") {
                let entry = SimpleEntry(date: Date(), configuration: configuration, weatherData: weatherData)
                let timeline = Timeline(entries: [entry], policy: .never)
                completion(timeline)
            }
        }
    }
}
