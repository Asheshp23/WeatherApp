import SwiftUI

struct PhotoGalleryView: View {
  @StateObject private var vm = PhotoGalleryViewModel(dataManager: PhotoGalleryDataManager())
  var columnGrid: [GridItem] = Array(repeating: .init(.flexible(), spacing: 1), count: 3)
  @State private var task: Task<Void, Never>?
  
  var body: some View {
    VStack {
      if vm.images.isEmpty {
        ProgressView()
      } else {
        ScrollView {
          LazyVGrid(columns: columnGrid, spacing: 1) {
            ForEach(vm.images, id: \.self) { image in
              NavigationLink(destination: PhotoDetailView(imageName: image)) {
                Image(uiImage: image)
                  .resizable()
                  .scaledToFit()
                  .frame(height: 150)
              }
            }
          }
        }
      }
    }
    .onAppear {
      task = Task { await vm.loadImages() }
    }
    .onDisappear {
      task?.cancel()
    }
    .navigationTitle("Photos")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct PhotoGalleryView_Previews: PreviewProvider {
  static var previews: some View {
    PhotoGalleryView()
  }
}
