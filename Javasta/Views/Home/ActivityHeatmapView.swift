import SwiftUI

/// GitHub contribution graph 風の学習ヒートマップ。
/// 横方向に「古い週 → 今週」、縦方向に曜日（月〜日）で並ぶコンパクト版。
struct ActivityHeatmapView: View {
    let counts: [(dateKey: String, count: Int)]
    var weeks: Int = 12

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
            Text("直近\(weeks)週")
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

    private func cell(for day: Day) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(cellColor(day))
            .frame(width: cellSize, height: cellSize)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.jbBorder.opacity(day.isValid ? 0 : 0.4), lineWidth: 0.5)
            )
            .opacity(day.isValid ? 1 : 0)
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
            Text("多")
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

    /// 列 = 週。各列は [月, 火, ..., 日] の7要素。先頭の空白分をパディング。
    private func makeColumns() -> [[Day]] {
        let cal = Calendar(identifier: .gregorian)
        // 月曜起点（日本の慣習）
        var weekStartCal = cal
        weekStartCal.firstWeekday = 2

        let total = weeks * 7
        let trimmed = Array(counts.suffix(total))
        guard !trimmed.isEmpty else {
            return Array(repeating: Array(repeating: Day(dateKey: "", count: 0, isValid: false), count: 7), count: weeks)
        }

        // 1列=1週で、日付の weekday (月=0 ... 日=6) の位置に入れる
        var cols: [[Day]] = []
        var currentWeek: [Day] = Array(repeating: Day(dateKey: "", count: 0, isValid: false), count: 7)
        var lastWeekOfYear: Int? = nil

        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.calendar = cal
        fmt.timeZone = TimeZone.current

        for item in trimmed {
            guard let date = fmt.date(from: item.dateKey) else { continue }
            let weekday = cal.component(.weekday, from: date) // 1=日 ... 7=土
            // 月曜=0 のインデックスに変換
            let idx = (weekday + 5) % 7
            let weekOfYear = weekStartCal.component(.weekOfYear, from: date)

            if let last = lastWeekOfYear, last != weekOfYear {
                cols.append(currentWeek)
                currentWeek = Array(repeating: Day(dateKey: "", count: 0, isValid: false), count: 7)
            }
            currentWeek[idx] = Day(dateKey: item.dateKey, count: item.count, isValid: true)
            lastWeekOfYear = weekOfYear
        }
        cols.append(currentWeek)

        // 末尾が最新週。先頭側に足りない分の空週を付加
        while cols.count < weeks {
            cols.insert(Array(repeating: Day(dateKey: "", count: 0, isValid: false), count: 7), at: 0)
        }
        return Array(cols.suffix(weeks))
    }

    private func cellColor(_ day: Day) -> Color {
        guard day.isValid else { return Color.jbBackground.opacity(0.4) }
        return colorForLevel(level(for: day.count))
    }

    private func level(for count: Int) -> Int {
        switch count {
        case 0:      return 0
        case 1...2:  return 1
        case 3...5:  return 2
        case 6...9:  return 3
        default:     return 4
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
