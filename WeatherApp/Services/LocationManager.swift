import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  let manager = CLLocationManager()

  @Published var location: CLLocation = CLLocation(latitude: 0.0, longitude: 0.0)

  override init() {
    manager.allowsBackgroundLocationUpdates = true
    super.init()
    manager.delegate = self
    manager.requestAlwaysAuthorization()
  }

  func requestLocation() {
    manager.startUpdatingLocation()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let lastLocation = locations.last {
      self.location = lastLocation
      manager.stopUpdatingLocation()
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(String(describing: error))
    print(error.localizedDescription)
  }
}
