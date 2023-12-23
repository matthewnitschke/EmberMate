//
//  AppView.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 12/3/23.
//

import Foundation
import SwiftUI

struct AppView: View {
    @ObservedObject var emberMug: EmberMug
    var appState: AppState
    @ObservedObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        switch bluetoothManager.state {
        case .connected: MugControlView(emberMug: emberMug, appState: appState)
        case .disconnected, .connecting: ConnectMugView(bluetoothManager: bluetoothManager)
        case .reConnecting: Text("Device Disconnected. Searching...").padding()
        }
    }
}
