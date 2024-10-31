import SwiftUI

struct ContentView: View {
  
  var body: some View {
    NavigationStack {
      WeatherDetailView()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
