import Foundation
import MapKit
import CoreLocation

final class WeatherDetailVM: ObservableObject {
  let weatherService: WeatherServiceProtocol
  let quoteService: WeatherQuoteServiceProtocol
  let briefingService: WeatherBriefingServiceProtocol
  
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
  /// The last current-weather fetch failure, kept so the UI can explain what happened.
  @Published var weatherError: Error?
  /// Apple Intelligence's wording of the briefing, tied to the rule text it was made from.
  @Published var polishedBriefing: PolishedBriefing?

  struct PolishedBriefing: Equatable {
    let source: String
    let text: String
  }
  
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
  
  // MARK: Presentation helpers for the redesigned weather screen (derived only, no fetching)
  
  var isDay: Bool {
    weather?.current.isDay != 0
  }
  
  var conditionText: String {
    weather?.current.condition.text ?? notAvailableText
  }
  
  /// The forecast city's time zone, so hour labels show local time there, not on the device.
  var cityTimeZone: TimeZone? {
    (forecast ?? weather).flatMap { TimeZone(identifier: $0.location.tzId) }
  }
  
  var today: ForecastDay? {
    forecast?.forecast?.forecastday.first
  }
  
  var forecastDays: [ForecastDay] {
    forecast?.forecast?.forecastday ?? []
  }
  
  var alerts: [WeatherAlert] {
    forecast?.alerts?.alert ?? []
  }
  
  func formattedTemperature(celsius: Double, fahrenheit: Double) -> String {
    let value = tempUnit == .celcius ? celsius : fahrenheit
    return "\(Helper.localizedNumber(Int(value.rounded())))°"
  }
  
  var todayHighText: String? {
    guard let day = today?.day else { return nil }
    return formattedTemperature(celsius: day.maxtempC, fahrenheit: day.maxtempF)
  }
  
  var todayLowText: String? {
    guard let day = today?.day else { return nil }
    return formattedTemperature(celsius: day.mintempC, fahrenheit: day.mintempF)
  }
  
  /// Today's chance of rain or snow, only when it's high enough to be worth mentioning.
  var meaningfulPrecipitationChance: Int? {
    guard let day = today?.day else { return nil }
    let chance = max(day.dailyChanceOfRain, day.dailyChanceOfSnow)
    return chance >= Self.meaningfulPrecipitationThreshold ? chance : nil
  }
  
  /// Below this, a precipitation percentage is noise rather than information.
  static let meaningfulPrecipitationThreshold = 20
  
  /// The next `count` hours starting with the current hour, spanning into tomorrow if needed.
  func upcomingHours(_ count: Int) -> [HourModel] {
    // Keep the hour that contains "now". Comparing epochs (not device-local hour starts) keeps this
    // right for cities on half-hour offsets, such as India.
    let now = Int(Date().timeIntervalSince1970)
    let hours = forecastDays.flatMap(\.hour).filter { $0.timeEpoch + 3600 > now }
    return Array(hours.prefix(count))
  }

  // MARK: Day dial and briefing (derived only)

  private func displayTemperature(celsius: Double, fahrenheit: Double) -> String {
    formattedTemperature(celsius: celsius, fahrenheit: fahrenheit)
  }

  var dayDialModel: DayDialModel? {
    guard let weather else { return nil }
    let hours = upcomingHours(24)
    guard hours.count == 24 else { return nil }
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = cityTimeZone ?? .current
    let dialHours = hours.map { hour in
      DialHour(
        epoch: hour.timeEpoch,
        hourOfDay: calendar.component(.hour, from: Date(timeIntervalSince1970: TimeInterval(hour.timeEpoch))),
        temperatureC: hour.tempC,
        displayTemperature: displayTemperature(celsius: hour.tempC, fahrenheit: hour.tempF),
        precipitationChance: max(hour.chanceOfRain, hour.chanceOfSnow),
        isSnow: hour.chanceOfSnow > hour.chanceOfRain,
        conditionSymbol: hour.condition.weatherCondition.symbolName(isDay: hour.isDay == 1)
      )
    }
    let now = calendar.dateComponents([.hour, .minute], from: Date())
    let nowFraction = (Double(now.hour ?? 0) + Double(now.minute ?? 0) / 60) / 24
    return DayDialModel(
      hours: dialHours,
      nowFraction: nowFraction,
      sunriseFraction: todayAstro.flatMap { Helper.dayFraction(fromAPITime: $0.sunrise) },
      sunsetFraction: todayAstro.flatMap { Helper.dayFraction(fromAPITime: $0.sunset) },
      isDay: isDay,
      currentTemperature: displayTemperature(celsius: weather.current.tempC, fahrenheit: weather.current.tempF),
      conditionText: conditionText,
      conditionSymbol: conditionSymbolName,
      sunriseText: todayAstro == nil ? nil : sunriseText,
      sunsetText: todayAstro == nil ? nil : sunsetText,
      timeZone: cityTimeZone
    )
  }

