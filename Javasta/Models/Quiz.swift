import Foundation

struct Quiz: Codable, Identifiable {
    let id: String
    let level: JavaLevel
    let category: String
    let tags: [String]
    let code: String
    let question: String
    let choices: [Choice]
    let explanationRef: String
    let designIntent: String

    var categoryDisplayName: String {
        QuizCategory(rawValue: category)?.displayName ?? category
    }

    struct Choice: Codable, Identifiable {
        let id: String
        let text: String
        let correct: Bool
        let misconception: String?
        let explanation: String
    }
}
