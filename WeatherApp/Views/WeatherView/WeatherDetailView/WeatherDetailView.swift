import SwiftUI

struct WeatherDetailView: View {
  @State var vm: WeatherDetailVM = WeatherDetailVM(weatherService: WeatherDataService())
  @State var locationManager = LocationManager()
  
  var cityNameView: some View {
    HStack {
      Button(action: handleLocationButtonTap) {
        Image(systemName: vm.isLocationButtonTapped ? "location.fill" : "location")
          .resizable()
          .frame(width: 24, height: 24)
          .padding(.leading)
      }
      Text(vm.selectedCity)
        .font(.largeTitle)
        .shadow(radius: 5)
        .fontWeight(.bold)
      Button(action: vm.handleShowCityListButtonTap) {
        Image(systemName: "chevron.down")
          .font(.headline)
          .padding(.trailing)
      }
      .accessibilityIdentifier("goToCityList")
    }
    .padding(.bottom, -12.0)
  }
  
  var temperatureDetailView: some View {
    VStack(alignment: .center) {
      Text("\(vm.temperature)\(vm.tempUnit == .celcius ? "° C" : "° F")")
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
  
  var lastUpdatedTimeView: some View {
    HStack {
      Spacer()
      Text("Updated \(vm.lastUpdatedAt)")
        .font(.caption)
        .fontWeight(.light)
        .padding(.trailing, 8.0)
        .shadow(radius: 5)
    }
  }
  
  var body: some View {
    ZStack {
      SkyImageView(weatherCondition: WeatherCondition(rawValue: ((vm.weather?.current.condition.weatherCondition) ?? .cloudy).rawValue) ?? .cloudy)
        .ignoresSafeArea()
      
      if vm.isLoading {
        ProgressView()
      }
      
      VStack {
        cityNameView
        temperatureDetailView
        lastUpdatedTimeView
        Spacer()
        StyledNavigationLink(destination: PhotoGalleryView(), label: "Photo Gallery", imageName: "photo.on.rectangle.angled", accessibilityIdentifier: "goToPhotos")
        StyledNavigationLink(destination: ContactUsView(), label: "Contact Us", imageName: "envelope.fill", accessibilityIdentifier: "goToContactUs")
        StyledNavigationLink(destination:
                              WeatherMapView(cityName: $vm.selectedCity,
                                             temperature: vm.temperature,
                                             userLocation: vm.isLocationButtonTapped ?
                                             vm.userLocation : vm.selectedCityLocation),
                             label: "View it on the Map",
                             imageName: "map",
                             accessibilityIdentifier: "goToMapView")
      }
      .foregroundStyle(
        .white.adaptedTextColor()
      )
      .padding()
      .sheet(isPresented: $vm.showCityList) {
        ListOfCitiesView(selectedCity: $vm.selectedCity, showCityList: $vm.showCityList)
          .presentationDetents([.medium, .large])
      }
      .sheet(isPresented: $vm.showSettings) {
        SettingsView(tempUnit: $vm.tempUnit, showSettings: $vm.showSettings)
          .presentationDetents([.height(250.0)])
      }
      .toolbar {
        SettingsButtonView(showSettings: $vm.showSettings)
      }
      .onChange(of: vm.selectedCity) { oldValue, newValue  in
        Task {
          if vm.selectedCity != "" {
            vm.getLocationFromCityName()
            await vm.fetchWeather()
          }
        }
      }
      .onChange(of: locationManager.location) { oldValue, newLocation in
        if let newLocation = newLocation, vm.isLocationButtonTapped {
          vm.userLocation = newLocation.coordinate
          Task {
            await vm.handleLocationUpdate(newValue: newLocation)
          }
        } else {
          return
        }
      }
      .onAppear {
        locationManager.requestLocation()
      }
    }
  }
  
  fileprivate func handleLocationButtonTap() {
    vm.handleLocationButtonTap()
  }
}

struct WeatherDetailView_Previews: PreviewProvider {
  static var previews: some View {
    WeatherDetailView(locationManager: LocationManager())
  }
}
