import SwiftUI

struct FilteredImageView: View {
  @Bindable var viewModel: PhotoDetailVM
  
  var body: some View {
    ZStack {
      InitialImageView(image: viewModel.editedPhoto ?? viewModel.photo)
        .brightness(viewModel.brightness)
        .saturation(viewModel.saturation)
        .contrast(viewModel.contrast)
        .background(.clear)
      VStack {
        Spacer()
        SliderRow(text: "Brightness", value: $viewModel.brightness, inRange: -1...1)
        SliderRow(text: "Contrast", value: $viewModel.contrast, inRange: 0...2)
        SliderRow(text: "Saturation", value: $viewModel.saturation, inRange: 0...2)
      }
    }
  }
}
