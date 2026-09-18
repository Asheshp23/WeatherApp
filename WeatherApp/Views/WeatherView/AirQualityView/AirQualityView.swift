import SwiftUI

struct AirQualityView: View {
  @ObservedObject var vm: WeatherDetailVM

  private var airQuality: AirQualityModel? {
    vm.airQuality
  }

  var body: some View {
    ZStack {
      SkyImageView(weatherCondition: vm.weather?.current.condition.weatherCondition ?? .cloudy)
        .ignoresSafeArea()
      content
    }
    .foregroundColor(.white)
    .navigationTitle("Air Quality")
    .navigationBarTitleDisplayMode(.inline)
  }

  @ViewBuilder
  private var content: some View {
    if let airQuality {
      ScrollView {
        VStack(spacing: 16) {
          AQIBadge(airQuality: airQuality)
          pollutantGrid(airQuality)
        }
        .padding()
      }
    } else if vm.isLoading {
      ProgressView(tintColor: .white)
    } else {
      ContentUnavailableView(
        "Air quality unavailable",
        systemImage: "aqi.medium",
        description: Text("Pull to refresh on the main screen and try again.")
      )
    }
  }

  private func pollutantGrid(_ airQuality: AirQualityModel) -> some View {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
      PollutantCard(title: "CO", value: airQuality.co)
      PollutantCard(title: "NO₂", value: airQuality.no2)
      PollutantCard(title: "O₃", value: airQuality.o3)
      PollutantCard(title: "SO₂", value: airQuality.so2)
      PollutantCard(title: "PM2.5", value: airQuality.pm2_5)
      PollutantCard(title: "PM10", value: airQuality.pm10)
    }
  }
}

private struct AQIBadge: View {
  let airQuality: AirQualityModel

  private var color: Color {
    switch airQuality.usEpaIndex {
    case 1: return .green
    case 2: return .yellow
    case 3: return .orange
    case 4: return .red
    case 5: return .purple
    default: return Color(red: 0.4, green: 0, blue: 0)
    }
  }

  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: airQuality.symbolName)
        .symbolRenderingMode(.multicolor)
        .font(.system(size: 48))
      Text("\(airQuality.usEpaIndex)")
        .font(.system(size: 40, weight: .bold))
      Text(airQuality.usEpaCategory)
        .font(.headline)
        .foregroundStyle(color)
      Text("US EPA Air Quality Index")
        .font(.caption)
        .opacity(0.75)
    }
    .frame(maxWidth: .infinity)
    .padding(20)
    .glassSurface(cornerRadius: Radius.card)
  }
}

private struct PollutantCard: View {
  let title: String
  let value: Double

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(title)
        .font(.caption)
        .fontWeight(.medium)
        .opacity(0.85)
      Text(String(format: "%.1f", value))
        .font(.headline)
        .fontWeight(.semibold)
      Text("µg/m³")
        .font(.caption2)
        .opacity(0.7)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(12)
    .glassSurface(cornerRadius: Radius.card)
  }
}

struct AirQualityView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      AirQualityView(vm: WeatherDetailVM(weatherService: WeatherDataService()))
    }
  }
}
