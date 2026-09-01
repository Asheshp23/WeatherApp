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
  
  // Background and loading view
  private var backgroundView: some View {
    SkyImageView(weatherCondition: vm.weather?.current.condition.weatherCondition ?? .cloudy)
      .ignoresSafeArea()
      .overlay(loadingOverlay)
  }
  
  // Main content of the view
  private var content: some View {
    VStack {
      cityNameView
      temperatureDetailView
      lastUpdatedTimeView
      Spacer()
      navigationLinks
    }
    .padding()
    .foregroundColor(.white)
    .sheet(isPresented: $vm.showCityList) {
      ListOfCitiesView(selectedCity: $vm.selectedCity, showCityList: $vm.showCityList)
        .presentationDetents([.medium, .large])
    }
    .sheet(isPresented: $vm.showSettings) {
      SettingsView(tempUnit: $vm.tempUnit, showSettings: $vm.showSettings)
        .presentationDetents([.height(250.0)])
    }
  }
  
  // Loading overlay
  private var loadingOverlay: some View {
    Group {
      if vm.isLoading { ProgressView() }
    }
  }
  
  // Views for city name and details
  private var cityNameView: some View {
    HStack {
      locationButton
      Text(vm.selectedCity)
        .font(.largeTitle)
        .fontWeight(.bold)
        .shadow(radius: 5)
      cityListButton
    }
  }
  
  private var temperatureDetailView: some View {
    VStack(alignment: .center) {
      Text("\(vm.temperature)° \(vm.tempUnit == .celcius ? "C" : "F")")
        .font(.system(size: 45))
        .fontWeight(.black)
        .shadow(radius: 5)
      Text("Feels like \(vm.feelslike)")
        .font(.title2)
        .shadow(radius: 5)
      Text(vm.weather?.current.condition.text ?? "Not available")
        .font(.title2)
        .fontWeight(.heavy)
        .shadow(radius: 5)
    }
  }
  
  private var lastUpdatedTimeView: some View {
    HStack {
      Spacer()
      Text("Updated \(vm.lastUpdatedAt)")
        .font(.caption)
        .fontWeight(.light)
        .padding(.trailing, 8.0)
        .shadow(radius: 5)
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
  }
  
  private var cityListButton: some View {
    Button(action: vm.handleShowCityListButtonTap) {
      Image(systemName: "chevron.down")
        .font(Font.system(size: 26))
    }
    .accessibilityIdentifier("goToCityList")
  }
  
  // Navigation links section
  private var navigationLinks: some View {
    VStack(spacing: 16) {
      StyledNavigationLink(destination: PhotoGalleryView(), label: "Photo Gallery", imageName: "photo.on.rectangle.angled", accessibilityIdentifier: "goToPhotos")
      StyledNavigationLink(destination: ContactUsView(), label: "Contact Us", imageName: "envelope.fill", accessibilityIdentifier: "goToContactUs")
      StyledNavigationLink(destination: WeatherMapView(cityName: $vm.selectedCity, temperature: vm.temperature, userLocation: vm.isLocationButtonTapped ? vm.userLocation : vm.selectedCityLocation), label: "View it on the Map", imageName: "map", accessibilityIdentifier: "goToMapView")
    }
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

struct WeatherDetailView_Previews: PreviewProvider {
  static var previews: some View {
    WeatherDetailView()
  }
}
