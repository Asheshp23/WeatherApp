import SwiftUI
import CoreLocation
import MapKit

struct WeatherMapView: View {
  @Binding var cityName: String
  var temperature: String
  var userLocation: CLLocationCoordinate2D
  
  var body: some View {
    Map() {
      Annotation(cityName, coordinate: userLocation) {
        ZStack {
          RoundedRectangle(cornerRadius: 5)
            .fill(Color.teal.opacity(0.7))
          Text(temperature)
            .bold()
            .padding(12.0)
            .foregroundStyle(.white)
        }
      }
    }
    .mapStyle(.hybrid(elevation: .realistic))
    .mapControls {
      MapUserLocationButton()
      MapCompass()
      MapScaleView()
    }
    .navigationTitle("Weather map view")
  }
}
