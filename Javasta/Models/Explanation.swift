import Foundation

struct Explanation: Codable, Identifiable {
    let id: String
    let initialCode: String
    let steps: [Step]

    struct Step: Codable, Identifiable {
        let index: Int
        let narration: String
        let highlightLines: [Int]
        let variables: [Variable]
        let callStack: [CallStackFrame]
        let heap: [HeapObject]
        let predict: PredictPrompt?

        var id: Int { index }
    }

    struct Variable: Codable, Identifiable, Equatable {
        let name: String
        let type: String
        let value: String
        let scope: String

        var id: String { "\(scope).\(name)" }
    }

    struct CallStackFrame: Codable, Identifiable {
        let method: String
        let line: Int

        var id: String { "\(method)-\(line)" }
    }

    struct HeapObject: Codable, Identifiable {
        let id: String
        let type: String
        let fields: [String: String]
    }

    struct PredictPrompt: Codable {
        let question: String
        let choices: [String]
        let answerIndex: Int
        let hint: String
        let afterExplanation: String
    }
}
