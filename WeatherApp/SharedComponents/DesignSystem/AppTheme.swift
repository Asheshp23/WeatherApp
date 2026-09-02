import SwiftUI

enum Radius {
  static let card: CGFloat = 12
  static let control: CGFloat = 20
  static let sheet: CGFloat = 28
}

enum Motion {
  static var snappy: Animation { .spring(response: 0.38, dampingFraction: 0.78) }
  static var gentle: Animation { .spring(response: 0.55, dampingFraction: 0.85) }
  static var reduced: Animation { .linear(duration: 0.12) }

  static func resolve(_ animation: Animation, reduceMotion: Bool) -> Animation {
    reduceMotion ? reduced : animation
  }
}
