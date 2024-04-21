import SwiftUI

struct TextAnnotationOverlayView: View {
  @Bindable var viewModel: PhotoDetailVM
  
  var body: some View {
    ForEach(viewModel.textBoxes) { textBox in
      Text(viewModel.textBoxes[viewModel.currentIndex].id == textBox.id && viewModel.addNewBox ? "" : textBox.text)
        .font(.system(size: 30, weight: textBox.isBold ? .bold : .regular))
        .foregroundColor(textBox.textColor)
        .italic(textBox.isItalic)
        .underline(textBox.isUnderlined)
        .offset(textBox.offset)
        .gesture(
          DragGesture()
            .onChanged({ value in
              viewModel.handleDragGesture(value: value, textBox: textBox)
            })
            .onEnded({ value in
              viewModel.handleDragGestureEnd(value: value, tb: textBox)
            }))
        .onLongPressGesture { viewModel.handleLongPress(textBox: textBox) }
    }
  }
}

