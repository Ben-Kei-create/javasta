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
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("spotlight.pendingTermId") private var pendingTermId: String = ""
    @AppStorage("spotlight.pendingLessonId") private var pendingLessonId: String = ""
    @AppStorage("colorScheme") private var colorSchemeRaw: String = "system"

    private var preferredScheme: ColorScheme? {
        switch colorSchemeRaw {
        case "dark":  return .dark
        case "light": return .light
        default:      return nil   // system
        }
    }

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains(Self.resetAppStateArgument) {
            Self.resetPersistentState()
        }
        // UI テスト時はオンボーディングをスキップして即ホームへ
        if arguments.contains(Self.uiTestingArgument) {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }

        _splashFinished = State(initialValue: arguments.contains(Self.uiTestingArgument))
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if splashFinished {
                    ContentView()
                        .transition(.opacity)
                        .preferredColorScheme(preferredScheme)
                        .fullScreenCover(isPresented: .constant(!hasCompletedOnboarding)) {
                            OnboardingView()
                        }
                } else {
                    SplashView(onFinish: {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            splashFinished = true
                        }
                    })
                    .transition(.opacity)
                }
            }
            .task {
                await NotificationManager.shared.syncOnLaunch()
                await CloudSyncManager.shared.syncOnLaunch()
                await PurchaseManager.shared.loadOnLaunch()
                SpotlightIndexer.shared.indexAll()
            }
            .onContinueUserActivity(SpotlightIndexer.glossaryActivityType) { activity in
                if let termId = activity.userInfo?["id"] as? String {
                    pendingTermId = termId
                }
            }
            .onContinueUserActivity(SpotlightIndexer.lessonActivityType) { activity in
                if let lessonId = activity.userInfo?["id"] as? String {
                    pendingLessonId = lessonId
                }
            }
        }
    }

    private static func resetPersistentState() {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return }
        UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
    }
}
