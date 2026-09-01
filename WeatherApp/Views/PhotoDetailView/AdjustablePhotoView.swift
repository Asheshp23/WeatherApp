import SwiftUI

struct AdjustmentPanel: View {
  @Bindable var viewModel: PhotoDetailVM

  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Text("Adjust")
          .font(.headline)
        Spacer()
        Button {
          viewModel.brightness = 0
          viewModel.contrast = 1
          viewModel.saturation = 1
        } label: {
          Label("Reset", systemImage: "arrow.counterclockwise")
            .font(.subheadline)
        }
      }
      SliderRow(text: "Brightness", systemImage: "sun.max", value: $viewModel.brightness, inRange: -1...1)
      SliderRow(text: "Contrast", systemImage: "circle.lefthalf.filled", value: $viewModel.contrast, inRange: 0...2)
      SliderRow(text: "Saturation", systemImage: "drop.fill", value: $viewModel.saturation, inRange: 0...2)
    }
    .padding(16)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    .padding(.horizontal)
    .padding(.bottom, 12)
  }
}

struct StickersPanel: View {
  @Bindable var viewModel: PhotoDetailVM

  var body: some View {
    HStack {
      Text("Tap + to add a sticker. Drag to move, pinch to resize, long-press to delete.")
        .font(.caption)
        .foregroundStyle(.secondary)
      Spacer()
      Button {
        viewModel.showStickerPicker = true
      } label: {
        Image(systemName: "plus.circle.fill")
          .font(.title2)
      }
    }
    .padding(16)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    .padding(.horizontal)
    .padding(.bottom, 12)
  }
}
