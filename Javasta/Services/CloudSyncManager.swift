import Foundation

/// NSUbiquitousKeyValueStore を使って ProgressStore のデータを
/// デバイス間で同期するマネージャー。
/// - push(): ProgressStore → KVS へ書き込む
/// - pullAndMerge(): KVS → ProgressStore へマージ（union / max 戦略）
/// - startObserving(): 外部デバイスからの変更通知を受け取る
@MainActor
final class CloudSyncManager {
    static let shared = CloudSyncManager()
    private let kvs = NSUbiquitousKeyValueStore.default
    private let store = ProgressStore.shared

    // debounce 用タイマー
    private var pushWorkItem: DispatchWorkItem?

    private init() {}

    func syncOnLaunch() async {
        kvs.synchronize()
        pullAndMerge()
        startObserving()
    }

    /// ProgressStore の内容を KVS へ書き込む（debounce 2秒）
    func schedulePush() {
        pushWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            self?.push()
        }
        pushWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: item)
    }

    func push() {
        kvs.set(store.totalAnswered,                    forKey: "progress.totalAnswered")
        kvs.set(store.totalCorrect,                     forKey: "progress.totalCorrect")
        kvs.set(store.streakDays,                       forKey: "progress.streakDays")
        kvs.set(store.dailyGoal,                        forKey: "progress.dailyGoal")
        kvs.set(Array(store.completedLessons),          forKey: "progress.completedLessons")
        kvs.set(Array(store.bookmarkedQuizIds),         forKey: "progress.bookmarkedQuizzes")
        kvs.set(store.reviewQueueQuizIds,               forKey: "progress.reviewQueueQuizIds")
        kvs.set(store.dailyHistory,                     forKey: "progress.dailyHistory")

        // answerHistory: KVS 用は最新 500 件に制限
        let recentAnswers = Array(store.answerHistory.suffix(500))
        if let data = try? JSONEncoder().encode(recentAnswers) {
            kvs.set(data, forKey: "progress.answerHistory")
        }

        if let data = try? JSONEncoder().encode(store.mockExamAttempts) {
            kvs.set(data, forKey: "progress.mockExamAttempts")
        }

        kvs.synchronize()
    }

    private func pullAndMerge() {
        // totalAnswered / totalCorrect / streakDays: max
        let remoteAnswered = kvs.longLong(forKey: "progress.totalAnswered")
        let remoteCorrect  = kvs.longLong(forKey: "progress.totalCorrect")
        let remoteStreak   = kvs.longLong(forKey: "progress.streakDays")

        if Int(remoteAnswered) > store.totalAnswered {
            store.totalAnswered = Int(remoteAnswered)
        }
        if Int(remoteCorrect) > store.totalCorrect {
            store.totalCorrect = Int(remoteCorrect)
        }
        if Int(remoteStreak) > store.streakDays {
            store.streakDays = Int(remoteStreak)
        }

        // dailyGoal: KVS 優先（意図的な設定変更）
        let remoteGoal = kvs.longLong(forKey: "progress.dailyGoal")
        if remoteGoal > 0 {
            store.dailyGoal = Int(remoteGoal)
        }

        // completedLessons: union
        if let remoteCompleted = kvs.array(forKey: "progress.completedLessons") as? [String] {
            store.completedLessons.formUnion(remoteCompleted)
        }

        // bookmarkedQuizIds: union
        if let remoteBookmarks = kvs.array(forKey: "progress.bookmarkedQuizzes") as? [String] {
            store.bookmarkedQuizIds.formUnion(remoteBookmarks)
        }

        // reviewQueueQuizIds: union + deduplicate
        if let remoteQueue = kvs.array(forKey: "progress.reviewQueueQuizIds") as? [String] {
            var merged = store.reviewQueueQuizIds + remoteQueue
            var seen = Set<String>()
            merged = merged.filter { seen.insert($0).inserted }
            store.reviewQueueQuizIds = merged
        }

        // dailyHistory: 各日付のカウントは max
        if let remoteHistory = kvs.dictionary(forKey: "progress.dailyHistory") as? [String: Int] {
            for (date, count) in remoteHistory {
                let local = store.dailyHistory[date] ?? 0
                store.dailyHistory[date] = max(local, count)
            }
        }

        // answerHistory: UUID で dedup、answeredAt 降順で最新 2000 件
        if let data = kvs.data(forKey: "progress.answerHistory"),
           let remoteRecords = try? JSONDecoder().decode([QuizAnswerRecord].self, from: data) {
            var byId = Dictionary(uniqueKeysWithValues: store.answerHistory.map { ($0.id, $0) })
            for record in remoteRecords {
                if byId[record.id] == nil {
                    byId[record.id] = record
                }
            }
            store.answerHistory = byId.values
                .sorted { $0.answeredAt > $1.answeredAt }
                .prefix(2000)
                .map { $0 }
                .sorted { $0.answeredAt < $1.answeredAt } // 古い順に戻す
        }

        // mockExamAttempts: UUID で dedup、completedAt 降順で最新 30 件
        if let data = kvs.data(forKey: "progress.mockExamAttempts"),
           let remoteAttempts = try? JSONDecoder().decode([MockExamAttempt].self, from: data) {
            var byId = Dictionary(uniqueKeysWithValues: store.mockExamAttempts.map { ($0.id, $0) })
            for attempt in remoteAttempts {
                if byId[attempt.id] == nil {
                    byId[attempt.id] = attempt
                }
            }
            store.mockExamAttempts = byId.values
                .sorted { $0.completedAt > $1.completedAt }
                .prefix(30)
                .map { $0 }
                .sorted { $0.completedAt < $1.completedAt } // 古い順に戻す
        }
    }

    private func startObserving() {
        // Use async notification stream so the handler always runs on @MainActor,
        // avoiding the data race that @objc selector callbacks (called on an arbitrary
        // background thread) would cause with @MainActor @Observable ProgressStore.
        Task { @MainActor [weak self] in
            let notifications = NotificationCenter.default.notifications(
                named: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                object: self?.kvs
            )
            for await _ in notifications {
                self?.pullAndMerge()
            }
        }
    }
}
