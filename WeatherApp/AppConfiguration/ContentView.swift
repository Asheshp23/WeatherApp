import SwiftUI

struct ContentView: View {
  @StateObject var vm: WeatherDetailVM = WeatherDetailVM()
  
  var body: some View {
    NavigationStack {
      WeatherDetailView()
        .environmentObject(vm)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
