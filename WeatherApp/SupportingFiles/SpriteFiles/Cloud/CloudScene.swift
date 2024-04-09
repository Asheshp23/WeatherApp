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
  
  override func sceneDidLoad() {
    scaleMode = .resizeFill
    backgroundColor = .clear
    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    let node = SKEmitterNode(fileNamed: "Cloud.sks")!
    node.particlePositionRange.dx = UIScreen.main.bounds.width
    node.position = CGPoint(x: 0, y: self.size.height / 2)
    if weatherCondition == .partlyCloudy {
      configureParticleNode(node, birthRate: 0.1, lifetime: 5, speed: 3)
    } else if weatherCondition == .overcast {
      configureParticleNode(node, birthRate: 0.2, lifetime: 30, speed: 5)
    } else if weatherCondition == .cloudy {
      configureParticleNode(node, birthRate: 0.4, lifetime: 30, speed: 15)
    }
    addChild(node)
  }
  
  private func configureParticleNode(_ node: SKEmitterNode, birthRate: CGFloat, lifetime: CGFloat, speed: CGFloat) {
    node.particleBirthRate = birthRate
    node.particleLifetime = lifetime
    node.particleSpeed = speed
    node.particleScale = 0.01
  }
}
