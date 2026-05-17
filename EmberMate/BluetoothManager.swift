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
    private var recentlySeen: Set<CBPeripheral> = []
    private var staleTimer: Timer?

    init(emberMug: EmberMug) {
        self.emberMug = emberMug
        super.init()

        let existingIdentifier = UserDefaults.standard.string(forKey: "peripheralIdentifier")
        if let existingIdentifier = existingIdentifier {
            self.peripheralIdentifier = UUID(uuidString: existingIdentifier)
        }

        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    private func sortPeripherals() {
        peripherals.sort { lhs, rhs in
            let lhsName = lhs.name ?? ""
            let rhsName = rhs.name ?? ""
            if lhsName != rhsName { return lhsName < rhsName }
            return lhs.identifier.uuidString < rhs.identifier.uuidString
        }
    }

    func stopScanning() {
        centralManager?.stopScan()
        staleTimer?.invalidate()
        staleTimer = nil
    }

    func startScanning() {
        centralManager?.scanForPeripherals(
            withServices: [CBUUID(string: "fc543622-236c-4c94-8fa9-944a3e5353fa")],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )

        staleTimer?.invalidate()
        staleTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            guard let self else { return }
            var seen = self.recentlySeen
            self.recentlySeen.removeAll()
            if let connected = self.emberMug.peripheral, !seen.contains(connected) {
                seen.insert(connected)
            }
            self.peripherals = Array(seen)
            sortPeripherals()
        }
    }

    func connect(peripheral: CBPeripheral) {
        state = .connecting
        UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: "peripheralIdentifier")
        peripheral.delegate = emberMug
        self.centralManager!.connect(peripheral)
        startScanning()
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
            // Try to reconnect to a known device
            if let peripheralIdentifier = peripheralIdentifier {
                let peripherals = centralManager!.retrievePeripherals(withIdentifiers: [peripheralIdentifier])
                if let peripheral = peripherals.first {
                    self.peripherals.append(peripheral)
                    peripheral.delegate = emberMug
                    centralManager!.connect(peripheral, options: nil)
                } else {
                    print("Peripheral not found. Make sure the device is nearby and powered on.")
                }
            } else {
                print("No stored peripheral identifier. Connect to the device for the first time.")
            }

            startScanning()
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        recentlySeen.insert(peripheral)
        if !peripherals.contains(peripheral) {
            self.peripherals.append(peripheral)
            sortPeripherals()
        }
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("ERROR")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        state = .connected
        stopScanning()
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // only try to re-connect if we were connected
        // eg: dont re-connect to a device that was just explicitly disconnected
        if state == .connected {
            state = .reConnecting
            centralManager!.connect(emberMug.peripheral!, options: nil)
        }

        startScanning()
    }
}
