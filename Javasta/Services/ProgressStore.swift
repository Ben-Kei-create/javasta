import Foundation
import Observation

/// 学習進捗の永続化ストア（UserDefaultsベース）。
@Observable
final class ProgressStore {
    static let shared = ProgressStore()

    // 永続化キー
    private enum Key {
        static let totalAnswered     = "progress.totalAnswered"
        static let totalCorrect      = "progress.totalCorrect"
        static let lastStudyDateKey  = "progress.lastStudyDate"   // yyyy-MM-dd
        static let streakDays        = "progress.streakDays"
        static let todayAnswered     = "progress.todayAnswered"
        static let todayDateKey      = "progress.todayDateKey"     // yyyy-MM-dd
        static let dailyGoal         = "progress.dailyGoal"
        static let completedLessons  = "progress.completedLessons" // [String]
        static let dailyHistory      = "progress.dailyHistory"     // [yyyy-MM-dd: Int]
    }

    /// 保持する履歴日数（ヒートマップ用）
    static let historyWindowDays = 84   // 12週 × 7日

    private let defaults: UserDefaults

    var totalAnswered: Int
    var totalCorrect: Int
    var streakDays: Int
    var todayAnswered: Int
    var dailyGoal: Int
    var completedLessons: Set<String>
    /// "yyyy-MM-dd" -> その日の回答数
    var dailyHistory: [String: Int]

    var accuracyPercent: Int {
        guard totalAnswered > 0 else { return 0 }
        return Int((Double(totalCorrect) / Double(totalAnswered) * 100).rounded())
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.totalAnswered = defaults.integer(forKey: Key.totalAnswered)
        self.totalCorrect  = defaults.integer(forKey: Key.totalCorrect)
        self.streakDays    = defaults.integer(forKey: Key.streakDays)
        let goal = defaults.integer(forKey: Key.dailyGoal)
        self.dailyGoal     = goal == 0 ? 5 : goal
        self.completedLessons = Set(defaults.stringArray(forKey: Key.completedLessons) ?? [])
        let storedTodayKey = defaults.string(forKey: Key.todayDateKey)
        if storedTodayKey == Self.todayKey() {
            self.todayAnswered = defaults.integer(forKey: Key.todayAnswered)
        } else {
            self.todayAnswered = 0
        }
        let rawHistory = defaults.dictionary(forKey: Key.dailyHistory) as? [String: Int] ?? [:]
        self.dailyHistory = Self.prune(rawHistory, windowDays: Self.historyWindowDays)
    }

    // MARK: API

    func recordAnswer(correct: Bool) {
        rolloverDayIfNeeded()
        bumpStreakIfFirstOfDay()

        totalAnswered += 1
        if correct { totalCorrect += 1 }
        todayAnswered += 1

        let key = Self.todayKey()
        dailyHistory[key, default: 0] += 1
        dailyHistory = Self.prune(dailyHistory, windowDays: Self.historyWindowDays)

        defaults.set(totalAnswered, forKey: Key.totalAnswered)
        defaults.set(totalCorrect,  forKey: Key.totalCorrect)
        defaults.set(todayAnswered, forKey: Key.todayAnswered)
        defaults.set(key,            forKey: Key.todayDateKey)
        defaults.set(dailyHistory,   forKey: Key.dailyHistory)
    }

    /// 直近 `days` 日の回答数を新しい順に返す (末尾が今日)
    func recentDailyCounts(days: Int) -> [(dateKey: String, count: Int)] {
        Self.lastDateKeys(days: days).map { ($0, dailyHistory[$0] ?? 0) }
    }

    func markLessonCompleted(_ lessonId: String) {
        completedLessons.insert(lessonId)
        defaults.set(Array(completedLessons), forKey: Key.completedLessons)
    }

    func setDailyGoal(_ value: Int) {
        dailyGoal = max(1, value)
        defaults.set(dailyGoal, forKey: Key.dailyGoal)
    }

    func resetAll() {
        totalAnswered = 0
        totalCorrect = 0
        streakDays = 0
        todayAnswered = 0
        completedLessons = []
        dailyHistory = [:]
        defaults.removeObject(forKey: Key.totalAnswered)
        defaults.removeObject(forKey: Key.totalCorrect)
        defaults.removeObject(forKey: Key.streakDays)
        defaults.removeObject(forKey: Key.todayAnswered)
        defaults.removeObject(forKey: Key.todayDateKey)
        defaults.removeObject(forKey: Key.lastStudyDateKey)
        defaults.removeObject(forKey: Key.completedLessons)
        defaults.removeObject(forKey: Key.dailyHistory)
    }

    // MARK: 内部

    /// 日付が変わっていたら todayAnswered をリセット
    private func rolloverDayIfNeeded() {
        let storedKey = defaults.string(forKey: Key.todayDateKey)
        if storedKey != Self.todayKey() {
            todayAnswered = 0
        }
    }

    /// その日初めての回答ならストリークを更新
    private func bumpStreakIfFirstOfDay() {
        let storedToday = defaults.string(forKey: Key.todayDateKey)
        guard storedToday != Self.todayKey() else { return }

        let lastStudy = defaults.string(forKey: Key.lastStudyDateKey)
        if lastStudy == Self.yesterdayKey() {
            streakDays += 1
        } else if lastStudy == nil {
            streakDays = 1
        } else {
            streakDays = 1
        }
        defaults.set(streakDays, forKey: Key.streakDays)
        defaults.set(Self.todayKey(), forKey: Key.lastStudyDateKey)
    }

    // MARK: 日付ヘルパー

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.calendar = Calendar(identifier: .gregorian)
        f.timeZone = TimeZone.current
        return f
    }()

    private static func todayKey() -> String {
        dateFormatter.string(from: Date())
    }

    private static func yesterdayKey() -> String {
        let cal = Calendar.current
        let y = cal.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return dateFormatter.string(from: y)
    }

    /// 今日を末尾とする過去 `days` 日分のキー（古い順）
    static func lastDateKeys(days: Int) -> [String] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<days).reversed().compactMap { offset in
            cal.date(byAdding: .day, value: -offset, to: today).map { dateFormatter.string(from: $0) }
        }
    }

    /// 古いエントリを削り、履歴を windowDays 分までに切り詰める
    private static func prune(_ history: [String: Int], windowDays: Int) -> [String: Int] {
        let keep = Set(lastDateKeys(days: windowDays))
        return history.filter { keep.contains($0.key) }
    }
}
