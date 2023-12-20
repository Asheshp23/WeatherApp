import XCTest
@testable import WeatherApp

class WeatherViewModelTests: XCTestCase {
  //test fetch weather function by using mock data
  func testNotNilData() {
    let viewModel = WeatherDetailVM(weatherService: WeatherDataService())
    Task {
      await viewModel.fetchWeather()
    }
    XCTAssertNotNil(viewModel.weather)
  }
}
