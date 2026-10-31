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

/// Formats a temperature (always stored in celsius) for display.
///
/// Uses the user's locale so the decimal separator is correct (`65.5°` in en_US,
/// `65,5°` in de_DE). The degree symbol is appended by hand rather than using
/// `Measurement.formatted()` because the UI already implies the unit via the
/// picker and the extra "C"/"F" glyph does not fit the fixed-width buttons.
func getFormattedTemperature(_ temp: Double, unit: TemperatureUnit) -> String {
    let value: Double
    let fractionDigits: Int

    switch unit {
    case .celcius:
        // The mug reports temperatures to a hundredth of a degree, but a single
        // decimal is all the UI has room for.
        value = temp
        fractionDigits = 1
    case .fahrenheit:
        value = Measurement(value: temp, unit: UnitTemperature.celsius)
            .converted(to: .fahrenheit)
            .value
        fractionDigits = 0
    }

    let number = value.formatted(
        .number
            .precision(.fractionLength(fractionDigits))
            .rounded(rule: .toNearestOrEven)
    )

    return "\(number)°"
}

func getFormattedBatteryLevel(_ batteryLevel: Int) -> String {
    // `batteryLevel` is a whole percentage (0...100), so shift it into the 0...1
    // range the percent format style expects.
    return (Double(batteryLevel) / 100).formatted(.percent.precision(.fractionLength(0)))
}

func formatTime(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    return String(format: "%d:%02d", locale: Locale.current, minutes, remainingSeconds)
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
