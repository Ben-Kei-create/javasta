import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    var onSelectQuiz: ((String) -> Void)? = nil
    @AppStorage("codeZoom") private var codeZoom: Double = CodeZoom.default
    @Environment(\.dismiss) private var dismiss
    @State private var progress = ProgressStore.shared

    @State private var glossaryRoot: GlossaryRoot? = nil
    @State private var glossaryPath: [String] = []

    private struct GlossaryRoot: Identifiable, Hashable {
        let id: String
    }

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    headerCard

                    ForEach(Array(lesson.sections.enumerated()), id: \.element.id) { idx, section in
                        sectionView(section, index: idx + 1)
                    }

                    keyPointsCard
                    completionCard

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
    }

    @ViewBuilder
    private func glossarySheet(rootId: String) -> some View {
        if let term = GlossaryTerm.lookup(rootId) {
            let origin = GlossaryDetailView.Origin(
                icon: "book.fill",
                label: lesson.title,
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
            .environment(\.openURL, OpenURLAction { url in
                if let id = GlossaryTerm.parse(url: url) {
                    glossaryPath.append(id)
                    return .handled
                }
                return .systemAction
            })
        }
    }

    // MARK: Header

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // メタ行
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
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.jbText)

            // 対象読者バナー（Silver / Gold で変わる）
            audienceBanner

            Text(lesson.summary)
                .font(.system(size: 15))
                .foregroundStyle(Color.jbSubtext)
                .lineSpacing(6)
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .jbCard(radius: Radius.lg)
    }

    /// Silver = Java初学者向け、Gold = Silver取得者・Javaエンジニア向け
    private var audienceBanner: some View {
        let (icon, label, detail, tint): (String, String, String, Color) = {
            switch lesson.level {
            case .silver:
                return ("graduationcap.fill", "Java初学者向け",
                        "Javaをはじめて学ぶ方・基礎を固めたい方", Color.jbSuccess)
            case .gold:
                return ("briefcase.fill", "Silver取得者・Javaエンジニア向け",
                        "実務で使う応用知識を深掘りするレッスン", Color.jbAccent)
            }
        }()
        return HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(tint)
                Text(detail)
                    .font(.system(size: 11))
                    .foregroundStyle(tint.opacity(0.75))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: Radius.sm)
                .fill(tint.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: Radius.sm).stroke(tint.opacity(0.3), lineWidth: 1))
        )
    }

    // MARK: Markdown helper

    private func markdownBody(_ source: String) -> Text {
        let opts = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        if let attr = try? AttributedString(markdown: source, options: opts) {
            return Text(attr)
        }
        return Text(source)
    }

    // MARK: Section

    private func sectionView(_ section: Lesson.Section, index: Int) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // セクション番号 + 見出し
            HStack(spacing: Spacing.sm) {
                Text("\(index)")
                    .font(.system(size: 12, weight: .bold).monospacedDigit())
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.jbAccent))
                Text(section.heading)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.jbText)
            }

            // 本文（余白たっぷり・行間広め）
            markdownBody(section.body)
                .font(.system(size: 15))
                .foregroundStyle(Color.jbText)
                .lineSpacing(7)
                .tint(Color.jbAccent)
                .frame(maxWidth: .infinity, alignment: .leading)

            // コードブロック（高さ制限なし — 全行表示）
            if let code = section.code {
                CodePanelView(
                    code: code,
                    highlightLines: section.highlightLines,
                    zoom: codeZoom
                )
                .background(Color.jbBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .stroke(Color.jbBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
            }

            // コールアウト
            if let callout = section.callout {
                calloutView(callout)
            }
        }
        .padding(Spacing.lg)
        .jbCard(radius: Radius.lg)
    }

    // MARK: Callout

    private func calloutView(_ callout: Lesson.Callout) -> some View {
        let style = calloutStyle(callout.kind)
        return VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: 5) {
                Image(systemName: style.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(style.color)
                Text(style.label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(style.color)
                    .tracking(0.5)
            }
            Text(callout.text)
                .font(.system(size: 14))
                .foregroundStyle(Color.jbText)
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radius.sm)
                .fill(style.color.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .stroke(style.color.opacity(0.35), lineWidth: 1)
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
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "key.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.jbWarning)
                Text("覚えるポイント")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.jbText)
            }

            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(Array(lesson.keyPoints.enumerated()), id: \.offset) { _, point in
                    HStack(alignment: .top, spacing: Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.jbSuccess)
                            .padding(.top, 1)
                        Text(point)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.jbText)
                            .lineSpacing(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.lg)
                .fill(Color.jbWarning.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .stroke(Color.jbWarning.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var completionCard: some View {
        let completed = progress.completedLessons.contains(lesson.id)
        return Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            progress.markLessonCompleted(lesson.id)
            if !completed { dismiss() }
        }) {
            HStack(spacing: Spacing.md) {
                Image(systemName: completed ? "checkmark.seal.fill" : "checkmark.circle")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(completed ? Color.jbSuccess : Color.jbAccent)

                VStack(alignment: .leading, spacing: 3) {
                    Text(completed ? "レッスン完了済み ✓" : "このレッスンを完了にする")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(completed ? Color.jbSuccess : Color.jbText)
                    Text(completed ? "関連問題で定着度を確認しましょう"
                                   : "タップして完了 — 学習ログに記録されます")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.jbSubtext)
                        .lineSpacing(3)
                }

                Spacer()

                if !completed {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.jbAccent)
                }
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(completed ? Color.jbSuccess.opacity(0.08) : Color.jbAccent.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.lg)
                            .stroke(completed ? Color.jbSuccess.opacity(0.4) : Color.jbAccent.opacity(0.4), lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(JBScaledButtonStyle(scaleAmount: 0.98))
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
