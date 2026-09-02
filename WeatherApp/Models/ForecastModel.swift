import Foundation

struct ForecastContainer: Codable, Sendable {
  let forecastday: [ForecastDay]
}

struct ForecastDay: Codable, Identifiable, Sendable {
  let date: String
  let dateEpoch: Int
  let day: DayAggregate
  let hour: [HourModel]

  var id: String { date }

  enum CodingKeys: String, CodingKey {
    case date
    case dateEpoch = "date_epoch"
    case day
    case hour
  }
}

struct DayAggregate: Codable, Sendable {
  let maxtempC: Double
  let maxtempF: Double
  let mintempC: Double
  let mintempF: Double
  let avgtempC: Double
  let avgtempF: Double
  let dailyChanceOfRain: Int
  let dailyChanceOfSnow: Int
  let condition: ConditionModel
  let uv: Double

  enum CodingKeys: String, CodingKey {
    case maxtempC = "maxtemp_c"
    case maxtempF = "maxtemp_f"
    case mintempC = "mintemp_c"
    case mintempF = "mintemp_f"
    case avgtempC = "avgtemp_c"
    case avgtempF = "avgtemp_f"
    case dailyChanceOfRain = "daily_chance_of_rain"
    case dailyChanceOfSnow = "daily_chance_of_snow"
    case condition
    case uv
  }
}

struct HourModel: Codable, Identifiable, Sendable {
  let timeEpoch: Int
  let time: String
  let tempC: Double
  let tempF: Double
  let isDay: Int
  let condition: ConditionModel
  let chanceOfRain: Int
  let chanceOfSnow: Int

  var id: Int { timeEpoch }

  enum CodingKeys: String, CodingKey {
    case timeEpoch = "time_epoch"
    case time
    case tempC = "temp_c"
    case tempF = "temp_f"
    case isDay = "is_day"
    case condition
    case chanceOfRain = "chance_of_rain"
    case chanceOfSnow = "chance_of_snow"
  }
}

struct AlertsContainer: Codable, Sendable {
  let alert: [WeatherAlert]
}

struct WeatherAlert: Codable, Identifiable, Sendable {
  let headline: String
  let severity: String
  let event: String
  let effective: String
  let expires: String
  let desc: String
  let instruction: String

  var id: String { headline + effective }
}
