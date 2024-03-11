import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationIntent
  let weatherData: WeatherModel?
  let backgroundColor: Color
}
