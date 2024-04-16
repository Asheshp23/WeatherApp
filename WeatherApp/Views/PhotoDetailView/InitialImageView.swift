import SwiftUI

struct InitialImageView: View {
  let image: UIImage
  
  var body: some View {
    Image(uiImage: image)
      .resizable()
      .scaledToFit()
  }
}
