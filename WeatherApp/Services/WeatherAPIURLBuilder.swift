import Foundation

protocol URLBuilderProtocol {
  func buildURL(for city: String) throws -> URL
}

struct WeatherAPIURLBuilder: URLBuilderProtocol {
  private let apiKey: String
  private let baseURL: String
  private let includeAQI: Bool
  
  init(apiKey: String = Helper.getApiKey(),
       baseURL: String = "http://api.weatherapi.com/v1/current.json",
       includeAQI: Bool = false) {
    self.apiKey = apiKey
    self.baseURL = baseURL
    self.includeAQI = includeAQI
  }
  
  func buildURL(for city: String) throws -> URL {
    guard let cityName = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
      throw NetworkError.invalidURL
    }
    
    let aqi = includeAQI ? "yes" : "no"
    let endpoint = "\(baseURL)?key=\(apiKey)&q=\(cityName)&aqi=\(aqi)"
    
    guard let url = URL(string: endpoint) else {
      throw NetworkError.invalidURL
    }
    
    return url
  }
}
