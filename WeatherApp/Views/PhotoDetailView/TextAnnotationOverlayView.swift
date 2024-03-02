import SwiftUI

struct TextAnnotationOverlayView: View {
    @ObservedObject var viewModel: PhotoDetailVM
    
    var body: some View {
        ForEach(viewModel.textBoxes) { textBox in
            Text(viewModel.textBoxes[viewModel.currentIndex].id == textBox.id && viewModel.addNewBox ? "" : textBox.text)
                .font(.system(size: 30, weight: viewModel.textBoxes[viewModel.currentIndex].isBold ? .bold : .regular))
                .foregroundColor(textBox.textColor)
                .italic(viewModel.textBoxes[viewModel.currentIndex].isItalic)
                .underline(viewModel.textBoxes[viewModel.currentIndex].isUnderlined)
                .offset(textBox.offset)
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            viewModel.handleDragGesture(value: value, tb: textBox)
                        })
                        .onEnded({ value in
                            viewModel.handleDragGestureEnd(value: value, tb: textBox)
                        }))
                .onLongPressGesture { viewModel.handleLongPress(tb: textBox) }
        }
    }
}

