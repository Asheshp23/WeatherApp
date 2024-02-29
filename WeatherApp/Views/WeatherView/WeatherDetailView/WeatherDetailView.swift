import SwiftUI
import CoreLocation
import CoreLocationUI

struct WeatherDetailView: View {
  @StateObject var vm: WeatherDetailVM = WeatherDetailVM(weatherService: WeatherDataService())
  @StateObject var locationManager = LocationManager()
  
  var progressView: some View {
    ProgressView()
      .tint(.white)
      .accessibilityIdentifier("loadingView")
  }
  
    fileprivate func handleLocatonButtonTap() {
        vm.selectedCity = ""
        vm.isLocationButtonTapped.toggle()
        locationManager.requestLocation()
    }
    
    fileprivate func handleShowCityListButtonTap() {
        vm.isLocationButtonTapped = false
        vm.showCityList.toggle()
    }
    
    var cityNameView: some View {
    HStack(alignment: .center) {
      Button(action: handleLocatonButtonTap){
        Image(systemName: vm.isLocationButtonTapped ? "location.fill" :"location")
          .resizable()
          .foregroundColor(.white)
          .frame(width: 24.0, height: 24.0)
          .font(.headline)
          .padding(.leading)
      }
      Text(vm.selectedCity)
        .font(.largeTitle)
        .foregroundColor(.white)
        .shadow(radius: 5)
        .fontWeight(.bold)
      
      Button(action: handleShowCityListButtonTap){
        HStack {
          Image(systemName: "chevron.down")
            .foregroundColor(.white)
            .font(.headline)
            .padding([.top, .bottom, .trailing])
        }
      }
      .accessibilityIdentifier("goToCityList")
    }
  }
  
  var temperatureDetailView: some View {
    VStack {
      HStack(alignment: .top) {
        Text("\(vm.temperature)")
          .font(.system(size : 45))
          .fontWeight(.black)
          .foregroundColor(.white)
          .shadow( radius: 5)
        Text(vm.tempUnit == .celcius ? "°C" : "°F")
          .foregroundColor(.white)
          .shadow(radius: 5)
      }
      Text("Feels like \(vm.feelslike)")
        .font(.title2)
        .foregroundColor(.white)
        .shadow(radius: 5)
      Text(self.vm.weather?.current.condition.text ?? "Not available")
        .font(.title2)
        .fontWeight(.heavy)
        .foregroundColor(.white)
        .shadow(radius: 5)
    }
  }
  
  var lastUpdatedTimeView: some View {
    HStack {
      Spacer()
      Text("Updated \(self.vm.lastUpdatedAt)")
        .font(.caption)
        .fontWeight(.light)
        .foregroundColor(.white)
        .padding(.trailing, 8.0)
        .shadow(radius: 5)
    }
  }
  
  var photoGalleryView: some View {
    NavigationLink(destination: PhotoGalleryView()) {
      VStack(alignment: .center) {
        HStack {
          Image(systemName: "photo.on.rectangle.angled")
            .foregroundColor(.white)
            .font(.title.bold())
          Text("Photo gallery")
            .font(.title)
            .fontWeight(.bold)
            .padding()
            .foregroundColor(.white)
            .accessibilityIdentifier("goToPhotos")
        }
      }
    }
  }
  
  var contactUsView: some View {
    NavigationLink(destination: ContactUsView()) {
      VStack(alignment: .center) {
        HStack {
          Image(systemName: "envelope.fill")
            .foregroundColor(.white)
            .font(.title.bold())
          Text("Contact us")
            .font(.title)
            .fontWeight(.bold)
            .padding()
            .foregroundColor(.white)
            .accessibilityIdentifier("goToContactUs")
        }
      }
    }
  }
  
  var settingsView: some View {
    Button(action: {
      vm.showSettings.toggle()
    }){
      Image(systemName: "gearshape")
        .foregroundColor(.white)
    }
    .accessibilityIdentifier("showSettings")
  }
  
  var viewItOnMapView: some View {
    NavigationLink(destination: WeatherMapView(cityName: $vm.selectedCity, temperature: vm.temperature, userLocation: vm.userLocation)) {
      HStack {
        Image(systemName: "map")
          .foregroundColor(.white)
          .font(.title.bold())
        Text("View it on the map ")
          .foregroundColor(.white)
          .font(.title.bold())
      }
    }
  }
  
  var body: some View {
    ZStack {
        SkyImageView(weatherCondition: WeatherCondition(rawValue: ((vm.weather?.current.condition.weatherCondition) ?? .cloudy).rawValue) ?? .cloudy)
            .ignoresSafeArea()
      if vm.isLoading {
        progressView
      }
      VStack(alignment: .center) {
        cityNameView
          .padding(.bottom, -12.0)
        temperatureDetailView
        lastUpdatedTimeView
        Spacer()
        viewItOnMapView
        photoGalleryView
        contactUsView
      }
      .sheet(isPresented: $vm.showCityList) {
        ListOfCitiesView(selectedCity: $vm.selectedCity,
                         showCityList: $vm.showCityList)
        .presentationDetents([.medium, .large])
      }
      .sheet(isPresented: $vm.showSettings,
             content: {
        SettingsView(tempUnit: $vm.tempUnit,
                     showSettings: $vm.showSettings)
        .presentationDetents([.height(250.0)])
      }
      )
      .toolbar { settingsView }
      .onChange(of: vm.selectedCity, perform: { newValue  in
        Task {
          await self.vm.fetchWeather()
        }
      })
      .onChange(of: locationManager.location, perform: { newLocation in
          if let newLocation = newLocation, vm.selectedCity.isEmpty {
              vm.userLocation = newLocation.coordinate
              Task {
                await vm.handleLocationUpdate(newValue: newLocation)
              }
          }
      })
      .task {
        locationManager.requestLocation()
      }
    }
  }
}

struct WeatherDetailView_Previews: PreviewProvider {
  static var previews: some View {
    WeatherDetailView()
  }
}
