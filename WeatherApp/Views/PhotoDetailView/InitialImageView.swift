import SwiftUI

struct InitialImageView: View {
    let image: UIImage

    var body: some View {
        HStack(alignment: .center) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        }
    }
}
