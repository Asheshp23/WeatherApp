import SwiftUI

struct PhotoGalleryView: View {
  var images : [String] = ["IMG1","IMG2","IMG3","IMG4","IMG5","IMG6","IMG7","IMG8","IMG9","IMG10"]
  @State var imageName = ""
  @State var goToDetailView = false
  var columnGrid : [GridItem] = [GridItem(.flexible(), spacing: 1),GridItem(.flexible(), spacing: 1),GridItem(.flexible(), spacing: 1)]

  var body: some View {
    ScrollView{
      LazyVGrid(columns: columnGrid ,spacing: 1) {
        ForEach((0..<images.count),id: \.self){ i in
          NavigationLink(destination: PhotoDetailView(imageName: $imageName)){
            Image(images[i])
              .resizable()
              .frame(width: (UIScreen.main.bounds.width / 3 ) - 1, height: (UIScreen.main.bounds.width / 3 ) - 1)
              .scaledToFit()
              .clipped()
              .accessibilityIdentifier(images[i])
          }
          .simultaneousGesture(
            TapGesture().onEnded({ _ in
            self.imageName = images[i]
          }))
        }
      }
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
