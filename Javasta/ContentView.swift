//
//  ContentView.swift
//  Javasta
//
//  Created by 茂木史明 on 2026/04/19.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .quiz
    @AppStorage("spotlight.pendingTermId") private var pendingTermId: String = ""
    @AppStorage("spotlight.pendingLessonId") private var pendingLessonId: String = ""

    enum Tab: Hashable { case learning, quiz }

    var body: some View {
        TabView(selection: $selectedTab) {
            LearningHomeView()
                .tag(Tab.learning)
                .tabItem {
                    Label("学習", systemImage: "book.fill")
                }

            HomeView()
                .tag(Tab.quiz)
                .tabItem {
                    Label("問題", systemImage: "pencil.and.list.clipboard")
                }
        }
        .tint(Color.jbAccent)
        .preferredColorScheme(.dark)
        .onChange(of: pendingTermId) { _, newId in
            if !newId.isEmpty { selectedTab = .learning }
        }
        .onChange(of: pendingLessonId) { _, newId in
            if !newId.isEmpty { selectedTab = .learning }
        }
    }
}

#Preview {
    ContentView()
}
