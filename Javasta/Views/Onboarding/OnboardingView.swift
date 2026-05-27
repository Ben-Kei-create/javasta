import SwiftUI

// MARK: - OnboardingView

/// フルスクリーンオンボーディング（初回起動時のみ表示）
///
/// 4ページ構成:
///   1. Welcome   — アプリの価値訴求
///   2. Level     — Silver / Gold 選択
///   3. Goal      — 1日の目標問題数
///   4. Ready     — 設定サマリーと開始ボタン
///
/// 完了時に `AppStorage("hasCompletedOnboarding")` を `true` に設定し、
/// `JavastaApp` の `.fullScreenCover` を閉じる。
struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding")  var hasCompleted = false
    @AppStorage("selectedJavaLevel")  var selectedLevelRaw = JavaLevel.silver.rawValue
    @AppStorage("selectedExamVersion") var selectedVersionRaw = JavaExamVersion.se17.rawValue
    @State private var page: Int = 0

    // Proxy for ProgressStore dailyGoal — we write via ProgressStore.shared
    @State private var selectedGoal: Int = 5

    private var selectedLevel: JavaLevel {
        JavaLevel(rawValue: selectedLevelRaw) ?? .silver
    }

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Page indicator (dots)
                pageIndicator
                    .padding(.top, Spacing.lg)

                // Paged content
                TabView(selection: $page) {
                    welcomePage.tag(0)
                    levelPage.tag(1)
                    goalPage.tag(2)
                    readyPage.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.jbSmooth, value: page)
            }
        }
        .onAppear {
            // SE17 を既定に固定（SE11 は廃止）
            selectedVersionRaw = JavaExamVersion.se17.rawValue
        }
    }

    // MARK: - Page indicator

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<4) { i in
                Capsule()
                    .fill(i == page ? Color.jbAccent : Color.jbBorder)
                    .frame(width: i == page ? 20 : 6, height: 6)
                    .animation(.jbFast, value: page)
            }
        }
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()

            VStack(spacing: Spacing.lg) {
                // App icon placeholder ring
                ZStack {
                    Circle()
                        .fill(Color.jbAccent.opacity(0.12))
                        .frame(width: 110, height: 110)
                    Circle()
                        .strokeBorder(Color.jbAccent.opacity(0.4), lineWidth: 2)
                        .frame(width: 110, height: 110)
                    Text("{ }")
                        .font(.system(size: 38, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.jbAccent)
                }

                VStack(spacing: Spacing.sm) {
                    Text("Javasta")
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundStyle(Color.jbText)

                    Text("Java認定試験の合格を\nコードで理解して目指す")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.jbSubtext)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }

            VStack(spacing: Spacing.md) {
                featureLine(icon: "curlybraces", text: "コードを追って理解する問題形式")
                featureLine(icon: "chart.line.uptrend.xyaxis", text: "苦手分野を自動で洗い出し復習")
                featureLine(icon: "doc.text.fill", text: "本番想定の模擬試験モード")
            }
            .padding(.horizontal, Spacing.xl)

            Spacer()

            nextButton(label: "はじめる") { advance() }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.xxl)
    }

    // MARK: - Page 2: Level

    private var levelPage: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()

            VStack(spacing: Spacing.md) {
                pageTitle(number: 1, title: "目標レベルを選んでください")
                Text("いつでも設定から変更できます")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.jbSubtext)
            }

            VStack(spacing: Spacing.md) {
                levelCard(
                    level: .silver,
                    subtitle: "Java SE 17 Silver\n1Z0-829-JPN",
                    description: "Javaの基礎〜オブジェクト指向を網羅。\n初めて受験する方にも最適。",
                    icon: "medal"
                )
                levelCard(
                    level: .gold,
                    subtitle: "Java SE 17 Gold\n1Z0-830-JPN",
                    description: "ラムダ・Stream・並行処理など応用領域。\nSilver取得後のステップアップに。",
                    icon: "medal.fill"
                )
            }
            .padding(.horizontal, Spacing.lg)

            Spacer()

            nextButton(label: "次へ") { advance() }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.xxl)
    }

    // MARK: - Page 3: Daily goal

    private var goalPage: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()

            VStack(spacing: Spacing.md) {
                pageTitle(number: 2, title: "1日の目標問題数")
                Text("毎日コツコツが合格への近道")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.jbSubtext)
            }

            VStack(spacing: Spacing.sm) {
                ForEach([3, 5, 10, 15], id: \.self) { goal in
                    goalRow(goal)
                }
            }
            .padding(.horizontal, Spacing.lg)

            Spacer()

            nextButton(label: "次へ") {
                ProgressStore.shared.setDailyGoal(selectedGoal)
                advance()
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.xxl)
    }

    // MARK: - Page 4: Ready

    @State private var notifications = NotificationManager.shared

    private var readyPage: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()

            VStack(spacing: Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(Color.jbSuccess.opacity(0.12))
                        .frame(width: 100, height: 100)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(Color.jbSuccess)
                }

                VStack(spacing: Spacing.sm) {
                    Text("準備完了！")
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundStyle(Color.jbText)
                    Text("設定はいつでも変更できます")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.jbSubtext)
                }
            }

            // Summary card
            VStack(spacing: 0) {
                summaryRow(icon: "flag.fill", label: "目標レベル", value: selectedLevel.displayName)
                Divider().background(Color.jbBorder).padding(.horizontal, Spacing.md)
                summaryRow(icon: "doc.text", label: "試験コード", value: JavaExamVersion.se17.examCode(for: selectedLevel))
                Divider().background(Color.jbBorder).padding(.horizontal, Spacing.md)
                summaryRow(icon: "target", label: "1日の目標", value: "\(selectedGoal)問")
            }
            .jbCard(radius: Radius.lg)
            .padding(.horizontal, Spacing.lg)

            // 通知オプトインバナー（未決定の場合のみ表示）
            if notifications.authorizationStatus == .notDetermined {
                notificationOptInBanner
            }

            Spacer()

            nextButton(label: "学習をはじめる 🚀", tint: Color.jbSuccess) {
                withAnimation(.jbSmooth) {
                    hasCompleted = true
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.xxl)
        .task { await notifications.refreshStatus() }
    }

    private var notificationOptInBanner: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 22))
                .foregroundStyle(Color.jbAccent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text("毎日リマインダー")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.jbText)
                Text("学習習慣をサポートします")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.jbSubtext)
            }

            Spacer()

            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                Task { await notifications.requestPermissionAndEnable() }
            }) {
                Text("オン")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
                    .background(Color.jbAccent)
                    .clipShape(Capsule())
            }
            .buttonStyle(JBScaledButtonStyle())
        }
        .padding(Spacing.md)
        .jbCard(radius: Radius.lg)
        .padding(.horizontal, Spacing.lg)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Sub-components

    private func featureLine(icon: String, text: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.jbAccent)
                .frame(width: 28)
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(Color.jbText)
            Spacer()
        }
    }

    private func pageTitle(number: Int, title: String) -> some View {
        VStack(spacing: Spacing.xs) {
            Text("STEP \(number)")
                .font(.system(size: 11, weight: .heavy).monospaced())
                .foregroundStyle(Color.jbAccent)
                .tracking(1)
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.jbText)
                .multilineTextAlignment(.center)
        }
    }

    private func levelCard(
        level: JavaLevel,
        subtitle: String,
        description: String,
        icon: String
    ) -> some View {
        let selected = selectedLevel == level
        return Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            selectedLevelRaw = level.rawValue
        }) {
            HStack(alignment: .top, spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(selected ? Color.jbAccent : Color.jbSubtext)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(level.displayName)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(selected ? Color.jbText : Color.jbSubtext)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .semibold).monospaced())
                        .foregroundStyle(selected ? Color.jbAccent : Color.jbSubtext)
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundStyle(selected ? Color.jbText.opacity(0.8) : Color.jbSubtext.opacity(0.7))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()

                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(selected ? Color.jbAccent : Color.jbSubtext)
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(selected ? Color.jbAccent.opacity(0.08) : Color.jbCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.lg)
                            .stroke(selected ? Color.jbAccent.opacity(0.6) : Color.jbBorder, lineWidth: selected ? 1.5 : 1)
                    )
            )
        }
        .buttonStyle(JBScaledButtonStyle(scaleAmount: 0.97))
        .animation(.jbFast, value: selectedLevelRaw)
    }

    private func goalRow(_ goal: Int) -> some View {
        let selected = selectedGoal == goal
        return Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            selectedGoal = goal
        }) {
            HStack(spacing: Spacing.md) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(selected ? Color.jbAccent : Color.jbSubtext)
                    .frame(width: 28)

                Text("1日 \(goal) 問")
                    .font(.system(size: 16, weight: selected ? .semibold : .regular))
                    .foregroundStyle(selected ? Color.jbText : Color.jbSubtext)

                Spacer()

                if goal == 5 {
                    Text("おすすめ")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.jbAccent)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 3)
                        .background(Color.jbAccent.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: Radius.md)
                    .fill(selected ? Color.jbAccent.opacity(0.08) : Color.jbCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .stroke(selected ? Color.jbAccent.opacity(0.5) : Color.jbBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(JBScaledButtonStyle(scaleAmount: 0.97))
        .animation(.jbFast, value: selectedGoal)
    }

    private func summaryRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.jbAccent)
                .frame(width: 22)
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Color.jbSubtext)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.jbText)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 12)
        .background(Color.jbCard)
    }

    private func nextButton(label: String, tint: Color = Color.jbAccent, action: @escaping () -> Void) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            Text(label)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .fill(tint)
                )
        }
        .buttonStyle(JBScaledButtonStyle())
        .padding(.horizontal, Spacing.lg)
    }

    // MARK: - Helpers

    private func advance() {
        withAnimation(.jbSmooth) {
            page = min(page + 1, 3)
        }
    }
}

#Preview {
    OnboardingView()
}
