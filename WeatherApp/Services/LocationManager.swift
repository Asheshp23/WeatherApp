import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()
    }
    
    deinit {
        manager.stopUpdatingLocation()
    }
    
    func requestLocation() {
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            if location == nil || lastLocation.distance(from: location!) > 5 { // Update if new location is significantly different
                self.location = lastLocation
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied, .restricted:
            // Handle denied/restricted authorization status
            print("Location access denied or restricted.")
        default:
            break
        }
    }
}
