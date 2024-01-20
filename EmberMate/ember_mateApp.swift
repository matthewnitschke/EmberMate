//
//  ember_macosApp.swift
//  EmberMate
//
//  Created by Matthew Nitschke on 12/4/23.
//

import SwiftUI
import MenuBarExtraAccess

@main
struct ember_mateApp: App {
    @ObservedObject private var emberMug: EmberMug
    @ObservedObject private var bluetoothManager: BluetoothManager
    @ObservedObject private var appState: AppState

    @State private var isMenuPresented = false
    @State private var statusItem: NSStatusItem?

    private var notificationAdapter: NotificationAdapter

    init() {
        let mug = EmberMug()
        self.emberMug = mug
        bluetoothManager = BluetoothManager(emberMug: mug)

        let state = AppState()
        self.appState = state

        self.notificationAdapter = NotificationAdapter(appState: state, emberMug: mug)
    }

    var body: some Scene {
        MenuBarExtra() {
            AppView(emberMug: emberMug, appState: appState, bluetoothManager: bluetoothManager)
        } label: {
            HStack {
                Image(systemName: getIconName())
                
                if (appState.countdown != nil) {
                    Text(formatCountdown(appState.countdown!))
                } else if (bluetoothManager.state == .connected && emberMug.liquidState != .empty) {
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

    func getIconName() -> String {
        if (appState.countdown != nil) {
            return "clock.fill"
        }
        
        if (bluetoothManager.state == .reConnecting || bluetoothManager.state == .disconnected) {
            // "empty" state for a reconnecting mug
            // ideally this would be a mug with a slash in it
            // but I dont want to create a custom icon
            return "mug"
        }

        if (emberMug.liquidState == .empty) {
            return "mug"
        }

        if (appState.selectedPreset != nil) {
            return appState.selectedPreset!.icon
        }

        return "mug.fill"
    }
    
    func formatCountdown(_ countdown: Int) -> String {
        let roundedMinutes = countdown.dividedReportingOverflow(by: 60)
        let minutes = roundedMinutes.partialValue
        
        if (minutes == 0) {
            return ">1min"
        }
        return "\(minutes)min"
    }
}
