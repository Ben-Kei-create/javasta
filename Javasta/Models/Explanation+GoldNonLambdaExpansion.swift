import Foundation

extension Explanation {
    static let goldNonLambdaAuthoredSamples: [String: Explanation] = Dictionary(
        uniqueKeysWithValues: GoldNonLambdaQuestionData.specs.map { spec in
            (spec.explanationRef, spec.explanation)
        }
    )

    static let goldNonLambdaFurtherAuthoredSamples: [String: Explanation] = Dictionary(
        uniqueKeysWithValues: GoldNonLambdaFurtherQuestionData.specs.map { spec in
            (spec.explanationRef, spec.explanation)
        }
    )
}

extension GoldNonLambdaQuestionData.Spec {
    var explanation: Explanation {
        Explanation(
            id: explanationRef,
            initialCode: code,
            codeTabs: codeTabs,
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
