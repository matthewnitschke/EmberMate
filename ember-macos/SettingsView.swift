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
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Presets").font(.title)
                    
                    Grid(alignment: .leading) {
                        ForEach(appState.presets, id: \.id) { preset in
                            PresetRowView(
                                preset: preset,
                                onRemove: {
                                    appState.presets.removeAll(where: { $0.id == preset.id })
                                }
                            )
                        }.padding(.bottom, 7)
                    }
                    
                    
                    Button("+") {
                        appState.presets.append(Preset())
                    }
                    
                    
                    Text("Timer").font(.title).padding(.top, 20)
                    TextField("Enter integers separated by commas", text: Binding(
                        get: {
                            internalTime ?? appState.timers
                                .map(formatTime)
                                .joined(separator: ", ")
                        },
                        set: { internalTime = $0 }
                    ))
                    
                    HStack(alignment: .center) {
                        Button("Save") {
                            if let internalTime = internalTime {
                                let components = internalTime
                                    .split(separator: ",")
                                    .map { String($0.trimmingCharacters(in: .whitespaces)) }
                                    .compactMap(convertTimeToSeconds)
                                appState.timers = components.compactMap { Int($0) }
                            }
                            
                            appState.save()
                        }
                    }.padding(.top, 30)
      
                }
                .padding(30)
                .navigationTitle("Settings")
            }
        }
        .frame(width: 480, height: 500)
    }
}

struct PresetRowView: View {
    @State private var isIconPopoverPresented = false
    @ObservedObject var preset: Preset
    
    var images: [String] = [
        "mug.fill",
        "cup.and.saucer.fill",
        "drop.fill",
        "leaf.fill",
        "star.fill",
        "flame.fill"
    ]
    
    var onRemove: () -> Void
    
    var body: some View {
        GridRow {
            Button(action: {
                isIconPopoverPresented.toggle()
            }) {
                Image(systemName: preset.icon)
                    .frame(width: 20)
            }
            .popover(isPresented: $isIconPopoverPresented, arrowEdge: .leading) {
                LazyVGrid(
                    columns: [GridItem(.fixed(30), spacing: 7), GridItem(.fixed(30), spacing: 7)],
                    spacing: 7
                ) {
                    ForEach(images, id: \.self) { image in
                        Button(action: {
                            preset.icon = image
                        }) {
                            Image(systemName: image).font(.title)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }.padding(10)
            }
            
            TextField("Name", text: $preset.name)
            TextField("Temp", value: $preset.temperature, format: .number)
            Button("-") { onRemove() }
        }
    }
}
