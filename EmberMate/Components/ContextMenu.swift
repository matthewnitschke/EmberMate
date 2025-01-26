//
//  Test.swift
//  EmberMate
//
//  Created by Matthew Nitschke on 12/5/23.
//

import Foundation

import Cocoa
import UserNotifications
import SwiftUICore
import SwiftUI

class ContextMenu: NSObject, NSMenuDelegate {
    let menu = NSMenu()

    private var bluetoothManager: BluetoothManager
    private var emberMug: EmberMug
    private var openSettings: () -> Void

    init(bluetoothManager: BluetoothManager, emberMug: EmberMug, openSettings: @escaping () -> Void) {
        self.bluetoothManager = bluetoothManager
        self.emberMug = emberMug
        self.openSettings = openSettings

        super.init()

        let preferencesMenuItem = NSMenuItem(title: "Preferences", action: #selector(preferencesClicked(_:)), keyEquivalent: "")
        preferencesMenuItem.target = self
        menu.addItem(preferencesMenuItem)

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.shared.terminate(_:)), keyEquivalent: ""))

        // Set the menu delegate
        menu.delegate = self
    }

    @objc open func preferencesClicked(_ sender: NSMenuItem) {
        self.openSettings()
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc open func disconnectClicked(_ sender: NSMenuItem) {
        bluetoothManager.disconnect()
    }
}
