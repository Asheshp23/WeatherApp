import SwiftUI

/// Next 24 hours as a single list. Precipitation only appears on hours where it's likely
/// enough to matter, so rainy hours stand out instead of every row showing "0%".
struct HourlyForecastView: View {
  @ObservedObject var vm: WeatherDetailVM

  var body: some View {
    ZStack {
      SkyImageView(weatherCondition: vm.weather?.current.condition.weatherCondition ?? .cloudy, isDay: vm.isDay)
      content
    }
    .navigationTitle("Hourly Forecast")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarColorScheme(.dark, for: .navigationBar)
    .task {
      vm.loadForecastIfNeeded()
    }
  }

  @ViewBuilder
  private var content: some View {
    let hours = vm.upcomingHours(24)
    if !hours.isEmpty {
      ScrollView {
        Plate(padding: DS.Space.l) {
          ForEach(Array(hours.enumerated()), id: \.element.id) { index, hour in
            if index > 0 { PlateDivider() }
            HourListRow(hour: hour, isNow: index == 0, tempUnit: vm.tempUnit, timeZone: vm.cityTimeZone)
          }
        }
        .padding(.horizontal, DS.Space.page)
        .padding(.vertical, DS.Space.l)
      }
    } else if vm.isForecastLoading {
      SwiftUI.ProgressView().tint(DS.Palette.onSky)
    } else if vm.forecastFailed {
      WeatherStateView(symbol: "wifi.slash",
                       title: "Forecast unavailable",
                       message: "Check your connection and try again.",
                       actionTitle: "Try Again") { vm.loadForecastIfNeeded() }
    } else {
      WeatherStateView(symbol: "clock", title: "No hourly data", message: "Pull to refresh on the main screen and try again.")
    }
  }
}

#Preview {
  NavigationStack {
    HourlyForecastView(vm: WeatherDetailVM(weatherService: WeatherDataService(), initialCity: "Toronto"))
  }
}
