import SwiftUI

struct GlossaryDetailView: View {
    let term: GlossaryTerm
    var origin: Origin? = nil
    var onSelectLesson: ((String) -> Void)? = nil
    var onSelectQuiz: ((String) -> Void)? = nil

    /// 用語集チェーンの起点 (レッスン/問題など) に一気に戻るための情報。
    struct Origin {
        let icon: String
        let label: String
        let action: () -> Void
    }

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    if let origin {
                        originBar(origin)
                    }
                    headerCard
                    bodyCard

                    if !term.relatedTermIds.isEmpty {
                        relatedTermsSection
                    }
                    if !term.relatedLessonIds.isEmpty, onSelectLesson != nil {
                        relatedLessonsSection
                    }
                    if !term.relatedQuizIds.isEmpty, onSelectQuiz != nil {
                        relatedQuizzesSection
                    }

                    Spacer(minLength: Spacing.xxl)
                }
                .padding(Spacing.md)
            }
        }
        .navigationTitle("用語")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    // MARK: Origin bar

    private func originBar(_ origin: Origin) -> some View {
        Button(action: origin.action) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.jbAccent)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.jbAccent.opacity(0.15)))

                VStack(alignment: .leading, spacing: 1) {
                    Text("最初に戻る")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.jbSubtext)
                        .tracking(0.3)
                    HStack(spacing: 4) {
                        Image(systemName: origin.icon)
                            .font(.system(size: 11))
                        Text(origin.label)
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(Color.jbAccent)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.jbAccent.opacity(0.6))
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(Color.jbAccent.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(Color.jbAccent.opacity(0.35), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: Header

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "character.book.closed.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.jbAccent)
                Text("TERM")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.jbAccent)
                    .tracking(0.5)
                Spacer()
            }

            Text(term.term)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color.jbText)

            if !term.aliases.isEmpty {
                Text(term.aliases.joined(separator: " · "))
                    .font(.codeFont(11))
                    .foregroundStyle(Color.jbSubtext)
            }

            markdown(term.summary)
                .font(.system(size: 14))
                .foregroundStyle(Color.jbText)
                .lineSpacing(4)
                .tint(Color.jbAccent)
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

    // MARK: Body

    private var bodyCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            markdown(term.body, full: true)
                .font(.system(size: 14))
                .foregroundStyle(Color.jbText)
                .lineSpacing(5)
                .tint(Color.jbAccent)
                .frame(maxWidth: .infinity, alignment: .leading)
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

    // MARK: Related terms

    private var relatedTermsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionLabel("関連する用語")
            FlowLayout(spacing: Spacing.xs) {
                ForEach(term.relatedTermIds, id: \.self) { id in
                    if let related = GlossaryTerm.lookup(id) {
                        NavigationLink(value: id) {
                            HStack(spacing: 4) {
                                Image(systemName: "link")
                                    .font(.system(size: 10))
                                Text(related.term)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundStyle(Color.jbAccent)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.jbAccent.opacity(0.1))
                                    .overlay(Capsule().stroke(Color.jbAccent.opacity(0.4), lineWidth: 1))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: Related lessons / quizzes

    private var relatedLessonsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionLabel("関連レッスン")
            ForEach(term.relatedLessonIds, id: \.self) { id in
                if let lesson = Lesson.sample(for: id) {
                    Button(action: { onSelectLesson?(id) }) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.jbAccent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(lesson.title)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color.jbText)
                                Text("\(lesson.estimatedMinutes)分")
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
                                        .stroke(Color.jbBorder, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var relatedQuizzesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionLabel("関連する問題")
            ForEach(term.relatedQuizIds, id: \.self) { id in
                if let quiz = Quiz.samples.first(where: { $0.id == id }) {
                    Button(action: { onSelectQuiz?(id) }) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "pencil.and.list.clipboard")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.jbAccent)
                            Text(quiz.question)
                                .font(.system(size: 13))
                                .foregroundStyle(Color.jbText)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
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

    // MARK: Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Color.jbSubtext)
            .tracking(0.5)
    }

    private func markdown(_ source: String, full: Bool = false) -> Text {
        let opts = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: full ? .full : .inlineOnlyPreservingWhitespace
        )
        if let attr = try? AttributedString(markdown: source, options: opts) {
            return Text(attr)
        }
        return Text(source)
    }
}

// MARK: - FlowLayout (折り返し配置)

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        for sv in subviews {
            let sz = sv.sizeThatFits(.unspecified)
            if rowWidth + sz.width > maxWidth, rowWidth > 0 {
                totalHeight += rowHeight + spacing
                totalWidth = max(totalWidth, rowWidth - spacing)
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += sz.width + spacing
            rowHeight = max(rowHeight, sz.height)
        }
        totalHeight += rowHeight
        totalWidth = max(totalWidth, rowWidth - spacing)
        return CGSize(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for sv in subviews {
            let sz = sv.sizeThatFits(.unspecified)
            if x + sz.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            sv.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(sz))
            x += sz.width + spacing
            rowHeight = max(rowHeight, sz.height)
        }
    }
}
