import Foundation

enum TemperatureUnit  : String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case celcius = "c"
    case fahrenheit = "f"
}

struct WeatherModel: Codable {
    let location: LocationModel
    let current: CurrentWeatherModel
    let forecast: ForecastContainer?
    let alerts: AlertsContainer?

    init(location: LocationModel, current: CurrentWeatherModel, forecast: ForecastContainer? = nil, alerts: AlertsContainer? = nil) {
        self.location = location
        self.current = current
        self.forecast = forecast
        self.alerts = alerts
    }
}
