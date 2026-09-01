import SwiftUI

struct TextAnnotationOverlayView: View {
  @Bindable var viewModel: PhotoDetailVM
  
  var body: some View {
    ForEach(viewModel.textBoxes) { textBox in
      Text(viewModel.textBoxes[viewModel.currentIndex].id == textBox.id && viewModel.addNewBox ? "" : textBox.text)
        .font((AppFont(rawValue: textBox.fontName) ?? .system).font(size: textBox.fontSize))
        .fontWeight(textBox.isBold ? .bold : .regular)
        .foregroundColor(textBox.textColor)
        .italic(textBox.isItalic)
        .underline(textBox.isUnderlined)
        .scaleEffect(textBox.scale)
        .rotationEffect(.degrees(textBox.rotation))
        .offset(textBox.offset)
        .gesture(
          DragGesture()
            .onChanged({ value in
              viewModel.handleDragGesture(value: value, textBox: textBox)
            })
            .onEnded({ value in
              viewModel.handleDragGestureEnd(value: value, tb: textBox)
            })
            .simultaneously(with:
              MagnificationGesture()
                .onChanged { value in viewModel.handleTextMagnification(value: value, textBox: textBox) }
                .onEnded { _ in viewModel.handleTextMagnificationEnd(textBox: textBox) }
            )
            .simultaneously(with:
              RotationGesture()
                .onChanged { value in viewModel.handleTextRotation(value: value, textBox: textBox) }
                .onEnded { _ in viewModel.handleTextRotationEnd(textBox: textBox) }
            )
        )
        .onLongPressGesture { viewModel.handleLongPress(textBox: textBox) }
    }
  }
}

