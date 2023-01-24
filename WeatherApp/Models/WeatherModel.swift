import Foundation

struct WeatherModel {
  var labelUpdatedTime: String?
  var lastUpdatedTime: String?
  var lastUpdatedTimeStampGmt: String?
  var weatherCondition: String?
  var icon: String?
  var inic: String?
  var temperature: String?
  var feelsLike: String?
  var temperatureUnit: String?
  var placeCode: String?

  private enum WeatherCodingKeys : String, CodingKey{
    case labelUpdatedTime = "lbl_updatetime"
    case lastUpdatedTime = "updatetime"
    case lastUpdatedTimeStampGmt = "updatetime_stamp_gmt"
    case weatherCondition = "wxcondition"
    case icon
    case inic
    case temperature
    case feelsLike = "feels_like"
    case temperatureUnit = "temperature_unit"
    case placeCode = "placecode"
  }
}

enum cityNames : String, CaseIterable {
  case Toronto = "CAON0696"
  case Montreal = "CAON0423"
  case Ottawa = "CAON0512"
  case Vancouver = "CABC0308"
  case Calgary = "CAAB0049"
}


enum temperatureUnit  : String, CaseIterable, Identifiable {
  var id: String { self.rawValue }
  case celcius = "c"
  case fahrenheit = "f"
}

extension WeatherModel: Equatable {}

extension WeatherModel : Decodable {
  init(from decoder: Decoder) throws {
    let weatherData = try decoder.container(keyedBy: WeatherCodingKeys.self)
    labelUpdatedTime = try weatherData.decode(String.self, forKey: .labelUpdatedTime)
    lastUpdatedTime = try weatherData.decode(String.self, forKey: .lastUpdatedTime )
    // decoded updated time stamp to user friendly time..
    lastUpdatedTimeStampGmt = try weatherData.decodeDate(from: .lastUpdatedTimeStampGmt)
    weatherCondition = try weatherData.decode(String.self, forKey: .weatherCondition)
    icon = try weatherData.decode(String.self, forKey: .icon)
    inic = try weatherData.decode(String.self, forKey: .inic)
    temperatureUnit = try weatherData.decode(String.self, forKey: .temperatureUnit)
    // decoded temperature to String according to the temperature unit (user friendly)
    if let temperatureUnit = temperatureUnit {
      temperature = try weatherData.decodeTemp(from: .temperature, tempUnit: temperatureUnit)
      feelsLike =  try weatherData.decodeTemp(from: .feelsLike, tempUnit: temperatureUnit)
    }
    placeCode = try weatherData.decode(String.self, forKey: .placeCode)
  }
}
