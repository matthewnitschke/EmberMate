//
//  EmberMug.swift
//  EmberMate
//
//  Created by Matthew Nitschke on 12/2/23.
//

import Foundation
import CoreBluetooth
import Combine
import SwiftUI

enum LiquidState: Int {
    case empty = 1
    case filling = 2
    case cooling = 4
    case heating = 5
    case stableTemperature = 6
}

enum TemperatureUnit: Int {
    case celcius = 0
    case fahrenheit = 1
}

class EmberMug: NSObject, ObservableObject, CBPeripheralDelegate {
    @Published var batteryLevel: Int = 0 // 5 - 100
    @Published var isCharging: Bool = false
    @Published var currentTemp: Double = 0.0
    @Published var targetTemp: Double = 0.0
    @Published var liquidState: LiquidState = LiquidState.empty
    @Published var temperatureUnit: TemperatureUnit = TemperatureUnit.celcius
    @Published var color: Color = Color.white

    var peripheral: CBPeripheral?

    private var targetTempCharacteristic: CBCharacteristic?
    private var currentTempCharacteristic: CBCharacteristic?
    private var batteryCharacteristic: CBCharacteristic?
    private var liquidStateCharacteristic: CBCharacteristic?
    private var temperatureUnitCharacteristic: CBCharacteristic?
    private var colorCharacteristic: CBCharacteristic?

    private var cancellables: Set<AnyCancellable> = []

    override init() {
        super.init()

        self.$temperatureUnit
            .sink { newData in
                if (newData != self.temperatureUnit) {
                    self.setTemperatureUnit(newData)
                }
            }
            .store(in: &cancellables)
        
        self.$color
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { newData in
                self.setColor(newData)
            }
            .store(in: &cancellables)
    }


    func setTargetTemp(temp: Double) {
        // add an artifical limit, to mirror the app
        // I'm unsure if this is a requirement, but I
        // dont want to have people accidentially breaking their mugs
        if (temp < 50 || temp > 63) { return }

        self.targetTemp = temp

        let uintVal = UInt16(temp * 100)
        let byte1 = UInt8(uintVal & 0xFF)
        let byte2 = UInt8((uintVal >> 8) & 0xFF)

        let data = Data([byte1, byte2])
        peripheral?.writeValue(data, for: targetTempCharacteristic!, type: .withResponse)
    }

    func setTemperatureUnit(_ unit: TemperatureUnit) {
        let data = Data([UInt8(unit.rawValue)])
        peripheral?.writeValue(data, for: temperatureUnitCharacteristic!, type: .withResponse)
    }
    
    func setColor(_ color: Color) {
        let parts = NSColor(color).cgColor.components!
        let red = UInt8(parts[0] * 255)
        let green = UInt8(parts[1] * 255)
        let blue = UInt8(parts[2] * 255)
        let alpha = UInt8(parts[3] * 255)
        peripheral?.writeValue(Data([red, green, blue, alpha]), for: colorCharacteristic!, type: .withResponse)
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
            case CBUUID(string: "fc540004-236c-4c94-8fa9-944a3e5353fa"):
                temperatureUnitCharacteristic = characteristic
            case CBUUID(string: "fc540014-236c-4c94-8fa9-944a3e5353fa"):
                colorCharacteristic = characteristic
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
                targetTemp = Double(temp) * 0.01
            } else if (characteristic == currentTempCharacteristic) {
                let temp = data.extractUInt16()
                currentTemp = Double(temp) * 0.01
            } else if characteristic == batteryCharacteristic {
                batteryLevel = Int(data[0])
                isCharging = Int(data[1]) == 1
            } else if (characteristic == liquidStateCharacteristic) {
                if let state = LiquidState(rawValue: Int(data[0])) {
                    liquidState = state
                }
            } else if (characteristic == temperatureUnitCharacteristic) {
                if let unit = TemperatureUnit(rawValue: Int(data[0])) {
                    temperatureUnit = unit
                }
            } else if (characteristic == colorCharacteristic) {
                let red = Double(data[0])
                let green = Double(data[1])
                let blue = Double(data[2])
                let alpha = Double(data[3])
                color = Color(red: red/255, green: green/255, blue: blue/255, opacity: alpha/255)
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
