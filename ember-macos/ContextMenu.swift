//
//  Test.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 12/5/23.
//

import Foundation

import Cocoa
import UserNotifications

class ContextMenu: NSObject, NSMenuDelegate {

    let menu = NSMenu()
    
    private var bluetoothManager: BluetoothManager
    private var emberMug: EmberMug
    
    init(bluetoothManager: BluetoothManager, emberMug: EmberMug) {
        self.bluetoothManager = bluetoothManager
        self.emberMug = emberMug
        
        super.init()
        
        if (bluetoothManager.isConnected) {            
            let batteryItem = NSMenuItem(title: "\(emberMug.batteryLevel)% - \(emberMug.peripheral?.name ?? "Unknown Device")", action: nil, keyEquivalent: "")
            let icon = getBatteryIcon(emberMug.batteryLevel, isCharging: emberMug.isCharging)
            batteryItem.image = NSImage(systemSymbolName: icon, accessibilityDescription: nil)
            menu.addItem(batteryItem)
            
            let disconnectMenuItem = NSMenuItem(title: "Disconnect", action: #selector(disconnectClicked(_:)), keyEquivalent: "")
            disconnectMenuItem.target = self
            menu.addItem(disconnectMenuItem)
            menu.addItem(NSMenuItem.separator())
        }
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.shared.terminate(_:)), keyEquivalent: ""))

        // Set the menu delegate
        menu.delegate = self
    }

    @objc open func disconnectClicked(_ sender: NSMenuItem) {
        bluetoothManager.disconnect()
    }
}
