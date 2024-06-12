import Testing
@testable import WeatherApp

struct WeatherDataServiceSwiftTests {
  @Test
  func fetchDataSuccess() async throws {
    let service = MockWeatherDataService()
    let city = "London" // Provide a valid city name for testing
    let weather: WeatherModel = try await service.fetchData(city: city)
    #expect(weather != nil)
  }
}
