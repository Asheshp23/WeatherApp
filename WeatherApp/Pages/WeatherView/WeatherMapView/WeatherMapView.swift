import SwiftUI
import MapKit
import CoreLocation

struct WeatherMapView: UIViewRepresentable {
  typealias UIViewType = MKMapView
  let weatherMapView = MKMapView()
  @Binding var cityName: String
  var temperature: String
  var userLocation: CLLocationCoordinate2D
  @State private var annotations: [MKPointAnnotation] = []


  func makeUIView(context: Context) -> MKMapView {
    weatherMapView.delegate = context.coordinator
    weatherMapView.showsScale = true
    weatherMapView.showsCompass = true
    weatherMapView.showsUserLocation = true
    weatherMapView.userTrackingMode = .followWithHeading
    weatherMapView.preferredConfiguration = MKHybridMapConfiguration(elevationStyle: .flat)
    let center = CLLocationCoordinate2D(latitude: userLocation.latitude,
                                        longitude: userLocation.longitude)
    let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    let region = MKCoordinateRegion(center: center, span: span)
    weatherMapView.setRegion(region, animated: true)

    let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.addAnnotation(_:)))
    weatherMapView.addGestureRecognizer(longPressGesture)



    return weatherMapView
  }

  func updateUIView(_ uiView: MKMapView, context: Context) {
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }

  class Coordinator: NSObject, MKMapViewDelegate {
    var parent: WeatherMapView

    init(_ parent: WeatherMapView) {
      self.parent = parent
      
    }

    @objc func addAnnotation(_ gestureRecognizer: UILongPressGestureRecognizer) {
      // Create a new annotation at the long press location and add it to the array of annotations
      let location = gestureRecognizer.location(in: gestureRecognizer.view)
      let coordinate = parent.weatherMapView.convert(location, toCoordinateFrom: parent.weatherMapView)
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      parent.weatherMapView.addAnnotation(annotation)

    }


    func getCityName(from coordinate: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
      let geocoder = CLGeocoder()
      let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

      geocoder.reverseGeocodeLocation(location) { placemarks, error in
        guard let placemark = placemarks?.first, error == nil else {
          completion(nil)
          return
        }

        let city = placemark.locality
        completion(city)
      }
    }


    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      if annotation is MKUserLocation {
        let identifier = "marker"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView?.glyphText = "\(parent.temperature)"
        annotationView?.canShowCallout = true
        annotationView?.markerTintColor = .white

        return annotationView
      } else if annotation is MKPointAnnotation {
        let identifier = "marker"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)

        annotationView?.markerTintColor = .white
        getCityName(from: annotation.coordinate) { cityName in
          if let cityName = cityName {
            annotationView?.glyphText = cityName
          }
        }
        annotationView?.isDraggable = true

        return annotationView
      }
      return nil
    }
  }
}

