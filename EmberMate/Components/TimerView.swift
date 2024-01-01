//
//  TimerView.swift
//  EmberMate
//
//  Created by Matthew Nitschke on 12/10/23.
//

import Foundation
import SwiftUI

struct TimerView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "timer")
                .font(.system(size: 20))
            Text("Timer")
                .font(.system(size: 14))
            Spacer()

            if appState.countdown == nil {
                ForEach(appState.timers, id: \.self) { time in
                    Button(time) {
                        appState.startTimer(convertTimeToSeconds(time)!)
                    }.buttonStyle(EmberButtonStyle())
                }
            }

            if appState.countdown != nil {
                Text(formatTime(appState.countdown!))
                    .font(.system(size: 14))
                Button(action: {
                    appState.stopTimer()
                }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                }.buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.29))
        .cornerRadius(9)
    }
}


struct EmberButtonStyle: ButtonStyle {
        typealias Body = Button

        func makeBody(configuration: Self.Configuration) -> some View {
            return configuration
                .label
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(Color.black.opacity(0.29))
                .cornerRadius(9)
        }
}
