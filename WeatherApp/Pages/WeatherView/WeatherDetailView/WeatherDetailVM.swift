import Foundation
import CoreLocation

class WeatherDetailVM: ObservableObject {
  private let weatherService = WeatherData.shared

  @Published var weather = WeatherModel()
  @Published var isLoading = false
  @Published var selectedCity = "Toronto"
  @Published var showCityList = false
  @Published var showSettings = false
  @Published var tempUnit : temperatureUnit = .celcius

  // fetch weather data
  @MainActor
  func fetchWeather() async {
    self.isLoading = true
    if let weatherData = await self.weatherService.getWeather(city: self.selectedCity,
                                                              tempUnit: self.tempUnit.rawValue) {
      self.weather = weatherData
      self.isLoading.toggle()
    }
  }
}
