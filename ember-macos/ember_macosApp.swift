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
    
    @State private var isMenuPresented = false
    @State private var statusItem: NSStatusItem?
    
    init() {
        let mug = EmberMug()
        self.emberMug = mug
        bluetoothManager = BluetoothManager(emberMug: mug)
    }
    
    var body: some Scene {
        MenuBarExtra() {
            AppView(emberMug: emberMug, bluetoothManager: bluetoothManager)
        } label: {
            HStack {
                Image(systemName: emberMug.liquidState == LiquidState.empty ? "mug" : "mug.fill")
                if (emberMug.liquidState != LiquidState.empty) {
                    Text(String(format: "%.1f°", emberMug.currentTemp))
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
    }
}
