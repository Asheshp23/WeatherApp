import XCTest
@testable import WeatherApp

class WeatherDataServiceTests: XCTestCase {
    func testFetchDataSuccess() async {
        // Given
        let service = MockWeatherDataService()
        let city = "London" // Provide a valid city name for testing
        
        // When
        do {
            let weather: WeatherModel = try await service.fetchData(city: city)
            
            // Then
            XCTAssertNotNil(weather, "Weather data should not be nil")
            // Add more assertions as needed to verify the weather data
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchDataFailure() async {
        // Given
        let service = WeatherDataService()
        let invalidCity = "InvalidCityName" // Provide an invalid city name for testing
        
        // When
        do {
            let _: WeatherModel = try await service.fetchData(city: invalidCity)
            
            // Then
            XCTFail("Expected error but got success")
        } catch {
            // Expected error, test passed
            XCTAssertTrue(error is NetworkError, "Expected NetworkError")
            XCTAssertEqual(error as? NetworkError, NetworkError.invalidResponse, "Expected invalidResponse error")
        }
    }
}

