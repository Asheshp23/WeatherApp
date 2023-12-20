import Foundation

protocol WeatherDataServiceProtocol {
  func getWeather(city: String) async -> Result<WeatherModel?, Error>
}

class WeatherDataService: WeatherDataServiceProtocol {
  func getWeather(city: String) async -> Result<WeatherModel?, Error> {
    let aqi = "no"
    let key = Helper.getApiKey()
    let cityName = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let endpoint = "http://api.weatherapi.com/v1/current.json?key=\(key)&q=\(cityName)&aqi=\(aqi)"
    guard let url = URL(string: endpoint) else {
      return .failure(NetworkError.invalidURL)
    }
    
    do {
      let (data, response) = try await URLSession.shared.data(from: url)
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        return .failure(NetworkError.invalidResponse)
      }
      let decoder = JSONDecoder()
      let result = try decoder.decode(WeatherModel.self, from: data)
      return .success(result)
    } catch {
      print(error)
      return .failure(error)
    }
  }
}
