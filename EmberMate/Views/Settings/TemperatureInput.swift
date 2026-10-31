//
//  TemperatureInput.swift
//  EmberMate
//
//  Created by Matthew Nitschke on 1/26/25.
//

import Foundation
import SwiftUI
import AppKit
import UserNotifications

struct TemperatureInput: View {
    @EnvironmentObject private var emberMug: EmberMug
    
    @Binding var value: Double

    var body: some View {
        TextField(
            "Temperature",
            text: Binding(
                get: {
                    let displayValue = emberMug.temperatureUnit == .celcius
                        ? value
                        : (value * 9/5) + 32

                    // Locale aware, so a German user sees "60" but a locale with
                    // a decimal separator would see the separator it expects.
                    return displayValue.formatted(
                        .number.precision(.fractionLength(0))
                    )
                },
                set: {
                    // Parse with the user's locale so both "60.5" and "60,5"
                    // round-trip depending on the region.
                    guard let doubleValue = Self.parse($0) else { return }
                    if emberMug.temperatureUnit == .celcius {
                        value = doubleValue
                    } else {
                        value = (doubleValue - 32) * 5/9
                    }
                }
            )
        )
            .labelsHidden()
            .multilineTextAlignment(.trailing)
        
    }

    /// Accepts a number typed with the user's decimal separator, and falls back
    /// to treating "," as a decimal mark so "60,5" works in every region.
    ///
    /// Deliberately avoids `FormatStyle.parseStrategy` because it parses a
    /// prefix and ignores the rest, so "60.5" under a German locale would
    /// silently become 60 instead of being rejected.
    private static func parse(_ input: String) -> Double? {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        let normalized = trimmed.replacingOccurrences(of: decimalSeparator, with: ".")

        if let value = Double(normalized) {
            return value
        }

        return Double(trimmed.replacingOccurrences(of: ",", with: "."))
    }
}
