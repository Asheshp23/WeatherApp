import XCTest

@testable import WeatherApp

class WeatherModelTests: XCTestCase {

  // updated time since  like how much time ago it is updated ...
    func testDate() {
        // 3 * 60 * 60 = 10,800 seconds => 3 hours
        let date = Date(timeIntervalSinceNow: Double(-10800))
        XCTAssertEqual(Date().time(since: date) , "3 hours ago")
    }
    
  // test decode using mock data
    func testSuccessFetchData() {

        
    }
    
    
    //test weather instance by using mock data
    func testWeatherModelInstance(){
       
    }
}
