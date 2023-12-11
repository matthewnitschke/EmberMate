//
//  TimerView.swift
//  ember-macos
//
//  Created by Matthew Nitschke on 12/10/23.
//

import Foundation
import SwiftUI

struct TimerView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        HStack {
            Image(systemName: "timer")
                .font(.system(size: 20))
            Text("Timer")
                .font(.system(size: 14))
            Spacer()
            
            if appState.countdown == nil {
                ForEach(appState.timers, id: \.self) { time in
                    Button(formatTime(time)) {
                        appState.startTimer(time)
                    }
                }
            }
            
            if appState.countdown != nil {
                Text(formatTime(appState.countdown!))
                    .font(.system(size: 14))
                Button(action: {
                    appState.stopTimer()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.29))
        .cornerRadius(9)
    }
}
