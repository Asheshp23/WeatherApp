import SwiftUI

struct LaunchAnimationView: View {
  @State private var logoVisible = false
  @State private var logoBreathing = false
  @State private var titleVisible = false
  @State private var subtitleVisible = false
  @State private var ambientPulse = false

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    ZStack {
      Color("BrandNavy")
        .ignoresSafeArea()

      ambientGlow

      VStack(spacing: 16) {
        Spacer()
        logo
        titleStack
        Spacer()
        Spacer()
      }
    }
    .onAppear(perform: runEntranceSequence)
  }

  private var logo: some View {
    Image(systemName: "cloud.sun.fill")
      .resizable()
      .scaledToFit()
      .frame(width: 84, height: 84)
      .foregroundStyle(Color("BrandSun"))
      .opacity(logoVisible ? 1 : 0)
      .scaleEffect(logoVisible ? (logoBreathing ? 1.06 : 1) : 0.6)
  }

  private var titleStack: some View {
    VStack(spacing: 4) {
      Text("Weatherly Studio")
        .font(.system(size: 28, weight: .bold, design: .rounded))
        .foregroundStyle(Color("BrandSun"))
        .opacity(titleVisible ? 1 : 0)
        .offset(y: titleVisible ? 0 : 10)

      Text("Your sky, beautifully forecast")
        .font(.subheadline)
        .foregroundStyle(Color("BrandSun").opacity(0.8))
        .opacity(subtitleVisible ? 1 : 0)
        .offset(y: subtitleVisible ? 0 : 8)
    }
  }

  private var ambientGlow: some View {
    Circle()
      .fill(
        RadialGradient(
          colors: [Color("BrandSun").opacity(ambientPulse ? 0.22 : 0.1), .clear],
          center: .center,
          startRadius: 10,
          endRadius: 220
        )
      )
      .frame(width: 440, height: 440)
      .allowsHitTesting(false)
  }

  private func runEntranceSequence() {
    guard !reduceMotion else {
      logoVisible = true
      titleVisible = true
      subtitleVisible = true
      return
    }

    withAnimation(.spring(response: 0.55, dampingFraction: 0.62)) {
      logoVisible = true
    }
    withAnimation(.easeInOut(duration: 0.4).delay(0.45)) {
      titleVisible = true
    }
    withAnimation(.easeInOut(duration: 0.4).delay(0.65)) {
      subtitleVisible = true
    }
    withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true).delay(0.9)) {
      ambientPulse = true
    }
    withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true).delay(1.1)) {
      logoBreathing = true
    }
  }
}

#Preview {
  LaunchAnimationView()
}
