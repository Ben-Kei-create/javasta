import SwiftUI

struct QuizView: View {
    @State var vm: QuizViewModel
    @State private var activeIssueReport: QuizIssueReport?
    var codeZoom: Double = 1.0
    var onShowExplanation: () -> Void
    var onNextQuiz: (() -> Void)? = nil
    var nextButtonTitle: String = "次の問題"

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            GeometryReader { proxy in
                ScrollView {
                    contentLayout(size: proxy.size)
                        .padding(Spacing.md)
                        .animation(.jbSpring, value: vm.isAnswered)
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $activeIssueReport) { report in
            QuizIssueReportSheet(report: report)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private func contentLayout(size: CGSize) -> some View {
        if shouldUseSplitLayout(size) {
            HStack(alignment: .top, spacing: Spacing.md) {
                codeBlock(compactHeight: splitCodeHeight(for: size))
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                VStack(alignment: .leading, spacing: Spacing.lg) {
                    questionSection
                    choicesSection
                    choicesHintSection
                    answeredResultSection
                    Spacer(minLength: Spacing.xl)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        } else {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                codeBlock()
                questionSection
                choicesSection
                choicesHintSection
                answeredResultSection
                Spacer(minLength: Spacing.xxl)
            }
        }
    }

    // MARK: Markdown helper

    private func markdownBody(_ source: String) -> Text {
        let opts = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        if let attr = try? AttributedString(markdown: source, options: opts) {
            return Text(attr)
        }
        return Text(source)
    }

    // MARK: Code block

    @ViewBuilder
    private func codeBlock(compactHeight: CGFloat = 220) -> some View {
        if let codeTabs = vm.quiz.codeTabs, !codeTabs.isEmpty {
            CodeBlockView(
                tabs: codeTabs.map {
                    CodeBlockView.FileTab(id: $0.id, filename: $0.filename, code: $0.code)
                },
                zoom: codeZoom,
                compactHeight: compactHeight
            )
        } else {
            CodeBlockView(code: vm.quiz.code, zoom: codeZoom, compactHeight: compactHeight)
        }
    }

    private func shouldUseSplitLayout(_ size: CGSize) -> Bool {
        size.width > size.height && size.width >= 680
    }

    private func splitCodeHeight(for size: CGSize) -> CGFloat {
        min(max(size.height - Spacing.xl, 260), 560)
    }

    // MARK: Question

    private var questionSection: some View {
        Text(vm.quiz.question)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(Color.jbText)
            .lineSpacing(4)
    }

    // MARK: Choices

    private var choicesSection: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(vm.displayedChoices) { choice in
                QuizChoiceButton(
                    choice: choice,
                    isSelected: vm.selectedChoiceId == choice.id,
                    isAnswered: vm.isAnswered,
                    onTap: { vm.select(choice) }
                )
            }
        }
    }

    @ViewBuilder
    private var choicesHintSection: some View {
        if !vm.isAnswered {
            HStack(alignment: .top, spacing: Spacing.xs) {
                Image(systemName: "lightbulb")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.jbSubtext)
                    .padding(.top, 1)

                Text("選択後に、答えの簡単な解説が表示されます。")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.jbSubtext)
                    .lineSpacing(2)
            }
            .padding(.horizontal, Spacing.xs)
            .transition(.opacity)
        }
    }

    // MARK: Result

    @ViewBuilder
    private var answeredResultSection: some View {
        if vm.isAnswered {
            resultSection
                .transition(.asymmetric(
                    insertion: .push(from: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))
        }
    }

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: vm.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(vm.isCorrect ? Color.jbSuccess : Color.jbError)
                Text(vm.isCorrect ? "正解" : "不正解")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(vm.isCorrect ? Color.jbSuccess : Color.jbError)
            }

            if let choice = vm.selectedChoice {
                markdownBody(choice.explanation)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.jbText)
                    .lineSpacing(4)
                    .tint(Color.jbAccent)
            }

            markdownBody(vm.quiz.designIntent)
                .font(.system(size: 13).italic())
                .foregroundStyle(Color.jbSubtext)
                .tint(Color.jbAccent)
                .padding(Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .fill(Color.jbBackground)
                )

            actionButtons

            issueReportButton
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
        )
    }

    // MARK: Action buttons

    private var actionButtons: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: onShowExplanation) {
                HStack(spacing: 6) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 15))
                    Text("実行を追う")
                        .font(.system(size: 14, weight: .semibold))
                    traceStatusBadge
                }
                .foregroundStyle(Color.jbAccent)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbAccent, lineWidth: 1.5)
                    )
            }
            .disabled(explanationTraceStatus == .missing)

            if let onNextQuiz {
                Button(action: onNextQuiz) {
                    HStack(spacing: 6) {
                        Text(nextButtonTitle)
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: nextButtonTitle == "完了" ? "checkmark" : "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .fill(Color.jbAccent)
                    )
                }
            }
        }
    }

    private var issueReportButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            activeIssueReport = QuizIssueReport(
                quiz: vm.quiz,
                selectedChoice: vm.selectedChoice
            )
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "flag")
                    .font(.system(size: 11, weight: .semibold))
                Text("問題の不備を報告")
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(Color.jbSubtext)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("問題の不備を報告")
    }

    private var explanationTraceStatus: ExplanationTraceStatus {
        Explanation.traceStatus(for: vm.quiz.explanationRef)
    }

    @ViewBuilder
    private var traceStatusBadge: some View {
        switch explanationTraceStatus {
        case .authored:
            EmptyView()
        case .placeholder:
            Text("汎用")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.jbWarning)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color.jbWarning.opacity(0.14)))
        case .missing:
            Text("未解決")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.jbError)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color.jbError.opacity(0.14)))
        }
    }
}

