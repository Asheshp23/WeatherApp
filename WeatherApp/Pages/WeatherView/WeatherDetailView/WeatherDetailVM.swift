import Foundation
import CoreLocation

class WeatherDetailVM: ObservableObject {
  private let weatherService = WeatherData.shared

  @Published var weather = WeatherModel()
  @Published var isLoading = false
  @Published var selectedCity = "Toronto"
  @Published var showCityList = false
  @Published var showSettings = false
  @Published var tempUnit : TemperatureUnit = .celcius
  @Published var isLocationButtonTapped = false

  var temperature: String {
    return Helper.formatTemperature(tempUnit == .celcius ? self.weather.current.tempC : self.weather.current.tempF, unit: tempUnit)
  }

  var feelslike: String {
    return Helper.formatTemperature(tempUnit == .celcius ? self.weather.current.feelslikeC : self.weather.current.feelslikeF, unit: tempUnit)
  }

  var lastUpdatedAt: String {
   return Helper.decodeDate(dateAsString: self.weather.current.lastUpdated) ?? "Not available"
  }

  // fetch weather data
  @MainActor
  func fetchWeather() async {
    self.isLoading = true
    if let weatherData = await self.weatherService.getWeather(city: self.selectedCity,
                                                              tempUnit: self.tempUnit.rawValue) {
      self.weather = weatherData
      self.isLoading = false
    }
  }
}
