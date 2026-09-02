import SwiftUI
import CoreLocation

struct WeatherDetailView: View {
  @StateObject private var vm: WeatherDetailVM
  @State private var locationManager: LocationManager

  init(locationManager: LocationManager = LocationManager(), prefetchedCity: String? = nil, prefetchedWeather: WeatherModel? = nil) {
    _locationManager = State(wrappedValue: locationManager)
    _vm = StateObject(wrappedValue: WeatherDetailVM(weatherService: WeatherDataService(), initialCity: prefetchedCity, initialWeather: prefetchedWeather))
  }

  var body: some View {
    ZStack {
      backgroundView
      content
    }
    .onAppear {
      locationManager.requestLocation()
      if vm.weather == nil && !vm.selectedCity.isEmpty {
        vm.fetchWeather()
      }
    }
    .onChange(of: vm.selectedCity, { oldValue, newValue in
      handleCityChange(oldValue: oldValue, newValue: newValue)
    })
    .onChange(of: locationManager.location, { oldValue, newValue in
      handleLocationChange(oldValue: oldValue, newValue: newValue)
    })
    .toolbar {
      SettingsButtonView(showSettings: $vm.showSettings)
    }
  }
  
  // Background sky, plus a loading indicator while the first fetch is in flight
  private var backgroundView: some View {
    SkyImageView(weatherCondition: vm.weather?.current.condition.weatherCondition ?? .cloudy)
      .ignoresSafeArea()
      .overlay(loadingOverlay)
  }
  
  // Main content of the view
  private var content: some View {
    ScrollView {
      VStack(spacing: 28) {
        cityNameView
        currentConditionView
        weatherDetailsGrid
        lastUpdatedTimeView
        exploreSection
      }
      .padding()
      .padding(.top, 8)
    }
    .refreshable {
      vm.fetchWeather()
    }
    .foregroundColor(.white)
    .sheet(isPresented: $vm.showCityList) {
      ListOfCitiesView(selectedCity: $vm.selectedCity, weatherService: vm.weatherService)
    }
    .sheet(isPresented: $vm.showSettings) {
      SettingsView(tempUnit: $vm.tempUnit)
    }
  }
  
  // Loading overlay
  private var loadingOverlay: some View {
    Group {
      if vm.isLoading { ProgressView() }
    }
  }
  
  // City name and navigation controls
  private var cityNameView: some View {
    HStack {
      locationButton
      Text(vm.selectedCity)
        .font(.title2)
        .fontWeight(.bold)
        .lineLimit(1)
        .shadow(radius: 5)
      cityListButton
    }
  }
  
  // Weather icon, temperature, condition text and feels-like
  private var currentConditionView: some View {
    VStack(spacing: 6) {
      Image(systemName: vm.conditionSymbolName)
        .symbolRenderingMode(.multicolor)
        .font(.system(size: 56))
        .shadow(radius: 6)
      Text("\(vm.temperature)°\(vm.temperatureUnitSymbol)")
        .font(.system(size: 64, weight: .thin))
        .shadow(radius: 5)
      Text(vm.weather?.current.condition.text ?? "Not available")
        .font(.title3)
        .fontWeight(.semibold)
        .shadow(radius: 5)
      Text("Feels like \(vm.feelslike)°")
        .font(.subheadline)
        .opacity(0.85)
        .shadow(radius: 3)
    }
    .accessibilityElement(children: .combine)
  }
  
