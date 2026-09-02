import SwiftUI

struct DailyForecastView: View {
  @ObservedObject var vm: WeatherDetailVM

  private var days: [ForecastDay] {
    vm.forecast?.forecast?.forecastday ?? []
  }

  var body: some View {
    ZStack {
      SkyImageView(weatherCondition: vm.weather?.current.condition.weatherCondition ?? .cloudy)
        .ignoresSafeArea()
      content
    }
    .foregroundColor(.white)
    .navigationTitle(days.isEmpty ? "Daily Forecast" : "\(days.count)-Day Forecast")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      vm.loadForecastIfNeeded()
    }
  }

  @ViewBuilder
  private var content: some View {
    if !days.isEmpty {
      ScrollView {
        LazyVStack(spacing: 8) {
          ForEach(days) { day in
            DayRow(day: day, tempUnit: vm.tempUnit)
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
      ContentUnavailableView("No forecast data", systemImage: "calendar")
    }
  }
}

private struct DayRow: View {
  let day: ForecastDay
  let tempUnit: TemperatureUnit

  private static let inputFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()

  private static let displayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    return formatter
  }()

  private var weekdayLabel: String {
    guard let date = Self.inputFormatter.date(from: day.date) else { return day.date }
    if Calendar.current.isDateInToday(date) { return "Today" }
    return Self.displayFormatter.string(from: date)
  }

  private func temperature(_ celsius: Double, _ fahrenheit: Double) -> String {
    let value = tempUnit == .celcius ? celsius : fahrenheit
    return "\(Int(value.rounded()))°"
  }

  var body: some View {
    HStack {
      Text(weekdayLabel)
        .font(.body.weight(.semibold))
        .frame(width: 90, alignment: .leading)
      Image(systemName: day.day.condition.weatherCondition.symbolName(isDay: true))
        .symbolRenderingMode(.multicolor)
        .frame(width: 30)
      Spacer()
      Text(temperature(day.day.mintempC, day.day.mintempF))
        .foregroundStyle(.secondary)
      Text(temperature(day.day.maxtempC, day.day.maxtempF))
        .fontWeight(.semibold)
    }
    .padding(12)
    .glassSurface(cornerRadius: Radius.card)
  }
}

struct DailyForecastView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      DailyForecastView(vm: WeatherDetailVM(weatherService: WeatherDataService()))
    }
  }
}
