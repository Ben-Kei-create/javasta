import SwiftUI

struct HomeView: View {
    @State private var activeSession: QuizSession?
    @State private var progress = ProgressStore.shared
    @State private var showSettings = false
    @State private var showEmptySessionAlert = false
    @State private var emptySessionMessage = ""
    @State private var expandedMetric: HomeMetric?
    @AppStorage("selectedExamVersion") private var selectedExamVersionRaw = JavaExamVersion.se17.rawValue
    @AppStorage("selectedJavaLevel") private var selectedLevelRaw = JavaLevel.silver.rawValue

    private var selectedVersion: JavaExamVersion {
        JavaExamVersion(rawValue: selectedExamVersionRaw) ?? .se17
    }

    private var selectedLevel: JavaLevel {
        JavaLevel(rawValue: selectedLevelRaw) ?? .silver
    }

    private var reviewQueueQuizzes: [Quiz] {
        var seen = Set<String>()
        return progress.reviewQueueQuizIds.compactMap { id in
            guard seen.insert(id).inserted else { return nil }
            return QuestionBank.quiz(id: id)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.jbBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        headerSection

                        commandCenter
                        ActivityHeatmapView(
                            counts: progress.recentDailyCounts(days: ProgressStore.historyWindowDays)
                        )
                        if !reviewQueueQuizzes.isEmpty {
                            reviewQueueSection
                        }
                        practiceModesSection
                        LevelSectionView(
                            level: selectedLevel,
                            version: selectedVersion,
                            quizzes: QuestionBank.quizzes(version: selectedVersion, level: selectedLevel),
                            onSelect: { activeSession = QuizSession.single($0) },
                            onStartSession: { activeSession = $0 }
                        )
                        .id(selectedLevel)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                    .padding(.bottom, Spacing.lg)
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
        HStack(alignment: .center, spacing: Spacing.sm) {
            Text("JavaSta")
                .font(.system(size: 30, weight: .bold, design: .default))
                .foregroundStyle(Color.jbText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Spacer(minLength: Spacing.xs)

            HomeTimestampToggle()
                .layoutPriority(1)
                .offset(y: -1)

            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.jbSubtext)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
    }

    // MARK: Command center

    private var commandCenter: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .top, spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(selectedLevel.displayName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.jbText)
                    Text("\(selectedVersion.displayName) / \(selectedVersion.examCode(for: selectedLevel))")
                        .font(.system(size: 11, weight: .bold).monospacedDigit())
                        .foregroundStyle(Color.jbAccent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                        .allowsTightening(true)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.jbAccent.opacity(0.12)))
                        .layoutPriority(1)
                }

                Spacer()

