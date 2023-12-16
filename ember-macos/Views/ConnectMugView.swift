//
//  ConnectMugView.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 12/4/23.
//

import Foundation
import SwiftUI
import CoreBluetooth

struct ConnectMugView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @State private var selectedMug: CBPeripheral?

    var body: some View {
        VStack {
            Text("Select a Mug")
                .font(.title).padding(.top)
            List(
                bluetoothManager.peripherals,
                id: \.self,
                selection: $selectedMug
            ) { peripheral in
                Text(peripheral.name ?? "Unknown Device")
            }
            if let selectedMug = selectedMug {
                
                if (bluetoothManager.isConnecting) {
                    ProgressView()
                } else {
                    Button("Connect") {
                        bluetoothManager.connect(peripheral: selectedMug)
                    }
                }
            }
        }.padding(8)
    }
}

