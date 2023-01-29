import Foundation
import SpriteKit

class SnowFallScene: SKScene {
  override func sceneDidLoad() {
    size = UIScreen.main.bounds.size
    scaleMode = .resizeFill
    anchorPoint = CGPoint(x: 0.5, y: 1)
    backgroundColor = .clear
    zPosition = 1
    let node = SKEmitterNode(fileNamed: "SnowFall.sks")!
    addChild(node)
    node.particlePositionRange.dx = UIScreen.main.bounds.width
  }
}
