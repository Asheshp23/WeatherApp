import Foundation

class WeatherDetailVM: ObservableObject {
  private let weatherService = WeatherService.shared

  @Published var weather = WeatherModel()
  @Published var isLoading = false
  @Published var selectedCity = "Toronto"
  @Published var showCityList = false
  @Published var showSettings = false
  @Published var tempUnit : temperatureUnit = .celcius

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
  func fetchWeather() async {
    self.isLoading = true
    let city = getCityNameAssosiatedWithCityCode(city: self.selectedCity)
    if let weatherData = await self.weatherService.getWeather(city: city,
                                                              tempUnit: self.tempUnit.rawValue) {
      self.weather = weatherData
      self.isLoading.toggle()

    }
  }
}
