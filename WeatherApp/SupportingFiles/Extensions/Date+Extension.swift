import Foundation

extension Date {
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
