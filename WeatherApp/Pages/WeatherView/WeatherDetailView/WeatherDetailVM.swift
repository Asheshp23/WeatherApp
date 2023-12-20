import Foundation
import CoreLocation

class WeatherDetailVM: ObservableObject {
  private let weatherService: WeatherDataServiceProtocol
  
  @Published var weather = WeatherModel()
  @Published var isLoading = false
  @Published var selectedCity = "Toronto"
  @Published var showCityList = false
  @Published var showSettings = false
  @Published var tempUnit : TemperatureUnit = .celcius
  @Published var isLocationButtonTapped = false
  @Published var cityName: String = ""
  @Published var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(20.0, -30.0)
  
  var temperature: String {
    return Helper.formatTemperature(tempUnit == .celcius ? self.weather.current.tempC : self.weather.current.tempF, unit: tempUnit)
  }
  
  var feelslike: String {
    return Helper.formatTemperature(tempUnit == .celcius ? self.weather.current.feelslikeC : self.weather.current.feelslikeF, unit: tempUnit)
  }
  
  var lastUpdatedAt: String {
    return Helper.decodeDate(dateAsString: self.weather.current.lastUpdated) ?? "Not available"
  }
  
  init(weatherService: WeatherDataServiceProtocol) {
    self.weatherService = weatherService
  }
  
  // fetch weather data
  @MainActor
  func fetchWeather() async {
    let response = await self.weatherService.getWeather(city: self.selectedCity)
    switch response {
    case .success(let weatherData):
      if let weatherData = weatherData {
        self.weather = weatherData
      }
    case .failure(let error):
      print(error.localizedDescription)
    }
  }
  
  func reverseGeocodeLocationAsync(_ location: CLLocation) async throws -> String {
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
  
  @MainActor
  func handleLocationUpdate(newValue: CLLocation) async {
    do {
      let city = try await reverseGeocodeLocationAsync(newValue)
      self.selectedCity = city
      await fetchWeather()
    } catch {
      if let locationError = error as? LocationError {
        switch locationError {
        case .noCityFound:
          // Handle the case when no city is found
          print("No city found")
        }
      } else {
        // Handle other errors
        print("Error: \(error)")
      }
    }
  }
}
