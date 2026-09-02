import SwiftUI

struct GlassSurface: ViewModifier {
  var cornerRadius: CGFloat = Radius.card
  var material: Material = .ultraThinMaterial
  var strokeOpacity: Double = 0.22

  private var shape: RoundedRectangle {
    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
  }

  func body(content: Content) -> some View {
    content
      .background(shape.fill(material))
      .overlay(shape.strokeBorder(.white.opacity(strokeOpacity), lineWidth: 1))
      .clipShape(shape)
  }
}

extension View {
  func glassSurface(cornerRadius: CGFloat = Radius.card, material: Material = .ultraThinMaterial) -> some View {
    modifier(GlassSurface(cornerRadius: cornerRadius, material: material))
  }
}

/// Visual press feedback. Set `scales: false` when the label hosts a
/// `matchedGeometryEffect` source — scaling the label would distort the match mid-spring.
struct PressableButtonStyle: ButtonStyle {
  var scales: Bool = true

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(scales && configuration.isPressed ? 0.97 : 1)
      .opacity(configuration.isPressed ? 0.85 : 1)
      .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
  }
}

struct SheetGrabber: View {
  var body: some View {
    Capsule(style: .continuous)
      .fill(.secondary.opacity(0.5))
      .frame(width: 36, height: 5)
      .padding(.top, 8)
      .accessibilityHidden(true)
  }
}
