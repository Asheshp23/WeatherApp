import XCTest
@testable import WeatherApp

class MockWeatherDataService: WeatherDataServiceProtocol {
    // Define a property to hold the mock weather model
    let mockWeatherModel: WeatherModel
    
    // Initialize the mock weather model with mock data
    init() {
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
    
    // Implement the fetchData method of the WeatherDataServiceProtocol
    func fetchData<T>(city: String) async throws -> T where T : Decodable {
        // Cast and return the mock weather model as T
        guard let result = mockWeatherModel as? T else {
            throw NetworkError.invalidResponse
        }
        return result
    }
}

class WeatherViewModelTests: XCTestCase {
  //test fetch weather function by using mock data
  func testNilData() {
    let mockWeatherDataService = MockWeatherDataService()
    let viewModel = WeatherDetailVM(weatherService: mockWeatherDataService)
    Task {
      await viewModel.fetchWeather()
    }
    XCTAssertNil(viewModel.weather)
  }
}
