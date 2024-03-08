import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  private let manager = CLLocationManager()
  
  @Published var location: CLLocation?
  
  override init() {
    super.init()
    setupLocationManager()
  }
  
  deinit {
    manager.stopUpdatingLocation()
  }
  
  func requestLocation() {
    manager.startUpdatingLocation()
  }
  
  private func setupLocationManager() {
    manager.delegate = self
    manager.requestAlwaysAuthorization()
    manager.allowsBackgroundLocationUpdates = true
    manager.startUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let lastLocation = locations.last else { return }
    guard location == nil || lastLocation.distance(from: location!) > 5 else { return }
    
    self.location = lastLocation
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location update failed: \(error.localizedDescription)")
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .denied, .restricted:
      print("Location access denied or restricted.")
      // You may want to show an alert or handle this case accordingly
    default:
      break
    }
  }
}
