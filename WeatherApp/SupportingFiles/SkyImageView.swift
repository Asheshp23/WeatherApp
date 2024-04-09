import SwiftUI
import SpriteKit

struct SkyImageView: View {
  var weatherCondition: WeatherCondition = .overcast
  var body: some View {
    GeometryReader {
      proxy in
      if weatherCondition == .overcast || weatherCondition == .cloudy
          || weatherCondition == .partlyCloudy {
        Image("SKY")
        SpriteView(scene: CloudScene(size: CGSize(width: 50, height: 50), weatherCondition: weatherCondition), options: [.allowsTransparency])
          .ignoresSafeArea()
          .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
      } else if weatherCondition == .heavySnow || weatherCondition == .lightSnow ||
                  weatherCondition == .freezingDrizzle {
        Image("SKY")
        SpriteView(scene: SnowFallScene(size: CGSize(width: 100, height: 100), weatherCondition: weatherCondition), options: [.allowsTransparency])
          .ignoresSafeArea()
          .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
      } else if weatherCondition == .heavyRain || weatherCondition == .lightRain
                  || weatherCondition == .lightRainShower {
        Image("DARK SKY")
        SpriteView(scene: RainFallScene(size: CGSize(width: 100, height: 100), weatherCondition: weatherCondition), options: [.allowsTransparency])
          .ignoresSafeArea()
          .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
      } else {
        Image("SKY")
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
