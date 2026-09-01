import SwiftUI

struct LaunchAnimationView: View {
  @State private var animate = false

  var body: some View {
    ZStack {
      Color("BrandNavy")
        .ignoresSafeArea()

      VStack {
        Spacer()
        Text("Weatherly Studio")
          .font(.system(size: 28, weight: .bold))
          .foregroundStyle(Color("BrandSun"))
          .opacity(animate ? 1 : 0)
          .scaleEffect(animate ? 1 : 0.8)
          .offset(y: animate ? 0 : 12)
        Spacer()
        Spacer()
      }
    }
    .onAppear {
      withAnimation(.easeOut(duration: 0.7)) {
        animate = true
      }
    }
  }
}

#Preview {
  LaunchAnimationView()
}
