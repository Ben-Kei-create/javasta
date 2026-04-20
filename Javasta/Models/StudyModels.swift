import Foundation

enum JavaExamVersion: String, Codable, CaseIterable, Identifiable {
    case se17 = "se17"
    case se11 = "se11"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .se17: return "Java SE 17"
        case .se11: return "Java SE 11"
        }
    }

    func examCode(for level: JavaLevel) -> String {
        switch (self, level) {
        case (.se17, .silver): return "1Z0-825-JPN"
        case (.se17, .gold): return "1Z0-826-JPN"
        case (.se11, .silver): return "1Z0-815-JPN"
        case (.se11, .gold): return "1Z0-816-JPN"
        }
    }
}

enum QuizDifficulty: String, Codable, CaseIterable {
    case foundation
    case standard
    case tricky
    case exam

    var displayName: String {
        switch self {
        case .foundation: return "基礎"
        case .standard: return "標準"
        case .tricky: return "ひっかけ"
        case .exam: return "本番"
        }
    }
}

enum QuizReviewStatus: String, Codable {
    case draft
    case verified
    case needsReview

    var displayName: String {
        switch self {
        case .draft: return "下書き"
        case .verified: return "検証済み"
        case .needsReview: return "要確認"
        }
    }
}

struct ExamObjective: Identifiable, Hashable {
    let id: String
    let version: JavaExamVersion
    let level: JavaLevel
    let category: QuizCategory
    let title: String
    let priority: Int
}

enum ExamObjectiveCatalog {
    static let all: [ExamObjective] = [
        ExamObjective(
            id: "se17-silver-program",
            version: .se17,
            level: .silver,
            category: .javaBasics,
            title: "Javaの概要と簡単なJavaプログラム",
            priority: 1
        ),
        ExamObjective(
            id: "se17-silver-data-string",
            version: .se17,
            level: .silver,
            category: .dataTypes,
            title: "基本データ型・文字列・配列・ArrayList",
            priority: 1
        ),
        ExamObjective(
            id: "se17-silver-control",
            version: .se17,
            level: .silver,
            category: .controlFlow,
            title: "演算子と制御構造",
            priority: 1
        ),
        ExamObjective(
            id: "se17-silver-class",
            version: .se17,
            level: .silver,
            category: .classes,
            title: "クラス・メソッド・コンストラクタ",
            priority: 1
        ),
        ExamObjective(
            id: "se17-silver-inheritance",
            version: .se17,
            level: .silver,
            category: .inheritance,
            title: "継承とインタフェース",
            priority: 1
        ),
        ExamObjective(
            id: "se17-silver-exception",
            version: .se17,
            level: .silver,
            category: .exceptionHandling,
            title: "例外処理",
            priority: 1
        ),
        ExamObjective(
            id: "se17-gold-collections",
            version: .se17,
            level: .gold,
            category: .collections,
            title: "コレクションとジェネリクス",
            priority: 1
        ),
        ExamObjective(
            id: "se17-gold-lambda",
            version: .se17,
            level: .gold,
            category: .lambdaStreams,
            title: "関数型インタフェースとラムダ式",
            priority: 1
        ),
        ExamObjective(
            id: "se17-gold-stream",
            version: .se17,
            level: .gold,
            category: .lambdaStreams,
            title: "Java Stream API",
            priority: 1
        ),
        ExamObjective(
            id: "se17-gold-module",
            version: .se17,
            level: .gold,
            category: .moduleSystem,
            title: "Javaモジュール・システム",
            priority: 2
        ),
        ExamObjective(
            id: "se17-gold-concurrency",
            version: .se17,
            level: .gold,
            category: .concurrency,
            title: "並列処理",
            priority: 2
        ),
        ExamObjective(
            id: "se17-gold-io",
            version: .se17,
            level: .gold,
            category: .io,
            title: "ファイルI/O",
            priority: 2
        ),
        ExamObjective(
            id: "se17-gold-jdbc",
            version: .se17,
            level: .gold,
            category: .jdbc,
            title: "JDBC",
            priority: 3
        ),
        ExamObjective(
            id: "se17-gold-localization",
            version: .se17,
            level: .gold,
            category: .localization,
            title: "ローカライズ",
            priority: 3
        ),
    ]

