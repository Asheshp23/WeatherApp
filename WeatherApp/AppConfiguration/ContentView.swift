import SwiftUI

/// Two top-level areas: Weather (the product) and Photos (gallery + editor, unrelated to weather).
/// Contact Us lives in Settings. Keeping Photos in its own tab stops it from competing with weather
/// content while staying one tap away.
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
        TabView {
          NavigationStack {
            WeatherDetailView(
              locationManager: bootstrap.locationManager,
              prefetchedCity: bootstrap.prefetchedCity,
              prefetchedWeather: bootstrap.prefetchedWeather
            )
          }
          .tabItem { Label("Weather", systemImage: "cloud.sun") }

          NavigationStack {
            PhotoGalleryView()
          }
          .tabItem { Label("Photos", systemImage: "photo.on.rectangle") }
          .accessibilityIdentifier("goToPhotos")
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

#Preview {
  ContentView()
}
