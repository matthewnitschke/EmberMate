//
//  NotificationAdapter.swift
//  EmberMate
//
//  Created by Matthew Nitschke on 12/16/23.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

class NotificationAdapter {
    private var appState: AppState
    private var emberMug: EmberMug

    private var cancellables: Set<AnyCancellable> = []

    private var previousLiquidState: LiquidState?
    private var lastNotifiedTemp: Double?

    private var wasLowBattery: Bool = false
    
    init(appState: AppState, emberMug: EmberMug) {
        self.appState = appState
        self.emberMug = emberMug

        Publishers.CombineLatest(
            self.emberMug.$liquidState.dropFirst(),
            self.emberMug.$targetTemp.dropFirst()
        ).sink { (newState, newTemp) in
            if (newState == .stableTemperature && newTemp != self.lastNotifiedTemp) {
                self.notifyTemperatureReached()
                self.lastNotifiedTemp = newTemp
            } else if (self.previousLiquidState == .empty && newState == .filling) {
                self.lastNotifiedTemp = nil
            }
            
            self.previousLiquidState = newState
        }
        .store(in: &cancellables)

        self.emberMug.$batteryLevel
            .dropFirst()
            .sink { newData in
                if newData <= appState.notifyOnLowBattery.rawValue {
                    if !self.wasLowBattery && !self.emberMug.isCharging {
                        self.notifyLowBattery()
                    }
                    self.wasLowBattery = true
                } else {
                    self.wasLowBattery = false
                }
            }
            .store(in: &cancellables)
    }


    func notifyTemperatureReached() {
        if (!appState.notifyOnTemperatureReached) {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Target Temperature Reached"
        content.subtitle = "Your beverage is now \(getFormattedTemperature(emberMug.targetTemp, unit: emberMug.temperatureUnit))"
        content.sound = UNNotificationSound.default
        content.userInfo = ["icon": "AppIcon"]

        let request = UNNotificationRequest(identifier: "tempReached", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func notifyLowBattery() {
        if appState.notifyOnLowBattery == .off {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Mug has low battery"
        content.subtitle = "Your mug has reached \(appState.notifyOnLowBattery) battery level. Charge to prevent the heater turning off"
        content.sound = UNNotificationSound.default
        content.userInfo = ["icon": "AppIcon"]

        let request = UNNotificationRequest(identifier: "lowBattery", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
