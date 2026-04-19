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
        static let answerHistory     = "progress.answerHistory"    // [QuizAnswerRecord]
        static let bookmarkedQuizzes = "progress.bookmarkedQuizzes"
    }

    private let defaults: UserDefaults

    var totalAnswered: Int
    var totalCorrect: Int
    var streakDays: Int
    var todayAnswered: Int
    var dailyGoal: Int
    var completedLessons: Set<String>
    var answerHistory: [QuizAnswerRecord]
    var bookmarkedQuizIds: Set<String>

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
        self.answerHistory = Self.loadAnswerHistory(from: defaults)
        self.bookmarkedQuizIds = Set(defaults.stringArray(forKey: Key.bookmarkedQuizzes) ?? [])
        let storedTodayKey = defaults.string(forKey: Key.todayDateKey)
        if storedTodayKey == Self.todayKey() {
            self.todayAnswered = defaults.integer(forKey: Key.todayAnswered)
        } else {
            self.todayAnswered = 0
        }
    }

    // MARK: API

    func recordAnswer(correct: Bool) {
        rolloverDayIfNeeded()
        bumpStreakIfFirstOfDay()

        totalAnswered += 1
        if correct { totalCorrect += 1 }
        todayAnswered += 1

        defaults.set(totalAnswered, forKey: Key.totalAnswered)
        defaults.set(totalCorrect,  forKey: Key.totalCorrect)
        defaults.set(todayAnswered, forKey: Key.todayAnswered)
        defaults.set(Self.todayKey(), forKey: Key.todayDateKey)
    }

    func recordAnswer(quiz: Quiz, choice: Quiz.Choice, elapsedSeconds: Int? = nil) {
        recordAnswer(correct: choice.correct)
        let record = QuizAnswerRecord(
            quizId: quiz.id,
            level: quiz.level,
            category: quiz.category,
            tags: quiz.tags,
            selectedChoiceId: choice.id,
            correct: choice.correct,
            elapsedSeconds: elapsedSeconds
        )
        answerHistory.append(record)
        if answerHistory.count > 2_000 {
            answerHistory = Array(answerHistory.suffix(2_000))
        }
        saveAnswerHistory()
    }

    func markLessonCompleted(_ lessonId: String) {
        completedLessons.insert(lessonId)
        defaults.set(Array(completedLessons), forKey: Key.completedLessons)
    }

    func toggleBookmark(quizId: String) {
        if bookmarkedQuizIds.contains(quizId) {
            bookmarkedQuizIds.remove(quizId)
        } else {
            bookmarkedQuizIds.insert(quizId)
        }
        defaults.set(Array(bookmarkedQuizIds), forKey: Key.bookmarkedQuizzes)
    }

    func setDailyGoal(_ value: Int) {
        dailyGoal = max(1, value)
        defaults.set(dailyGoal, forKey: Key.dailyGoal)
    }

    func stats(for quizId: String) -> QuizAttemptStats {
        let records = answerHistory.filter { $0.quizId == quizId }
        return QuizAttemptStats(
            attempts: records.count,
            correct: records.filter(\.correct).count,
            latest: records.max { $0.answeredAt < $1.answeredAt }
        )
    }

    func weakTags(limit: Int = 5) -> [WeakTagSummary] {
        var attempts: [String: Int] = [:]
        var misses: [String: Int] = [:]

        for record in answerHistory {
            for tag in record.tags {
                attempts[tag, default: 0] += 1
                if !record.correct {
                    misses[tag, default: 0] += 1
                }
            }
        }

        return attempts.keys
            .map { tag in
                WeakTagSummary(
                    tag: tag,
                    attempts: attempts[tag, default: 0],
                    misses: misses[tag, default: 0]
                )
            }
            .filter { $0.misses > 0 }
            .sorted {
                if $0.missRate == $1.missRate {
                    return $0.attempts > $1.attempts
                }
                return $0.missRate > $1.missRate
            }
            .prefix(limit)
            .map { $0 }
    }

    func answeredCount(level: JavaLevel? = nil) -> Int {
        let ids = answerHistory
            .filter { level == nil || $0.level == level }
            .map(\.quizId)
        return Set(ids).count
    }

    func resetAll() {
        totalAnswered = 0
        totalCorrect = 0
        streakDays = 0
        todayAnswered = 0
        completedLessons = []
        answerHistory = []
        bookmarkedQuizIds = []
        defaults.removeObject(forKey: Key.totalAnswered)
        defaults.removeObject(forKey: Key.totalCorrect)
        defaults.removeObject(forKey: Key.streakDays)
        defaults.removeObject(forKey: Key.todayAnswered)
        defaults.removeObject(forKey: Key.todayDateKey)
        defaults.removeObject(forKey: Key.lastStudyDateKey)
        defaults.removeObject(forKey: Key.completedLessons)
        defaults.removeObject(forKey: Key.answerHistory)
        defaults.removeObject(forKey: Key.bookmarkedQuizzes)
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

    private func saveAnswerHistory() {
        guard let data = try? JSONEncoder().encode(answerHistory) else { return }
        defaults.set(data, forKey: Key.answerHistory)
    }

    // MARK: 日付ヘルパー

    private static func loadAnswerHistory(from defaults: UserDefaults) -> [QuizAnswerRecord] {
        guard let data = defaults.data(forKey: Key.answerHistory),
              let records = try? JSONDecoder().decode([QuizAnswerRecord].self, from: data)
        else { return [] }
        return records
    }

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
}
