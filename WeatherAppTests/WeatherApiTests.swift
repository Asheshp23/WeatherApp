import XCTest
@testable import WeatherApp

class WeatherServiceTests: XCTestCase {

  func testGetWeather() {
    let weatherService = WeatherDataService()
    Task {
      let response = await weatherService.getWeather(city: "San Francisco")
      switch response {
      case .success(let weatherData):
        XCTAssertNotNil(weatherData)
      case .failure(let error):
        XCTAssertNotNil(error)
      }
    }
  }
}

