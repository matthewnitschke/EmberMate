//
//  SettingsView.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 12/10/23.
//

import Foundation
import SwiftUI
import AppKit



struct SettingsView: View {
    @ObservedObject var appState: AppState
    
    @State var internalTime: String?
    
    var body: some View {
        TabView {
//            GeneralSettingsView()
//                .tabItem {
//                    Label("General", systemImage: "gear")
//                }
            PresetsSettingsView(appState: appState)
                .tabItem {
                    Label("Presets", systemImage: "square.and.arrow.down")
                }
            TimerSettingsView()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
        }
        .navigationTitle("Settings")
    
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(alignment: .leading) {
//                    Text("Presets").font(.title)
//
//                    Grid(alignment: .leading) {
//                        ForEach(appState.presets, id: \.id) { preset in
//                            PresetRowView(
//                                preset: preset,
//                                onRemove: {
//                                    appState.presets.removeAll(where: { $0.id == preset.id })
//                                }
//                            )
//                        }.padding(.bottom, 7)
//                    }
//
//
//                    Button("+") {
//                        appState.presets.append(Preset())
//                    }
//
//
//                    Text("Timer").font(.title).padding(.top, 20)
//                    TextField("Enter integers separated by commas", text: Binding(
//                        get: {
//                            internalTime ?? appState.timers
//                                .map(formatTime)
//                                .joined(separator: ", ")
//                        },
//                        set: { internalTime = $0 }
//                    ))
//
//                    HStack(alignment: .center) {
//                        Button("Save") {
//                            if let internalTime = internalTime {
//                                let components = internalTime
//                                    .split(separator: ",")
//                                    .map { String($0.trimmingCharacters(in: .whitespaces)) }
//                                    .compactMap(convertTimeToSeconds)
//                                appState.timers = components.compactMap { Int($0) }
//                            }
//
//                            appState.save()
//                        }
//                    }.padding(.top, 30)
//
//                }
//                .padding(30)
//                .navigationTitle("Settings")
//            }
//        }
//        .frame(width: 480, height: 500)
    }
}

//struct GeneralView: View {
//    @State var isOn: Bool = false
//    var body: some View {
//        Form {
//            Toggle("Launch at login", isOn: $isOn)
//        }
//        .formStyle(.grouped)
//    }
//}

struct PresetsSettingsView: View {
    @ObservedObject var appState: AppState
    
//    @State var name: String = "name"
//    @State var temp: Double = 10.2
//
//    @State var selection: String = "mug.fill"
    @State var isOn: Bool = true
    
    var images: [String] = [
        "mug.fill",
        "cup.and.saucer.fill",
        "drop.fill",
        "leaf.fill",
        "star.fill",
        "flame.fill"
    ]
    
    var body: some View {
        Form {
            ForEach($appState.presets, id: \.id) { preset in
                Section {
                    TextField("Name", text: preset.name)
                    Picker(
                        selection: preset.icon,
                        label: Text("Icon")
                    ) {
                        ForEach(images, id: \.self) { image in
                            Image(systemName: image).tag(image)
                       }
                    }
                    TextField("Temperature", value: preset.temperature, format: .number)
                    Toggle("Enabled", isOn: $isOn)
                }
            }
        }
        .formStyle(.grouped)
    }
}

struct TimerSettingsView: View {
    @AppStorage("timer") var timer: [String] = ["4:00", "5:00", "6:00"]
    
    var body: some View {
        Form {
            Section {
                ForEach($timer, id: \.self) {time in
                    TextField("Duration", text: time)
                }
            }
        }
        .formStyle(.grouped)
    }
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
