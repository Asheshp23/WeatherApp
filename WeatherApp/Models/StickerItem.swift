import SwiftUI

struct StickerItem: Identifiable {
  var id = UUID().uuidString
  var emoji: String
  var offset: CGSize = .zero
  var lastOffset: CGSize = .zero
  var scale: CGFloat = 1.0
  var lastScale: CGFloat = 1.0
  var rotation: Angle = .zero
  var lastRotation: Angle = .zero
}
