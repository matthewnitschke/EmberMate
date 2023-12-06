//
//  BluetoothManager.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 11/28/23.
//

import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject {
    private var centralManager: CBCentralManager?
    @Published var peripherals: [CBPeripheral] = []
    
    @Published var isConnected = false
    @Published var isConnecting = false
    
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
        isConnecting = true
        peripheral.delegate = emberMug
        self.centralManager!.connect(peripheral)
    }
    
    @objc func disconnect() {
        self.centralManager!.cancelPeripheralConnection(emberMug.peripheral!)
        UserDefaults.standard.removeObject(forKey: "peripheralIdentifier")
        isConnected = false
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
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            self.peripherals.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("ERROR")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnecting = false
        isConnected = true
        UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: "peripheralIdentifier")
        peripheral.discoverServices(nil)
    }
}
