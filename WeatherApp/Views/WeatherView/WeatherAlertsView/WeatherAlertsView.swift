import SwiftUI

/// Full alert text. Reached from the alert banner, which only exists when alerts do.
struct WeatherAlertsView: View {
  @ObservedObject var vm: WeatherDetailVM

  var body: some View {
    ZStack {
      SkyImageView(weatherCondition: vm.weather?.current.condition.weatherCondition ?? .cloudy, isDay: vm.isDay)
      content
    }
    .navigationTitle("Weather Alerts")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarColorScheme(.dark, for: .navigationBar)
    .task {
      vm.loadForecastIfNeeded()
    }
  }

  @ViewBuilder
  private var content: some View {
    if vm.isForecastLoading && vm.forecast == nil {
      SwiftUI.ProgressView().tint(DS.Palette.onSky)
    } else if vm.forecastFailed && vm.forecast == nil {
      WeatherStateView(symbol: "wifi.slash",
                       title: "Alerts unavailable",
                       message: "Check your connection and try again.",
                       actionTitle: "Try Again") { vm.loadForecastIfNeeded() }
    } else if vm.alerts.isEmpty {
      WeatherStateView(symbol: "checkmark.shield",
                       title: "No Active Alerts",
                       message: "We'll show any active weather alerts for \(vm.selectedCity) here.")
    } else {
      ScrollView {
        VStack(spacing: DS.Space.l) {
          ForEach(vm.alerts) { alert in
            AlertDetail(alert: alert)
          }
        }
        .padding(.horizontal, DS.Space.page)
        .padding(.vertical, DS.Space.l)
      }
    }
  }
}

private struct AlertDetail: View {
  let alert: WeatherAlert

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Severity carried by colour *and* words.
      VStack(alignment: .leading, spacing: DS.Space.xxs) {
        if !alert.severity.isEmpty {
          Text("\(alert.severity.capitalized) severity")
            .font(.footnote.weight(.semibold))
        }
        Text(alert.event.isEmpty ? alert.headline : alert.event)
          .font(.title3.weight(.semibold))
          .fixedSize(horizontal: false, vertical: true)
          .accessibilityAddTraits(.isHeader)
        if !alert.effective.isEmpty || !alert.expires.isEmpty {
          Text("\(alert.effective) – \(alert.expires)")
            .font(.footnote.monospacedDigit())
            .opacity(0.9)
        }
      }
      .foregroundStyle(.white)
      .padding(DS.Space.l)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(DS.Palette.alertFill(severity: alert.severity))

      VStack(alignment: .leading, spacing: DS.Space.m) {
        if !alert.desc.isEmpty {
          Text(alert.desc)
            .font(.body)
        }
        if !alert.instruction.isEmpty {
          Text(alert.instruction)
            .font(.body.weight(.semibold))
        }
      }
      .foregroundStyle(DS.Palette.onSky)
      .padding(DS.Space.l)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color.black.opacity(0.28))
    }
    .clipShape(RoundedRectangle(cornerRadius: DS.Corner.plate, style: .continuous))
    .accessibilityElement(children: .combine)
  }
}

#Preview {
  NavigationStack {
    WeatherAlertsView(vm: WeatherDetailVM(weatherService: WeatherDataService(), initialCity: "Toronto"))
  }
}