    static func objectives(for version: JavaExamVersion, level: JavaLevel) -> [ExamObjective] {
        all
            .filter { $0.version == version && $0.level == level }
            .sorted {
                if $0.priority == $1.priority { return $0.title < $1.title }
                return $0.priority < $1.priority
            }
    }
}

enum QuizPracticeMode: String, CaseIterable, Identifiable {
    case single
    case daily
    case weak
    case mistakes
    case unattempted
    case mockExam

    static let allCases: [QuizPracticeMode] = [.daily, .weak, .mistakes, .unattempted, .mockExam]
    static let homeModes: [QuizPracticeMode] = [.daily, .unattempted]

    var id: String { rawValue }

    var title: String {
        switch self {
        case .single: return "単問チャレンジ"
        case .daily: return "ランダム10問"
        case .weak: return "苦手克服"
        case .mistakes: return "ミスだけ復習"
        case .unattempted: return "未回答から"
        case .mockExam: return "模擬試験"
        }
    }

    var subtitle: String {
        switch self {
        case .single: return "選んだ問題を解く"
        case .daily: return "毎回シャッフルして解く"
        case .weak: return "正答率が低いタグを優先"
        case .mistakes: return "間違えた問題を再挑戦"
        case .unattempted: return "新しい問題だけ進める"
        case .mockExam: return "最後に合格ゾーンを判定"
        }
    }

    var icon: String {
        switch self {
        case .single: return "pencil.and.list.clipboard"
        case .daily: return "sparkles"
        case .weak: return "target"
        case .mistakes: return "arrow.counterclockwise"
        case .unattempted: return "circle.dashed"
        case .mockExam: return "graduationcap.fill"
        }
    }

    var limit: Int {
        switch self {
        case .single: return 1
        case .daily: return 10
        case .weak: return 10
        case .mistakes: return 10
        case .unattempted: return 10
        case .mockExam: return 60
        }
    }
}

struct QuizSession: Identifiable {
    let id = UUID()
    let mode: QuizPracticeMode
    let level: JavaLevel
    let version: JavaExamVersion
    let quizzes: [Quiz]
    var customTitle: String? = nil
    var mockExamVariant: MockExamVariant? = nil

    var title: String { customTitle ?? mode.title }
    var subtitle: String { "\(level.displayName) / \(version.displayName)" }
    var icon: String { mode.icon }

    static func single(_ quiz: Quiz) -> QuizSession {
        QuizSession(
            mode: .single,
            level: quiz.level,
            version: quiz.examVersion,
            quizzes: [quiz],
            customTitle: "単問チャレンジ"
        )
    }
}

struct QuizAnswerRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let quizId: String
    let level: JavaLevel
    let category: String
    let tags: [String]
    let selectedChoiceId: String
    let correct: Bool
    let answeredAt: Date
    let elapsedSeconds: Int?

    init(
        id: UUID = UUID(),
        quizId: String,
        level: JavaLevel,
        category: String,
        tags: [String],
        selectedChoiceId: String,
        correct: Bool,
        answeredAt: Date = Date(),
        elapsedSeconds: Int? = nil
    ) {
        self.id = id
        self.quizId = quizId
        self.level = level
        self.category = category
        self.tags = tags
        self.selectedChoiceId = selectedChoiceId
        self.correct = correct
        self.answeredAt = answeredAt
        self.elapsedSeconds = elapsedSeconds
    }
}

struct QuizAttemptStats {
    let attempts: Int
    let correct: Int
    let latest: QuizAnswerRecord?

    var accuracy: Double {
        guard attempts > 0 else { return 0 }
        return Double(correct) / Double(attempts)
    }

    var isAnswered: Bool { attempts > 0 }
    var isMastered: Bool { attempts >= 2 && accuracy >= 0.8 && latest?.correct == true }
    var needsReview: Bool { attempts > 0 && latest?.correct == false }
}

struct WeakTagSummary: Identifiable, Hashable {
    let tag: String
    let attempts: Int
    let misses: Int

    var id: String { tag }
    var missRate: Double {
        guard attempts > 0 else { return 0 }
        return Double(misses) / Double(attempts)
    }

    var missRatePercent: Int {
        Int((missRate * 100).rounded())
    }
}
