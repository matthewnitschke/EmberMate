//
//  NotificationAdapter.swift
//  ember-macos
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
    private var shouldNotifyOnStable: Bool = false
    
    init(appState: AppState, emberMug: EmberMug) {
        self.appState = appState
        self.emberMug = emberMug
        
        self.emberMug.$liquidState
            .sink { newData in
                if (self.shouldNotifyOnStable && newData == .stableTemperature) {
                    self.shouldNotifyOnStable = false
                    self.notifyTemperatureReached()
                } else if (self.previousLiquidState == .empty && newData == .filling) {
                    self.shouldNotifyOnStable = true
                }
                
                self.previousLiquidState = newData
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
        
        let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
