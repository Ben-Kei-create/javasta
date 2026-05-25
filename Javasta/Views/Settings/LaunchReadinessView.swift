#if DEBUG
import SwiftUI

struct LaunchReadinessView: View {
    private var snapshot: LaunchReadinessSnapshot {
        LaunchReadinessSnapshot()
    }

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    summaryCard
                    contentMetrics
                    coverageCard
                    checklist
                    marketingCopyCard
                }
                .padding(Spacing.md)
            }
        }
        .navigationTitle("販売準備")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    private var summaryCard: some View {
        let ready = snapshot.isReadyForStoreReview
        return VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: ready ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(ready ? Color.jbSuccess : Color.jbWarning)
                Spacer()
                Text(ready ? "READY" : "CHECK")
                    .font(.system(size: 12, weight: .heavy).monospaced())
                    .foregroundStyle(ready ? Color.jbSuccess : Color.jbWarning)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Capsule().fill((ready ? Color.jbSuccess : Color.jbWarning).opacity(0.14)))
            }

            Text(ready ? "教材品質はリリース水準です" : "販売前に確認したい項目があります")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.jbText)

            Text("App Store審査に出す前の内部チェックです。通常リリースではこの画面は表示されません。")
                .font(.system(size: 13))
                .foregroundStyle(Color.jbSubtext)
                .lineSpacing(4)
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(ready ? Color.jbSuccess.opacity(0.35) : Color.jbWarning.opacity(0.35), lineWidth: 1)
                )
        )
    }

    private var contentMetrics: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
            LaunchReadinessMetric(title: "Silver通常", value: "\(snapshot.silverPracticeCount)問", tint: Color.jbAccent)
            LaunchReadinessMetric(title: "Gold通常", value: "\(snapshot.goldPracticeCount)問", tint: Color.jbAccent)
            LaunchReadinessMetric(title: "Silver模試専用", value: "\(snapshot.silverMockOnlyCount)問", tint: snapshot.silverMockOnlyCount >= 100 ? Color.jbSuccess : Color.jbWarning)
            LaunchReadinessMetric(title: "Gold模試専用", value: "\(snapshot.goldMockOnlyCount)問", tint: snapshot.goldMockOnlyCount >= 100 ? Color.jbSuccess : Color.jbWarning)
            LaunchReadinessMetric(title: "用語", value: "\(snapshot.glossaryCount)件", tint: Color.jbSuccess)
            LaunchReadinessMetric(title: "レッスン", value: "\(snapshot.lessonCount)件", tint: Color.jbSuccess)
        }
    }

    private var checklist: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("リリース前チェック")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.jbText)
                .padding(.horizontal, Spacing.xs)

            VStack(spacing: 0) {
                LaunchReadinessCheckRow(
                    title: "汎用解説・紐付け",
                    detail: "汎用、欠落、重複ref、未使用解説",
                    value: "\(snapshot.explanationIssueCount)件",
                    isPassing: snapshot.explanationIssueCount == 0
                )
                Divider().background(Color.jbBorder).padding(.horizontal, Spacing.md)
                LaunchReadinessCheckRow(
                    title: "内容品質監査",
                    detail: "重複コード、重複設計意図、重複選択肢など",
                    value: "\(snapshot.contentQualityIssueCount)件",
                    isPassing: snapshot.contentQualityIssueCount == 0
                )
                Divider().background(Color.jbBorder).padding(.horizontal, Spacing.md)
                LaunchReadinessCheckRow(
                    title: "問題データ検証",
                    detail: "ID、正答数、カテゴリ、関連問題リンク",
                    value: "\(snapshot.validationIssueCount)件",
                    isPassing: snapshot.validationIssueCount == 0
                )
                Divider().background(Color.jbBorder).padding(.horizontal, Spacing.md)
                LaunchReadinessCheckRow(
                    title: "出題範囲カバレッジ",
                    detail: "SE / 級ごとの試験範囲に通常問題があるか",
                    value: "\(snapshot.coverageIssueCount)件",
                    isPassing: snapshot.coverageIssueCount == 0
                )
                Divider().background(Color.jbBorder).padding(.horizontal, Spacing.md)
                LaunchReadinessCheckRow(
                    title: "模試専用問題",
                    detail: "Silver / Gold それぞれ100問を目安",
                    value: "\(min(snapshot.silverMockOnlyCount, snapshot.goldMockOnlyCount))/100",
                    isPassing: snapshot.silverMockOnlyCount >= 100 && snapshot.goldMockOnlyCount >= 100
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(Color.jbBorder, lineWidth: 1)
            )
        }
    }

    private var coverageCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("出題範囲カバレッジ")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.jbText)
                Spacer()
                Text(snapshot.coverageIssueCount == 0 ? "ALL COVERED" : "\(snapshot.coverageIssueCount) OPEN")
                    .font(.system(size: 10, weight: .heavy).monospaced())
                    .foregroundStyle(snapshot.coverageIssueCount == 0 ? Color.jbSuccess : Color.jbWarning)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill((snapshot.coverageIssueCount == 0 ? Color.jbSuccess : Color.jbWarning).opacity(0.12))
                    )
            }

            VStack(spacing: 0) {
                ForEach(Array(snapshot.coverageGroups.enumerated()), id: \.element.id) { index, group in
                    LaunchCoverageGroupRow(group: group)
                    if index < snapshot.coverageGroups.count - 1 {
                        Divider().background(Color.jbBorder).padding(.leading, Spacing.md)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(Color.jbBorder, lineWidth: 1)
            )
        }
    }

    private var marketingCopyCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("広告で押す軸")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.jbText)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                LaunchCopyLine(icon: "curlybraces", text: "コードの流れを追って理解するJava試験対策")
                LaunchCopyLine(icon: "checklist.checked", text: "Silver / Gold対応、通常練習と本番想定模試")
                LaunchCopyLine(icon: "doc.text.magnifyingglass", text: "汎用解説ではなく、各問題ごとの追跡解説")
                LaunchCopyLine(icon: "flag", text: "問題報告とフィードバック導線で品質改善を回せる")
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
}

