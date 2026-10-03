import SwiftUI

// MARK: - Hero

/// The 3-second read: temperature, condition, today's range, feels-like, and rain chance when it matters.
struct WeatherHero: View {
  let temperature: String
  let conditionText: String
  let conditionSymbol: String
  let high: String?
  let low: String?
  let feelsLike: String
  let precipitationChance: Int?

  @ScaledMetric(relativeTo: .largeTitle) private var temperatureSize: CGFloat = 96

  var body: some View {
    VStack(alignment: .leading, spacing: DS.Space.xs) {
      Text(temperature)
        .font(.system(size: temperatureSize, weight: .thin))
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .accessibilityLabel(temperature)

      Label {
        Text(conditionText)
      } icon: {
        Image(systemName: conditionSymbol)
          .symbolRenderingMode(.multicolor)
      }
      .font(DS.Typo.condition)

      TodayFacts(high: high, low: low, feelsLike: feelsLike, precipitationChance: precipitationChance)
        .padding(.top, DS.Space.xxs)
    }
    .foregroundStyle(DS.Palette.onSky)
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityElement(children: .combine)
    .accessibilityIdentifier("currentTemperature")
  }
}

// MARK: - Today's facts

/// High, low, feels like, and rain chance when it matters. Wraps to a column when it doesn't fit.
struct TodayFacts: View {
  let high: String?
  let low: String?
  let feelsLike: String
  let precipitationChance: Int?
  var alignment: HorizontalAlignment = .leading

  var body: some View {
    ViewThatFits(in: .horizontal) {
      HStack(spacing: DS.Space.m) { facts }
      VStack(alignment: alignment, spacing: DS.Space.xxs) { facts }
    }
    // Primary white: this line sits directly on the sky (no plate), so it can't afford 80% opacity.
    .font(DS.Typo.supporting)
    .foregroundStyle(DS.Palette.onSky)
  }

  @ViewBuilder
  private var facts: some View {
    if let high, let low {
      Text("High \(high)")
      Text("Low \(low)")
    }
    Text("Feels like \(feelsLike)°")
    if let precipitationChance {
      Label {
        Text("\(Helper.localizedNumber(precipitationChance))%")
      } icon: {
        Image(systemName: "drop.fill")
      }
      .foregroundStyle(DS.Palette.precipitation)
      .accessibilityLabel("\(precipitationChance)% chance of precipitation")
    }
  }
}

// MARK: - Briefing

/// The plain-language headline above the dial.
struct BriefingText: View {
  let text: String
  let isAIGenerated: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: DS.Space.xs) {
      Text(text)
        .font(.title2.weight(.medium))
        .fixedSize(horizontal: false, vertical: true)
        .contentTransition(.opacity)
      if isAIGenerated {
        // Say where the wording came from; the facts are always the app's own.
        Label("Worded by Apple Intelligence", systemImage: "sparkles")
          .font(.caption)
          .foregroundStyle(DS.Palette.onSkySecondary)
      }
    }
    .foregroundStyle(DS.Palette.onSky)
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(.isHeader)
  }
}

// MARK: - Alert banner

/// Shown only when alerts exist. The most prominent element on the screen when present.
struct AlertBanner: View {
  let alerts: [WeatherAlert]

  private var primary: WeatherAlert? { alerts.first }

  var body: some View {
    if let primary {
      HStack(alignment: .top, spacing: DS.Space.m) {
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.title3)
          .accessibilityHidden(true)
        VStack(alignment: .leading, spacing: DS.Space.xxs) {
          Text("Weather Alerts")
            .font(.footnote.weight(.semibold))
            .opacity(0.85)
          Text(primary.event.isEmpty ? primary.headline : primary.event)
            .font(.headline)
            .fixedSize(horizontal: false, vertical: true)
          if !primary.severity.isEmpty {
            Text("\(primary.severity.capitalized) severity")
              .font(.subheadline)
              .opacity(0.9)
          }
        }
        Spacer(minLength: 0)
        Image(systemName: "chevron.right")
          .font(.footnote.weight(.semibold))
          .padding(.top, DS.Space.xxs)
          .accessibilityHidden(true)
      }
      .foregroundStyle(.white)
      .padding(DS.Space.l)
      .frame(maxWidth: .infinity, minHeight: DS.Size.minTarget, alignment: .leading)
      .background(DS.Palette.alertFill(severity: primary.severity),
                  in: RoundedRectangle(cornerRadius: DS.Corner.plate, style: .continuous))
      .accessibilityElement(children: .combine)
      .accessibilityAddTraits(.isButton)
    }
  }
}

