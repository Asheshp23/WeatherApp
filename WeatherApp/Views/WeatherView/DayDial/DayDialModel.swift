import Foundation

// Foundation-only so it can be shared with the widget target, which also compiles WeatherDetailVM.

/// One hour on the dial.
struct DialHour: Identifiable, Equatable {
  let epoch: Int
  /// 0–23 in the forecast city's time zone; decides where the segment sits on the face.
  let hourOfDay: Int
  let temperatureC: Double
  let displayTemperature: String
  let precipitationChance: Int
  let isSnow: Bool
  let conditionSymbol: String

  var id: Int { epoch }
}

struct DayDialModel: Equatable {
  /// The next 24 hours; `hours[0]` is the current hour.
  let hours: [DialHour]
  /// Current time in the city, as a fraction of the day (0 = midnight).
  let nowFraction: Double
  let sunriseFraction: Double?
  let sunsetFraction: Double?
  let isDay: Bool
  let currentTemperature: String
  let conditionText: String
  let conditionSymbol: String
  let sunriseText: String?
  let sunsetText: String?
  let timeZone: TimeZone?
}
