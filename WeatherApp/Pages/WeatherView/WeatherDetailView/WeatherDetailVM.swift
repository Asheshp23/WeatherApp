import Foundation

class WeatherDetailVM: ObservableObject {
  private let weatherService = WeatherService.shared

  @Published var weather = WeatherModel()
  @Published var isLoading = false

  // fetch city code from city name
  func getCityNameAssosiatedWithCityCode(city : String) -> String {
    switch city {
    case "Calgary":
      return "CAAB0049"
    case "Montreal":
      return "CAON0423"
    case "Ottawa":
      return "CAON0512"
    case "Vancouver":
      return "CABC0308"
    default:
      return "CAON0696"
    }
  }

  // fetch weather data
  @MainActor
  func fetchWeather(by city: String, unit: temperatureUnit) async {
    self.isLoading = true
    let selectedCity    = getCityNameAssosiatedWithCityCode(city: city)
    let temperatureUnit = unit.rawValue
    if let weatherData = await self.weatherService.getWeather(city: selectedCity,
                                                              tempUnit: temperatureUnit) {
      self.weather = weatherData
      self.isLoading.toggle()

    }
  }
}