                TodayStudyCounterView(
                    answered: progress.todayAnswered,
                    dailyGoal: progress.dailyGoal
                )
            }

            levelPicker

            HStack(spacing: Spacing.sm) {
                CommandMetric(
                    title: "正答率",
                    value: progress.answerAttemptCount(level: selectedLevel) > 0 ? "\(progress.levelAccuracyPercent(selectedLevel))%" : "—",
                    icon: "chart.line.uptrend.xyaxis",
                    color: accuracyColor,
                    isSelected: expandedMetric == .accuracy,
                    onTap: { toggleMetric(.accuracy) }
                )
                CommandMetric(
                    title: "連続",
                    value: "\(progress.streakDays)日",
                    icon: "flame.fill",
                    color: Color.jbWarning,
                    isSelected: expandedMetric == .streak,
                    onTap: { toggleMetric(.streak) }
                )
                CommandMetric(
                    title: "解答済み",
                    value: "\(progress.answeredCount(level: selectedLevel))問",
                    icon: "checkmark.seal.fill",
                    color: Color.jbSuccess,
                    isSelected: expandedMetric == .answered,
                    onTap: { toggleMetric(.answered) }
                )
            }

            if let expandedMetric {
                MetricDetailTray(
                    title: expandedMetric.detailTitle,
                    items: metricDetails(for: expandedMetric)
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.jbFast, value: expandedMetric)
        .padding(Spacing.sm)
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

    private var reviewQueueSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "arrow.counterclockwise")
                    .foregroundStyle(Color.jbWarning)
                    .font(.system(size: 12, weight: .bold))
                Text("復習キュー")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.jbText)
                Text("\(reviewQueueQuizzes.count)問")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.jbSubtext)
                Spacer()
            }
            .padding(.horizontal, Spacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(reviewQueueQuizzes) { quiz in
                        ReviewQueueCard(quiz: quiz, onTap: { activeSession = QuizSession.single(quiz) })
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 2)
            }
        }
    }

    private var levelPicker: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(JavaLevel.allCases, id: \.self) { level in
                Button(action: {
                    withAnimation(.jbSpring) {
                        selectedLevelRaw = level.rawValue
                    }
                }) {
                    Text(level.displayName.replacingOccurrences(of: "Java ", with: ""))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(selectedLevel == level ? .white : Color.jbSubtext)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
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
                ForEach(QuizPracticeMode.homeModes) { mode in
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

    private func toggleMetric(_ metric: HomeMetric) {
        withAnimation(.jbFast) {
            expandedMetric = expandedMetric == metric ? nil : metric
        }
    }

    private func metricDetails(for metric: HomeMetric) -> [MetricDetailItem] {
        let levelRecords = progress.answerHistory.filter { $0.level == selectedLevel }
        let levelCorrect = levelRecords.filter(\.correct).count
        let levelQuizCount = QuestionBank.quizzes(version: selectedVersion, level: selectedLevel).count

        switch metric {
        case .accuracy:
            return [
                MetricDetailItem(label: "総回答数", value: "\(progress.totalAnswered)回"),
                MetricDetailItem(label: "総正解数", value: "\(progress.totalCorrect)回"),
                MetricDetailItem(label: selectedLevel.displayName, value: "\(levelCorrect)/\(levelRecords.count)")
            ]
        case .streak:
            return [
                MetricDetailItem(label: "今日", value: "\(progress.todayAnswered)/\(progress.dailyGoal)問"),
                MetricDetailItem(label: "復習キュー", value: "\(reviewQueueQuizzes.count)問"),
                MetricDetailItem(label: "完了レッスン", value: "\(progress.completedLessons.count)件")
            ]
        case .answered:
            return [
                MetricDetailItem(label: "この級", value: "\(progress.answeredCount(level: selectedLevel))/\(levelQuizCount)問"),
                MetricDetailItem(label: "全体", value: "\(progress.answeredCount())問"),
                MetricDetailItem(label: "保存", value: "\(progress.bookmarkedQuizIds.count)問")
            ]
        }
    }

    private var accuracyColor: Color {
        guard progress.answerAttemptCount(level: selectedLevel) > 0 else { return Color.jbSubtext }
        let p = progress.levelAccuracyPercent(selectedLevel)
        if p >= 70 { return Color.jbSuccess }
        if p >= 40 { return Color.jbWarning }
        return Color.jbError
    }
}

// MARK: - HomeMetric

private enum HomeMetric: String, Identifiable {
    case accuracy
    case streak
    case answered

    var id: String { rawValue }

    var detailTitle: String {
        switch self {
        case .accuracy: return "回答の内訳"
        case .streak: return "今日の状態"
        case .answered: return "進捗の内訳"
        }
    }
}

private struct MetricDetailItem: Identifiable {
    let label: String
    let value: String

    var id: String { label }
}

// MARK: - HomeTimestampToggle

private struct HomeTimestampToggle: View {
    @AppStorage("homeTimestampVisible") private var isTimestampVisible = true

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            Button(action: {
                withAnimation(.jbFast) {
                    isTimestampVisible.toggle()
                }
            }) {
                Group {
                    if isTimestampVisible {
                        Text(Self.timestamp(timeline.date))
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    } else {
                        Image(systemName: "clock")
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
                .foregroundStyle(Color.jbSubtext)
                .frame(height: 22)
                .frame(
                    minWidth: isTimestampVisible ? 126 : 22,
                    maxWidth: isTimestampVisible ? 170 : 22,
                    alignment: .trailing
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isTimestampVisible ? "日時を隠す" : "日時を表示")
        }
    }

    private static func timestamp(_ date: Date) -> String {
        let parts = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        return String(
            format: "%04d年%02d月%02d日 %02d:%02d:%02d",
            parts.year ?? 0,
            parts.month ?? 0,
            parts.day ?? 0,
            parts.hour ?? 0,
            parts.minute ?? 0,
            parts.second ?? 0
        )
    }
}

// MARK: - TodayStudyCounterView

private struct TodayStudyCounterView: View {
    let answered: Int
    let dailyGoal: Int

    private var reachedGoal: Bool {
        answered >= dailyGoal
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text("\(answered)")
                .font(.system(size: 28, weight: .bold).monospacedDigit())
                .foregroundStyle(reachedGoal ? Color.jbSuccess : Color.jbAccent)
            Text("/\(dailyGoal)")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.jbSubtext)
        }
    }
}

// MARK: - MetricDetailTray

private struct MetricDetailTray: View {
    let title: String
    let items: [MetricDetailItem]

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.jbSubtext)
                .frame(width: 64, alignment: .leading)

            ForEach(items) { item in
                VStack(alignment: .leading, spacing: 1) {
                    Text(item.value)
                        .font(.system(size: 13, weight: .bold).monospacedDigit())
                        .foregroundStyle(Color.jbText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Text(item.label)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color.jbSubtext)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 7)
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

// MARK: - CommandMetric

private struct CommandMetric: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(color)
                Text(value)
                    .font(.system(size: 16, weight: .bold).monospacedDigit())
                    .foregroundStyle(Color.jbText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(title)
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
                            .stroke(isSelected ? color.opacity(0.8) : Color.jbBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - PracticeModeCard

private struct PracticeModeCard: View {
    let mode: QuizPracticeMode
    let isPrimary: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: mode.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(isPrimary ? .white : Color.jbAccent)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle().fill(isPrimary ? Color.white.opacity(0.18) : Color.jbAccent.opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(isPrimary ? .white : Color.jbText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(mode.subtitle)
                        .font(.system(size: 10))
                        .foregroundStyle(isPrimary ? .white.opacity(0.76) : Color.jbSubtext)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Spacer(minLength: Spacing.xs)

                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isPrimary ? .white.opacity(0.8) : Color.jbSubtext)
            }
            .padding(Spacing.sm)
            .frame(maxWidth: .infinity, minHeight: 74, alignment: .leading)
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

// MARK: - LevelSectionView

struct LevelSectionView: View {
    let level: JavaLevel
    let version: JavaExamVersion
    let quizzes: [Quiz]
    let onSelect: (Quiz) -> Void
    let onStartSession: (QuizSession) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Text(level.displayName)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(Color.jbText)
                LevelBadgeView(level: level)
                Spacer()
                NavigationLink {
                    AllQuizzesView(
                        level: level,
                        version: version,
                        onSelect: onSelect,
                        onStartSession: onStartSession
                    )
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

// MARK: - ReviewQueueCard

private struct ReviewQueueCard: View {
    let quiz: Quiz
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.jbWarning)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.jbWarning.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text(quiz.categoryDisplayName)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.jbWarning)
                        .lineLimit(1)
                    Text(quiz.question)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.jbText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.jbSubtext)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 7)
            .frame(width: 176, height: 50)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(Color.jbCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(Color.jbWarning.opacity(0.32), lineWidth: 1)
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
    @State private var scoredQuizIds: Set<String> = []
    @State private var correctCount = 0
    @State private var showSessionResult = false
    @State private var activeExplanation: Explanation?
    @State private var glossaryRoot: GlossaryRoot? = nil
    @State private var glossaryPath: [String] = []
    @AppStorage("codeZoom") private var codeZoom: Double = CodeZoom.default
    @Environment(\.dismiss) private var dismiss

    private struct GlossaryRoot: Identifiable, Hashable {
        let id: String
    }

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
            if showSessionResult {
                QuizSessionResultView(
                    session: session,
                    correctCount: correctCount,
                    onClose: { dismiss() }
                )
            } else {
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
        }
        .environment(\.openURL, OpenURLAction { url in
            if let id = GlossaryTerm.parse(url: url) {
                glossaryRoot = GlossaryRoot(id: id)
                return .handled
            }
            return .systemAction
        })
        .sheet(item: $glossaryRoot, onDismiss: { glossaryPath.removeAll() }) { root in
            glossarySheet(rootId: root.id)
        }
        .fullScreenCover(item: $activeExplanation) { explanation in
            ExplanationView(explanation: explanation, level: currentQuiz.level, onDismiss: { activeExplanation = nil })
        }
    }

    @ViewBuilder
    private func glossarySheet(rootId: String) -> some View {
        if let term = GlossaryTerm.lookup(rootId) {
            let origin = GlossaryDetailView.Origin(
                icon: "pencil.and.list.clipboard",
                label: currentQuiz.categoryDisplayName,
                action: { glossaryRoot = nil }
            )
            NavigationStack(path: $glossaryPath) {
                GlossaryDetailView(term: term, origin: origin)
                    .navigationDestination(for: String.self) { id in
                        if let next = GlossaryTerm.lookup(id) {
                            GlossaryDetailView(term: next, origin: origin)
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("閉じる") { glossaryRoot = nil }
                                .foregroundStyle(Color.jbSubtext)
                        }
                    }
            }
            .preferredColorScheme(.dark)
            .environment(\.openURL, OpenURLAction { url in
                if let id = GlossaryTerm.parse(url: url) {
                    glossaryPath.append(id)
                    return .handled
                }
                return .systemAction
            })
        }
    }

    private var isLastQuiz: Bool {
        currentIndex >= session.quizzes.count - 1
    }

    private func goToNextQuiz() {
        captureCurrentScore()
        guard !isLastQuiz else {
            if session.mode == .mockExam {
                withAnimation(.jbSpring) {
                    showSessionResult = true
                }
            } else {
                dismiss()
            }
            return
        }
        let nextIndex = currentIndex + 1
        let next = session.quizzes[nextIndex]
        currentIndex = nextIndex
        currentQuiz = next
        quizVM = QuizViewModel(quiz: next)
    }

    private func captureCurrentScore() {
        guard !scoredQuizIds.contains(currentQuiz.id), quizVM.isAnswered else { return }
        scoredQuizIds.insert(currentQuiz.id)
        if quizVM.isCorrect {
            correctCount += 1
        }
    }
}

// MARK: - QuizSessionResultView

private struct QuizSessionResultView: View {
    let session: QuizSession
    let correctCount: Int
    let onClose: () -> Void

    private var totalCount: Int { max(session.quizzes.count, 1) }
    private var scorePercent: Int {
        Int((Double(correctCount) / Double(totalCount) * 100).rounded())
    }
    private var isPassing: Bool { scorePercent >= 65 }

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: Spacing.lg) {
                Spacer(minLength: Spacing.lg)

                VStack(alignment: .leading, spacing: Spacing.md) {
                    HStack {
                        Image(systemName: isPassing ? "checkmark.seal.fill" : "chart.bar.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(isPassing ? Color.jbSuccess : Color.jbWarning)
                        Spacer()
                        LevelBadgeView(level: session.level)
                    }

                    Text(isPassing ? "合格ゾーン" : "もう少しで合格ゾーン")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.jbText)

                    Text("\(session.version.examCode(for: session.level)) の目安として 65% 以上を合格ゾーンにしています。")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.jbSubtext)
                        .lineSpacing(4)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(scorePercent)")
                            .font(.system(size: 54, weight: .heavy).monospacedDigit())
                            .foregroundStyle(isPassing ? Color.jbSuccess : Color.jbWarning)
                        Text("%")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.jbSubtext)
                    }

                    HStack(spacing: Spacing.sm) {
                        ResultMetric(title: "正解", value: "\(correctCount)問", color: Color.jbSuccess)
                        ResultMetric(title: "出題", value: "\(session.quizzes.count)問", color: Color.jbAccent)
                        ResultMetric(title: "基準", value: "65%", color: Color.jbWarning)
                    }
                }
                .padding(Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .fill(Color.jbCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.md)
                                .stroke(isPassing ? Color.jbSuccess.opacity(0.35) : Color.jbWarning.opacity(0.35), lineWidth: 1.5)
                        )
                )

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
                            .fill(isPassing ? Color.jbSuccess : Color.jbAccent)
                    )
                }

                Spacer(minLength: Spacing.xl)
            }
            .padding(Spacing.md)
        }
        .navigationBarBackButtonHidden(true)
    }
}

private struct ResultMetric: View {
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
