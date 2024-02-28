import Foundation

enum TemperatureUnit  : String, CaseIterable, Identifiable {
  var id: String { self.rawValue }
  case celcius = "c"
  case fahrenheit = "f"
}

struct WeatherModel: Codable {
  let location: LocationModel
  let current: CurrentWeatherModel
}
