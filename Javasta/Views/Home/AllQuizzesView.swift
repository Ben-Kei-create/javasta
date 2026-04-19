import SwiftUI

struct AllQuizzesView: View {
    let level: JavaLevel
    var onSelect: (Quiz) -> Void

    private var quizzes: [Quiz] {
        Quiz.samples.filter { $0.level == level }
    }

    private var grouped: [(category: QuizCategory, quizzes: [Quiz])] {
        let dict = Dictionary(grouping: quizzes) { quiz in
            QuizCategory(rawValue: quiz.category) ?? .controlFlow
        }
        return dict
            .map { ($0.key, $0.value) }
            .sorted { $0.0.displayName < $1.0.displayName }
    }

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    HStack(spacing: Spacing.sm) {
                        Text("\(quizzes.count) 問")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.jbSubtext)
                        LevelBadgeView(level: level)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.sm)

                    ForEach(grouped, id: \.category) { group in
                        categorySection(category: group.category, items: group.quizzes)
                    }

                    Spacer(minLength: Spacing.xxl)
                }
            }
        }
        .navigationTitle(level.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    private func categorySection(category: QuizCategory, items: [Quiz]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(category.displayName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.jbText)
                .padding(.horizontal, Spacing.md)

            VStack(spacing: Spacing.xs) {
                ForEach(items) { quiz in
                    QuizListRow(quiz: quiz, onTap: { onSelect(quiz) })
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}

// MARK: - QuizListRow

private struct QuizListRow: View {
    let quiz: Quiz
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quiz.question)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.jbText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    if !quiz.tags.isEmpty {
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
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.jbSubtext)
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
        .buttonStyle(.plain)
    }
}
