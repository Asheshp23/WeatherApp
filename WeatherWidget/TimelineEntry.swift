//
//  TimelineEntry.swift
//  WeatherWidgetExtension
//
//  Created by apdev on 2023-07-28.
//

import WidgetKit

struct SimpleEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationIntent
  let weatherData: WeatherModel?
}
