import WidgetKit

struct SimpleEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationIntent
  let weatherData: WeatherModel?
}
