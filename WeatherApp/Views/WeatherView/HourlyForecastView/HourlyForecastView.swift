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
      ScrollView {
        LazyVStack(spacing: 8) {
          ForEach(hours) { hour in
            HourRow(hour: hour, tempUnit: vm.tempUnit)
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

private struct HourRow: View {
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
    if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .hour) { return "Now" }
    return Self.displayFormatter.string(from: date)
  }

  private var temperature: String {
    let value = tempUnit == .celcius ? hour.tempC : hour.tempF
    return "\(Int(value.rounded()))°"
  }

  private var precipitationChance: Int {
    max(hour.chanceOfRain, hour.chanceOfSnow)
  }

  var body: some View {
    HStack(spacing: 12) {
      Text(timeLabel)
        .font(.body.weight(.semibold))
        .frame(width: 60, alignment: .leading)
      Image(systemName: hour.condition.weatherCondition.symbolName(isDay: hour.isDay == 1))
        .symbolRenderingMode(.multicolor)
        .frame(width: 30)
      if precipitationChance > 0 {
        HStack(spacing: 2) {
          Image(systemName: "drop.fill")
            .font(.caption2)
          Text("\(precipitationChance)%")
            .font(.caption)
        }
        .foregroundStyle(.cyan)
      }
      Spacer()
      Text(temperature)
        .font(.headline)
        .fontWeight(.semibold)
    }
    .padding(12)
    .glassSurface(cornerRadius: Radius.card)
  }
}

struct HourlyForecastView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      HourlyForecastView(vm: WeatherDetailVM(weatherService: WeatherDataService()))
    }
  }
}
