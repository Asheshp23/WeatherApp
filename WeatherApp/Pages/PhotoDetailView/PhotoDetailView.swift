import SwiftUI

struct PhotoDetailView: View {
  @Binding var image : String
  var body: some View {
    VStack{
      HStack(alignment: .center){
        Image(image)
          .resizable()
          .scaledToFit()
      }
    }.navigationTitle(image)
  }
}

struct PhotoDetailView_Previews: PreviewProvider {
  static var previews: some View {
    PhotoDetailView(image: .constant("IMG1"))
  }
}
