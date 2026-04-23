import Charts
import SwiftUI

struct MockExamView: View {
    let session: QuizSession

    @State private var currentIndex = 0
    @State private var selectedChoiceIds: [String: String] = [:]
    @State private var elapsedSecondsByQuizId: [String: Int] = [:]
    @State private var choiceOrders: [String: [Quiz.Choice]]
    @State private var startedAt: Date
    @State private var endDate: Date
    @State private var submittedAttempt: MockExamAttempt?
    @State private var didSubmit = false
    @State private var showExitAlert = false
    @State private var showSubmitAlert = false
    @State private var reviewSession: QuizSession?
    @State private var progress = ProgressStore.shared
    @AppStorage("codeZoom") private var codeZoom: Double = CodeZoom.default
    @Environment(\.dismiss) private var dismiss

    init(session: QuizSession) {
        self.session = session

        let start = Date()
        let spec = MockExamSpec.official(version: session.version, level: session.level)
        let variant = session.mockExamVariant ?? .full
        let questionCount = max(session.quizzes.count, 1)
        let timeLimit = spec.durationSeconds(for: variant, questionCount: questionCount)
        let orders = Dictionary(uniqueKeysWithValues: session.quizzes.map { ($0.id, $0.choices.shuffled()) })

        self._startedAt = State(initialValue: start)
        self._endDate = State(initialValue: start.addingTimeInterval(TimeInterval(timeLimit)))
        self._choiceOrders = State(initialValue: orders)
    }

    private var variant: MockExamVariant {
        session.mockExamVariant ?? .full
    }

    private var spec: MockExamSpec {
        MockExamSpec.official(version: session.version, level: session.level)
    }

    private var currentQuiz: Quiz {
        session.quizzes[min(currentIndex, max(session.quizzes.count - 1, 0))]
    }

    private var timeLimitSeconds: Int {
        spec.durationSeconds(for: variant, questionCount: max(session.quizzes.count, 1))
    }

