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

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text(emberMug.peripheral?.name ?? "")
                    .font(.caption)
                Spacer()
                Image(systemName: getBatteryIcon())
            }
            
            HStack {
                Text(
                    emberMug.liquidState == LiquidState.empty
                        ? "Empty"
                        : String(format: "%.1f°", self.emberMug.currentTemp)
                ).font(.largeTitle)
               
            }.padding(.vertical, 17)
            
            HStack(alignment: .center) {
                Button(action: {
                    let nextTemp = round((self.emberMug.targetTemp - 0.5) * 2) / 2
                    self.emberMug.setTargetTemp(temp: nextTemp)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }.buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Text(String(format: "Target: %.1f°", self.emberMug.targetTemp))
                
                Spacer()
                
                Button(action: {
                   let nextTemp = round((self.emberMug.targetTemp + 0.5) * 2) / 2
                   self.emberMug.setTargetTemp(temp: nextTemp)
               }) {
                   Image(systemName: "chevron.right")
                       .font(.title2)
               }.buttonStyle(PlainButtonStyle())
            }
            
        }.padding(10).background(LinearGradient(
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
        
        return getColor(red, green, blue)
    }
    
    private func getColor(_ red: Int, _ green: Int, _ blue: Int) -> Color {
        return getColor(Double(red), Double(green), Double(blue))
    }
    
    private func getColor(_ red: Double, _ green: Double, _ blue: Double) -> Color {
        return Color(red: red / 255, green: green / 255, blue: blue / 255)
    }
    
    private func getBatteryIcon() -> String {
        if (emberMug.isCharging) {
            return "battery.100.bolt"
        }
        
        let segment = Int(round(Double(emberMug.batteryLevel) / 25.0) * 25.0)
        return "battery.\(segment)"
    }
}
