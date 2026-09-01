import Testing
@testable import WeatherApp

struct WeatherDataServiceSwiftTests {
  @Test(.tags(.critical),
        arguments: [("London")])
  func fetchDataSuccess(city: String) async throws {
    let service = MockWeatherDataService()
    let weather: WeatherModel = try await service.fetchCurrentWeather(for: city)
    #expect(weather.location.name == "London")
  }
}

extension Tag {
  @Tag static var critical: Tag
}
