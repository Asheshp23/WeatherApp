import Foundation
import SpriteKit

class RainFallScene: SKScene {
  var weatherCondition: WeatherCondition

  init(size: CGSize, weatherCondition: WeatherCondition) {
    self.weatherCondition = weatherCondition
    super.init(size: size)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func sceneDidLoad() {
    size = UIScreen.main.bounds.size
    scaleMode = .resizeFill
    anchorPoint = CGPoint(x: 0.5, y: 1)
    backgroundColor = .clear
    let node = SKEmitterNode(fileNamed: "RainFall.sks")!
    addChild(node)
    node.particlePositionRange.dx = UIScreen.main.bounds.width
    if weatherCondition == .heavyRain {
      node.particleBirthRate = 15
      node.particleLifetime = 12
    } else if weatherCondition == .lightRain {
      node.particleBirthRate = 2
      node.particleLifetime = 15
    } else if weatherCondition == .moderateRain {
      node.particleBirthRate = 4
      node.particleLifetime = 20
    } else if weatherCondition == .lightRainShower {
      node.particleBirthRate = 3
      node.particleLifetime = 25
    }
    node.particleSpeed = 25
  }
}
