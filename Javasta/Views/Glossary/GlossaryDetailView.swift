import SwiftUI

struct GlossaryDetailView: View {
    let term: GlossaryTerm
    var allTerms: [GlossaryTerm] = GlossaryTerm.samples
    var origin: Origin? = nil
    var onSelectLesson: ((String) -> Void)? = nil
    var onSelectQuiz: ((String) -> Void)? = nil

    @State private var displayedTerm: GlossaryTerm
    @State private var termHistory: [GlossaryTerm] = []
    @Environment(\.dismiss) private var dismiss

    /// 用語集チェーンの起点 (レッスン/問題など) に一気に戻るための情報。
    struct Origin {
        let icon: String
        let label: String
        let action: () -> Void
    }

    init(term: GlossaryTerm,
         allTerms: [GlossaryTerm] = GlossaryTerm.samples,
         origin: Origin? = nil,
         onSelectLesson: ((String) -> Void)? = nil,
         onSelectQuiz: ((String) -> Void)? = nil) {
        self.term = term
        self.allTerms = allTerms
        self.origin = origin
        self.onSelectLesson = onSelectLesson
        self.onSelectQuiz = onSelectQuiz
        self._displayedTerm = State(initialValue: term)
    }

    // MARK: Sequential nav

    private var currentIndex: Int? {
        allTerms.firstIndex { $0.id == displayedTerm.id }
    }
    private var prevTerm: GlossaryTerm? {
        guard let i = currentIndex, i > 0 else { return nil }
        return allTerms[i - 1]
    }
    private var nextTerm: GlossaryTerm? {
        guard let i = currentIndex, i < allTerms.count - 1 else { return nil }
        return allTerms[i + 1]
    }

    private func navigate(to id: String) {
        guard let t = GlossaryTerm.lookup(id), t.id != displayedTerm.id else { return }
        termHistory.append(displayedTerm)
        withAnimation(.jbFast) { displayedTerm = t }
    }

    private func goBack() {
        guard !termHistory.isEmpty else { return }
        withAnimation(.jbFast) { displayedTerm = termHistory.removeLast() }
    }

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    if !termHistory.isEmpty {
                        historyBackBar
                    }
                    if let origin {
                        originBar(origin)
                    }
                    headerCard
                    bodyCard

                    if !displayedTerm.relatedTermIds.isEmpty {
                        relatedTermsSection
                    }
                    if !displayedTerm.relatedLessonIds.isEmpty, onSelectLesson != nil {
                        relatedLessonsSection
                    }
                    if !displayedTerm.relatedQuizIds.isEmpty, onSelectQuiz != nil {
                        relatedQuizzesSection
                    }

                    prevNextBar

                    Spacer(minLength: Spacing.xxl)
                }
                .padding(Spacing.md)
            }
        }
        .navigationTitle("用語")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 3) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 12))
                        Text("一覧")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(Color.jbAccent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: History back bar

    private var historyBackBar: some View {
        Button(action: goBack) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.jbAccent)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.jbAccent.opacity(0.15)))
                VStack(alignment: .leading, spacing: 1) {
                    Text("前の用語に戻る")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.jbSubtext)
                    Text(termHistory.last?.term ?? "")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.jbAccent)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.left")
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
                if let i = currentIndex {
                    Text("\(i + 1) / \(allTerms.count)")
                        .font(.system(size: 10, weight: .semibold).monospacedDigit())
                        .foregroundStyle(Color.jbSubtext)
                }
            }

            Text(displayedTerm.term)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color.jbText)

            if !displayedTerm.aliases.isEmpty {
                Text(displayedTerm.aliases.joined(separator: " · "))
                    .font(.codeFont(11))
                    .foregroundStyle(Color.jbSubtext)
            }

            markdown(displayedTerm.summary)
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
            markdown(displayedTerm.body, full: true)
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
        .environment(\.openURL, OpenURLAction { url in
            if let id = GlossaryTerm.parse(url: url) {
                navigate(to: id)
                return .handled
            }
            return .systemAction
        })
    }

    // MARK: Related terms

    private var relatedTermsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionLabel("関連する用語")
            FlowLayout(spacing: Spacing.xs) {
                ForEach(displayedTerm.relatedTermIds, id: \.self) { id in
                    if let related = GlossaryTerm.lookup(id) {
                        Button(action: { navigate(to: id) }) {
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
            ForEach(displayedTerm.relatedLessonIds, id: \.self) { id in
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
            ForEach(displayedTerm.relatedQuizIds, id: \.self) { id in
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

    // MARK: Prev / Next bar

    private var prevNextBar: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: {
                if let p = prevTerm {
                    termHistory.removeAll()
                    withAnimation(.jbFast) { displayedTerm = p }
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .bold))
                    Text(prevTerm?.term ?? "")
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)
                }
                .foregroundStyle(prevTerm != nil ? Color.jbAccent : Color.jbSubtext.opacity(0.3))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .fill(Color.jbCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.sm)
                                .stroke(prevTerm != nil ? Color.jbAccent.opacity(0.4) : Color.jbBorder, lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            .disabled(prevTerm == nil)

            Button(action: {
                if let n = nextTerm {
                    termHistory.removeAll()
                    withAnimation(.jbFast) { displayedTerm = n }
                }
            }) {
                HStack(spacing: 4) {
                    Text(nextTerm?.term ?? "")
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(nextTerm != nil ? Color.jbAccent : Color.jbSubtext.opacity(0.3))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .fill(Color.jbCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.sm)
                                .stroke(nextTerm != nil ? Color.jbAccent.opacity(0.4) : Color.jbBorder, lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            .disabled(nextTerm == nil)
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