    var body: some View {
        NavigationStack {
            Group {
                if let attempt = submittedAttempt {
                    MockExamResultView(
                        session: session,
                        attempt: attempt,
                        history: progress.mockExamAttempts(
                            version: session.version,
                            level: session.level,
                            variant: variant
                        ),
                        onReviewWrong: { startReview(quizzes: wrongQuizzes(for: attempt), title: "模擬試験の間違い直し") },
                        onReviewAll: { startReview(quizzes: session.quizzes, title: "模擬試験の全問復習") },
                        onClose: { dismiss() }
                    )
                } else {
                    TimelineView(.periodic(from: .now, by: 1)) { timeline in
                        examBody(now: timeline.date)
                    }
                }
            }
            .navigationTitle(submittedAttempt == nil ? variant.displayName : "模擬試験サマリー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
        .interactiveDismissDisabled(submittedAttempt == nil)
        .alert("模擬試験を中断しますか？", isPresented: $showExitAlert) {
            Button("続ける", role: .cancel) {}
            Button("中断して閉じる", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("現在の回答と経過時間は保存されません。")
        }
        .alert("提出しますか？", isPresented: $showSubmitAlert) {
            Button("戻る", role: .cancel) {}
            Button("提出する") {
                submitExam(completedAt: Date())
            }
        } message: {
            Text(submitAlertMessage)
        }
        .sheet(item: $reviewSession) { session in
            QuizSheetView(session: session)
        }
        .task {
            await monitorTimeLimit()
        }
        .preferredColorScheme(.dark)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(submittedAttempt == nil ? "閉じる" : "完了") {
                if submittedAttempt == nil {
                    showExitAlert = true
                } else {
                    dismiss()
                }
            }
            .foregroundStyle(Color.jbSubtext)
        }

        ToolbarItem(placement: .principal) {
            VStack(spacing: 1) {
                Text(session.version.examCode(for: session.level))
                    .font(.system(size: 12, weight: .bold).monospacedDigit())
                    .foregroundStyle(Color.jbText)
                Text("\(variant.displayName) ・ \(session.quizzes.count)問")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.jbSubtext)
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            LevelBadgeView(
                level: session.level,
                zoomPercent: CodeZoom.percent(codeZoom),
                onTap: { codeZoom = CodeZoom.next(after: codeZoom) }
            )
        }
    }

    private func examBody(now: Date) -> some View {
        let remaining = remainingSeconds(now: now)

        return ZStack {
            Color.jbBackground.ignoresSafeArea()

            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        MockExamStatusBar(
                            currentIndex: currentIndex,
                            totalCount: session.quizzes.count,
                            answeredCount: selectedChoiceIds.count,
                            now: now,
                            remainingSeconds: remaining,
                            timeLimitSeconds: timeLimitSeconds,
                            passingScorePercent: spec.passingScorePercent
                        )

                        questionLayout(size: proxy.size)
                    }
                    .padding(Spacing.md)
                }
                .safeAreaInset(edge: .bottom) {
                    navigationBar
                }
            }
        }
    }

    @ViewBuilder
    private func questionLayout(size: CGSize) -> some View {
        if shouldUseSplitLayout(size) {
            HStack(alignment: .top, spacing: Spacing.md) {
                codeBlock(compactHeight: splitCodeHeight(for: size))
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                VStack(alignment: .leading, spacing: Spacing.lg) {
                    questionHeader
                    choicesSection
                    Spacer(minLength: Spacing.xl)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        } else {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                codeBlock()
                questionHeader
                choicesSection
                Spacer(minLength: Spacing.xxl)
            }
        }
    }

    @ViewBuilder
    private func codeBlock(compactHeight: CGFloat = 220) -> some View {
        if let codeTabs = currentQuiz.codeTabs, !codeTabs.isEmpty {
            CodeBlockView(
                tabs: codeTabs.map {
                    CodeBlockView.FileTab(id: $0.id, filename: $0.filename, code: $0.code)
                },
                zoom: codeZoom,
                compactHeight: compactHeight
            )
        } else {
            CodeBlockView(code: currentQuiz.code, zoom: codeZoom, compactHeight: compactHeight)
        }
    }

    private var questionHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                Text("問 \(currentIndex + 1)")
                    .font(.system(size: 12, weight: .bold).monospacedDigit())
                    .foregroundStyle(Color.jbAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.jbAccent.opacity(0.12)))

                Text(currentQuiz.categoryDisplayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.jbSubtext)

                Spacer()
            }

            Text(currentQuiz.question)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.jbText)
                .lineSpacing(4)
        }
    }

    private var choicesSection: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(choiceOrders[currentQuiz.id] ?? currentQuiz.choices) { choice in
                MockExamChoiceButton(
                    choice: choice,
                    isSelected: selectedChoiceIds[currentQuiz.id] == choice.id,
                    onTap: { select(choice) }
                )
            }
        }
    }

    private var navigationBar: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: { move(by: -1) }) {
                Label("前へ", systemImage: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(currentIndex == 0 ? Color.jbSubtext.opacity(0.5) : Color.jbText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .fill(Color.jbCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: Radius.md)
                                    .stroke(Color.jbBorder, lineWidth: 1)
                            )
                    )
            }
            .disabled(currentIndex == 0)
            .buttonStyle(.plain)

            Button(action: nextOrSubmit) {
                HStack(spacing: 6) {
                    Text(currentIndex == session.quizzes.count - 1 ? "提出" : "次へ")
                    Image(systemName: currentIndex == session.quizzes.count - 1 ? "paperplane.fill" : "chevron.right")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .fill(currentIndex == session.quizzes.count - 1 ? Color.jbSuccess : Color.jbAccent)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.sm)
        .background(.ultraThinMaterial)
    }

    private var submitAlertMessage: String {
        let unanswered = session.quizzes.count - selectedChoiceIds.count
        if unanswered > 0 {
            return "未回答が \(unanswered) 問あります。未回答は不正解として採点されます。"
        }
        return "提出後に採点し、模擬試験履歴として保存します。"
    }

    private func shouldUseSplitLayout(_ size: CGSize) -> Bool {
        size.width > size.height && size.width >= 680
    }

    private func splitCodeHeight(for size: CGSize) -> CGFloat {
        min(max(size.height - Spacing.xl, 260), 560)
    }

    private func remainingSeconds(now: Date) -> Int {
        max(0, Int(endDate.timeIntervalSince(now).rounded(.up)))
    }

    private func select(_ choice: Quiz.Choice) {
        withAnimation(.snappy(duration: 0.18, extraBounce: 0.02)) {
            selectedChoiceIds[currentQuiz.id] = choice.id
            elapsedSecondsByQuizId[currentQuiz.id] = max(1, Int(Date().timeIntervalSince(startedAt).rounded()))
        }
    }

    private func move(by offset: Int) {
        let next = min(max(currentIndex + offset, 0), session.quizzes.count - 1)
        guard next != currentIndex else { return }
        withAnimation(.snappy(duration: 0.22, extraBounce: 0.03)) {
            currentIndex = next
        }
    }

    private func nextOrSubmit() {
        if currentIndex == session.quizzes.count - 1 {
            showSubmitAlert = true
        } else {
            move(by: 1)
        }
    }

    private func monitorTimeLimit() async {
        while !didSubmit {
            if Date() >= endDate {
                await MainActor.run {
                    submitExam(completedAt: Date())
                }
                return
            }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
    }

    @MainActor
    private func submitExam(completedAt: Date) {
        guard !didSubmit else { return }
        didSubmit = true

        let answers = session.quizzes.map { quiz in
            let selectedId = selectedChoiceIds[quiz.id]
            let correctChoice = quiz.choices.first { $0.correct }
            return MockExamAnswer(
                quizId: quiz.id,
                category: quiz.canonicalCategoryRawValue,
                tags: quiz.tags,
                selectedChoiceId: selectedId,
                correctChoiceId: correctChoice?.id ?? "",
                correct: selectedId == correctChoice?.id,
                elapsedSeconds: elapsedSecondsByQuizId[quiz.id]
            )
        }

        let attempt = MockExamAttempt(
            version: session.version,
            level: session.level,
            variant: variant,
            startedAt: startedAt,
            completedAt: completedAt,
            timeLimitSeconds: timeLimitSeconds,
            elapsedSeconds: min(timeLimitSeconds, max(1, Int(completedAt.timeIntervalSince(startedAt).rounded()))),
            questionCount: session.quizzes.count,
            correctCount: answers.filter(\.correct).count,
            passingScorePercent: spec.passingScorePercent,
            answers: answers
        )

        progress.recordMockExamAttempt(attempt, quizzes: session.quizzes)
        withAnimation(.jbSpring) {
            submittedAttempt = attempt
        }
    }

    private func wrongQuizzes(for attempt: MockExamAttempt) -> [Quiz] {
        let wrongIds = Set(attempt.answers.filter { !$0.correct }.map(\.quizId))
        return session.quizzes.filter { wrongIds.contains($0.id) }
    }

    private func startReview(quizzes: [Quiz], title: String) {
        guard !quizzes.isEmpty else { return }
        reviewSession = QuizSession(
            mode: .daily,
            level: session.level,
            version: session.version,
            quizzes: quizzes,
            customTitle: title
        )
    }
}

