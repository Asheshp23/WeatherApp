import SwiftUI

struct PhotoContentView: View {
  @Bindable var viewModel: PhotoDetailVM
  let size: CGSize

  var body: some View {
    ZStack {
      if viewModel.startEditing {
        switch viewModel.activeTool {
        case .annotate:
          CanvasView(canvas: $viewModel.canvas,
                     toolPicker: $viewModel.toolPicker,
                     image: try? viewModel.applyFilter(to: viewModel.editedPhoto ?? viewModel.photo) ?? viewModel.photo,
                     rect: size)
        case .crop:
          CropRotateView(viewModel: viewModel)
        case .adjust, .filters, .stickers:
          editingCanvas
        }
      } else {
        Image(uiImage: viewModel.editedPhoto ?? viewModel.photo)
          .resizable()
          .aspectRatio(contentMode: .fit)
      }

      TextAnnotationOverlayView(viewModel: viewModel)
      StickerOverlayView(viewModel: viewModel)

      if viewModel.addNewBox {
        TextInputOverlay(viewModel: viewModel)
      }
    }
  }

  private var editingCanvas: some View {
    ZStack {
      Image(uiImage: viewModel.editedPhoto ?? viewModel.photo)
        .resizable()
        .scaledToFit()
        .brightness(viewModel.brightness)
        .saturation(viewModel.saturation)
        .contrast(viewModel.contrast)

      VStack {
        Spacer()
        switch viewModel.activeTool {
        case .filters:
          FilterPresetsView(viewModel: viewModel)
        case .stickers:
          StickersPanel(viewModel: viewModel)
        default:
          AdjustmentPanel(viewModel: viewModel)
        }
        ToolSwitcherBar(viewModel: viewModel)
      }
    }
  }
}
