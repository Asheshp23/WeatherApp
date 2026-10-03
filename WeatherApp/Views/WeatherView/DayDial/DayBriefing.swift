import Foundation

/// One forecast hour, reduced to what the briefing rules need.
struct BriefingHour: Equatable {
  let epoch: Int
  let temperatureC: Double
  /// Already formatted in the user's unit and digits.
  let displayTemperature: String
  let rainChance: Int
  let snowChance: Int

  var precipitationChance: Int { max(rainChance, snowChance) }
  var isSnow: Bool { snowChance > rainChance }
}

struct BriefingInput: Equatable {
  /// The coming hours, starting with the current one.
  let hours: [BriefingHour]
  let currentTemperatureC: Double
  let displayCurrentTemperature: String
  let feelsLikeC: Double
  let displayFeelsLike: String
  let uvIndex: Double
  let isDay: Bool
  let windKph: Double
  let aqiIndex: Int?
  let alertEvent: String?
  /// Rain or snow actually falling according to current conditions (not just "possible").
  var precipitatingNow = false
  var snowingNow = false
}

/// Turns the forecast into one or two plain sentences: what happens next, then what to do about it.
///
/// This is the source of truth for the briefing. It's deterministic and localized, so it works on
/// every device and in every language; Apple Intelligence may only rephrase it (see
/// `WeatherBriefingService`), never change the facts.
enum DayBriefing {
  /// How far ahead the first sentence looks. Further out is better left to the forecast sections.
  static let lookahead = 12
  static let likelyChance = 50
  static let possibleChance = 30

  static func make(_ input: BriefingInput, formatHour: (Int) -> String) -> String {
    let window = Array(input.hours.prefix(lookahead))
    guard let first = window.first else { return "" }

    var sentences: [String] = []
    var precipitation: Precipitation?

    // The current hour is "now", never a "by…" or "around…" target: its start time is already past.
    let upcoming = window.dropFirst()

    if first.precipitationChance >= likelyChance || input.precipitatingNow {
      // Already wet: say when it stops.
      let isSnow = first.precipitationChance >= likelyChance ? first.isSnow : input.snowingNow
      precipitation = isSnow ? .snow : .rain
      if let end = upcoming.first(where: { $0.precipitationChance < possibleChance }) {
        let format = isSnow
          ? String(localized: "briefing_snow_until", defaultValue: "Snow until about %@.")
          : String(localized: "briefing_rain_until", defaultValue: "Rain until about %@.")
        sentences.append(String(format: format, formatHour(end.epoch)))
      } else {
        sentences.append(isSnow
          ? String(localized: "briefing_snow_continuing", defaultValue: "Snow for the next 12 hours.")
          : String(localized: "briefing_rain_continuing", defaultValue: "Rain for the next 12 hours."))
      }
    } else if let start = upcoming.first(where: { $0.precipitationChance >= likelyChance }) {
      // Dry now: say when it starts.
      precipitation = start.isSnow ? .snow : .rain
      let format = start.isSnow
        ? String(localized: "briefing_snow_from", defaultValue: "Snow likely from about %@.")
        : String(localized: "briefing_rain_from", defaultValue: "Rain likely from about %@.")
      sentences.append(String(format: format, formatHour(start.epoch)))
    } else if let peak = upcoming.max(by: { $0.precipitationChance < $1.precipitationChance }),
              peak.precipitationChance >= possibleChance {
      let format = peak.isSnow
        ? String(localized: "briefing_snow_chance", defaultValue: "A chance of snow around %@.")
        : String(localized: "briefing_showers_chance", defaultValue: "A chance of showers around %@.")
      sentences.append(String(format: format, formatHour(peak.epoch)))
    } else {
      sentences.append(temperatureTrend(Array(upcoming), input: input, formatHour: formatHour))
    }

    if let advice = advice(input, precipitation: precipitation) {
      sentences.append(advice)
    }
    return sentences.joined(separator: " ")
  }

  private enum Precipitation { case rain, snow }

  /// Used when no rain or snow is expected: the temperature change is then the most useful thing to say.
  /// It doesn't claim "dry", because the current conditions can still read "patchy rain nearby".
  private static func temperatureTrend(_ window: [BriefingHour], input: BriefingInput, formatHour: (Int) -> String) -> String {
    let steady = String(format: String(localized: "briefing_trend_steady", defaultValue: "Steady around %@."),
                        input.displayCurrentTemperature)
    guard let warmest = window.max(by: { $0.temperatureC < $1.temperatureC }),
          let coolest = window.min(by: { $0.temperatureC < $1.temperatureC }) else { return steady }

    // Thresholds are in °C regardless of the display unit, so the wording doesn't flip with the toggle.
    if warmest.temperatureC - input.currentTemperatureC >= 3 {
      return String(format: String(localized: "briefing_trend_warming", defaultValue: "Warming to %1$@ by %2$@."),
                    warmest.displayTemperature, formatHour(warmest.epoch))
    }
    if input.currentTemperatureC - coolest.temperatureC >= 4 {
      return String(format: String(localized: "briefing_trend_cooling", defaultValue: "Cooling to %1$@ by %2$@."),
                    coolest.displayTemperature, formatHour(coolest.epoch))
    }
    return steady
  }

  /// At most one piece of advice, in order of how much it should change what someone does.
  private static func advice(_ input: BriefingInput, precipitation: Precipitation?) -> String? {
    if let event = input.alertEvent, !event.isEmpty {
      return String(format: String(localized: "briefing_alert", defaultValue: "Alert in effect: %@."), event)
    }
    if let aqi = input.aqiIndex, aqi >= 4 {
      return String(localized: "briefing_unhealthy_air", defaultValue: "Air quality is unhealthy, so limit time outdoors.")
    }
    switch precipitation {
    case .rain: return String(localized: "briefing_umbrella", defaultValue: "Take an umbrella.")
    case .snow: return String(localized: "briefing_travel_time", defaultValue: "Allow extra travel time.")
    case nil: break
    }
    if input.isDay && input.uvIndex >= 6 {
      return String(localized: "briefing_high_uv", defaultValue: "UV is high, so wear sunscreen.")
    }
    if input.windKph >= 40 {
      return String(localized: "briefing_windy", defaultValue: "Expect strong wind.")
    }
    if abs(input.feelsLikeC - input.currentTemperatureC) >= 4 {
      return String(format: String(localized: "briefing_feels_like", defaultValue: "Feels like %@."), input.displayFeelsLike)
    }
    return nil
  }
}

extension WeatherCondition {
  /// Rain, sleet, drizzle or snow actually falling. The "possible" codes (1063–1087), mist and fog
  /// don't count.
  var isPrecipitating: Bool {
    rawValue >= 1114 && self != .fog && self != .freezingFog
  }

  var isSnow: Bool {
    switch self {
    case .blowingSnow, .blizzard, .patchyLightSnow, .lightSnow, .patchyModerateSnow, .moderateSnow,
        .patchyHeavySnow, .heavySnow, .lightSnowShowers, .moderateOrHeavySnowShowers,
        .patchyLightSnowWithThunder, .moderateOrHeavySnowWithThunder:
      return true
    default:
      return false
    }
  }
}
