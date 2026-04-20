import SwiftUI

private enum AllQuizzesLayout {
    static let topActionCardHeight: CGFloat = 78
    static let topActionIconSize: CGFloat = 46
    static let categoryActionHeight: CGFloat = 36
    static let expandAnimation = Animation.snappy(duration: 0.24, extraBounce: 0.04)
    static let stateAnimation = Animation.snappy(duration: 0.22, extraBounce: 0.03)

    static var expandTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity
                .combined(with: .move(edge: .top))
                .combined(with: .scale(scale: 0.985, anchor: .top)),
            removal: .opacity
                .combined(with: .scale(scale: 0.99, anchor: .top))
        )
    }

    static var stateTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.985)),
            removal: .opacity.combined(with: .scale(scale: 0.995))
        )
    }
}

struct AllQuizzesView: View {
    let level: JavaLevel
    var version: JavaExamVersion = .se17
    var onSelect: (Quiz) -> Void
    var onStartSession: (QuizSession) -> Void

    @State private var expandedCategories: Set<QuizCategory> = []
    @State private var selectedQuizIds: Set<String> = []
    @State private var progress = ProgressStore.shared

    private var quizzes: [Quiz] {
        QuestionBank.quizzes(version: version, level: level)
    }

    private var selectedQuizzes: [Quiz] {
        quizzes.filter { selectedQuizIds.contains($0.id) }
    }

    private var hasSelection: Bool {
        !selectedQuizzes.isEmpty
    }

    private var grouped: [(category: QuizCategory, quizzes: [Quiz])] {
        let dict = Dictionary(grouping: quizzes) { quiz in
            QuizCategory(rawValue: quiz.category) ?? .controlFlow
        }
        return dict
            .map { ($0.key, $0.value.sorted { $0.id < $1.id }) }
            .sorted { lhs, rhs in
                if lhs.0.displayName == rhs.0.displayName { return lhs.1.count > rhs.1.count }
                return lhs.0.displayName < rhs.0.displayName
            }
    }

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    summaryHeader
                    topActionCard

