import SwiftUI

struct HomeView: View {
    @State private var selectedQuiz: Quiz?
    @State private var progress = ProgressStore.shared
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.jbBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        headerSection
                        dailyProgressCard
                        ForEach(JavaLevel.allCases, id: \.self) { level in
                            LevelSectionView(
                                level: level,
                                quizzes: Quiz.samples.filter { $0.level == level },
                                onSelect: { selectedQuiz = $0 }
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
        .sheet(item: $selectedQuiz) { quiz in
            QuizSheetView(quiz: quiz)
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
                Text("Java資格 × 本質理解")
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

    // MARK: Daily progress

    private var dailyProgressCard: some View {
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text("今日の学習")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.jbSubtext)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(progress.todayAnswered)")
                        .font(.system(size: 28, weight: .bold).monospacedDigit())
                        .foregroundStyle(progress.todayAnswered >= progress.dailyGoal ? Color.jbSuccess : Color.jbAccent)
                    Text("/ \(progress.dailyGoal) 問")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.jbSubtext)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("連続学習")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.jbSubtext)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(progress.streakDays)")
                        .font(.system(size: 28, weight: .bold).monospacedDigit())
                        .foregroundStyle(Color.jbText)
                    Text("日")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.jbSubtext)
                }
            }

            Divider()
                .frame(height: 40)
                .background(Color.jbBorder)

            VStack(alignment: .trailing, spacing: 4) {
                Text("正答率")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.jbSubtext)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(progress.totalAnswered > 0 ? "\(progress.accuracyPercent)" : "—")
                        .font(.system(size: 28, weight: .bold).monospacedDigit())
                        .foregroundStyle(accuracyColor)
                    Text("%")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.jbSubtext)
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
        .padding(.horizontal, Spacing.md)
    }

    private var accuracyColor: Color {
        guard progress.totalAnswered > 0 else { return Color.jbSubtext }
        let p = progress.accuracyPercent
        if p >= 70 { return Color.jbSuccess }
        if p >= 40 { return Color.jbWarning }
        return Color.jbError
    }
}

// MARK: - LevelSectionView

struct LevelSectionView: View {
    let level: JavaLevel
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
                    AllQuizzesView(level: level, onSelect: onSelect)
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
    @State private var currentQuiz: Quiz
    @State private var quizVM: QuizViewModel
    @State private var activeExplanation: Explanation?
    @AppStorage("codeZoom") private var codeZoom: Double = CodeZoom.default
    @Environment(\.dismiss) private var dismiss

    init(quiz: Quiz) {
        self._currentQuiz = State(initialValue: quiz)
        self._quizVM = State(wrappedValue: QuizViewModel(quiz: quiz))
    }

    var body: some View {
        NavigationStack {
            QuizView(
                vm: quizVM,
                codeZoom: codeZoom,
                onShowExplanation: {
                    activeExplanation = Explanation.sample(for: currentQuiz.explanationRef)
                },
                onNextQuiz: { goToNextQuiz() }
            )
            .id(currentQuiz.id)
            .navigationTitle(currentQuiz.categoryDisplayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(Color.jbSubtext)
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

    private func goToNextQuiz() {
        let pool = Quiz.samples.filter { $0.level == currentQuiz.level }
        guard !pool.isEmpty else { return }
        let idx = pool.firstIndex(where: { $0.id == currentQuiz.id }) ?? -1
        let next = pool[(idx + 1) % pool.count]
        currentQuiz = next
        quizVM = QuizViewModel(quiz: next)
    }
}
