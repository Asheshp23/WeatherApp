import Foundation
import MapKit
import CoreLocation

final class WeatherDetailVM: ObservableObject {
  let weatherService: WeatherServiceProtocol
  
  @Published var weather: WeatherModel?
  @Published var isLoading = false
  @Published var forecast: WeatherModel?
  @Published var isForecastLoading = false
  @Published var forecastFailed = false
  @Published var selectedCity = ""
  @Published var showCityList = false
  @Published var showSettings = false
  @Published var tempUnit : TemperatureUnit = .celcius
  @Published var isLocationButtonTapped = true
  @Published var cityName: String = ""
  @Published var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(20.0, -30.0)
  @Published var selectedCityLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(20.0, -30.0)
  
  var temperature: String {
    guard let weather = weather else { return localizedString("not_available") }
    let temperatureValue = tempUnit == .celcius ? weather.current.tempC : weather.current.tempF
    return Helper.formatTemperature(temperatureValue, unit: tempUnit)
  }
  
  var feelslike: String {
    guard let weather = weather else { return localizedString("not_available") }
    let feelslikeValue = tempUnit == .celcius ? weather.current.feelslikeC : weather.current.feelslikeF
    return Helper.formatTemperature(feelslikeValue, unit: tempUnit)
  }
  
  var lastUpdatedAt: String {
    guard let weather = weather else { return localizedString("not_available") }
    let lastUpdatedDate = Date(timeIntervalSince1970: TimeInterval(weather.current.lastUpdatedEpoch))
    return Helper.timeAgoSince(lastUpdatedDate)
  }
  
  var temperatureUnitSymbol: String {
    tempUnit == .celcius ? "C" : "F"
  }
  
  var conditionSymbolName: String {
    guard let weather = weather else { return "cloud.fill" }
    return weather.current.condition.weatherCondition.symbolName(isDay: weather.current.isDay == 1)
  }
  
  var windText: String {
    guard let weather = weather else { return localizedString("not_available") }
    let speed = tempUnit == .celcius ? weather.current.windKph : weather.current.windMph
    let unit = tempUnit == .celcius ? "km/h" : "mph"
    return "\(Int(speed.rounded())) \(unit) \(weather.current.windDir)"
  }
  
  var humidityText: String {
    guard let weather = weather else { return localizedString("not_available") }
    return "\(weather.current.humidity)%"
  }
  
  var uvIndexText: String {
    guard let weather = weather else { return localizedString("not_available") }
    return "\(Int(weather.current.uv.rounded()))"
  }
  
  var uvDescription: String {
    guard let weather = weather else { return "" }
    switch weather.current.uv {
    case ..<3: return "Low"
    case 3..<6: return "Moderate"
    case 6..<8: return "High"
    case 8..<11: return "Very High"
    default: return "Extreme"
    }
  }
  
  var visibilityText: String {
    guard let weather = weather else { return localizedString("not_available") }
    let distance = tempUnit == .celcius ? weather.current.visKm : weather.current.visMiles
    let unit = tempUnit == .celcius ? "km" : "mi"
    return "\(Int(distance.rounded())) \(unit)"
  }
  
  var pressureText: String {
    guard let weather = weather else { return localizedString("not_available") }
    if tempUnit == .celcius {
      return "\(Int(weather.current.pressureMb.rounded())) hPa"
    }
    return String(format: "%.2f inHg", weather.current.pressureIn)
  }
  
  init(weatherService: WeatherServiceProtocol, initialCity: String? = nil, initialWeather: WeatherModel? = nil) {
    self.weatherService = weatherService
    if let initialCity {
      self.selectedCity = initialCity
    }
    self.weather = initialWeather
  }
  
  @MainActor
  func handleShowCityListButtonTap() {
    self.isLocationButtonTapped = false
    self.showCityList = true
  }
  
  // fetch weather data
  @MainActor
  func fetchWeather() {
    isLoading = true
    Task {
      defer { isLoading = false }
      do {
        self.weather = try await self.weatherService.fetchCurrentWeather(for: selectedCity)
        UserDefaults.standard.set(selectedCity, forKey: "lastSelectedCity")
      } catch {
        print(error.localizedDescription)
      }
    }
  }
  
  // fetch forecast + alerts, once per city, shared by Hourly/Daily/Alerts screens
  @MainActor
  func loadForecastIfNeeded() {
    guard forecast == nil, !isForecastLoading else { return }
    isForecastLoading = true
    forecastFailed = false
    Task {
      defer { isForecastLoading = false }
      do {
        self.forecast = try await self.weatherService.fetchForecast(for: selectedCity, days: 7)
      } catch {
        print(error.localizedDescription)
        forecastFailed = true
      }
    }
  }

  @MainActor
  func getCityNameFrom(_ location: CLLocation) async throws -> String {
    do {
      let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
      
      guard let city = placemarks.first?.locality else {
        throw LocationError.noCityFound
      }
      
      return city
    } catch {
      throw error
    }
  }
  
  func getLocationFromCityName() {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(selectedCity) { placemarks, error in
      guard let placemark = placemarks?.first, error == nil else {
        return
      }
      
      if let location = placemark.location?.coordinate {
        self.selectedCityLocation = location
      }
    }
  }
  
  @MainActor
  func handleLocationUpdate(newValue: CLLocation) async {
    do {
      let city = try await getCityNameFrom(newValue)
      self.selectedCity = city
    } catch {
      if let locationError = error as? LocationError {
        switch locationError {
        case .noCityFound:
          print("No city found")
        }
      } else {
        print("Error: \(error)")
      }
    }
  }
  
  private func localizedString(_ key: String) -> String {
    // Localize string based on the current locale
    return NSLocalizedString(key, comment: "")
  }
  
  @MainActor
  func handleLocationButtonTap() {
    cityName = ""
    isLocationButtonTapped = true
  }
}
