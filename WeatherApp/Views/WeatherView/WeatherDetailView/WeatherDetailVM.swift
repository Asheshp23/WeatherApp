import Foundation
import MapKit
import CoreLocation

final class WeatherDetailVM: ObservableObject {
  let weatherService: WeatherServiceProtocol
  let quoteService: WeatherQuoteServiceProtocol
  
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
  @Published var weatherQuote: String = ""
  @Published var isGeneratingQuote = false
  
  var temperature: String {
    guard let weather = weather else { return notAvailableText }
    let temperatureValue = tempUnit == .celcius ? weather.current.tempC : weather.current.tempF
    return Helper.formatTemperature(temperatureValue, unit: tempUnit)
  }
  
  var feelslike: String {
    guard let weather = weather else { return notAvailableText }
    let feelslikeValue = tempUnit == .celcius ? weather.current.feelslikeC : weather.current.feelslikeF
    return Helper.formatTemperature(feelslikeValue, unit: tempUnit)
  }
  
  var lastUpdatedAt: String {
    guard let weather = weather else { return notAvailableText }
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
    guard let weather = weather else { return notAvailableText }
    let speed = tempUnit == .celcius ? weather.current.windKph : weather.current.windMph
    let unit = tempUnit == .celcius ? "km/h" : "mph"
    return "\(Helper.localizedNumber(Int(speed.rounded()))) \(unit) \(weather.current.windDir)"
  }
  
  var humidityText: String {
    guard let weather = weather else { return notAvailableText }
    return "\(Helper.localizedNumber(weather.current.humidity))%"
  }
  
  var uvIndexText: String {
    guard let weather = weather else { return notAvailableText }
    return Helper.localizedNumber(Int(weather.current.uv.rounded()))
  }
  
  var uvDescription: String {
    guard let weather = weather else { return "" }
    switch weather.current.uv {
    case ..<3: return String(localized: "uv_low", defaultValue: "Low")
    case 3..<6: return String(localized: "uv_moderate", defaultValue: "Moderate")
    case 6..<8: return String(localized: "uv_high", defaultValue: "High")
    case 8..<11: return String(localized: "uv_very_high", defaultValue: "Very High")
    default: return String(localized: "uv_extreme", defaultValue: "Extreme")
    }
  }
  
  var visibilityText: String {
    guard let weather = weather else { return notAvailableText }
    let distance = tempUnit == .celcius ? weather.current.visKm : weather.current.visMiles
    let unit = tempUnit == .celcius ? "km" : "mi"
    return "\(Helper.localizedNumber(Int(distance.rounded()))) \(unit)"
  }
  
  var pressureText: String {
    guard let weather = weather else { return notAvailableText }
    if tempUnit == .celcius {
      return "\(Helper.localizedNumber(Int(weather.current.pressureMb.rounded()))) hPa"
    }
    return "\(Helper.localizedNumber(weather.current.pressureIn, fractionDigits: 2)) inHg"
  }
  
  // Today's astro data (sunrise/sunset/moon), sourced from the 7-day forecast.
  var todayAstro: AstroModel? {
    forecast?.forecast?.forecastday.first?.astro
  }
  
  var sunriseText: String {
    guard let sunrise = todayAstro?.sunrise else { return notAvailableText }
    return Helper.localizedTime(sunrise)
  }
  
  var sunsetText: String {
    guard let sunset = todayAstro?.sunset else { return notAvailableText }
    return Helper.localizedTime(sunset)
  }
  
  var moonPhaseText: String {
    guard let astro = todayAstro else { return notAvailableText }
    return "\(astro.localizedMoonPhase) · \(Helper.localizedNumber(Int(astro.moonIllumination.rounded())))%"
  }
  
  var moonPhaseSymbolName: String {
    todayAstro?.moonPhaseSymbolName ?? "moonphase.full.moon"
  }
  
  var dayOfYearText: String {
    let today = Date()
    let dayNumber = Helper.localizedNumber(today.dayOfYear)
    let totalDays = Helper.localizedNumber(today.daysInYear)
    let format = String(localized: "day_of_year_value", defaultValue: "Day %@ of %@")
    return String(format: format, dayNumber, totalDays)
  }
  
  var airQuality: AirQualityModel? {
    weather?.current.airQuality
  }
  
  var aqiCategoryText: String {
    airQuality?.usEpaCategory ?? notAvailableText
  }
  
  var aqiSymbolName: String {
    airQuality?.symbolName ?? "aqi.medium"
  }
  
  init(weatherService: WeatherServiceProtocol, quoteService: WeatherQuoteServiceProtocol = WeatherQuoteService(), initialCity: String? = nil, initialWeather: WeatherModel? = nil) {
    self.weatherService = weatherService
    self.quoteService = quoteService
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
        loadForecastIfNeeded()
        generateQuoteIfNeeded()
      } catch {
        print(error.localizedDescription)
      }
    }
  }
  
  // generate a short Apple Intelligence quote about the current weather, once per city
  @MainActor
  func generateQuoteIfNeeded() {
    guard !isGeneratingQuote, let weather = weather else { return }
    isGeneratingQuote = true
    Task {
      defer { isGeneratingQuote = false }
      weatherQuote = await quoteService.generateQuote(
        cityName: weather.location.name,
        condition: weather.current.condition.text,
        temperature: tempUnit == .celcius ? "\(Int(weather.current.tempC.rounded()))" : "\(Int(weather.current.tempF.rounded()))"
      )
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
  
  private var notAvailableText: String {
    String(localized: "not_available", defaultValue: "Not available")
  }
  
  @MainActor
  func handleLocationButtonTap() {
    cityName = ""
    isLocationButtonTapped = true
  }
}
