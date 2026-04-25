import Foundation

struct Quiz: Codable, Identifiable {
    let id: String
    let level: JavaLevel
    var examVersion: JavaExamVersion = .se17
    var examObjectiveId: String = "unmapped"
    var difficulty: QuizDifficulty = .standard
    var estimatedSeconds: Int = 90
    var isMultipleSelect: Bool = false
    var validatedByJavac: Bool = true
    var reviewStatus: QuizReviewStatus = .draft
    var variantGroupId: String? = nil
    var isMockExamOnly: Bool = false
    let category: String
    let tags: [String]
    let code: String
    var codeTabs: [CodeFile]? = nil
    var question: String
    let choices: [Choice]
    let explanationRef: String
    let designIntent: String

    var canonicalCategory: QuizCategory? {
        QuizCategory.canonical(rawValue: category)
    }

    var canonicalCategoryRawValue: String {
        canonicalCategory?.rawValue ?? category
    }

    var categoryDisplayName: String {
        canonicalCategory?.displayName ?? category
    }

    var examCode: String {
        examVersion.examCode(for: level)
    }

    struct CodeFile: Codable, Identifiable, Hashable {
        let id: String
        let filename: String
        let code: String

        init(filename: String, code: String, id: String? = nil) {
            self.id = id ?? filename
            self.filename = filename
            self.code = code
        }
    }

    struct Choice: Codable, Identifiable {
        let id: String
        let text: String
        let correct: Bool
        let misconception: String?
        let explanation: String
    }
}

extension Quiz {
    private enum CodingKeys: String, CodingKey {
        case id
        case level
        case examVersion
        case examObjectiveId
        case difficulty
        case estimatedSeconds
        case isMultipleSelect
        case validatedByJavac
        case reviewStatus
        case variantGroupId
        case isMockExamOnly
        case category
        case tags
        case code
        case codeTabs
        case question
        case choices
        case explanationRef
        case designIntent
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        level = try container.decode(JavaLevel.self, forKey: .level)
        examVersion = try container.decodeIfPresent(JavaExamVersion.self, forKey: .examVersion) ?? .se17
        examObjectiveId = try container.decodeIfPresent(String.self, forKey: .examObjectiveId) ?? "unmapped"
        difficulty = try container.decodeIfPresent(QuizDifficulty.self, forKey: .difficulty) ?? .standard
        estimatedSeconds = try container.decodeIfPresent(Int.self, forKey: .estimatedSeconds) ?? 90
        isMultipleSelect = try container.decodeIfPresent(Bool.self, forKey: .isMultipleSelect) ?? false
        validatedByJavac = try container.decodeIfPresent(Bool.self, forKey: .validatedByJavac) ?? true
        reviewStatus = try container.decodeIfPresent(QuizReviewStatus.self, forKey: .reviewStatus) ?? .draft
        variantGroupId = try container.decodeIfPresent(String.self, forKey: .variantGroupId)
        isMockExamOnly = try container.decodeIfPresent(Bool.self, forKey: .isMockExamOnly) ?? false
        category = try container.decode(String.self, forKey: .category)
        tags = try container.decode([String].self, forKey: .tags)
        code = try container.decode(String.self, forKey: .code)
        codeTabs = try container.decodeIfPresent([CodeFile].self, forKey: .codeTabs)
        let rawQuestion = try container.decode(String.self, forKey: .question)
        question = Self.contextualizedQuestion(
            rawQuestion,
            category: category,
            tags: tags
        )
        choices = try container.decode([Choice].self, forKey: .choices)
        explanationRef = try container.decode(String.self, forKey: .explanationRef)
        designIntent = try container.decode(String.self, forKey: .designIntent)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(level, forKey: .level)
        try container.encode(examVersion, forKey: .examVersion)
        try container.encode(examObjectiveId, forKey: .examObjectiveId)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(estimatedSeconds, forKey: .estimatedSeconds)
        try container.encode(isMultipleSelect, forKey: .isMultipleSelect)
        try container.encode(validatedByJavac, forKey: .validatedByJavac)
        try container.encode(reviewStatus, forKey: .reviewStatus)
        try container.encodeIfPresent(variantGroupId, forKey: .variantGroupId)
        try container.encode(isMockExamOnly, forKey: .isMockExamOnly)
        try container.encode(category, forKey: .category)
        try container.encode(tags, forKey: .tags)
        try container.encode(code, forKey: .code)
        try container.encodeIfPresent(codeTabs, forKey: .codeTabs)
        try container.encode(question, forKey: .question)
        try container.encode(choices, forKey: .choices)
        try container.encode(explanationRef, forKey: .explanationRef)
        try container.encode(designIntent, forKey: .designIntent)
    }

    func contextualizedForPresentation() -> Quiz {
        var quiz = self
        quiz.question = Self.contextualizedQuestion(
            question,
            category: category,
            tags: tags
        )
        return quiz
    }

    private static func contextualizedQuestion(
        _ question: String,
        category: String,
        tags: [String]
    ) -> String {
        let genericTemplates: [String: (String) -> String] = [
            "このコードを実行したとき、出力されるのはどれか？": {
                "この\($0)を扱うコードを実行したとき、出力されるのはどれか？"
            },
            "このコードをコンパイルしたときの結果として正しいものはどれか？": {
                "この\($0)を扱うコードをコンパイルしたときの結果として正しいものはどれか？"
            },
            "このコードを実行したとき、出力される結果はどれか？": {
                "この\($0)を扱うコードを実行したとき、出力される結果はどれか？"
            },
            "このコードの出力はどれか？": {
                "この\($0)を扱うコードの出力はどれか？"
            },
            "このコードについて正しい説明はどれか？": {
                "この\($0)を扱うコードについて正しい説明はどれか？"
            },
            "このコードの出力として正しいものはどれか？": {
                "この\($0)を扱うコードの出力として正しいものはどれか？"
            }
        ]

        guard let template = genericTemplates[question] else {
            return question
        }

        let focus = questionFocus(category: category, tags: tags)
        guard !focus.isEmpty else {
            return question
        }

        return template(focus)
    }

    private static func questionFocus(category: String, tags: [String]) -> String {
        let ignoredTags: Set<String> = [
            "模試専用",
            "compile",
            "exam",
            "standard",
            "tricky",
            "basic",
            "application"
        ]

        var parts: [String] = []
        let categoryLabel = QuizCategory.canonical(rawValue: category)?.displayName ?? category
        if !categoryLabel.isEmpty {
            parts.append(categoryLabel)
        }

        for tag in tags where !ignoredTags.contains(tag) && !tag.isEmpty {
            if parts.contains(tag) { continue }
            parts.append(tag)
            if parts.count == 3 { break }
        }

        return parts.joined(separator: "・")
    }
}
