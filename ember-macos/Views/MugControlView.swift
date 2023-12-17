//
//  MugControlView.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 12/5/23.
//

import Foundation
import SwiftUI
import UserNotifications

struct MugControlView: View {
    @ObservedObject var emberMug: EmberMug
    @ObservedObject var appState: AppState

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text(emberMug.peripheral?.name ?? "")
                    .font(.caption)
                Spacer()
                Image(systemName: getBatteryIcon(emberMug.batteryLevel, isCharging: emberMug.isCharging))
            }
            
            HStack {
                Button(action: {
                    setTemperature(delta: -0.5)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .frame(width: 30, height: 100)
                        .background(Color.black.opacity(0.29))
                }.buttonStyle(PlainButtonStyle()).cornerRadius(9)
                
                Spacer()
                
                VStack {
                    Text(
                        emberMug.liquidState == LiquidState.empty
                            ? "Empty"
                            : getFormattedTemperature(emberMug.currentTemp, unit: emberMug.temperatureUnit)
                    ).font(.largeTitle)
                    
                    if emberMug.liquidState != LiquidState.empty {
                        Text("Target: \(getFormattedTemperature(emberMug.targetTemp, unit: emberMug.temperatureUnit))")
                    }
                }
                
                Spacer()
                
                Button(action: {
                    setTemperature(delta: 0.5)
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .frame(width: 30, height: 100)
                        .background(Color.black.opacity(0.29))
                }.buttonStyle(PlainButtonStyle()).cornerRadius(9)
            }
            
            HStack {
                ForEach(appState.presets, id: \.id) { preset in
                    TemperaturePresetButton(
                        preset: preset,
                        isSelected: appState.selectedPreset?.id == preset.id,
                        onSelect: {
                            appState.selectedPreset = preset
                            emberMug.setTargetTemp(temp: $0)
                        }
                    )
                }
            }
            
            if !appState.timers.isEmpty {
                TimerView(appState: appState)
            }
            
        }.padding(10).background(LinearGradient(
            colors: getBackgroundGradient(),
            startPoint: .top,
            endPoint: .bottom
        ))
    }
    
    private func setTemperature(delta: Double) {
        appState.selectedPreset = nil
        
        let nextTemp = round((self.emberMug.targetTemp + delta) * 2) / 2
        self.emberMug.setTargetTemp(temp: nextTemp)
    }
    
    private func getBackgroundGradient() -> [Color] {
        let empty = [getColor(212, 212, 212), getColor(69, 69, 69)]
        let min = [getColor(247, 209, 111), getColor(213, 122, 52)]
        let max = [getColor(236, 113, 47), getColor(183, 67, 30)]
        
        if (emberMug.liquidState == LiquidState.empty) {
            return empty
        }
        
        
        let currentTemp = emberMug.currentTemp
        
        if (currentTemp <= 50) {
            return min
        } else if (currentTemp >= 63) {
            return max
        }
        
        let val = Double(currentTemp - 50)
        
        return [
            interpolateColor(minColor: (247, 209, 111), maxColor: (236, 113, 47), value: val),
            interpolateColor(minColor: (213, 122, 52), maxColor: (183, 67, 30), value: val),
        ]
    }
}