                    VStack(spacing: Spacing.sm) {
                        ForEach(grouped, id: \.category) { group in
                            CategoryQuizGroupCard(
                                category: group.category,
                                quizzes: group.quizzes,
                                isExpanded: expandedCategories.contains(group.category),
                                selectedQuizIds: selectedQuizIds,
                                progress: progress,
                                onToggleExpanded: { toggleExpanded(group.category) },
                                onToggleQuiz: { toggleQuiz($0) },
                                onStartCategory: {
                                    onStartSession(categorySession(category: group.category, quizzes: group.quizzes))
                                },
                                onStartSelection: {
                                    let selected = group.quizzes.filter { selectedQuizIds.contains($0.id) }
                                    onStartSession(selectedSession(quizzes: selected, title: "\(group.category.displayName) 選択問題"))
                                },
                                onClearSelection: {
                                    clearCategorySelection(group.quizzes)
                                },
                                onStartSingle: { onSelect($0) }
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.md)

                    Spacer(minLength: Spacing.xxl)
                }
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xxl)
            }
        }
        .navigationTitle(level.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    private var summaryHeader: some View {
        HStack(alignment: .center, spacing: Spacing.sm) {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(version.displayName) / \(version.examCode(for: level))")
                    .font(.system(size: 12, weight: .semibold).monospacedDigit())
                    .foregroundStyle(Color.jbAccent)
                Text("\(grouped.count) 分野 ・ \(quizzes.count) 問")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.jbSubtext)
            }

            Spacer()
            LevelBadgeView(level: level)
        }
        .padding(.horizontal, Spacing.md)
    }

    @ViewBuilder
    private var topActionCard: some View {
        Group {
            if !hasSelection {
                MockExamCard(
                    level: level,
                    version: version,
                    count: quizzes.count,
                    onStart: { variant in
                        if let session = QuestionBank.makeMockExamSession(
                            variant: variant,
                            version: version,
                            level: level
                        ) {
                            onStartSession(session)
                        }
                    }
                )
            } else {
                SelectedQuizzesActionCard(
                    selectedCount: selectedQuizzes.count,
                    onStart: {
                        onStartSession(selectedSession(quizzes: selectedQuizzes, title: "選択した問題"))
                    },
                    onClear: {
                        clearAllSelections()
                    }
                )
            }
        }
        .id(hasSelection ? "selected-quizzes" : "mock-exam")
        .transition(AllQuizzesLayout.stateTransition)
        .animation(AllQuizzesLayout.stateAnimation, value: hasSelection)
        .animation(AllQuizzesLayout.stateAnimation, value: selectedQuizzes.count)
        .padding(.horizontal, Spacing.md)
    }

    private func toggleExpanded(_ category: QuizCategory) {
        withAnimation(AllQuizzesLayout.expandAnimation) {
            if expandedCategories.contains(category) {
                expandedCategories.remove(category)
            } else {
                expandedCategories.insert(category)
            }
        }
    }

    private func toggleQuiz(_ quiz: Quiz) {
        withAnimation(AllQuizzesLayout.stateAnimation) {
            if selectedQuizIds.contains(quiz.id) {
                selectedQuizIds.remove(quiz.id)
            } else {
                selectedQuizIds.insert(quiz.id)
            }
        }
    }

    private func clearCategorySelection(_ quizzes: [Quiz]) {
        let categoryIds = Set(quizzes.map(\.id))
        withAnimation(AllQuizzesLayout.stateAnimation) {
            selectedQuizIds.subtract(categoryIds)
        }
    }

    private func clearAllSelections() {
        withAnimation(AllQuizzesLayout.stateAnimation) {
            selectedQuizIds.removeAll()
        }
    }

    private func categorySession(category: QuizCategory, quizzes: [Quiz]) -> QuizSession {
        QuizSession(
            mode: .daily,
            level: level,
            version: version,
            quizzes: quizzes,
            customTitle: "\(category.displayName) \(quizzes.count)問"
        )
    }

    private func selectedSession(quizzes: [Quiz], title: String) -> QuizSession {
        QuizSession(
            mode: .daily,
            level: level,
            version: version,
            quizzes: quizzes,
            customTitle: "\(title) \(quizzes.count)問"
        )
    }
}

// MARK: - SelectedQuizzesActionCard

private struct SelectedQuizzesActionCard: View {
    let selectedCount: Int
    let onStart: () -> Void
    let onClear: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: AllQuizzesLayout.topActionIconSize, height: AllQuizzesLayout.topActionIconSize)
                .background(Circle().fill(Color.jbSuccess))

            VStack(alignment: .leading, spacing: 4) {
                Text("\(selectedCount)問 選択中")
                    .font(.system(size: 18, weight: .bold).monospacedDigit())
                    .foregroundStyle(Color.jbText)
                    .contentTransition(.numericText())
                Text("選んだ問題だけをまとめて学習")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.jbSubtext)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .layoutPriority(1)

            Spacer()

            HStack(spacing: Spacing.xs) {
                Button(action: onClear) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.jbSubtext)
                        .frame(width: 34, height: 34)
                        .background(
                            Circle()
                                .fill(Color.jbBackground)
                                .overlay(
                                    Circle().stroke(Color.jbBorder, lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("選択をすべて解除")

                Button(action: onStart) {
                    HStack(spacing: 5) {
                        Text("開始")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 34)
                    .background(
                        Capsule().fill(Color.jbAccent)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: AllQuizzesLayout.topActionIconSize)
        .padding(.horizontal, Spacing.md)
        .frame(maxWidth: .infinity)
        .frame(height: AllQuizzesLayout.topActionCardHeight)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbSuccess.opacity(0.35), lineWidth: 1.5)
                )
        )
    }
}

// MARK: - MockExamCard

