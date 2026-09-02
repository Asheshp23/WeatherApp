import Foundation

@MainActor
@Observable
final class SavedCitiesStore {
  private static let key = "savedCities"

  private(set) var cities: [CitySearchResult]

  init() {
    if let data = UserDefaults.standard.data(forKey: Self.key),
       let decoded = try? JSONDecoder().decode([CitySearchResult].self, from: data) {
      cities = decoded
    } else {
      cities = []
    }
  }

  func add(_ city: CitySearchResult) {
    guard !contains(id: city.id) else { return }
    cities.append(city)
    persist()
  }

  func remove(_ city: CitySearchResult) {
    cities.removeAll { $0.id == city.id }
    persist()
  }

  func contains(id: Int) -> Bool {
    cities.contains { $0.id == id }
  }

  private func persist() {
    guard let data = try? JSONEncoder().encode(cities) else { return }
    UserDefaults.standard.set(data, forKey: Self.key)
  }
}
