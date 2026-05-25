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

    static let goldSE11CompatibilityAuthoredSamples: [String: Explanation] = {
        let reusableSources = goldSE11ReusableSourceExplanations
        let pairs = zip(
            QuizExpansion.goldSE11CompatibilitySourceExpansion,
            QuizExpansion.goldSE11CompatibilityExpansion
        )

        return Dictionary(
            uniqueKeysWithValues: pairs.map { sourceQuiz, targetQuiz in
                let sourceExplanation = reusableSources[sourceQuiz.explanationRef]
                let explanation = sourceExplanation.map {
                    retargetedSE11Explanation($0, for: targetQuiz)
                } ?? focusedSE11Trace(sourceQuiz: sourceQuiz, targetQuiz: targetQuiz)

                return (targetQuiz.explanationRef, explanation)
            }
        )
    }()

    private static var goldSE11ReusableSourceExplanations: [String: Explanation] {
        goldSE11CoreSourceExplanations
            .merging(generatedAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(streamApiAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(goldGeneralAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(goldAdvancedAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(goldBalancedAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(goldInheritanceBalanceAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(goldNonLambdaAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(goldNonLambdaFurtherAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(auditBackfillSamples, uniquingKeysWith: { existing, _ in existing })
    }

    private static var goldSE11CoreSourceExplanations: [String: Explanation] {
        [
            goldOptional004Explanation.id: goldOptional004Explanation
        ]
    }

    private static func retargetedSE11Explanation(
        _ source: Explanation,
        for quiz: Quiz
    ) -> Explanation {
        let lineCount = max(quiz.code.components(separatedBy: .newlines).count, 1)

        return Explanation(
            id: quiz.explanationRef,
            initialCode: quiz.code,
            codeTabs: quiz.codeTabs ?? source.codeTabs,
            steps: source.steps.map { step in
                Explanation.Step(
                    index: step.index,
                    narration: step.narration,
                    highlightLines: normalizedLines(step.highlightLines, lineCount: lineCount),
                    variables: step.variables,
                    callStack: step.callStack.map {
                        Explanation.CallStackFrame(
                            method: $0.method,
                            line: normalizedLine($0.line, lineCount: lineCount)
                        )
                    },
                    heap: step.heap,
                    predict: step.predict
                )
            }
        )
    }

    private static func normalizedLines(_ lines: [Int], lineCount: Int) -> [Int] {
        lines.map { normalizedLine($0, lineCount: lineCount) }
    }

    private static func normalizedLine(_ line: Int, lineCount: Int) -> Int {
        min(max(line, 1), lineCount)
    }

    private static func focusedSE11Trace(
        sourceQuiz: Quiz,
        targetQuiz: Quiz
    ) -> Explanation {
        let lines = targetQuiz.code.components(separatedBy: .newlines)
        let mainLine = lines.firstIndex { $0.contains("main(") }.map { $0 + 1 } ?? 1
        let focusLines = se11FocusLines(in: lines)
        let highlightedLines = Array(Set([mainLine] + focusLines)).sorted()
        let correctChoice = targetQuiz.choices.first { $0.correct }
        let wrongHints = targetQuiz.choices
            .filter { !$0.correct }
            .compactMap { choice -> String? in
                guard let misconception = choice.misconception, !misconception.isEmpty else {
                    return nil
                }
                return "\(choice.text)は\(misconception)"
            }
            .prefix(2)
            .joined(separator: "。")
        let focusText = focusLines
            .map { "L\($0) `\(se11Snippet(from: lines, at: $0))`" }
            .joined(separator: "、")
        let firstFocusLine = focusLines.first ?? mainLine
        let resultLine = focusLines.last ?? mainLine

        return Explanation(
            id: targetQuiz.explanationRef,
            initialCode: targetQuiz.code,
            codeTabs: targetQuiz.codeTabs,
            steps: [
                Explanation.Step(
                    index: 0,
                    narration: "`main` から実行を始めます。この問題で結果を左右するのは \(focusText) です。",
                    highlightLines: highlightedLines,
                    variables: [
                        Explanation.Variable(
                            name: "source",
                            type: "Quiz",
                            value: sourceQuiz.id,
                            scope: "SE11"
                        )
                    ],
                    callStack: [Explanation.CallStackFrame(method: "main", line: mainLine)],
                    heap: [],
                    predict: nil
                ),
                Explanation.Step(
                    index: 1,
                    narration: correctChoice?.explanation ?? targetQuiz.designIntent,
                    highlightLines: [firstFocusLine],
                    variables: [
                        Explanation.Variable(
                            name: "focus",
                            type: "String",
                            value: se11Snippet(from: lines, at: firstFocusLine),
                            scope: "main"
                        )
                    ],
                    callStack: [Explanation.CallStackFrame(method: "main", line: firstFocusLine)],
                    heap: [],
                    predict: Explanation.PredictPrompt(
                        question: targetQuiz.question,
                        choices: targetQuiz.choices.map(\.text),
                        answerIndex: max(targetQuiz.choices.firstIndex(where: { $0.correct }) ?? 0, 0),
                        hint: targetQuiz.tags.joined(separator: " / "),
                        afterExplanation: correctChoice?.explanation ?? targetQuiz.designIntent
                    )
                ),
                Explanation.Step(
                    index: 2,
                    narration: [
                        "正解は「\(correctChoice?.text ?? "該当なし")」です。",
                        wrongHints.isEmpty ? nil : "誤答を消すなら、\(wrongHints)。"
                    ]
                    .compactMap { $0 }
                    .joined(separator: " "),
                    highlightLines: [resultLine],
                    variables: [
                        Explanation.Variable(
                            name: "answer",
                            type: "Choice",
                            value: targetQuiz.choices.filter(\.correct).map(\.id).joined(separator: ","),
                            scope: "result"
                        )
                    ],
                    callStack: [Explanation.CallStackFrame(method: "main", line: resultLine)],
                    heap: [],
                    predict: nil
                ),
            ]
        )
    }

    private static func se11FocusLines(in lines: [String]) -> [Int] {
        let preferredTokens = [
            "System.out", "return", "throw", "catch", "assert", "try",
            ".stream", ".parallelStream", ".collect", ".reduce", ".map",
            ".filter", ".flatMap", ".orElse", ".orElseGet", ".find",
            ".anyMatch", ".allMatch", ".noneMatch", ".add", ".remove",
            ".get", ".put", ".merge", ".set", "ServiceLoader",
            "DriverManager", "PreparedStatement", "CallableStatement",
            "ResourceBundle", "Locale", "Files.", "Path", "implements",
            "extends", "default ", "private "
        ]

        let matches = lines.enumerated().compactMap { offset, line -> Int? in
            preferredTokens.contains { line.contains($0) } ? offset + 1 : nil
        }

        if matches.isEmpty {
            return [max(lines.count, 1)]
        }

        return Array(matches.prefix(4))
    }

    private static func se11Snippet(from lines: [String], at line: Int) -> String {
        guard lines.indices.contains(line - 1) else { return "" }

        let trimmed = lines[line - 1]
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "`", with: "'")
        if trimmed.count <= 90 {
            return trimmed
        }
        return String(trimmed.prefix(87)) + "..."
    }
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
