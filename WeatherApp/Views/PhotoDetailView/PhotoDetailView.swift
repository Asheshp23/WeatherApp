import SwiftUI

struct PhotoDetailView: View {
    @StateObject var viewModel: PhotoDetailVM
    
    var body: some View {
        ZStack {
            GeometryReader {  proxy -> AnyView in
                let size = proxy.frame(in: .global).size
                Task { @MainActor in
                    if viewModel.rect == .zero {
                        viewModel.rect = proxy.frame(in: .global)
                    }
                }
                return AnyView(PhotoContentView(viewModel: viewModel, size: size))
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(viewModel.message), dismissButton: .destructive(Text("OK")))
        }
        .navigationBarBackButtonHidden(viewModel.startEditing)
        .toolbar { ToolBarContentView(viewModel: viewModel) }
    }
}

struct PhotoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoDetailView(viewModel: PhotoDetailVM(photo: UIImage(imageLiteralResourceName: "IMG1")))
    }
}
