import Foundation
import CoreLocation

class WeatherDetailVM: ObservableObject {
  private let weatherService: WeatherDataServiceProtocol
  
  @Published var weather: WeatherModel?
  @Published var isLoading = false
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
  
  init(weatherService: WeatherDataServiceProtocol) {
    self.weatherService = weatherService
  }
  
  func handleShowCityListButtonTap() {
    self.isLocationButtonTapped = false
    self.showCityList.toggle()
  }
  
  // fetch weather data
  @MainActor
  func fetchWeather() async {
    do {
      self.weather = try await self.weatherService.fetchData(city: self.selectedCity)
    } catch {
      print(error.localizedDescription)
    }
  }
  
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
  
  func handleLocatonButtonTap() {
    if !isLocationButtonTapped {
      selectedCity = ""
      isLocationButtonTapped = true
    }
  }
}
