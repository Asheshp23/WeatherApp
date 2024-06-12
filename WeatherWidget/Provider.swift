import WidgetKit
import Intents
import SwiftUI

class Provider: @preconcurrency IntentTimelineProvider {
  private let weatherService: WeatherDataServiceProtocol
  var locationManager = WidgetLocationManager()
  
  init(weatherService: WeatherDataServiceProtocol) {
    self.weatherService = weatherService
  }
  
  func placeholder(in context: Context) -> SimpleEntry {
    return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), weatherData: nil, conditionImage: nil)
  }
  
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let entry = SimpleEntry(date: Date(), configuration: configuration, weatherData: nil, conditionImage: nil)
    completion(entry)
  }
  
  @MainActor
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
    Task {
      do {
        if let location = locationManager.location,
           let cityName = try await getCityNameFrom(location) {
          if !cityName.isEmpty {
            let weatherData: WeatherModel = try await weatherService.fetchData(city: cityName)
            let updateInterval = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let image =  await loadImageFromURL(imageUrlString: "https:" + weatherData.current.condition.icon)
            let entry = SimpleEntry(date: Date(), configuration: configuration, weatherData: weatherData, conditionImage: image)
            let timeline = Timeline(entries: [entry], policy: .after(updateInterval))
           
            completion(timeline)
          } else {
            return
          }
        }
      } catch {
        return
      }
    }
  }
  
  private func loadImageFromURL(imageUrlString: String) async -> Image? {
      guard let url = URL(string: imageUrlString) else { return nil }
    do {
      let(data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
      if let image = UIImage(data: data) {
        return Image(uiImage: image)
      }
      return nil
    } catch {
      return nil
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
