import SwiftUI

struct TextInputOverlay: View {
  @Bindable var viewModel: PhotoDetailVM
  
  var body: some View {
    ZStack {
      Color.black.opacity(0.75)
        .ignoresSafeArea()
      
      if !viewModel.textBoxes.isEmpty {
        TextField("Type here", text: $viewModel.textBoxes[viewModel.currentIndex].text)
          .font((AppFont(rawValue: viewModel.textBoxes[viewModel.currentIndex].fontName) ?? .system)
            .font(size: viewModel.textBoxes[viewModel.currentIndex].fontSize))
          .fontWeight(viewModel.textBoxes[viewModel.currentIndex].isBold ? .bold : .regular)
          .italic(viewModel.textBoxes[viewModel.currentIndex].isItalic)
          .underline(viewModel.textBoxes[viewModel.currentIndex].isUnderlined)
          .colorScheme(.dark)
          .multilineTextAlignment(.center)
          .padding()
          .foregroundColor(viewModel.textBoxes[viewModel.currentIndex].textColor)
      }

      VStack {
        HStack {
          Button(action: { viewModel.handleCancelButtonTap() }) {
            Image(systemName: "xmark")
              .font(.headline)
              .foregroundColor(.white)
              .padding(10)
              .background(.white.opacity(0.15), in: Circle())
          }

          Spacer()

          Button(action: viewModel.duplicateCurrentTextBox) {
            Image(systemName: "square.on.square")
              .font(.headline)
              .foregroundColor(.white)
              .padding(10)
              .background(.white.opacity(0.15), in: Circle())
          }

          Button(action: viewModel.deleteCurrentTextBox) {
            Image(systemName: "trash")
              .font(.headline)
              .foregroundColor(.white)
              .padding(10)
              .background(.white.opacity(0.15), in: Circle())
          }

          Spacer()

          Button(action: viewModel.handleAddButtonTap) {
            Image(systemName: "checkmark")
              .font(.headline)
              .foregroundColor(.black)
              .padding(10)
              .background(.white, in: Circle())
          }
        }
        .padding()

        Spacer()

        TextStylingBarView(viewModel: viewModel)
          .padding(.bottom, 24)
      }
    }
  }
}