private struct MockExamStatusBar: View {
    let currentIndex: Int
    let totalCount: Int
    let answeredCount: Int
    let now: Date
    let remainingSeconds: Int
    let timeLimitSeconds: Int
    let passingScorePercent: Int

    private var remainingColor: Color {
        let ratio = Double(remainingSeconds) / Double(max(timeLimitSeconds, 1))
        if ratio <= 0.12 { return Color.jbError }
        if ratio <= 0.25 { return Color.jbWarning }
        return Color.jbAccent
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text("残り \(Self.timeText(remainingSeconds))")
                    .font(.system(size: 24, weight: .heavy).monospacedDigit())
                    .foregroundStyle(remainingColor)
                    .contentTransition(.numericText())

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(Self.clockText(now))
                        .font(.system(size: 12, weight: .bold).monospacedDigit())
                        .foregroundStyle(Color.jbSubtext)
                    Text("\(currentIndex + 1)/\(totalCount)")
                        .font(.system(size: 14, weight: .bold).monospacedDigit())
                        .foregroundStyle(Color.jbText)
                }
            }

            HStack(spacing: Spacing.sm) {
                statusPill("回答済み", "\(answeredCount)/\(totalCount)")
                statusPill("合格基準", "\(passingScorePercent)%")
                statusPill("残り", "\(max(totalCount - answeredCount, 0))問")
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(remainingColor.opacity(0.35), lineWidth: 1.2)
                )
        )
    }

    private func statusPill(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 13, weight: .bold).monospacedDigit())
                .foregroundStyle(Color.jbText)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.jbSubtext)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.sm)
                .fill(Color.jbBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .stroke(Color.jbBorder, lineWidth: 1)
                )
        )
    }

    static func timeText(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%02d:%02d", minutes, remainder)
    }

    static func clockText(_ date: Date) -> String {
        clockFormatter.string(from: date)
    }

    private static let clockFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}

