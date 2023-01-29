import SwiftUI
import CoreLocation
import CoreLocationUI

struct WeatherDetailView: View {
  @StateObject var vm: WeatherDetailVM = WeatherDetailVM()
  @StateObject var locationManager = LocationManager()

  var progressView: some View {
    ProgressView()
      .tint(.white)
      .accessibilityIdentifier("loadingView")
  }

  var cityNameView: some View {
    HStack(alignment: .center) {
      Button(action: {
        vm.isLocationButtonTapped.toggle()
        locationManager.requestLocation()
      }){
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

      Button(action: {
        if vm.isLocationButtonTapped {
          vm.isLocationButtonTapped.toggle()
        }
        vm.showCityList.toggle()
      }){
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
      Text(self.vm.weather.current.condition.text)
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
        .shadow( radius: 5)
    }
  }

  var photoGalleryView: some View {
    NavigationLink(destination: PhotoGalleryView()) {
      HStack{
        Image(systemName: "photo.on.rectangle.angled")
          .foregroundColor(.white)
        Text("Photo gallery")
          .font(.title)
          .fontWeight(.bold)
          .padding()
          .foregroundColor(.white)
          .accessibilityIdentifier("goToPhotos")
      }
    }
  }

  var contactUsView: some View {
    NavigationLink(destination: ContactUsView()) {
      HStack{
        Image(systemName: "envelope.fill")
          .foregroundColor(.white)
        Text("Contact us")
          .font(.title)
          .fontWeight(.bold)
          .padding()
          .foregroundColor(.white)
          .accessibilityIdentifier("goToContactUs")
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
    .sheet(isPresented: $vm.showSettings,
           content: {
      SettingsView(tempUnit: $vm.tempUnit,
                   showSettings: $vm.showSettings)
      .presentationDetents([.height(250.0)])
    }
    )
  }

  var body: some View {
    ZStack {
      GeometryReader { _ in
        SkyImageView(weatherCondition: vm.weather.current.condition.weatherCondition)
      }
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
        photoGalleryView
        contactUsView
      }
      .sheet(isPresented: $vm.showCityList) {
        ListOfCitiesView(selectedCity: $vm.selectedCity,
                         showCityList: $vm.showCityList)
        .presentationDetents([.medium, .large])
      }
      .toolbar { settingsView }
      .onChange(of: vm.selectedCity, perform: { newValue  in
        Task {
          await self.vm.fetchWeather()
        }
      })
      .onChange(of: locationManager.location, perform: { newValue in
        CLGeocoder().reverseGeocodeLocation(newValue, completionHandler: {(placemarks, error) -> Void in
          if error != nil {
            return
          } else if let city = placemarks?.first?.locality {
            self.vm.selectedCity = city
            Task {
              await self.vm.fetchWeather()
            }
          }
        })
      })
      .onAppear {
        Task {
          vm.isLocationButtonTapped.toggle()
          locationManager.requestLocation()
        }
      }
    }
  }
}

struct WeatherDetailView_Previews: PreviewProvider {
  static var previews: some View {
    WeatherDetailView()
  }
}
