import Foundation

struct LocationModel: Codable {
  let name: String
  let region: String
  let country: String
  let lat: Double
  let lon: Double
  let tzId: String
  let localtimeEpoch: Int
  let localtime: String

  enum CodingKeys: String, CodingKey {
    case name = "name"
    case region = "region"
    case country = "country"
    case lat = "lat"
    case lon = "lon"
    case tzId = "tz_id"
    case localtimeEpoch = "localtime_epoch"
    case localtime = "localtime"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(String.self, forKey: .name)
    self.region = try container.decode(String.self, forKey: .region)
    self.country = try container.decode(String.self, forKey: .country)
    self.lat = try container.decode(Double.self, forKey: .lat)
    self.lon = try container.decode(Double.self, forKey: .lon)
    self.tzId = try container.decode(String.self, forKey: .tzId)
    self.localtimeEpoch = try container.decode(Int.self, forKey: .localtimeEpoch)
    self.localtime = try container.decode(String.self, forKey: .localtime)
  }
}
