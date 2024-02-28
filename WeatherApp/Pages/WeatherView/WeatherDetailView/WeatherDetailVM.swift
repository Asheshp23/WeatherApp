import Foundation
import CoreLocation

class WeatherDetailVM: ObservableObject {
    private let weatherService: WeatherDataServiceProtocol
    
    @Published var weather: WeatherModel?
    @Published var isLoading = false
    @Published var selectedCity = ""
    @Published var showCityList = false
    @Published var showSettings = false
    @Published var tempUnit : TemperatureUnit = .celcius
    @Published var isLocationButtonTapped = false
    @Published var cityName: String = ""
    @Published var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(20.0, -30.0)
    
    var temperature: String {
        if let weather = weather {
            return Helper.formatTemperature(tempUnit == .celcius ? weather.current.tempC : weather.current.tempF, unit: tempUnit)
        }
        return "not available"
    }
    
    var feelslike: String {
        if let weather = weather {
            return Helper.formatTemperature(tempUnit == .celcius ? weather.current.feelslikeC : weather.current.feelslikeF, unit: tempUnit)
        }
        return "not available"
    }
    
    var lastUpdatedAt: String {
        if let weather = weather {
            return Helper.timeAgoSince(Date(timeIntervalSince1970: TimeInterval(weather.current.lastUpdatedEpoch)))
        }
        return "not available"
    }
    
    init(weatherService: WeatherDataServiceProtocol) {
        self.weatherService = weatherService
    }
    
    // fetch weather data
    @MainActor
    func fetchWeather() async {
        do {
            self.weather = try await self.weatherService.fetchData(city: self.selectedCity)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func reverseGeocodeLocationAsync(_ location: CLLocation) async throws -> String {
        do {
            let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
            
            guard let city = placemarks.first?.locality else {
                throw LocationError.noCityFound
            }
            
            return city
        } catch {
            throw error
        }
    }
    
    @MainActor
    func handleLocationUpdate(newValue: CLLocation) async {
        do {
            let city = try await reverseGeocodeLocationAsync(newValue)
            self.selectedCity = city
            await fetchWeather()
        } catch {
            if let locationError = error as? LocationError {
                switch locationError {
                case .noCityFound:
                    // Handle the case when no city is found
                    print("No city found")
                }
            } else {
                // Handle other errors
                print("Error: \(error)")
            }
        }
    }
}
