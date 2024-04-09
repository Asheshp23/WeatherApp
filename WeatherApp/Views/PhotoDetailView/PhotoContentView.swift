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
          FilteredImageView(viewModel: viewModel)
        }
      } else {
        InitialImageView(image: viewModel.editedPhoto ?? viewModel.photo)
      }
      TextAnnotationOverlayView(viewModel: viewModel)
      if viewModel.addNewBox {
        TextInputOverlay(viewModel: viewModel)
      }
    }
  }
}
