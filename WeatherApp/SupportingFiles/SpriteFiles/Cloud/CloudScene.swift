import Foundation
import SpriteKit

class CloudScene: SKScene {
  var weatherCondition: WeatherCondition

  init(size: CGSize, weatherCondition: WeatherCondition) {
    self.weatherCondition = weatherCondition
    super.init(size: size)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didMove(to view: SKView) {
    scaleMode = .resizeFill
    backgroundColor = .clear
    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    let node = SKEmitterNode(fileNamed: "Cloud.sks")!
    node.particlePositionRange.dx = UIScreen.main.bounds.width
    node.position = CGPoint(x: self.size.width / 3, y: self.size.height)
    if weatherCondition == .partlyCloudy {
        node.particleBirthRate = 2
        node.particleLifetime = 25
        node.particleSpeed = 4
    } else if weatherCondition == .overcast {
      node.particleBirthRate = 0.15
      node.particleLifetime = 25
      node.particleSpeed = 25
    } else if weatherCondition == .cloudy {
      node.particleBirthRate = 0.75
      node.particleLifetime = 25
      node.particleSpeed = 25
    }
    addChild(node)
  }
}
