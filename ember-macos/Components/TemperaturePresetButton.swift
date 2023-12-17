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
        Button(action: {
            onSelect(preset.temperature)
        }) {
            VStack {
                Text(preset.name)
                    .font(.caption)
                Spacer()
                Image(systemName: preset.icon)
                    .font(.largeTitle)
                Spacer()
                Text(getFormattedTemperature(preset.temperature, unit: .celcius))
                    .font(.caption)
            }
            .padding(10)
            .frame(width: 90, height: 90)
            .background(Color.black.opacity(isSelected ? 0.6 : 0.29))
        }
        .buttonStyle(PlainButtonStyle())
        .cornerRadius(9)
    }
}
