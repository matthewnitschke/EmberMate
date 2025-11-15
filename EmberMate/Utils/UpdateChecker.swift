//
//  UpdateChecker.swift
//  EmberMate
//
//  Created by Matthew Nitschke on 11/15/25.
//

import SwiftUI
import Combine

class UpdateChecker: ObservableObject {
    
    @Published var hasUpdate: Bool = false
    @Published var latestVersion: String?
    
    private var timer: AnyCancellable?
    
    // Initialize nextUpdateCheck to the past so we check updates on the first run
    private var nextUpdateCheck: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    
    private var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
        
        timer = Timer.publish(every: 3600, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.run()
            }
    }
    
    private func run() {
        // if the user has explicitly disabled update checking, don't check
        if !appState.automaticallyCheckForUpdates {
            return
        }
        
        // only check for updates once a week (and on initial startup)
        if nextUpdateCheck > Date() {
            return
        }
        
        Task {
            self.latestVersion = await getLatestVersion()
            self.hasUpdate = self.latestVersion != Bundle.main.appVersion
        }
        
        nextUpdateCheck = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    }
    
}
