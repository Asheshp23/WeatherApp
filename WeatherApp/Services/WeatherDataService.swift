import Foundation

protocol WeatherDataServiceProtocol {
    func fetchData<T: Decodable>(city: String) async throws -> T
}

class WeatherDataService: WeatherDataServiceProtocol {
    func fetchData<T: Decodable>(city: String) async throws -> T {
        let aqi = "no"
        let key = Helper.getApiKey()
        let cityName = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let endpoint = "http://api.weatherapi.com/v1/current.json?key=\(key)&q=\(cityName)&aqi=\(aqi)"
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        let decoder = JSONDecoder()
        let result = try decoder.decode(T.self, from: data)
        return result
    }
}
