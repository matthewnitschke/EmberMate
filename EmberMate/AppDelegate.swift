import AppKit
import Combine
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?
    static var pendingModels: (EmberMug, AppState, BluetoothManager)?

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?

    private var emberMug: EmberMug?
    private var appState: AppState?
    private var bluetoothManager: BluetoothManager?

    private var cancellables: Set<AnyCancellable> = []

    private var didFinishLaunching = false
    private var modelsInjected = false

    override init() {
        super.init()
        AppDelegate.shared = self
        if let (mug, state, bluetoothManager) = AppDelegate.pendingModels {
            AppDelegate.pendingModels = nil
            connect(emberMug: mug, appState: state, bluetoothManager: bluetoothManager)
        }
    }

    func connect(emberMug: EmberMug, appState: AppState, bluetoothManager: BluetoothManager) {
        self.emberMug = emberMug
        self.appState = appState
        self.bluetoothManager = bluetoothManager
        modelsInjected = true
        setupWhenReady()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        didFinishLaunching = true
        setupWhenReady()
    }

    private func setupWhenReady() {
        guard didFinishLaunching, modelsInjected,
            let emberMug, let appState, let bluetoothManager
        else { return }

        setupStatusItem()
        setupPopover(emberMug: emberMug, appState: appState, bluetoothManager: bluetoothManager)
        observeState()
    }

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.target = self
            button.action = #selector(statusItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.imagePosition = .imageLeading
        }
        statusItem = item
        updateStatusItem()
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        guard let popover else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func setupPopover(emberMug: EmberMug, appState: AppState, bluetoothManager: BluetoothManager) {
        let popover = NSPopover()
        popover.behavior = .transient

        let hosting = AutoSizingHostingController(
            rootView: AppView()
                .environmentObject(emberMug)
                .environmentObject(appState)
                .environmentObject(bluetoothManager)
                .environment(\.dismissPopover) { [weak self] in
                    self?.popover?.performClose(nil)
                }
        )
        hosting.onResize = { [weak popover] size in
            guard let popover,
                abs(popover.contentSize.width - size.width) > 1 ||
                abs(popover.contentSize.height - size.height) > 1
            else { return }
            popover.contentSize = size
        }
        popover.contentViewController = hosting
        self.popover = popover
    }

    private func observeState() {
        guard let emberMug, let appState, let bluetoothManager else { return }

        let publishers: [AnyPublisher<Void, Never>] = [
            appState.$countdown.map { _ in () }.eraseToAnyPublisher(),
            appState.$selectedPreset.map { _ in () }.eraseToAnyPublisher(),
            bluetoothManager.$state.map { _ in () }.eraseToAnyPublisher(),
            emberMug.$liquidState.map { _ in () }.eraseToAnyPublisher(),
            emberMug.$currentTemp.map { _ in () }.eraseToAnyPublisher(),
            emberMug.$temperatureUnit.map { _ in () }.eraseToAnyPublisher(),
            emberMug.$batteryLevel.map { _ in () }.eraseToAnyPublisher(),
            emberMug.$isCharging.map { _ in () }.eraseToAnyPublisher(),
        ]

        Publishers.MergeMany(publishers)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItem()
            }
            .store(in: &cancellables)

        updateStatusItem()
    }

    private func updateStatusItem() {
        guard let button = statusItem?.button else { return }
        button.image = NSImage(systemSymbolName: getIconName(), accessibilityDescription: nil)
        button.title = getStatusTitle()
    }

    private func getIconName() -> String {
        guard let appState, let bluetoothManager, let emberMug else { return "mug" }

        if appState.countdown != nil {
            return "clock.fill"
        }

        if bluetoothManager.state == .reConnecting || bluetoothManager.state == .disconnected {
            return "mug"
        }

        if emberMug.liquidState == .empty {
            return "mug"
        }

        if let selectedPreset = appState.selectedPreset {
            return selectedPreset.icon
        }

        return "mug.fill"
    }

    private func getStatusTitle() -> String {
        guard let appState, let bluetoothManager, let emberMug else { return "" }

        if let countdown = appState.countdown {
            return formatCountdown(countdown)
        }

        if bluetoothManager.state == .connected && emberMug.liquidState != .empty {
            return getFormattedTemperature(emberMug.currentTemp, unit: emberMug.temperatureUnit)
        }

        if bluetoothManager.state == .connected &&
            emberMug.liquidState == .empty &&
            emberMug.batteryLevel != 100 &&
            emberMug.isCharging {
            return getFormattedBatteryLevel(emberMug.batteryLevel)
        }

        return ""
    }

    private func formatCountdown(_ countdown: Int) -> String {
        let minutes = countdown / 60
        if minutes == 0 {
            return ">1min"
        }
        return "\(minutes)min"
    }
}

final class AutoSizingHostingController<Content: View>: NSHostingController<Content> {
    var onResize: ((CGSize) -> Void)?

    override func viewDidLayout() {
        super.viewDidLayout()
        onResize?(view.fittingSize)
    }
}

private struct DismissPopoverKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var dismissPopover: () -> Void {
        get { self[DismissPopoverKey.self] }
        set { self[DismissPopoverKey.self] = newValue }
    }
}