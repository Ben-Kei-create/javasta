import StoreKit
import SwiftUI

struct SettingsView: View {
    @State private var progress = ProgressStore.shared
    @AppStorage("codeZoom") private var codeZoom: Double = CodeZoom.default
    @AppStorage(CodeSyntaxTheme.storageKey) private var codeSyntaxThemeRaw: String = CodeSyntaxTheme.classic.rawValue
    @AppStorage("examDateTimestamp") private var examDateTimestamp: Double = 0
    @State private var showResetConfirm = false
    @State private var showExamDatePicker = false
    @State private var showExamClearConfirm = false
    @State private var pickerDate: Date = Date().addingTimeInterval(60 * 60 * 24 * 30)
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview

    private let goalOptions = [3, 5, 10, 15]

    private var codeSyntaxTheme: CodeSyntaxTheme {
        CodeSyntaxTheme.value(for: codeSyntaxThemeRaw)
    }

    private var examDate: Date? {
        examDateTimestamp > 0 ? Date(timeIntervalSince1970: examDateTimestamp) : nil
    }

    private static let examDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ja_JP")
        fmt.dateFormat = "yyyy/MM/dd (E) HH:mm"
        return fmt
    }()

    private var examDateDisplay: String {
        guard let date = examDate else { return "未設定" }
        return Self.examDateFormatter.string(from: date)
    }

    private var daysUntilExam: Int? {
        guard let date = examDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: .now, to: date).day ?? 0
        return max(0, days)
    }

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

                    // MARK: 学習目標
                    section(title: "学習目標") {
                        VStack(spacing: 0) {
                            ForEach(Array(goalOptions.enumerated()), id: \.element) { index, goal in
                                if index > 0 {
                                    Divider()
                                        .background(Color.jbBorder)
                                        .padding(.horizontal, Spacing.md)
                                }
                                goalRow(goal)
                            }
                        }
                    }

                    // MARK: 受験日
                    section(title: "受験日") {
                        VStack(spacing: 0) {
                            examDateRow
                            if let days = daysUntilExam {
                                Divider()
                                    .background(Color.jbBorder)
                                    .padding(.horizontal, Spacing.md)
                                HStack(spacing: Spacing.sm) {
                                    Image(systemName: "hourglass")
                                        .font(.system(size: 15))
                                        .foregroundStyle(days <= 7 ? Color.jbError : Color.jbAccent)
                                        .frame(width: 24)
                                    Text("試験まで")
                                        .font(.system(size: 15))
                                        .foregroundStyle(Color.jbText)
                                    Spacer()
                                    Text(days == 0 ? "今日！" : "\(days)日")
                                        .font(.system(size: 14, weight: .semibold).monospacedDigit())
                                        .foregroundStyle(days <= 7 ? Color.jbError : Color.jbSubtext)
                                }
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, 12)
                                .background(Color.jbCard)
                            }
                        }
                    }

                    // MARK: 表示
                    section(title: "表示") {
                        VStack(spacing: 0) {
                            SettingRow(
                                icon: "textformat.size",
                                title: "コード文字サイズ",
                                value: "\(CodeZoom.percent(codeZoom))%",
                                onTap: {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    codeZoom = CodeZoom.next(after: codeZoom)
                                }
                            )

                            Divider()
                                .background(Color.jbBorder)
                                .padding(.horizontal, Spacing.md)

                            codeSyntaxThemeRow
                        }
                    }

                    // MARK: データ
                    section(title: "データ") {
                        SettingRow(
                            icon: "arrow.counterclockwise",
                            title: "学習進捗をリセット",
                            isDestructive: true,
                            onTap: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                showResetConfirm = true
                            }
                        )
                    }

#if DEBUG
                    // MARK: 販売準備
                    section(title: "販売準備") {
                        NavigationLink {
                            LaunchReadinessView()
                        } label: {
                            SettingNavigationRow(
                                icon: "checklist.checked",
                                title: "リリース品質チェック",
                                value: launchReadinessSummary
                            )
                        }
                        .buttonStyle(.plain)
                    }
