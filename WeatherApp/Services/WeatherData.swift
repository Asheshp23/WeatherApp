import Foundation
import WeatherKit
import CoreLocation
import os

open class WeatherData: ObservableObject {
  public static let shared = WeatherData()
  private let service = WeatherService.shared
  @Published private var currentWeathers = [CurrentWeather]()
  @Published private var dailyForecasts = [ Forecast<DayWeather>]()
  @Published private var hourlyForecasts = [Forecast<HourWeather>]()

  //api call
  func getWeather(city: String, tempUnit: String) async -> WeatherModel? {
    let aqi = "no"
    let key = "4276de9c52c141b180081734232701"
    let cityName = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let endpoint = "http://api.weatherapi.com/v1/current.json?key=\(key)&q=\(cityName)&aqi=\(aqi)"
    guard let url = URL(string: endpoint) else { return nil }
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

  @discardableResult
  func weather(for location: CLLocation) async -> CurrentWeather? {
    let currentWeather = await Task.detached(priority: .userInitiated) {
      let forcast = try? await self.service.weather(
        for: location,
        including: .current)
      return forcast
    }.value
    if let currentWeather = currentWeather {
      currentWeathers.append(currentWeather)
    }
    return currentWeather
  }

  @discardableResult
  func dailyForecast(for location: CLLocation) async -> Forecast<DayWeather>? {
    let dayWeather = await Task.detached(priority: .userInitiated) {
      let forcast = try? await self.service.weather(
        for: location,
        including: .daily)
      return forcast
    }.value
    if let dayWeather = dayWeather {
      dailyForecasts.append(dayWeather)
    }
    return dayWeather
  }

  @discardableResult
  func hourlyForecast(for location: CLLocation) async -> Forecast<HourWeather>? {
    let hourWeather = await Task.detached(priority: .userInitiated) {
      let forcast = try? await self.service.weather(
        for: location,
        including: .hourly)
      return forcast
    }.value
    if let hourWeather = hourWeather {
      hourlyForecasts.append(hourWeather)
    }
    return hourWeather
  }
}
