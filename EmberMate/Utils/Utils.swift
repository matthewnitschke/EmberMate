//
//  Utils.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 12/7/23.
//

import Foundation
import SwiftUI

func getBackgroundGradient(_ val: Double) -> [Color] {
    return [
        interpolateColor(minColor: (247, 209, 111), maxColor: (236, 113, 47), value: val),
        interpolateColor(minColor: (213, 122, 52), maxColor: (183, 67, 30), value: val),
    ]
}

func getFormattedTemperature(_ temp: Double, unit: TemperatureUnit) -> String {
    if unit == .celcius {
        return String(format: "%.1f°", temp)
    }

    return String(format: "%.0f°", (temp * 9/5) + 32)
}

func getFormattedBatteryLevel(_ batteryLevel: Int) -> String {
    return String(format: "%d%%", batteryLevel)
}

func formatTime(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    return String(format: "%d:%02d", minutes, remainingSeconds)
}

func convertTimeToSeconds(_ timeString: String) -> Int? {
    let components = timeString.components(separatedBy: ":")

    guard components.count == 2,
        let minutes = Int(components[0]),
        let seconds = Int(components[1]) else {
            return nil // Return nil if the format is not as expected
    }

    return minutes * 60 + seconds
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

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}

func getLatestVersion() async -> String? {
    let url = URL(string: "https://api.github.com/repos/matthewnitschke/EmberMate/releases/latest")!

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           var name = json["name"] as? String {
            
            if name.hasPrefix("v") {
                name = String(name.dropFirst())
            }
            
            return name
        }
    } catch {
        print("Error fetching data:", error)
    }
    return nil
}
