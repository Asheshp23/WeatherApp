import Foundation

enum LocationError: Error {
  case noCityFound
}

enum NetworkError: Error {
  case invalidURL
  case invalidResponse
}
