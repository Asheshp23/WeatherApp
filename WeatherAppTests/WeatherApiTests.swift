import XCTest
@testable import WeatherApp

class WeatherServiceTests: XCTestCase {


  func testGetWeather() {
    let expectation = XCTestExpectation(description: "Get weather for a city")
    let weatherService = WeatherData.shared
    Task {
      if let weatherModel =   await weatherService.getWeather(city: "San Francisco") {
        XCTAssertNotNil(weatherModel)
        XCTAssertNotNil(weatherModel.location)
        XCTAssertNotNil(weatherModel.current)
        expectation.fulfill()
      }
    }
    wait(for: [expectation], timeout: 10.0)
  }
}

