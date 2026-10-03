
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
        localizedNumber(Int(temperature.rounded()))
    }
    
    // Hindi/Gujarati/Punjabi default to Western digits on iOS (matching Apple's own apps),
    // but this app forces native digit shaping (Devanagari/Gujarati/Gurmukhi) as a deliberate choice.
    static var numberLocale: Locale {
        let numberingSystems = ["hi": "deva", "gu": "gujr", "pa": "guru"]
        guard let languageCode = Locale.current.language.languageCode?.identifier,
              let system = numberingSystems[languageCode] else {
            return .current
        }
        return Locale(identifier: "\(languageCode)@numbers=\(system)")
    }
    
    static func localizedNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = numberLocale
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    static func localizedNumber(_ value: Double, fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        formatter.locale = numberLocale
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(fractionDigits)f", value)
    }
    
    // weatherapi.com returns sunrise/sunset as a fixed "h:mm a" English string (e.g. "06:45 AM"),
    // not locale-aware at all. Parse it with a fixed-format parser, then re-render using the
    // app's locale so the hour/minute digits and AM/PM marker both match the selected language.
    private static let apiTimeParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    static func localizedTime(_ apiTimeString: String) -> String {
        guard let date = apiTimeParser.date(from: apiTimeString) else { return apiTimeString }
        let formatter = DateFormatter()
        formatter.locale = numberLocale
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Position of an API time ("06:45 AM") within the day, from 0 (midnight) to 1.
    static func dayFraction(fromAPITime apiTimeString: String) -> Double? {
        guard let date = apiTimeParser.date(from: apiTimeString) else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = apiTimeParser.timeZone
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        guard let hour = parts.hour, let minute = parts.minute else { return nil }
        return (Double(hour) + Double(minute) / 60) / 24
    }

    /// Hour label ("3 PM" / "15") from an epoch, honouring the locale's 12/24-hour convention and digits.
    /// `timeZone` should be the forecast city's, so a Tokyo forecast shows Tokyo hours.
    static func localizedHour(_ epoch: Int, timeZone: TimeZone? = nil) -> String {
        let formatter = DateFormatter()
        formatter.locale = numberLocale
        formatter.timeZone = timeZone ?? .current
        formatter.setLocalizedDateFormatFromTemplate("j")
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(epoch)))
    }
    
    /// Short weekday name ("Mon") from an epoch, in the forecast city's time zone.
    static func localizedWeekday(_ epoch: Int, timeZone: TimeZone? = nil) -> String {
        let formatter = DateFormatter()
        formatter.locale = numberLocale
        formatter.timeZone = timeZone ?? .current
        formatter.setLocalizedDateFormatFromTemplate("EEE")
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(epoch)))
    }
    
    // Uses RelativeDateTimeFormatter so grammar/pluralization is correct in every locale,
    // instead of hand-rolling English-only "ago" strings.
    static public func timeAgoSince(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = numberLocale
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
}
