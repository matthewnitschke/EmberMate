//
//  MugControlView.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 12/5/23.
//

import Foundation
import SwiftUI

struct MugControlView: View {
    @ObservedObject var emberMug: EmberMug

    var body: some View {
        VStack {
            HStack(spacing: 1) {
                Spacer()
                Text("\(self.emberMug.batteryLevel)%")
                    .font(.caption)
                    .foregroundColor(Color.black)
                Image(systemName: getBatteryIcon())
                    .foregroundColor(Color.black)
            }
            
            
            Text(
                emberMug.liquidState == LiquidState.empty
                    ? "Empty"
                    : String(format: "%.1f °C", self.emberMug.currentTemp)
            ).font(.largeTitle)
                .padding(.vertical, 50)
        
            
            HStack {
                Button(action: {
                    let nextTemp = round((self.emberMug.targetTemp - 0.5) * 2) / 2
                    self.emberMug.setTargetTemp(temp: nextTemp)
                }) {
                    Image(systemName: "chevron.left")
                }.buttonStyle(PlainButtonStyle())
                Spacer()
                Text("Target: \(String(format: "%.1f °C", self.emberMug.targetTemp))")
                Spacer()
                Button(action: {
                    let nextTemp = round((self.emberMug.targetTemp + 0.5) * 2) / 2
                    self.emberMug.setTargetTemp(temp: nextTemp)
                }) {
                    Image(systemName: "chevron.right")
                }.buttonStyle(PlainButtonStyle())
            }
        }.padding(8).background(LinearGradient(
            colors: getBackgroundGradient(),
            startPoint: .top,
            endPoint: .bottom
        ))
    }
    
    private func getBackgroundGradient() -> [Color] {
        let empty = [getColor(217, 223, 229), getColor(111, 113, 125)]
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
    
    func interpolateColor(minColor: (Double, Double, Double), maxColor: (Double, Double, Double), value: Double) -> Color {
        let clampedValue = max(0, min(value, 13)) / 13.0

        let red = minColor.0 + (maxColor.0 - minColor.0) * clampedValue
        let green = minColor.1 + (maxColor.1 - minColor.1) * clampedValue
        let blue = minColor.2 + (maxColor.2 - minColor.2) * clampedValue

        return Color(red: red / 255.0, green: green / 255.0, blue: blue / 255.0)
    }
    
    private func getColor(_ red: Int, _ green: Int, _ blue: Int) -> Color {
        return Color(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
    }
    
    private func getBatteryIcon() -> String {
        if (emberMug.isCharging) {
            return "battery.100.bolt"
        }
        
        let segment = Int(round(Double(emberMug.batteryLevel) / 25.0) * 25.0)
        return "battery.\(segment)"
    }
}
