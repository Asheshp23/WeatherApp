
import Foundation

struct DataModel: Codable {
  var API_KEY: String
}

class Helper {
  static func getApiKey() -> String {
    let decoder = PropertyListDecoder()

    if let plistPath = Bundle.main.path(forResource: "config", ofType: "plist"),
       let plistData = FileManager.default.contents(atPath: plistPath),
       let dataModel = try? decoder.decode(DataModel.self, from: plistData) {
      return dataModel.API_KEY
    }
    return "not found"
  }

  static func formatTemperature(_ temperature: Double, unit: TemperatureUnit) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.maximumFractionDigits = 0
    let formattedTemperature = numberFormatter.string(from: NSNumber(value: temperature)) ?? "Not available"
    return formattedTemperature
  }

  static func decodeDate(dateAsString: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.locale = Locale.current
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    guard let date = dateFormatter.date(from: dateAsString) else { return nil }
    let today = dateFormatter.date(from:dateFormatter.string(from: Date.now))
    return today?.time(since: date)
  }

}
