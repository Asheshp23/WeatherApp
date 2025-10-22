import Foundation

protocol WeatherServiceProtocol {
  func fetchCurrentWeather(for city: String) async throws -> WeatherModel
}


struct WeatherDataService: WeatherServiceProtocol {
  private let network: NetworkServiceProtocol
  private let urlBuilder: URLBuilderProtocol
  private let decoder: JSONDecoder
  
  init(network: NetworkServiceProtocol = NetworkService(),
       urlBuilder: URLBuilderProtocol = WeatherAPIURLBuilder(),
       decoder: JSONDecoder = JSONDecoder()) {
    self.network = network
    self.urlBuilder = urlBuilder
    self.decoder = decoder
  }
  
  func fetchCurrentWeather(for city: String) async throws -> WeatherModel {
    let url = try urlBuilder.buildURL(for: city)
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    
    return try await network.request(request, decoder: decoder)
  }
}
