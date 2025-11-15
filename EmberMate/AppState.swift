//
//  AppState.swift
//  EmberMate
//
//  Created by Matthew Nitschke on 12/10/23.
//

import SwiftUI
import Foundation
import Combine
import UserNotifications

class AppState: ObservableObject {
    var timer: Timer?

    @Published var selectedPreset: Preset?
    @Published var countdown: Int?
    
    @AppStorage("timers") var timers: [String] = ["4:00", "5:00", "6:00"]
    @AppStorage("presets") var presets: [Preset] = [
        Preset(
            icon: "cup.and.saucer.fill",
            name: "Latte",
            temperature: 52.0
        ),
        Preset(
            icon: "mug.fill",
            name: "Coffee",
            temperature: 55.0
        ),
        Preset(
            icon: "leaf.fill",
            name: "Tea",
            temperature: 60.0
        )
    ]

    @Published var notificationsDisabled = false
    
    @AppStorage("notifyOnTemperatureReached") var notifyOnTemperatureReached: Bool = true
    @AppStorage("notifyAtBatteryPercentage") var notifyAtBatteryPercentage: LowBatteryLevel = .default
    @AppStorage("showBatteryLevelWhenCharging") var showBatteryLevelWhenCharging: Bool = false
    
    @AppStorage("automaticallyCheckForUpdates") var automaticallyCheckForUpdates: Bool = true
    
    
    private var cancellables: Set<AnyCancellable> = []

    init() {
        Task { @MainActor in
            migrateUserDefaults()
            await requestNotificationAuthorization(provisional: true)
            await updateNotificationsDisabled()
        }
    }
    
    @MainActor
    func migrateUserDefaults() {
        if let oldValue = UserDefaults.standard.object(forKey: "notifyOnLowBattery") as? Bool {
            self.notifyAtBatteryPercentage = oldValue ? .default : .off
            UserDefaults.standard.removeObject(forKey: "notifyOnLowBattery")
        }
    }
    
    @MainActor
    func updateNotificationsDisabled() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        self.notificationsDisabled = settings.authorizationStatus == .denied
    }

    @MainActor
    private func requestNotificationAuthorization(provisional: Bool) async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        
        guard settings.authorizationStatus == .notDetermined
            || !provisional && settings.authorizationStatus == .provisional
        else {
            return
        }
        
        do {
            var options: UNAuthorizationOptions = [.alert, .sound]
            if provisional {
                options.insert(.provisional)
            }
            
            let authorized = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: options)
            
            print("Notifications \(authorized ? "" : "not ")authorized")
        } catch {
            print("Notifications not authorized: \(error)")
        }
    }
    
    func startTimer(_ time: Int) {
        timer?.invalidate()
        
        Task { @MainActor in
            await requestNotificationAuthorization(provisional: false)
        }
        
        self.countdown = time
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            self.countdown! -= 1
            if self.countdown! == 0 {
                self.stopTimer()

                let content = UNMutableNotificationContent()
                content.title = "Ember Timer Complete"
                content.subtitle = "Your timer is complete"
                content.sound = UNNotificationSound.default
                content.userInfo = ["icon": "AppIcon"]

                let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        countdown = nil
    }
}

class Preset: Identifiable, ObservableObject, Codable {
    var id = UUID().uuidString
    @Published var icon: String = "mug.fill"
    @Published var name: String = "Coffee"
    @Published var temperature: Double = 55.0

    private enum CodingKeys: String, CodingKey {
        case id
        case icon
        case name
        case temperature
    }

    init(
        icon: String = "mug.fill",
        name: String = "Coffee",
        temperature: Double = 55.0
    ) {
        self.icon = icon
        self.name = name
        self.temperature = temperature
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        icon = try container.decode(String.self, forKey: .icon)
        name = try container.decode(String.self, forKey: .name)
        temperature = try container.decode(Double.self, forKey: .temperature)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(icon, forKey: .icon)
        try container.encode(name, forKey: .name)
        try container.encode(temperature, forKey: .temperature)
    }
}

extension AppState {
    enum LowBatteryLevel: Int, CaseIterable, CustomStringConvertible {
        static let `default` = LowBatteryLevel.fifteen
        
        case off     = 0
        case five    = 5
        case ten     = 10
        case fifteen = 15
        case twenty  = 20
        
        init?(rawValue: Int) {
            switch rawValue {
            case 0: self = .off
            case 5: self = .five
            case 10: self = .ten
            case 15: self = .fifteen
            case 20: self = .twenty
            default: self = LowBatteryLevel.default
            }
        }
        
        var description: String {
            if self == .off {
                return "Off"
            }
            
            return getFormattedBatteryLevel(self.rawValue)
        }
    }
}
