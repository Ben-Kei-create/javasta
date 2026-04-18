import SwiftUI

struct HomeView: View {
    @State private var selectedQuiz: Quiz?

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

            Button(action: {}) {
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
                    Text("1")
                        .font(.system(size: 28, weight: .bold).monospacedDigit())
                        .foregroundStyle(Color.jbAccent)
                    Text("/ 5 問")
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
                    Text("3")
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
                    Text("72")
                        .font(.system(size: 28, weight: .bold).monospacedDigit())
                        .foregroundStyle(Color.jbSuccess)
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
                Button(action: {}) {
                    Text("すべて見る")
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
    let quiz: Quiz
    @State private var quizVM: QuizViewModel
    @State private var activeExplanation: Explanation?
    @Environment(\.dismiss) private var dismiss

    init(quiz: Quiz) {
        self.quiz = quiz
        self._quizVM = State(wrappedValue: QuizViewModel(quiz: quiz))
    }

    var body: some View {
        NavigationStack {
            QuizView(vm: quizVM, onShowExplanation: {
                activeExplanation = Explanation.sample(for: quiz.explanationRef)
            })
            .navigationTitle(quiz.categoryDisplayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(Color.jbSubtext)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    LevelBadgeView(level: quiz.level)
                }
            }
        }
        .fullScreenCover(item: $activeExplanation) { explanation in
            ExplanationView(explanation: explanation, onDismiss: { activeExplanation = nil })
        }
    }
}
