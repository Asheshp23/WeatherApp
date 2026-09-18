
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
        let notAvailable = String(localized: "not_available", defaultValue: "Not available")
        let formattedTemperature = numberFormatter.string(from: NSNumber(value: temperature)) ?? notAvailable
        return formattedTemperature
    }
    
    // Uses RelativeDateTimeFormatter so grammar/pluralization is correct in every locale,
    // instead of hand-rolling English-only "ago" strings.
    static public func timeAgoSince(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
}
