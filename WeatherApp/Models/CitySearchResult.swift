import Foundation

struct CitySearchResult: Codable, Identifiable, Hashable, Sendable {
  let id: Int
  let name: String
  let region: String
  let country: String
  let lat: Double
  let lon: Double
  let url: String

  /// "Ontario, Canada" — collapses the empty-region case (city-states, some countries).
  var subtitle: String {
    [region, country]
      .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
      .joined(separator: ", ")
  }
}

#if DEBUG
extension CitySearchResult {
  static let previewFixtures: [CitySearchResult] = [
    CitySearchResult(id: 1, name: "London", region: "City of London, Greater London", country: "United Kingdom", lat: 51.52, lon: -0.11, url: "london-city-of-london-greater-london-united-kingdom"),
    CitySearchResult(id: 2, name: "London", region: "Ontario", country: "Canada", lat: 42.98, lon: -81.23, url: "london-ontario-canada"),
    CitySearchResult(id: 3, name: "Paris", region: "Ile-de-France", country: "France", lat: 48.87, lon: 2.33, url: "paris-ile-de-france-france"),
    CitySearchResult(id: 4, name: "Tokyo", region: "Tokyo", country: "Japan", lat: 35.69, lon: 139.69, url: "tokyo-tokyo-japan")
  ]
}
#endif
