import Foundation

public extension KeyedDecodingContainer where Key : CodingKey {
  func decodeTemp(from key : Key , tempUnit : String) throws -> String?  {
    // when temperature unit is celcius
    if tempUnit == "C" {
      let temperatureInCelcius = try decode(String.self, forKey: key)
      return temperatureInCelcius
    }
    // temperature unit is fahrenheit
    let temperatureInFahrenheit =  try decode(Int.self, forKey: key)
    return "\(temperatureInFahrenheit)"
  }

  func decodeDate(from key : Key ) throws -> String?  {
    let dateAsString = try decode(String.self, forKey: key)
    let date = Date(timeIntervalSince1970: Double((Double(dateAsString) ?? 0.0)/1000) )
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current //Set timezone that you want
    dateFormatter.locale = Locale.current
    dateFormatter.dateFormat = "yyyy-MM-dd h:mm a" //Specify your format that you want
    let strDate = dateFormatter.string(from: date)
    guard let updatedDate = dateFormatter.date(from:strDate) else{ return nil }
    let today =   dateFormatter.date(from:dateFormatter.string(from: Date.now))
    return today?.time(since: updatedDate)
  }
}
