import SwiftUI

struct ExplanationView: View {
    @State private var vm: ExplanationViewModel
    @State private var activeLesson: Lesson?
    @AppStorage("codeZoom") private var codeZoom: Double = CodeZoom.default
    let level: JavaLevel
    var onDismiss: () -> Void

    init(explanation: Explanation, level: JavaLevel, onDismiss: @escaping () -> Void) {
        self._vm = State(wrappedValue: ExplanationViewModel(explanation: explanation))
        self.level = level
        self.onDismiss = onDismiss
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.jbBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    headerBar
                    Divider().background(Color.jbBorder)

                    explanationCodeView(maxHeight: geo.size.height * 0.38)

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
                            traceStatusBanner

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
        .sensoryFeedback(.selection, trigger: codeZoom)
        .sheet(item: $activeLesson) { lesson in
            NavigationStack {
                LessonDetailView(lesson: lesson)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("閉じる") { activeLesson = nil }
                                .foregroundStyle(Color.jbSubtext)
                        }
                    }
            }
            .preferredColorScheme(.dark)
        }
    }

    private var relatedGlossaryTerms: [GlossaryTerm] {
        let lessonId = vm.explanation.relatedLessonId
        let quizIds = Set(Quiz.samples
            .filter { $0.explanationRef == vm.explanation.id }
            .map(\.id))

        return GlossaryTerm.samples.filter { term in
            let byLesson = lessonId.map { term.relatedLessonIds.contains($0) } ?? false
            let byQuiz = !quizIds.isDisjoint(with: term.relatedQuizIds)
            return byLesson || byQuiz
        }
    }

    private var traceStatus: ExplanationTraceStatus {
        Explanation.traceStatus(for: vm.explanation.id)
    }

    private var linkedQuiz: Quiz? {
        Quiz.samples.first { $0.explanationRef == vm.explanation.id }
    }

    @ViewBuilder
    private func explanationCodeView(maxHeight: CGFloat) -> some View {
        if let codeTabs = vm.explanation.codeTabs, !codeTabs.isEmpty {
            CodeBlockView(
                tabs: codeTabs.map {
                    CodeBlockView.FileTab(id: $0.id, filename: $0.filename, code: $0.code)
                },
                highlightLines: vm.currentStep.highlightLines,
                zoom: codeZoom,
                compactHeight: maxHeight
            )
            .frame(maxHeight: maxHeight)
            .background(Color.jbBackground)
        } else {
            CodePanelView(
                code: vm.explanation.initialCode,
                highlightLines: vm.currentStep.highlightLines,
                zoom: codeZoom
            )
            .frame(maxHeight: maxHeight)
            .background(Color.jbBackground)
        }
    }

    // MARK: Header

    private var headerBar: some View {
        HStack(spacing: Spacing.sm) {
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

            TraceStatusPill(status: traceStatus)

            LevelBadgeView(
                level: level,
                zoomPercent: CodeZoom.percent(codeZoom),
                onTap: { codeZoom = CodeZoom.next(after: codeZoom) }
            )
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    @ViewBuilder
    private var traceStatusBanner: some View {
        if traceStatus != .authored {
            HStack(alignment: .top, spacing: Spacing.sm) {
                Image(systemName: traceStatus.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(traceStatus.tint)
                    .padding(.top, 1)

                VStack(alignment: .leading, spacing: 3) {
                    Text(traceStatus.bannerTitle)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(traceStatus.tint)
                    Text(traceStatus.bannerBody(ref: vm.explanation.id, quizId: linkedQuiz?.id))
                        .font(.system(size: 12))
                        .foregroundStyle(Color.jbSubtext)
                        .lineSpacing(2)
                }
            }
            .padding(Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(traceStatus.tint.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(traceStatus.tint.opacity(0.25), lineWidth: 1)
                    )
            )
        }
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

            Button(action: {
                if vm.isComplete { onDismiss() } else { vm.goForward() }
            }) {
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
        VStack(alignment: .leading, spacing: Spacing.sm) {
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

            if !relatedGlossaryTerms.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("関連用語")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.jbSubtext)
                    termPills
                }
            }

            if let lessonId = vm.explanation.relatedLessonId,
               let lesson = Lesson.sample(for: lessonId) {
                Button(action: { activeLesson = lesson }) {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 14))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("詳しく学ぶ: \(lesson.title)")
                                .font(.system(size: 13, weight: .semibold))
                            Text("\(lesson.estimatedMinutes)分のレッスン")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.jbSubtext)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.jbSubtext)
                    }
                    .foregroundStyle(Color.jbAccent)
                    .padding(Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .fill(Color.jbBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: Radius.sm)
                                    .stroke(Color.jbAccent.opacity(0.4), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
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

    private var termPills: some View {
        let terms = Array(relatedGlossaryTerms.prefix(6))
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 6)], alignment: .leading, spacing: 6) {
            ForEach(terms, id: \.id) { term in
                Text(term.term)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.jbAccent)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.jbAccent.opacity(0.12))
                            .overlay(
                                Capsule().stroke(Color.jbAccent.opacity(0.35), lineWidth: 1)
                            )
                    )
            }
        }
    }
}

// MARK: - TraceStatusPill

private struct TraceStatusPill: View {
    let status: ExplanationTraceStatus

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: status.icon)
                .font(.system(size: 8, weight: .bold))
            Text(status.shortTitle)
                .font(.system(size: 9, weight: .bold))
        }
        .foregroundStyle(status.tint)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Capsule().fill(status.tint.opacity(0.12)))
    }
}

private extension ExplanationTraceStatus {
    var shortTitle: String {
        switch self {
        case .authored: return "手書き"
        case .placeholder: return "汎用"
        case .missing: return "未解決"
        }
    }

    var icon: String {
        switch self {
        case .authored: return "checkmark.seal.fill"
        case .placeholder: return "doc.text"
        case .missing: return "link.badge.plus"
        }
    }

    var tint: Color {
        switch self {
        case .authored: return Color.jbSuccess
        case .placeholder: return Color.jbWarning
        case .missing: return Color.jbError
        }
    }

    var bannerTitle: String {
        switch self {
        case .authored: return "手書き解説"
        case .placeholder: return "汎用解説で表示中"
        case .missing: return "解説の紐付け未解決"
        }
    }

    func bannerBody(ref: String, quizId: String?) -> String {
        switch self {
        case .authored:
            return "この問題には手書きの実行追跡があります。"
        case .placeholder:
            return "quickTrace による自動生成の3ステップ解説です。quiz: \(quizId ?? "-") / ref: \(ref)"
        case .missing:
            return "Explanation.sample(for:) で解決できません。quiz: \(quizId ?? "-") / ref: \(ref)"
        }
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
