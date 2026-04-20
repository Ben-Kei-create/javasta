import SwiftUI

struct SettingsView: View {
    @State private var progress = ProgressStore.shared
    @AppStorage("codeZoom") private var codeZoom: Double = CodeZoom.default
    @State private var showResetConfirm = false
    @Environment(\.dismiss) private var dismiss

    private let goalOptions = [3, 5, 10, 15]
    private var validationIssues: [String] { QuestionBank.validationIssues() }
    private var explanationReport: ExplanationAuditReport { QuestionBank.explanationAuditReport() }
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    section(title: "学習目標") {
                        VStack(spacing: Spacing.xs) {
                            ForEach(goalOptions, id: \.self) { goal in
                                goalRow(goal)
                            }
                        }
                    }

                    section(title: "表示") {
                        SettingRow(
                            icon: "textformat.size",
                            title: "コード文字サイズ",
                            value: "\(CodeZoom.percent(codeZoom))%",
                            onTap: { codeZoom = CodeZoom.next(after: codeZoom) }
                        )
                    }

                    section(title: "問題データ") {
                        VStack(spacing: 1) {
                            SettingRow(
                                icon: "checkmark.shield",
                                title: "品質チェック",
                                value: validationIssues.isEmpty ? "OK" : "\(validationIssues.count)件",
                                tint: validationIssues.isEmpty ? Color.jbText : Color.jbWarning,
                                onTap: nil
                            )
                            NavigationLink {
                                ExplanationAuditView()
                            } label: {
                                SettingNavigationRow(
                                    icon: "doc.text.magnifyingglass",
                                    title: "解説チェック",
                                    value: explanationReport.needsAttentionCount == 0 ? "OK" : "\(explanationReport.needsAttentionCount)件",
                                    tint: explanationReport.needsAttentionCount == 0 ? Color.jbText : Color.jbWarning
                                )
                            }
                            .buttonStyle(.plain)
                            SettingRow(
                                icon: "square.stack.3d.up",
                                title: "収録問題",
                                value: "\(QuestionBank.allQuizzes.count)問",
                                onTap: nil
                            )
                        }
                    }

                    section(title: "データ") {
                        SettingRow(
                            icon: "arrow.counterclockwise",
                            title: "学習進捗をリセット",
                            isDestructive: true,
                            onTap: { showResetConfirm = true }
                        )
                    }

                    section(title: "アプリについて") {
                        VStack(spacing: 1) {
                            SettingRow(icon: "info.circle", title: "バージョン", value: appVersion, onTap: nil)
                            SettingRow(icon: "envelope", title: "フィードバックを送る", onTap: {})
                        }
                    }

                    Spacer(minLength: Spacing.xxl)
                }
                .padding(Spacing.md)
            }
        }
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .alert("学習進捗をリセット", isPresented: $showResetConfirm) {
            Button("キャンセル", role: .cancel) {}
            Button("リセット", role: .destructive) { progress.resetAll() }
        } message: {
            Text("正答数・連続日数・完了レッスンがすべて消去されます。")
        }
    }

    // MARK: Goal row

    private func goalRow(_ goal: Int) -> some View {
        let selected = progress.dailyGoal == goal
        return Button(action: { progress.setDailyGoal(goal) }) {
            HStack {
                Text("1日 \(goal) 問")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.jbText)
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.jbAccent)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 12)
            .background(Color.jbCard)
        }
        .buttonStyle(.plain)
    }

    // MARK: Section helper

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.jbSubtext)
                .tracking(0.5)
                .padding(.horizontal, Spacing.sm)
            content()
                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbBorder, lineWidth: 1)
                )
        }
    }
}

// MARK: - SettingRow

struct SettingRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    var tint: Color = Color.jbText
    var isDestructive: Bool = false
    var onTap: (() -> Void)?

    private var iconColor: Color { isDestructive ? Color.jbError : Color.jbAccent }
    private var titleColor: Color { isDestructive ? Color.jbError : tint }

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(iconColor)
                    .frame(width: 24)
                Text(title)
                    .font(.system(size: 15))
                    .foregroundStyle(titleColor)
                Spacer()
                if let value {
                    Text(value)
                        .font(.system(size: 14).monospacedDigit())
                        .foregroundStyle(Color.jbSubtext)
                }
                if onTap != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.jbSubtext)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 12)
            .background(Color.jbCard)
        }
        .buttonStyle(.plain)
        .disabled(onTap == nil)
    }
}

struct SettingNavigationRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    var tint: Color = Color.jbText

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(Color.jbAccent)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(tint)
            Spacer()
            if let value {
                Text(value)
                    .font(.system(size: 14).monospacedDigit())
                    .foregroundStyle(Color.jbSubtext)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundStyle(Color.jbSubtext)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 12)
        .background(Color.jbCard)
    }
}
