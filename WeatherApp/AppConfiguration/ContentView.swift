import SwiftUI

struct ContentView: View {
  @State private var bootstrap = AppBootstrapService()
  @State private var showLaunchScreen = true

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    ZStack {
      if showLaunchScreen {
        LaunchAnimationView()
          .transition(launchScreenTransition)
          .zIndex(1)
      } else {
        NavigationStack {
          WeatherDetailView(
            locationManager: bootstrap.locationManager,
            prefetchedCity: bootstrap.prefetchedCity,
            prefetchedWeather: bootstrap.prefetchedWeather
          )
        }
        .transition(.opacity)
      }
    }
    .task {
      await bootstrap.run()
      withAnimation(reduceMotion ? .linear(duration: 0.2) : .easeInOut(duration: 0.5)) {
        showLaunchScreen = false
      }
    }
  }

  private var launchScreenTransition: AnyTransition {
    reduceMotion ? .opacity : .asymmetric(insertion: .opacity, removal: .scale(scale: 0.92).combined(with: .opacity))
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