  var briefingInput: BriefingInput? {
    guard let weather else { return nil }
    let hours = upcomingHours(DayBriefing.lookahead)
    guard !hours.isEmpty else { return nil }
    let current = weather.current
    return BriefingInput(
      hours: hours.map { hour in
        BriefingHour(epoch: hour.timeEpoch, temperatureC: hour.tempC,
                     displayTemperature: displayTemperature(celsius: hour.tempC, fahrenheit: hour.tempF),
                     rainChance: hour.chanceOfRain, snowChance: hour.chanceOfSnow)
      },
      currentTemperatureC: current.tempC,
      displayCurrentTemperature: displayTemperature(celsius: current.tempC, fahrenheit: current.tempF),
      feelsLikeC: current.feelslikeC,
      displayFeelsLike: displayTemperature(celsius: current.feelslikeC, fahrenheit: current.feelslikeF),
      uvIndex: current.uv,
      isDay: isDay,
      windKph: current.windKph,
      aqiIndex: current.airQuality?.usEpaIndex,
      alertEvent: alerts.first?.event,
      precipitatingNow: current.condition.weatherCondition.isPrecipitating,
      snowingNow: current.condition.weatherCondition.isSnow
    )
  }

  /// The rule-based briefing in the user's language and unit.
  var ruleBriefing: String? {
    guard let briefingInput else { return nil }
    let timeZone = cityTimeZone
    let text = DayBriefing.make(briefingInput) { Helper.localizedHour($0, timeZone: timeZone) }
    return text.isEmpty ? nil : text
  }

  /// What the screen shows: the Apple Intelligence wording if it was made from the current rule text.
  var briefingText: String? {
    guard let ruleBriefing else { return nil }
    if let polishedBriefing, polishedBriefing.source == ruleBriefing { return polishedBriefing.text }
    return ruleBriefing
  }

  var isBriefingAIGenerated: Bool {
    guard let ruleBriefing, let polishedBriefing else { return false }
    return polishedBriefing.source == ruleBriefing
  }

  /// Asks Apple Intelligence to reword the current briefing. Safe to call repeatedly.
  @MainActor
  func polishBriefing() async {
    guard let source = ruleBriefing, polishedBriefing?.source != source else { return }
    guard let text = await briefingService.polish(source), ruleBriefing == source else { return }
    polishedBriefing = PolishedBriefing(source: source, text: text)
  }
  
  enum LoadIssue: Equatable {
    case missingAPIKey
    case offline
    case rejected
    case unknown
  }
  
  /// Classifies the last failure using only information already available on the client.
  /// The network layer doesn't expose HTTP status codes, so an unknown city and an invalid key
  /// both surface as `.rejected`.
  var loadIssue: LoadIssue? {
    guard let weatherError else { return nil }
    if Helper.getApiKey() == "not found" || Helper.getApiKey().isEmpty { return .missingAPIKey }
    if weatherError is URLError { return .offline }
    if case NetworkError.invalidResponse? = weatherError as? NetworkError { return .rejected }
    return .unknown
  }
  
  init(weatherService: WeatherServiceProtocol, quoteService: WeatherQuoteServiceProtocol = WeatherQuoteService(), briefingService: WeatherBriefingServiceProtocol = WeatherBriefingService(), initialCity: String? = nil, initialWeather: WeatherModel? = nil) {
    self.weatherService = weatherService
    self.quoteService = quoteService
    self.briefingService = briefingService
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
        self.weatherError = nil
        UserDefaults.standard.set(selectedCity, forKey: "lastSelectedCity")
        loadForecastIfNeeded()
        generateQuoteIfNeeded()
      } catch {
        print(error.localizedDescription)
        self.weatherError = error
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
