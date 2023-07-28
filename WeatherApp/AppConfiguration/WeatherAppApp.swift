import SwiftUI

@main
struct WeatherAppApp: App {
  @StateObject var vm: WeatherDetailVM = WeatherDetailVM()
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(vm)
    }
  }
}