// MARK: - Hourly strip

/// Next few hours in fixed columns — no horizontal scrolling. At accessibility text sizes the
/// columns become rows so nothing truncates.
struct HourlyStrip: View {
  let hours: [HourModel]
  let tempUnit: TemperatureUnit
  let timeZone: TimeZone?

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    if dynamicTypeSize.isAccessibilitySize {
      VStack(spacing: 0) {
        ForEach(Array(hours.enumerated()), id: \.element.id) { index, hour in
          if index > 0 { PlateDivider() }
          HourListRow(hour: hour, isNow: index == 0, tempUnit: tempUnit, timeZone: timeZone)
        }
      }
    } else {
      HStack(alignment: .top, spacing: 0) {
        ForEach(Array(hours.enumerated()), id: \.element.id) { index, hour in
          HourColumn(hour: hour, isNow: index == 0, tempUnit: tempUnit, timeZone: timeZone)
            .frame(maxWidth: .infinity)
        }
      }
    }
  }
}

private struct HourColumn: View {
  let hour: HourModel
  let isNow: Bool
  let tempUnit: TemperatureUnit
  let timeZone: TimeZone?

  var body: some View {
    let model = HourPresentation(hour: hour, isNow: isNow, tempUnit: tempUnit, timeZone: timeZone)
    VStack(spacing: DS.Space.s) {
      Text(model.timeLabel)
        .font(.footnote.weight(isNow ? .semibold : .regular))
        .foregroundStyle(isNow ? DS.Palette.onSky : DS.Palette.onSkySecondary)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
      Image(systemName: model.symbol)
        .symbolRenderingMode(.multicolor)
        .font(.title3)
        .frame(height: 24)
      // Reserve the line so temperatures stay aligned whether or not rain is shown.
      Text(model.precipitationText ?? " ")
        .font(.caption.weight(.semibold).monospacedDigit())
        .foregroundStyle(DS.Palette.precipitation)
      Text(model.temperature)
        .font(DS.Typo.rowValue)
    }
    .foregroundStyle(DS.Palette.onSky)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(model.accessibilityLabel)
  }
}

struct HourListRow: View {
  let hour: HourModel
  let isNow: Bool
  let tempUnit: TemperatureUnit
  let timeZone: TimeZone?

  var body: some View {
    let model = HourPresentation(hour: hour, isNow: isNow, tempUnit: tempUnit, timeZone: timeZone)
    HStack(spacing: DS.Space.m) {
      Text(model.timeLabel)
        .font(isNow ? DS.Typo.rowValue : DS.Typo.rowLabel)
      Spacer(minLength: DS.Space.s)
      Image(systemName: model.symbol)
        .symbolRenderingMode(.multicolor)
      if let precipitationText = model.precipitationText {
        Text(precipitationText)
          .font(.subheadline.weight(.semibold).monospacedDigit())
          .foregroundStyle(DS.Palette.precipitation)
      }
      Text(model.temperature)
        .font(DS.Typo.rowValue)
    }
    .foregroundStyle(DS.Palette.onSky)
    .padding(.vertical, DS.Space.m)
    .frame(minHeight: DS.Size.minTarget)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(model.accessibilityLabel)
  }
}

/// Shared formatting for hour columns and rows.
private struct HourPresentation {
  let timeLabel: String
  let symbol: String
  let temperature: String
  let precipitationText: String?
  let accessibilityLabel: String

  init(hour: HourModel, isNow: Bool, tempUnit: TemperatureUnit, timeZone: TimeZone?) {
    timeLabel = isNow ? String(localized: "Now") : Helper.localizedHour(hour.timeEpoch, timeZone: timeZone)
    symbol = hour.condition.weatherCondition.symbolName(isDay: hour.isDay == 1)
    let value = tempUnit == .celcius ? hour.tempC : hour.tempF
    temperature = "\(Helper.localizedNumber(Int(value.rounded())))°"
    let chance = max(hour.chanceOfRain, hour.chanceOfSnow)
    let meaningful = chance >= WeatherDetailVM.meaningfulPrecipitationThreshold
    precipitationText = meaningful ? "\(Helper.localizedNumber(chance))%" : nil
    var parts = [timeLabel, hour.condition.text, temperature]
    if meaningful {
      parts.append(String(localized: "\(chance)% chance of precipitation"))
    }
    accessibilityLabel = parts.joined(separator: ", ")
  }
}

