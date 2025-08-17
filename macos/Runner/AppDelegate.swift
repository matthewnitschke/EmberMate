import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate, NSWindowDelegate {
  private var statusItem: NSStatusItem?
  private var popover: NSPopover?
  private var eventMonitor: Any?
  private var methodChannel: FlutterMethodChannel?
  private var settingsWindow: NSWindow?
  private var settingsViewController: FlutterViewController?
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Create the status item in the menu bar
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    if let button = statusItem?.button {
      // Create a simple text-based icon since systemSymbolName requires macOS 11.0+
      button.title = "☕"
      button.action = #selector(togglePopover)
      button.target = self
      
      // Enable right-click menu
      button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    
    // Create the popover
    popover = NSPopover()
    popover?.contentSize = NSSize(width: 400, height: 600)
    popover?.behavior = .transient
    popover?.contentViewController = FlutterViewController()
    
    // Register the Flutter plugins
    if let flutterViewController = popover?.contentViewController as? FlutterViewController {
      RegisterGeneratedPlugins(registry: flutterViewController)
      
      // Set up method channel for menubar icon updates
      methodChannel = FlutterMethodChannel(name: "ember_mate/menubar", binaryMessenger: flutterViewController.engine.binaryMessenger)
      methodChannel?.setMethodCallHandler { [weak self] (call, result) in
        self?.handleMethodCall(call, result: result)
      }
    }
    
    // Monitor events to close popover when clicking outside
    eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
      if let strongSelf = self, strongSelf.popover?.isShown == true {
        strongSelf.closePopover()
      }
    }
    
    super.applicationDidFinishLaunching(notification)
  }
  
  @objc func togglePopover() {
    let event = NSApp.currentEvent
    
    // Check if it's a right-click
    if event?.type == .rightMouseUp {
      showContextMenu()
    } else {
      // Left click - toggle popover
      if popover?.isShown == true {
        closePopover()
      } else {
        showPopover()
      }
    }
  }
  
  func showPopover() {
    if let button = statusItem?.button {
      popover?.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
    }
  }
  
  func showContextMenu() {
    let menu = NSMenu()
    
    // Settings menu item
    let settingsItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: "")
    settingsItem.target = self
    menu.addItem(settingsItem)
    
    // Separator
    menu.addItem(NSMenuItem.separator())
    
    // Quit menu item
    let quitItem = NSMenuItem(title: "Quit EmberMate", action: #selector(quitApplication), keyEquivalent: "q")
    quitItem.target = self
    menu.addItem(quitItem)
    
    // Show the menu using the modern API
    if let button = statusItem?.button {
      menu.popUp(positioning: nil, at: NSPoint.zero, in: button)
    }
  }
  
  func closePopover() {
    popover?.performClose(nil)
  }
  
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false // Don't terminate when window is closed since we're a menubar app
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "updateIcon":
      if let args = call.arguments as? [String: Any] {
        updateMenubarIcon(with: args)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  func updateMenubarIcon(with data: [String: Any]) {
    guard let button = statusItem?.button else { return }
    
    let currentTemp = data["currentTemp"] as? Double ?? 0.0
    let targetTemp = data["targetTemp"] as? Double ?? 0.0
    let batteryLevel = data["batteryLevel"] as? Int ?? 0
    let isCharging = data["isCharging"] as? Bool ?? false
    let liquidState = data["liquidState"] as? String ?? "empty"
    
    // Determine what to show in the menubar
    if currentTemp > 0 {
      // Show temperature if we have a reading
      let tempString = data["temperature"] as? String ?? "☕"
      button.title = tempString
    } else if batteryLevel > 0 {
      // Show battery level if no temperature but we have battery info
      let batteryIcon = isCharging ? "🔌" : "🔋"
      button.title = "\(batteryIcon)\(batteryLevel)%"
    } else {
      // Default coffee cup
      button.title = "☕"
    }
    
    // Create detailed tooltip
    var tooltip = "EmberMate"
    
    if currentTemp > 0 {
      tooltip += "\nCurrent: \(String(format: "%.1f", currentTemp))°"
    }
    
    if targetTemp > 0 {
      tooltip += "\nTarget: \(String(format: "%.1f", targetTemp))°"
    }
    
    if batteryLevel > 0 {
      let chargingStatus = isCharging ? " (Charging)" : ""
      tooltip += "\nBattery: \(batteryLevel)%\(chargingStatus)"
    }
    
    if liquidState != "empty" {
      tooltip += "\nState: \(liquidState.capitalized)"
    }
    
    button.toolTip = tooltip
  }
  
  @objc func openSettings() {
    if settingsWindow == nil {
      createSettingsWindow()
    }
    
    settingsWindow?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
  
  func createSettingsWindow() {
    // Create the Flutter view controller for settings
    settingsViewController = FlutterViewController()
    
    // Register plugins for the settings window
    if let settingsVC = settingsViewController {
      RegisterGeneratedPlugins(registry: settingsVC)
      
      // Set up method channel for settings
      let settingsChannel = FlutterMethodChannel(name: "ember_mate/settings", binaryMessenger: settingsVC.engine.binaryMessenger)
      settingsChannel.setMethodCallHandler { [weak self] (call, result) in
        switch call.method {
        case "closeSettings":
          self?.closeSettingsWindow()
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
    
    // Create the window
    settingsWindow = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
      styleMask: [.titled, .closable, .miniaturizable, .resizable],
      backing: .buffered,
      defer: false
    )
    
    settingsWindow?.title = "EmberMate Settings"
    settingsWindow?.contentViewController = settingsViewController
    settingsWindow?.center()
    settingsWindow?.isReleasedWhenClosed = false
    
    // Set up window delegate to handle window closing
    settingsWindow?.delegate = self
  }
  
  func closeSettingsWindow() {
    settingsWindow?.close()
  }
  
  // MARK: - NSWindowDelegate
  
  func windowWillClose(_ notification: Notification) {
    if let window = notification.object as? NSWindow, window == settingsWindow {
      settingsWindow = nil
      settingsViewController = nil
    }
  }
  
  @objc func quitApplication() {
    NSApplication.shared.terminate(nil)
  }
  
  deinit {
    if let eventMonitor = eventMonitor {
      NSEvent.removeMonitor(eventMonitor)
    }
  }
}
