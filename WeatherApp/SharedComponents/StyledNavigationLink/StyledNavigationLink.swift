import SwiftUI

struct StyledNavigationLink<Destination: View>: View {
  let destination: Destination
  let label: String
  let imageName: String
  let accessibilityIdentifier: String
  
  var body: some View {
    NavigationLink(destination: destination) {
      VStack(alignment: .leading) {
        HStack {
          Image(systemName: imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .padding(.leading, 8.0)
          Text(label)
            .font(.headline)
            .padding()
            .accessibilityIdentifier(accessibilityIdentifier)
            .padding(.trailing, 8.0)
          Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(
          RoundedRectangle(cornerRadius: 8.0)
            .fill(Color.white.opacity(0.3))
        )
        .padding(.horizontal)
      }
    }
  }
}
