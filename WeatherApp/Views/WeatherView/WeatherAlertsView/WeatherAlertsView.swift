import SwiftUI

struct WeatherAlertsView: View {
  @ObservedObject var vm: WeatherDetailVM

  private var alerts: [WeatherAlert] {
    vm.forecast?.alerts?.alert ?? []
  }

  var body: some View {
    ZStack {
      SkyImageView(weatherCondition: vm.weather?.current.condition.weatherCondition ?? .cloudy)
        .ignoresSafeArea()
      content
    }
    .foregroundColor(.white)
    .navigationTitle("Weather Alerts")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      vm.loadForecastIfNeeded()
    }
  }

  @ViewBuilder
  private var content: some View {
    if vm.isForecastLoading && vm.forecast == nil {
      ProgressView(tintColor: .white)
    } else if vm.forecastFailed && vm.forecast == nil {
      ContentUnavailableView {
        Label("Alerts unavailable", systemImage: "wifi.slash")
      } description: {
        Text("Check your connection and try again.")
      } actions: {
        Button("Try Again") { vm.loadForecastIfNeeded() }
      }
    } else if alerts.isEmpty {
      ContentUnavailableView("No Active Alerts", systemImage: "checkmark.shield", description: Text("We'll show any active weather alerts for \(vm.selectedCity) here."))
    } else {
      ScrollView {
        LazyVStack(spacing: 12) {
          ForEach(alerts) { alert in
            AlertCard(alert: alert)
          }
        }
        .padding()
      }
    }
  }
}

private struct AlertCard: View {
  let alert: WeatherAlert

  private var severityColor: Color {
    switch alert.severity.lowercased() {
    case "extreme": return .red
    case "severe": return .orange
    case "moderate": return .yellow
    default: return .blue
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: "exclamationmark.triangle.fill")
          .foregroundStyle(severityColor)
        Text(alert.event.isEmpty ? alert.headline : alert.event)
          .font(.headline)
        Spacer()
      }
      if !alert.effective.isEmpty || !alert.expires.isEmpty {
        Text("\(alert.effective) – \(alert.expires)")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      if !alert.desc.isEmpty {
        Text(alert.desc)
          .font(.subheadline)
      }
      if !alert.instruction.isEmpty {
        Text(alert.instruction)
          .font(.footnote)
          .foregroundStyle(.secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(12)
    .glassSurface(cornerRadius: Radius.card)
  }
}

struct WeatherAlertsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      WeatherAlertsView(vm: WeatherDetailVM(weatherService: WeatherDataService()))
    }
  }
}
