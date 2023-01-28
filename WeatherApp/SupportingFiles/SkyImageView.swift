import SwiftUI

struct SkyImageView: View {
  var weatherCondition: String = ""
  var body: some View {
    GeometryReader{
      proxy in
      if weatherCondition == "Overcast" {
        Image("IMG1")
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: proxy.size.width, height: proxy.size.height)
      }
      else {
        Image("SKY")
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: proxy.size.width, height: proxy.size.height)
      }

    }
    .ignoresSafeArea()
  }
}

struct SkyImageView_Previews: PreviewProvider {
  static var previews: some View {
    SkyImageView()
  }
}
