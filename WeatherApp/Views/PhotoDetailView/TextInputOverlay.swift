import SwiftUI

struct TextInputOverlay: View {
    @ObservedObject var viewModel: PhotoDetailVM

    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()
            
            TextField("Type here", text: $viewModel.textBoxes[viewModel.currentIndex].text)
                .font(.system(size: 35.0))
                .italic(viewModel.textBoxes[viewModel.currentIndex].isItalic)
                .underline(viewModel.textBoxes[viewModel.currentIndex].isUnderlined)
                .colorScheme(.dark)
                .padding()
                .foregroundColor(viewModel.textBoxes[viewModel.currentIndex].textColor)
            
            HStack {
                Button(action: viewModel.handleAddButtonTap) {
                    Text("Add")
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()
                
                Button(action: viewModel.handleCancelButtonTap) {
                    Text("Cancel")
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .padding()
                }
            }
            .overlay(TextStylingBarView(viewModel: viewModel))
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}
