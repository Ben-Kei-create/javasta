import SwiftUI

/// GitHub contribution graph 風の学習ヒートマップ。
/// 横方向に「古い週 → 今週」、縦方向に曜日（月〜日）で並ぶコンパクト版。
struct ActivityHeatmapView: View {
    let counts: [(dateKey: String, count: Int)]
    var weeks: Int = 12
    var futureWeeks: Int = 4

    @AppStorage("examDateTimestamp") private var examDateTimestamp: Double = 0
    @State private var pulse: Bool = false
    @State private var showExamAlert: Bool = false

    private var examDate: Date? {
        examDateTimestamp > 0 ? Date(timeIntervalSince1970: examDateTimestamp) : nil
    }

    private static func todayKey() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.calendar = Calendar(identifier: .gregorian)
        fmt.timeZone = TimeZone.current
        return fmt.string(from: Date())
    }

    private var examDateKey: String? {
        guard let examDate else { return nil }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.calendar = Calendar(identifier: .gregorian)
        fmt.timeZone = TimeZone.current
        return fmt.string(from: examDate)
    }

    private var daysUntilExam: Int? {
        guard let examDate else { return nil }
        let cal = Calendar(identifier: .gregorian)
        let start = cal.startOfDay(for: Date())
        let target = cal.startOfDay(for: examDate)
        return cal.dateComponents([.day], from: start, to: target).day
    }

    private static let maxIntensityCount = 100

    // ドット & 余白
    private let cellSize: CGFloat = 8
    private let cellSpacing: CGFloat = 2
    // 週（列）の並び: 古い週 → 今週
    private var columns: [[Day]] { makeColumns() }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            header
            HStack(alignment: .top, spacing: cellSpacing) {
                dayLabels
                grid
            }
            legend
        }
        .padding(Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbBorder, lineWidth: 1)
                )
        )
        .padding(.horizontal, Spacing.md)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
        .alert("受験日まで", isPresented: $showExamAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            if let days = daysUntilExam {
                if days > 0 {
                    Text("あと \(days) 日")
                } else if days == 0 {
                    Text("本日が受験日です")
                } else {
                    Text("受験日を過ぎています")
                }
            } else {
                Text("受験日が設定されていません")
            }
        }
    }

    // MARK: Subviews

    private var header: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "square.grid.3x3.fill")
                .font(.system(size: 11))
                .foregroundStyle(Color.jbAccent)
            Text("学習マップ")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.jbText)
                .tracking(0.3)
            Spacer()
            Text("\(weeks)週")
                .font(.system(size: 11))
                .foregroundStyle(Color.jbSubtext)
        }
    }

    private var dayLabels: some View {
        VStack(alignment: .trailing, spacing: cellSpacing) {
            ForEach(0..<7, id: \.self) { i in
                Text(dayLabel(for: i))
                    .font(.system(size: 9))
                    .foregroundStyle(Color.jbSubtext.opacity(i % 2 == 0 ? 0.9 : 0))
                    .frame(width: 14, height: cellSize)
            }
        }
    }

    private var grid: some View {
        HStack(alignment: .top, spacing: cellSpacing) {
            ForEach(columns.indices, id: \.self) { col in
                VStack(spacing: cellSpacing) {
                    ForEach(0..<7, id: \.self) { row in
                        cell(for: columns[col][row])
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func cell(for day: Day) -> some View {
        let isExam = (day.dateKey == examDateKey) && !day.dateKey.isEmpty
        let isToday = day.dateKey == Self.todayKey()
        if isExam && !isToday {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.jbError)
                .frame(width: cellSize, height: cellSize)
                .opacity(pulse ? 1.0 : 0.35)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.jbError.opacity(0.8), lineWidth: 0.5)
                )
                .onTapGesture { showExamAlert = true }
                .accessibilityLabel(Text("受験日 \(day.dateKey)"))
        } else {
            RoundedRectangle(cornerRadius: 2)
                .fill(cellColor(day))
                .frame(width: cellSize, height: cellSize)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(isExam && isToday ? Color.jbError.opacity(0.9) : Color.jbBorder.opacity(day.isValid ? 0 : 0.4), lineWidth: isExam && isToday ? 1 : 0.5)
                )
                .opacity(day.isValid ? 1 : 0)
                .onTapGesture { if isExam { showExamAlert = true } }
                .accessibilityLabel(Text("\(day.dateKey) \(day.count)問"))
                .accessibilityHidden(!day.isValid)
        }
    }

    private var legend: some View {
        HStack(spacing: cellSpacing) {
            Text("少")
                .font(.system(size: 9))
                .foregroundStyle(Color.jbSubtext)
            ForEach(0..<5, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(colorForLevel(i))
                    .frame(width: cellSize, height: cellSize)
            }
            Text("\(Self.maxIntensityCount)問+")
                .font(.system(size: 9))
                .foregroundStyle(Color.jbSubtext)

            Spacer()

            if let streak = currentStreak() {
                Label("\(streak)日連続", systemImage: "flame.fill")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.jbAccent)
            }
        }
    }

    // MARK: Data helpers

    private struct Day {
        let dateKey: String
        let count: Int
        let isValid: Bool
    }

    /// 列 = 週。各列は [月, 火, ..., 日] の7要素。過去 + 未来を日付ベースで生成。
    private func makeColumns() -> [[Day]] {
        let cal = Calendar(identifier: .gregorian)
        var weekStartCal = cal
        weekStartCal.firstWeekday = 2

        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.calendar = cal
        fmt.timeZone = TimeZone.current

        let countsDict: [String: Int] = Dictionary(uniqueKeysWithValues: counts.map { ($0.dateKey, $0.count) })

        let today = cal.startOfDay(for: Date())
        let pastWeeks = max(weeks - futureWeeks, 1)
        // 開始日: 今日が属する週の月曜から pastWeeks-1 週前
        let weekday = cal.component(.weekday, from: today)
        let mondayOffset = (weekday + 5) % 7
        guard let thisMonday = cal.date(byAdding: .day, value: -mondayOffset, to: today),
              let startDate = cal.date(byAdding: .day, value: -7 * (pastWeeks - 1), to: thisMonday)
        else {
            return Array(repeating: Array(repeating: Day(dateKey: "", count: 0, isValid: false), count: 7), count: weeks)
        }

        var cols: [[Day]] = []
        for w in 0..<weeks {
            var week: [Day] = Array(repeating: Day(dateKey: "", count: 0, isValid: false), count: 7)
            for d in 0..<7 {
                if let date = cal.date(byAdding: .day, value: w * 7 + d, to: startDate) {
                    let key = fmt.string(from: date)
                    let count = countsDict[key] ?? 0
                    week[d] = Day(dateKey: key, count: count, isValid: true)
                }
            }
            cols.append(week)
        }
        return cols
    }

    private func cellColor(_ day: Day) -> Color {
        guard day.isValid else { return Color.jbBackground.opacity(0.4) }
        return colorForLevel(level(for: day.count))
    }

    private func level(for count: Int) -> Int {
        switch count {
        case 0:
            return 0
        case 1...25:
            return 1
        case 26...50:
            return 2
        case 51..<Self.maxIntensityCount:
            return 3
        default:
            return 4
        }
    }

    private func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 0: return Color.jbBorder.opacity(0.45)
        case 1: return Color.jbAccent.opacity(0.25)
        case 2: return Color.jbAccent.opacity(0.5)
        case 3: return Color.jbAccent.opacity(0.75)
        default: return Color.jbAccent
        }
    }

    private func dayLabel(for i: Int) -> String {
        // 月から開始
        ["月", "火", "水", "木", "金", "土", "日"][i]
    }

    private func currentStreak() -> Int? {
        // 末尾（今日）から遡って count > 0 が続く日数
        var streak = 0
        for item in counts.reversed() {
            if item.count > 0 { streak += 1 } else { break }
        }
        return streak > 0 ? streak : nil
    }
}
