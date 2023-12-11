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
        if bluetoothManager.isConnected {
            MugControlView(emberMug: emberMug, appState: appState)
        } else {
            ConnectMugView(bluetoothManager: bluetoothManager)
        }
    }
}
