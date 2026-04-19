import SwiftUI

struct LearningHomeView: View {
    @State private var selectedLesson: Lesson?
    @State private var pendingQuizId: String?
    @State private var activeQuiz: Quiz?
    @State private var progress = ProgressStore.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color.jbBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        headerSection

                        ForEach(JavaLevel.allCases, id: \.self) { level in
                            levelSection(level: level)
                        }
                    }
                    .padding(.bottom, Spacing.xxl)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $selectedLesson, onDismiss: handleSheetDismiss) { lesson in
            NavigationStack {
                LessonDetailView(lesson: lesson, onSelectQuiz: { quizId in
                    pendingQuizId = quizId
                    selectedLesson = nil
                })
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("閉じる") { selectedLesson = nil }
                            .foregroundStyle(Color.jbSubtext)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
        .sheet(item: $activeQuiz) { quiz in
            QuizSheetView(quiz: quiz)
        }
        .preferredColorScheme(.dark)
    }

    private func handleSheetDismiss() {
        guard let id = pendingQuizId else { return }
        pendingQuizId = nil
        if let quiz = Quiz.samples.first(where: { $0.id == id }) {
            activeQuiz = quiz
        }
    }

    // MARK: Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("学習")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Color.jbText)
            Text("教科書 → 問題 で確実に身につける")
                .font(.system(size: 14))
                .foregroundStyle(Color.jbSubtext)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.lg)
    }

    // MARK: Level section

    private func levelSection(level: JavaLevel) -> some View {
        let lessons = Lesson.samples.filter { $0.level == level }
        return VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Text(level.displayName)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(Color.jbText)
                LevelBadgeView(level: level)
                Spacer()
            }
            .padding(.horizontal, Spacing.md)

            VStack(spacing: Spacing.sm) {
                ForEach(lessons) { lesson in
                    LessonRowView(
                        lesson: lesson,
                        isCompleted: progress.completedLessons.contains(lesson.id),
                        onTap: { selectedLesson = lesson }
                    )
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}

// MARK: - LessonRowView

struct LessonRowView: View {
    let lesson: Lesson
    var isCompleted: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .fill(Color.jbAccent.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "book.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(Color.jbAccent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.jbText)
                        .multilineTextAlignment(.leading)

                    Text(lesson.summary)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.jbSubtext)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: Spacing.sm) {
                        Label("\(lesson.estimatedMinutes)分", systemImage: "clock")
                        Text("·")
                        Text(lesson.categoryDisplayName)
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(Color.jbSubtext)
                }

                Spacer()

                Image(systemName: isCompleted ? "checkmark.circle.fill" : "chevron.right")
                    .font(.system(size: 11))
                    .foregroundStyle(isCompleted ? Color.jbSuccess : Color.jbSubtext)
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
