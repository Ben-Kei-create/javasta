import SwiftUI

struct HomeView: View {
    @State private var activeSession: QuizSession?
    @State private var progress = ProgressStore.shared
    @State private var selectedLevel: JavaLevel = .silver
    @State private var showSettings = false
    @State private var showEmptySessionAlert = false
    @State private var emptySessionMessage = ""
    @AppStorage("selectedExamVersion") private var selectedExamVersionRaw = JavaExamVersion.se17.rawValue

    private var selectedVersion: JavaExamVersion {
        JavaExamVersion(rawValue: selectedExamVersionRaw) ?? .se17
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.jbBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        headerSection
                        commandCenter
                        practiceModesSection
                        coverageSection
                        weaknessSection
                        ForEach(JavaLevel.allCases, id: \.self) { level in
                            LevelSectionView(
                                level: level,
                                version: selectedVersion,
                                quizzes: QuestionBank.quizzes(version: selectedVersion, level: level),
                                onSelect: { activeSession = QuizSession.single($0) }
                            )
                        }
                    }
                    .padding(.bottom, Spacing.xxl)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .sheet(item: $activeSession) { session in
            QuizSheetView(session: session)
        }
        .alert("開始できません", isPresented: $showEmptySessionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(emptySessionMessage)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("ジャバスタ")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundStyle(Color.jbText)
                HStack(spacing: 6) {
                    Text("Java資格 × 本質理解")
                    Text(selectedVersion.examCode(for: selectedLevel))
                        .font(.system(size: 11, weight: .bold).monospacedDigit())
                        .foregroundStyle(Color.jbAccent)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.jbAccent.opacity(0.12)))
                }
                .font(.system(size: 14))
                .foregroundStyle(Color.jbSubtext)
            }

            Spacer()

            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.jbSubtext)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.lg)
    }

    // MARK: Command center

    private var commandCenter: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(alignment: .top, spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(selectedLevel.displayName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.jbText)
                    Text("\(selectedVersion.displayName) / \(selectedVersion.examCode(for: selectedLevel))")
                        .font(.system(size: 12, weight: .semibold).monospacedDigit())
                        .foregroundStyle(Color.jbAccent)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("今日")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.jbSubtext)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(progress.todayAnswered)")
                            .font(.system(size: 28, weight: .bold).monospacedDigit())
                            .foregroundStyle(progress.todayAnswered >= progress.dailyGoal ? Color.jbSuccess : Color.jbAccent)
                        Text("/\(progress.dailyGoal)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.jbSubtext)
                    }
                }
            }

            levelPicker

            HStack(spacing: Spacing.sm) {
                CommandMetric(
                    title: "正答率",
                    value: progress.totalAnswered > 0 ? "\(progress.accuracyPercent)%" : "—",
                    icon: "chart.line.uptrend.xyaxis",
                    color: accuracyColor
                )
                CommandMetric(
                    title: "連続",
                    value: "\(progress.streakDays)日",
                    icon: "flame.fill",
                    color: Color.jbWarning
                )
                CommandMetric(
                    title: "解答済み",
                    value: "\(progress.answeredCount(level: selectedLevel))問",
                    icon: "checkmark.seal.fill",
                    color: Color.jbSuccess
                )
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
        .padding(.horizontal, Spacing.md)
    }

    private var levelPicker: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(JavaLevel.allCases, id: \.self) { level in
                Button(action: { selectedLevel = level }) {
                    Text(level.displayName.replacingOccurrences(of: "Java ", with: ""))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(selectedLevel == level ? .white : Color.jbSubtext)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.sm)
                                .fill(selectedLevel == level ? Color.jbAccent : Color.jbBackground)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: Practice modes

    private var practiceModesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionHeader("練習を開始", trailing: "\(QuestionBank.quizzes(version: selectedVersion, level: selectedLevel).count)問")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                ForEach(QuizPracticeMode.allCases) { mode in
                    PracticeModeCard(
                        mode: mode,
                        isPrimary: mode == .daily,
                        onTap: { start(mode) }
                    )
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }

    private var coverageSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionHeader("試験範囲カバー", trailing: selectedVersion.displayName)
            VStack(spacing: Spacing.xs) {
                ForEach(QuestionBank.coverage(version: selectedVersion, level: selectedLevel), id: \.objective.id) { row in
                    ObjectiveCoverageRow(objective: row.objective, count: row.count)
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }

    private var weaknessSection: some View {
        let weakTags = progress.weakTags(limit: 4)
        return VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionHeader("弱点インサイト", trailing: progress.answerHistory.isEmpty ? "未分析" : "\(weakTags.count)件")

            if weakTags.isEmpty {
                EmptyInsightRow()
                    .padding(.horizontal, Spacing.md)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(weakTags) { tag in
                            WeakTagCard(summary: tag)
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private func sectionHeader(_ title: String, trailing: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.jbText)
            Spacer()
            Text(trailing)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.jbSubtext)
        }
        .padding(.horizontal, Spacing.md)
    }

    private func start(_ mode: QuizPracticeMode) {
        if let session = QuestionBank.makeSession(
            mode: mode,
            version: selectedVersion,
            level: selectedLevel,
            progress: progress
        ) {
            activeSession = session
        } else {
            emptySessionMessage = "\(selectedLevel.displayName) の問題がまだありません。"
            showEmptySessionAlert = true
        }
    }

    private var accuracyColor: Color {
        guard progress.totalAnswered > 0 else { return Color.jbSubtext }
        let p = progress.accuracyPercent
        if p >= 70 { return Color.jbSuccess }
        if p >= 40 { return Color.jbWarning }
        return Color.jbError
    }
}

// MARK: - CommandMetric

private struct CommandMetric: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 17, weight: .bold).monospacedDigit())
                .foregroundStyle(Color.jbText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(title)
                .font(.system(size: 10, weight: .medium))
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

// MARK: - PracticeModeCard

private struct PracticeModeCard: View {
    let mode: QuizPracticeMode
    let isPrimary: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: mode.icon)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(isPrimary ? .white : Color.jbAccent)
                        .frame(width: 30, height: 30)
                        .background(
                            Circle().fill(isPrimary ? Color.white.opacity(0.18) : Color.jbAccent.opacity(0.12))
                        )
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(isPrimary ? .white.opacity(0.8) : Color.jbSubtext)
                }

                Text(mode.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(isPrimary ? .white : Color.jbText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(mode.subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(isPrimary ? .white.opacity(0.76) : Color.jbSubtext)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: Radius.md)
                    .fill(isPrimary ? Color.jbAccent : Color.jbCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .stroke(isPrimary ? Color.jbAccent : Color.jbBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ObjectiveCoverageRow

private struct ObjectiveCoverageRow: View {
    let objective: ExamObjective
    let count: Int

    private var countColor: Color {
        if count == 0 { return Color.jbError }
        if count < 3 { return Color.jbWarning }
        return Color.jbSuccess
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: count == 0 ? "circle" : "checkmark.circle.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(countColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(objective.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.jbText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(objective.category.displayName)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.jbSubtext)
            }

            Spacer()

            Text("\(count)問")
                .font(.system(size: 12, weight: .bold).monospacedDigit())
                .foregroundStyle(countColor)
                .frame(minWidth: 42, alignment: .trailing)
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
}

// MARK: - WeakTagCard

private struct WeakTagCard: View {
    let summary: WeakTagSummary

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.jbWarning)
                Spacer()
                Text("\(summary.missRatePercent)%")
                    .font(.system(size: 13, weight: .bold).monospacedDigit())
                    .foregroundStyle(Color.jbWarning)
            }
            Text(summary.tag)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.jbText)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
            Text("\(summary.misses)/\(summary.attempts) ミス")
                .font(.system(size: 11))
                .foregroundStyle(Color.jbSubtext)
        }
        .padding(Spacing.md)
        .frame(width: 150, height: 96, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbWarning.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbWarning.opacity(0.35), lineWidth: 1)
                )
        )
    }
}

