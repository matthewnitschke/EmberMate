//
//  AboutView.swift
//  EmberMate
//
//  Created by Matthew Nitschke on 11/8/25.
//

import SwiftUI

struct AboutView: View {
    @State var isCheckingForUpdates: Bool = false
    @State var latestVersion: String?
    
    var body: some View {
        VStack(spacing: 9) {
            Image(nsImage: NSApp.applicationIconImage!)
                .resizable()
                .frame(width: 64, height: 64)
            
            Text("EmberMate")
                .font(.title)
            
            Text("Version \(Bundle.main.appVersion)")
                .font(.footnote)
            
            HStack(spacing: 1.5) {
                Text("Made with").font(.footnote)
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.footnote)
                Text("by").font(.footnote)
                Link("Matthew Nitschke", destination: URL(string: "https://github.com/matthewnitschke")!).font(.footnote)
            }
            
            Divider()
            
            if (latestVersion != nil) {
                if (latestVersion == Bundle.main.appVersion) {
                    Text("No updates available")
                } else {
                    HStack(spacing: 1.5) {
                        Text("Update available! Click")
                        Link("here", destination: URL(string: "https://github.com/matthewnitschke/EmberMate/releases/latest")!)
                        Text("to download")
                    }
                }
            } else {
                Button(
                    isCheckingForUpdates ? "Checking for Updates..." : "Check for Updates"
                ) {
                    checkForUpdates()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 300)
    }
    
    func checkForUpdates() {
        isCheckingForUpdates = true
        Task {
            latestVersion = await getLatestVersion()
        }
    }
}

func showAboutWindow() {
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 300, height: 250),
        styleMask: [.titled, .closable],
        backing: .buffered,
        defer: false
    )
    window.title = "About EmberMate"
    window.center()
    window.contentView = NSHostingView(rootView: AboutView())
    window.isReleasedWhenClosed = false
    
    NSApp.activate(ignoringOtherApps: true)
    window.makeKeyAndOrderFront(nil)
}
