import Foundation

open class WeatherService: ObservableObject {
  public static let shared = WeatherService()
  //api call
  func getWeather(city: String,tempUnit: String) async -> WeatherModel? {
    guard let url = URL(string: "https://www.theweathernetwork.com/api/obsdata/\(city)/\(tempUnit)") else { return nil }
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
