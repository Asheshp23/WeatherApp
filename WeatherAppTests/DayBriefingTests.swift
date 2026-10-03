import Testing
@testable import WeatherApp

struct DayBriefingTests {
  /// Hour labels are the epoch index, so expectations don't depend on locale or time zone.
  private func formatHour(_ epoch: Int) -> String { "h\(epoch)" }

  private func hours(temperatures: [Double], rain: [Int] = [], snow: [Int] = []) -> [BriefingHour] {
    temperatures.enumerated().map { index, temperature in
      BriefingHour(epoch: index, temperatureC: temperature, displayTemperature: "\(Int(temperature))°",
                   rainChance: index < rain.count ? rain[index] : 0,
                   snowChance: index < snow.count ? snow[index] : 0)
    }
  }

  private func input(_ hours: [BriefingHour], current: Double? = nil, feelsLike: Double? = nil,
                     uv: Double = 0, isDay: Bool = true, wind: Double = 0,
                     aqi: Int? = nil, alert: String? = nil) -> BriefingInput {
    let now = current ?? hours.first?.temperatureC ?? 0
    let feels = feelsLike ?? now
    return BriefingInput(hours: hours, currentTemperatureC: now, displayCurrentTemperature: "\(Int(now))°",
                         feelsLikeC: feels, displayFeelsLike: "\(Int(feels))°", uvIndex: uv, isDay: isDay,
                         windKph: wind, aqiIndex: aqi, alertEvent: alert)
  }

  @Test("Rain later says when it starts and suggests an umbrella")
  func rainStarts() {
    let text = DayBriefing.make(input(hours(temperatures: Array(repeating: 15, count: 12),
                                            rain: [0, 0, 10, 60, 80])), formatHour: formatHour)
    #expect(text == "Rain likely from about h3. Take an umbrella.")
  }

  @Test("Rain now says when it stops")
  func rainStops() {
    let text = DayBriefing.make(input(hours(temperatures: Array(repeating: 15, count: 12),
                                            rain: [90, 70, 20])), formatHour: formatHour)
    #expect(text == "Rain until about h2. Take an umbrella.")
  }

  @Test("Snow uses snow wording and travel advice")
  func snow() {
    let text = DayBriefing.make(input(hours(temperatures: Array(repeating: -2, count: 12),
                                            rain: [0, 10], snow: [0, 70])), formatHour: formatHour)
    #expect(text == "Snow likely from about h1. Allow extra travel time.")
  }

  @Test("Only a possible shower gets softer wording and no umbrella")
  func possibleShowers() {
    let text = DayBriefing.make(input(hours(temperatures: Array(repeating: 15, count: 12),
                                            rain: [0, 0, 0, 0, 35])), formatHour: formatHour)
    #expect(text == "A chance of showers around h4.")
  }

  @Test("Warming names the peak")
  func warming() {
    let text = DayBriefing.make(input(hours(temperatures: [14, 16, 18, 21, 20, 19])), formatHour: formatHour)
    #expect(text == "Warming to 21° by h3.")
  }

  @Test("Cooling names the low")
  func cooling() {
    let text = DayBriefing.make(input(hours(temperatures: [20, 18, 16, 14, 15])), formatHour: formatHour)
    #expect(text == "Cooling to 14° by h3.")
  }

  @Test("Rain beyond the 12-hour window is ignored")
  func lookahead() {
    var rain = Array(repeating: 0, count: 13)
    rain[12] = 90
    let text = DayBriefing.make(input(hours(temperatures: Array(repeating: 15, count: 13), rain: rain)),
                                formatHour: formatHour)
    #expect(text == "Steady around 15°.")
  }

  @Test("Advice priority: alert beats air quality, which beats rain")
  func advicePriority() {
    let wet = hours(temperatures: Array(repeating: 15, count: 12), rain: [80])
    #expect(DayBriefing.make(input(wet, aqi: 5, alert: "Flood Warning"), formatHour: formatHour)
            .hasSuffix("Alert in effect: Flood Warning."))
    #expect(DayBriefing.make(input(wet, aqi: 5), formatHour: formatHour)
            .hasSuffix("Air quality is unhealthy, so limit time outdoors."))
  }

  @Test("High UV only matters in daylight")
  func uvNeedsDaylight() {
    let dry = hours(temperatures: Array(repeating: 25, count: 12))
    #expect(DayBriefing.make(input(dry, uv: 8, isDay: true), formatHour: formatHour)
            == "Steady around 25°. UV is high, so wear sunscreen.")
    #expect(DayBriefing.make(input(dry, uv: 8, isDay: false), formatHour: formatHour)
            == "Steady around 25°.")
  }

  @Test("A big feels-like gap is mentioned last")
  func feelsLike() {
    let dry = hours(temperatures: Array(repeating: 2, count: 12))
    #expect(DayBriefing.make(input(dry, feelsLike: -4), formatHour: formatHour)
            == "Steady around 2°. Feels like -4°.")
  }

  @Test("The current hour is never named as a future time")
  func currentHourIsNotATarget() {
    // Now is 15° but the current hour's forecast says 18°: that's not "warming to 18° by" a past time.
    let text = DayBriefing.make(input(hours(temperatures: [18, 16, 16, 16]), current: 15), formatHour: formatHour)
    #expect(text == "Steady around 15°.")
  }

  @Test("Rain falling now counts even when the hourly chance is low")
  func rainingNowOverridesLowChance() {
    var raining = input(hours(temperatures: Array(repeating: 12, count: 12), rain: [20, 25, 10]))
    raining.precipitatingNow = true
    #expect(DayBriefing.make(raining, formatHour: formatHour) == "Rain until about h1. Take an umbrella.")
  }

  @Test("No hours, no briefing")
  func empty() {
    #expect(DayBriefing.make(input([]), formatHour: formatHour).isEmpty)
  }
}

struct WeatherBriefingServiceTests {
  @Test("A rewrite that keeps every number is accepted")
  func keepsNumbers() {
    #expect(WeatherBriefingService.preservesFacts(
      original: "Rain likely from about 4 PM. Take an umbrella.",
      rewrite: "Expect rain from around 4 PM, so bring an umbrella."))
  }

  @Test("A rewrite that changes or adds a number is rejected", arguments: [
    "Expect rain from around 5 PM, so bring an umbrella.",
    "Rain from 4 PM with 80% chance. Bring an umbrella.",
    "Rain later today. Bring an umbrella.",
    ""
  ])
  func rejectsChangedNumbers(rewrite: String) {
    #expect(!WeatherBriefingService.preservesFacts(
      original: "Rain likely from about 4 PM. Take an umbrella.", rewrite: rewrite))
  }
}
