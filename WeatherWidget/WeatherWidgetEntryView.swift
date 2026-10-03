import SwiftUI
import WidgetKit
import Intents

/// Widget, small and medium. Same language as the app: one large temperature, a condition symbol,
/// and a dark condition-tinted background so white text is legible regardless of wallpaper.
struct WeatherWidgetEntryView: View {
  var entry: Provider.Entry

  @Environment(\.widgetFamily) private var family

  var body: some View {
    Group {
      if let weather = entry.weatherData {
        switch family {
        case .systemMedium:
          MediumWeatherWidget(weather: weather)
        default:
          SmallWeatherWidget(weather: weather)
        }
      } else {
        // Placeholder/snapshot: shape of real content, no fake city or values.
        SmallWeatherWidget(weather: nil)
          .redacted(reason: .placeholder)
      }
    }
    .foregroundStyle(.white)
    .widgetBackground(WidgetSky(weather: entry.weatherData))
  }
}

private struct SmallWeatherWidget: View {
  let weather: WeatherModel?

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(weather?.location.name ?? "—")
        .font(.subheadline.weight(.semibold))
        .lineLimit(1)
        .minimumScaleFactor(0.8)
      Text(temperature)
        .font(.system(size: 44, weight: .thin))
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .widgetAccentable()
      Spacer(minLength: 0)
      Image(systemName: symbol)
        .symbolRenderingMode(.multicolor)
        .font(.body)
        .accessibilityHidden(true)
      Text(weather?.current.condition.text ?? "—")
        .font(.caption.weight(.medium))
        .lineLimit(2)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .accessibilityElement(children: .combine)
  }

  private var temperature: String {
    guard let weather else { return "—°" }
    return "\(Helper.localizedNumber(Int(weather.current.tempC.rounded())))°"
  }

  private var symbol: String {
    guard let weather else { return "cloud.fill" }
    return weather.current.condition.weatherCondition.symbolName(isDay: weather.current.isDay == 1)
  }
}

private struct MediumWeatherWidget: View {
  let weather: WeatherModel

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      SmallWeatherWidget(weather: weather)
      VStack(alignment: .leading, spacing: 6) {
        row("Feels like", "\(Helper.localizedNumber(Int(weather.current.feelslikeC.rounded())))°")
        row("Humidity", "\(Helper.localizedNumber(weather.current.humidity))%")
        row("Wind", "\(Helper.localizedNumber(Int(weather.current.windKph.rounded()))) km/h")
        row("UV Index", Helper.localizedNumber(Int(weather.current.uv.rounded())))
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
  }

  private func row(_ label: LocalizedStringKey, _ value: String) -> some View {
    HStack {
      Text(label)
        .font(.caption)
        .opacity(0.8)
      Spacer(minLength: 4)
      Text(value)
        .font(.caption.weight(.semibold).monospacedDigit())
    }
    .accessibilityElement(children: .combine)
  }
}

/// Condition-tinted background. Every variant is dark enough for white caption text (≥ 4.5:1).
private struct WidgetSky: View {
  let weather: WeatherModel?

  var body: some View {
    LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
  }

  private var colors: [Color] {
    guard let weather else {
      return [Color(red: 0.20, green: 0.30, blue: 0.48), Color(red: 0.28, green: 0.40, blue: 0.58)]
    }
    if weather.current.isDay == 0 {
      return [Color(red: 0.04, green: 0.07, blue: 0.20), Color(red: 0.11, green: 0.15, blue: 0.32)]
    }
    switch weather.current.condition.weatherCondition {
    case .sunny:
      return [Color(red: 0.12, green: 0.38, blue: 0.78), Color(red: 0.22, green: 0.50, blue: 0.86)]
    case .partlyCloudy, .cloudy, .overcast, .mist, .fog, .freezingFog:
      return [Color(red: 0.30, green: 0.38, blue: 0.50), Color(red: 0.40, green: 0.48, blue: 0.60)]
    default:
      // Rain, snow and storms.
      return [Color(red: 0.18, green: 0.23, blue: 0.32), Color(red: 0.28, green: 0.34, blue: 0.44)]
    }
  }
}

extension View {
  func widgetBackground(_ backgroundView: some View) -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      return containerBackground(for: .widget) {
        backgroundView
      }
    } else {
      return background(backgroundView)
    }
  }
}
