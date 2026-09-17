import SwiftUI

@main
struct ember_mateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

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

        if let delegate = AppDelegate.shared {
            delegate.connect(emberMug: mug, appState: state, bluetoothManager: bluetoothManager)
        } else {
            AppDelegate.pendingModels = (mug, state, bluetoothManager)
        }
    }

    var body: some Scene {
        Settings {
            SettingsView()
                .frame(width: 400, height: 510)
                .environmentObject(emberMug)
                .environmentObject(appState)
                .environmentObject(bluetoothManager)
        }
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