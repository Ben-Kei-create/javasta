import WidgetKit
import SwiftUI

// MARK: - Shared UserDefaults (App Group)
// アプリ本体と同じ App Group を使ってデータを共有する。
// Xcode でアプリ本体・Widget 両ターゲットの Signing & Capabilities に
// App Group「group.com.fumiakiMogi777.Javasta」を追加すること。

private let appGroupID = "group.com.fumiakiMogi777.Javasta"

private extension UserDefaults {
    static var shared: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }
}

// MARK: - Widget data model

private struct WidgetData {
    let streakDays: Int
    let todayAnswered: Int
    let dailyGoal: Int
    let accuracyPercent: Int   // 全体

    static func load() -> WidgetData {
        let d = UserDefaults.shared
        return WidgetData(
            streakDays:      d.integer(forKey: "progress.streakDays"),
            todayAnswered:   d.integer(forKey: "progress.todayAnswered"),
            dailyGoal:       max(1, d.integer(forKey: "progress.dailyGoal")),
            accuracyPercent: {
                let total   = d.integer(forKey: "progress.totalAnswered")
                let correct = d.integer(forKey: "progress.totalCorrect")
                guard total > 0 else { return 0 }
                return Int(Double(correct) / Double(total) * 100)
            }()
        )
    }

    var goalProgress: Double {
        min(Double(todayAnswered) / Double(dailyGoal), 1.0)
    }

    var reachedGoal: Bool { todayAnswered >= dailyGoal }
}

// MARK: - Timeline entry

struct JavastaEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

// MARK: - Timeline provider

struct JavastaWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> JavastaEntry {
        JavastaEntry(date: .now, data: WidgetData(
            streakDays: 7, todayAnswered: 6, dailyGoal: 10, accuracyPercent: 72
        ))
    }

    func getSnapshot(in context: Context, completion: @escaping (JavastaEntry) -> Void) {
        completion(JavastaEntry(date: .now, data: WidgetData.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<JavastaEntry>) -> Void) {
        let entry = JavastaEntry(date: .now, data: WidgetData.load())
        // 30分ごとにリフレッシュ
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

// MARK: - Small widget (systemSmall)

struct JavastaSmallWidgetView: View {
    let entry: JavastaEntry

    var body: some View {
        ZStack {
            Color.black
            VStack(spacing: 6) {
                // 炎アイコン + 連続日数
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.orange)
                    Text("\(entry.data.streakDays)日")
                        .font(.system(size: 18, weight: .bold).monospacedDigit())
                        .foregroundStyle(.white)
                }

                // 今日の進捗リング
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 5)
                    Circle()
                        .trim(from: 0, to: entry.data.goalProgress)
                        .stroke(
                            entry.data.reachedGoal ? Color.green : Color(red: 0.2, green: 0.6, blue: 1.0),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 1) {
                        Text("\(entry.data.todayAnswered)")
                            .font(.system(size: 20, weight: .bold).monospacedDigit())
                            .foregroundStyle(.white)
                        Text("/ \(entry.data.dailyGoal)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .frame(width: 70, height: 70)

                Text("今日の目標")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(12)
        }
    }
}

// MARK: - Medium widget (systemMedium)

struct JavastaMediumWidgetView: View {
    let entry: JavastaEntry

    private var accuracyColor: Color {
        let p = entry.data.accuracyPercent
        if p >= 70 { return Color.green }
        if p >= 40 { return Color.orange }
        return Color.red
    }

    var body: some View {
        ZStack {
            Color.black
            HStack(spacing: 0) {
                // 左: 今日の進捗
                VStack(alignment: .leading, spacing: 8) {
                    Label("Javasta", systemImage: "bolt.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color(red: 0.2, green: 0.6, blue: 1.0))

                    Text("今日 \(entry.data.todayAnswered) / \(entry.data.dailyGoal) 問")
                        .font(.system(size: 13, weight: .bold).monospacedDigit())
                        .foregroundStyle(.white)

                    ProgressView(value: entry.data.goalProgress)
                        .tint(entry.data.reachedGoal ? .green : Color(red: 0.2, green: 0.6, blue: 1.0))
                        .scaleEffect(x: 1, y: 1.6)

                    Text(entry.data.reachedGoal ? "目標達成 🎉" : "もう少し！")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()
                    .background(Color.white.opacity(0.1))

                // 右: 連続 + 正答率
                VStack(spacing: 12) {
                    VStack(spacing: 2) {
                        HStack(spacing: 3) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.orange)
                            Text("\(entry.data.streakDays)")
                                .font(.system(size: 22, weight: .bold).monospacedDigit())
                                .foregroundStyle(.white)
                        }
                        Text("連続日数")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    VStack(spacing: 2) {
                        Text("\(entry.data.accuracyPercent)%")
                            .font(.system(size: 22, weight: .bold).monospacedDigit())
                            .foregroundStyle(accuracyColor)
                        Text("正答率")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .frame(width: 90)
                .padding(.vertical, 14)
            }
        }
    }
}

// MARK: - Widget definitions

struct JavastaSmallWidget: Widget {
    let kind = "JavastaSmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JavastaWidgetProvider()) { entry in
            JavastaSmallWidgetView(entry: entry)
                .containerBackground(.black, for: .widget)
        }
        .configurationDisplayName("Javasta — 今日の進捗")
        .description("連続日数と今日の解答状況を表示します。")
        .supportedFamilies([.systemSmall])
    }
}

struct JavastaMediumWidget: Widget {
    let kind = "JavastaMediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JavastaWidgetProvider()) { entry in
            JavastaMediumWidgetView(entry: entry)
                .containerBackground(.black, for: .widget)
        }
        .configurationDisplayName("Javasta — 学習ダッシュボード")
        .description("今日の目標・連続日数・正答率をまとめて確認できます。")
        .supportedFamilies([.systemMedium])
    }
}