private struct LaunchReadinessSnapshot {
    let silverPracticeCount: Int
    let goldPracticeCount: Int
    let silverMockOnlyCount: Int
    let goldMockOnlyCount: Int
    let glossaryCount: Int
    let lessonCount: Int
    let explanationIssueCount: Int
    let contentQualityIssueCount: Int
    let validationIssueCount: Int
    let coverageGroups: [LaunchReadinessCoverageGroup]

    init() {
        let explanationReport = QuestionBank.explanationAuditReport()
        silverPracticeCount = QuestionBank.quizzes(version: .se17, level: .silver).count
        goldPracticeCount = QuestionBank.quizzes(version: .se17, level: .gold).count
        silverMockOnlyCount = QuestionBank.mockExamOnlyQuizzes.filter { $0.level == .silver && $0.examVersion == .se17 }.count
        goldMockOnlyCount = QuestionBank.mockExamOnlyQuizzes.filter { $0.level == .gold && $0.examVersion == .se17 }.count
        glossaryCount = GlossaryTerm.samples.count
        lessonCount = Lesson.samples.count
        explanationIssueCount = explanationReport.needsAttentionCount
        contentQualityIssueCount = QuestionBank.contentQualityIssues().count
        validationIssueCount = QuestionBank.validationIssues().count
        coverageGroups = JavaExamVersion.allCases.flatMap { version in
            JavaLevel.allCases.compactMap { level in
                let objectives = QuestionBank.coverage(version: version, level: level)
                guard !objectives.isEmpty else { return nil }
                let items = objectives.map {
                    LaunchReadinessObjectiveCoverage(
                        objective: $0.objective,
                        count: $0.count
                    )
                }
                return LaunchReadinessCoverageGroup(
                    version: version,
                    level: level,
                    practiceCount: QuestionBank.quizzes(version: version, level: level).count,
                    objectives: items
                )
            }
        }
    }

