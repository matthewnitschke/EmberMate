//
//  Utils.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 12/7/23.
//

import Foundation
import SwiftUI

func getFormattedTemperature(_ temp: Double, unit: TemperatureUnit) -> String {
    if unit == .celcius {
        return String(format: "%.f°", temp)
    }
    
    return String(format: "%.0f°", (temp * 9/5) + 32)
}


func getBatteryIcon(_ batteryLevel: Int, isCharging: Bool) -> String {
    if (isCharging) {
        return "battery.100.bolt"
    }

    let segment = Int(round(Double(batteryLevel) / 25.0) * 25.0)
    return "battery.\(segment)"
}


func interpolateColor(minColor: (Double, Double, Double), maxColor: (Double, Double, Double), value: Double) -> Color {
    let clampedValue = max(0, min(value, 13)) / 13.0

    let red = minColor.0 + (maxColor.0 - minColor.0) * clampedValue
    let green = minColor.1 + (maxColor.1 - minColor.1) * clampedValue
    let blue = minColor.2 + (maxColor.2 - minColor.2) * clampedValue
    
    return getColor(red, green, blue)
}

func getColor(_ red: Int, _ green: Int, _ blue: Int) -> Color {
    return getColor(Double(red), Double(green), Double(blue))
}

func getColor(_ red: Double, _ green: Double, _ blue: Double) -> Color {
    return Color(red: red / 255, green: green / 255, blue: blue / 255)
}
