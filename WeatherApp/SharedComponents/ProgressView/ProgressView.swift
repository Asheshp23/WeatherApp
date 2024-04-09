import SwiftUI

struct ProgressView: View {
    var tintColor: Color = .white
    var body: some View {
        ProgressView()
          .tint(tintColor)
          .accessibilityIdentifier("loadingView")
    }
}

#Preview {
    ProgressView()
}
