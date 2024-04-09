import SwiftUI

@MainActor
struct TextStylingBarView: View {
  @Bindable var viewModel: PhotoDetailVM
  
  var textStylingBarView: some View {
    VStack {
      HStack {
        ColorPicker("", selection: $viewModel.textBoxes[viewModel.currentIndex].textColor)
          .labelsHidden()
        Text("B")
          .bold()
          .padding()
          .onTapGesture {
            viewModel.toggleBold()
          }
          .foregroundColor(.white)
        Divider()
        Text("I")
          .italic()
          .padding()
          .onTapGesture {
            viewModel.toggleItalic()
          }
          .foregroundColor(.white)
        Divider()
        Text("U")
          .underline()
          .padding()
          .onTapGesture {
            viewModel.toggleUnderline()
          }
          .foregroundColor(.white)
      }
    }
  }
  
  var body: some View {
    textStylingBarView
  }
}
