import Foundation

@MainActor
@Observable
final class AppBootstrapService {
  static let defaultCity = "London"
  private static let lastSelectedCityKey = "lastSelectedCity"
  private static let fallbackTimeout: Duration = .seconds(2.5)

  private(set) var isFinished = false
  private(set) var prefetchedWeather: WeatherModel?
  private(set) var prefetchedCity: String?
  private(set) var hasSavedSession = false

  let locationManager = LocationManager()

  private let weatherService: WeatherServiceProtocol

  init(weatherService: WeatherServiceProtocol = WeatherDataService()) {
    self.weatherService = weatherService
  }

  /// Runs permission checks, session verification, and a weather pre-fetch,
  /// but never blocks the launch screen for longer than `fallbackTimeout`.
  func run() async {
    await withTaskGroup(of: Void.self) { group in
      group.addTask { await self.performBootstrapWork() }
      group.addTask { try? await Task.sleep(for: Self.fallbackTimeout) }
      await group.next()
      group.cancelAll()
    }
    isFinished = true
  }

  private func performBootstrapWork() async {
    verifySavedSession()
    locationManager.requestLocation()

    let city = prefetchedCity ?? Self.defaultCity
    do {
      let weather = try await weatherService.fetchCurrentWeather(for: city)
      guard !Task.isCancelled else { return }
      prefetchedWeather = weather
      prefetchedCity = city
    } catch {
      print("Launch pre-fetch failed: \(error.localizedDescription)")
    }
  }

  private func verifySavedSession() {
    if let savedCity = UserDefaults.standard.string(forKey: Self.lastSelectedCityKey), !savedCity.isEmpty {
      hasSavedSession = true
      prefetchedCity = savedCity
    }
  }
}
