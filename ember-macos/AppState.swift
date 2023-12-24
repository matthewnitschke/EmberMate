//
//  AppState.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 12/10/23.
//

import SwiftUI
import Foundation
import Combine
import UserNotifications

class AppState: ObservableObject {
    var timer: Timer?
    
    // this value is not persisted, only published
    @Published var selectedPreset: Preset?
    
    @Published var countdown: Int?
    
    @Published var timers: [String] = ["4:00", "5:00", "6:00"]
    @Published var presets: [Preset] = [
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
    
    @AppStorage("notifyOnTemperatureReached") var notifyOnTemperatureReached: Bool = true
    @AppStorage("notifyOnLowBattery") var notifyOnLowBattery: Bool = true
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let presets = UserDefaults.standard.string(forKey: "presets")
        if let presets = presets {
            do {
                self.presets = try decoder.decode([Preset].self, from: presets.data(using: .utf8)!)
            } catch {
                print("Error decoding presets: \(error)")
            }
        }
        self.$presets
            .sink { newData in
                do {
                    let presetData = try encoder.encode(newData)
                    if let jsonString = String(data: presetData, encoding: .utf8) {
                        print("Saving: \(jsonString)")
                        UserDefaults.standard.set(jsonString, forKey: "presets")
                    }
                } catch {
                    print("Error encoding presets: \(error)")
                }
            }
            .store(in: &cancellables)
        
        
        let timers = UserDefaults.standard.string(forKey: "timers")
        if let timers = timers {
            do {
                self.timers = try decoder.decode([String].self, from: timers.data(using: .utf8)!)
            } catch {
                print("Error decoding timers: \(error)")
            }
        }
        self.$timers
            .sink { newData in
                do {
                    let timerData = try encoder.encode(newData)
                    if let jsonString = String(data: timerData, encoding: .utf8) {
                        print("Saving: \(jsonString)")
                        UserDefaults.standard.set(jsonString, forKey: "timers")
                    }
                } catch {
                    print("Error encoding timers: \(error)")
                }
            }
            .store(in: &cancellables)
    }
    
    func startTimer(_ time: Int) {
        timer?.invalidate()
        
        let un = UNUserNotificationCenter.current()
        
        un.requestAuthorization(options: [.alert, .sound]) { (authorized, error) in
            if authorized {
                print("Authorized")
            }
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
