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
                Image(systemName: getBatteryIcon(emberMug.batteryLevel, isCharging: emberMug.isCharging))
            }
            
            HStack {
                Text(
                    emberMug.liquidState == LiquidState.empty
                        ? "Empty"
                        : getFormattedTemperature(emberMug.currentTemp, unit: emberMug.temperatureUnit)
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
                
                Text("Target: \(getFormattedTemperature(emberMug.targetTemp, unit: emberMug.temperatureUnit))")
                
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
}