// MARK: - QuizIssueReport

private struct QuizIssueReport: Identifiable {
    let id = UUID()
    let quiz: Quiz
    let selectedChoice: Quiz.Choice?
}

private enum QuizIssueType: String, CaseIterable, Identifiable {
    case wrongAnswer = "正答が違う"
    case explanation = "解説が不自然"
    case code = "コード不備"
    case typo = "誤字・表記"
    case other = "その他"

    var id: String { rawValue }
}

private struct QuizIssueReportSheet: View {
    let report: QuizIssueReport

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var issueType: QuizIssueType = .wrongAnswer
    @State private var detail = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.jbBackground.ignoresSafeArea()

                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Picker("種類", selection: $issueType) {
                        ForEach(QuizIssueType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color.jbAccent)

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("対象")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.jbSubtext)
                        Text(report.quiz.id)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color.jbText)
                    }

                    TextEditor(text: $detail)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.jbText)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 130)
                        .padding(Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.sm)
                                .fill(Color.jbCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Radius.sm)
                                        .stroke(Color.jbBorder, lineWidth: 1)
                                )
                        )
                        .overlay(alignment: .topLeading) {
                            if detail.isEmpty {
                                Text("気づいた点を書いてください")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.jbSubtext.opacity(0.7))
                                    .padding(Spacing.md)
                                    .allowsHitTesting(false)
                            }
                        }

                    Button {
                        sendReport()
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "paperplane.fill")
                            Text("問い合わせを作成")
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.md)
                                .fill(Color.jbAccent)
                        )
                    }

                    Spacer(minLength: 0)
                }
                .padding(Spacing.lg)
            }
            .navigationTitle("問題を報告")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(Color.jbSubtext)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func sendReport() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let subject = "Javasta 問題報告: \(report.quiz.id)"
        var body = """
問題ID: \(report.quiz.id)
級: \(report.quiz.level.displayName)
カテゴリ: \(report.quiz.categoryDisplayName)
報告種別: \(issueType.rawValue)
選択肢: \(report.selectedChoice?.id ?? "未選択")

詳細:
\(detail)
"""
        body += "\n\n---\n問題文:\n\(report.quiz.question)\n"
        openMail(subject: subject, body: body)
    }

    private func openMail(subject: String, body: String) {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "fsmall.worldm@gmail.com"
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body),
        ]
        if let url = components.url {
            openURL(url)
            dismiss()
        }
    }
}

// MARK: - QuizChoiceButton

struct QuizChoiceButton: View {
    let choice: Quiz.Choice
    let isSelected: Bool
    let isAnswered: Bool
    let onTap: () -> Void

    private var borderColor: Color {
        guard isAnswered else { return isSelected ? Color.jbAccent : Color.jbBorder }
        if choice.correct { return Color.jbSuccess }
        if isSelected { return Color.jbError }
        return Color.jbBorder.opacity(0.3)
    }

    private var bgColor: Color {
        guard isAnswered else { return isSelected ? Color.jbAccent.opacity(0.1) : Color.jbCard }
        if choice.correct { return Color.jbSuccess.opacity(0.1) }
        if isSelected { return Color.jbError.opacity(0.1) }
        return Color.jbCard.opacity(0.5)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                Text(choice.text)
                    .font(.system(size: 15))
                    .foregroundStyle(
                        (isAnswered && !choice.correct && !isSelected)
                            ? Color.jbSubtext.opacity(0.5)
                            : Color.jbText
                    )
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isAnswered {
                    if choice.correct {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.jbSuccess)
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.jbError)
                    }
                }
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Radius.md)
                    .fill(bgColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .stroke(borderColor, lineWidth: 1.5)
                    )
            )
        }
        .disabled(isAnswered)
        .animation(.jbFast, value: isAnswered)
    }
}
