import SwiftUI

struct MugSettingsView: View {
    @EnvironmentObject private var emberMug: EmberMug
    @EnvironmentObject private var bluetoothManager: BluetoothManager

    @State private var showMugPicker = false

    var body: some View {
        Form {
            Section {
                HStack {
                    if (bluetoothManager.state == .disconnected) {
                        Image(systemName: "mug")
                            .font(.largeTitle)
                        Text("No Device Connected")
                    } else {
                        Image(systemName: "mug.fill")
                            .font(.largeTitle)
                        VStack(alignment: .leading) {
                            Text(emberMug.peripheral?.name ?? "Unknown Device")
                            BatteryView(
                                display: .both,
                                batteryLevel: emberMug.batteryLevel,
                                isCharging: emberMug.isCharging
                            ).foregroundColor(.gray)
                        }
                        Spacer()
                        Button("Disconnect") {
                            bluetoothManager.disconnect()
                        }
                    }
                }

                if (bluetoothManager.state == .connected) {
                    Picker("Measurement Unit", selection: $emberMug.temperatureUnit) {
                        Text("℉").tag(TemperatureUnit.fahrenheit)
                        Text("℃").tag(TemperatureUnit.celcius)
                    }
                    ColorPicker("LED Color", selection: $emberMug.color)
                }
            } footer: {
                HStack {
                    Spacer()
                    Button("+") {
                        showMugPicker = true
                    }
                    .popover(isPresented: $showMugPicker, arrowEdge: .trailing) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Available Mugs")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.top, 8)
                                .padding(.bottom, 4)

                            Divider()

                            HStack {
                                Spacer()
                                ProgressView("Searching...")
                                    .scaleEffect(0.8)
                                Spacer()
                            }

                            List {
                                ForEach(bluetoothManager.peripherals.filter { $0 != emberMug.peripheral }, id: \.identifier) { peripheral in
                                    Button {
                                        print(peripheral.name ?? "Unknown")
                                    } label: {
                                        HStack {
                                            Image(systemName: "mug.fill")
                                                .foregroundColor(.secondary)
                                            Text(peripheral.name ?? "Unknown")
                                            Spacer()
                                        }
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                            .listStyle(.plain)
                            .frame(width: 220, height: 140)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .onChange(of: showMugPicker) { showing in
            if showing {
                bluetoothManager.startScanning()
            } else {
                bluetoothManager.stopScanning()
            }
        }
    }
}
