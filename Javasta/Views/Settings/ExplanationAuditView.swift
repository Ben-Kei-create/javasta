import SwiftUI

struct ExplanationAuditView: View {
    @State private var selectedFilter: ExplanationAuditFilter = .needsWork

    private var report: ExplanationAuditReport {
        QuestionBank.explanationAuditReport()
    }

    private var visibleIssues: [ExplanationAuditIssue] {
        switch selectedFilter {
        case .needsWork:
            return report.issues
        case .placeholder:
            return report.issues.filter { $0.kind == .placeholder }
        case .linking:
            return report.issues.filter { $0.kind != .placeholder }
        }
    }

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    summaryBand
                    filterPicker
                    issueList
                }
                .padding(Spacing.md)
            }
        }
        .navigationTitle("解説チェック")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    private var summaryBand: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                ExplanationAuditMetric(
                    title: "問題",
                    value: "\(report.quizCount)",
                    tint: Color.jbAccent
                )
                ExplanationAuditMetric(
                    title: "手書き",
                    value: "\(report.authoredExplanationCount)",
                    tint: Color.jbSuccess
                )
                ExplanationAuditMetric(
                    title: "汎用",
                    value: "\(report.placeholderCount)",
                    tint: report.placeholderCount == 0 ? Color.jbSuccess : Color.jbWarning
                )
                ExplanationAuditMetric(
                    title: "紐付け",
                    value: "\(report.missingCount + report.duplicateRefCount + report.orphanedCount)",
                    tint: report.missingCount + report.duplicateRefCount + report.orphanedCount == 0 ? Color.jbSuccess : Color.jbError
                )
            }

            Text("汎用は quickTrace による自動生成解説です。手書き解説を追加して authoredSamples に登録すると、この一覧から消えます。")
                .font(.system(size: 12))
                .foregroundStyle(Color.jbSubtext)
                .fixedSize(horizontal: false, vertical: true)
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

    private var filterPicker: some View {
        Picker("表示", selection: $selectedFilter) {
            ForEach(ExplanationAuditFilter.allCases, id: \.self) { filter in
                Text(filter.title).tag(filter)
            }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder
    private var issueList: some View {
        if visibleIssues.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.jbSuccess)
                Text("この条件の問題はありません")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.jbText)
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
        } else {
            LazyVStack(spacing: Spacing.sm) {
                ForEach(visibleIssues) { issue in
                    ExplanationAuditIssueRow(issue: issue)
                }
            }
        }
    }
}

private enum ExplanationAuditFilter: CaseIterable {
    case needsWork
    case placeholder
    case linking

    var title: String {
        switch self {
        case .needsWork: return "要対応"
        case .placeholder: return "汎用"
        case .linking: return "紐付け"
        }
    }
}

private struct ExplanationAuditMetric: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.jbSubtext)
            Text(value)
                .font(.system(size: 20, weight: .bold).monospacedDigit())
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ExplanationAuditIssueRow: View {
    let issue: ExplanationAuditIssue

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .top, spacing: Spacing.sm) {
                Image(systemName: issue.kind.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(issue.kind.tint)
                    .frame(width: 22)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(issue.kind.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(issue.kind.tint)
                        if let level = issue.level {
                            Text(level.displayName)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color.jbSubtext)
                        }
                        if let category = issue.category {
                            Text(category)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color.jbSubtext)
                        }
                    }

                    Text(issue.quizId ?? "未使用の手書き解説")
                        .font(.system(size: 12, weight: .medium).monospaced())
                        .foregroundStyle(Color.jbText)

                    Text(issue.explanationRef)
                        .font(.system(size: 11).monospaced())
                        .foregroundStyle(Color.jbSubtext)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }

                Spacer(minLength: Spacing.sm)
            }

            Text(issue.detail)
                .font(.system(size: 13))
                .foregroundStyle(Color.jbSubtext)
                .fixedSize(horizontal: false, vertical: true)

            if let question = issue.question {
                Text(question)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.jbText)
                    .lineLimit(3)
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(issue.kind.tint.opacity(0.32), lineWidth: 1)
                )
        )
    }
}

private extension ExplanationAuditIssue.Kind {
    var title: String {
        switch self {
        case .placeholder: return "汎用解説"
        case .missing: return "紐付け切れ"
        case .duplicateRef: return "ref重複"
        case .orphaned: return "未使用"
        }
    }

    var icon: String {
        switch self {
        case .placeholder: return "doc.text"
        case .missing: return "link.badge.plus"
        case .duplicateRef: return "square.on.square"
        case .orphaned: return "tray"
        }
    }

    var tint: Color {
        switch self {
        case .placeholder: return Color.jbWarning
        case .missing: return Color.jbError
        case .duplicateRef: return Color.jbError
        case .orphaned: return Color.jbWarning
        }
    }
}

#Preview {
    NavigationStack {
        ExplanationAuditView()
    }
}
