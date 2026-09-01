import SwiftUI

struct PhotoGalleryView: View {
  @State private var vm = PhotoGalleryViewModel()
  var columnGrid: [GridItem] = Array(repeating: .init(.flexible(), spacing: 8), count: 3)
  @State private var task: Task<Void, Never>?

  var body: some View {
    Group {
      if let images = vm.images {
        ScrollView {
          LazyVGrid(columns: columnGrid, spacing: 8) {
            ForEach(Array(images.enumerated()), id: \.offset) { index, image in
              NavigationLink(destination: PhotoDetailView(viewModel: PhotoDetailVM(photo: image))) {
                GeometryReader { proxy in
                  Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.width)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .aspectRatio(1, contentMode: .fit)
              }
              .buttonStyle(GalleryThumbnailButtonStyle())
              .accessibilityLabel("Photo \(index + 1)")
            }
          }
          .padding(12)
        }
      } else if vm.loadFailed {
        emptyState
      } else {
        loadingState
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

  private var loadingState: some View {
    VStack(spacing: 12) {
      ProgressView()
      Text("Loading photos…")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var emptyState: some View {
    VStack(spacing: 16) {
      Image(systemName: "photo.on.rectangle.angled")
        .font(.system(size: 44))
        .foregroundStyle(.secondary)
      Text("Couldn't load photos")
        .font(.headline)
      Text("Check your connection and try again.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      Button {
        task = Task { await vm.loadImages() }
      } label: {
        Label("Retry", systemImage: "arrow.clockwise")
      }
      .buttonStyle(.borderedProminent)
      .padding(.top, 4)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
  }
}

private struct GalleryThumbnailButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.95 : 1)
      .opacity(configuration.isPressed ? 0.85 : 1)
      .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
  }
}

struct PhotoGalleryView_Previews: PreviewProvider {
  static var previews: some View {
    PhotoGalleryView()
  }
}
