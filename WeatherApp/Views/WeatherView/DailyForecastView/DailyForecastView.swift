import SwiftUI

/// Standalone daily forecast. The main screen shows the same list inline (the free plan only
/// returns 3 days), so this screen exists for deep links and widget taps.
struct DailyForecastView: View {
  @ObservedObject var vm: WeatherDetailVM

  var body: some View {
    ZStack {
      SkyImageView(weatherCondition: vm.weather?.current.condition.weatherCondition ?? .cloudy, isDay: vm.isDay)
      content
    }
    .navigationTitle(vm.forecastDays.isEmpty ? Text("Daily Forecast") : Text("\(vm.forecastDays.count)-Day Forecast"))
    .navigationBarTitleDisplayMode(.inline)
    .toolbarColorScheme(.dark, for: .navigationBar)
    .task {
      vm.loadForecastIfNeeded()
    }
  }

  @ViewBuilder
  private var content: some View {
    if !vm.forecastDays.isEmpty {
      ScrollView {
        Plate {
          DailyForecastList(days: vm.forecastDays, tempUnit: vm.tempUnit)
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
      WeatherStateView(symbol: "calendar", title: "No forecast data", message: "Pull to refresh on the main screen and try again.")
    }
  }
}

#Preview {
  NavigationStack {
    DailyForecastView(vm: WeatherDetailVM(weatherService: WeatherDataService(), initialCity: "Toronto"))
  }
}
