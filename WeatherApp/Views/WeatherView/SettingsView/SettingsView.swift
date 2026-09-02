import SwiftUI

struct SettingsView: View {
  @Binding var tempUnit: TemperatureUnit

  @Environment(\.dismiss) private var dismiss
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var dismissTick = 0

  var body: some View {
    VStack(spacing: 20) {
      SheetGrabber()
      VStack(spacing: 6) {
        Text("Temperature Unit")
          .font(.title2.bold())
        Text("Also switches wind, visibility and pressure units.")
          .font(.footnote)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }
      TemperatureUnitToggle(selection: $tempUnit) { dismissTick += 1 }
        .padding(.horizontal, 32)
      Spacer(minLength: 0)
    }
    .padding(.horizontal, 16)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .presentationDetents([.height(300)])
    .presentationBackground(.ultraThinMaterial)
    .presentationDragIndicator(.hidden)
    .presentationCornerRadius(Radius.sheet)
    .task(id: dismissTick) {
      guard dismissTick > 0 else { return }
      let delay: Duration = reduceMotion ? .milliseconds(200) : .milliseconds(600)
      guard (try? await Task.sleep(for: delay)) != nil else { return }
      dismiss()
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    let unit : TemperatureUnit = .celcius
    SettingsView(tempUnit: .constant(unit))
  }
}
