import Foundation
import SpriteKit

class CloudScene: SKScene {
  override func didMove(to view: SKView) {
    scaleMode = .resizeFill
    backgroundColor = .clear
    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    let node = SKEmitterNode(fileNamed: "Cloud.sks")!
    node.particlePositionRange.dx = UIScreen.main.bounds.width
    node.position = CGPoint(x: self.size.width / 2, y: self.size.height)
    node.particleBirthRate = 0.2
    node.particleLifetime = 20
    node.particleSpeed = 20
    addChild(node)
  }
}
