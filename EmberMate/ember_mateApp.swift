//
//  ember_macosApp.swift
//  EmberMate
//
//  Created by Matthew Nitschke on 12/4/23.
//

import SwiftUI
import Combine

@main
struct ember_mateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Settings scene - not shown automatically, only when explicitly opened
        Settings {
            EmptyView()
        }
    }
}

// MARK: - AppDelegate with NSStatusItem

class AppDelegate: NSObject, NSApplicationDelegate {
    var emberMug: EmberMug!
    var bluetoothManager: BluetoothManager!
    var appState: AppState!
    private var notificationAdapter: NotificationAdapter!
    
    private var statusItem: NSStatusItem!
    private var statusWindow: StatusItemWindow!
    private var contextMenuHandler: ContextMenu!
    private var settingsWindow: NSWindow?
    
    private var cancellables = Set<AnyCancellable>()
    private var eventMonitor: Any?
    
    override init() {
        super.init()
        
        emberMug = EmberMug()
        bluetoothManager = BluetoothManager(emberMug: emberMug)
        appState = AppState()
        notificationAdapter = NotificationAdapter(appState: appState, emberMug: emberMug)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupStatusWindow()
        setupObservers()
    }
    
    // MARK: - Status Item Setup
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem.button else { return }
        
        updateStatusItemDisplay()
        
        // Use a custom view approach for handling both left and right clicks
        button.target = self
        button.action = #selector(statusItemClicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    
    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            handleRightClick()
        } else {
            handleLeftClick()
        }
    }
    
    private func handleLeftClick() {
        if statusWindow.isVisible {
            closeStatusWindow()
        } else {
            showStatusWindow()
        }
    }
    
    private func handleRightClick() {
        // Close window if open
        if statusWindow.isVisible {
            closeStatusWindow()
        }
        
        // Show context menu
        contextMenuHandler = ContextMenu(
            bluetoothManager: bluetoothManager,
            emberMug: emberMug,
            openSettings: openSettings
        )
        
        statusItem.menu = contextMenuHandler.menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }
    
    // MARK: - Status Window Setup
    
    private func setupStatusWindow() {
        let contentView = AppView()
            .environmentObject(emberMug)
            .environmentObject(appState)
            .environmentObject(bluetoothManager)
        
        statusWindow = StatusItemWindow(contentView: contentView)
    }
    
    private func showStatusWindow() {
        guard let button = statusItem.button,
              let buttonWindow = button.window else { return }
        
        // Get the button's frame in screen coordinates
        let buttonRect = button.convert(button.bounds, to: nil)
        let screenRect = buttonWindow.convertToScreen(buttonRect)
        
        // Position window centered below the button
        let windowSize = statusWindow.frame.size
        let x = screenRect.midX - (windowSize.width / 2)
        let y = screenRect.minY - windowSize.height // 4pt gap below menu bar
        
        statusWindow.setFrameOrigin(NSPoint(x: x, y: y))
        
        NSApp.activate(ignoringOtherApps: true)
        statusWindow.makeKeyAndOrderFront(nil)
        
        // Add event monitor to close window when clicking outside
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            guard let self = self else { return }
            
            // Check if click is outside the window
            if !self.statusWindow.frame.contains(NSEvent.mouseLocation) {
                self.closeStatusWindow()
            }
        }
    }
    
    private func closeStatusWindow() {
        statusWindow.orderOut(nil)
        
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    // MARK: - Observers for updating status item
    
    private func setupObservers() {
        // Observe changes to update the status item display
        emberMug.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItemDisplay()
            }
            .store(in: &cancellables)
        
        appState.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItemDisplay()
            }
            .store(in: &cancellables)
        
        bluetoothManager.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItemDisplay()
            }
            .store(in: &cancellables)
    }
    
    private func updateStatusItemDisplay() {
        guard let button = statusItem.button else { return }
        
        let iconName = getIconName()
        button.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "EmberMate")
        
        // Build the title text
        var titleText = ""
        if let countdown = appState.countdown {
            titleText = formatCountdown(countdown)
        } else if bluetoothManager.state == .connected && emberMug.liquidState != .empty {
            titleText = getFormattedTemperature(emberMug.currentTemp, unit: emberMug.temperatureUnit)
        } else if bluetoothManager.state == .connected && emberMug.liquidState == .empty && emberMug.batteryLevel != 100 && emberMug.isCharging && appState.showBatteryLevelWhenCharging {
            titleText = getFormattedBatteryLevel(emberMug.batteryLevel)
        }
        
        button.title = titleText
        button.imagePosition = titleText.isEmpty ? .imageOnly : .imageLeading
    }
    
    private func getIconName() -> String {
        if appState.countdown != nil {
            return "clock.fill"
        }
        
        if bluetoothManager.state == .reConnecting || bluetoothManager.state == .disconnected {
            return "mug"
        }
        
        if emberMug.liquidState == .empty {
            return "mug"
        }
        
        if let preset = appState.selectedPreset {
            return preset.icon
        }
        
        return "mug.fill"
    }
    
    private func formatCountdown(_ countdown: Int) -> String {
        let roundedMinutes = countdown.dividedReportingOverflow(by: 60)
        let minutes = roundedMinutes.partialValue
        
        if minutes == 0 {
            return ">1min"
        }
        return "\(minutes)min"
    }
    
    func openSettings() {
        closeStatusWindow()
        
        NSApp.activate(ignoringOtherApps: true)
        
        // If settings window already exists, just show it
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            return
        }
        
        // Create settings window
        let settingsSize = NSSize(width: 400, height: 510)
        let settingsView = SettingsView()
            .frame(width: settingsSize.width, height: settingsSize.height)
            .environmentObject(emberMug)
            .environmentObject(appState)
            .environmentObject(bluetoothManager)
        
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: settingsSize),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Settings"
        window.contentViewController = NSHostingController(rootView: settingsView)
        window.setContentSize(settingsSize)
        window.center()
        window.isReleasedWhenClosed = false
        
        self.settingsWindow = window
        window.makeKeyAndOrderFront(nil)
    }
}

// MARK: - Status Item Window

class StatusItemWindow: NSPanel {
    static let windowSize = NSSize(width: 306, height: 290)
    
    init<Content: View>(contentView: Content) {
        let size = StatusItemWindow.windowSize
        
        super.init(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // Window behavior
        self.isFloatingPanel = true
        self.level = .statusBar
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isMovableByWindowBackground = false
        self.hidesOnDeactivate = false
        
        // Make it look like a floating panel
        self.isOpaque = false
        self.backgroundColor = .clear
        
        // Host the SwiftUI view with rounded corners and background
        let hostingView = NSHostingView(rootView:
            contentView
                .frame(width: size.width, height: size.height)
                .background(VisualEffectBackground())
                .clipShape(RoundedRectangle(cornerRadius: 10))
        )
        
        self.contentView = hostingView
    }
    
    // Allow the window to become key so it can receive keyboard events
    override var canBecomeKey: Bool { true }
    
    // Close the window when it loses focus
    override func resignKey() {
        super.resignKey()
        self.orderOut(nil)
    }
}

// MARK: - Visual Effect Background

struct VisualEffectBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .popover
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
