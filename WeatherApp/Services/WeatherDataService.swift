import Foundation

protocol WeatherServiceProtocol {
  func fetchCurrentWeather(for city: String) async throws -> WeatherModel
}

struct WeatherDataService: WeatherServiceProtocol {
  private let network: NetworkServiceProtocol
  private let decoder: JSONDecoder
  private let baseURL: String = "http://api.weatherapi.com/v1/current.json"
  
  init(network: NetworkServiceProtocol = NetworkService(),
       decoder: JSONDecoder = JSONDecoder()) {
    self.network = network
    self.decoder = decoder
  }
  
  func fetchCurrentWeather(for city: String) async throws -> WeatherModel {
    let url = try buildURL(with: [
      "key": Helper.getApiKey(),
      "q": city,
      "aqi": "no"
    ])
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    
    return try await network.request(request, decoder: decoder)
  }
  
  func buildURL(with parameters: [String: String]) throws -> URL {
    guard var components = URLComponents(string: baseURL) else {
      throw NetworkError.invalidBaseURL
    }
    
    components.queryItems = parameters.map { key, value in
      URLQueryItem(name: key, value: value)
    }
    
    guard let url = components.url else {
      throw NetworkError.invalidURL
    }
    
    return url
  }
}
