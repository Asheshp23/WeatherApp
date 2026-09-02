import SwiftUI

// A single toggling button rather than two segment buttons — this keeps
// app.buttons["temperatureUnit"] a deterministic tap target and gives
// VoiceOver one element with a proper label/value instead of two.
struct TemperatureUnitToggle: View {
  @Binding var selection: TemperatureUnit
  var onToggle: () -> Void = {}

  @Namespace private var namespace
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  private static let sliderID = "temperatureUnitSlider"

  var body: some View {
    Button(action: toggle) {
      HStack(spacing: 0) {
        segment(for: .celcius)
        segment(for: .fahrenheit)
      }
      .padding(4)
      .background(Capsule(style: .continuous).fill(.thinMaterial))
      .overlay(Capsule(style: .continuous).strokeBorder(.white.opacity(0.22), lineWidth: 1))
    }
    .buttonStyle(PressableButtonStyle(scales: false))
    .accessibilityIdentifier("temperatureUnit")
    .accessibilityLabel("Temperature unit")
    .accessibilityValue(selection == .celcius ? "Celsius" : "Fahrenheit")
    .accessibilityHint("Double tap to switch between Celsius and Fahrenheit")
    .sensoryFeedback(.selection, trigger: selection)
  }

  private func toggle() {
    let next: TemperatureUnit = (selection == .celcius) ? .fahrenheit : .celcius
    withAnimation(Motion.resolve(Motion.snappy, reduceMotion: reduceMotion)) {
      selection = next
    }
    onToggle()
  }

  @ViewBuilder
  private func segment(for unit: TemperatureUnit) -> some View {
    let isSelected = (unit == selection)
    HStack(spacing: 6) {
      if isSelected {
        Image(systemName: "checkmark")
          .font(.footnote.weight(.bold))
          .transition(.scale(scale: 0.4).combined(with: .opacity))
      }
      Text("°\(unit.rawValue.uppercased())")
        .font(.title3.weight(.semibold))
    }
    .foregroundStyle(isSelected ? Color("BrandNavy") : Color.primary.opacity(0.7))
    .frame(maxWidth: .infinity)
    .padding(.vertical, 12)
    .background {
      if isSelected {
        Capsule(style: .continuous)
          .fill(Color("BrandSun"))
          .matchedGeometryEffect(id: Self.sliderID, in: namespace)
      }
    }
  }
}

#Preview {
  @Previewable @State var unit: TemperatureUnit = .celcius
  TemperatureUnitToggle(selection: $unit)
    .padding(32)
}
