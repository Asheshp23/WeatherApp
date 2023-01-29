import SwiftUI
import SpriteKit

struct SkyImageView: View {
  var weatherCondition: WeatherCondition = .overcast
  var body: some View {
    GeometryReader{
      proxy in
      Image("SKY")
      if weatherCondition == .overcast || weatherCondition == .cloudy
         || weatherCondition == .partlyCloudy {
        SpriteView(scene: CloudScene(), options: [.allowsTransparency])
          .ignoresSafeArea()
      } else if weatherCondition == .heavySnow || weatherCondition == .lightSnow ||
                  weatherCondition == .freezingDrizzle {
        SpriteView(scene: SnowFallScene(), options: [.allowsTransparency])
          .ignoresSafeArea()
      } else if weatherCondition == .heavyRain || weatherCondition == .lightRain
               || weatherCondition == .lightRainShower {
        SpriteView(scene: RainFallScene(), options: [.allowsTransparency])
          .ignoresSafeArea()
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
