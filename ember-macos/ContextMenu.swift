//
//  Test.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 12/5/23.
//

import Foundation

import Cocoa

class ContextMenu: NSObject, NSMenuDelegate {

    let menu = NSMenu()
    
    private var bluetoothManager: BluetoothManager

    init(bluetoothManager: BluetoothManager) {
        self.bluetoothManager = bluetoothManager
        super.init()
        
        if (bluetoothManager.isConnected) {
            let disconnectMenuItem = NSMenuItem(title: "Disconnect", action: #selector(disconnectClicked(_:)), keyEquivalent: "")
            disconnectMenuItem.target = self
            menu.addItem(disconnectMenuItem)
            menu.addItem(NSMenuItem.separator())
        }

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.shared.terminate(_:)), keyEquivalent: ""))

        // Set the menu delegate
        menu.delegate = self
    }

    // Menu item action methods
    @objc open func disconnectClicked(_ sender: NSMenuItem) {
        bluetoothManager.disconnect()
    }
}
