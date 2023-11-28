import Foundation
import WeatherKit
import CoreLocation
import os

struct WeatherData {
  public static let shared = WeatherData()
  //api call
  func getWeather(city: String) async -> WeatherModel? {
    let aqi = "no"
    let key = Helper.getApiKey()
    let cityName = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let endpoint = "http://api.weatherapi.com/v1/current.json?key=\(key)&q=\(cityName)&aqi=\(aqi)"
    guard let url = URL(string: endpoint) else { return nil }
    let urlRequest = URLRequest(url: url)
    do {
      let (data, response) = try await URLSession.shared.data(for: urlRequest)
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        return nil
      }
      let decoder = JSONDecoder()
      let result = try decoder.decode(WeatherModel.self, from: data)
      return result
    } catch {
      print(error)
    }
    return nil
  }
}
