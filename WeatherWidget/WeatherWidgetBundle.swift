//
//  WeatherWidgetBundle.swift
//  WeatherWidget
//
//  Created by Apdev on 2023-01-23.
//

import WidgetKit
import SwiftUI

@main
struct WeatherWidgetBundle: WidgetBundle {
    var body: some Widget {
        WeatherWidget()
        WeatherWidgetLiveActivity()
    }
}
