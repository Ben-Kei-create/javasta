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
        static let reviewQueueQuizIds = "progress.reviewQueueQuizIds" // [String]
        static let answerHistory     = "progress.answerHistory"    // [QuizAnswerRecord]
        static let bookmarkedQuizzes = "progress.bookmarkedQuizzes"
        static let mockExamAttempts  = "progress.mockExamAttempts"  // [MockExamAttempt]
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
    /// 復習対象の問題ID（誤答で追加、正答で取り除く）
    var reviewQueueQuizIds: [String]
    var answerHistory: [QuizAnswerRecord]
    var bookmarkedQuizIds: Set<String>
    var mockExamAttempts: [MockExamAttempt]

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
        self.mockExamAttempts = Self.pruneMockExamAttempts(Self.loadMockExamAttempts(from: defaults))
        let storedTodayKey = defaults.string(forKey: Key.todayDateKey)
        if storedTodayKey == Self.todayKey() {
            self.todayAnswered = defaults.integer(forKey: Key.todayAnswered)
        } else {
            self.todayAnswered = 0
        }
        let rawHistory = defaults.dictionary(forKey: Key.dailyHistory) as? [String: Int] ?? [:]
        self.dailyHistory = Self.prune(rawHistory, windowDays: Self.historyWindowDays)
        let storedReviewQueue = defaults.stringArray(forKey: Key.reviewQueueQuizIds) ?? []
        self.reviewQueueQuizIds = Self.deduplicated(storedReviewQueue)
        if storedReviewQueue != reviewQueueQuizIds {
            defaults.set(reviewQueueQuizIds, forKey: Key.reviewQueueQuizIds)
        }
    }

    // MARK: API

    func recordAnswer(quizId: String, correct: Bool) {
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

        if !quizId.isEmpty {
            reviewQueueQuizIds = Self.deduplicated(reviewQueueQuizIds)
            if correct {
                reviewQueueQuizIds.removeAll { $0 == quizId }
            } else {
                reviewQueueQuizIds.removeAll { $0 == quizId }
                reviewQueueQuizIds.append(quizId)
            }
            defaults.set(reviewQueueQuizIds, forKey: Key.reviewQueueQuizIds)
        }
    }

    /// 既存呼び出し向け互換API。問題IDのない場面では復習キューは更新しない。
    func recordAnswer(correct: Bool) {
        recordAnswer(quizId: "", correct: correct)
    }

    /// 直近 `days` 日の回答数を新しい順に返す (末尾が今日)
    func recentDailyCounts(days: Int) -> [(dateKey: String, count: Int)] {
        Self.lastDateKeys(days: days).map { ($0, dailyHistory[$0] ?? 0) }
    }

    func recordAnswer(quiz: Quiz, choice: Quiz.Choice, elapsedSeconds: Int? = nil) {
        recordAnswer(quizId: quiz.id, correct: choice.correct)
        let record = QuizAnswerRecord(
            quizId: quiz.id,
            level: quiz.level,
            category: quiz.canonicalCategoryRawValue,
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

    func recordMockExamAttempt(_ attempt: MockExamAttempt, quizzes: [Quiz]) {
        rolloverDayIfNeeded()
        bumpStreakIfFirstOfDay()

        totalAnswered += attempt.questionCount
        totalCorrect += attempt.correctCount
        todayAnswered += attempt.questionCount

        let key = Self.todayKey()
        dailyHistory[key, default: 0] += attempt.questionCount
        dailyHistory = Self.prune(dailyHistory, windowDays: Self.historyWindowDays)

        let quizById = Dictionary(uniqueKeysWithValues: quizzes.map { ($0.id, $0) })
        for answer in attempt.answers {
            guard let quiz = quizById[answer.quizId] else { continue }
            answerHistory.append(
                QuizAnswerRecord(
                    quizId: quiz.id,
                    level: quiz.level,
                    category: quiz.canonicalCategoryRawValue,
                    tags: quiz.tags,
                    selectedChoiceId: answer.selectedChoiceId ?? "",
                    correct: answer.correct,
                    answeredAt: attempt.completedAt,
                    elapsedSeconds: answer.elapsedSeconds
                )
            )

            reviewQueueQuizIds.removeAll { $0 == quiz.id }
            if !answer.correct && !quiz.isMockExamOnly {
                reviewQueueQuizIds.append(quiz.id)
            }
        }

        if answerHistory.count > 2_000 {
            answerHistory = Array(answerHistory.suffix(2_000))
        }
        reviewQueueQuizIds = Self.deduplicated(reviewQueueQuizIds)
        mockExamAttempts = Self.pruneMockExamAttempts(mockExamAttempts + [attempt])

        defaults.set(totalAnswered, forKey: Key.totalAnswered)
        defaults.set(totalCorrect, forKey: Key.totalCorrect)
        defaults.set(todayAnswered, forKey: Key.todayAnswered)
        defaults.set(key, forKey: Key.todayDateKey)
        defaults.set(dailyHistory, forKey: Key.dailyHistory)
        defaults.set(reviewQueueQuizIds, forKey: Key.reviewQueueQuizIds)
        saveAnswerHistory()
        saveMockExamAttempts()
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

    func answerAttemptCount(level: JavaLevel) -> Int {
        answerHistory.filter { $0.level == level }.count
    }

    func levelAccuracyPercent(_ level: JavaLevel) -> Int {
        let records = answerHistory.filter { $0.level == level }
        guard !records.isEmpty else { return 0 }
        let correct = records.filter(\.correct).count
        return Int((Double(correct) / Double(records.count) * 100).rounded())
    }

    func mockExamAttempts(
        version: JavaExamVersion,
        level: JavaLevel,
        variant: MockExamVariant
    ) -> [MockExamAttempt] {
        mockExamAttempts
            .filter { $0.version == version && $0.level == level && $0.variant == variant }
            .sorted { $0.completedAt < $1.completedAt }
    }

    func resetAll() {
        totalAnswered = 0
        totalCorrect = 0
        streakDays = 0
        todayAnswered = 0
        completedLessons = []
        dailyHistory = [:]
        reviewQueueQuizIds = []
        answerHistory = []
        bookmarkedQuizIds = []
        mockExamAttempts = []
        defaults.removeObject(forKey: Key.totalAnswered)
        defaults.removeObject(forKey: Key.totalCorrect)
        defaults.removeObject(forKey: Key.streakDays)
        defaults.removeObject(forKey: Key.todayAnswered)
        defaults.removeObject(forKey: Key.todayDateKey)
        defaults.removeObject(forKey: Key.lastStudyDateKey)
        defaults.removeObject(forKey: Key.completedLessons)
        defaults.removeObject(forKey: Key.dailyHistory)
        defaults.removeObject(forKey: Key.reviewQueueQuizIds)
        defaults.removeObject(forKey: Key.answerHistory)
        defaults.removeObject(forKey: Key.bookmarkedQuizzes)
        defaults.removeObject(forKey: Key.mockExamAttempts)
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

    private func saveMockExamAttempts() {
        guard let data = try? JSONEncoder().encode(mockExamAttempts) else { return }
        defaults.set(data, forKey: Key.mockExamAttempts)
    }

    // MARK: 日付ヘルパー

    private static func loadAnswerHistory(from defaults: UserDefaults) -> [QuizAnswerRecord] {
        guard let data = defaults.data(forKey: Key.answerHistory),
              let records = try? JSONDecoder().decode([QuizAnswerRecord].self, from: data)
        else { return [] }
        return records
    }

    private static func loadMockExamAttempts(from defaults: UserDefaults) -> [MockExamAttempt] {
        guard let data = defaults.data(forKey: Key.mockExamAttempts),
              let attempts = try? JSONDecoder().decode([MockExamAttempt].self, from: data)
        else { return [] }
        return attempts
    }

    private static func deduplicated(_ ids: [String]) -> [String] {
        var seen = Set<String>()
        return ids.filter { seen.insert($0).inserted }
    }

    private static func pruneMockExamAttempts(_ attempts: [MockExamAttempt]) -> [MockExamAttempt] {
        let grouped = Dictionary(grouping: attempts) { attempt in
            "\(attempt.version.rawValue)-\(attempt.level.rawValue)-\(attempt.variant.rawValue)"
        }

        return grouped.values
            .flatMap { group in
                group.sorted { $0.completedAt < $1.completedAt }.suffix(10)
            }
            .sorted { $0.completedAt < $1.completedAt }
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
