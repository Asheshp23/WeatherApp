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
        
        let mockData = """
                            {
                            "lbl_updatetime":"Updated on",
                            "updatetime":"Sun Mar 20 1:35 PM",
                            "updatetime_stamp_gmt":"1647797700000",
                            "wxcondition":"Partly cloudy",
                            "icon":"3",
                            "inic":"iVBORw0KGgoAAAANSUhEUgAAAAcAAAAHCAMAAADzjKfhAAAAS1BMVEUAAADfqE\\/i1KyqqqruuFnkrlHCw8bssEjq2on74ZXux3P40XvMzM7Bp330wljh4eL3yGS9qo3p5uLusEbg4eDz8u\\/\\/7Ib333n62zc3bsJYAAAAFHRSTlMAB\\/hNPS8UDP7tysWsi4iBdHBlGexLoNwAAAA2SURBVAjXFcrHEcAgDADBE9HZBBH6r5Rh3wtIZHPpcwL17sOUgD\\/n0dpPvIyqPuDza23YX4AFKzUBiDlmoFoAAAAASUVORK5CYII=",
                            "temperature":"8",
                            "feels_like":"4",
                            "temperature_unit":"C",
                            "placecode":"CAON0696"
                            }
                            """.data(using: .utf8)!
        
        let expectedData = WeatherModel(labelUpdatedTime: Optional("Updated on"), lastUpdatedTime: Optional("Sun Mar 20 2:05 PM"), lastUpdatedTimeStampGmt: Optional("44 minutes ago"), weatherCondition: Optional("Partly cloudy"), icon: Optional("3"), inic: Optional("iVBORw0KGgoAAAANSUhEUgAAAAcAAAAHCAMAAADzjKfhAAAAS1BMVEUAAADfqE/i1KyqqqruuFnkrlHCw8bssEjq2on74ZXux3P40XvMzM7Bp330wljh4eL3yGS9qo3p5uLusEbg4eDz8u//7Ib333n62zc3bsJYAAAAFHRSTlMAB/hNPS8UDP7tysWsi4iBdHBlGexLoNwAAAA2SURBVAjXFcrHEcAgDADBE9HZBBH6r5Rh3wtIZHPpcwL17sOUgD/n0dpPvIyqPuDza23YX4AFKzUBiDlmoFoAAAAASUVORK5CYII="), temperature: Optional("10"), feelsLike: Optional("7"), temperatureUnit: Optional("C"), placeCode: Optional("CAON0696"))
        
        let weather = try! JSONDecoder().decode(WeatherModel.self,from: mockData)
        
        XCTAssertNotNil(weather)
        XCTAssertNotNil(weather.temperature)
        XCTAssertEqual(expectedData.placeCode, weather.placeCode)
        
        
    }
    
    
    //test weather instance by using mock data
    func testWeatherModelInstance(){
        let weatherInstance = WeatherModel(labelUpdatedTime: Optional("Updated on"), lastUpdatedTime: Optional("Sun Mar 20 2:45 PM"), lastUpdatedTimeStampGmt: Optional("51 minutes ago"), weatherCondition: Optional("Partly cloudy"), icon: Optional("3"), inic: Optional("iVBORw0KGgoAAAANSUhEUgAAAAcAAAAHCAMAAADzjKfhAAAAS1BMVEUAAADfqE/i1KyqqqruuFnkrlHCw8bssEjq2on74ZXux3P40XvMzM7Bp330wljh4eL3yGS9qo3p5uLusEbg4eDz8u//7Ib333n62zc3bsJYAAAAFHRSTlMAB/hNPS8UDP7tysWsi4iBdHBlGexLoNwAAAA2SURBVAjXFcrHEcAgDADBE9HZBBH6r5Rh3wtIZHPpcwL17sOUgD/n0dpPvIyqPuDza23YX4AFKzUBiDlmoFoAAAAASUVORK5CYII="), temperature: Optional("10"), feelsLike: Optional("6"), temperatureUnit: Optional("C"), placeCode: Optional("CAON0696"))
        
        XCTAssertNotNil(weatherInstance)
        XCTAssertEqual(weatherInstance.placeCode, Optional("CAON0696"))
    }
}
