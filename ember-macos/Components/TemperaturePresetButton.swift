//
//  TemperaturePresetButton.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 12/10/23.
//

import Foundation
import SwiftUI

struct TemperaturePresetButton: View {
    var preset: Preset
    var isSelected: Bool
    var onSelect: (Double) -> Void
    
    var body: some View {
        IconButton(
            headerText: preset.name,
            footerText: getFormattedTemperature(preset.temperature, unit: .celcius),
            icon: preset.icon,
            isSelected: isSelected,
            onSelect: {
                onSelect(preset.temperature)
            }
        )
    }
}