private struct MockExamCard: View {
    let level: JavaLevel
    let version: JavaExamVersion
    let count: Int
    let onStart: (MockExamVariant) -> Void

    private var spec: MockExamSpec {
        MockExamSpec.official(version: version, level: level)
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: AllQuizzesLayout.topActionIconSize, height: AllQuizzesLayout.topActionIconSize)
                .background(Circle().fill(Color.jbAccent))

            VStack(alignment: .leading, spacing: 4) {
                Text("模擬試験")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.jbText)
                Text("本番形式・解説なし・提出時に採点")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.jbSubtext)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .layoutPriority(1)

            Spacer(minLength: Spacing.xs)

            HStack(spacing: 6) {
                ForEach(MockExamVariant.allCases) { variant in
                    let questionCount = min(spec.questionCount(for: variant), count)
                    Button(action: { onStart(variant) }) {
                        VStack(spacing: 1) {
                            Text(variant.shortTitle)
                                .font(.system(size: 12, weight: .bold).monospacedDigit())
                                .foregroundStyle(variant == .full ? .white : Color.jbText)
                                .lineLimit(1)
                            Text(spec.durationText(for: questionCount))
                                .font(.system(size: 9, weight: .semibold).monospacedDigit())
                                .foregroundStyle(variant == .full ? .white.opacity(0.82) : Color.jbSubtext)
                        }
                        .frame(width: 54, height: 38)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.sm)
                                .fill(variant == .full ? Color.jbAccent : Color.jbBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Radius.sm)
                                        .stroke(variant == .full ? Color.jbAccent.opacity(0.45) : Color.jbBorder, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(variant.displayName) \(questionCount)問")
                }
            }
        }
        .frame(height: AllQuizzesLayout.topActionIconSize)
        .padding(.horizontal, Spacing.md)
        .frame(maxWidth: .infinity)
        .frame(height: AllQuizzesLayout.topActionCardHeight)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbAccent.opacity(0.35), lineWidth: 1.5)
                )
            )
    }
}

// MARK: - CategoryQuizGroupCard

private struct CategoryQuizGroupCard: View {
    let category: QuizCategory
    let quizzes: [Quiz]
    let isExpanded: Bool
    let selectedQuizIds: Set<String>
    let progress: ProgressStore
    let onToggleExpanded: () -> Void
    let onToggleQuiz: (Quiz) -> Void
    let onStartCategory: () -> Void
    let onStartSelection: () -> Void
    let onClearSelection: () -> Void
    let onStartSingle: (Quiz) -> Void

    private var selectedCount: Int {
        quizzes.filter { selectedQuizIds.contains($0.id) }.count
    }

    private var hasSelection: Bool {
        selectedCount > 0
    }

    private var answeredCount: Int {
        quizzes.filter { progress.stats(for: $0.id).isAnswered }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggleExpanded) {
                HStack(spacing: Spacing.md) {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: Spacing.xs) {
                            Text(category.displayName)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color.jbText)
                            Text("\(quizzes.count)問")
                                .font(.system(size: 11, weight: .bold).monospacedDigit())
                                .foregroundStyle(Color.jbAccent)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.jbAccent.opacity(0.12)))
                        }

                        Text("解答済み \(answeredCount)/\(quizzes.count) ・ 選択中 \(selectedCount)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.jbSubtext)
                            .contentTransition(.numericText())
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.jbSubtext)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(Spacing.md)
            }
            .buttonStyle(.plain)

            HStack(spacing: Spacing.sm) {
                CategoryActionButton(
                    title: hasSelection ? "やめる" : "分野を全問解く",
                    systemImage: hasSelection ? "xmark.circle.fill" : "play.fill",
                    style: hasSelection ? .clear : .primary,
                    isEnabled: true,
                    action: hasSelection ? onClearSelection : onStartCategory
                )

                CategoryActionButton(
                    title: "選択した問題を解く",
                    systemImage: "checkmark.circle.fill",
                    style: hasSelection ? .selected : .disabled,
                    isEnabled: hasSelection,
                    action: onStartSelection
                )
            }
            .animation(AllQuizzesLayout.stateAnimation, value: hasSelection)
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, isExpanded ? Spacing.sm : Spacing.md)

            if isExpanded {
                LazyVStack(spacing: Spacing.xs) {
                    ForEach(quizzes) { quiz in
                        SelectableQuizRow(
                            quiz: quiz,
                            isSelected: selectedQuizIds.contains(quiz.id),
                            stats: progress.stats(for: quiz.id),
                            onToggle: { onToggleQuiz(quiz) },
                            onStartSingle: { onStartSingle(quiz) }
                        )
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.md)
                .transition(AllQuizzesLayout.expandTransition)
            }
        }
        .animation(AllQuizzesLayout.expandAnimation, value: isExpanded)
        .animation(AllQuizzesLayout.stateAnimation, value: selectedCount)
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