    var isReadyForStoreReview: Bool {
        explanationIssueCount == 0 &&
        contentQualityIssueCount == 0 &&
        validationIssueCount == 0 &&
        coverageIssueCount == 0 &&
        silverMockOnlyCount >= 100 &&
        goldMockOnlyCount >= 100
    }

    var coverageIssueCount: Int {
        coverageGroups.reduce(0) { $0 + $1.uncoveredCount }
    }
}

private struct LaunchReadinessCoverageGroup: Identifiable {
    let version: JavaExamVersion
    let level: JavaLevel
    let practiceCount: Int
    let objectives: [LaunchReadinessObjectiveCoverage]

    var id: String {
        "\(version.rawValue)-\(level.rawValue)"
    }

    var title: String {
        "\(version.displayName) / \(level.displayName)"
    }

    var coveredCount: Int {
        objectives.filter { $0.count > 0 }.count
    }

    var totalObjectiveCount: Int {
        objectives.count
    }

    var uncoveredCount: Int {
        totalObjectiveCount - coveredCount
    }

    var minimumCount: Int {
        objectives.map(\.count).min() ?? 0
    }

    var progress: Double {
        guard totalObjectiveCount > 0 else { return 0 }
        return Double(coveredCount) / Double(totalObjectiveCount)
    }

    var uncoveredTitles: String {
        objectives
            .filter { $0.count == 0 }
            .map { $0.objective.title }
            .prefix(2)
            .joined(separator: "、")
    }
}

private struct LaunchReadinessObjectiveCoverage: Identifiable {
    let objective: ExamObjective
    let count: Int

    var id: String {
        objective.id
    }
}

private struct LaunchReadinessMetric: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold).monospacedDigit())
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.jbSubtext)
                .lineLimit(1)
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
}

private struct LaunchCoverageGroupRow: View {
    let group: LaunchReadinessCoverageGroup

    private var isPassing: Bool {
        group.uncoveredCount == 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(group.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.jbText)
                    Text("\(group.practiceCount)問 / 最少 \(group.minimumCount)問")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.jbSubtext)
                }

                Spacer(minLength: Spacing.sm)

                Text("\(group.coveredCount)/\(group.totalObjectiveCount)")
                    .font(.system(size: 14, weight: .bold).monospacedDigit())
                    .foregroundStyle(isPassing ? Color.jbSuccess : Color.jbWarning)
            }

            ProgressView(value: group.progress)
                .tint(isPassing ? Color.jbSuccess : Color.jbWarning)
                .scaleEffect(x: 1, y: 1.2)

            if !isPassing {
                Text("未カバー: \(group.uncoveredTitles)")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.jbWarning)
                    .lineLimit(2)
            }
        }
        .padding(Spacing.md)
        .background(Color.jbCard)
    }
}

private struct LaunchReadinessCheckRow: View {
    let title: String
    let detail: String
    let value: String
    let isPassing: Bool

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: isPassing ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(isPassing ? Color.jbSuccess : Color.jbWarning)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.jbText)
                Text(detail)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.jbSubtext)
                    .lineLimit(2)
            }

            Spacer(minLength: Spacing.sm)

            Text(value)
                .font(.system(size: 13, weight: .bold).monospacedDigit())
                .foregroundStyle(isPassing ? Color.jbSuccess : Color.jbWarning)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 12)
        .background(Color.jbCard)
    }
}

private struct LaunchCopyLine: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.jbAccent)
                .frame(width: 22)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(Color.jbText)
                .lineSpacing(3)
        }
    }
}

#Preview {
    NavigationStack {
        LaunchReadinessView()
    }
}
#endif