// MARK: - Daily forecast

/// Daily rows with a temperature range bar scaled across all shown days.
struct DailyForecastList: View {
  let days: [ForecastDay]
  let tempUnit: TemperatureUnit

  private var bounds: ClosedRange<Double> {
    let lows = days.map { tempUnit == .celcius ? $0.day.mintempC : $0.day.mintempF }
    let highs = days.map { tempUnit == .celcius ? $0.day.maxtempC : $0.day.maxtempF }
    let lower = lows.min() ?? 0
    let upper = max(highs.max() ?? 1, lower + 1)
    return lower...upper
  }

  var body: some View {
    VStack(spacing: 0) {
      ForEach(Array(days.enumerated()), id: \.element.id) { index, day in
        if index > 0 { PlateDivider() }
        DailyRow(day: day, isToday: index == 0, tempUnit: tempUnit, bounds: bounds)
      }
    }
  }
}

private struct DailyRow: View {
  let day: ForecastDay
  let isToday: Bool
  let tempUnit: TemperatureUnit
  let bounds: ClosedRange<Double>

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @ScaledMetric(relativeTo: .body) private var dayColumnWidth: CGFloat = 52
  @ScaledMetric(relativeTo: .body) private var tempColumnWidth: CGFloat = 40

  private var weekday: String {
    isToday ? String(localized: "Today") : Helper.localizedWeekday(day.dateEpoch, timeZone: TimeZone(identifier: "UTC"))
  }

  private var low: Double { tempUnit == .celcius ? day.day.mintempC : day.day.mintempF }
  private var high: Double { tempUnit == .celcius ? day.day.maxtempC : day.day.maxtempF }
  private func format(_ value: Double) -> String { "\(Helper.localizedNumber(Int(value.rounded())))°" }

  private var precipitationChance: Int? {
    let chance = max(day.day.dailyChanceOfRain, day.day.dailyChanceOfSnow)
    return chance >= WeatherDetailVM.meaningfulPrecipitationThreshold ? chance : nil
  }

  var body: some View {
    Group {
      if dynamicTypeSize.isAccessibilitySize {
        VStack(alignment: .leading, spacing: DS.Space.s) {
          HStack(spacing: DS.Space.m) {
            Text(weekday).font(DS.Typo.rowValue)
            Spacer(minLength: 0)
            conditionIcon
            precipitation
          }
          HStack(spacing: DS.Space.m) {
            Text(format(low)).foregroundStyle(DS.Palette.onSkySecondary)
            TemperatureRangeBar(low: low, high: high, bounds: bounds)
            Text(format(high))
          }
          .font(DS.Typo.rowValue)
        }
      } else {
        HStack(spacing: DS.Space.m) {
          Text(weekday)
            .font(DS.Typo.rowValue)
            .frame(minWidth: dayColumnWidth, alignment: .leading)
            .fixedSize()
          conditionIcon
            .frame(width: 28)
          precipitation
            .frame(minWidth: 36, alignment: .leading)
          Text(format(low))
            .font(DS.Typo.rowValue)
            .foregroundStyle(DS.Palette.onSkySecondary)
            .frame(minWidth: tempColumnWidth, alignment: .trailing)
          TemperatureRangeBar(low: low, high: high, bounds: bounds)
          Text(format(high))
            .font(DS.Typo.rowValue)
            .frame(minWidth: tempColumnWidth, alignment: .trailing)
        }
      }
    }
    .foregroundStyle(DS.Palette.onSky)
    .padding(.vertical, DS.Space.m)
    .frame(minHeight: DS.Size.minTarget)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(accessibilityLabel)
  }

  private var conditionIcon: some View {
    Image(systemName: day.day.condition.weatherCondition.symbolName(isDay: true))
      .symbolRenderingMode(.multicolor)
  }

