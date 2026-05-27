import UserNotifications
import SwiftUI

// MARK: - NotificationManager

/// 学習リマインダー通知を管理するシングルトンサービス。
///
/// 責務:
/// - 通知パーミッションの要求・状態監視
/// - 毎日指定時刻に繰り返すリマインダーのスケジューリング
/// - 設定変更時の再スケジュール
///
/// UserDefaults キー:
///   - `notificationEnabled`  : Bool   — 通知オン/オフ
///   - `notificationHour`     : Int    — 通知時刻（時）、デフォルト 20
///   - `notificationMinute`   : Int    — 通知時刻（分）、デフォルト 0
@MainActor
@Observable
final class NotificationManager {

    // MARK: Singleton

    static let shared = NotificationManager()
    private init() {}

    // MARK: Persisted state

    var isEnabled: Bool = UserDefaults.standard.bool(forKey: Keys.enabled) {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Keys.enabled)
            Task { await syncSchedule() }
        }
    }

    /// 通知時刻（時）。デフォルト 20（20:00）
    var reminderHour: Int = {
        let stored = UserDefaults.standard.integer(forKey: Keys.hour)
        return stored == 0 ? 20 : stored
    }() {
        didSet {
            UserDefaults.standard.set(reminderHour, forKey: Keys.hour)
            if isEnabled { reschedule() }
        }
    }

    /// 通知時刻（分）。デフォルト 0
    var reminderMinute: Int = UserDefaults.standard.integer(forKey: Keys.minute) {
        didSet {
            UserDefaults.standard.set(reminderMinute, forKey: Keys.minute)
            if isEnabled { reschedule() }
        }
    }

    // MARK: Runtime state

    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    // MARK: - Public API

    /// パーミッション要求 → 付与されたら通知を有効化する（オンボーディング後・設定画面から呼ぶ）
    func requestPermissionAndEnable() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
            await refreshStatus()
            if granted {
                isEnabled = true    // didSet で scheduleDaily() が走る
            }
        } catch {
            // パーミッション要求に失敗してもクラッシュしない
        }
    }

    /// 権限ステータスをシステムから再取得
    func refreshStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
        // システム側で権限が剥奪されていたら UI 状態も無効化
        if authorizationStatus == .denied && isEnabled {
            isEnabled = false
        }
    }

    /// アプリ起動時に呼び出し — UserDefaults 設定と実際のスケジュールを同期
    func syncOnLaunch() async {
        await refreshStatus()
        guard isEnabled, authorizationStatus == .authorized else {
            cancelAll()
            return
        }
        reschedule()    // 既存のスケジュールを更新（アプリ更新後などの保険）
    }

    /// 全リマインダー通知を削除
    func cancelAll() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [NotificationID.daily])
    }

    // MARK: - Formatting

    var reminderTimeDisplay: String {
        String(format: "%02d:%02d", reminderHour, reminderMinute)
    }

    /// DatePicker の初期値として使う `Date` オブジェクト（時・分のみ意味を持つ）
    var defaultPickerDate: Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour   = reminderHour
        comps.minute = reminderMinute
        return Calendar.current.date(from: comps) ?? Date()
    }

    // MARK: - Private

    private func syncSchedule() async {
        await refreshStatus()
        guard isEnabled, authorizationStatus == .authorized else {
            cancelAll()
            return
        }
        reschedule()
    }

    private func reschedule() {
        cancelAll()

        let content = UNMutableNotificationContent()
        content.title = "今日も練習しよう 💪"
        content.body = todayMessage
        content.sound = .default

        var comps = DateComponents()
        comps.hour   = reminderHour
        comps.minute = reminderMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(
            identifier: NotificationID.daily,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    /// 曜日に応じてメッセージをローテーション（同じ文が続くと無視されやすい）
    private var todayMessage: String {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return Self.reminderMessages[weekday % Self.reminderMessages.count]
    }

    private static let reminderMessages: [String] = [
        "Java認定試験への道。今日も1問解いてみよう。",
        "毎日の積み重ねが合格への近道です ☕",
        "今日の目標を達成してストリークを守ろう！",
        "コードを読む力は1問ずつ鍛えられる。",
        "Silver・Goldへの一歩。今日も練習しよう。",
        "昨日の自分より少しだけ前に進もう 🚀",
        "試験本番まで、今日を無駄にしないで。",
    ]

    // MARK: - Keys / IDs

    private enum Keys {
        static let enabled = "notificationEnabled"
        static let hour    = "notificationHour"
        static let minute  = "notificationMinute"
    }

    private enum NotificationID {
        static let daily = "javasta.daily.reminder"
    }
}
