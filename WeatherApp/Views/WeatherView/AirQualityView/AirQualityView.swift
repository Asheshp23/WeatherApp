import SwiftUI

/// Air quality detail. The category is the headline (in words), position on the US EPA scale
/// is shown by location *and* colour, and the pollutant breakdown is secondary.
struct AirQualityView: View {
  @ObservedObject var vm: WeatherDetailVM

  var body: some View {
    ZStack {
      SkyImageView(weatherCondition: vm.weather?.current.condition.weatherCondition ?? .cloudy, isDay: vm.isDay)
      content
    }
    .navigationTitle("Air Quality")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarColorScheme(.dark, for: .navigationBar)
  }

  @ViewBuilder
  private var content: some View {
    if let airQuality = vm.airQuality {
      ScrollView {
        VStack(alignment: .leading, spacing: DS.Space.xl) {
          AQISummary(airQuality: airQuality)
          Plate {
            SectionTitle(title: "Pollutants")
              .frame(minHeight: DS.Size.minTarget)
            pollutantRow("PM2.5", airQuality.pm2_5)
            PlateDivider()
            pollutantRow("PM10", airQuality.pm10)
            PlateDivider()
            pollutantRow("O₃", airQuality.o3)
            PlateDivider()
            pollutantRow("NO₂", airQuality.no2)
            PlateDivider()
            pollutantRow("SO₂", airQuality.so2)
            PlateDivider()
            pollutantRow("CO", airQuality.co)
          }
        }
        .padding(.horizontal, DS.Space.page)
        .padding(.vertical, DS.Space.l)
      }
    } else if vm.isLoading {
      SwiftUI.ProgressView().tint(DS.Palette.onSky)
    } else {
      WeatherStateView(symbol: "aqi.medium",
                       title: "Air quality unavailable",
                       message: "Pull to refresh on the main screen and try again.")
    }
  }

  /// Ordered by health relevance: fine particles first. Chemical symbols aren't translated.
  private func pollutantRow(_ name: String, _ value: Double) -> some View {
    HStack(alignment: .firstTextBaseline) {
      Text(verbatim: name)
        .font(DS.Typo.metricLabel)
        .foregroundStyle(DS.Palette.onSkySecondary)
      Spacer(minLength: DS.Space.s)
      Text(Helper.localizedNumber(value, fractionDigits: 1))
        .font(DS.Typo.rowValue)
      Text("µg/m³")
        .font(.caption)
        .foregroundStyle(DS.Palette.onSkySecondary)
    }
    .foregroundStyle(DS.Palette.onSky)
    .padding(.vertical, DS.Space.m)
    .frame(minHeight: DS.Size.minTarget)
    .accessibilityElement(children: .combine)
  }
}

private struct AQISummary: View {
  let airQuality: AirQualityModel

  private static let levels = 6

  var body: some View {
    VStack(alignment: .leading, spacing: DS.Space.m) {
      Text(airQuality.usEpaCategory)
        .font(.largeTitle.weight(.semibold))
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityAddTraits(.isHeader)

      Text("Level \(Helper.localizedNumber(airQuality.usEpaIndex)) of \(Helper.localizedNumber(Self.levels))")
        .font(DS.Typo.supporting)
        .foregroundStyle(DS.Palette.onSkySecondary)

      HStack(spacing: DS.Space.xs) {
        ForEach(1...Self.levels, id: \.self) { level in
          let isCurrent = level == airQuality.usEpaIndex
          Capsule()
            .fill(DS.Palette.aqi(level).opacity(isCurrent ? 1 : 0.55))
            .frame(height: isCurrent ? 10 : 6)
            .overlay {
              if isCurrent {
                Capsule().strokeBorder(.white, lineWidth: 1.5)
              }
            }
        }
      }
      .frame(height: 10)
      .accessibilityHidden(true)

      Text("US EPA Air Quality Index")
        .font(.caption)
        .foregroundStyle(DS.Palette.onSkySecondary)
    }
    .foregroundStyle(DS.Palette.onSky)
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityElement(children: .combine)
  }
}

#Preview {
  NavigationStack {
    AirQualityView(vm: WeatherDetailVM(weatherService: WeatherDataService(), initialCity: "Toronto"))
  }
}
