import SwiftUI

struct HomeView: View {
    @State private var activeSession: QuizSession?
    @State private var progress = ProgressStore.shared
    @State private var showSettings = false
    @State private var showEmptySessionAlert = false
    @State private var emptySessionMessage = ""
    @State private var expandedMetric: HomeMetric = .accuracy
    @AppStorage("selectedExamVersion") private var selectedExamVersionRaw = JavaExamVersion.se17.rawValue
    @AppStorage("selectedJavaLevel") private var selectedLevelRaw = JavaLevel.silver.rawValue
    @AppStorage("homeSectionOrderV1") private var homeSectionOrderRaw: String = HomeSectionID.defaultOrderRaw
    @State private var draggingSection: HomeSectionID?
    @State private var dragLocationY: CGFloat?
    @State private var dragGrabOffsetY: CGFloat = 0
    @State private var sectionFrames: [HomeSectionID: CGRect] = [:]

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

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        headerSection

                        ForEach(visibleSectionOrder, id: \.self) { sectionId in
                            reorderableSection(for: sectionId)
                                .transition(.scale(scale: 0.96).combined(with: .opacity))
                        }

                        Color.clear
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                    }
                    .padding(.bottom, Spacing.lg)
                    .animation(.spring(response: 0.45, dampingFraction: 0.82), value: sectionOrder)
                    .onPreferenceChange(HomeSectionFramePreferenceKey.self) { frames in
                        sectionFrames = frames
                    }
                    .background(
                        Color.jbAccent
                            .opacity(isReordering ? 0.06 : 0)
                            .ignoresSafeArea()
                            .animation(.easeInOut(duration: 0.25), value: isReordering)
                    )
                }
                .coordinateSpace(name: HomeSectionDragSpace.name)
                .scrollDisabled(isReordering)
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

            MetricDetailTray(
                title: expandedMetric.detailTitle,
                items: metricDetails(for: expandedMetric)
            )
            .id(expandedMetric)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.18), value: expandedMetric)
        }
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
                Text("復習")
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
                .buttonStyle(.jbScaled)
                .sensoryFeedback(.selection, trigger: selectedLevelRaw)
            }
        }
    }

    // MARK: Practice modes

    private var practiceModesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(QuizPracticeMode.homeModes) { mode in
                    PracticeModeCard(
                        mode: mode,
                        isPrimary: mode == .daily,
                        onTap: { start(mode) }
                    )
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 2)
        }
    }

    private func start(_ mode: QuizPracticeMode) {
        if let session = QuestionBank.makeSession(
            mode: mode,
            version: selectedVersion,
            level: selectedLevel,
            progress: progress
        ) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            activeSession = session
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            emptySessionMessage = "\(selectedLevel.displayName) の問題がまだありません。"
            showEmptySessionAlert = true
        }
    }

    private func toggleMetric(_ metric: HomeMetric) {
        withAnimation(.jbFast) {
            expandedMetric = metric
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
                MetricDetailItem(label: "復習", value: "\(reviewQueueQuizzes.count)問"),
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

    // MARK: Reorderable sections

    private var sectionOrder: [HomeSectionID] {
        var decoded = HomeSectionID.decode(homeSectionOrderRaw)
        for id in HomeSectionID.allCases where !decoded.contains(id) {
            decoded.append(id)
        }
        return decoded.filter { HomeSectionID.allCases.contains($0) }
    }

    private var visibleSectionOrder: [HomeSectionID] {
        sectionOrder.filter { id in
            if case .reviewQueue = id {
                return !reviewQueueQuizzes.isEmpty
            }
            return true
        }
    }

    private var isReordering: Bool { draggingSection != nil }

    @ViewBuilder
    private func reorderableSection(for id: HomeSectionID) -> some View {
        let content = sectionContent(for: id)
        content
            .padding(.vertical, 2)
            .background(sectionFrameReader(for: id))
            .background(
                RoundedRectangle(cornerRadius: Radius.md)
                    .fill(Color.jbAccent.opacity(draggingSection == id ? 0.14 : (isReordering ? 0.05 : 0)))
                    .padding(.horizontal, Spacing.sm)
                    .animation(.easeInOut(duration: 0.22), value: draggingSection)
            )
            .scaleEffect(draggingSection == id ? 1.02 : 1.0)
            .offset(y: dragOffsetY(for: id))
            .zIndex(draggingSection == id ? 10 : 0)
            .shadow(
                color: Color.black.opacity(draggingSection == id ? 0.22 : 0),
                radius: draggingSection == id ? 18 : 0,
                y: draggingSection == id ? 12 : 0
            )
            .animation(.spring(response: 0.32, dampingFraction: 0.78), value: draggingSection)
            .gesture(reorderGesture(for: id))
    }

    @ViewBuilder
    private func sectionContent(for id: HomeSectionID) -> some View {
        switch id {
        case .commandCenter:
            commandCenter
        case .heatmap:
            ActivityHeatmapView(
                counts: progress.recentDailyCounts(days: ProgressStore.historyWindowDays)
            )
        case .reviewQueue:
            reviewQueueSection
        case .practiceModes:
            practiceModesSection
        case .levelSection:
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
    }

    private func sectionFrameReader(for id: HomeSectionID) -> some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: HomeSectionFramePreferenceKey.self,
                    value: [id: proxy.frame(in: .named(HomeSectionDragSpace.name))]
                )
        }
    }

    private func reorderGesture(for id: HomeSectionID) -> some Gesture {
        LongPressGesture(minimumDuration: 0.28, maximumDistance: 18)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .named(HomeSectionDragSpace.name)))
            .onChanged { value in
                switch value {
                case .first(true):
                    beginSectionDrag(id)
                case .second(true, let drag):
                    beginSectionDrag(id)
                    guard let drag else { return }
                    updateSectionDrag(id, drag: drag)
                default:
                    break
                }
            }
            .onEnded { _ in
                endSectionDrag()
            }
    }

    private func beginSectionDrag(_ id: HomeSectionID) {
        guard draggingSection == nil || draggingSection == id else { return }
        withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
            draggingSection = id
        }
    }

    private func updateSectionDrag(_ id: HomeSectionID, drag: DragGesture.Value) {
        guard draggingSection == id else { return }
        if dragLocationY == nil, let frame = sectionFrames[id] {
            dragGrabOffsetY = drag.startLocation.y - frame.midY
        }
        dragLocationY = drag.location.y
        updateSectionPosition(id, draggedCenterY: drag.location.y - dragGrabOffsetY)
    }

    private func updateSectionPosition(_ id: HomeSectionID, draggedCenterY: CGFloat) {
        let visibleOrder = visibleSectionOrder
        guard visibleOrder.count > 1, visibleOrder.contains(id) else { return }

        let insertionIndex = visibleOrder.firstIndex { target in
            guard let frame = sectionFrames[target] else { return false }
            return draggedCenterY < frame.midY
        } ?? visibleOrder.count

        withAnimation(.spring(response: 0.44, dampingFraction: 0.84)) {
            moveSection(id, toVisibleInsertionIndex: insertionIndex, visibleOrder: visibleOrder)
        }
    }

    private func moveSection(
        _ source: HomeSectionID,
        toVisibleInsertionIndex insertionIndex: Int,
        visibleOrder: [HomeSectionID]
    ) {
        guard let oldIndex = visibleOrder.firstIndex(of: source) else { return }

        var reorderedVisible = visibleOrder
        reorderedVisible.remove(at: oldIndex)

        let adjustedIndex = insertionIndex > oldIndex ? insertionIndex - 1 : insertionIndex
        let safeIndex = min(max(adjustedIndex, 0), reorderedVisible.count)
        guard safeIndex != oldIndex else { return }

        reorderedVisible.insert(source, at: safeIndex)

        var reorderedIterator = reorderedVisible.makeIterator()
        let visibleSet = Set(visibleOrder)
        let newOrder = sectionOrder.map { sectionId in
            visibleSet.contains(sectionId) ? (reorderedIterator.next() ?? sectionId) : sectionId
        }
        homeSectionOrderRaw = HomeSectionID.encode(newOrder)
    }

    private func dragOffsetY(for id: HomeSectionID) -> CGFloat {
        guard draggingSection == id,
              let frame = sectionFrames[id],
              let dragLocationY else {
            return 0
        }
        return dragLocationY - frame.midY - dragGrabOffsetY
    }

    private func endSectionDrag() {
        withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
            draggingSection = nil
            dragLocationY = nil
            dragGrabOffsetY = 0
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

// MARK: - HomeSectionID

enum HomeSectionID: String, CaseIterable, Codable, Hashable {
    case commandCenter
    case heatmap
    case reviewQueue
    case practiceModes
    case levelSection

    var displayTitle: String {
        switch self {
        case .commandCenter: return "ステータス"
        case .heatmap: return "学習マップ"
        case .reviewQueue: return "復習"
        case .practiceModes: return "練習を開始"
        case .levelSection: return "問題リスト"
        }
    }

    static var defaultOrderRaw: String {
        encode(Self.allCases)
    }

    static func encode(_ ids: [HomeSectionID]) -> String {
        ids.map { $0.rawValue }.joined(separator: ",")
    }

    static func decode(_ raw: String) -> [HomeSectionID] {
        raw.split(separator: ",").compactMap { HomeSectionID(rawValue: String($0)) }
    }
}

private enum HomeSectionDragSpace {
    static let name = "home-section-drag-space"
}

private struct HomeSectionFramePreferenceKey: PreferenceKey {
    static var defaultValue: [HomeSectionID: CGRect] = [:]

    static func reduce(value: inout [HomeSectionID: CGRect], nextValue: () -> [HomeSectionID: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
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
    @AppStorage("examDateTimestamp") private var examDateTimestamp: Double = 0

    private var examDate: Date? {
        examDateTimestamp > 0 ? Date(timeIntervalSince1970: examDateTimestamp) : nil
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let isExamToday = Self.isSameDay(examDate, timeline.date)
            let hasExam = examDate != nil && (examDate! > timeline.date) && !isExamToday
            let displayText: String = {
                if isExamToday { return "受験頑張ってください！" }
                if hasExam { return Self.countdown(from: timeline.date, to: examDate!) }
                return Self.timestamp(timeline.date)
            }()
            Button(action: {
                withAnimation(.jbFast) {
                    isTimestampVisible.toggle()
                }
            }) {
                Group {
                    if isTimestampVisible {
                        Text(displayText)
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .foregroundStyle(isExamToday ? Color.jbError : (hasExam ? Color.jbError : Color.jbSubtext))
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    } else {
                        Image(systemName: "clock")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.jbSubtext)
                    }
                }
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

    private static func isSameDay(_ a: Date?, _ b: Date) -> Bool {
        guard let a else { return false }
        return Calendar.current.isDate(a, inSameDayAs: b)
    }

    private static func countdown(_ now: Date = Date(), to exam: Date) -> String {
        countdown(from: now, to: exam)
    }

    private static func countdown(from now: Date, to exam: Date) -> String {
        let diff = max(0, exam.timeIntervalSince(now))
        let days = Int(diff) / 86400
        let hours = (Int(diff) % 86400) / 3600
        let minutes = (Int(diff) % 3600) / 60
        let seconds = Int(diff) % 60
        return String(format: "受験まで %d日 %02d:%02d:%02d", days, hours, minutes, seconds)
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
                    .foregroundStyle(isSelected ? color : color.opacity(0.7))
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
                    .fill(isSelected ? color.opacity(0.1) : Color.jbBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(isSelected ? color.opacity(0.8) : Color.jbBorder, lineWidth: isSelected ? 1.5 : 1)
                    )
            )
            .animation(.jbFast, value: isSelected)
        }
        .buttonStyle(.jbScaled)
        .sensoryFeedback(.selection, trigger: isSelected)
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
            .frame(width: 200, height: 74, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Radius.md)
                    .fill(isPrimary ? Color.jbAccent : Color.jbCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .stroke(isPrimary ? Color.jbAccent : Color.jbBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.jbScaled)
    }
}

// MARK: - LevelSectionView

struct LevelSectionView: View {
    let level: JavaLevel
    let version: JavaExamVersion
    let quizzes: [Quiz]
    let onSelect: (Quiz) -> Void
    let onStartSession: (QuizSession) -> Void

    private let previewCount = 5

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(quizzes.prefix(previewCount)) { quiz in
                    QuizCardView(quiz: quiz, onTap: { onSelect(quiz) })
                }
                NavigationLink {
                    AllQuizzesView(
                        level: level,
                        version: version,
                        onSelect: onSelect,
                        onStartSession: onStartSession
                    )
                } label: {
                    VStack(spacing: Spacing.xs) {
                        Image(systemName: "chevron.right.2")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.jbAccent)
                        Text("すべて見る")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.jbAccent)
                    }
                    .frame(width: 80, height: 118)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .fill(Color.jbCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: Radius.md)
                                    .stroke(Color.jbAccent.opacity(0.35), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 4)
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
        .buttonStyle(.jbScaled)
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
        .buttonStyle(.jbScaled)
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
        Group {
            if session.mode == .mockExam {
                MockExamView(session: session)
            } else {
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
