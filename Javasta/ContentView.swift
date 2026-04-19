//
//  ContentView.swift
//  Javasta
//
//  Created by 茂木史明 on 2026/04/19.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .quiz

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
    }
}

#Preview {
    ContentView()
}
