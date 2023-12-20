import WidgetKit
import Intents
import SwiftUI

class Provider: IntentTimelineProvider {
  private let weatherService: WeatherDataServiceProtocol
  @StateObject var locationManager = LocationManager()
  
  init(weatherService: WeatherDataServiceProtocol) {
    self.weatherService = weatherService
  }
  
  func placeholder(in context: Context) -> SimpleEntry {
    return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), weatherData: nil)
  }
  
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let entry = SimpleEntry(date: Date(), configuration: configuration, weatherData: nil)
    completion(entry)
  }
  
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
    Task {
      let response = await self.weatherService.getWeather(city: "Brampton")
      switch response {
      case .success(let weatherData):
        if let weatherData {
          let entry = SimpleEntry(date: Date(), configuration: configuration, weatherData: weatherData)
          let timeline = Timeline(entries: [entry], policy: .never)
          completion(timeline)
        }
      case .failure(_):
        let entry = SimpleEntry(date: Date(), configuration: configuration, weatherData: nil)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
      }
    }
  }
}
