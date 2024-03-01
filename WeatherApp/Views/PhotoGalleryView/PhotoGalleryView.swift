import SwiftUI

struct PhotoGalleryView: View {
    @StateObject private var vm = PhotoGalleryViewModel()
    var columnGrid: [GridItem] = Array(repeating: .init(.flexible(), spacing: 1), count: 3)
    @State private var task: Task<Void, Never>?
    
    var body: some View {
        VStack {
            if let images = vm.images {
                ScrollView {
                    LazyVGrid(columns: columnGrid, spacing: 1) {
                        ForEach(images, id: \.self) { image in
                            NavigationLink(destination: PhotoDetailView(photo: image)) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                            }
                        }
                    }
                }
            } else {
               Text("Loading...")
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
