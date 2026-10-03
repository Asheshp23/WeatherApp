import SwiftUI
import SpriteKit

/// The app's condition-aware sky. It's the identity of the app, but it must never cost legibility:
/// every scene gets a scrim strong enough for white text, a night tint when `isDay` is false,
/// and particles are dimmed (and removed entirely under Reduce Motion).
struct SkyImageView: View {
  var weatherCondition: WeatherCondition = .overcast
  var isDay: Bool = true
  /// Adds the legibility scrim. Turn off only where nothing is drawn on top (none today).
  var showsScrim: Bool = true

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  enum SkyScene {
    case clear, clouds, fog, rain, snow
  }

  var skyScene: SkyScene { Self.scene(for: weatherCondition) }

  static func scene(for condition: WeatherCondition) -> SkyScene {
    switch condition {
    case .sunny:
      return .clear
    case .partlyCloudy, .cloudy, .overcast:
      return .clouds
    case .mist, .fog, .freezingFog:
      return .fog
    case .patchyRainPossible, .patchyFreezingDrizzlePossible, .thunderyOutbreaksPossible,
        .patchyLightDrizzle, .lightDrizzle, .freezingDrizzle, .heavyFreezingDrizzle,
        .patchyLightRain, .lightRain, .moderateRainAtTimes, .moderateRain,
        .heavyRainAtTimes, .heavyRain, .lightFreezingRain, .moderateOrHeavyFreezingRain,
        .lightRainShower, .moderateOrHeavyRainShower, .torrentialRainShower,
        .patchyLightRainWithThunder, .moderateOrHeavyRainWithThunder:
      return .rain
    case .patchySnowPossible, .patchySleetPossible, .blowingSnow, .blizzard,
        .lightSleet, .moderateOrHeavySleet, .patchyLightSnow, .lightSnow,
        .patchyModerateSnow, .moderateSnow, .patchyHeavySnow, .heavySnow, .icePellets,
        .lightSleetShowers, .moderateOrHeavySleetShowers, .lightSnowShowers,
        .moderateOrHeavySnowShowers, .lightShowersOfIcePellets, .moderateOrHeavyShowersOfIcePellets,
        .patchyLightSnowWithThunder, .moderateOrHeavySnowWithThunder:
      return .snow
    }
  }

  /// Base darkening per scene. Bright scenes (fog haze, snow on a light sky) need the most.
  /// Tuned so white body text over the brightest part of each image stays ≥ 4.5:1 after
  /// the plate tint is added, and ≥ 3:1 for the large hero temperature without a plate.
  private var scrimOpacity: Double {
    switch skyScene {
    case .clear: return 0.32
    case .clouds: return 0.36
    case .fog: return 0.42
    case .rain: return 0.15
    case .snow: return 0.40
    }
  }

  var body: some View {
    ZStack {
      // Overlay-on-clear keeps the fill image from widening the layout it sits behind.
      Color.clear
        .overlay {
          Image(skyScene == .rain ? "DARK SKY" : "SKY")
            .resizable()
            .scaledToFill()
        }
        .clipped()
      if skyScene == .fog {
        Color.white.opacity(0.35)
      }
      if !reduceMotion {
        particles
          .opacity(0.7)
          .allowsHitTesting(false)
      }
      if !isDay {
        // Night: pull the daytime image toward deep navy rather than shipping a second asset.
        Color(red: 0.03, green: 0.05, blue: 0.16).opacity(0.62)
      }
      if showsScrim {
        LinearGradient(
          colors: [.black.opacity(scrimOpacity + 0.08), .black.opacity(scrimOpacity), .black.opacity(scrimOpacity + 0.12)],
          startPoint: .top,
          endPoint: .bottom
        )
      }
    }
    .ignoresSafeArea()
    .accessibilityHidden(true)
  }

  @ViewBuilder
  private var particles: some View {
    switch skyScene {
    case .clear, .fog:
      EmptyView()
    case .clouds:
      SpriteView(scene: CloudScene(size: CGSize(width: 50, height: 50), weatherCondition: weatherCondition), options: [.allowsTransparency])
    case .rain:
      SpriteView(scene: RainFallScene(size: CGSize(width: 100, height: 100), weatherCondition: weatherCondition), options: [.allowsTransparency])
    case .snow:
      SpriteView(scene: SnowFallScene(size: CGSize(width: 100, height: 100), weatherCondition: weatherCondition), options: [.allowsTransparency])
    }
  }
}

#Preview("Day") { SkyImageView(weatherCondition: .sunny) }
#Preview("Night rain") { SkyImageView(weatherCondition: .moderateRain, isDay: false) }
#Preview("Snow") { SkyImageView(weatherCondition: .heavySnow) }
