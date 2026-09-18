import Foundation

struct ForecastContainer: Codable, Sendable {
  let forecastday: [ForecastDay]
}

struct ForecastDay: Codable, Identifiable, Sendable {
  let date: String
  let dateEpoch: Int
  let day: DayAggregate
  let astro: AstroModel
  let hour: [HourModel]

  var id: String { date }

  enum CodingKeys: String, CodingKey {
    case date
    case dateEpoch = "date_epoch"
    case day
    case astro
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

struct AstroModel: Codable, Sendable {
  let sunrise: String
  let sunset: String
  let moonrise: String
  let moonset: String
  let moonPhase: String
  let moonIllumination: Double

  enum CodingKeys: String, CodingKey {
    case sunrise
    case sunset
    case moonrise
    case moonset
    case moonPhase = "moon_phase"
    case moonIllumination = "moon_illumination"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    sunrise = try values.decode(String.self, forKey: .sunrise)
    sunset = try values.decode(String.self, forKey: .sunset)
    moonrise = try values.decode(String.self, forKey: .moonrise)
    moonset = try values.decode(String.self, forKey: .moonset)
    moonPhase = try values.decode(String.self, forKey: .moonPhase)
    // weatherapi.com has historically returned this field as either a Double or a String.
    if let value = try? values.decode(Double.self, forKey: .moonIllumination) {
      moonIllumination = value
    } else {
      let stringValue = try values.decode(String.self, forKey: .moonIllumination)
      moonIllumination = Double(stringValue) ?? 0
    }
  }
}

extension AstroModel {
  /// SF Symbol representing this moon phase.
  var moonPhaseSymbolName: String {
    switch moonPhase.lowercased() {
    case "new moon": return "moonphase.new.moon"
    case "waxing crescent": return "moonphase.waxing.crescent"
    case "first quarter": return "moonphase.first.quarter"
    case "waxing gibbous": return "moonphase.waxing.gibbous"
    case "full moon": return "moonphase.full.moon"
    case "waning gibbous": return "moonphase.waning.gibbous"
    case "last quarter": return "moonphase.last.quarter"
    case "waning crescent": return "moonphase.waning.crescent"
    default: return "moonphase.full.moon"
    }
  }

  /// weatherapi.com's `moon_phase` field is always English and isn't affected by the
  /// request's `lang` parameter, so map the closed set of phase names ourselves.
  var localizedMoonPhase: String {
    switch moonPhase.lowercased() {
    case "new moon": return String(localized: "moon_phase_new", defaultValue: "New Moon")
    case "waxing crescent": return String(localized: "moon_phase_waxing_crescent", defaultValue: "Waxing Crescent")
    case "first quarter": return String(localized: "moon_phase_first_quarter", defaultValue: "First Quarter")
    case "waxing gibbous": return String(localized: "moon_phase_waxing_gibbous", defaultValue: "Waxing Gibbous")
    case "full moon": return String(localized: "moon_phase_full", defaultValue: "Full Moon")
    case "waning gibbous": return String(localized: "moon_phase_waning_gibbous", defaultValue: "Waning Gibbous")
    case "last quarter": return String(localized: "moon_phase_last_quarter", defaultValue: "Last Quarter")
    case "waning crescent": return String(localized: "moon_phase_waning_crescent", defaultValue: "Waning Crescent")
    default: return moonPhase
    }
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