  // Humidity, wind, UV, visibility and pressure at a glance
  private var weatherDetailsGrid: some View {
    Group {
      if vm.weather != nil {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
          WeatherDetailCard(icon: "humidity.fill", title: "Humidity", value: vm.humidityText)
          WeatherDetailCard(icon: "wind", title: "Wind", value: vm.windText)
          WeatherDetailCard(icon: "sun.max.fill", title: "UV Index", value: "\(vm.uvIndexText) · \(vm.uvDescription)")
          WeatherDetailCard(icon: "eye.fill", title: "Visibility", value: vm.visibilityText)
          WeatherDetailCard(icon: "barometer", title: "Pressure", value: vm.pressureText)
        }
      }
    }
  }
  
  private var lastUpdatedTimeView: some View {
    Text("Updated \(vm.lastUpdatedAt)")
      .font(.caption)
      .fontWeight(.light)
      .opacity(0.8)
      .shadow(radius: 5)
  }
  
  // Secondary destinations, visually separated from the weather content
  private var exploreSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Explore")
        .font(.headline)
        .padding(.leading, 4)

      exploreGroup(title: "Forecast") {
        ExploreTile(destination: HourlyForecastView(vm: vm), label: "Hourly", imageName: "clock.fill", accessibilityIdentifier: "goToHourlyForecast")
        ExploreTile(destination: DailyForecastView(vm: vm), label: "7-Day", imageName: "calendar", accessibilityIdentifier: "goToDailyForecast")
        ExploreTile(destination: WeatherAlertsView(vm: vm), label: "Alerts", imageName: "exclamationmark.triangle.fill", accessibilityIdentifier: "goToAlerts")
      }

      exploreGroup(title: "More") {
        ExploreTile(destination: SavedCitiesView(selectedCity: $vm.selectedCity, weatherService: vm.weatherService), label: "Saved Cities", imageName: "star.fill", accessibilityIdentifier: "goToSavedCities")
        ExploreTile(destination: PhotoGalleryView(), label: "Photo Gallery", imageName: "photo.on.rectangle.angled", accessibilityIdentifier: "goToPhotos")
        ExploreTile(destination: ContactUsView(), label: "Contact Us", imageName: "envelope.fill", accessibilityIdentifier: "goToContactUs")
        ExploreTile(destination: WeatherMapView(cityName: $vm.selectedCity, temperature: vm.temperature, userLocation: vm.isLocationButtonTapped ? vm.userLocation : vm.selectedCityLocation), label: "Map", imageName: "map", accessibilityIdentifier: "goToMapView")
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private func exploreGroup(title: String, @ViewBuilder tiles: () -> some View) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.subheadline.weight(.semibold))
        .opacity(0.85)
        .padding(.leading, 4)
      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        tiles()
      }
    }
  }
  
  // Location and city list buttons
  private var locationButton: some View {
    Button(action: handleLocationButtonTap) {
      Image(systemName: vm.isLocationButtonTapped ? "location.fill" : "location")
        .resizable()
        .frame(width: 24, height: 24)
        .padding(.leading)
    }
    .accessibilityLabel("Use current location")
  }
  
  private var cityListButton: some View {
    Button(action: vm.handleShowCityListButtonTap) {
      Image(systemName: "chevron.down")
        .font(Font.system(size: 26))
    }
    .accessibilityIdentifier("goToCityList")
    .accessibilityLabel("Choose a city")
  }
  
  // Action functions
  private func handleLocationButtonTap() {
    locationManager.requestLocation()
    vm.handleLocationButtonTap()
  }
  
  private func handleCityChange(oldValue: String, newValue: String) {
    Task {
      if !newValue.isEmpty {
        vm.getLocationFromCityName()
        vm.fetchWeather()
        vm.forecast = nil
        vm.forecastFailed = false
      }
    }
  }
  
  private func handleLocationChange(oldValue: CLLocation?, newValue: CLLocation?) {
    if let newLocation = newValue, vm.isLocationButtonTapped {
      vm.userLocation = newLocation.coordinate
      Task { await vm.handleLocationUpdate(newValue: newLocation) }
    }
  }
}

// A single stat card used in the weather details grid
private struct WeatherDetailCard: View {
  let icon: String
  let title: String
  let value: String

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack(spacing: 6) {
        Image(systemName: icon)
          .font(.subheadline)
        Text(title)
          .font(.caption)
          .fontWeight(.medium)
      }
      .opacity(0.85)
      Text(value)
        .font(.headline)
        .fontWeight(.semibold)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.white.opacity(0.25))
    )
    .accessibilityElement(children: .combine)
  }
}

// A single Explore destination tile — the identifier goes on the NavigationLink
// itself (not an inner Text) so it stays a reliable app.buttons[...] target.
private struct ExploreTile<Destination: View>: View {
  let destination: Destination
  let label: String
  let imageName: String
  let accessibilityIdentifier: String

  var body: some View {
    NavigationLink(destination: destination) {
      VStack(spacing: 8) {
        Image(systemName: imageName)
          .font(.title2)
        Text(label)
          .font(.caption)
          .fontWeight(.medium)
          .lineLimit(1)
          .minimumScaleFactor(0.8)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 14)
    }
    .buttonStyle(PressableButtonStyle())
    .glassSurface(cornerRadius: Radius.control)
    .accessibilityIdentifier(accessibilityIdentifier)
  }
}

struct WeatherDetailView_Previews: PreviewProvider {
  static var previews: some View {
    WeatherDetailView()
  }
}
