import SwiftUI
import SpriteKit

struct SkyImageView: View {
  var weatherCondition: String = ""
  var body: some View {
    GeometryReader{
      proxy in
      Image("SKY")
        SpriteView(scene: SnowFall(), options: [.allowsTransparency])
          .ignoresSafeArea()
    }
    .ignoresSafeArea()
  }
}

struct SkyImageView_Previews: PreviewProvider {
  static var previews: some View {
    SkyImageView()
  }
}

class RainFall: SKScene {
  override func sceneDidLoad() {
    size = UIScreen.main.bounds.size
    scaleMode = .resizeFill
    anchorPoint = CGPoint(x: 0.5, y: 1)
    backgroundColor = .clear
    zPosition = 1

    let node = SKEmitterNode(fileNamed: "RainFall.sks")!
    addChild(node)
    node.particlePositionRange.dx = UIScreen.main.bounds.width

  }
}

class SnowFall: SKScene {
  override func sceneDidLoad() {
    size = UIScreen.main.bounds.size
    scaleMode = .resizeFill
    anchorPoint = CGPoint(x: 0.5, y: 1)
    backgroundColor = .clear

    let node = SKEmitterNode(fileNamed: "SnowFall.sks")!
    addChild(node)
    node.particlePositionRange.dx = UIScreen.main.bounds.width

  }
}
