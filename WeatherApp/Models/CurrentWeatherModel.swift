import Foundation

struct CurrentWeatherModel: Codable {
  let lastUpdatedEpoch: Int
  let lastUpdated: String
  let tempC: Double
  let tempF: Double
  let isDay: Int
  let condition: ConditionModel
  let windMph: Double
  let windKph: Double
  let windDegree: Int
  let windDir: String
  let pressureMb: Double
  let pressureIn: Double
  let precipMm: Double
  let precipIn: Double
  let humidity: Int
  let cloud: Int
  let feelslikeC: Double
  let feelslikeF: Double
  let visKm: Double
  let visMiles: Double
  let uv: Double
  let gustMph: Double
  let gustKph: Double

  enum CodingKeys: String, CodingKey {
    case lastUpdatedEpoch = "last_updated_epoch"
    case lastUpdated = "last_updated"
    case tempC = "temp_c"
    case tempF = "temp_f"
    case isDay = "is_day"
    case condition = "condition"
    case windMph = "wind_mph"
    case windKph = "wind_kph"
    case windDegree = "wind_degree"
    case windDir = "wind_dir"
    case pressureMb = "pressure_mb"
    case pressureIn = "pressure_in"
    case precipMm = "precip_mm"
    case precipIn = "precip_in"
    case humidity = "humidity"
    case cloud = "cloud"
    case feelslikeC = "feelslike_c"
    case feelslikeF = "feelslike_f"
    case visKm = "vis_km"
    case visMiles = "vis_miles"
    case uv = "uv"
    case gustMph = "gust_mph"
    case gustKph = "gust_kph"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    lastUpdatedEpoch = try values.decode(Int.self, forKey: .lastUpdatedEpoch)
    lastUpdated = try values.decode(String.self, forKey: .lastUpdated)
    tempC = try values.decode(Double.self, forKey: .tempC)
    tempF = try values.decode(Double.self, forKey: .tempF)
    isDay = try values.decode(Int.self, forKey: .isDay)
    condition = try values.decode(ConditionModel.self, forKey: .condition)
    windMph = try values.decode(Double.self, forKey: .windMph)
    windKph = try values.decode(Double.self, forKey: .windKph)
    windDegree = try values.decode(Int.self, forKey: .windDegree)
    windDir = try values.decode(String.self, forKey: .windDir)
    pressureMb = try values.decode(Double.self, forKey: .pressureMb)
    pressureIn = try values.decode(Double.self, forKey: .pressureIn)
    precipMm = try values.decode(Double.self, forKey: .precipMm)
    precipIn = try values.decode(Double.self, forKey: .precipIn)
    humidity = try values.decode(Int.self, forKey: .humidity)
    cloud = try values.decode(Int.self, forKey: .cloud)
    feelslikeC = try values.decode(Double.self, forKey: .feelslikeC)
    feelslikeF = try values.decode(Double.self, forKey: .feelslikeF)
    visKm = try values.decode(Double.self, forKey: .visKm)
    visMiles = try values.decode(Double.self, forKey: .visMiles)
    uv = try values.decode(Double.self, forKey: .uv)
    gustMph = try values.decode(Double.self, forKey: .gustMph)
    gustKph = try values.decode(Double.self, forKey: .gustKph)
  }

  init() {
    lastUpdatedEpoch = 0
    lastUpdated = ""
    tempC = 0.0
    tempF = 0.0
    isDay = 0
    condition =  ConditionModel()
    windMph = 0.0
    windKph = 0.0
    windDegree = 0
    windDir = ""
    pressureMb = 0.0
    pressureIn = 0.0
    precipMm = 0.0
    precipIn = 0.0
    humidity = 0
    cloud = 0
    feelslikeC = 0.0
    feelslikeF = 0.0
    visKm = 0.0
    visMiles = 0.0
    uv = 0.0
    gustMph = 0.0
    gustKph = 0.0
  }
}
