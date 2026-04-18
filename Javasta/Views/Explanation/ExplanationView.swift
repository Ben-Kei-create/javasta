import SwiftUI

struct ExplanationView: View {
    @State private var vm: ExplanationViewModel
    var onDismiss: () -> Void

    init(explanation: Explanation, onDismiss: @escaping () -> Void) {
        self._vm = State(wrappedValue: ExplanationViewModel(explanation: explanation))
        self.onDismiss = onDismiss
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.jbBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    headerBar
                    Divider().background(Color.jbBorder)

                    CodePanelView(
                        code: vm.explanation.initialCode,
                        highlightLines: vm.currentStep.highlightLines
                    )
                    .frame(maxHeight: geo.size.height * 0.38)
                    .background(Color.jbBackground)

                    Divider().background(Color.jbBorder)

                    VariablePanelView(
                        variables: vm.currentStep.variables,
                        previousVariables: vm.previousStep?.variables ?? [],
                        callStack: vm.currentStep.callStack
                    )
                    .background(Color.jbCard)

                    Divider().background(Color.jbBorder)

                    ScrollView {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text(vm.currentStep.narration)
                                .font(.system(size: 15))
                                .foregroundStyle(Color.jbText)
                                .lineSpacing(5)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if let predict = vm.currentStep.predict {
                                PredictView(
                                    predict: predict,
                                    selectedIndex: vm.predictSelectedIndex,
                                    isAnswered: vm.predictAnswered,
                                    showHint: vm.showPredictHint,
                                    onSelect: { vm.selectPredict(index: $0) },
                                    onHint: { vm.showPredictHint = true }
                                )
                                .transition(.push(from: .bottom))
                            }

                            if vm.isComplete && !vm.isPredictBlocking {
                                completionBanner
                                    .transition(.push(from: .bottom))
                            }
                        }
                        .padding(Spacing.md)
                        .animation(.jbSpring, value: vm.currentStepIndex)
                    }
                    .background(Color.jbBackground)

                    Divider().background(Color.jbBorder)
                    navigationBar
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: Header

    private var headerBar: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.jbSubtext)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.jbCard))
            }

            Spacer()

            ProgressView(value: vm.progress)
                .tint(Color.jbAccent)
                .frame(width: 100)
                .scaleEffect(x: 1, y: 1.4)

            Spacer()

            Text("\(vm.currentStepIndex + 1) / \(vm.explanation.steps.count)")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.jbSubtext)
                .monospacedDigit()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: Navigation bar

    private var navigationBar: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: vm.goBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("戻る")
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(vm.canGoBack ? Color.jbText : Color.jbSubtext.opacity(0.4))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .fill(Color.jbCard)
                )
            }
            .disabled(!vm.canGoBack)

            Button(action: vm.goForward) {
                HStack(spacing: 4) {
                    Text(vm.isComplete ? "完了" : "進む")
                    Image(systemName: vm.isComplete ? "checkmark" : "chevron.right")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(vm.isPredictBlocking ? Color.jbText.opacity(0.4) : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .fill(
                            vm.isPredictBlocking
                                ? Color.jbAccent.opacity(0.25)
                                : (vm.isComplete ? Color.jbSuccess : Color.jbAccent)
                        )
                )
            }
            .disabled(vm.isPredictBlocking)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.jbBackground)
    }

    // MARK: Completion

    private var completionBanner: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.jbSuccess)
                .font(.system(size: 20))
            VStack(alignment: .leading, spacing: 2) {
                Text("ステップ完走")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.jbSuccess)
                Text("コードの流れを理解できました")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.jbSubtext)
            }
            Spacer()
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbSuccess.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbSuccess.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - PredictView

struct PredictView: View {
    let predict: Explanation.PredictPrompt
    let selectedIndex: Int?
    let isAnswered: Bool
    let showHint: Bool
    let onSelect: (Int) -> Void
    let onHint: () -> Void

    var isCorrect: Bool {
        selectedIndex == predict.answerIndex
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.jbWarning)
                Text("予測してみよう")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.jbWarning)
            }

            Text(predict.question)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.jbText)

            VStack(spacing: Spacing.xs) {
                ForEach(Array(predict.choices.enumerated()), id: \.offset) { idx, choice in
                    PredictChoiceRow(
                        text: choice,
                        index: idx,
                        selectedIndex: selectedIndex,
                        correctIndex: predict.answerIndex,
                        isAnswered: isAnswered,
                        onTap: { onSelect(idx) }
                    )
                }
            }

            if isAnswered {
                HStack(alignment: .top, spacing: Spacing.xs) {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "info.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(isCorrect ? Color.jbSuccess : Color.jbError)
                        .padding(.top, 1)
                    Text(predict.afterExplanation)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.jbSubtext)
                        .lineSpacing(3)
                }
                .padding(Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .fill(Color.jbBackground)
                )
            } else if !showHint {
                Button(action: onHint) {
                    Text("ヒントを見る")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.jbSubtext)
                        .underline()
                }
            } else {
                Text("ヒント: \(predict.hint)")
                    .font(.system(size: 12).italic())
                    .foregroundStyle(Color.jbSubtext)
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbWarning.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

// MARK: - PredictChoiceRow

private struct PredictChoiceRow: View {
    let text: String
    let index: Int
    let selectedIndex: Int?
    let correctIndex: Int
    let isAnswered: Bool
    let onTap: () -> Void

    private var isSelected: Bool { selectedIndex == index }
    private var isCorrect: Bool  { index == correctIndex }

    private var borderColor: Color {
        guard isAnswered else { return isSelected ? Color.jbAccent : Color.jbBorder }
        if isCorrect { return Color.jbSuccess }
        if isSelected { return Color.jbError }
        return Color.jbBorder.opacity(0.3)
    }

    private var bgColor: Color {
        guard isAnswered else { return isSelected ? Color.jbAccent.opacity(0.08) : Color.clear }
        if isCorrect { return Color.jbSuccess.opacity(0.08) }
        if isSelected { return Color.jbError.opacity(0.08) }
        return Color.clear
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(text)
                    .font(.codeFont(12))
                    .foregroundStyle(
                        (isAnswered && !isCorrect && !isSelected)
                            ? Color.jbSubtext.opacity(0.5)
                            : Color.jbText
                    )
                Spacer()
                if isAnswered {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.jbSuccess)
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(Color.jbError)
                    }
                }
            }
            .font(.system(size: 13))
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(bgColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(borderColor, lineWidth: 1)
                    )
            )
        }
        .disabled(isAnswered)
        .animation(.jbFast, value: isAnswered)
    }
}
