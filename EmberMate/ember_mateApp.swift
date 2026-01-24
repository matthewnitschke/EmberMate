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
        Settings {
            SettingsView()
                .frame(width: 400, height: 510)
                .environmentObject(appDelegate.emberMug)
                .environmentObject(appDelegate.appState)
                .environmentObject(appDelegate.bluetoothManager)
        }
    }
}

// MARK: - AppDelegate with NSStatusItem

class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    var emberMug: EmberMug!
    var bluetoothManager: BluetoothManager!
    var appState: AppState!
    private var notificationAdapter: NotificationAdapter!
    
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var contextMenuHandler: ContextMenu!
    
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
        setupPopover()
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
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }
    
    private func handleRightClick() {
        // Close popover if open
        if popover.isShown {
            closePopover()
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
    
    // MARK: - Popover Setup
    
    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 320)
        popover.behavior = .transient
        popover.delegate = self
        
        let contentView = AppView()
            .environmentObject(emberMug)
            .environmentObject(appState)
            .environmentObject(bluetoothManager)
        
        popover.contentViewController = NSHostingController(rootView: contentView)
    }
    
    private func showPopover() {
        guard let button = statusItem.button else { return }
        
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        
        // Add event monitor to close popover when clicking outside
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.closePopover()
        }
    }
    
    private func closePopover() {
        popover.performClose(nil)
        
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    // MARK: - NSPopoverDelegate
    
    func popoverDidClose(_ notification: Notification) {
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
    
    private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}
