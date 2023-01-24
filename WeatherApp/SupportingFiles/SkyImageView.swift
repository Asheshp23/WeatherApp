import SwiftUI

struct SkyImageView: View {
  var body: some View {
    GeometryReader{
      proxy in
      Image("SKY")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: proxy.size.width, height: proxy.size.height)
    }
    .ignoresSafeArea()
  }
}

struct SkyImageView_Previews: PreviewProvider {
  static var previews: some View {
    SkyImageView()
  }
}
