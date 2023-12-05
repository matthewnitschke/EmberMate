//
//  AppView.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 12/3/23.
//

import Foundation
import SwiftUI

struct AppView: View {
    @ObservedObject var emberMug: EmberMug

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("\(self.emberMug.batteryLevel)%")
                    .font(.caption)
                Image(systemName: "battery.0")
            }
            
            
            Text(
                emberMug.liquidState == LiquidState.empty
                    ? "Empty"
                    : String(format: "%.1f °C", self.emberMug.currentTemp)
            ).font(.title)
             .padding()
        

            HStack {
                Button(action: {
                    let nextTemp = round((self.emberMug.targetTemp - 0.5) * 2) / 2
                    self.emberMug.setTargetTemp(temp: nextTemp)
                }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text("Target: \(String(format: "%.1f °C", self.emberMug.targetTemp))")
                Spacer()
                Button(action: {
                    let nextTemp = round((self.emberMug.targetTemp + 0.5) * 2) / 2
                    self.emberMug.setTargetTemp(temp: nextTemp)
                }) {
                    Image(systemName: "chevron.right")
                }
            }
        }.padding(8)
    }
}
