import XCTest
@testable import WeatherApp

class WeatherViewModelTests: XCTestCase {
    //test fetch weather function by using mock data
    func testNotNilData() {
        let viewModel = WeatherDetailVM()
      Task {
        await viewModel.fetchWeather(by: "Toronto", unit: temperatureUnit.celcius)
      }
        XCTAssertNotNil(viewModel.weather)
    }
    //test get city code function using mock data....
    func testViewModelFunction(){
        let viewModel = WeatherDetailVM()
        let city =  viewModel.getCityNameAssosiatedWithCityCode(city: "Toronto")
        XCTAssertEqual("CAON0696", city)
    }
}
