//
//  ember_macosApp.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 12/4/23.
//

import SwiftUI

@main
struct ember_controllerApp: App {
    @ObservedObject private var emberMug: EmberMug
    @ObservedObject private var bluetoothViewModel: BluetoothViewModel
    
    @State private var showingPopover = false
    
    init() {
        let mug = EmberMug()
        self.emberMug = mug
        bluetoothViewModel = BluetoothViewModel(emberMug: mug)
    }
    
    var body: some Scene {
        MenuBarExtra() {
            if (bluetoothViewModel.isConnected) {
                AppView(emberMug: emberMug)
            } else {
                ConnectMugView(bluetoothViewModel: bluetoothViewModel)
            }
        } label: {
            HStack {
                Image(systemName: emberMug.liquidState == LiquidState.empty ? "mug" : "mug.fill")
                if (emberMug.liquidState != LiquidState.empty) {
                    Text(String(format: "%.1f °C", emberMug.currentTemp))
                }
            }
        }.menuBarExtraStyle(.window)
    }
}
