import Testing
import Foundation
@testable import WeatherApp

struct WeatherModelTests {
  @Test("times ago",
        arguments: [(Double(-10800))])
  func timesAgo(date: Double) {
    // 3 * 60 * 60 = 10,800 seconds => 3 hours
    let date = Date(timeIntervalSinceNow: date)
    #expect(Date().time(since: date) == "3 hours ago")
  }
}
