//
//  JavastaApp.swift
//  Javasta
//
//  Created by 茂木史明 on 2026/04/19.
//

import SwiftUI

@main
struct JavastaApp: App {
    private static let uiTestingArgument = "-ui-testing"
    private static let resetAppStateArgument = "-reset-app-state"

    @State private var splashFinished: Bool

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains(Self.resetAppStateArgument) {
            Self.resetPersistentState()
        }

        _splashFinished = State(initialValue: arguments.contains(Self.uiTestingArgument))
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if splashFinished {
                    ContentView()
                        .transition(.opacity)
                } else {
                    SplashView(onFinish: {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            splashFinished = true
                        }
                    })
                    .transition(.opacity)
                }
            }
        }
    }

    private static func resetPersistentState() {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return }
        UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
    }
}
