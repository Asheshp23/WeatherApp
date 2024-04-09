import SwiftUI

struct SettingsButtonView: View {
  @Binding var showSettings: Bool
  var body: some View {
    Button(action: {
      self.showSettings.toggle()
    }){
      Image(systemName: "gearshape")
    }
    .accessibilityIdentifier("showSettings")
    .foregroundStyle(
      .white.adaptedTextColor()
    )
  }
}

#Preview {
  SettingsButtonView(showSettings: .constant(false))
}
