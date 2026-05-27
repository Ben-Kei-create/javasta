//
//  ContentView.swift
//  Javasta
//
//  Created by 茂木史明 on 2026/04/19.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .quiz
    @Environment(\.horizontalSizeClass) private var hSizeClass

    enum Tab: Hashable { case learning, quiz, stats }

    var body: some View {
        if hSizeClass == .regular {
            // iPad: NavigationSplitView でサイドバー
            iPadLayout
        } else {
            // iPhone: TabView（既存）
            iPhoneLayout
        }
    }

    private var iPhoneLayout: some View {
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

            StatsView()
                .tag(Tab.stats)
                .tabItem {
                    Label("統計", systemImage: "chart.bar.fill")
                }
        }
        .tint(Color.jbAccent)
    }

    private var iPadLayout: some View {
        NavigationSplitView {
            // サイドバー
            List {
                Button {
                    selectedTab = .learning
                } label: {
                    Label("学習", systemImage: "book.fill")
                        .foregroundStyle(selectedTab == .learning ? Color.jbAccent : Color.jbText)
                }
                .listRowBackground(selectedTab == .learning ? Color.jbAccent.opacity(0.12) : Color.clear)

                Button {
                    selectedTab = .quiz
                } label: {
                    Label("問題", systemImage: "pencil.and.list.clipboard")
                        .foregroundStyle(selectedTab == .quiz ? Color.jbAccent : Color.jbText)
                }
                .listRowBackground(selectedTab == .quiz ? Color.jbAccent.opacity(0.12) : Color.clear)

                Button {
                    selectedTab = .stats
                } label: {
                    Label("統計", systemImage: "chart.bar.fill")
                        .foregroundStyle(selectedTab == .stats ? Color.jbAccent : Color.jbText)
                }
                .listRowBackground(selectedTab == .stats ? Color.jbAccent.opacity(0.12) : Color.clear)
            }
            .navigationTitle("Javasta")
            .listStyle(.sidebar)
        } detail: {
            switch selectedTab {
            case .learning: LearningHomeView()
            case .quiz:     HomeView()
            case .stats:    StatsView()
            }
        }
        .tint(Color.jbAccent)
    }
}

#Preview {
    ContentView()
}
