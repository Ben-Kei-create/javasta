import Foundation

struct Lesson: Codable, Identifiable {
    let id: String
    let level: JavaLevel
    let category: String
    let title: String
    let summary: String
    let estimatedMinutes: Int
    let sections: [Section]
    let keyPoints: [String]
    let relatedQuizIds: [String]

    var categoryDisplayName: String {
        QuizCategory(rawValue: category)?.displayName ?? category
    }

    struct Section: Codable, Identifiable {
        let id: String
        let heading: String
        let body: String
        let code: String?
        let highlightLines: [Int]
        let callout: Callout?
    }

    struct Callout: Codable {
        enum Kind: String, Codable { case tip, warning, note, exam }
        let kind: Kind
        let text: String
    }
}
