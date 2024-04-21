import SwiftUI

struct PhotoContentView: View {
  @Bindable var viewModel: PhotoDetailVM
  let size: CGSize
  
  var body: some View {
    ZStack {
      if viewModel.startEditing {
        if viewModel.startAnnotating {
          CanvasView(canvas: $viewModel.canvas,
                     toolPicker: $viewModel.toolPicker,
                     image: viewModel.applyFilter(to: viewModel.editedPhoto ?? viewModel.photo) ?? viewModel.photo,
                     rect: size)
        } else {
          AdjustablePhotoView(viewModel: viewModel)
        }
      } else {
        Image(uiImage: viewModel.editedPhoto ?? viewModel.photo)
          .resizable()
          .aspectRatio(contentMode: .fit)
      }
      TextAnnotationOverlayView(viewModel: viewModel)
      if viewModel.addNewBox {
        TextInputOverlay(viewModel: viewModel)
      }
    }
  }
}
