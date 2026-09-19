import SwiftUI

struct SliderRow: View {
  let text: LocalizedStringKey
  let systemImage: String
  @Binding var value: Double
  let inRange: ClosedRange<Double>

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: systemImage)
        .foregroundStyle(.secondary)
        .frame(width: 20)
      Text(text)
        .font(.subheadline)
        .frame(width: 78, alignment: .leading)
      Slider(value: $value, in: inRange, step: 0.1)
      Text(Helper.localizedNumber(value, fractionDigits: 1))
        .font(.caption)
        .foregroundStyle(.secondary)
        .monospacedDigit()
        .frame(width: 30, alignment: .trailing)
    }
  }
}