#endif

                    // MARK: アプリについて
                    section(title: "アプリについて") {
                        VStack(spacing: 0) {
                            SettingRow(icon: "info.circle", title: "バージョン", value: appVersion, onTap: nil)
                            Divider()
                                .background(Color.jbBorder)
                                .padding(.horizontal, Spacing.md)
                            ShareLink(item: JavastaShare.appInviteText) {
                                SettingNavigationRow(
                                    icon: "square.and.arrow.up",
                                    title: "Javastaを紹介"
                                )
                            }
                            .buttonStyle(.plain)
                            Divider()
                                .background(Color.jbBorder)
                                .padding(.horizontal, Spacing.md)
                            SettingRow(
                                icon: "star.bubble",
                                title: "レビューを書く",
                                onTap: {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    requestReview()
                                }
                            )
                            Divider()
                                .background(Color.jbBorder)
                                .padding(.horizontal, Spacing.md)
                            SettingRow(
                                icon: "envelope",
                                title: "フィードバックを送る",
                                onTap: {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    let subject = "Javasta フィードバック v\(appVersion)"
                                    let encoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                                    if let url = URL(string: "mailto:fsmall.worldm@gmail.com?subject=\(encoded)") {
                                        openURL(url)
                                    }
                                }
                            )
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
        .sheet(isPresented: $showExamDatePicker) {
            examDatePickerSheet
        }
        .alert("受験日をクリア", isPresented: $showExamClearConfirm) {
            Button("キャンセル", role: .cancel) {}
            Button("クリア", role: .destructive) {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                examDateTimestamp = 0
            }
        } message: {
            Text("設定した受験日時を削除します。")
        }
        .alert("学習進捗をリセット", isPresented: $showResetConfirm) {
            Button("キャンセル", role: .cancel) {}
            Button("リセット", role: .destructive) {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                progress.resetAll()
            }
        } message: {
            Text("正答数・連続日数・完了レッスンがすべて消去されます。")
        }
    }

#if DEBUG
    private var launchReadinessSummary: String {
        let issueCount = QuestionBank.explanationAuditReport().needsAttentionCount +
            QuestionBank.contentQualityIssues().count +
            QuestionBank.validationIssues().count
        return issueCount == 0 ? "OK" : "\(issueCount)件"
    }
#endif

    private var codeSyntaxThemeRow: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "paintpalette")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.jbAccent)
                    .frame(width: 24)

                Text("コード配色")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.jbText)

                Spacer()

                Text(codeSyntaxTheme.displayName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.jbSubtext)
            }

            HStack(spacing: Spacing.sm) {
                ForEach(CodeSyntaxTheme.allCases) { theme in
                    CodeSyntaxThemeButton(
                        theme: theme,
                        isSelected: theme == codeSyntaxTheme,
                        action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            codeSyntaxThemeRaw = theme.rawValue
                        }
                    )
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 12)
        .background(Color.jbCard)
    }

    // MARK: - Exam date row (inline clear button)

    private var examDateRow: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            pickerDate = examDate ?? Date().addingTimeInterval(60 * 60 * 24 * 30)
            showExamDatePicker = true
        }) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "calendar")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.jbAccent)
                    .frame(width: 24)
                Text("受験日時")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.jbText)
                Spacer()
                Text(examDateDisplay)
                    .font(.system(size: 13).monospacedDigit())
                    .foregroundStyle(examDate != nil ? Color.jbAccent : Color.jbSubtext)
                if examDate != nil {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showExamClearConfirm = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 17))
                            .foregroundStyle(Color.jbSubtext)
                    }
                    .buttonStyle(.plain)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.jbSubtext)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 12)
            .background(Color.jbCard)
        }
        .buttonStyle(JBScaledButtonStyle(scaleAmount: 0.97))
    }

    // MARK: - Exam date picker sheet

    private var examDatePickerSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    DatePicker(
                        "受験日時",
                        selection: $pickerDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .tint(Color.jbAccent)
                    .padding(.horizontal, Spacing.sm)

                    // Quick-select chips
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("クイック選択")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.jbSubtext)
                            .tracking(0.4)
                            .padding(.horizontal, Spacing.sm)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.sm) {
                                ForEach([30, 60, 90, 120], id: \.self) { days in
                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        pickerDate = Date().addingTimeInterval(Double(days) * 86400)
                                    }) {
                                        Text("\(days)日後")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(Color.jbText)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(Color.jbCard)
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(Color.jbBorder, lineWidth: 1))
                                    }
                                    .buttonStyle(JBScaledButtonStyle())
                                }
                            }
                            .padding(.horizontal, Spacing.md)
                        }
                    }

                    Spacer(minLength: Spacing.xxl)
                }
            }
            .background(Color.jbBackground.ignoresSafeArea())
            .navigationTitle("受験日時を設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") { showExamDatePicker = false }
                        .foregroundStyle(Color.jbSubtext)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        examDateTimestamp = pickerDate.timeIntervalSince1970
                        showExamDatePicker = false
                    }
                    .foregroundStyle(Color.jbAccent)
                    .bold()
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Goal row

    private func goalRow(_ goal: Int) -> some View {
        let selected = progress.dailyGoal == goal
        return Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            progress.setDailyGoal(goal)
        }) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundStyle(selected ? Color.jbAccent : Color.jbSubtext)
                    .frame(width: 24)
                Text("1日 \(goal) 問")
                    .font(.system(size: 15, weight: selected ? .semibold : .regular))
                    .foregroundStyle(selected ? Color.jbText : Color.jbSubtext)
                Spacer()
                if selected {
                    Text("設定中")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.jbAccent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.jbAccent.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 12)
            .background(selected ? Color.jbAccent.opacity(0.07) : Color.jbCard)
            .animation(.easeInOut(duration: 0.15), value: selected)
        }
        .buttonStyle(JBScaledButtonStyle(scaleAmount: 0.97))
    }

    // MARK: - Section helper

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
        .buttonStyle(onTap != nil ? JBScaledButtonStyle(scaleAmount: 0.97) : JBScaledButtonStyle(scaleAmount: 1.0))
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

private struct CodeSyntaxThemeButton: View {
    let theme: CodeSyntaxTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 3) {
                    ForEach(Array(theme.palette.swatches.enumerated()), id: \.offset) { _, color in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color)
                            .frame(width: 10, height: 14)
                    }
                }

                HStack(spacing: 4) {
                    Text(theme.displayName)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.jbText : Color.jbSubtext)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.jbAccent)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(isSelected ? Color.jbAccent.opacity(0.1) : Color.jbBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(isSelected ? Color.jbAccent.opacity(0.55) : Color.jbBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(JBScaledButtonStyle(scaleAmount: 0.97))
    }
}
