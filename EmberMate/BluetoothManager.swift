//
//  BluetoothManager.swift
//  EmberMate
//
//  Created by Matthew Nitschke on 11/28/23.
//

import CoreBluetooth

enum ConnectionState {
    // there is a mug currently connected
    case connected

    // we are actively looking for a mug
    case connecting

    // a mug was previouslly connected, but then
    // was disconnected and we are searching for it
    case reConnecting

    // there is no mug connected
    case disconnected
}

class BluetoothManager: NSObject, ObservableObject {
    private var centralManager: CBCentralManager?
    @Published var peripherals: [CBPeripheral] = []

    @Published var state: ConnectionState = .disconnected

    var emberMug: EmberMug

    private var peripheralIdentifier: UUID?

    init(emberMug: EmberMug) {
        self.emberMug = emberMug
        super.init()

        let existingIdentifier = UserDefaults.standard.string(forKey: "peripheralIdentifier")
        if let existingIdentifier = existingIdentifier {
            self.peripheralIdentifier = UUID(uuidString: existingIdentifier)
        }

        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    func connect(peripheral: CBPeripheral) {
        state = .connecting
        UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: "peripheralIdentifier")
        peripheral.delegate = emberMug
        self.centralManager!.connect(peripheral)
    }

    @objc func disconnect() {
        self.centralManager!.cancelPeripheralConnection(emberMug.peripheral!)
        UserDefaults.standard.removeObject(forKey: "peripheralIdentifier")
        state = .disconnected
    }
}

extension BluetoothManager: CBCentralManagerDelegate {


    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {

            var peripheralFound = false

            // Try to reconnect to the known device
            if let peripheralIdentifier = peripheralIdentifier {
                let peripherals = centralManager!.retrievePeripherals(withIdentifiers: [peripheralIdentifier])
                if let peripheral = peripherals.first {
                    peripheralFound = true
                    self.peripherals.append(peripheral)
                    peripheral.delegate = emberMug
                    centralManager!.connect(peripheral, options: nil)
                } else {
                    print("Peripheral not found. Make sure the device is nearby and powered on.")
                }
            } else {
                print("No stored peripheral identifier. Connect to the device for the first time.")
            }

            if (!peripheralFound) {
                self.centralManager!.scanForPeripherals(
                    withServices: [CBUUID(string: "fc543622-236c-4c94-8fa9-944a3e5353fa")]
                )
            }
        }
    }

    // initial device discovery, this will be any ember devices
    // around the device that is scanning
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        if !peripherals.contains(peripheral) {
            self.peripherals.append(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("ERROR")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        state = .connected

        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // only try to re-connect if we were connected
        // eg: dont re-connect to a device that was just explicitly disconnected
        if state == .connected {
            state = .reConnecting
            centralManager!.connect(emberMug.peripheral!, options: nil)
        }
    }
}
