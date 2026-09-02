import SwiftUI
import SpriteKit

struct SkyImageView: View {
  var weatherCondition: WeatherCondition = .overcast

  private enum SkyScene {
    case clear
    case clouds
    case fog
    case rain
    case snow
  }

  private var skyScene: SkyScene {
    switch weatherCondition {
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

  var body: some View {
    GeometryReader { _ in
      switch skyScene {
      case .clear:
        Image("SKY")
      case .clouds:
        Image("SKY")
        SpriteView(scene: CloudScene(size: CGSize(width: 50, height: 50), weatherCondition: weatherCondition), options: [.allowsTransparency])
          .ignoresSafeArea()
          .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
      case .fog:
        Image("SKY")
        Color.white.opacity(0.35)
          .ignoresSafeArea()
      case .rain:
        Image("DARK SKY")
        SpriteView(scene: RainFallScene(size: CGSize(width: 100, height: 100), weatherCondition: weatherCondition), options: [.allowsTransparency])
          .ignoresSafeArea()
          .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
      case .snow:
        Image("SKY")
        SpriteView(scene: SnowFallScene(size: CGSize(width: 100, height: 100), weatherCondition: weatherCondition), options: [.allowsTransparency])
          .ignoresSafeArea()
          .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
      }
    }
    .ignoresSafeArea()
  }
}

struct SkyImageView_Previews: PreviewProvider {
  static var previews: some View {
    SkyImageView()
  }
}
