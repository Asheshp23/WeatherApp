import SwiftUI

/// Photos tab. A tight, edge-to-edge grid like the Photos app: the images are the content,
/// so no rounded tiles, borders or shadows compete with them.
struct PhotoGalleryView: View {
  @State private var vm = PhotoGalleryViewModel()
  @State private var task: Task<Void, Never>?

  @ScaledMetric(relativeTo: .body) private var minimumTileSize: CGFloat = 110

  var body: some View {
    Group {
      if let images = vm.images {
        ScrollView {
          LazyVGrid(columns: [GridItem(.adaptive(minimum: minimumTileSize), spacing: 2)], spacing: 2) {
            ForEach(Array(images.enumerated()), id: \.offset) { index, image in
              NavigationLink(destination: PhotoDetailView(viewModel: PhotoDetailVM(photo: image))) {
                Color.clear
                  .aspectRatio(1, contentMode: .fit)
                  .overlay {
                    Image(uiImage: image)
                      .resizable()
                      .scaledToFill()
                  }
                  .clipped()
                  .contentShape(Rectangle())
              }
              .buttonStyle(.plain)
              .accessibilityLabel("Photo \(index + 1) of \(images.count)")
            }
          }
        }
      } else if vm.loadFailed {
        ContentUnavailableView {
          Label("Couldn't load photos", systemImage: "photo.on.rectangle.angled")
        } description: {
          Text("Check your connection and try again.")
        } actions: {
          Button("Try Again") { reload() }
        }
      } else {
        VStack(spacing: DS.Space.m) {
          SwiftUI.ProgressView()
          Text("Loading photos…")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
    .navigationTitle("Photos")
    .onAppear { if vm.images == nil { reload() } }
    .onDisappear { task?.cancel() }
  }

  private func reload() {
    task?.cancel()
    task = Task { await vm.loadImages() }
  }
}

#Preview {
  NavigationStack { PhotoGalleryView() }
}
