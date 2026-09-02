import SwiftUI

struct HourlyForecastView: View {
  @ObservedObject var vm: WeatherDetailVM

  var body: some View {
    ZStack {
      SkyImageView(weatherCondition: vm.weather?.current.condition.weatherCondition ?? .cloudy)
        .ignoresSafeArea()
      content
    }
    .foregroundColor(.white)
    .navigationTitle("Hourly Forecast")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      vm.loadForecastIfNeeded()
    }
  }

  @ViewBuilder
  private var content: some View {
    if let hours = vm.forecast?.forecast?.forecastday.first?.hour {
      ScrollView(.horizontal) {
        LazyHStack(spacing: 12) {
          ForEach(hours) { hour in
            HourCard(hour: hour, tempUnit: vm.tempUnit)
          }
        }
        .padding()
      }
    } else if vm.isForecastLoading {
      ProgressView(tintColor: .white)
    } else if vm.forecastFailed {
      ContentUnavailableView {
        Label("Forecast unavailable", systemImage: "wifi.slash")
      } description: {
        Text("Check your connection and try again.")
      } actions: {
        Button("Try Again") { vm.loadForecastIfNeeded() }
      }
    } else {
      ContentUnavailableView("No hourly data", systemImage: "clock")
    }
  }
}

private struct HourCard: View {
  let hour: HourModel
  let tempUnit: TemperatureUnit

  private static let inputFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter
  }()

  private static let displayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "h a"
    return formatter
  }()

  private var timeLabel: String {
    guard let date = Self.inputFormatter.date(from: hour.time) else { return hour.time }
    return Self.displayFormatter.string(from: date)
  }

  private var temperature: String {
    let value = tempUnit == .celcius ? hour.tempC : hour.tempF
    return "\(Int(value.rounded()))°"
  }

  var body: some View {
    VStack(spacing: 8) {
      Text(timeLabel)
        .font(.caption)
        .fontWeight(.medium)
      Image(systemName: hour.condition.weatherCondition.symbolName(isDay: hour.isDay == 1))
        .symbolRenderingMode(.multicolor)
        .font(.title2)
      Text(temperature)
        .font(.headline)
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 10)
    .glassSurface(cornerRadius: Radius.control)
  }
}

struct HourlyForecastView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      HourlyForecastView(vm: WeatherDetailVM(weatherService: WeatherDataService()))
    }
  }
}
