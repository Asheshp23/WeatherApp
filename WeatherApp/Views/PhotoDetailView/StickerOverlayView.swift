import SwiftUI

struct StickerOverlayView: View {
  @Bindable var viewModel: PhotoDetailVM

  var body: some View {
    ForEach(viewModel.stickers) { sticker in
      Text(sticker.emoji)
        .font(.system(size: 60))
        .scaleEffect(sticker.scale)
        .rotationEffect(sticker.rotation)
        .offset(sticker.offset)
        .gesture(
          DragGesture()
            .onChanged { value in viewModel.handleStickerDrag(value: value, sticker: sticker) }
            .onEnded { _ in viewModel.handleStickerDragEnd(sticker: sticker) }
            .simultaneously(with:
              MagnificationGesture()
                .onChanged { value in viewModel.handleStickerMagnification(value: value, sticker: sticker) }
                .onEnded { _ in viewModel.handleStickerMagnificationEnd(sticker: sticker) }
            )
            .simultaneously(with:
              RotationGesture()
                .onChanged { value in viewModel.handleStickerRotation(value: value, sticker: sticker) }
                .onEnded { _ in viewModel.handleStickerRotationEnd(sticker: sticker) }
            )
        )
        .onLongPressGesture {
          viewModel.deleteSticker(sticker)
        }
    }
  }
}
