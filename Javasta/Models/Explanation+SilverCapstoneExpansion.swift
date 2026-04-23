import Foundation

extension Explanation {
    static let silverCapstoneAuthoredSamples: [String: Explanation] = Dictionary(
        uniqueKeysWithValues: (SilverCapstoneQuestionData.practiceSpecs + SilverCapstoneQuestionData.mockSpecs).map { spec in
            (spec.explanationRef, spec.explanation)
        }
    )
}

extension SilverCapstoneQuestionData.Spec {
    var explanation: Explanation {
        Explanation(
            id: explanationRef,
            initialCode: code,
            steps: steps.enumerated().map { offset, spec in
                Explanation.Step(
                    index: offset,
                    narration: spec.narration,
                    highlightLines: spec.highlightLines,
                    variables: spec.variables.map {
                        Explanation.Variable(
                            name: $0.name,
                            type: $0.type,
                            value: $0.value,
                            scope: $0.scope
                        )
                    },
                    callStack: [],
                    heap: [],
                    predict: nil
                )
            }
        )
    }
}
