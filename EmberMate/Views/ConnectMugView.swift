//
//  ConnectMugView.swift
//  EmberMate
//
//  Created by Matthew Nitschke on 12/4/23.
//

import Foundation
import SwiftUI
import CoreBluetooth

struct ConnectMugView: View {
    @EnvironmentObject private var bluetoothManager: BluetoothManager
    @State private var selectedMug: CBPeripheral?

    var body: some View {
        VStack {
            Text("Connect a Device")
                .fontWeight(.medium)
                .font(.largeTitle)

            SelectDeviceView()

            Text("Press and hold the power button on the mug to enter connection mode")
                .font(.caption).italic()
        }.padding(20).frame(width: 350)
        .background(LinearGradient(
            colors: [getColor(234, 182, 125), getColor(186, 102, 56)],
            startPoint: .top,
            endPoint: .bottom
        ))
        .environment(\.colorScheme, .dark) // Ignore OS level light mode, UI is designed for "dark" mode
    }
}

struct SelectDeviceView: View {
    @EnvironmentObject private var bluetoothManager: BluetoothManager
    @State private var selectedMug: CBPeripheral?

    var body: some View {
        HStack {
            ForEach(bluetoothManager.peripherals, id: \.self) { peripheral in
                Button(action: {
                    if selectedMug == nil {
                        selectedMug = peripheral
                        bluetoothManager.connect(peripheral: selectedMug!)
                    }
                }) {
                    VStack {
                        Spacer()

                        if selectedMug == peripheral {
                            ProgressView()
                        } else {
                            Image(systemName: "mug")
                                .font(.largeTitle)
                        }

                        Spacer()

                        Text(peripheral.name ?? "Unknown Device")
                            .font(.caption)
                    }
                    .padding(10)
                    .frame(width: 90, height: 90)
                    .background(Color.black.opacity(0.29))
                }
                .buttonStyle(.plain)
                .cornerRadius(9)
                }
            
        }
        
        HStack(spacing: 1) {
            ProgressView()
                .scaleEffect(0.5)
                .frame(height: 10)
            Text("Searching")
                .font(.caption2)
        }
        .padding(.top, 4)
    }
}
