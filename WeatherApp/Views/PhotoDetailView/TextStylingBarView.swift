import SwiftUI

struct TextStylingBarView: View {
    @ObservedObject var viewModel: PhotoDetailVM

    var textStylingBarView: some View {
        VStack {
            HStack {
                ColorPicker("", selection: $viewModel.textBoxes[viewModel.currentIndex].textColor)
                    .labelsHidden()
                Text("B")
                    .bold()
                    .padding()
                    .onTapGesture {
                        viewModel.textBoxes[viewModel.currentIndex].isBold.toggle()
                    }
                    .foregroundColor(.white)
                Divider()
                Text("I")
                    .italic()
                    .padding()
                    .onTapGesture {
                        viewModel.textBoxes[viewModel.currentIndex].isItalic.toggle()
                    }
                    .foregroundColor(.white)
                Divider()
                Text("U")
                    .underline()
                    .padding()
                    .onTapGesture {
                        viewModel.textBoxes[viewModel.currentIndex].isUnderlined.toggle()
                    }
                    .foregroundColor(.white)
            }
        }
    }
    
    var body: some View {
        textStylingBarView
    }
}
