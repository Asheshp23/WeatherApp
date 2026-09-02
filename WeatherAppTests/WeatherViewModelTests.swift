import Testing
@testable import WeatherApp

class MockWeatherDataService: WeatherServiceProtocol {
    // Define a property to hold the mock weather model
    let mockWeatherModel: WeatherModel
    let mockSearchResults: [CitySearchResult]

    // Initialize the mock weather model with mock data
    init(searchResults: [CitySearchResult] = CitySearchResult.previewFixtures) {
        self.mockSearchResults = searchResults
        self.mockWeatherModel = WeatherModel(
            location: LocationModel(
                name: "London",
                region: "City of London, Greater London",
                country: "United Kingdom",
                lat: 51.52,
                lon: -0.11,
                tzId: "Europe/London",
                localtimeEpoch: 1709235102,
                localtime: "2024-02-29 19:31"
            ),
            current: CurrentWeatherModel(
                lastUpdatedEpoch: 1709235000,
                lastUpdated: "2024-02-29 19:30",
                tempC: 7.0,
                tempF: 44.6,
                isDay: 0,
                condition: ConditionModel(
                    text: "Clear",
                    icon: "//cdn.weatherapi.com/weather/64x64/night/113.png",
                    code: 1000
                ),
                windMph: 6.9,
                windKph: 11.2,
                windDegree: 240,
                windDir: "WSW",
                pressureMb: 1002.0,
                pressureIn: 29.59,
                precipMm: 0.02,
                precipIn: 0.0,
                humidity: 76,
                cloud: 0,
                feelslikeC: 5.8,
                feelslikeF: 42.4,
                visKm: 10.0,
                visMiles: 6.0,
                uv: 1.0,
                gustMph: 11.4,
                gustKph: 18.4
            )
        )
    }
    
    // Implement the fetchCurrentWeather method of the WeatherServiceProtocol
    func fetchCurrentWeather(for city: String) async throws -> WeatherModel {
        return mockWeatherModel
    }

    func searchCities(matching query: String) async throws -> [CitySearchResult] {
        mockSearchResults.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    func fetchForecast(for city: String, days: Int) async throws -> WeatherModel {
        return mockWeatherModel
    }
}

struct WeatherViewModelTests {
  //test fetch weather function by using mock data
  @Test("Empty data")
  func emptyModel() throws {
    Task { @MainActor in
      let mockWeatherDataService = MockWeatherDataService()
      let viewModel = WeatherDetailVM(weatherService: mockWeatherDataService)
      viewModel.fetchWeather()
      let weather = try #require(viewModel.weather)
    }
  }
}
