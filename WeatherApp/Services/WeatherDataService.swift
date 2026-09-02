import Foundation

protocol WeatherServiceProtocol: Sendable {
  func fetchCurrentWeather(for city: String) async throws -> WeatherModel
  func searchCities(matching query: String) async throws -> [CitySearchResult]
  func fetchForecast(for city: String, days: Int) async throws -> WeatherModel
}

struct WeatherDataService: WeatherServiceProtocol {
  private let network: NetworkServiceProtocol
  private let decoder: JSONDecoder
  private let baseURL: String = "https://api.weatherapi.com/v1"
  
  init(network: NetworkServiceProtocol = NetworkService(),
       decoder: JSONDecoder = JSONDecoder()) {
    self.network = network
    self.decoder = decoder
  }
  
  func fetchCurrentWeather(for city: String) async throws -> WeatherModel {
    try await get(path: "current.json", parameters: [
      "key": Helper.getApiKey(),
      "q": city,
      "aqi": "no"
    ])
  }
  
  func searchCities(matching query: String) async throws -> [CitySearchResult] {
    try await get(path: "search.json", parameters: [
      "key": Helper.getApiKey(),
      "q": query
    ])
  }

  func fetchForecast(for city: String, days: Int) async throws -> WeatherModel {
    try await get(path: "forecast.json", parameters: [
      "key": Helper.getApiKey(),
      "q": city,
      "days": "\(days)",
      "alerts": "yes",
      "aqi": "no"
    ])
  }
  
  private func get<T: Decodable>(path: String, parameters: [String: String]) async throws -> T {
    let url = try buildURL(path: path, with: parameters)
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    
    return try await network.request(request, decoder: decoder)
  }
  
  func buildURL(path: String, with parameters: [String: String]) throws -> URL {
    guard var components = URLComponents(string: baseURL) else {
      throw NetworkError.invalidBaseURL
    }
    
    components.path += "/" + path
    components.queryItems = parameters.map { key, value in
      URLQueryItem(name: key, value: value)
    }
    
    guard let url = components.url else {
      throw NetworkError.invalidURL
    }
    
    return url
  }
}
