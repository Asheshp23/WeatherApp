import SwiftUI

struct AdjustablePhotoView: View {
  @Bindable var viewModel: PhotoDetailVM
  
  var body: some View {
    ZStack {
      Image(uiImage: viewModel.editedPhoto ?? viewModel.photo)
        .resizable()
        .scaledToFit()
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
