import WidgetKit
import Intents
import SwiftUI

class Provider: IntentTimelineProvider {
  private let weatherService: WeatherDataServiceProtocol
  var locationManager = WidgetLocationManager()
  
  init(weatherService: WeatherDataServiceProtocol) {
    self.weatherService = weatherService
  }
  
  func placeholder(in context: Context) -> SimpleEntry {
    return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), weatherData: nil, backgroundColor: .white)
  }
  
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let entry = SimpleEntry(date: Date(), configuration: configuration, weatherData: nil, backgroundColor: .white)
    completion(entry)
  }
  
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
    Task {
      do {
        if let location = locationManager.location,
           let cityName = try await getCityNameFrom(location) {
          if !cityName.isEmpty {
            let weatherData: WeatherModel = try await weatherService.fetchData(city: cityName)
           
            
            let updateInterval = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
            let entry = SimpleEntry(date: Date(), configuration: configuration, weatherData: weatherData, backgroundColor: Color.random)
            let timeline = Timeline(entries: [entry], policy: .after(updateInterval))
            
            completion(timeline)
          } else {
            let entry = SimpleEntry(date: Date(), configuration: configuration, weatherData: nil,  backgroundColor: .green)
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
          }
        }
      } catch {
        let entry = SimpleEntry(date: Date(), configuration: configuration, weatherData: nil, backgroundColor: .gray)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
      }
    }
  }
  
  func getCityNameFrom(_ location: CLLocation) async throws -> String? {
    do {
      let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
      
      guard let city = placemarks.first?.locality else {
        throw LocationError.noCityFound
      }
      return city
    } catch {
      return nil
    }
  }
}

extension Color {
  static var random: Color {
    let red = Double.random(in: 0.0...1.0)
    let green = Double.random(in: 0.0...1.0)
    let blue = Double.random(in: 0.0...1.0)
    
    return Color(red: red, green: green, blue: blue)
  }
}
