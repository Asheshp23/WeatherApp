import Testing
@testable import WeatherApp

struct WeatherDataServiceSwiftTests {
  @Test(.tags(.critical),
        arguments: [("London")])
  func fetchDataSuccess(city: String) async throws {
    let service = MockWeatherDataService()
    let weather: WeatherModel = try await service.fetchData(city: city)
    #expect(weather != nil)
  }
}

extension Tag {
  @Tag static var critical: Tag
}
