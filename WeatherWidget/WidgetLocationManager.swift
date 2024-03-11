import CoreLocation
import WidgetKit

class WidgetLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  private let manager = CLLocationManager()
  
  var location: CLLocation?
  
  override init() {
    super.init()
    setupLocationManager()
  }
  
  deinit {
    manager.stopUpdatingLocation()
  }
  
  private func setupLocationManager() {
    manager.delegate = self
    manager.requestAlwaysAuthorization()
    manager.requestLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let lastLocation = locations.last else { return }
    guard location == nil || lastLocation.distance(from: location!) > 5 else { return }
    
    self.location = lastLocation
    WidgetCenter.shared.reloadAllTimelines()
    manager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location update failed: \(error.localizedDescription)")
    print(String(describing: error))
    manager.requestWhenInUseAuthorization()
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
