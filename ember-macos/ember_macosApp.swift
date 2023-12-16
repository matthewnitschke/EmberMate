//
//  ember_macosApp.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 12/4/23.
//

import SwiftUI
import MenuBarExtraAccess

@main
struct ember_controllerApp: App {
    @ObservedObject private var emberMug: EmberMug
    @ObservedObject private var bluetoothManager: BluetoothManager
    @ObservedObject private var appState: AppState
    
    @State private var isMenuPresented = false
    @State private var statusItem: NSStatusItem?
    
    init() {
        let mug = EmberMug()
        self.emberMug = mug
        bluetoothManager = BluetoothManager(emberMug: mug)
        
        appState = AppState()
    }
    
    var body: some Scene {
        MenuBarExtra() {
            AppView(emberMug: emberMug, appState: appState, bluetoothManager: bluetoothManager)
        } label: {
            HStack {
                Image(systemName: emberMug.liquidState == LiquidState.empty ? "mug" : "mug.fill")
                
                if (emberMug.liquidState != LiquidState.empty) {
                    Text(getFormattedTemperature(emberMug.currentTemp, unit: emberMug.temperatureUnit))
                }
            }
        }.menuBarExtraAccess(isPresented: $isMenuPresented) { statusItem in

            if (self.statusItem == nil) {
                self.statusItem = statusItem

                NSEvent.addLocalMonitorForEvents(matching: .rightMouseDown) { event in
                    let contextMenu = ContextMenu(bluetoothManager: bluetoothManager, emberMug: emberMug)

                    statusItem.menu = contextMenu.menu
                    statusItem.button?.performClick(nil)
                    statusItem.menu = nil

                    return event
                }
            }

        }.menuBarExtraStyle(.window)
        
        Settings {
            SettingsView(
                appState: appState,
                emberMug: emberMug,
                bluetoothManager: bluetoothManager
            )
                .frame(width: 400, height: 510)
        }
    }
}
