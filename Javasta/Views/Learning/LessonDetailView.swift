import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    var onSelectQuiz: ((String) -> Void)? = nil
    @AppStorage("codeZoom") private var codeZoom: Double = CodeZoom.default
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    headerCard

                    ForEach(Array(lesson.sections.enumerated()), id: \.element.id) { idx, section in
                        sectionView(section, index: idx + 1)
                    }

                    keyPointsCard

                    if let onSelectQuiz, !lesson.relatedQuizIds.isEmpty {
                        relatedQuizSection(onSelectQuiz: onSelectQuiz)
                    }

                    Spacer(minLength: Spacing.xxl)
                }
                .padding(Spacing.md)
            }
        }
        .navigationTitle(lesson.categoryDisplayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                LevelBadgeView(
                    level: lesson.level,
                    zoomPercent: CodeZoom.percent(codeZoom),
                    onTap: { codeZoom = CodeZoom.next(after: codeZoom) }
                )
            }
        }
        .sensoryFeedback(.selection, trigger: codeZoom)
        .preferredColorScheme(.dark)
    }

    // MARK: Header

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "book.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.jbAccent)
                Text("LESSON")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.jbAccent)
                    .tracking(0.5)
                Spacer()
                Label("\(lesson.estimatedMinutes)分", systemImage: "clock")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.jbSubtext)
            }

            Text(lesson.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.jbText)

            Text(lesson.summary)
                .font(.system(size: 14))
                .foregroundStyle(Color.jbSubtext)
                .lineSpacing(4)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbBorder, lineWidth: 1)
                )
        )
    }

    // MARK: Section

    private func sectionView(_ section: Lesson.Section, index: Int) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Text("\(index)")
                    .font(.system(size: 12, weight: .bold).monospacedDigit())
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(Color.jbAccent))
                Text(section.heading)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.jbText)
            }

            Text(section.body)
                .font(.system(size: 14))
                .foregroundStyle(Color.jbText)
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let code = section.code {
                CodePanelView(
                    code: code,
                    highlightLines: section.highlightLines,
                    zoom: codeZoom
                )
                .frame(maxHeight: 240)
                .background(Color.jbBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .stroke(Color.jbBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
            }

            if let callout = section.callout {
                calloutView(callout)
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

    // MARK: Callout

    private func calloutView(_ callout: Lesson.Callout) -> some View {
        let style = calloutStyle(callout.kind)
        return HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: style.icon)
                .font(.system(size: 13))
                .foregroundStyle(style.color)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(style.label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(style.color)
                    .tracking(0.5)
                Text(callout.text)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.jbText)
                    .lineSpacing(3)
            }
            Spacer(minLength: 0)
        }
        .padding(Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: Radius.sm)
                .fill(style.color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .stroke(style.color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func calloutStyle(_ kind: Lesson.Callout.Kind) -> (icon: String, label: String, color: Color) {
        switch kind {
        case .tip:     return ("lightbulb.fill", "TIP", Color.jbAccent)
        case .warning: return ("exclamationmark.triangle.fill", "WARNING", Color.jbWarning)
        case .note:    return ("info.circle.fill", "NOTE", Color.jbSubtext)
        case .exam:    return ("checkmark.seal.fill", "試験ポイント", Color.jbSuccess)
        }
    }

    // MARK: Key points

    private var keyPointsCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "key.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.jbWarning)
                Text("覚えるポイント")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.jbText)
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(lesson.keyPoints.enumerated()), id: \.offset) { _, point in
                    HStack(alignment: .top, spacing: Spacing.xs) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.jbSuccess)
                            .padding(.top, 4)
                        Text(point)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.jbText)
                            .lineSpacing(3)
                    }
                }
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbWarning.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbWarning.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: Related quiz

    private func relatedQuizSection(onSelectQuiz: @escaping (String) -> Void) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("関連する問題で試す")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.jbSubtext)

            ForEach(lesson.relatedQuizIds, id: \.self) { quizId in
                if let quiz = Quiz.samples.first(where: { $0.id == quizId }) {
                    Button(action: { onSelectQuiz(quizId) }) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "pencil.and.list.clipboard")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.jbAccent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(quiz.question)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.jbText)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                Text(quiz.categoryDisplayName)
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.jbSubtext)
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
                                        .stroke(Color.jbAccent.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