  @ViewBuilder
  private var precipitation: some View {
    if let precipitationChance {
      Text("\(Helper.localizedNumber(precipitationChance))%")
        .font(.subheadline.weight(.semibold).monospacedDigit())
        .foregroundStyle(DS.Palette.precipitation)
    } else {
      Color.clear.frame(width: 0, height: 0)
    }
  }

  private var accessibilityLabel: String {
    var parts = [weekday, day.day.condition.text,
                 String(localized: "High \(format(high))"),
                 String(localized: "Low \(format(low))")]
    if let precipitationChance {
      parts.append(String(localized: "\(precipitationChance)% chance of precipitation"))
    }
    return parts.joined(separator: ", ")
  }
}

/// A capsule track with the day's range filled on a cool→warm ramp. The ramp spans the
/// whole track so a bar's colour reflects absolute temperature, not just its own width.
struct TemperatureRangeBar: View {
  let low: Double
  let high: Double
  let bounds: ClosedRange<Double>

  var body: some View {
    GeometryReader { proxy in
      let span = bounds.upperBound - bounds.lowerBound
      let start = CGFloat((low - bounds.lowerBound) / span) * proxy.size.width
      let end = CGFloat((high - bounds.lowerBound) / span) * proxy.size.width
      ZStack(alignment: .leading) {
        Capsule().fill(DS.Palette.separator)
        LinearGradient(gradient: DS.Palette.temperatureRamp, startPoint: .leading, endPoint: .trailing)
          .frame(width: proxy.size.width)
          .mask(alignment: .leading) {
            Capsule()
              .frame(width: max(end - start, 6))
              .offset(x: start)
          }
      }
    }
    .frame(height: 6)
    .frame(minWidth: 60)
    .accessibilityHidden(true)
  }
}

// MARK: - Metric rows

/// Label on the leading edge, value on the trailing edge. Wraps (rather than truncates) at large sizes.
struct MetricRow: View {
  let label: LocalizedStringKey
  let value: String
  var detail: String? = nil

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    Group {
      if dynamicTypeSize.isAccessibilitySize {
        VStack(alignment: .leading, spacing: DS.Space.xxs) {
          Text(label).font(DS.Typo.metricLabel).foregroundStyle(DS.Palette.onSkySecondary)
          valueText
        }
      } else {
        HStack(alignment: .firstTextBaseline, spacing: DS.Space.m) {
          Text(label).font(DS.Typo.metricLabel).foregroundStyle(DS.Palette.onSkySecondary)
          Spacer(minLength: DS.Space.s)
          valueText.multilineTextAlignment(.trailing)
        }
      }
    }
    .foregroundStyle(DS.Palette.onSky)
    .padding(.vertical, DS.Space.m)
    .frame(maxWidth: .infinity, minHeight: DS.Size.minTarget, alignment: .leading)
    .accessibilityElement(children: .combine)
  }

  private var valueText: some View {
    Group {
      if let detail {
        Text("\(value) · \(detail)")
      } else {
        Text(value)
      }
    }
    .font(DS.Typo.rowValue)
  }
}

// MARK: - States

/// Full-screen state over the sky: says what happened and what to do.
struct WeatherStateView: View {
  let symbol: String
  let title: LocalizedStringKey
  let message: LocalizedStringKey
  var actionTitle: LocalizedStringKey? = nil
  var action: (() -> Void)? = nil

  var body: some View {
    VStack(spacing: DS.Space.m) {
      Image(systemName: symbol)
        .font(.largeTitle)
        .accessibilityHidden(true)
      Text(title)
        .font(.title3.weight(.semibold))
        .multilineTextAlignment(.center)
        .accessibilityAddTraits(.isHeader)
      Text(message)
        .font(.body)
        .foregroundStyle(DS.Palette.onSkySecondary)
        .multilineTextAlignment(.center)
      if let actionTitle, let action {
        Button(actionTitle, action: action)
          .font(.body.weight(.semibold))
          .padding(.horizontal, DS.Space.xl)
          .frame(minHeight: DS.Size.minTarget)
          .glassControl(in: Capsule())
          .padding(.top, DS.Space.s)
      }
    }
    .foregroundStyle(DS.Palette.onSky)
    .padding(DS.Space.xl)
    .frame(maxWidth: 420)
  }
}
