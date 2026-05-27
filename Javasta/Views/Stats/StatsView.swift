import Charts
import SwiftUI

// MARK: - StatsView

struct StatsView: View {
    @State private var progress = ProgressStore.shared
    @State private var selectedLevel: JavaLevel = .silver
    @AppStorage("selectedJavaLevel") private var selectedLevelRaw = JavaLevel.silver.rawValue

    private var level: JavaLevel {
        JavaLevel(rawValue: selectedLevelRaw) ?? .silver
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.jbBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        summaryRow
                        activityCalendar
                        weeklyAccuracyChart
                        categoryAccuracyChart
                        if !progress.mockExamAttempts.isEmpty {
                            mockExamScoreChart
                        }
                        weakTagsCard
                        Spacer(minLength: Spacing.xxl)
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("統計")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    levelSegmentedPicker
                }
            }
        }
    }

    // MARK: - Level picker

    private var levelSegmentedPicker: some View {
        Picker("レベル", selection: $selectedLevelRaw) {
            ForEach(JavaLevel.allCases, id: \.rawValue) { lv in
                Text(lv.displayName.replacingOccurrences(of: "Java ", with: ""))
                    .tag(lv.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .frame(width: 160)
    }

    // MARK: - Summary row (top KPIs)

    private var summaryRow: some View {
        HStack(spacing: Spacing.sm) {
            kpiCard(value: "\(progress.answeredCount(level: level))問",
                    label: "解答数",
                    icon: "pencil.and.list.clipboard",
                    tint: Color.jbAccent)
            kpiCard(value: progress.answerAttemptCount(level: level) > 0
                        ? "\(progress.levelAccuracyPercent(level))%"
                        : "—",
                    label: "正答率",
                    icon: "chart.line.uptrend.xyaxis",
                    tint: accuracyColor(progress.levelAccuracyPercent(level)))
            kpiCard(value: "\(progress.streakDays)日",
                    label: "連続",
                    icon: "flame.fill",
                    tint: Color.jbWarning)
            kpiCard(value: "\(progress.completedLessons.count)件",
                    label: "完了レッスン",
                    icon: "book.fill",
                    tint: Color.jbSuccess)
        }
    }

    private func kpiCard(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
            Text(value)
                .font(.system(size: 18, weight: .bold).monospacedDigit())
                .foregroundStyle(Color.jbText)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.jbSubtext)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .jbCard()
    }

    // MARK: - Activity calendar (12-week heatmap)

    private var activityCalendar: some View {
        let counts = progress.recentDailyCounts(days: 84)
        let maxCount = counts.map(\.count).max() ?? 1
        let weeks = stride(from: 0, to: 84, by: 7).map { offset in
            Array(counts[offset..<min(offset + 7, counts.count)])
        }

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            chartHeader(title: "アクティビティ", subtitle: "直近12週")

            VStack(spacing: 3) {
                // 曜日ラベル
                HStack(spacing: 3) {
                    Text("").frame(width: 20)
                    ForEach(["月","火","水","木","金","土","日"], id: \.self) { d in
                        Text(d)
                            .font(.system(size: 9))
                            .foregroundStyle(Color.jbSubtext)
                            .frame(maxWidth: .infinity)
                    }
                }

                HStack(alignment: .top, spacing: 3) {
                    // 週ラベル（M/月初のみ）
                    VStack(spacing: 3) {
                        ForEach(Array(weeks.enumerated()), id: \.offset) { i, week in
                            let firstDay = week.first.flatMap { parseDate($0.dateKey) }
                            let isMonthStart = firstDay.map { Calendar.current.component(.day, from: $0) <= 7 } ?? false
                            Text(isMonthStart ? monthLabel(firstDay) : "")
                                .font(.system(size: 9))
                                .foregroundStyle(Color.jbSubtext)
                                .frame(width: 20, height: cellSize)
                        }
                    }

                    // セル
                    ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                        VStack(spacing: 3) {
                            ForEach(week, id: \.dateKey) { entry in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(cellColor(entry.count, max: maxCount))
                                    .frame(width: cellSize, height: cellSize)
                            }
                        }
                    }
                }
            }

            // 凡例
            HStack(spacing: 4) {
                Text("少")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.jbSubtext)
                ForEach([0, 0.25, 0.5, 0.75, 1.0], id: \.self) { intensity in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.jbAccent.opacity(intensity == 0 ? 0.08 : intensity * 0.85 + 0.15))
                        .frame(width: cellSize, height: cellSize)
                }
                Text("多")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.jbSubtext)
            }
        }
        .padding(Spacing.md)
        .jbCard()
    }

    private let cellSize: CGFloat = 14

    private func cellColor(_ count: Int, max: Int) -> Color {
        guard max > 0 else { return Color.jbAccent.opacity(0.08) }
        if count == 0 { return Color.jbAccent.opacity(0.08) }
        let ratio = Double(count) / Double(max)
        return Color.jbAccent.opacity(0.2 + ratio * 0.7)
    }

    private func parseDate(_ key: String) -> Date? {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.date(from: key)
    }

    private func monthLabel(_ date: Date?) -> String {
        guard let d = date else { return "" }
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ja_JP")
        fmt.dateFormat = "M月"
        return fmt.string(from: d)
    }

    // MARK: - Weekly accuracy chart

    private var weeklyAccuracyChart: some View {
        let points = weeklyAccuracyPoints()

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            chartHeader(title: "週別正答率", subtitle: "直近12週")

            if points.isEmpty || points.allSatisfy({ $0.count == 0 }) {
                emptyChartPlaceholder("まだ回答データがありません")
            } else {
                Chart(points) { p in
                    LineMark(
                        x: .value("週", p.weekLabel),
                        y: .value("正答率", p.accuracy)
                    )
                    .foregroundStyle(Color.jbAccent)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("週", p.weekLabel),
                        y: .value("正答率", p.accuracy)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.jbAccent.opacity(0.25), Color.jbAccent.opacity(0.0)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("週", p.weekLabel),
                        y: .value("正答率", p.accuracy)
                    )
                    .foregroundStyle(Color.jbAccent)
                    .symbolSize(30)
                    .annotation(position: .top, spacing: 4) {
                        if p.count > 0 {
                            Text("\(Int(p.accuracy))%")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(Color.jbSubtext)
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(values: [0, 25, 50, 75, 100]) { v in
                        AxisGridLine().foregroundStyle(Color.jbBorder.opacity(0.5))
                        AxisValueLabel {
                            Text("\(v.as(Int.self) ?? 0)%")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.jbSubtext)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.system(size: 9))
                            .foregroundStyle(Color.jbSubtext)
                    }
                }
                .chartYScale(domain: 0...100)
                .frame(height: 160)
            }
        }
        .padding(Spacing.md)
        .jbCard()
    }

    private struct WeeklyAccuracyPoint: Identifiable {
        let id = UUID()
        let weekLabel: String
        let accuracy: Double
        let count: Int
    }

    private func weeklyAccuracyPoints() -> [WeeklyAccuracyPoint] {
        let levelRecords = progress.answerHistory.filter { $0.level == level }
        guard !levelRecords.isEmpty else { return [] }

        let cal = Calendar.current
        let today = Date()
        return (0..<12).reversed().map { weeksAgo in
            guard let weekStart = cal.date(byAdding: .weekOfYear, value: -weeksAgo, to: today),
                  let weekEnd = cal.date(byAdding: .day, value: 7, to: weekStart)
            else { return WeeklyAccuracyPoint(weekLabel: "", accuracy: 0, count: 0) }

            let inWeek = levelRecords.filter { $0.answeredAt >= weekStart && $0.answeredAt < weekEnd }
            let accuracy = inWeek.isEmpty ? 0.0
                : Double(inWeek.filter(\.correct).count) / Double(inWeek.count) * 100

            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "ja_JP")
            fmt.dateFormat = "M/d"
            return WeeklyAccuracyPoint(
                weekLabel: fmt.string(from: weekStart),
                accuracy: accuracy,
                count: inWeek.count
            )
        }
    }

    // MARK: - Category accuracy chart

    private var categoryAccuracyChart: some View {
        let points = categoryAccuracyPoints()

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            chartHeader(title: "カテゴリ別正答率", subtitle: "\(level.displayName) / 回答済みのみ")

            if points.isEmpty {
                emptyChartPlaceholder("まだ回答データがありません")
            } else {
                Chart(points) { p in
                    BarMark(
                        x: .value("正答率", p.accuracy),
                        y: .value("カテゴリ", p.label)
                    )
                    .foregroundStyle(barColor(p.accuracy))
                    .cornerRadius(3)
                    .annotation(position: .trailing, spacing: 4) {
                        Text("\(Int(p.accuracy))%")
                            .font(.system(size: 10, weight: .semibold).monospacedDigit())
                            .foregroundStyle(Color.jbSubtext)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: [0, 50, 100]) { v in
                        AxisGridLine().foregroundStyle(Color.jbBorder.opacity(0.4))
                        AxisValueLabel {
                            Text("\(v.as(Int.self) ?? 0)%")
                                .font(.system(size: 9))
                                .foregroundStyle(Color.jbSubtext)
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.system(size: 10))
                            .foregroundStyle(Color.jbText)
                    }
                }
                .chartXScale(domain: 0...110)
                .frame(height: CGFloat(max(points.count * 36, 120)))
            }
        }
        .padding(Spacing.md)
        .jbCard()
    }

    private struct CategoryPoint: Identifiable {
        let id = UUID()
        let label: String
        let accuracy: Double
        let count: Int
    }

    private func categoryAccuracyPoints() -> [CategoryPoint] {
        let records = progress.answerHistory.filter { $0.level == level }
        let grouped = Dictionary(grouping: records) { $0.category }
        return grouped.compactMap { (cat, recs) -> CategoryPoint? in
            guard recs.count >= 2 else { return nil }   // 2問以上の場合のみ表示
            let accuracy = Double(recs.filter(\.correct).count) / Double(recs.count) * 100
            let label = QuizCategory(rawValue: cat)?.displayName ?? cat
            return CategoryPoint(label: label, accuracy: accuracy, count: recs.count)
        }
        .sorted { $0.accuracy < $1.accuracy }
    }

    private func barColor(_ accuracy: Double) -> Color {
        if accuracy >= 80 { return Color.jbSuccess }
        if accuracy >= 60 { return Color.jbAccent }
        return Color.jbError
    }

    // MARK: - Mock exam score chart

    private var mockExamScoreChart: some View {
        let attempts = progress.mockExamAttempts
            .filter { $0.level == level }
            .sorted { $0.completedAt < $1.completedAt }
            .suffix(10)  // 直近10回

        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ja_JP")
        fmt.dateFormat = "M/d"

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            chartHeader(title: "模試スコア推移", subtitle: "直近10回")

            if attempts.isEmpty {
                emptyChartPlaceholder("まだ模試の記録がありません")
            } else {
                let passingLine = attempts.first.map { Double($0.passingScorePercent) } ?? 65.0
                let points: [(label: String, score: Double, passing: Double)] = attempts.map { a in
                    let score = Double(a.correctCount) / Double(a.questionCount) * 100
                    return (fmt.string(from: a.completedAt), score, Double(a.passingScorePercent))
                }

                Chart {
                    // 合格ライン
                    RuleMark(y: .value("合格ライン", passingLine))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                        .foregroundStyle(Color.jbWarning.opacity(0.7))
                        .annotation(position: .trailing, alignment: .bottom, spacing: 2) {
                            Text("合格ライン")
                                .font(.system(size: 9))
                                .foregroundStyle(Color.jbWarning)
                        }

                    ForEach(Array(points.enumerated()), id: \.offset) { i, p in
                        LineMark(
                            x: .value("回", p.label),
                            y: .value("スコア", p.score)
                        )
                        .foregroundStyle(Color.jbAccent)
                        .lineStyle(StrokeStyle(lineWidth: 2))

                        PointMark(
                            x: .value("回", p.label),
                            y: .value("スコア", p.score)
                        )
                        .foregroundStyle(p.score >= p.passing ? Color.jbSuccess : Color.jbError)
                        .symbolSize(45)
                        .annotation(position: .top, spacing: 4) {
                            Text("\(Int(p.score))%")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(p.score >= p.passing ? Color.jbSuccess : Color.jbError)
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(values: [0, 25, 50, 65, 75, 100]) { v in
                        AxisGridLine().foregroundStyle(Color.jbBorder.opacity(0.4))
                        AxisValueLabel {
                            Text("\(v.as(Int.self) ?? 0)%")
                                .font(.system(size: 9))
                                .foregroundStyle(Color.jbSubtext)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.system(size: 9))
                            .foregroundStyle(Color.jbSubtext)
                    }
                }
                .chartYScale(domain: 0...105)
                .frame(height: 170)
            }
        }
        .padding(Spacing.md)
        .jbCard()
    }

    // MARK: - Weak tags card

    private var weakTagsCard: some View {
        let tags = progress.weakTags(limit: 8).filter { $0.missRate > 0.3 }

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            chartHeader(title: "苦手タグ", subtitle: "ミス率 30% 超")

            if tags.isEmpty {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.jbSuccess)
                    Text("目立った苦手タグはありません 🎉")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.jbSubtext)
                }
                .padding(.vertical, Spacing.sm)
            } else {
                VStack(spacing: Spacing.xs) {
                    ForEach(tags) { tag in
                        HStack(spacing: Spacing.sm) {
                            Text(tag.tag)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.jbText)
                                .lineLimit(1)
                            Spacer()
                            Text("\(tag.missRatePercent)%")
                                .font(.system(size: 12, weight: .bold).monospacedDigit())
                                .foregroundStyle(missColor(tag.missRate))
                            ProgressView(value: tag.missRate)
                                .tint(missColor(tag.missRate))
                                .frame(width: 60)
                                .scaleEffect(x: 1, y: 1.3)
                        }
                    }
                }
            }
        }
        .padding(Spacing.md)
        .jbCard()
    }

    // MARK: - Helpers

    private func chartHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.jbText)
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundStyle(Color.jbSubtext)
        }
    }

    private func emptyChartPlaceholder(_ message: String) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "chart.bar")
                .foregroundStyle(Color.jbSubtext.opacity(0.4))
            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(Color.jbSubtext)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 80)
    }

    private func accuracyColor(_ percent: Int) -> Color {
        if percent >= 80 { return Color.jbSuccess }
        if percent >= 60 { return Color.jbAccent }
        return Color.jbError
    }

    private func missColor(_ rate: Double) -> Color {
        if rate >= 0.7 { return Color.jbError }
        if rate >= 0.5 { return Color.jbWarning }
        return Color.jbAccent
    }
}

// MARK: - QuizCategory display name extension

private extension QuizCategory {
    var displayName: String {
        switch self {
        case .javaBasics:         return "基礎"
        case .classes:            return "クラス"
        case .overloadResolution: return "オーバーロード"
        case .exceptionHandling:  return "例外処理"
        case .collections:        return "コレクション"
        case .generics:           return "ジェネリクス"
        case .lambdaStreams:       return "ラムダ/Stream"
        case .inheritance:        return "継承"
        case .moduleSystem:       return "モジュール"
        case .concurrency:        return "並行処理"
        case .io:                 return "入出力"
        case .secureCoding:       return "セキュリティ"
        case .jdbc:               return "JDBC"
        case .localization:       return "国際化"
        case .annotations:        return "アノテーション"
        case .dataTypes:          return "データ型"
        case .controlFlow:        return "制御フロー"
        case .string:             return "文字列"
        case .optionalApi:        return "Optional"
        case .dateTime:           return "日時"
        }
    }
}

#Preview {
    StatsView()
}
