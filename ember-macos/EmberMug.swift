//
//  EmberMug.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 12/2/23.
//

import Foundation
import CoreBluetooth

enum LiquidState: Int {
    case empty = 1
    case filling = 2
    case cooling = 4
    case heating = 5
    case stableTemperature = 6
}

class EmberMug: NSObject, ObservableObject, CBPeripheralDelegate {
    @Published var batteryLevel: Int = 0
    @Published var isCharging: Bool = false
    @Published var currentTemp: Float = 0.0
    @Published var targetTemp: Float = 0.0
    @Published var liquidState: LiquidState = LiquidState.empty
    
    private var peripheral: CBPeripheral?
    private var targetTempCharacteristic: CBCharacteristic?
    private var currentTempCharacteristic: CBCharacteristic?
    private var batteryCharacteristic: CBCharacteristic?
    private var liquidStateCharacteristic: CBCharacteristic?
    
    func setTargetTemp(temp: Float) {
        self.targetTemp = temp
        
        let uintVal = UInt16(temp * 100)
        let byte1 = UInt8(uintVal & 0xFF)
        let byte2 = UInt8((uintVal >> 8) & 0xFF)
        
        let data = Data([byte1, byte2])
        peripheral?.writeValue(data, for: targetTempCharacteristic!, type: .withResponse)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        self.peripheral = peripheral
        for service: CBService in peripheral.services! {
            // only discover characteristics for main ember mug service
            if service.uuid == CBUUID(string: "FC543622-236C-4C94-8FA9-944A3E5353FA") {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic: CBCharacteristic in service.characteristics! {
            
            switch characteristic.uuid {
            case CBUUID(string: "fc540003-236c-4c94-8fa9-944a3e5353fa"):
                targetTempCharacteristic = characteristic
            case CBUUID(string: "fc540002-236c-4c94-8fa9-944a3e5353fa"):
                currentTempCharacteristic = characteristic
            case CBUUID(string: "fc540007-236c-4c94-8fa9-944a3e5353fa"):
                batteryCharacteristic = characteristic
            case CBUUID(string: "fc540008-236c-4c94-8fa9-944a3e5353fa"):
                liquidStateCharacteristic = characteristic
            case CBUUID(string: "fc540012-236c-4c94-8fa9-944a3e5353fa"):
                // enable notifications for the event characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            default:
                print("Unregistered characteristic \(characteristic.uuid)")
            }
            
            // read the initial value
            // TODO: probably only do this if its a value we care about
            peripheral.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let data = characteristic.value
        
        if let data = data {
            if characteristic == targetTempCharacteristic {
                let temp = data.extractUInt16()
                targetTemp = Float(temp) * 0.01
            } else if (characteristic == currentTempCharacteristic) {
                let temp = data.extractUInt16()
                currentTemp = Float(temp) * 0.01
            } else if characteristic == batteryCharacteristic {
                batteryLevel = Int(data[0])
                isCharging = Int(data[1]) == 1
            } else if (characteristic == liquidStateCharacteristic) {
                if let state = LiquidState(rawValue: Int(data[0])) {
                    liquidState = state
                }
            } else if (characteristic.uuid == CBUUID(string: "fc540012-236c-4c94-8fa9-944a3e5353fa")) {
                let state = Int(data[0])
                
                if (state == 1) {
                    peripheral.readValue(for: batteryCharacteristic!)
                } else if (state == 2) {
                    isCharging = true
                } else if (state == 3) {
                    isCharging = false
                } else if (state == 4) {
                    peripheral.readValue(for: targetTempCharacteristic!)
                } else if (state == 5) {
                    peripheral.readValue(for: currentTempCharacteristic!)
                } else if (state == 8) {
                    peripheral.readValue(for: liquidStateCharacteristic!)
                }
                
            }
        }
    }
}

extension Data {
    func extractUInt16() -> UInt16 {
        var value: UInt16 = 0
        (self as NSData).getBytes(&value, length: MemoryLayout<UInt16>.size)
        return value
    }
}
