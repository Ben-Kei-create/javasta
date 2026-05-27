import Foundation

/// App-wide constants for App Store submission and external links.
///
/// Centralises every string that would otherwise be scattered across
/// `SettingsView`, `QuizView`, `JavastaShare`, etc.  Update the values
/// here once and every call-site benefits automatically.
enum AppConfig {
    // MARK: - Contact / Support

    /// Developer contact email — used in feedback mailto links.
    static let supportEmail = "fsmall.worldm@gmail.com"

    // MARK: - App Store

    /// App Store numeric identifier (replace with actual ID after first submission).
    /// Used to build the review URL and the invite share-text.
    static let appStoreID = "0000000000"          // TODO: replace after first App Store upload

    /// Deep-link to the App Store product page.
    static var appStoreURL: URL {
        URL(string: "https://apps.apple.com/app/id\(appStoreID)")!
    }

    /// Deep-link directly to the "Write a Review" sheet.
    static var appStoreReviewURL: URL {
        URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review")!
    }

    // MARK: - Legal / Privacy

    /// Public-facing privacy policy URL.
    static let privacyPolicyURL = URL(string: "https://ben-kei-create.github.io/javasta/privacy.html")!

    /// App support page URL — shown in App Store listing and required by Apple.
    static let supportURL = URL(string: "https://ben-kei-create.github.io/javasta/support.html")!
}