private struct MockExamChoiceButton: View {
    let choice: Quiz.Choice
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.jbAccent : Color.jbSubtext)
                    .frame(width: 24, height: 24)
                    .contentTransition(.symbolEffect(.replace))

                Text(choice.text)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.jbText)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Radius.md)
                    .fill(isSelected ? Color.jbAccent.opacity(0.1) : Color.jbCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .stroke(isSelected ? Color.jbAccent : Color.jbBorder, lineWidth: isSelected ? 1.5 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.snappy(duration: 0.18, extraBounce: 0.02), value: isSelected)
    }
}

private struct MockExamResultView: View {
    let session: QuizSession
    let attempt: MockExamAttempt
    let history: [MockExamAttempt]
    let onReviewWrong: () -> Void
    let onReviewAll: () -> Void
    let onClose: () -> Void

    private var wrongCount: Int {
        attempt.questionCount - attempt.correctCount
    }

    private var passCount: Int {
        history.filter(\.isPassing).count
    }

    private var bestScore: Int {
        history.map(\.scorePercent).max() ?? attempt.scorePercent
    }

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    summaryCard
                    historyCard
                    reviewActions
                    explanations
                }
                .padding(Spacing.md)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: attempt.isPassing ? "checkmark.seal.fill" : "chart.bar.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(attempt.isPassing ? Color.jbSuccess : Color.jbWarning)
                Spacer()
                LevelBadgeView(level: session.level)
            }

            Text(attempt.isPassing ? "合格ゾーン" : "もう少しで合格ゾーン")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.jbText)

            Text("\(session.version.examCode(for: session.level)) / \(attempt.variant.displayName) / \(Self.dateText(attempt.completedAt))")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.jbSubtext)
                .lineLimit(2)
                .minimumScaleFactor(0.84)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(attempt.scorePercent)")
                    .font(.system(size: 54, weight: .heavy).monospacedDigit())
                    .foregroundStyle(attempt.isPassing ? Color.jbSuccess : Color.jbWarning)
                Text("%")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.jbSubtext)
            }

            HStack(spacing: Spacing.sm) {
                MockResultMetric(title: "正解", value: "\(attempt.correctCount)問", color: Color.jbSuccess)
                MockResultMetric(title: "不正解", value: "\(wrongCount)問", color: Color.jbError)
                MockResultMetric(title: "時間", value: MockExamStatusBar.timeText(attempt.elapsedSeconds), color: Color.jbAccent)
            }
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(attempt.isPassing ? Color.jbSuccess.opacity(0.35) : Color.jbWarning.opacity(0.35), lineWidth: 1.5)
                )
        )
    }

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("直近10回の推移")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.jbText)
                Spacer()
                Text("\(passCount)/\(history.count) 合格 ・ Best \(bestScore)%")
                    .font(.system(size: 11, weight: .semibold).monospacedDigit())
                    .foregroundStyle(Color.jbSubtext)
            }

            if history.count >= 2 {
                Chart {
                    ForEach(chartPoints) { point in
                        LineMark(
                            x: .value("実施", point.index),
                            y: .value("正答率", point.scorePercent)
                        )
                        .foregroundStyle(Color.jbAccent)
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("実施", point.index),
                            y: .value("正答率", point.scorePercent)
                        )
                        .foregroundStyle(point.isPassing ? Color.jbSuccess : Color.jbWarning)
                    }

                    RuleMark(y: .value("合格基準", attempt.passingScorePercent))
                        .foregroundStyle(Color.jbSubtext.opacity(0.45))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }
                .chartYScale(domain: 0...100)
                .frame(height: 170)
            } else {
                Text("2回目以降に折れ線グラフが表示されます。")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.jbSubtext)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Spacing.md)
                    .background(RoundedRectangle(cornerRadius: Radius.sm).fill(Color.jbBackground))
            }

            VStack(spacing: Spacing.xs) {
                ForEach(history.suffix(10).reversed()) { item in
                    HStack {
                        Text(Self.dateText(item.completedAt))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.jbSubtext)
                        Spacer()
                        Text("\(item.scorePercent)%")
                            .font(.system(size: 12, weight: .bold).monospacedDigit())
                            .foregroundStyle(item.isPassing ? Color.jbSuccess : Color.jbWarning)
                        Text(item.isPassing ? "合格" : "未達")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(item.isPassing ? Color.jbSuccess : Color.jbWarning)
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbBorder, lineWidth: 1)
                )
        )
    }

    private var reviewActions: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: onReviewWrong) {
                Label("間違いを解き直す", systemImage: "arrow.counterclockwise")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(wrongCount == 0 ? Color.jbSubtext.opacity(0.5) : .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .fill(wrongCount == 0 ? Color.jbCard : Color.jbAccent)
                    )
            }
            .disabled(wrongCount == 0)
            .buttonStyle(.plain)

            Button(action: onReviewAll) {
                Label("全問を復習", systemImage: "book.closed.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.jbText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .fill(Color.jbCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: Radius.md)
                                    .stroke(Color.jbBorder, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var explanations: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("問題ごとの解説")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.jbText)

            ForEach(session.quizzes) { quiz in
                if let answer = attempt.answers.first(where: { $0.quizId == quiz.id }) {
                    MockExamAnswerReviewRow(quiz: quiz, answer: answer)
                }
            }

            Button(action: onClose) {
                HStack {
                    Text("閉じる")
                        .font(.system(size: 15, weight: .bold))
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .fill(attempt.isPassing ? Color.jbSuccess : Color.jbAccent)
                )
            }
            .buttonStyle(.plain)
            .padding(.top, Spacing.sm)
        }
    }

    private var chartPoints: [MockExamChartPoint] {
        history.enumerated().map { index, attempt in
            MockExamChartPoint(
                id: attempt.id,
                index: index + 1,
                scorePercent: attempt.scorePercent,
                isPassing: attempt.isPassing
            )
        }
    }

    private static func dateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

