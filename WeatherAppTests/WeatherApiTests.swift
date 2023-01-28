import XCTest
@testable import WeatherApp

class WeatherServiceTests: XCTestCase {

  func testGetWeather() {
    // Test valid city and temperature unit
    let city = "Toronto"
    let tempUnit = "c"
    Task {
      let weatherService = WeatherData.shared
      let weather =  await weatherService.getWeather(city: city, tempUnit: tempUnit)
      XCTAssertNotNil(weather)
    }

    Task {
      // Test invalid city
      let invalidCity = "InvalidCity"
      let weatherService = WeatherData.shared
      let weather =  await weatherService.getWeather(city: invalidCity, tempUnit: tempUnit)
      XCTAssertNil(weather)
    }

    Task {
      // Test invalid temperature unit
      let invalidTempUnit = "F"
      let invalidTempWeather = await WeatherData.shared.getWeather(city: city, tempUnit: invalidTempUnit)
      XCTAssertNil(invalidTempWeather)
    }
  }

  func testWeatherAPI() async {
    let url = URL(string: "https://www.theweathernetwork.com/api/obsdata/Toronto/C")
    let urlRequest = URLRequest(url: url!)
    do  {
      let (data, response) =  try await URLSession.shared.data(for: urlRequest)
      if let httpResponse = response as? HTTPURLResponse {
        XCTAssertEqual(httpResponse.statusCode, 200)
      }
      let decoder = JSONDecoder()
      let result = try decoder.decode(WeatherModel.self, from: data)
      XCTAssertNotNil(result)
    } catch {

    }
  }
}

