import SwiftUI

struct WeatherDetailView: View {
  @State var selectedCity = "Toronto"
  @State var showCityList = false
  @State var showSettings = false
  @State var tempUnit : temperatureUnit = .celcius
  @StateObject var vm: WeatherDetailVM = WeatherDetailVM()
  //main view
  var body: some View {
    ZStack {
      SkyImageView()
      if vm.isLoading {
        ProgressView()
          .tint(.white)
          .accessibilityIdentifier("loadingView")
      }
      VStack(alignment: .center){
        HStack {
          Text(selectedCity)
            .font(.system(size : 35))
            .foregroundColor(.white)
            .shadow( radius: 5)
          Button(action: {
            showCityList.toggle()
          }){
            Image(systemName: "chevron.down")
              .foregroundColor(.white)
          }
          .accessibilityIdentifier("goToCityList")
        }.sheet(isPresented: $showCityList) {
          ListOfCitiesView(selectedCity: $selectedCity,
                           showCityList: $showCityList)
        }
        HStack(alignment: .top) {
          Text(self.vm.weather.temperature ?? "")
            .font(.system(size : 45))
            .fontWeight(.black)
            .foregroundColor(.white)
            .shadow( radius: 5)
          Text(tempUnit == .celcius ? "°C" : "°F")
            .foregroundColor(.white)
            .shadow(radius: 5)
        }
        Text("Feels like \(self.vm.weather.feelsLike ?? "")")
          .font(.title2)
          .foregroundColor(.white)
          .shadow(radius: 5)
        Text(self.vm.weather.weatherCondition ?? "")
          .font(.title2)
          .fontWeight(.heavy)
          .foregroundColor(.white)
          .shadow(radius: 5)
        HStack {
          Spacer()
          Text("Updated \(self.vm.weather.lastUpdatedTimeStampGmt ?? "")")
            .font(.caption)
            .fontWeight(.light)
            .foregroundColor(.white)
            .padding(.trailing, 8.0)
            .shadow( radius: 5)
        }
        Spacer()
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
      .sheet(isPresented: $showSettings, content: {
        SettingsView(tempUnit: $tempUnit,
                     showSettings: $showSettings)
      }
      )
      .toolbar {
        Button(action: {
          showSettings.toggle()
        }){
          Image(systemName: "gearshape")
            .foregroundColor(.white)
        }
        .accessibilityIdentifier("showSettings")
      }
      //api call on user selected city
      .onChange(of: selectedCity, perform: { i  in
        DispatchQueue.main.async {
          Task {
            await self.vm.fetchWeather(by: selectedCity,
                                       unit: tempUnit)
          }
        }
      })
      //api call on user selected temperature unit
      .onChange(of: tempUnit, perform: { newValue in
        Task {
          await self.vm.fetchWeather(by: selectedCity,
                                     unit: tempUnit)
        }
      })
      .onAppear{
        // default api call
        DispatchQueue.main.async {
          Task {
            await self.vm.fetchWeather(by: selectedCity,
                                       unit: tempUnit)
          }
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
