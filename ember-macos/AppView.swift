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
    @ObservedObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        if bluetoothManager.isConnected {
            MugControlView(emberMug: emberMug)
        } else {
            ConnectMugView(bluetoothManager: bluetoothManager)
        }
    }
}
