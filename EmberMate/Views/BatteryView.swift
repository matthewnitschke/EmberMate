//
//  BatteryView.swift
//  EmberMate
//
//  Created by Jayson Rhynas on 2025-07-11.
//

import SwiftUI

struct BatteryView: View {
    enum DisplayMode: String, CaseIterable {
        case percentage, icon, both
    }
    
    let display: DisplayMode
    let batteryLevel: Int
    let isCharging: Bool
    let textFont: Font?
    
    var body: some View {
        HStack(spacing: 3) {
            if display.showIcon {
                Image(systemName: getBatteryIcon(batteryLevel, isCharging: isCharging))
            }
            if display.showPercentage {
                Text("\(batteryLevel, format: .percent)")
                    .font(textFont)
            }
        }
    }
    
    init(display: DisplayMode, batteryLevel: Int, isCharging: Bool, textFont: Font? = nil) {
        self.display = display
        self.batteryLevel = batteryLevel
        self.isCharging = isCharging
        self.textFont = textFont
    }
}

extension BatteryView.DisplayMode {
    var showPercentage: Bool {
        switch self {
        case .both, .percentage: true
        case .icon: false
        }
    }
    
    var showIcon: Bool {
        switch self {
        case .both, .icon: true
        case .percentage: false
        }
    }
}
