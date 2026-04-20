import SwiftUI

struct QuizView: View {
    @State var vm: QuizViewModel
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
            ForEach(vm.quiz.choices) { choice in
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
                }
                .foregroundStyle(Color.jbAccent)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbAccent, lineWidth: 1.5)
                )
            }

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