// MARK: - CategoryActionButton

private enum CategoryActionTone {
    case primary
    case selected
    case clear
    case disabled

    var foreground: Color {
        switch self {
        case .primary, .selected:
            return .white
        case .clear:
            return Color.jbWarning
        case .disabled:
            return Color.jbSubtext.opacity(0.55)
        }
    }

    var fill: Color {
        switch self {
        case .primary:
            return Color.jbAccent
        case .selected:
            return Color.jbSuccess
        case .clear, .disabled:
            return Color.jbBackground
        }
    }

    var stroke: Color {
        switch self {
        case .primary:
            return Color.jbAccent.opacity(0.35)
        case .selected:
            return Color.jbSuccess.opacity(0.45)
        case .clear:
            return Color.jbWarning.opacity(0.42)
        case .disabled:
            return Color.jbBorder
        }
    }
}

private struct CategoryActionButton: View {
    let title: String
    let systemImage: String
    let style: CategoryActionTone
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: systemImage)
                    .font(.system(size: 11, weight: .bold))
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .id("\(systemImage)-\(title)")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(style.foreground)
            .frame(maxWidth: .infinity)
            .frame(height: AllQuizzesLayout.categoryActionHeight)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(style.fill)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(style.stroke, lineWidth: 1)
                    )
            )
            .transition(.opacity)
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
        .animation(AllQuizzesLayout.stateAnimation, value: title)
    }
}

// MARK: - SelectableQuizRow

private struct SelectableQuizRow: View {
    let quiz: Quiz
    let isSelected: Bool
    let stats: QuizAttemptStats
    let onToggle: () -> Void
    let onStartSingle: () -> Void

    private var statusText: String {
        if !stats.isAnswered { return "未回答" }
        if stats.latest?.correct == true { return "正解済み" }
        return "復習"
    }

    private var statusColor: Color {
        if !stats.isAnswered { return Color.jbSubtext }
        if stats.latest?.correct == true { return Color.jbSuccess }
        return Color.jbWarning
    }

    private var displayId: String {
        quiz.id
            .replacingOccurrences(of: "\(quiz.level.rawValue)-", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .uppercased()
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.jbSuccess : Color.jbSubtext)
                    .frame(width: 30, height: 30)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: Spacing.xs) {
                    Text(displayId)
                        .font(.system(size: 12, weight: .bold).monospacedDigit())
                        .foregroundStyle(Color.jbText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text(statusText)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(statusColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(statusColor.opacity(0.12)))
                }

                HStack(spacing: 4) {
                    ForEach(quiz.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 10))
                            .foregroundStyle(Color.jbSubtext)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.jbBackground))
                    }
                }
            }

            Spacer()

            Button(action: onStartSingle) {
                Image(systemName: "play.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.jbAccent))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: Radius.sm)
                .fill(Color.jbBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .stroke(isSelected ? Color.jbSuccess.opacity(0.45) : Color.jbBorder, lineWidth: 1)
                )
        )
        .animation(AllQuizzesLayout.stateAnimation, value: isSelected)
    }
}
