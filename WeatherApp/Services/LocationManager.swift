import CoreLocation

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
  let manager = CLLocationManager()
  
  var location: CLLocation?
  
  override init() {
    super.init()
    manager.delegate = self
    manager.requestWhenInUseAuthorization()
    manager.allowsBackgroundLocationUpdates = true
  }
  
  deinit {
    manager.stopUpdatingLocation()
  }
  
  func requestLocation() {
    manager.startUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let lastLocation = locations.last else { return }
    guard location == nil || lastLocation.distance(from: location!) > 5 else { return }
    
    self.location = lastLocation
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location update failed: \(error.localizedDescription)")
    print(String(describing: error))
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .denied, .restricted:
      print("Location access denied or restricted.")
      // You may want to show an alert or handle this case accordingly
    case .authorizedWhenInUse, .authorizedAlways:
      manager.startUpdatingLocation() // Start updating location once authorized
    case .notDetermined:
      print("Location authorization status not determined.")
    @unknown default:
      fatalError("Unhandled case when checking location authorization status.")
    }
  }
}
