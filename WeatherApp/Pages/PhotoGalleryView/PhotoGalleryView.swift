import SwiftUI

struct PhotoGalleryView: View {
    var images: [String] = ["IMG1", "IMG2", "IMG3", "IMG4", "IMG5", "IMG6", "IMG7", "IMG8", "IMG9", "IMG10"]
    @State private var selectedImageName: String?
    var columnGrid: [GridItem] = Array(repeating: .init(.flexible(), spacing: 1), count: 3)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columnGrid, spacing: 1) {
                ForEach(images, id: \.self) { imageName in
                    AsyncImageView(imageName: imageName) { image in
                        NavigationLink(destination: PhotoDetailView(imageName: imageName)) {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: (UIScreen.main.bounds.width / 3) - 1, height: (UIScreen.main.bounds.width / 3) - 1)
                                .clipped()
                                .accessibilityIdentifier(imageName)
                        }
                    }
                    .simultaneousGesture(
                        TapGesture()
                          .onEnded { _ in
                            selectedImageName = imageName
                        }
                    )
                }
            }
        }
        .navigationTitle("Photos")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AsyncImageView<Content: View>: View {
    let imageName: String
    let content: (Image) -> Content

    var body: some View {
        content(loadImage())
    }

    private func loadImage() -> Image {
        if let uiImage = UIImage(named: imageName) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "photo")
        }
    }
}

struct PhotoGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoGalleryView()
    }
}