// MARK: - EmptyInsightRow

private struct EmptyInsightRow: View {
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.jbAccent)
            Text("数問解くと、タグ単位で苦手が見えてきます")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.jbSubtext)
            Spacer()
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
}

// MARK: - LevelSectionView

struct LevelSectionView: View {
    let level: JavaLevel
    let version: JavaExamVersion
    let quizzes: [Quiz]
    let onSelect: (Quiz) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Text(level.displayName)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(Color.jbText)
                LevelBadgeView(level: level)
                Spacer()
                NavigationLink {
                    AllQuizzesView(level: level, version: version, onSelect: onSelect)
                } label: {
                    HStack(spacing: 2) {
                        Text("すべて見る")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(Color.jbAccent)
                }
            }
            .padding(.horizontal, Spacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(quizzes) { quiz in
                        QuizCardView(quiz: quiz, onTap: { onSelect(quiz) })
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - QuizCardView

struct QuizCardView: View {
    let quiz: Quiz
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text(quiz.categoryDisplayName)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.jbAccent)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.jbSubtext)
                }

                Text(quiz.question)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.jbText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)

                HStack(spacing: 4) {
                    ForEach(quiz.tags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 10))
                            .foregroundStyle(Color.jbSubtext)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.jbBackground))
                    }
                }
            }
            .padding(Spacing.md)
            .frame(width: 210, height: 118)
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

