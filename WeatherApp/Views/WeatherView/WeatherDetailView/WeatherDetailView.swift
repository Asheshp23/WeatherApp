import SwiftUI

struct WeatherDetailView: View {
  @StateObject var vm: WeatherDetailVM = WeatherDetailVM(weatherService: WeatherDataService())
  @StateObject var locationManager = LocationManager()
  
  var cityNameView: some View {
    HStack {
      Button(action: handleLocatonButtonTap) {
        Image(systemName: vm.isLocationButtonTapped ? "location.fill" : "location")
          .resizable()
          .frame(width: 24, height: 24)
          .foregroundColor(.white)
          .padding(.leading)
      }
      Text(vm.selectedCity)
        .font(.largeTitle)
        .foregroundColor(.white)
        .shadow(radius: 5)
        .fontWeight(.bold)
      Button(action: vm.handleShowCityListButtonTap) {
        Image(systemName: "chevron.down")
          .foregroundColor(.white)
          .font(.headline)
          .padding(.trailing)
      }
      .accessibilityIdentifier("goToCityList")
    }
    .padding(.bottom, -12.0)
  }
  
  var temperatureDetailView: some View {
    VStack(alignment: .leading) {
      Text("\(vm.temperature)\(vm.tempUnit == .celcius ? "° C" : "° F")")
        .font(.system(size: 45))
        .fontWeight(.black)
        .foregroundColor(.white)
        .shadow(radius: 5)
      Text("Feels like \(vm.feelslike)")
        .font(.title2)
        .foregroundColor(.white)
        .shadow(radius: 5)
      Text(vm.weather?.current.condition.text ?? "Not available")
        .font(.title2)
        .fontWeight(.heavy)
        .foregroundColor(.white)
        .shadow(radius: 5)
    }
  }
  
  var lastUpdatedTimeView: some View {
    HStack {
      Spacer()
      Text("Updated \(vm.lastUpdatedAt)")
        .font(.caption)
        .foregroundColor(.white)
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
          vm.getLocationFromCityName()
          await vm.fetchWeather()
        }
      }
      .onChange(of: locationManager.location) { oldValue, newLocation in
        if let newLocation = newLocation, vm.selectedCity.isEmpty {
          vm.userLocation = newLocation.coordinate
          Task {
            await vm.handleLocationUpdate(newValue: newLocation)
          }
        }
      }
      .task {
        locationManager.requestLocation()
      }
    }
  }
  
  fileprivate func handleLocatonButtonTap() {
    vm.handleLocatonButtonTap()
    locationManager.requestLocation()
  }
}

struct WeatherDetailView_Previews: PreviewProvider {
  static var previews: some View {
    WeatherDetailView()
  }
}