private struct MockResultMetric: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .bold).monospacedDigit())
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.jbSubtext)
        }
        .padding(Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.sm)
                .fill(Color.jbBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .stroke(Color.jbBorder, lineWidth: 1)
                )
        )
    }
}

private struct MockExamChartPoint: Identifiable {
    let id: UUID
    let index: Int
    let scorePercent: Int
    let isPassing: Bool
}

private struct MockExamAnswerReviewRow: View {
    let quiz: Quiz
    let answer: MockExamAnswer
    @State private var isExpanded = false

    private var selectedChoice: Quiz.Choice? {
        guard let id = answer.selectedChoiceId else { return nil }
        return quiz.choices.first { $0.id == id }
    }

    private var correctChoice: Quiz.Choice? {
        quiz.choices.first { $0.id == answer.correctChoiceId }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.snappy(duration: 0.22, extraBounce: 0.03)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: answer.correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(answer.correct ? Color.jbSuccess : Color.jbError)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(quiz.categoryDisplayName)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.jbText)
                        Text(quiz.id)
                            .font(.system(size: 10, weight: .medium).monospacedDigit())
                            .foregroundStyle(Color.jbSubtext)
                            .lineLimit(1)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.jbSubtext)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(Spacing.md)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(quiz.question)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.jbText)
                        .lineSpacing(3)

                    explanationLine("選択", selectedChoice?.text ?? "未回答", color: answer.correct ? Color.jbSuccess : Color.jbError)
                    explanationLine("正解", correctChoice?.text ?? "-", color: Color.jbSuccess)

                    if let selectedChoice {
                        Text(selectedChoice.explanation)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.jbText)
                            .lineSpacing(3)
                    }

                    Text(quiz.designIntent)
                        .font(.system(size: 12).italic())
                        .foregroundStyle(Color.jbSubtext)
                        .lineSpacing(3)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.md)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(answer.correct ? Color.jbSuccess.opacity(0.22) : Color.jbError.opacity(0.26), lineWidth: 1)
                )
        )
    }

    private func explanationLine(_ label: String, _ value: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 36, alignment: .leading)
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.jbText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.sm)
        .background(RoundedRectangle(cornerRadius: Radius.sm).fill(Color.jbBackground))
    }
}
