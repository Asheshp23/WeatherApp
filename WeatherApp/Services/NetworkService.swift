import Foundation

protocol NetworkServiceProtocol: Sendable {
  func request<T: Decodable>(_ request: URLRequest, decoder: JSONDecoder) async throws -> T
}

struct NetworkService: NetworkServiceProtocol {
  private let session: URLSession
  
  init(session: URLSession = .shared) {
    self.session = session
  }
  
  func request<T: Decodable>(_ request: URLRequest, decoder: JSONDecoder = JSONDecoder()) async throws -> T {
    let (data, response) = try await session.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
      throw NetworkError.invalidResponse
    }
    return try decoder.decode(T.self, from: data)
  }
}
