import Foundation

extension Date {
  /// 1-based day-of-year, e.g. 260 for Sept 17th.
  var dayOfYear: Int {
    Calendar.current.ordinality(of: .day, in: .year, for: self) ?? 0
  }

  /// Total number of days in the year this date falls in (365 or 366).
  var daysInYear: Int {
    Calendar.current.range(of: .day, in: .year, for: self)?.count ?? 365
  }

  func time(since fromDate: Date) -> String {
    let earliest = self < fromDate ? self : fromDate
    let latest = (earliest == self) ? fromDate : self
    let allComponents: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
    let components:DateComponents = Calendar.current.dateComponents(allComponents, from: earliest, to: latest)
    let year = components.year  ?? 0
    let month = components.month  ?? 0
    let week = components.weekOfYear  ?? 0
    let day = components.day ?? 0
    let hour = components.hour ?? 0
    let minute = components.minute ?? 0
    let second = components.second ?? 0
    let descendingComponents = ["year": year, "month": month, "week": week,
                                "day": day, "hour": hour,
                                "minute": minute, "second": second]
    for (period, timeAgo) in descendingComponents {
      if timeAgo > 0 {
        return "\(timeAgo.of(period)) ago"
      }
    }
    return "Just now"
  }
}
