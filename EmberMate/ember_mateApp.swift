//
//  ember_macosApp.swift
//  EmberMate
//
//  Created by Matthew Nitschke on 12/4/23.
//

import SwiftUI

@main
struct ember_mateApp: App {
    @ObservedObject private var emberMug: EmberMug
    @ObservedObject private var bluetoothManager: BluetoothManager
    @ObservedObject private var appState: AppState

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
            AppView()
                .environmentObject(emberMug)
                .environmentObject(appState)
                .environmentObject(bluetoothManager)
        } label: {
            HStack {
                Image(systemName: getIconName())
                
                if (appState.countdown != nil) {
                    Text(formatCountdown(appState.countdown!))
                } else if (bluetoothManager.state == .connected && emberMug.liquidState != .empty) {
                    Text(getFormattedTemperature(emberMug.currentTemp, unit: emberMug.temperatureUnit))
                } else if (bluetoothManager.state == .connected && emberMug.liquidState == .empty && emberMug.batteryLevel != 100 && emberMug.isCharging && appState.showBatteryLevelWhenCharging) {
                    Text(getFormattedBatteryLevel(emberMug.batteryLevel))
                }
            }
        }.menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .frame(width: 400, height: 510)
                .environmentObject(emberMug)
                .environmentObject(appState)
                .environmentObject(bluetoothManager)
            
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

private struct OpenSettingsBackportKey: EnvironmentKey {
    static let defaultValue: () -> Void = {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

extension EnvironmentValues {
    var openSettings_backport: () -> Void {
        get {
            if #available(macOS 14.0, *) {
                return { [openSettings] in
                    openSettings()
                    NSApp.activate(ignoringOtherApps: true)
                }
            } else {
                return self[OpenSettingsBackportKey.self]
            }
        }
        set { self[OpenSettingsBackportKey.self] = newValue }
    }
}
