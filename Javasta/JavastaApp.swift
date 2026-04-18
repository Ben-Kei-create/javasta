//
//  JavastaApp.swift
//  Javasta
//
//  Created by 茂木史明 on 2026/04/19.
//

import SwiftUI

@main
struct JavastaApp: App {
    @State private var splashFinished = false

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
}
