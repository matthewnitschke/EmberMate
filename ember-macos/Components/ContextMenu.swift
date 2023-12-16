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
        
        let preferencesMenuItem = NSMenuItem(title: "Preferences", action: #selector(preferencesClicked(_:)), keyEquivalent: "")
        preferencesMenuItem.target = self
        menu.addItem(preferencesMenuItem)
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.shared.terminate(_:)), keyEquivalent: ""))

        // Set the menu delegate
        menu.delegate = self
    }
    
    @objc open func preferencesClicked(_ sender: NSMenuItem) {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }

    @objc open func disconnectClicked(_ sender: NSMenuItem) {
        bluetoothManager.disconnect()
    }
}
