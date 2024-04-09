
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
    
    static public func timeAgoSince(_ date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: date, to: now)
        
        if let years = components.year, years >= 2 {
            return "\(years) years ago"
        } else if let years = components.year, years >= 1 {
            return "Last year"
        } else if let months = components.month, months >= 2 {
            return "\(months) months ago"
        } else if let months = components.month, months >= 1 {
            return "Last month"
        } else if let weeks = components.weekOfYear, weeks >= 2 {
            return "\(weeks) weeks ago"
        } else if let weeks = components.weekOfYear, weeks >= 1 {
            return "Last week"
        } else if let days = components.day, days >= 2 {
            return "\(days) days ago"
        } else if let days = components.day, days >= 1 {
            return "Yesterday"
        } else if let hours = components.hour, hours >= 2 {
            return "\(hours) hours ago"
        } else if let hours = components.hour, hours >= 1 {
            return "An hour ago"
        } else if let minutes = components.minute, minutes >= 2 {
            return "\(minutes) minutes ago"
        } else if let minutes = components.minute, minutes >= 1 {
            return "A minute ago"
        } else if let seconds = components.second, seconds >= 3 {
            return "\(seconds) seconds ago"
        } else {
            return "Just now"
        }
    }
    
}
