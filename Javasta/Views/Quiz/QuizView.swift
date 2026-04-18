import SwiftUI

struct QuizView: View {
    @State var vm: QuizViewModel
    var codeZoom: Double = 1.0
    var onShowExplanation: () -> Void

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    codeBlock
                    questionSection
                    choicesSection

                    if vm.isAnswered {
                        resultSection
                            .transition(.asymmetric(
                                insertion: .push(from: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }

                    Spacer(minLength: Spacing.xxl)
                }
                .padding(Spacing.md)
                .animation(.jbSpring, value: vm.isAnswered)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: Code block

    private var codeBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Circle().fill(Color(hex: "FF5F57")).frame(width: 9, height: 9)
                Circle().fill(Color(hex: "FEBC2E")).frame(width: 9, height: 9)
                Circle().fill(Color(hex: "28C840")).frame(width: 9, height: 9)
                Spacer()
                Text("Java")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.jbSubtext)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)

            Divider().background(Color.jbBorder)

            CodePanelView(code: vm.quiz.code, highlightLines: [], zoom: codeZoom)
                .frame(maxHeight: 220)
        }
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbBorder, lineWidth: 1)
                )
        )
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

    // MARK: Result

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
                Text(choice.explanation)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.jbText)
                    .lineSpacing(4)
            }

            Text(vm.quiz.designIntent)
                .font(.system(size: 13).italic())
                .foregroundStyle(Color.jbSubtext)
                .padding(Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .fill(Color.jbBackground)
                )

            Button(action: onShowExplanation) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 17))
                    Text("コードの実行を追う")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Color.jbAccent)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbAccent, lineWidth: 1.5)
                )
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
        )
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