// MARK: - QuizSheetView

struct QuizSheetView: View {
    @State private var session: QuizSession
    @State private var currentQuiz: Quiz
    @State private var quizVM: QuizViewModel
    @State private var currentIndex: Int
    @State private var activeExplanation: Explanation?
    @AppStorage("codeZoom") private var codeZoom: Double = CodeZoom.default
    @Environment(\.dismiss) private var dismiss

    init(quiz: Quiz) {
        self.init(session: QuizSession.single(quiz))
    }

    init(session: QuizSession) {
        let firstQuiz = session.quizzes.first ?? Quiz.samples[0]
        self._session = State(initialValue: session)
        self._currentQuiz = State(initialValue: firstQuiz)
        self._quizVM = State(wrappedValue: QuizViewModel(quiz: firstQuiz))
        self._currentIndex = State(initialValue: 0)
    }

    var body: some View {
        NavigationStack {
            QuizView(
                vm: quizVM,
                codeZoom: codeZoom,
                onShowExplanation: {
                    activeExplanation = Explanation.sample(for: currentQuiz.explanationRef)
                },
                onNextQuiz: { goToNextQuiz() },
                nextButtonTitle: isLastQuiz ? "完了" : "次の問題"
            )
            .id(currentQuiz.id)
            .navigationTitle(session.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(Color.jbSubtext)
                }
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text(session.title)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.jbText)
                        Text("\(currentIndex + 1) / \(session.quizzes.count) ・ \(currentQuiz.categoryDisplayName)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.jbSubtext)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    LevelBadgeView(
                        level: currentQuiz.level,
                        zoomPercent: CodeZoom.percent(codeZoom),
                        onTap: { codeZoom = CodeZoom.next(after: codeZoom) }
                    )
                }
            }
            .sensoryFeedback(.selection, trigger: codeZoom)
        }
        .fullScreenCover(item: $activeExplanation) { explanation in
            ExplanationView(explanation: explanation, level: currentQuiz.level, onDismiss: { activeExplanation = nil })
        }
    }

    private var isLastQuiz: Bool {
        currentIndex >= session.quizzes.count - 1
    }

    private func goToNextQuiz() {
        guard !isLastQuiz else {
            dismiss()
            return
        }
        let nextIndex = currentIndex + 1
        let next = session.quizzes[nextIndex]
        currentIndex = nextIndex
        currentQuiz = next
        quizVM = QuizViewModel(quiz: next)
    }
}
