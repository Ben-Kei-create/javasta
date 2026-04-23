import Foundation

extension Explanation {
    static func sample(for ref: String) -> Explanation? {
        if let explanation = authoredSamples[ref] {
            return explanation
        }

        if let quiz = Quiz.samples.first(where: { $0.explanationRef == ref }) {
            return quickTrace(for: quiz, ref: ref)
        }

        return nil
    }

    static var authoredSampleIds: Set<String> {
        Set(authoredSamples.keys)
    }

    static var allSampleIds: [String] {
        authoredSamples.keys.sorted()
    }

    static func isAuthored(ref: String) -> Bool {
        authoredSamples[ref] != nil
    }

    static func traceStatus(for ref: String) -> ExplanationTraceStatus {
        if authoredSamples[ref] != nil {
            return .authored
        }

        if Quiz.samples.contains(where: { $0.explanationRef == ref }) {
            return .placeholder
        }

        return .missing
    }

    private static var authoredSamples: [String: Explanation] {
        let base: [String: Explanation] = [
            goldLambdaEffectivelyFinal001Explanation.id: goldLambdaEffectivelyFinal001Explanation,
            silverInheritanceException001Explanation.id: silverInheritanceException001Explanation,
            goldStreamLazy001Explanation.id: goldStreamLazy001Explanation,
            goldGenericsErasure001Explanation.id: goldGenericsErasure001Explanation,
            silverConstructorChain001Explanation.id: silverConstructorChain001Explanation,
            silverOverloadVarargs001Explanation.id: silverOverloadVarargs001Explanation,
            silverPolymorphism001Explanation.id: silverPolymorphism001Explanation,
            silverPolymorphismHiding001Explanation.id: silverPolymorphismHiding001Explanation,
            silverExceptionFinally001Explanation.id: silverExceptionFinally001Explanation,
            silverStringPool001Explanation.id: silverStringPool001Explanation,
            silverDataTypesPassByValueExplanation.id: silverDataTypesPassByValueExplanation,
            silverDataTypesPromotion003Explanation.id: silverDataTypesPromotion003Explanation,
            silverControlFlow003Explanation.id: silverControlFlow003Explanation,
            silverClasses003Explanation.id: silverClasses003Explanation,
            silverException003Explanation.id: silverException003Explanation,
            silverCollections002Explanation.id: silverCollections002Explanation,
            silverOverload003Explanation.id: silverOverload003Explanation,
            silverString002Explanation.id: silverString002Explanation,
            silverInheritance002Explanation.id: silverInheritance002Explanation,
            silverJavaBasics003Explanation.id: silverJavaBasics003Explanation,
            silverDataTypes004Explanation.id: silverDataTypes004Explanation,
            silverControlFlow004Explanation.id: silverControlFlow004Explanation,
            silverException004Explanation.id: silverException004Explanation,
            silverClasses004Explanation.id: silverClasses004Explanation,
            silverCollections003Explanation.id: silverCollections003Explanation,
            silverOverload004Explanation.id: silverOverload004Explanation,
            silverString003Explanation.id: silverString003Explanation,
            silverJavaBasics004Explanation.id: silverJavaBasics004Explanation,
            silverArray003Explanation.id: silverArray003Explanation,
            silverException005Explanation.id: silverException005Explanation,
            silverClasses005Explanation.id: silverClasses005Explanation,
            silverControlFlow005Explanation.id: silverControlFlow005Explanation,
            goldGenerics004Explanation.id: goldGenerics004Explanation,
            goldStream006Explanation.id: goldStream006Explanation,
            goldOptional004Explanation.id: goldOptional004Explanation,
            goldConcurrency005Explanation.id: goldConcurrency005Explanation,
            silverOverload001.id: silverOverload001,
            silverException001.id: silverException001,
            goldGenerics001.id: goldGenerics001,
            silverString001.id: silverString001,
            silverAutoboxing001.id: silverAutoboxing001,
            silverSwitch001.id: silverSwitch001,
            goldStream001.id: goldStream001,
            goldLambdaMethodReference001Explanation.id: goldLambdaMethodReference001Explanation,
            goldOptional001.id: goldOptional001,
        ]

        return base
            .merging(generatedAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(silverBalancedAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(silverFurtherAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(silverCapstoneAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(silverSprintAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(silverFinalPushAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(streamApiAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(goldGeneralAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(goldAdvancedAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(goldBalancedAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(goldInheritanceBalanceAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(mockExamOnlyAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(silverMockFurtherAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(goldMockAdditionalAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(mockCenturyAuthoredSamples, uniquingKeysWith: { _, new in new })
            .merging(goldMockTopupAuthoredSamplesResolved, uniquingKeysWith: { _, new in new })
            .merging(auditBackfillSamples, uniquingKeysWith: { existing, _ in existing })
    }

    private static var goldMockTopupAuthoredSamplesResolved: [String: Explanation] {
        Dictionary(
            uniqueKeysWithValues: GoldMockTopupQuestionData.specs.map { spec in
                (
                    spec.explanationRef,
                    Explanation(
                        id: spec.explanationRef,
                        initialCode: spec.code,
                        steps: spec.steps.enumerated().map { offset, step in
                            Explanation.Step(
                                index: offset,
                                narration: step.narration,
                                highlightLines: step.highlightLines,
                                variables: step.variables.map {
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
                )
            }
        )
    }

    private static var auditBackfillSamples: [String: Explanation] {
        var samples: [String: Explanation] = [:]
        for quiz in Quiz.samples where auditBackfillRefs.contains(quiz.explanationRef) {
            samples[quiz.explanationRef] = focusedBackfillTrace(for: quiz, ref: quiz.explanationRef)
        }
        return samples
    }

    private static let auditBackfillRefs: Set<String> = [
        "explain-gold-annotations-002",
        "explain-gold-classes-003",
        "explain-gold-classes-004",
        "explain-gold-classes-005",
        "explain-gold-classes-006",
        "explain-gold-collections-002",
        "explain-gold-collections-003",
        "explain-gold-collections-004",
        "explain-gold-concurrency-007",
        "explain-gold-concurrency-008",
        "explain-gold-date-time-002",
        "explain-gold-date-time-003",
        "explain-gold-date-time-004",
        "explain-gold-exception-006",
        "explain-gold-generics-006",
        "explain-gold-io-003",
        "explain-gold-io-004",
        "explain-gold-io-005",
        "explain-gold-jdbc-003",
        "explain-gold-module-003",
        "explain-gold-optional-007",
        "explain-gold-stream-011",
        "explain-silver-array-004",
        "explain-silver-array-005",
        "explain-silver-array-006",
        "explain-silver-array-007",
        "explain-silver-array-008",
        "explain-silver-arraylist-001",
        "explain-silver-classes-007",
        "explain-silver-collections-006",
        "explain-silver-control-flow-008",
        "explain-silver-control-flow-009",
        "explain-silver-data-types-003",
        "explain-silver-data-types-007",
        "explain-silver-data-types-008",
        "explain-silver-data-types-009",
        "explain-silver-data-types-010",
        "explain-silver-data-types-011",
        "explain-silver-data-types-012",
        "explain-silver-inheritance-004",
        "explain-silver-inheritance-005",
        "explain-silver-inheritance-006",
        "explain-silver-inheritance-007",
        "explain-silver-java-basics-006",
        "explain-silver-operators-001",
        "explain-silver-operators-002",
        "explain-silver-string-006",
        "explain-silver-stringbuilder-002",
        "explain-silver-stringbuilder-003",
        "explain-silver-stringbuilder-004",
    ]

    private static func focusedBackfillTrace(for quiz: Quiz, ref: String) -> Explanation {
        let lines = quiz.code.components(separatedBy: .newlines)
        let mainLine = lines.firstIndex { $0.contains("main(") }.map { $0 + 1 } ?? 1
        let decisionLine = bestDecisionLine(in: lines)
        let correctChoice = quiz.choices.first { $0.correct }
        let focus = focusSnippet(from: lines, at: decisionLine)

        return Explanation(
            id: ref,
            initialCode: quiz.code,
            codeTabs: quiz.codeTabs,
            steps: [
                Step(
                    index: 0,
                    narration: "この問題は「\(quiz.designIntent)」を確認します。まず `main` から実行を開始し、判断に効く行 `\(focus)` に注目します。",
                    highlightLines: Array(Set([mainLine, decisionLine])).sorted(),
                    variables: [],
                    callStack: [CallStackFrame(method: "main", line: mainLine)],
                    heap: [],
                    predict: nil
                ),
                Step(
                    index: 1,
                    narration: correctChoice?.explanation ?? quiz.designIntent,
                    highlightLines: [decisionLine],
                    variables: [],
                    callStack: [CallStackFrame(method: "main", line: decisionLine)],
                    heap: [],
                    predict: PredictPrompt(
                        question: quiz.question,
                        choices: quiz.choices.map(\.text),
                        answerIndex: max(quiz.choices.firstIndex(where: { $0.correct }) ?? 0, 0),
                        hint: quiz.tags.joined(separator: " / "),
                        afterExplanation: correctChoice?.explanation ?? quiz.designIntent
                    )
                ),
                Step(
                    index: 2,
                    narration: "したがって正解は「\(correctChoice?.text ?? "該当なし")」です。コードの評価結果と選択肢の説明が一致するかを最後に確認します。",
                    highlightLines: [decisionLine],
                    variables: [],
                    callStack: [CallStackFrame(method: "main", line: decisionLine)],
                    heap: [],
                    predict: nil
                ),
            ]
        )
    }

    private static func bestDecisionLine(in lines: [String]) -> Int {
        let preferredTokens = ["System.out", "return", "throw", "catch", "if", "for", "while", ".add", ".remove", ".get", ".map", ".filter", ".orElse", ".parse", ".format", ".test", ".apply"]
        if let index = lines.lastIndex(where: { line in
            preferredTokens.contains { line.contains($0) }
        }) {
            return index + 1
        }
        return max(lines.count, 1)
    }

    private static func focusSnippet(from lines: [String], at line: Int) -> String {
        guard lines.indices.contains(line - 1) else { return "" }
        let trimmed = lines[line - 1].trimmingCharacters(in: .whitespaces)
        if trimmed.count <= 96 {
            return trimmed
        }
        return String(trimmed.prefix(93)) + "..."
    }

    private static func quickTrace(for quiz: Quiz, ref: String) -> Explanation {
        
        
        let lines = quiz.code.components(separatedBy: .newlines)
        let mainLine = lines.firstIndex { $0.contains("main(") }.map { $0 + 1 } ?? 1
        let outputLine = lines.lastIndex { $0.contains("System.out") }.map { $0 + 1 } ?? max(lines.count, 1)
        let correctChoice = quiz.choices.first { $0.correct }

        return Explanation(
            id: ref,
            initialCode: quiz.code,
            codeTabs: quiz.codeTabs,
            steps: [
                Step(
                    index: 0,
                    narration: "mainメソッドから実行開始。この問題では、コードを上から順に追い、出力またはコンパイル結果を判断します。",
                    highlightLines: [mainLine],
                    variables: [],
                    callStack: [CallStackFrame(method: "main", line: mainLine)],
                    heap: [],
                    predict: nil
                ),
                Step(
                    index: 1,
                    narration: "選択肢を判断する前に、型・参照・APIの評価順序を確認します。特にこの問題の狙いは「\(quiz.designIntent)」です。",
                    highlightLines: [outputLine],
                    variables: [],
                    callStack: [CallStackFrame(method: "main", line: outputLine)],
                    heap: [],
                    predict: PredictPrompt(
                        question: quiz.question,
                        choices: quiz.choices.map(\.text),
                        answerIndex: max(quiz.choices.firstIndex(where: { $0.correct }) ?? 0, 0),
                        hint: quiz.tags.joined(separator: " / "),
                        afterExplanation: correctChoice?.explanation ?? quiz.designIntent
                    )
                ),
                Step(
                    index: 2,
                    narration: "正解は「\(correctChoice?.text ?? "該当なし")」。\(correctChoice?.explanation ?? quiz.designIntent)",
                    highlightLines: [outputLine],
                    variables: [],
                    callStack: [CallStackFrame(method: "main", line: outputLine)],
                    heap: [],
                    predict: nil
                ),
            ]
        )
    }
    
    // MARK: - 解説: Effectively Final
        static let goldLambdaEffectivelyFinal001Explanation = Explanation(
            id: "explain-gold-lambda-effectively-final-001",
            initialCode: """
    public class Test {
        public static void main(String[] args) {
            int count = 0;
            Runnable r = () -> {
                System.out.println(count);
            };
            count++; // ここでエラー
            r.run();
        }
    }
    """,
            steps: [
                Step(index: 1,
                     narration: "ローカル変数 count を宣言し、ラムダ式 r を定義します。このとき、ラムダ式は外部の変数 count を『キャプチャ』しようとします。",
                     highlightLines: [3, 4, 5, 6],
                     variables: [
                         Variable(name: "count", type: "int", value: "0", scope: "main"),
                         Variable(name: "r", type: "Runnable", value: "参照 -> Lambda", scope: "main")
                     ],
                     callStack: [CallStackFrame(method: "main", line: 4)],
                     heap: [],
                     predict: PredictPrompt(
                         question: "ラムダ式を定義した後に `count++` を実行しました。ラムダ式内の count にはどのような影響が出るでしょうか？",
                         choices: ["ラムダの中も1になる", "ラムダの中は0のまま", "そもそもこの書き換えが許されない"],
                         answerIndex: 2,
                         hint: "Javaのラムダが参照するローカル変数は、宣言後一度も書き換えられてはいけないというルールがあります。",
                         afterExplanation: "正解です。Javaは『実質的にfinal』な変数しかラムダに持ち込めません。"
                     )),
                Step(index: 2,
                     narration: "コンパイラは `count++` という書き換えを検知します。ラムダ内で使用されている変数が変更されたため、『effectively final ではない』と判断し、コンパイルエラーを発生させます。",
                     highlightLines: [7],
                     variables: [Variable(name: "count", type: "int", value: "1 (変更検知!)", scope: "main")],
                     callStack: [CallStackFrame(method: "main", line: 7)],
                     heap: [],
                     predict: nil)
            ]
        )
    
    static let silverPolymorphismHiding001Explanation = Explanation(
        id: "explain-silver-inheritance-001",
        initialCode: """
    class Coffee {
        int price = 500;
        void info() { System.out.println("Coffee: " + price); }
    }

    class SpecialtyCoffee extends Coffee {
        int price = 800;
        @Override
        void info() { System.out.println("Specialty: " + price); }
    }

    public class CafeApp {
        public static void main(String[] args) {
            Coffee myDrink = new SpecialtyCoffee();
            System.out.println("Order Price: " + myDrink.price);
            myDrink.info();
        }
    }
    """,
        steps: [
            Step(
                index: 1,
                narration: "mainメソッドが呼び出され、実行が始まります。",
                highlightLines: [1],
                variables: [],
                callStack: [CallStackFrame(method: "main", line: 15)],
                heap: [],
                predict: nil
            ),
            Step(
                index: 2,
                narration: "ヒープ領域に SpecialtyCoffee のインスタンス(obj_1)が生成されます。このとき、SpecialtyCoffee自身のpriceと、継承したCoffeeのpriceの両方がメモリ上に確保されます。",
                highlightLines: [2],
                variables: [
                    Variable(name: "myDrink", type: "Coffee", value: "参照 -> obj_1", scope: "main")
                ],
                callStack: [CallStackFrame(method: "main", line: 16)],
                heap: [
                    HeapObject(id: "obj_1", type: "SpecialtyCoffee", fields: [
                        "Coffee.price": "500",
                        "SpecialtyCoffee.price": "800"
                    ])
                ],
                predict: nil
            ),
            Step(
                index: 3,
                narration: "myDrink.price にアクセスします。変数 myDrink の宣言型は Coffee であるため、JVMは Coffee クラスの price フィールド（500）を参照します。これが『フィールドの隠蔽』です。",
                highlightLines: [3],
                variables: [
                    Variable(name: "myDrink", type: "Coffee", value: "参照 -> obj_1", scope: "main")
                ],
                callStack: [CallStackFrame(method: "main", line: 17)],
                heap: [
                    HeapObject(id: "obj_1", type: "SpecialtyCoffee", fields: [
                        "Coffee.price": "500",
                        "SpecialtyCoffee.price": "800"
                    ])
                ],
                predict: PredictPrompt(
                    question: "次に myDrink.info() を呼び出します。どちらのクラスのメソッドが実行されるでしょうか？",
                    choices: ["Coffee型の宣言を優先して Coffeeクラスの info()", "実体である obj_1 の型を優先して SpecialtyCoffeeクラスの info()"],
                    answerIndex: 1,
                    hint: "メソッドは実行時の『実体』の型に紐づけられます。これを動的結合と呼びます。",
                    afterExplanation: "正解です！実体である SpecialtyCoffee のメソッドが呼ばれるため、出力にはそのクラスの挙動が反映されます。"
                )
            ),
            Step(
                index: 4,
                narration: "myDrink.info() が実行されます。JVMは実体である obj_1 の型を確認し、SpecialtyCoffee でオーバーライドされた info() を動的に呼び出します。このメソッド内では、SpecialtyCoffee 自身の price (800) が参照されます。",
                highlightLines: [4],
                variables: [
                    Variable(name: "myDrink", type: "Coffee", value: "参照 -> obj_1", scope: "main")
                ],
                callStack: [
                    CallStackFrame(method: "SpecialtyCoffee.info", line: 11),
                    CallStackFrame(method: "main", line: 18)
                ],
                heap: [
                    HeapObject(id: "obj_1", type: "SpecialtyCoffee", fields: [
                        "Coffee.price": "500",
                        "SpecialtyCoffee.price": "800"
                    ])
                ],
                predict: nil
            ),
            Step(
                index: 5,
                narration: "メソッドの実行が終了し、mainメソッドに戻ります。最終的な出力は 'Order Price: 500' と 'Specialty: 800' になります。",
                highlightLines: [5],
                variables: [
                    Variable(name: "myDrink", type: "Coffee", value: "参照 -> obj_1", scope: "main")
                ],
                callStack: [CallStackFrame(method: "main", line: 18)],
                heap: [
                    HeapObject(id: "obj_1", type: "SpecialtyCoffee", fields: [
                        "Coffee.price": "500",
                        "SpecialtyCoffee.price": "800"
                    ])
                ],
                predict: nil
            )
        ]
    )

        // MARK: - 解説: オーバーライドと例外
        static let silverInheritanceException001Explanation = Explanation(
            id: "explain-silver-inheritance-exception-001",
            initialCode: """
    class Super {
        void display() throws IOException { ... }
    }
    class Sub extends Super {
        @Override
        void display() { System.out.print("Sub "); }
    }
    public class Test {
        public static void main(String[] args) throws IOException {
            Super s = new Sub();
            s.display();
        }
    }
    """,
            steps: [
                Step(index: 1,
                     narration: "Super型の変数 s に Subインスタンスを代入します。ここで `s.display()` を呼ぶコードを書く際、コンパイラは『Super型のdisplayメソッド』の定義を確認します。",
                     highlightLines: [11, 12],
                     variables: [Variable(name: "s", type: "Super", value: "参照 -> Subインスタンス", scope: "main")],
                     callStack: [CallStackFrame(method: "main", line: 12)],
                     heap: [],
                     predict: PredictPrompt(
                         question: "Superのdisplayは『IOExceptionを投げる』と定義されています。オーバーライドしたSubのdisplayが『何も投げない』のは許されるでしょうか？",
                         choices: ["許される（親より厳しくない）", "許されない（親と同じでないといけない）"],
                         answerIndex: 0,
                         hint: "利用する側が『最悪IOExceptionが来るかも』と構えていれば、実際には何も来なくても困りませんよね？",
                         afterExplanation: "正解！呼び出し元に迷惑をかけない（想定以上の例外を投げない）範囲なら、例外を減らすことは自由です。"
                     )),
                Step(index: 2,
                     narration: "実行時、JVMはインスタンスの型を確認します。実体はSubなので、オーバーライドされた Sub.display() が実行され、\"Sub \" が出力されます。",
                     highlightLines: [7, 12],
                     variables: [],
                     callStack: [CallStackFrame(method: "Sub.display", line: 7), CallStackFrame(method: "main", line: 12)],
                     heap: [],
                     predict: nil)
            ]
        )
    // MARK: - 解説: Stream API 遅延評価
        static let goldStreamLazy001Explanation = Explanation(
            id: "explain-gold-stream-lazy-001",
            initialCode: """
    import java.util.stream.*;
    import java.util.*;

    public class Test {
        public static void main(String[] args) {
            List<String> list = new ArrayList<>(Arrays.asList("A", "B"));
            Stream<String> stream = list.stream()
                .filter(s -> {
                    System.out.print(s + " ");
                    return true;
                });
                
            list.add("C");
            System.out.print("Size: " + stream.count());
        }
    }
    """,
            steps: [
                Step(index: 1,
                     narration: "リストに \"A\", \"B\" を入れ、stream() を生成しました。ここで filter() を呼び出していますが、画面上にはまだ何も出力されません。",
                     highlightLines: [7, 8, 9, 10, 11],
                     variables: [
                         Variable(name: "list", type: "List", value: "[\"A\", \"B\"]", scope: "main"),
                         Variable(name: "stream", type: "Stream", value: "(待機中のパイプライン)", scope: "main")
                     ],
                     callStack: [CallStackFrame(method: "main", line: 11)],
                     heap: [],
                     predict: PredictPrompt(
                         question: "この直後、`list.add(\"C\")` を実行します。その後に stream.count() を呼んだとき、filter内の print(s) は \"C\" も処理するでしょうか？",
                         choices: ["処理する（A B C）", "処理しない（A B）"],
                         answerIndex: 0,
                         hint: "Streamは終端操作が呼ばれるまで、ソースのデータを取り出し始めません。",
                         afterExplanation: "正解です！これが遅延評価です。終端操作が呼ばれた瞬間の最新のリストの状態が使用されます。"
                     )),
                Step(index: 2,
                     narration: "リストに \"C\" を追加しました。stream変数が指しているのは『手順』であり、まだ実行はされていません。",
                     highlightLines: [13],
                     variables: [
                         Variable(name: "list", type: "List", value: "[\"A\", \"B\", \"C\"]", scope: "main")
                     ],
                     callStack: [CallStackFrame(method: "main", line: 13)],
                     heap: [],
                     predict: nil),
                Step(index: 3,
                     narration: "終端操作 `count()` が呼ばれました。ここで初めてパイプラインが動き出し、最新のリストの内容 (\"A\", \"B\", \"C\") が1つずつ filter を通り、コンソールに出力されます。",
                     highlightLines: [14, 8, 9],
                     variables: [],
                     callStack: [CallStackFrame(method: "count", line: 14), CallStackFrame(method: "main", line: 14)],
                     heap: [],
                     predict: nil),
                Step(index: 4,
                     narration: "すべての要素の処理が終わり、最終的な個数である 3 が返されます。\n出力結果: A B C Size: 3",
                     highlightLines: [14],
                     variables: [],
                     callStack: [CallStackFrame(method: "main", line: 14)],
                     heap: [],
                     predict: nil)
            ]
        )

        // MARK: - 解説: Generics 型消去
        static let goldGenericsErasure001Explanation = Explanation(
            id: "explain-gold-generics-erasure-001",
            initialCode: """
    public class Test {
        public void print(List<String> list) { ... }
        public void print(List<Integer> list) { ... } // 衝突！
    }
    """,
            steps: [
                Step(index: 1,
                     narration: "Javaコンパイラがこのコードを解析します。一見、StringとIntegerで型が違うため、オーバーロードできそうに見えます。",
                     highlightLines: [2, 3],
                     variables: [],
                     callStack: [],
                     heap: [],
                     predict: PredictPrompt(
                         question: "Javaのコンパイル後、`List<String>` と `List<Integer>` の型引数（<> の中身）はどうなるでしょうか？",
                         choices: ["そのまま残る", "消えて単なる List になる", "Object に変換される"],
                         answerIndex: 1,
                         hint: "これを『型消去(Type Erasure)』と呼び、過去のJavaとの互換性を保つための仕組みです。",
                         afterExplanation: "正解です。コンパイル後のバイトコード上では、どちらも `print(List list)` という全く同じ名前・同じ引数になってしまいます。"
                     )),
                Step(index: 2,
                     narration: "コンパイラは型消去を行います。\n1. `print(List<String> list)` → `print(List list)`\n2. `print(List<Integer> list)` → `print(List list)`\nこのように同じシグネチャが2つ存在することになり、コンパイルエラーとなります。",
                     highlightLines: [2, 3],
                     variables: [],
                     callStack: [],
                     heap: [],
                     predict: nil)
            ]
        )
    
    
    // MARK: - 解説: コンストラクタ・チェーン
        static let silverConstructorChain001Explanation = Explanation(
            id: "explain-silver-constructor-chain-001",
            initialCode: """
    class A {
        A() { System.out.print("A "); }
    }
    class B extends A {
        B() { 
            this("n");
            System.out.print("B1 "); 
        }
        B(String s) { 
            System.out.print("B2 "); 
        }
    }
    public class Test {
        public static void main(String[] args) {
            new B();
        }
    }
    """,
            steps: [
                Step(index: 1,
                     narration: "mainメソッドで `new B()` が実行されます。まずクラスBのデフォルトコンストラクタ B() が呼ばれます。",
                     highlightLines: [15, 5],
                     variables: [],
                     callStack: [CallStackFrame(method: "B()", line: 5), CallStackFrame(method: "main", line: 15)],
                     heap: [HeapObject(id: "objB", type: "B", fields: [:])],
                     predict: nil),
                Step(index: 2,
                     narration: "B() の先頭行にある `this(\"n\")` により、同じクラスの引数ありコンストラクタ B(String) が呼ばれます。B() の処理は一旦中断（保留）されます。",
                     highlightLines: [6, 9],
                     variables: [Variable(name: "s", type: "String", value: "\"n\"", scope: "B(String)")],
                     callStack: [CallStackFrame(method: "B(String)", line: 9), CallStackFrame(method: "B()", line: 6), CallStackFrame(method: "main", line: 15)],
                     heap: [HeapObject(id: "objB", type: "B", fields: [:])],
                     predict: PredictPrompt(
                         question: "ここで B(String) の処理が始まりますが、その前に「暗黙的」に行われることは何でしょうか？",
                         choices: ["親クラスAのコンストラクタ呼び出し", "変数sの初期化", "何も行われない"],
                         answerIndex: 0,
                         hint: "子クラスのコンストラクタは、冒頭で this() か super() を呼びます。何も書いていない場合は...？",
                         afterExplanation: "正解です！`this()` を書いていないコンストラクタの先頭には、自動的に `super()` が挿入されます。"
                     )),
                Step(index: 3,
                     narration: "B(String) の先頭で暗黙の `super()` が実行され、親クラスAのコンストラクタ A() が呼ばれます。ここで初めて \"A \" が出力されます。",
                     highlightLines: [2],
                     variables: [],
                     callStack: [CallStackFrame(method: "A()", line: 2), CallStackFrame(method: "B(String)", line: 9), CallStackFrame(method: "B()", line: 6), CallStackFrame(method: "main", line: 15)],
                     heap: [HeapObject(id: "objB", type: "B", fields: [:])],
                     predict: nil),
                Step(index: 4,
                     narration: "A() が完了し、B(String) に戻ります。残りの処理が実行され、\"B2 \" が出力されます。",
                     highlightLines: [10],
                     variables: [Variable(name: "s", type: "String", value: "\"n\"", scope: "B(String)")],
                     callStack: [CallStackFrame(method: "B(String)", line: 10), CallStackFrame(method: "B()", line: 6), CallStackFrame(method: "main", line: 15)],
                     heap: [HeapObject(id: "objB", type: "B", fields: [:])],
                     predict: nil),
                Step(index: 5,
                     narration: "B(String) が完了し、最初に呼び出された B() に戻ります。最後の行が実行され、\"B1 \" が出力されます。",
                     highlightLines: [7],
                     variables: [],
                     callStack: [CallStackFrame(method: "B()", line: 7), CallStackFrame(method: "main", line: 15)],
                     heap: [HeapObject(id: "objB", type: "B", fields: [:])],
                     predict: nil)
            ]
        )

        // MARK: - 解説: オーバーロード解決（優先順位）
        static let silverOverloadVarargs001Explanation = Explanation(
            id: "explain-silver-overload-varargs-001",
            initialCode: """
    public class Test {
        static void m(int... x) { System.out.print("A "); }
        static void m(long x)   { System.out.print("B "); }
        static void m(Integer x){ System.out.print("C "); }

        public static void main(String[] args) {
            int n = 5;
            m(n);
        }
    }
    """,
            steps: [
                Step(index: 1,
                     narration: "変数 n (int型) を引数にして メソッド m を呼び出そうとします。Javaコンパイラは最適なメソッドを探します。",
                     highlightLines: [8],
                     variables: [Variable(name: "n", type: "int", value: "5", scope: "main")],
                     callStack: [CallStackFrame(method: "main", line: 8)],
                     heap: [],
                     predict: PredictPrompt(
                         question: "Javaのオーバーロード解決において、int型の引数に『完全一致』がない場合、次に優先されるのはどれでしょう？",
                         choices: ["型昇格 (long)", "ボクシング (Integer)", "可変長引数 (int...)"],
                         answerIndex: 0,
                         hint: "Javaは歴史的に、基本データ型同士の変換（Widening）を最も安価で自然なものと考えます。",
                         afterExplanation: "正解です！優先度は 型昇格 ＞ ボクシング ＞ 可変長引数 の順です。"
                     )),
                Step(index: 2,
                     narration: "intからlongへの型昇格（Widening）が適用され、`m(long x)` が呼び出されます。\"B \" が出力されます。",
                     highlightLines: [3],
                     variables: [Variable(name: "x", type: "long", value: "5", scope: "m")],
                     callStack: [CallStackFrame(method: "m", line: 3), CallStackFrame(method: "main", line: 8)],
                     heap: [],
                     predict: nil)
            ]
        )
    
    // MARK: - 解説: ポリモーフィズムと静的束縛
        static let silverPolymorphism001Explanation = Explanation(
            id: "explain-silver-polymorphism-001",
            initialCode: """
    class Parent {
        int x = 10;
        static void print() { System.out.print("P1 "); }
        void show() { System.out.print("P2 "); }
    }
    class Child extends Parent {
        int x = 20;
        static void print() { System.out.print("C1 "); }
        void show() { System.out.print("C2 "); }
    }
    public class Test {
        public static void main(String[] args) {
            Parent p = new Child();
            System.out.print(p.x + " ");
            p.print();
            p.show();
        }
    }
    """,
            steps: [
                Step(index: 1,
                     narration: "Parent型の変数 p に、Childクラスのインスタンスを代入します。ヒープ上にはChildオブジェクトが生成されます。",
                     highlightLines: [13],
                     variables: [
                         Variable(name: "p", type: "Parent", value: "参照 -> childObj", scope: "main")
                     ],
                     callStack: [CallStackFrame(method: "main", line: 13)],
                     heap: [
                         HeapObject(id: "childObj", type: "Child", fields: ["Parent.x": "10", "Child.x": "20"])
                     ],
                     predict: PredictPrompt(
                         question: "次に p.x を呼び出します。pの型はParent、実体はChildです。出力される値はどちらでしょう？",
                         choices: ["10 (Parentのx)", "20 (Childのx)"],
                         answerIndex: 0,
                         hint: "フィールド（変数）は「オーバーライド」されません。コンパイラは変数の型だけを見て判断します。",
                         afterExplanation: "正解です！フィールドは「変数の型(Parent)」で決まるため、10が出力されます。"
                     )),
                Step(index: 2,
                     narration: "p.x の評価。フィールドは静的束縛（コンパイル時に変数の型で決定）されるため、Parentクラスの x (10) が選ばれます。",
                     highlightLines: [14],
                     variables: [Variable(name: "p", type: "Parent", value: "参照 -> childObj", scope: "main")],
                     callStack: [CallStackFrame(method: "main", line: 14)],
                     heap: [HeapObject(id: "childObj", type: "Child", fields: ["Parent.x": "10", "Child.x": "20"])],
                     predict: nil),
                Step(index: 3,
                     narration: "p.print() の呼び出し。staticメソッドも静的束縛です。実体がChildであっても、変数の型であるParentのprint()が呼ばれます。(P1が出力)",
                     highlightLines: [15],
                     variables: [Variable(name: "p", type: "Parent", value: "参照 -> childObj", scope: "main")],
                     callStack: [CallStackFrame(method: "main", line: 15)],
                     heap: [HeapObject(id: "childObj", type: "Child", fields: ["Parent.x": "10", "Child.x": "20"])],
                     predict: nil),
                Step(index: 4,
                     narration: "p.show() の呼び出し。インスタンスメソッドは動的束縛（実行時に実体の型で決定）されます。実体はChildなので、オーバーライドされたChildのshow()が呼ばれます。(C2が出力)",
                     highlightLines: [16, 9],
                     variables: [Variable(name: "p", type: "Parent", value: "参照 -> childObj", scope: "main")],
                     callStack: [CallStackFrame(method: "Child.show", line: 9), CallStackFrame(method: "main", line: 16)],
                     heap: [HeapObject(id: "childObj", type: "Child", fields: ["Parent.x": "10", "Child.x": "20"])],
                     predict: nil)
            ]
        )

    // MARK: - 解説: finallyとreturn
        static let silverExceptionFinally001Explanation = Explanation(
            id: "explain-silver-exception-finally-001",
            initialCode: """
    public class Test {
        public static void main(String[] args) {
            System.out.println(calc());
        }
        static int calc() {
            try {
                return 1;
            } finally {
                return 2;
            }
        }
    }
    """,
            steps: [
                Step(index: 1,
                     narration: "mainメソッドから calc() を呼び出します。",
                     highlightLines: [3],
                     variables: [],
                     callStack: [CallStackFrame(method: "main", line: 3)],
                     heap: [],
                     predict: nil),
                Step(index: 2,
                     narration: "tryブロックに入り、`return 1;` が実行されます。しかし、メソッドを終了する前に、必ずfinallyブロックを実行しなければなりません。1という値はJVMの内部に「一時保留」されます。",
                     highlightLines: [7],
                     variables: [Variable(name: "(保留中の戻り値)", type: "int", value: "1", scope: "calc")],
                     callStack: [CallStackFrame(method: "calc", line: 7), CallStackFrame(method: "main", line: 3)],
                     heap: [],
                     predict: PredictPrompt(
                         question: "次にfinallyブロックが実行されます。finally内で `return 2;` が呼ばれると、保留されていた `1` はどうなるでしょうか？",
                         choices: ["1がそのまま返る", "1が2に上書きされる", "コンパイルエラーになる"],
                         answerIndex: 1,
                         hint: "finallyブロック内の処理は、tryブロックの処理結果に対する最終決定権を持っています。",
                         afterExplanation: "正解です。finallyブロックでのreturnやthrowは、tryブロックのものをすべて上書き（握りつぶし）します。"
                     )),
                Step(index: 3,
                     narration: "finallyブロックが実行され、`return 2;` が呼ばれます。これにより、保留されていた戻り値の「1」は「2」に上書きされ、メソッドは2を返して終了します。",
                     highlightLines: [9],
                     variables: [Variable(name: "(最終的な戻り値)", type: "int", value: "2", scope: "calc")],
                     callStack: [CallStackFrame(method: "calc", line: 9), CallStackFrame(method: "main", line: 3)],
                     heap: [],
                     predict: nil),
                Step(index: 4,
                     narration: "mainメソッドに戻り、上書きされた戻り値である「2」が出力されます。",
                     highlightLines: [3],
                     variables: [],
                     callStack: [CallStackFrame(method: "main", line: 3)],
                     heap: [],
                     predict: nil)
            ]
        )

    // MARK: - 解説: String Pool
        static let silverStringPool001Explanation = Explanation(
            id: "explain-silver-string-pool-001",
            initialCode: """
    public class Test {
        public static void main(String[] args) {
            String s1 = "Java";
            String s2 = "Java";
            String s3 = new String("Java");
            
            System.out.print((s1 == s2) + " ");
            System.out.print((s1 == s3) + " ");
            System.out.print(s1.equals(s3));
        }
    }
    """,
            steps: [
                Step(index: 1,
                     narration: "文字列リテラル `\"Java\"` が評価されます。JVMはヒープ内の「String Pool（文字列プール）」に \"Java\" を作成し、s1にその参照を渡します。",
                     highlightLines: [3],
                     variables: [Variable(name: "s1", type: "String", value: "参照 -> pool_obj", scope: "main")],
                     callStack: [CallStackFrame(method: "main", line: 3)],
                     heap: [HeapObject(id: "pool_obj", type: "String (Pool)", fields: ["value": "\"Java\""])],
                     predict: nil),
                Step(index: 2,
                     narration: "再びリテラル `\"Java\"` が評価されます。JVMはプール内を検索し、すでに \"Java\" があることを発見するため、新しくオブジェクトを作らずに既存の参照をs2に渡します。",
                     highlightLines: [4],
                     variables: [
                         Variable(name: "s1", type: "String", value: "参照 -> pool_obj", scope: "main"),
                         Variable(name: "s2", type: "String", value: "参照 -> pool_obj", scope: "main")
                     ],
                     callStack: [CallStackFrame(method: "main", line: 4)],
                     heap: [HeapObject(id: "pool_obj", type: "String (Pool)", fields: ["value": "\"Java\""])],
                     predict: nil),
                Step(index: 3,
                     narration: "`new String(\"Java\")` が実行されます。newキーワードはプールを無視して、ヒープの通常領域に「強制的に」新しいインスタンスを作成します。",
                     highlightLines: [5],
                     variables: [
                         Variable(name: "s1", type: "String", value: "参照 -> pool_obj", scope: "main"),
                         Variable(name: "s2", type: "String", value: "参照 -> pool_obj", scope: "main"),
                         Variable(name: "s3", type: "String", value: "参照 -> heap_obj", scope: "main")
                     ],
                     callStack: [CallStackFrame(method: "main", line: 5)],
                     heap: [
                         HeapObject(id: "pool_obj", type: "String (Pool)", fields: ["value": "\"Java\""]),
                         HeapObject(id: "heap_obj", type: "String (Heap)", fields: ["value": "\"Java\""])
                     ],
                     predict: PredictPrompt(
                         question: "s1とs3を `==` で比較するとどうなるでしょうか？",
                         choices: ["true (中身が同じだから)", "false (指しているオブジェクトが違うから)"],
                         answerIndex: 1,
                         hint: "`==` 演算子は、参照先（ID）が完全に一致しているかだけをチェックします。",
                         afterExplanation: "正解です！s1はpool_obj、s3はheap_objを指しているため `==` はfalseになります。"
                     )),
                Step(index: 4,
                     narration: "参照の比較と値の比較を行います。`s1 == s2` は同じオブジェクトを指すので true。`s1 == s3` は別のオブジェクトなので false。`s1.equals(s3)` は文字の内容が同じなので true になります。",
                     highlightLines: [7, 8, 9],
                     variables: [
                         Variable(name: "s1", type: "String", value: "参照 -> pool_obj", scope: "main"),
                         Variable(name: "s2", type: "String", value: "参照 -> pool_obj", scope: "main"),
                         Variable(name: "s3", type: "String", value: "参照 -> heap_obj", scope: "main")
                     ],
                     callStack: [CallStackFrame(method: "main", line: 9)],
                     heap: [
                         HeapObject(id: "pool_obj", type: "String (Pool)", fields: ["value": "\"Java\""]),
                         HeapObject(id: "heap_obj", type: "String (Heap)", fields: ["value": "\"Java\""])
                     ],
                     predict: nil)
            ]
        )

    static let silverDataTypesPassByValueExplanation = Explanation(
            id: "explain-silver-datatypes-pass-by-value-001",
            relatedLessonId: "lesson-silver-pass-by-value", // 関連レッスンがあれば
            initialCode: """
    class Dog { String name; }
    public class Test {
        public static void main(String[] args) {
            Dog d = new Dog();
            d.name = "Pochi";
            changeName(d);
            System.out.println(d.name);
        }
        static void changeName(Dog dog) {
            dog.name = "Hachi";
            dog = new Dog();
            dog.name = "Taro";
        }
    }
    """,
            steps: [
                Step(index: 1,
                     narration: "mainメソッドから処理がスタートします。まず、新しいDogインスタンスがヒープ(メモリ)上に作られ、変数dにその「参照(リモコン)」が渡されます。名前は\"Pochi\"です。",
                     highlightLines: [4, 5],
                     variables: [
                         Variable(name: "d", type: "Dog", value: "参照 -> obj1", scope: "main")
                     ],
                     callStack: [CallStackFrame(method: "main", line: 5)],
                     heap: [
                         HeapObject(id: "obj1", type: "Dog", fields: ["name": "\"Pochi\""])
                     ],
                     predict: nil),
                     
                Step(index: 2,
                     narration: "changeNameメソッドを呼び出します。ここが最大のポイント！変数dの中身（参照）が「コピー」されて、引数dogに渡されます。つまり、dとdogは**同じヒープ上のインスタンス(obj1)**を指しています。",
                     highlightLines: [6, 9],
                     variables: [
                         Variable(name: "d", type: "Dog", value: "参照 -> obj1", scope: "main"),
                         Variable(name: "dog", type: "Dog", value: "参照 -> obj1", scope: "changeName")
                     ],
                     callStack: [CallStackFrame(method: "changeName", line: 9), CallStackFrame(method: "main", line: 6)],
                     heap: [
                         HeapObject(id: "obj1", type: "Dog", fields: ["name": "\"Pochi\""])
                     ],
                     predict: PredictPrompt(
                         question: "次の行（dog.name = \"Hachi\";）を実行すると、mainメソッドのd.nameも影響を受けるでしょうか？",
                         choices: ["影響を受ける（Hachiになる）", "影響を受けない（Pochiのまま）"],
                         answerIndex: 0,
                         hint: "dとdogは今、ヒープ上の同じオブジェクトを指しています。",
                         afterExplanation: "正解！同じインスタンスを操作しているので、書き換えは共有されます。"
                     )),
                     
                Step(index: 3,
                     narration: "dog.name を \"Hachi\" に変更しました。dとdogは同じオブジェクト(obj1)を指しているため、ヒープ上のobj1の中身が書き換わります。",
                     highlightLines: [10],
                     variables: [
                         Variable(name: "d", type: "Dog", value: "参照 -> obj1", scope: "main"),
                         Variable(name: "dog", type: "Dog", value: "参照 -> obj1", scope: "changeName")
                     ],
                     callStack: [CallStackFrame(method: "changeName", line: 10), CallStackFrame(method: "main", line: 6)],
                     heap: [
                         HeapObject(id: "obj1", type: "Dog", fields: ["name": "\"Hachi\""])
                     ],
                     predict: nil),
                     
                Step(index: 4,
                     narration: "次に、ローカル変数dogに新しいインスタンス(obj2)を代入し、名前を\"Taro\"にしました。ここでdogの参照先は変わりますが、**mainメソッドのdの参照先はobj1のまま**です。",
                     highlightLines: [11, 12],
                     variables: [
                         Variable(name: "d", type: "Dog", value: "参照 -> obj1", scope: "main"),
                         Variable(name: "dog", type: "Dog", value: "参照 -> obj2", scope: "changeName")
                     ],
                     callStack: [CallStackFrame(method: "changeName", line: 12), CallStackFrame(method: "main", line: 6)],
                     heap: [
                         HeapObject(id: "obj1", type: "Dog", fields: ["name": "\"Hachi\""]),
                         HeapObject(id: "obj2", type: "Dog", fields: ["name": "\"Taro\""])
                     ],
                     predict: nil),
                     
                Step(index: 5,
                     narration: "changeNameメソッドが終了し、mainメソッドに戻ってきました。変数dが指しているのは変わらずobj1です。obj1の名前は先ほど\"Hachi\"に書き換えられているため、\"Hachi\"が出力されます。",
                     highlightLines: [7],
                     variables: [
                         Variable(name: "d", type: "Dog", value: "参照 -> obj1", scope: "main")
                     ],
                     callStack: [CallStackFrame(method: "main", line: 7)],
                     heap: [
                         HeapObject(id: "obj1", type: "Dog", fields: ["name": "\"Hachi\""]),
                         HeapObject(id: "obj2", type: "Dog", fields: ["name": "\"Taro\""]) // 実際はこの後GC対象になります
                     ],
                     predict: nil)
            ]
        )
    
    // MARK: - Silver: オーバーロード解決

    static let silverOverload001 = Explanation(
        id: "explain-silver-overload-001",
        relatedLessonId: "lesson-overload-resolution",
        initialCode: """
public class Test {
    static void print(int x) {
        System.out.println("int: " + x);
    }
    static void print(long x) {
        System.out.println("long: " + x);
    }
    public static void main(String[] args) {
        print(5);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "mainメソッドから実行開始。JVMはmainをコールスタックに積みます。",
                 highlightLines: [8],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 8)],
                 heap: [], predict: nil),

            Step(index: 1,
                 narration: "print(5) を呼び出します。引数 5 はint型のリテラルです。Javaはここでオーバーロード解決を行い、どちらのprint()を呼ぶか決定します。",
                 highlightLines: [9],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 9)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "呼び出されるのはどちら？",
                    choices: ["print(int x)", "print(long x)"],
                    answerIndex: 0,
                    hint: "5はint型リテラル。完全一致 > 型昇格の優先順位",
                    afterExplanation: "print(int)と完全一致。型昇格は完全一致がない場合のみ試みられます。"
                 )),

            Step(index: 2,
                 narration: "print(int x) に入ります。引数 x に int 型の値 5 が渡されます。コールスタックにprint(int)が積まれます。",
                 highlightLines: [2],
                 variables: [Variable(name: "x", type: "int", value: "5", scope: "print(int)")],
                 callStack: [
                    CallStackFrame(method: "main", line: 9),
                    CallStackFrame(method: "print(int)", line: 2),
                 ],
                 heap: [], predict: nil),

            Step(index: 3,
                 narration: "System.out.println(\"int: \" + x) を実行。\"int: \" と x(=5) を連結して \"int: 5\" を出力します。",
                 highlightLines: [3],
                 variables: [Variable(name: "x", type: "int", value: "5", scope: "print(int)")],
                 callStack: [
                    CallStackFrame(method: "main", line: 9),
                    CallStackFrame(method: "print(int)", line: 3),
                 ],
                 heap: [], predict: nil),

            Step(index: 4,
                 narration: "print(int)が終了してコールスタックから取り除かれます。mainに戻り、プログラムが終了します。\n\n出力結果: \"int: 5\"",
                 highlightLines: [9],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 9)],
                 heap: [], predict: nil),
        ]
    )

    // MARK: - Silver: finallyのreturn

    static let silverException001 = Explanation(
        id: "explain-silver-exception-001",
        relatedLessonId: "lesson-finally-and-return",
        initialCode: """
public class Test {
    static int calc() {
        try {
            return 1;
        } finally {
            return 2;
        }
    }
    public static void main(String[] args) {
        System.out.println(calc());
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "mainからcalc()を呼び出します。",
                 highlightLines: [10],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 10)],
                 heap: [], predict: nil),

            Step(index: 1,
                 narration: "tryブロックに入ります。return 1 が実行されますが、Javaはすぐにメソッドを返しません。戻り値 1 を一時的に保留し、finallyブロックを必ず実行します。",
                 highlightLines: [4],
                 variables: [Variable(name: "保留中の戻り値", type: "int", value: "1", scope: "calc")],
                 callStack: [
                    CallStackFrame(method: "main", line: 10),
                    CallStackFrame(method: "calc", line: 4),
                 ],
                 heap: [],
                 predict: PredictPrompt(
                    question: "finallyのreturn 2が実行されると、最終的な戻り値は？",
                    choices: ["1（tryのreturnが優先）", "2（finallyのreturnが優先）", "例外が発生する"],
                    answerIndex: 1,
                    hint: "finallyはtryのreturnを上書きする",
                    afterExplanation: "finallyのreturnは保留中の戻り値1を完全に上書きします。最終的に2が返されます。"
                 )),

            Step(index: 2,
                 narration: "finallyブロックが実行されます。return 2 によって、保留中だった戻り値1が上書きされ、2がcalcの最終的な戻り値になります。",
                 highlightLines: [6],
                 variables: [Variable(name: "最終戻り値", type: "int", value: "2", scope: "calc")],
                 callStack: [
                    CallStackFrame(method: "main", line: 10),
                    CallStackFrame(method: "calc", line: 6),
                 ],
                 heap: [], predict: nil),

            Step(index: 3,
                 narration: "calc()が2を返してmainに戻ります。System.out.println(2)が実行され、\"2\" が出力されます。",
                 highlightLines: [10],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 10)],
                 heap: [], predict: nil),
        ]
    )

    // MARK: - Gold: ジェネリクス（上限境界ワイルドカード）

    static let goldGenerics001 = Explanation(
        id: "explain-gold-generics-001",
        relatedLessonId: "lesson-bounded-wildcards",
        initialCode: """
import java.util.*;

public class Test {
    static double sum(List<? extends Number> list) {
        double total = 0;
        for (Number n : list) {
            total += n.doubleValue();
        }
        return total;
    }
    public static void main(String[] args) {
        List<Integer> ints = Arrays.asList(1, 2, 3);
        System.out.println(sum(ints));
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "mainメソッドから実行開始。Arrays.asList(1, 2, 3) で List<Integer> を作成します。",
                 highlightLines: [12],
                 variables: [Variable(name: "ints", type: "List<Integer>", value: "[1, 2, 3]", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 12)],
                 heap: [], predict: nil),

            Step(index: 1,
                 narration: "sum(ints) を呼び出します。引数は List<Integer> ですが、メソッドは List<? extends Number> を受け取ります。型システムはこれを許可するでしょうか？",
                 highlightLines: [13],
                 variables: [Variable(name: "ints", type: "List<Integer>", value: "[1, 2, 3]", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 13)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "List<Integer> を List<? extends Number> として渡せる？",
                    choices: ["渡せる（IntegerはNumberのサブタイプ）", "渡せない（型不一致）"],
                    answerIndex: 0,
                    hint: "<? extends Number> は Number のサブタイプを受け入れる",
                    afterExplanation: "上限境界ワイルドカード <? extends Number> は、Number またはそのサブタイプ（Integer, Long, Double等）のリストを受け取れます。"
                 )),

            Step(index: 2,
                 narration: "sum メソッド内に入ります。total が 0.0 で初期化されます。",
                 highlightLines: [5],
                 variables: [
                    Variable(name: "list", type: "List<? ext Number>", value: "[1, 2, 3]", scope: "sum"),
                    Variable(name: "total", type: "double", value: "0.0", scope: "sum"),
                 ],
                 callStack: [
                    CallStackFrame(method: "main", line: 13),
                    CallStackFrame(method: "sum", line: 5),
                 ],
                 heap: [], predict: nil),

            Step(index: 3,
                 narration: "for-eachループ1回目。n = 1（Integer→Numberとして扱う）。doubleValue() で 1.0 に変換して total に加算します。",
                 highlightLines: [7],
                 variables: [
                    Variable(name: "list", type: "List<? ext Number>", value: "[1, 2, 3]", scope: "sum"),
                    Variable(name: "n", type: "Number", value: "1", scope: "sum"),
                    Variable(name: "total", type: "double", value: "1.0", scope: "sum"),
                 ],
                 callStack: [
                    CallStackFrame(method: "main", line: 13),
                    CallStackFrame(method: "sum", line: 7),
                 ],
                 heap: [], predict: nil),

            Step(index: 4,
                 narration: "ループ2回目。n = 2、total = 1.0 + 2.0 = 3.0",
                 highlightLines: [7],
                 variables: [
                    Variable(name: "list", type: "List<? ext Number>", value: "[1, 2, 3]", scope: "sum"),
                    Variable(name: "n", type: "Number", value: "2", scope: "sum"),
                    Variable(name: "total", type: "double", value: "3.0", scope: "sum"),
                 ],
                 callStack: [
                    CallStackFrame(method: "main", line: 13),
                    CallStackFrame(method: "sum", line: 7),
                 ],
                 heap: [], predict: nil),

            Step(index: 5,
                 narration: "ループ3回目。n = 3、total = 3.0 + 3.0 = 6.0",
                 highlightLines: [7],
                 variables: [
                    Variable(name: "list", type: "List<? ext Number>", value: "[1, 2, 3]", scope: "sum"),
                    Variable(name: "n", type: "Number", value: "3", scope: "sum"),
                    Variable(name: "total", type: "double", value: "6.0", scope: "sum"),
                 ],
                 callStack: [
                    CallStackFrame(method: "main", line: 13),
                    CallStackFrame(method: "sum", line: 7),
                 ],
                 heap: [], predict: nil),

            Step(index: 6,
                 narration: "sumが 6.0 を返してmainに戻ります。System.out.println(6.0) が実行され、\"6.0\" が出力されます。\n\n出力結果: \"6.0\"",
                 highlightLines: [13],
                 variables: [Variable(name: "ints", type: "List<Integer>", value: "[1, 2, 3]", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 13)],
                 heap: [], predict: nil),
        ]
    )

    // MARK: - Silver: 文字列比較

    static let silverString001 = Explanation(
        id: "explain-silver-string-001",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        String a = "hello";
        String b = "hello";
        String c = new String("hello");
        System.out.println((a == b) + " " + (a == c));
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "main開始。String a = \"hello\" でリテラル \"hello\" が文字列定数プールに格納され、aはその参照を保持します。",
                 highlightLines: [3],
                 variables: [Variable(name: "a", type: "String", value: "\"hello\" (pool@1)", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 3)],
                 heap: [Explanation.HeapObject(id: "pool@1", type: "String", fields: ["value": "\"hello\""])],
                 predict: nil),

            Step(index: 1,
                 narration: "String b = \"hello\" を実行。同じリテラルなので、新しいオブジェクトは作られず、bはプール内の同じ参照を共有します。",
                 highlightLines: [4],
                 variables: [
                    Variable(name: "a", type: "String", value: "\"hello\" (pool@1)", scope: "main"),
                    Variable(name: "b", type: "String", value: "\"hello\" (pool@1)", scope: "main"),
                 ],
                 callStack: [CallStackFrame(method: "main", line: 4)],
                 heap: [Explanation.HeapObject(id: "pool@1", type: "String", fields: ["value": "\"hello\""])],
                 predict: PredictPrompt(
                    question: "a == b の結果は？",
                    choices: ["true（同じ参照）", "false（別オブジェクト）"],
                    answerIndex: 0,
                    hint: "リテラルはプールで共有される",
                    afterExplanation: "同じリテラルはプール内で共有されるため、a と b は同じ参照を持ちます。a == b は true。"
                 )),

            Step(index: 2,
                 narration: "String c = new String(\"hello\") を実行。new はヒープ上に新しい String オブジェクトを生成します。プール内の \"hello\" とは別の参照です。",
                 highlightLines: [5],
                 variables: [
                    Variable(name: "a", type: "String", value: "\"hello\" (pool@1)", scope: "main"),
                    Variable(name: "b", type: "String", value: "\"hello\" (pool@1)", scope: "main"),
                    Variable(name: "c", type: "String", value: "\"hello\" (heap@2)", scope: "main"),
                 ],
                 callStack: [CallStackFrame(method: "main", line: 5)],
                 heap: [
                    Explanation.HeapObject(id: "pool@1", type: "String", fields: ["value": "\"hello\""]),
                    Explanation.HeapObject(id: "heap@2", type: "String", fields: ["value": "\"hello\""]),
                 ],
                 predict: PredictPrompt(
                    question: "a == c の結果は？",
                    choices: ["true（中身が同じ）", "false（別オブジェクト）"],
                    answerIndex: 1,
                    hint: "== は参照比較。new で別オブジェクト",
                    afterExplanation: "== は参照比較なので、別オブジェクトの a と c は false。中身を比較するなら equals() を使う。"
                 )),

            Step(index: 3,
                 narration: "println で結果を出力。a==b は true、a==c は false、これらが連結されて \"true false\" が出力されます。",
                 highlightLines: [6],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [], predict: nil),
        ]
    )

    // MARK: - Silver: オートボクシングとIntegerキャッシュ

    static let silverAutoboxing001 = Explanation(
        id: "explain-silver-autoboxing-001",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        Integer a = 100;
        Integer b = 100;
        Integer c = 200;
        Integer d = 200;
        System.out.println((a == b) + " " + (c == d));
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "Integer a = 100 で int リテラルが Integer.valueOf(100) によりオートボクシングされます。100 は -128〜127 のキャッシュ範囲内のため、JVM 内部のキャッシュから既存のオブジェクトが返されます。",
                 highlightLines: [3],
                 variables: [Variable(name: "a", type: "Integer", value: "100 (cache@100)", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 3)],
                 heap: [], predict: nil),

            Step(index: 1,
                 narration: "Integer b = 100 も同じ valueOf(100) を呼び出し、同じキャッシュオブジェクトを返します。a と b は同じ参照。",
                 highlightLines: [4],
                 variables: [
                    Variable(name: "a", type: "Integer", value: "100 (cache@100)", scope: "main"),
                    Variable(name: "b", type: "Integer", value: "100 (cache@100)", scope: "main"),
                 ],
                 callStack: [CallStackFrame(method: "main", line: 4)],
                 heap: [], predict: nil),

            Step(index: 2,
                 narration: "Integer c = 200 を実行。200 はキャッシュ範囲外のため、毎回 new Integer(200) 相当の新しいオブジェクトが作られます。",
                 highlightLines: [5],
                 variables: [
                    Variable(name: "a", type: "Integer", value: "100 (cache@100)", scope: "main"),
                    Variable(name: "b", type: "Integer", value: "100 (cache@100)", scope: "main"),
                    Variable(name: "c", type: "Integer", value: "200 (heap@x)", scope: "main"),
                 ],
                 callStack: [CallStackFrame(method: "main", line: 5)],
                 heap: [], predict: nil),

            Step(index: 3,
                 narration: "Integer d = 200 も同様に、別の新しい Integer オブジェクトを作成します。",
                 highlightLines: [6],
                 variables: [
                    Variable(name: "c", type: "Integer", value: "200 (heap@x)", scope: "main"),
                    Variable(name: "d", type: "Integer", value: "200 (heap@y)", scope: "main"),
                 ],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "(a == b) と (c == d) はそれぞれ何になる？",
                    choices: ["true / true", "true / false", "false / true", "false / false"],
                    answerIndex: 1,
                    hint: "Integerキャッシュの範囲は -128〜127",
                    afterExplanation: "100 はキャッシュ共有で同じ参照（true）、200 はキャッシュ範囲外で別オブジェクト（false）。出力は \"true false\"。"
                 )),

            Step(index: 4,
                 narration: "println で \"true false\" が出力されます。Wrapper同士の == は危険。値比較は必ず equals() を使う。",
                 highlightLines: [7],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 7)],
                 heap: [], predict: nil),
        ]
    )

    // MARK: - Silver: switchフォールスルー

    static let silverSwitch001 = Explanation(
        id: "explain-silver-switch-001",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        int x = 2;
        switch (x) {
            case 1: System.out.print("A");
            case 2: System.out.print("B");
            case 3: System.out.print("C");
                break;
            case 4: System.out.print("D");
        }
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "x = 2 で switch (x) を評価します。x の値 2 にマッチする case 2: から実行を開始します。",
                 highlightLines: [3, 4],
                 variables: [Variable(name: "x", type: "int", value: "2", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 4)],
                 heap: [], predict: nil),

            Step(index: 1,
                 narration: "case 2: にジャンプ。System.out.print(\"B\") で \"B\" を出力します。",
                 highlightLines: [6],
                 variables: [Variable(name: "x", type: "int", value: "2", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "case 2: の末尾には break がない。次に何が起こる？",
                    choices: ["switch を抜けて終了", "case 3: に流れ落ちる（フォールスルー）", "コンパイルエラー"],
                    answerIndex: 1,
                    hint: "switch文は break で明示的に抜けない限り続く",
                    afterExplanation: "break がない case はそのまま次の case の処理に流れ込みます。これを「フォールスルー」と呼びます。"
                 )),

            Step(index: 2,
                 narration: "break がないため case 3: に流れ落ちます。System.out.print(\"C\") で \"C\" を出力します。",
                 highlightLines: [7],
                 variables: [Variable(name: "x", type: "int", value: "2", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 7)],
                 heap: [], predict: nil),

            Step(index: 3,
                 narration: "case 3: の break; に到達。switch ブロックを抜けます。case 4: には到達しません。\n\n出力結果: \"BC\"",
                 highlightLines: [8],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 8)],
                 heap: [], predict: nil),
        ]
    )

    // MARK: - Gold: Stream API

    static let goldStream001 = Explanation(
        id: "explain-gold-stream-001",
        initialCode: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        List<Integer> nums = List.of(1, 2, 3, 4, 5);
        int result = nums.stream()
            .filter(n -> n % 2 == 0)
            .mapToInt(Integer::intValue)
            .sum();
        System.out.println(result);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "List.of(1, 2, 3, 4, 5) で不変リストを生成。nums がその参照を保持します。",
                 highlightLines: [6],
                 variables: [Variable(name: "nums", type: "List<Integer>", value: "[1, 2, 3, 4, 5]", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [], predict: nil),

            Step(index: 1,
                 narration: "nums.stream() で Stream<Integer> を作成。この時点では何も計算されません（中間操作は遅延評価）。",
                 highlightLines: [7],
                 variables: [Variable(name: "nums", type: "List<Integer>", value: "[1, 2, 3, 4, 5]", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 7)],
                 heap: [], predict: nil),

            Step(index: 2,
                 narration: ".filter(n -> n % 2 == 0) は中間操作。条件「nが偶数」を満たす要素だけ通すパイプラインを構築しますが、まだ実行されません。",
                 highlightLines: [8],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 8)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "filter はこの時点で実行される？",
                    choices: ["される（即評価）", "されない（遅延評価）"],
                    answerIndex: 1,
                    hint: "Streamは終端操作が呼ばれるまで動かない",
                    afterExplanation: "中間操作（filter, map等）はパイプラインを組み立てるだけ。終端操作（sum, collect等）が呼ばれて初めて実行されます。"
                 )),

            Step(index: 3,
                 narration: ".mapToInt(Integer::intValue) で Stream<Integer> を IntStream に変換するパイプラインを追加。これも中間操作で遅延評価。",
                 highlightLines: [9],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 9)],
                 heap: [], predict: nil),

            Step(index: 4,
                 narration: ".sum() は終端操作。ここで初めてパイプライン全体が実行されます。各要素について filter→mapToInt→加算が順に行われます。",
                 highlightLines: [10],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 10)],
                 heap: [], predict: nil),

            Step(index: 5,
                 narration: "実行: 1（奇数→除外）、2（偶数→2）、3（除外）、4（4）、5（除外）。残った [2, 4] を sum して 6 になります。",
                 highlightLines: [10],
                 variables: [Variable(name: "result", type: "int", value: "6", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 10)],
                 heap: [], predict: nil),

            Step(index: 6,
                 narration: "println(6) で \"6\" が出力されます。\n\n出力結果: \"6\"",
                 highlightLines: [11],
                 variables: [Variable(name: "result", type: "int", value: "6", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 11)],
                 heap: [], predict: nil),
        ]
    )

    // MARK: - Gold: Optional

    static let goldOptional001 = Explanation(
        id: "explain-gold-optional-001",
        initialCode: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        String s = null;
        String result = Optional.ofNullable(s)
            .map(String::toUpperCase)
            .orElse("DEFAULT");
        System.out.println(result);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "String s = null で s に null を代入します。",
                 highlightLines: [5],
                 variables: [Variable(name: "s", type: "String", value: "null", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 5)],
                 heap: [], predict: nil),

            Step(index: 1,
                 narration: "Optional.ofNullable(s) を呼び出します。s は null ですが、ofNullable は例外を投げず、空の Optional を返します（of(null) なら NPE）。",
                 highlightLines: [6],
                 variables: [Variable(name: "s", type: "String", value: "null", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "Optional.of(null) と Optional.ofNullable(null) の違いは？",
                    choices: ["どちらも空Optionalを返す", "of(null)はNPE、ofNullable(null)は空Optional", "どちらもNPE"],
                    answerIndex: 1,
                    hint: "of は null を許容しない",
                    afterExplanation: "Optional.of(null) は NullPointerException を投げます。null の可能性がある値には ofNullable() を使う。"
                 )),

            Step(index: 2,
                 narration: ".map(String::toUpperCase) を呼び出し。Optional が空の場合、map は何もせず空の Optional を返します（関数は呼ばれない）。",
                 highlightLines: [7],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 7)],
                 heap: [], predict: nil),

            Step(index: 3,
                 narration: ".orElse(\"DEFAULT\") を呼び出し。Optional が空なので、引数の \"DEFAULT\" がそのまま返されます。result に \"DEFAULT\" が代入されます。",
                 highlightLines: [8],
                 variables: [Variable(name: "result", type: "String", value: "\"DEFAULT\"", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 8)],
                 heap: [], predict: nil),

            Step(index: 4,
                 narration: "println で \"DEFAULT\" が出力されます。Optional + map + orElse の組み合わせで、null チェックなしに安全にデフォルト値を返せます。\n\n出力結果: \"DEFAULT\"",
                 highlightLines: [9],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 9)],
                 heap: [], predict: nil),
        ]
    )

    // MARK: - Silver: 複合代入と暗黙キャスト

    static let silverDataTypesPromotion003Explanation = Explanation(
        id: "explain-silver-data-types-promotion-003",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        byte b = 127;
        b += 1;
        // b = b + 1;
        System.out.println(b);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "`byte b = 127` で、byteの最大値(127)を変数bに代入します。",
                 highlightLines: [3],
                 variables: [Variable(name: "b", type: "byte", value: "127", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 3)],
                 heap: [],
                 predict: nil),

            Step(index: 1,
                 narration: "`b += 1` を評価します。複合代入は `b = (byte)(b + 1)` 相当で扱われるため、コンパイルエラーにはなりません。",
                 highlightLines: [4],
                 variables: [Variable(name: "b", type: "byte", value: "計算前: 127", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 4)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "127に1を足した結果をbyteに収めるとどうなる？",
                    choices: ["128のまま保持される", "-128になる", "実行時例外になる"],
                    answerIndex: 1,
                    hint: "byteは8bitの2の補数で表現されます。",
                    afterExplanation: "正解です。127の次は桁あふれして-128に循環します。"
                 )),

            Step(index: 2,
                 narration: "`127 + 1` はint演算で128になります。その後byteへ絞り込まれ、ビットが切り詰められて `-128` になります。",
                 highlightLines: [4],
                 variables: [Variable(name: "b", type: "byte", value: "-128", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 4)],
                 heap: [],
                 predict: nil),

            Step(index: 3,
                 narration: "`System.out.println(b)` が実行され、`-128` を出力します。なおコメントアウトされた `b = b + 1;` を有効化すると、右辺がintのためコンパイルエラーになります。",
                 highlightLines: [6],
                 variables: [Variable(name: "b", type: "byte", value: "-128", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: ラベル付きbreakの到達点

    static let silverControlFlow003Explanation = Explanation(
        id: "explain-silver-control-flow-003",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        outer:
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                if (i == 1 && j == 1) break outer;
                System.out.print(i + "" + j + " ");
            }
        }
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "実行開始後、`i=0` の内側ループで `00 01 02` が順に出力されます。",
                 highlightLines: [4, 5, 6, 7],
                 variables: [
                    Variable(name: "i", type: "int", value: "0", scope: "main"),
                    Variable(name: "j", type: "int", value: "0 -> 1 -> 2", scope: "main")
                 ],
                 callStack: [CallStackFrame(method: "main", line: 7)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "`i=1, j=0` では条件が偽なので `10` を出力します。次に `j=1` で条件 `i == 1 && j == 1` が真になります。",
                 highlightLines: [6, 7],
                 variables: [
                    Variable(name: "i", type: "int", value: "1", scope: "main"),
                    Variable(name: "j", type: "int", value: "0 -> 1", scope: "main")
                 ],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "`break outer;` が実行されたら、どこまでループを抜ける？",
                    choices: ["内側ループだけ", "外側ループごと終了", "ループは継続する"],
                    answerIndex: 1,
                    hint: "ラベル `outer` は外側for文についています。",
                    afterExplanation: "正解です。ラベル付きbreakは指定ラベルの文を終了させます。"
                 )),
            Step(index: 2,
                 narration: "`break outer;` により外側ループまで即終了するため、その後の `12` や `20` 以降は出力されません。最終出力は `00 01 02 10` です。",
                 highlightLines: [6],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: static初期化順序

    static let silverClasses003Explanation = Explanation(
        id: "explain-silver-classes-003",
        initialCode: """
public class Test {
    static int a = init("A");
    static { init("B"); }
    static int c = init("C");

    static int init(String s) {
        System.out.print(s + " ");
        return 0;
    }

    public static void main(String[] args) {
        System.out.print("M");
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "main実行前にクラス初期化が走り、最初の要素 `static int a = init(\"A\")` が実行されます。",
                 highlightLines: [2],
                 variables: [Variable(name: "a", type: "int", value: "0", scope: "class")],
                 callStack: [CallStackFrame(method: "init", line: 7)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "次に `static { init(\"B\"); }`、続いて `static int c = init(\"C\")` が宣言順で実行されます。",
                 highlightLines: [3, 4],
                 variables: [Variable(name: "c", type: "int", value: "0", scope: "class")],
                 callStack: [CallStackFrame(method: "init", line: 7)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "static初期化が終わった後に最後に実行されるのは？",
                    choices: ["mainメソッド", "もう何も実行されない", "initがもう一度自動実行される"],
                    answerIndex: 0,
                    hint: "エントリーポイントは `public static void main` です。",
                    afterExplanation: "その通りです。クラス初期化完了後にmainへ進みます。"
                 )),
            Step(index: 2,
                 narration: "最後にmainの `System.out.print(\"M\")` が実行されるため、出力は `A B C M` となります。",
                 highlightLines: [12],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 12)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: 例外とreturnの優先順位

    static let silverException003Explanation = Explanation(
        id: "explain-silver-exception-003",
        initialCode: """
public class Test {
    static int f() {
        try {
            return 1;
        } finally {
            return 2;
        }
    }
    public static void main(String[] args) {
        System.out.println(f());
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "`f()` 内のtryで `return 1` が評価され、戻り処理に入ろうとします。",
                 highlightLines: [4],
                 variables: [Variable(name: "return(from try)", type: "int", value: "1", scope: "f")],
                 callStack: [CallStackFrame(method: "f", line: 4)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "ただし戻る前にfinallyが必ず実行され、`return 2` が評価されます。これによりtry側の戻り値は上書きされます。",
                 highlightLines: [6],
                 variables: [Variable(name: "return(final)", type: "int", value: "2", scope: "f")],
                 callStack: [CallStackFrame(method: "f", line: 6)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "tryとfinallyの両方にreturnがあると、最終的に使われるのは？",
                    choices: ["tryのreturn", "finallyのreturn", "コンパイルエラー"],
                    answerIndex: 1,
                    hint: "finallyは必ず実行され、制御を変更できます。",
                    afterExplanation: "正解です。finallyのreturnが最終結果になります。"
                 )),
            Step(index: 2,
                 narration: "`main` で `System.out.println(f())` が `2` を出力します。",
                 highlightLines: [10],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 10)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: List.removeのオーバーロード

    static let silverCollections002Explanation = Explanation(
        id: "explain-silver-collections-002",
        initialCode: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<Integer> list = new ArrayList<>(Arrays.asList(10, 20, 30));
        list.remove(1);
        list.remove(Integer.valueOf(30));
        System.out.println(list);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "初期状態のlistは `[10, 20, 30]` です。",
                 highlightLines: [5],
                 variables: [Variable(name: "list", type: "List<Integer>", value: "[10, 20, 30]", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 5)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "`list.remove(1)` は `remove(int index)` が選ばれ、index 1 の要素20を削除して `[10, 30]` になります。",
                 highlightLines: [6],
                 variables: [Variable(name: "list", type: "List<Integer>", value: "[10, 30]", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "次の `remove(Integer.valueOf(30))` は何を意味する？",
                    choices: ["index 30 を削除", "値 30 の要素を削除", "曖昧でコンパイルエラー"],
                    answerIndex: 1,
                    hint: "Integerオブジェクトを渡している点に注目。",
                    afterExplanation: "その通りです。`remove(Object)` が呼ばれ、値一致で削除されます。"
                 )),
            Step(index: 2,
                 narration: "2回目は `remove(Object)` として値30を削除するため、最終的に `[10]` が出力されます。",
                 highlightLines: [7, 8],
                 variables: [Variable(name: "list", type: "List<Integer>", value: "[10]", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 8)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: オーバーロード解決（型昇格 vs ボクシング）

    static let silverOverload003Explanation = Explanation(
        id: "explain-silver-overload-003",
        initialCode: """
public class Test {
    static void m(long x)    { System.out.print("long "); }
    static void m(Integer x) { System.out.print("Integer "); }

    public static void main(String[] args) {
        m(10);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "`m(10)` の `10` は `int` リテラルです。コンパイラは適用可能なオーバーロード候補を比較します。",
                 highlightLines: [6],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "`m(long)` は型昇格で適用可能、`m(Integer)` はボクシングで適用可能です。ここで優先されるのは型昇格です。",
                 highlightLines: [2, 3, 6],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "オーバーロード解決で優先されるのは？",
                    choices: ["ボクシング", "型昇格(widening)", "常に曖昧エラー"],
                    answerIndex: 1,
                    hint: "primitive同士の通常変換が先です。",
                    afterExplanation: "正解です。`m(long)` が選ばれます。"
                 )),
            Step(index: 2,
                 narration: "最終的に `m(long)` が呼ばれ、`long` が出力されます。",
                 highlightLines: [2],
                 variables: [],
                 callStack: [CallStackFrame(method: "m(long)", line: 2), CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: Stringの不変性

    static let silverString002Explanation = Explanation(
        id: "explain-silver-string-002",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        String s = "Java";
        s.concat("SE");
        System.out.println(s);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "`s` は `\"Java\"` を参照します。",
                 highlightLines: [3],
                 variables: [Variable(name: "s", type: "String", value: "\"Java\"", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 3)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "`s.concat(\"SE\")` は新しいString `\"JavaSE\"` を返しますが、戻り値を受け取っていないため `s` は変化しません。",
                 highlightLines: [4],
                 variables: [Variable(name: "s", type: "String", value: "\"Java\" (変更なし)", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 4)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "sをJavaSEにしたい場合に必要な書き方は？",
                    choices: ["s.concat(\"SE\"); のままでよい", "s = s.concat(\"SE\"); が必要", "Stringは変更不可なので不可能"],
                    answerIndex: 1,
                    hint: "concatは新しい値を返すメソッドです。",
                    afterExplanation: "その通りです。戻り値を再代入する必要があります。"
                 )),
            Step(index: 2,
                 narration: "`println(s)` は `Java` を出力します。",
                 highlightLines: [5],
                 variables: [Variable(name: "s", type: "String", value: "\"Java\"", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 5)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: フィールド隠蔽とメソッド呼び出し

    static let silverInheritance002Explanation = Explanation(
        id: "explain-silver-inheritance-002",
        initialCode: """
class Parent {
    int x = 1;
    int getX() { return x; }
}
class Child extends Parent {
    int x = 2;
    @Override
    int getX() { return x; }
}
public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        System.out.print(p.x + " ");
        System.out.print(p.getX());
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "`Parent p = new Child();` で、参照型はParent・実体はChildになります。",
                 highlightLines: [12],
                 variables: [Variable(name: "p", type: "Parent", value: "参照 -> Childインスタンス", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 12)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "`p.x` はフィールド参照なので宣言型Parent側の `x=1` が使われます。",
                 highlightLines: [13],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 13)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "次の `p.getX()` はどちらが呼ばれる？",
                    choices: ["Parent.getX()", "Child.getX()", "曖昧でエラー"],
                    answerIndex: 1,
                    hint: "インスタンスメソッドは動的束縛です。",
                    afterExplanation: "正解です。実体がChildなのでChild.getX()が呼ばれます。"
                 )),
            Step(index: 2,
                 narration: "`p.getX()` はオーバーライド先のChild版が実行され、Child側 `x=2` を返します。出力は `1 2` です。",
                 highlightLines: [14],
                 variables: [],
                 callStack: [CallStackFrame(method: "Child.getX", line: 8), CallStackFrame(method: "main", line: 14)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: switch式のdefault到達

    static let silverJavaBasics003Explanation = Explanation(
        id: "explain-silver-java-basics-003",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        int n = 2;
        switch (n) {
            case 1:
                System.out.print("A ");
                break;
            default:
                System.out.print("D ");
            case 2:
                System.out.print("B ");
        }
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "`n` は2なので、switchは `case 2` ラベルへ直接ジャンプします。",
                 highlightLines: [3, 10],
                 variables: [Variable(name: "n", type: "int", value: "2", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 4)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "`case 2` から `System.out.print(\"B \")` が実行されます。この後はswitch末尾なので終了です。",
                 highlightLines: [10, 11],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 11)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "このケースでdefaultは実行される？",
                    choices: ["実行される", "実行されない"],
                    answerIndex: 1,
                    hint: "defaultは『一致ケースがない時の入口』です。",
                    afterExplanation: "その通りです。一致するcaseがあるのでdefaultには入りません。"
                 )),
            Step(index: 2,
                 narration: "最終出力は `B` です。",
                 highlightLines: [11],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 11)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: char演算とint昇格

    static let silverDataTypes004Explanation = Explanation(
        id: "explain-silver-data-types-004",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        char c1 = 'A';
        char c2 = 1;
        // char c3 = c1 + c2;
        int x = c1 + c2;
        System.out.println(x);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "`c1` は文字 `'A'`（数値65）、`c2` は1です。",
                 highlightLines: [3, 4],
                 variables: [
                    Variable(name: "c1", type: "char", value: "'A'(65)", scope: "main"),
                    Variable(name: "c2", type: "char", value: "1", scope: "main")
                 ],
                 callStack: [CallStackFrame(method: "main", line: 4)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "`c1 + c2` の算術演算では両方intへ昇格し、結果は66になります。",
                 highlightLines: [6],
                 variables: [Variable(name: "x", type: "int", value: "66", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "コメント行 `char c3 = c1 + c2;` を有効化すると？",
                    choices: ["コンパイル成功", "コンパイルエラー", "実行時例外"],
                    answerIndex: 1,
                    hint: "右辺はintで、charは縮小変換が必要です。",
                    afterExplanation: "正解です。明示キャストなしでは代入できません。"
                 )),
            Step(index: 2,
                 narration: "`println(x)` により 66 が出力されます。",
                 highlightLines: [7],
                 variables: [Variable(name: "x", type: "int", value: "66", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 7)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: continueのジャンプ先

    static let silverControlFlow004Explanation = Explanation(
        id: "explain-silver-control-flow-004",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        for (int i = 1; i <= 5; i++) {
            if (i % 2 == 0) continue;
            System.out.print(i + " ");
        }
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "forループは1〜5を順に処理します。",
                 highlightLines: [3],
                 variables: [Variable(name: "i", type: "int", value: "1..5", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 3)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "偶数のとき `continue` で `print` を飛ばし、次の反復へ進みます。したがって2と4は出力されません。",
                 highlightLines: [4, 5],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 4)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "出力されるのは？",
                    choices: ["1 2 3 4 5", "2 4", "1 3 5"],
                    answerIndex: 2,
                    hint: "偶数はcontinueでprintをスキップ。",
                    afterExplanation: "正解です。奇数だけが出力されます。"
                 )),
            Step(index: 2,
                 narration: "最終出力は `1 3 5` です。",
                 highlightLines: [5],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 5)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: 例外とfinallyの実行順

    static let silverException004Explanation = Explanation(
        id: "explain-silver-exception-004",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        try {
            System.out.print("T ");
            throw new RuntimeException();
        } catch (RuntimeException e) {
            System.out.print("C ");
        } finally {
            System.out.print("F ");
        }
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "tryに入り `T` を出力した後、`RuntimeException` を送出します。",
                 highlightLines: [4, 5],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 5)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "例外型が `catch (RuntimeException e)` に一致するため、catch節で `C` を出力します。",
                 highlightLines: [6, 7],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 7)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "catch実行後、finallyはどうなる？",
                    choices: ["実行されない", "実行される"],
                    answerIndex: 1,
                    hint: "finallyは通常、必ず実行されます。",
                    afterExplanation: "その通りです。最後にfinallyが実行されます。"
                 )),
            Step(index: 2,
                 narration: "finallyで `F` を出力して終了します。最終出力は `T C F` です。",
                 highlightLines: [8, 9],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 9)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: コンストラクタ連鎖

    static let silverClasses004Explanation = Explanation(
        id: "explain-silver-classes-004",
        initialCode: """
class Book {
    Book() {
        this("Java");
        System.out.print("A ");
    }
    Book(String title) {
        System.out.print("B ");
    }
}
public class Test {
    public static void main(String[] args) {
        new Book();
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "`new Book()` でBook()が呼ばれますが、先頭の `this(\"Java\")` によりBook(String)へ移動します。",
                 highlightLines: [3, 11],
                 variables: [],
                 callStack: [CallStackFrame(method: "Book()", line: 3), CallStackFrame(method: "main", line: 11)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "Book(String)で `B` が出力され、処理がBook()へ戻ります。",
                 highlightLines: [6, 7],
                 variables: [],
                 callStack: [CallStackFrame(method: "Book(String)", line: 7)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "Book()に戻った後に出力されるのは？",
                    choices: ["何も出ない", "A", "もう一度B"],
                    answerIndex: 1,
                    hint: "Book()本体の残りが実行されます。",
                    afterExplanation: "正解です。`System.out.print(\"A \")` が実行されます。"
                 )),
            Step(index: 2,
                 narration: "Book()残りで `A` を出力するため、最終出力は `B A` です。",
                 highlightLines: [4],
                 variables: [],
                 callStack: [CallStackFrame(method: "Book()", line: 4), CallStackFrame(method: "main", line: 11)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: Setの重複排除と順序

    static let silverCollections003Explanation = Explanation(
        id: "explain-silver-collections-003",
        initialCode: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Set<String> set = new LinkedHashSet<>();
        set.add("B");
        set.add("A");
        set.add("B");
        System.out.println(set);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "`LinkedHashSet` は重複を許さず、挿入順を保持するSetです。",
                 highlightLines: [5],
                 variables: [Variable(name: "set", type: "Set<String>", value: "[]", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 5)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "`B`、`A` の順に追加され `set=[B, A]` になります。3回目の `add(\"B\")` は重複のため無視されます。",
                 highlightLines: [6, 7, 8],
                 variables: [Variable(name: "set", type: "Set<String>", value: "[B, A]", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 8)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "LinkedHashSetの表示順は？",
                    choices: ["常にソート順", "挿入順", "未定義で毎回変わる"],
                    answerIndex: 1,
                    hint: "HashSetではなくLinkedHashSetです。",
                    afterExplanation: "その通りです。挿入順が維持されます。"
                 )),
            Step(index: 2,
                 narration: "最終的に `println(set)` は `[B, A]` を出力します。",
                 highlightLines: [9],
                 variables: [Variable(name: "set", type: "Set<String>", value: "[B, A]", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 9)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: 可変長引数より固定引数が優先

    static let silverOverload004Explanation = Explanation(
        id: "explain-silver-overload-004",
        initialCode: """
public class Test {
    static void call(int x)      { System.out.print("I "); }
    static void call(int... x)   { System.out.print("V "); }

    public static void main(String[] args) {
        call(1);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "`call(1)` の候補として、固定引数版とvarargs版の両方が見つかります。",
                 highlightLines: [2, 3, 6],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "オーバーロード解決では、より具体的な固定引数 `call(int)` が優先されます。",
                 highlightLines: [2],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "この場合に呼ばれるのは？",
                    choices: ["call(int)", "call(int...)", "曖昧でエラー"],
                    answerIndex: 0,
                    hint: "varargsは最後に検討される候補です。",
                    afterExplanation: "正解です。固定引数版が選択されます。"
                 )),
            Step(index: 2,
                 narration: "したがって `I` が出力されます。",
                 highlightLines: [2],
                 variables: [],
                 callStack: [CallStackFrame(method: "call(int)", line: 2), CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: StringBuilderとStringの違い

    static let silverString003Explanation = Explanation(
        id: "explain-silver-string-003",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("A");
        sb.append("B");
        String s = sb.toString();
        sb.append("C");
        System.out.println(s);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "`sb` は可変オブジェクトとして `\"A\"` から開始し、appendで `\"AB\"` になります。",
                 highlightLines: [3, 4],
                 variables: [Variable(name: "sb", type: "StringBuilder", value: "\"AB\"", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 4)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "`String s = sb.toString();` で、その時点の内容 `\"AB\"` を持つ不変Stringが作られます。",
                 highlightLines: [5],
                 variables: [Variable(name: "s", type: "String", value: "\"AB\"", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 5)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "この後 `sb.append(\"C\")` すると `s` は？",
                    choices: ["ABCになる", "ABのまま", "nullになる"],
                    answerIndex: 1,
                    hint: "Stringは不変です。",
                    afterExplanation: "その通りです。sはABのまま変わりません。"
                 )),
            Step(index: 2,
                 narration: "最終的に `println(s)` は `AB` を出力します。",
                 highlightLines: [7],
                 variables: [Variable(name: "s", type: "String", value: "\"AB\"", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 7)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: 短絡評価

    static let silverJavaBasics004Explanation = Explanation(
        id: "explain-silver-java-basics-004",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        int x = 0;
        if (x != 0 && 10 / x > 1) {
            System.out.print("T");
        } else {
            System.out.print("F");
        }
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "`x != 0` はfalseです。",
                 highlightLines: [3, 4],
                 variables: [Variable(name: "x", type: "int", value: "0", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 4)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "`&&` は短絡評価なので、左辺がfalseなら右辺 `10 / x > 1` は評価されません。",
                 highlightLines: [4],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 4)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "0除算は発生する？",
                    choices: ["発生する", "発生しない"],
                    answerIndex: 1,
                    hint: "右辺が未評価かどうかがポイントです。",
                    afterExplanation: "正解です。右辺は評価されないため例外は起こりません。"
                 )),
            Step(index: 2,
                 narration: "if条件はfalseなのでelse節が実行され、`F` が出力されます。",
                 highlightLines: [6, 7],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 7)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: 配列参照の再代入

    static let silverArray003Explanation = Explanation(
        id: "explain-silver-array-003",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        int[] a = {1, 2};
        int[] b = a;
        b[0] = 9;
        b = new int[]{3, 4};
        System.out.print(a[0] + " ");
        System.out.print(b[0]);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "`b = a` により、aとbは同じ配列 `[1, 2]` を参照します。",
                 highlightLines: [3, 4],
                 variables: [Variable(name: "a", type: "int[]", value: "ref#1", scope: "main"), Variable(name: "b", type: "int[]", value: "ref#1", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 4)],
                 heap: [HeapObject(id: "ref#1", type: "int[]", fields: ["[0]": "1", "[1]": "2"])],
                 predict: nil),
            Step(index: 1,
                 narration: "`b[0] = 9` で共有配列の先頭が9になります。続く `b = new int[]{3,4}` でbだけ別配列へ切り替わります。",
                 highlightLines: [5, 6],
                 variables: [Variable(name: "a", type: "int[]", value: "ref#1", scope: "main"), Variable(name: "b", type: "int[]", value: "ref#2", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [HeapObject(id: "ref#1", type: "int[]", fields: ["[0]": "9", "[1]": "2"]), HeapObject(id: "ref#2", type: "int[]", fields: ["[0]": "3", "[1]": "4"])],
                 predict: PredictPrompt(
                    question: "最後に出力される `a[0]` と `b[0]` は？",
                    choices: ["9 と 3", "1 と 3", "9 と 9"],
                    answerIndex: 0,
                    hint: "aはref#1、bはref#2です。",
                    afterExplanation: "正解です。共有→再代入で参照先が分かれています。"
                 )),
            Step(index: 2,
                 narration: "出力は `9 3` です。",
                 highlightLines: [7, 8],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 8)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: 例外のcatch順序

    static let silverException005Explanation = Explanation(
        id: "explain-silver-exception-005",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        try {
            throw new IllegalArgumentException();
        } catch (RuntimeException e) {
            System.out.print("R ");
        } catch (IllegalArgumentException e) {
            System.out.print("I ");
        }
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "`IllegalArgumentException` は `RuntimeException` のサブクラスです。",
                 highlightLines: [4, 5],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 5)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "先に `catch (RuntimeException e)` があるため、後続の `catch (IllegalArgumentException e)` は到達不能になります。",
                 highlightLines: [5, 7],
                 variables: [],
                 callStack: [],
                 heap: [],
                 predict: PredictPrompt(
                    question: "この時点で結果は？",
                    choices: ["Rが出力", "Iが出力", "コンパイルエラー"],
                    answerIndex: 2,
                    hint: "到達不能catchはコンパイル時に検出されます。",
                    afterExplanation: "正解です。実行前にエラーです。"
                 )),
            Step(index: 2,
                 narration: "したがってこのコードはコンパイルエラーになります。",
                 highlightLines: [7],
                 variables: [],
                 callStack: [],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: staticフィールドの共有

    static let silverClasses005Explanation = Explanation(
        id: "explain-silver-classes-005",
        initialCode: """
class Counter {
    static int s = 0;
    int i = 0;
    Counter() { s++; i++; }
}
public class Test {
    public static void main(String[] args) {
        Counter a = new Counter();
        Counter b = new Counter();
        System.out.print(a.s + " ");
        System.out.print(a.i + " ");
        System.out.print(b.i);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "1つ目生成で `s=1`、`a.i=1` になります。",
                 highlightLines: [4, 8],
                 variables: [Variable(name: "s", type: "static int", value: "1", scope: "Counter"), Variable(name: "a.i", type: "int", value: "1", scope: "a")],
                 callStack: [CallStackFrame(method: "Counter()", line: 4)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "2つ目生成で共有 `s=2`、`b.i=1`。`a.i` は1のままです。",
                 highlightLines: [4, 9],
                 variables: [Variable(name: "s", type: "static int", value: "2", scope: "Counter"), Variable(name: "a.i", type: "int", value: "1", scope: "a"), Variable(name: "b.i", type: "int", value: "1", scope: "b")],
                 callStack: [CallStackFrame(method: "Counter()", line: 4)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "出力 `a.s a.i b.i` は？",
                    choices: ["2 1 1", "1 1 2", "2 2 2"],
                    answerIndex: 0,
                    hint: "sは共有、iは各インスタンスです。",
                    afterExplanation: "その通りです。`2 1 1` になります。"
                 )),
            Step(index: 2,
                 narration: "最終出力は `2 1 1` です。",
                 highlightLines: [10, 11, 12],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 12)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Silver: do-whileの最低1回実行

    static let silverControlFlow005Explanation = Explanation(
        id: "explain-silver-control-flow-005",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        int x = 5;
        do {
            System.out.print(x + " ");
            x++;
        } while (x < 5);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "do-whileは条件判定前に本体を1回実行します。まず `5` を出力し、xは6になります。",
                 highlightLines: [4, 5, 6],
                 variables: [Variable(name: "x", type: "int", value: "6", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "次に条件 `x < 5` を評価すると `6 < 5` はfalseです。",
                 highlightLines: [7],
                 variables: [Variable(name: "x", type: "int", value: "6", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 7)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "2回目のループ本体は実行される？",
                    choices: ["される", "されない"],
                    answerIndex: 1,
                    hint: "条件がfalseです。",
                    afterExplanation: "正解です。1回で終了します。"
                 )),
            Step(index: 2,
                 narration: "出力は `5` のみです。",
                 highlightLines: [5],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 5)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Gold: ジェネリクス境界

    static let goldGenerics004Explanation = Explanation(
        id: "explain-gold-generics-004",
        initialCode: """
import java.util.*;

public class Test {
    static void addOne(List<? super Integer> list) {
        list.add(1);
    }
    public static void main(String[] args) {
        List<Number> nums = new ArrayList<>();
        addOne(nums);
        System.out.println(nums.get(0));
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "`List<Number>` は `List<? super Integer>` に適合します。",
                 highlightLines: [4, 8, 9],
                 variables: [Variable(name: "nums", type: "List<Number>", value: "[]", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 9)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "`addOne` 内で `1` を安全に追加でき、listは `[1]` になります。",
                 highlightLines: [5],
                 variables: [Variable(name: "nums", type: "List<Number>", value: "[1]", scope: "main")],
                 callStack: [CallStackFrame(method: "addOne", line: 5)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "`? super Integer` の主用途は？",
                    choices: ["安全な読み取り", "安全な書き込み(Integer)", "どちらも不可"],
                    answerIndex: 1,
                    hint: "PECS: Consumer Super",
                    afterExplanation: "その通りです。super境界は書き込み側で使います。"
                 )),
            Step(index: 2,
                 narration: "先頭要素 `1` を出力するため、結果は `1` です。",
                 highlightLines: [10],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 10)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Gold: Streamの終端操作1回制限

    static let goldStream006Explanation = Explanation(
        id: "explain-gold-stream-006",
        initialCode: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        Stream<String> s = Stream.of("a", "b");
        long c = s.count();
        System.out.print(c + " ");
        s.forEach(System.out::print);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "`count()` は終端操作で、Streamを消費します。cには2が入ります。",
                 highlightLines: [6, 7],
                 variables: [Variable(name: "c", type: "long", value: "2", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 7)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "その後に同じStreamへ `forEach` を呼ぶと、既に操作済みのため `IllegalStateException` が発生します。",
                 highlightLines: [8],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 8)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "出力済みの `2` は残る？",
                    choices: ["残る", "消える"],
                    answerIndex: 0,
                    hint: "例外は後続処理で発生します。",
                    afterExplanation: "その通りです。`2` は表示された後に例外です。"
                 )),
            Step(index: 2,
                 narration: "結果は『2 の出力後に IllegalStateException』です。",
                 highlightLines: [7, 8],
                 variables: [],
                 callStack: [],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Gold: Optional.orElseGetの遅延

    static let goldOptional004Explanation = Explanation(
        id: "explain-gold-optional-004",
        initialCode: """
import java.util.*;

public class Test {
    static String create() {
        System.out.print("X ");
        return "created";
    }
    public static void main(String[] args) {
        String v = Optional.of("ok").orElseGet(() -> create());
        System.out.println(v);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "`Optional.of(\"ok\")` は値ありOptionalです。",
                 highlightLines: [9],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 9)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "`orElseGet` は値がない場合のみSupplierを実行します。今回は値ありなので `create()` は呼ばれません。",
                 highlightLines: [9],
                 variables: [Variable(name: "v", type: "String", value: "\"ok\"", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 9)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "Xは出力される？",
                    choices: ["される", "されない"],
                    answerIndex: 1,
                    hint: "Supplierは必要時のみ評価。",
                    afterExplanation: "正解です。create()は未実行です。"
                 )),
            Step(index: 2,
                 narration: "最終出力は `ok` のみです。",
                 highlightLines: [10],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 10)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Gold: synchronizedでの共有更新

    static let goldConcurrency005Explanation = Explanation(
        id: "explain-gold-concurrency-005",
        initialCode: """
public class Test {
    private static int count = 0;
    static synchronized void inc() { count++; }

    public static void main(String[] args) throws Exception {
        Thread t1 = new Thread(() -> { for (int i = 0; i < 1000; i++) inc(); });
        Thread t2 = new Thread(() -> { for (int i = 0; i < 1000; i++) inc(); });
        t1.start(); t2.start();
        t1.join();  t2.join();
        System.out.println(count);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "2つのスレッドがそれぞれ1000回 `inc()` を呼びます。",
                 highlightLines: [6, 7, 8],
                 variables: [Variable(name: "count", type: "int", value: "0 -> ...", scope: "class")],
                 callStack: [CallStackFrame(method: "main", line: 8)],
                 heap: [],
                 predict: nil),
            Step(index: 1,
                 narration: "`inc()` は synchronized のため1回に1スレッドのみ実行でき、更新競合が防止されます。`join()` で両スレッド完了を待ちます。",
                 highlightLines: [3, 9],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 9)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "最終countは？",
                    choices: ["必ず2000", "1000〜1999のどれか", "0"],
                    answerIndex: 0,
                    hint: "排他 + join で確定。",
                    afterExplanation: "正解です。取りこぼしがないため2000です。"
                 )),
            Step(index: 2,
                 narration: "最終出力は `2000` です。",
                 highlightLines: [10],
                 variables: [Variable(name: "count", type: "int", value: "2000", scope: "class")],
                 callStack: [CallStackFrame(method: "main", line: 10)],
                 heap: [],
                 predict: nil),
        ]
    )

    // MARK: - Generated Queue (Scalable Batches)

    static let generatedAuthoredSamples: [String: Explanation] = [
        silverOverload005Explanation.id: silverOverload005Explanation,
        silverString004Explanation.id: silverString004Explanation,
        silverException006Explanation.id: silverException006Explanation,
        silverControlFlow006Explanation.id: silverControlFlow006Explanation,
        silverDataTypes005Explanation.id: silverDataTypes005Explanation,
        silverCollections004Explanation.id: silverCollections004Explanation,
        silverInheritance003Explanation.id: silverInheritance003Explanation,
        silverJavaBasics005Explanation.id: silverJavaBasics005Explanation,
        silverOverload006Explanation.id: silverOverload006Explanation,
        silverString005Explanation.id: silverString005Explanation,
        silverCollections005Explanation.id: silverCollections005Explanation,
        goldStream007Explanation.id: goldStream007Explanation,
        goldGenerics005Explanation.id: goldGenerics005Explanation,
        goldOptional005Explanation.id: goldOptional005Explanation,
        goldStream008Explanation.id: goldStream008Explanation,
        goldOptional006Explanation.id: goldOptional006Explanation,
        goldStream009Explanation.id: goldStream009Explanation,
        goldGenerics007Explanation.id: goldGenerics007Explanation,
        silverArray002Explanation.id: silverArray002Explanation,
        silverClasses002Explanation.id: silverClasses002Explanation,
        silverCollections001Explanation.id: silverCollections001Explanation,
        silverControlFlow001Explanation.id: silverControlFlow001Explanation,
        silverDataTypes002Explanation.id: silverDataTypes002Explanation,
        silverException002Explanation.id: silverException002Explanation,
        silverJavaBasics001Explanation.id: silverJavaBasics001Explanation,
        silverOverload002Explanation.id: silverOverload002Explanation,
        silverArrayDefaults001Explanation.id: silverArrayDefaults001Explanation,
        silverConstructor001Explanation.id: silverConstructor001Explanation,
        silverControlFlow002Explanation.id: silverControlFlow002Explanation,
        silverJavaBasics002Explanation.id: silverJavaBasics002Explanation,
        silverLambda001Explanation.id: silverLambda001Explanation,
        silverLambda002Explanation.id: silverLambda002Explanation,
        silverLambda003Explanation.id: silverLambda003Explanation,
        silverLambda004Explanation.id: silverLambda004Explanation,
        silverMultiFileOverride001Explanation.id: silverMultiFileOverride001Explanation,
        silverStringBuilder001Explanation.id: silverStringBuilder001Explanation,
        goldStream002Explanation.id: goldStream002Explanation,
        goldStream003Explanation.id: goldStream003Explanation,
        goldStream004Explanation.id: goldStream004Explanation,
        goldStream005Explanation.id: goldStream005Explanation,
        goldOptional002Explanation.id: goldOptional002Explanation,
        goldOptional003Explanation.id: goldOptional003Explanation,
        goldGenerics002Explanation.id: goldGenerics002Explanation,
        goldGenerics003Explanation.id: goldGenerics003Explanation,
        goldAnnotations001Explanation.id: goldAnnotations001Explanation,
        goldClasses001Explanation.id: goldClasses001Explanation,
        goldClasses002Explanation.id: goldClasses002Explanation,
        goldCollections001Explanation.id: goldCollections001Explanation,
        goldConcurrency001Explanation.id: goldConcurrency001Explanation,
        goldConcurrency002Explanation.id: goldConcurrency002Explanation,
        goldConcurrency003Explanation.id: goldConcurrency003Explanation,
        goldConcurrency004Explanation.id: goldConcurrency004Explanation,
        goldDateTime001Explanation.id: goldDateTime001Explanation,
        goldIo001Explanation.id: goldIo001Explanation,
        goldIo002Explanation.id: goldIo002Explanation,
        goldJdbc001Explanation.id: goldJdbc001Explanation,
        goldJdbc002Explanation.id: goldJdbc002Explanation,
        goldLocalization001Explanation.id: goldLocalization001Explanation,
        goldLocalization002Explanation.id: goldLocalization002Explanation,
        goldLocalization003Explanation.id: goldLocalization003Explanation,
        goldLocalization004Explanation.id: goldLocalization004Explanation,
        goldLocalization005Explanation.id: goldLocalization005Explanation,
        goldLocalization006Explanation.id: goldLocalization006Explanation,
        goldLocalization007Explanation.id: goldLocalization007Explanation,
        goldLocalization008Explanation.id: goldLocalization008Explanation,
        goldLocalization009Explanation.id: goldLocalization009Explanation,
        goldLocalization010Explanation.id: goldLocalization010Explanation,
        goldLocalization011Explanation.id: goldLocalization011Explanation,
        goldLocalization012Explanation.id: goldLocalization012Explanation,
        goldLocalization013Explanation.id: goldLocalization013Explanation,
        goldLocalization014Explanation.id: goldLocalization014Explanation,
        goldLocalization015Explanation.id: goldLocalization015Explanation,
        goldLocalization016Explanation.id: goldLocalization016Explanation,
        goldLocalization017Explanation.id: goldLocalization017Explanation,
        goldLocalization018Explanation.id: goldLocalization018Explanation,
        goldLocalization019Explanation.id: goldLocalization019Explanation,
        goldLocalization020Explanation.id: goldLocalization020Explanation,
        goldLocalization021Explanation.id: goldLocalization021Explanation,
        goldLocalization022Explanation.id: goldLocalization022Explanation,
        goldLocalization023Explanation.id: goldLocalization023Explanation,
        goldLocalization024Explanation.id: goldLocalization024Explanation,
        goldLambdaConstructorRef001Explanation.id: goldLambdaConstructorRef001Explanation,
        goldFunctionalLambda001Explanation.id: goldFunctionalLambda001Explanation,
        goldFunctionalLambda002Explanation.id: goldFunctionalLambda002Explanation,
        goldFunctionalLambda003Explanation.id: goldFunctionalLambda003Explanation,
        goldFunctionalLambda004Explanation.id: goldFunctionalLambda004Explanation,
        goldFunctionalLambda005Explanation.id: goldFunctionalLambda005Explanation,
        goldFunctionalLambda006Explanation.id: goldFunctionalLambda006Explanation,
        goldFunctionalLambda007Explanation.id: goldFunctionalLambda007Explanation,
        goldFunctionalLambda008Explanation.id: goldFunctionalLambda008Explanation,
        goldFunctionalLambda009Explanation.id: goldFunctionalLambda009Explanation,
        goldFunctionalLambda010Explanation.id: goldFunctionalLambda010Explanation,
        goldFunctionalLambda011Explanation.id: goldFunctionalLambda011Explanation,
        goldFunctionalLambda012Explanation.id: goldFunctionalLambda012Explanation,
        goldFunctionalLambda013Explanation.id: goldFunctionalLambda013Explanation,
        goldFunctionalLambda014Explanation.id: goldFunctionalLambda014Explanation,
        goldFunctionalLambda015Explanation.id: goldFunctionalLambda015Explanation,
        goldFunctionalLambda016Explanation.id: goldFunctionalLambda016Explanation,
        goldFunctionalLambda017Explanation.id: goldFunctionalLambda017Explanation,
        goldFunctionalLambda018Explanation.id: goldFunctionalLambda018Explanation,
        goldFunctionalLambda019Explanation.id: goldFunctionalLambda019Explanation,
        goldFunctionalLambda020Explanation.id: goldFunctionalLambda020Explanation,
        goldFunctionalLambda021Explanation.id: goldFunctionalLambda021Explanation,
        goldFunctionalLambda022Explanation.id: goldFunctionalLambda022Explanation,
        goldFunctionalLambda023Explanation.id: goldFunctionalLambda023Explanation,
        goldFunctionalLambda024Explanation.id: goldFunctionalLambda024Explanation,
        goldFunctionalLambda025Explanation.id: goldFunctionalLambda025Explanation,
        goldFunctionalLambda026Explanation.id: goldFunctionalLambda026Explanation,
        goldFunctionalLambda027Explanation.id: goldFunctionalLambda027Explanation,
        goldFunctionalLambda028Explanation.id: goldFunctionalLambda028Explanation,
        goldFunctionalLambda029Explanation.id: goldFunctionalLambda029Explanation,
        goldFunctionalLambda030Explanation.id: goldFunctionalLambda030Explanation,
        goldFunctionalLambda031Explanation.id: goldFunctionalLambda031Explanation,
        goldFunctionalLambda032Explanation.id: goldFunctionalLambda032Explanation,
        goldFunctionalLambda033Explanation.id: goldFunctionalLambda033Explanation,
        goldFunctionalLambda034Explanation.id: goldFunctionalLambda034Explanation,
        goldFunctionalLambda035Explanation.id: goldFunctionalLambda035Explanation,
        goldFunctionalLambda036Explanation.id: goldFunctionalLambda036Explanation,
        goldFunctionalLambda037Explanation.id: goldFunctionalLambda037Explanation,
        goldFunctionalLambda038Explanation.id: goldFunctionalLambda038Explanation,
        goldFunctionalLambda039Explanation.id: goldFunctionalLambda039Explanation,
        goldFunctionalLambda040Explanation.id: goldFunctionalLambda040Explanation,
        goldFunctionalLambda041Explanation.id: goldFunctionalLambda041Explanation,
        goldFunctionalLambda042Explanation.id: goldFunctionalLambda042Explanation,
        goldFunctionalLambda043Explanation.id: goldFunctionalLambda043Explanation,
        goldFunctionalLambda044Explanation.id: goldFunctionalLambda044Explanation,
        goldFunctionalLambda045Explanation.id: goldFunctionalLambda045Explanation,
        goldFunctionalLambda046Explanation.id: goldFunctionalLambda046Explanation,
        goldFunctionalLambda047Explanation.id: goldFunctionalLambda047Explanation,
        goldFunctionalLambda048Explanation.id: goldFunctionalLambda048Explanation,
        goldFunctionalLambda049Explanation.id: goldFunctionalLambda049Explanation,
        goldFunctionalLambda050Explanation.id: goldFunctionalLambda050Explanation,
        goldFunctionalLambda051Explanation.id: goldFunctionalLambda051Explanation,
        goldFunctionalLambda052Explanation.id: goldFunctionalLambda052Explanation,
        goldFunctionalLambda053Explanation.id: goldFunctionalLambda053Explanation,
        goldFunctionalLambda054Explanation.id: goldFunctionalLambda054Explanation,
        goldFunctionalLambda055Explanation.id: goldFunctionalLambda055Explanation,
        goldFunctionalLambda056Explanation.id: goldFunctionalLambda056Explanation,
        goldFunctionalLambda057Explanation.id: goldFunctionalLambda057Explanation,
        goldFunctionalLambda058Explanation.id: goldFunctionalLambda058Explanation,
        goldFunctionalLambda059Explanation.id: goldFunctionalLambda059Explanation,
        goldFunctionalLambda060Explanation.id: goldFunctionalLambda060Explanation,
        goldModule001Explanation.id: goldModule001Explanation,
        goldModule002Explanation.id: goldModule002Explanation,
        goldPathNormalize001Explanation.id: goldPathNormalize001Explanation,
        silverClasses006Explanation.id: silverClasses006Explanation,
        silverControlFlow007Explanation.id: silverControlFlow007Explanation,
        silverDataTypes006Explanation.id: silverDataTypes006Explanation,
        silverException007Explanation.id: silverException007Explanation,
        goldStream010Explanation.id: goldStream010Explanation,
        goldConcurrency006Explanation.id: goldConcurrency006Explanation,
        silverControlFlow010Explanation.id: silverControlFlow010Explanation,
        silverStringBuilder005Explanation.id: silverStringBuilder005Explanation,
        silverCollections007Explanation.id: silverCollections007Explanation,
        silverOverload007Explanation.id: silverOverload007Explanation,
        silverClasses008Explanation.id: silverClasses008Explanation,
        silverException008Explanation.id: silverException008Explanation,
        silverArray009Explanation.id: silverArray009Explanation,
        silverLambda005Explanation.id: silverLambda005Explanation,
        goldStream012Explanation.id: goldStream012Explanation,
        goldStream013Explanation.id: goldStream013Explanation,
        goldGenerics008Explanation.id: goldGenerics008Explanation,
        goldOptional008Explanation.id: goldOptional008Explanation,
        goldCollections005Explanation.id: goldCollections005Explanation,
        goldCollections006Explanation.id: goldCollections006Explanation,
        goldCollections007Explanation.id: goldCollections007Explanation,
        goldCollections008Explanation.id: goldCollections008Explanation,
        goldCollections009Explanation.id: goldCollections009Explanation,
        goldCollections010Explanation.id: goldCollections010Explanation,
        goldCollections011Explanation.id: goldCollections011Explanation,
        goldCollections012Explanation.id: goldCollections012Explanation,
        goldCollections013Explanation.id: goldCollections013Explanation,
        goldCollections014Explanation.id: goldCollections014Explanation,
        goldCollections015Explanation.id: goldCollections015Explanation,
        goldCollections016Explanation.id: goldCollections016Explanation,
        goldCollections017Explanation.id: goldCollections017Explanation,
        goldCollections018Explanation.id: goldCollections018Explanation,
        goldCollections019Explanation.id: goldCollections019Explanation,
        goldCollections020Explanation.id: goldCollections020Explanation,
        goldCollections021Explanation.id: goldCollections021Explanation,
        goldCollections022Explanation.id: goldCollections022Explanation,
        goldCollections023Explanation.id: goldCollections023Explanation,
        goldCollections024Explanation.id: goldCollections024Explanation,
        goldCollections025Explanation.id: goldCollections025Explanation,
        goldConcurrency009Explanation.id: goldConcurrency009Explanation,
        goldDateTime005Explanation.id: goldDateTime005Explanation,
        goldIo006Explanation.id: goldIo006Explanation,
        goldClasses007Explanation.id: goldClasses007Explanation,
        silverFinal001Explanation.id: silverFinal001Explanation,
        silverFinal002Explanation.id: silverFinal002Explanation,
        silverFinal003Explanation.id: silverFinal003Explanation,
        silverStatic001Explanation.id: silverStatic001Explanation,
        silverStatic002Explanation.id: silverStatic002Explanation,
        silverStatic003Explanation.id: silverStatic003Explanation,
        silverStatic004Explanation.id: silverStatic004Explanation,
        goldStatic005Explanation.id: goldStatic005Explanation,
        goldStatic006Explanation.id: goldStatic006Explanation,
        silverEnum001Explanation.id: silverEnum001Explanation,
        silverEnum002Explanation.id: silverEnum002Explanation,
        silverEnum003Explanation.id: silverEnum003Explanation,
        goldEnum004Explanation.id: goldEnum004Explanation,
        goldEnum005Explanation.id: goldEnum005Explanation,
        silverObject001Explanation.id: silverObject001Explanation,
        silverObject002Explanation.id: silverObject002Explanation,
        silverJavaBasics007Explanation.id: silverJavaBasics007Explanation,
        silverDataTypes013Explanation.id: silverDataTypes013Explanation,
        silverDataTypes014Explanation.id: silverDataTypes014Explanation,
        silverString007Explanation.id: silverString007Explanation,
        silverStringBuilder006Explanation.id: silverStringBuilder006Explanation,
        silverArray010Explanation.id: silverArray010Explanation,
        silverArray011Explanation.id: silverArray011Explanation,
        silverCollections008Explanation.id: silverCollections008Explanation,
        silverCollections009Explanation.id: silverCollections009Explanation,
        silverControlFlow011Explanation.id: silverControlFlow011Explanation,
        silverControlFlow012Explanation.id: silverControlFlow012Explanation,
        silverClasses009Explanation.id: silverClasses009Explanation,
        silverClasses010Explanation.id: silverClasses010Explanation,
        silverInheritance008Explanation.id: silverInheritance008Explanation,
        silverInheritance009Explanation.id: silverInheritance009Explanation,
        silverException009Explanation.id: silverException009Explanation,
        silverException010Explanation.id: silverException010Explanation,
        silverLambda006Explanation.id: silverLambda006Explanation,
        silverStatic005Explanation.id: silverStatic005Explanation,
        silverFinal004Explanation.id: silverFinal004Explanation,
        silverJavaBasics008Explanation.id: silverJavaBasics008Explanation,
        silverDataTypes015Explanation.id: silverDataTypes015Explanation,
        silverDataTypes016Explanation.id: silverDataTypes016Explanation,
        silverDataTypes017Explanation.id: silverDataTypes017Explanation,
        silverString008Explanation.id: silverString008Explanation,
        silverStringBuilder007Explanation.id: silverStringBuilder007Explanation,
        silverArray012Explanation.id: silverArray012Explanation,
        silverArray013Explanation.id: silverArray013Explanation,
        silverCollections010Explanation.id: silverCollections010Explanation,
        silverCollections011Explanation.id: silverCollections011Explanation,
        silverControlFlow013Explanation.id: silverControlFlow013Explanation,
        silverControlFlow014Explanation.id: silverControlFlow014Explanation,
        silverClasses011Explanation.id: silverClasses011Explanation,
        silverClasses012Explanation.id: silverClasses012Explanation,
        silverInheritance010Explanation.id: silverInheritance010Explanation,
        silverInheritance011Explanation.id: silverInheritance011Explanation,
        silverException011Explanation.id: silverException011Explanation,
        silverException012Explanation.id: silverException012Explanation,
        silverLambda007Explanation.id: silverLambda007Explanation,
        silverLambda008Explanation.id: silverLambda008Explanation,
        silverJavaBasics009Explanation.id: silverJavaBasics009Explanation,
        silverDataTypes018Explanation.id: silverDataTypes018Explanation,
        silverDataTypes019Explanation.id: silverDataTypes019Explanation,
        silverString009Explanation.id: silverString009Explanation,
        silverStringBuilder008Explanation.id: silverStringBuilder008Explanation,
        silverArray014Explanation.id: silverArray014Explanation,
        silverCollections012Explanation.id: silverCollections012Explanation,
        silverCollections013Explanation.id: silverCollections013Explanation,
        silverControlFlow015Explanation.id: silverControlFlow015Explanation,
        silverClasses013Explanation.id: silverClasses013Explanation,
        silverInheritance012Explanation.id: silverInheritance012Explanation,
        silverException013Explanation.id: silverException013Explanation,
        silverLambda009Explanation.id: silverLambda009Explanation,
        silverStatic006Explanation.id: silverStatic006Explanation,
        silverFinal005Explanation.id: silverFinal005Explanation,
        silverEnum004Explanation.id: silverEnum004Explanation,
        silverObject003Explanation.id: silverObject003Explanation,
        silverOverload008Explanation.id: silverOverload008Explanation,
        silverOperators003Explanation.id: silverOperators003Explanation,
        silverJavaBasics010Explanation.id: silverJavaBasics010Explanation,
        goldObject003Explanation.id: goldObject003Explanation,
        goldObject004Explanation.id: goldObject004Explanation,
        goldAnnotations003Explanation.id: goldAnnotations003Explanation,
        goldAnnotations004Explanation.id: goldAnnotations004Explanation,
        goldAnnotations005Explanation.id: goldAnnotations005Explanation,
        goldAnnotations006Explanation.id: goldAnnotations006Explanation,
        goldAnnotations007Explanation.id: goldAnnotations007Explanation,
        goldAnnotations008Explanation.id: goldAnnotations008Explanation,
        goldAnnotations009Explanation.id: goldAnnotations009Explanation,
        goldAnnotations010Explanation.id: goldAnnotations010Explanation,
        goldAnnotations011Explanation.id: goldAnnotations011Explanation,
        goldAnnotations012Explanation.id: goldAnnotations012Explanation,
        goldException007Explanation.id: goldException007Explanation,
        goldException008Explanation.id: goldException008Explanation,
        goldException009Explanation.id: goldException009Explanation,
        goldException010Explanation.id: goldException010Explanation,
        goldException011Explanation.id: goldException011Explanation,
        goldException012Explanation.id: goldException012Explanation,
        goldException013Explanation.id: goldException013Explanation,
        goldException014Explanation.id: goldException014Explanation,
        goldException015Explanation.id: goldException015Explanation,
        goldException016Explanation.id: goldException016Explanation,
        goldException017Explanation.id: goldException017Explanation,
        goldException018Explanation.id: goldException018Explanation,
        goldException019Explanation.id: goldException019Explanation,
        goldException020Explanation.id: goldException020Explanation,
        goldSecureCoding001Explanation.id: goldSecureCoding001Explanation,
        goldSecureCoding002Explanation.id: goldSecureCoding002Explanation,
        goldSecureCoding003Explanation.id: goldSecureCoding003Explanation,
        goldSecureCoding004Explanation.id: goldSecureCoding004Explanation,
        goldSecureCoding005Explanation.id: goldSecureCoding005Explanation,
        goldSecureCoding006Explanation.id: goldSecureCoding006Explanation,
        goldSecureCoding007Explanation.id: goldSecureCoding007Explanation,
        goldSecureCoding008Explanation.id: goldSecureCoding008Explanation,
        goldSecureCoding009Explanation.id: goldSecureCoding009Explanation,
        goldSecureCoding010Explanation.id: goldSecureCoding010Explanation,
        goldSecureCoding011Explanation.id: goldSecureCoding011Explanation,
        goldSecureCoding012Explanation.id: goldSecureCoding012Explanation,
        goldSecureCoding013Explanation.id: goldSecureCoding013Explanation,
        goldSecureCoding014Explanation.id: goldSecureCoding014Explanation,
        goldSecureCoding015Explanation.id: goldSecureCoding015Explanation,
        goldSecureCoding016Explanation.id: goldSecureCoding016Explanation,
        goldSecureCoding017Explanation.id: goldSecureCoding017Explanation,
        goldSecureCoding018Explanation.id: goldSecureCoding018Explanation,
        goldSecureCoding019Explanation.id: goldSecureCoding019Explanation,
        goldSecureCoding020Explanation.id: goldSecureCoding020Explanation,
    ]

    // MARK: - Silver Batch Queue-001

    static let silverOverload005Explanation = Explanation(
        id: "explain-silver-overload-005",
        initialCode: """
public class Test {
    static void m(String s)  { System.out.print("S "); }
    static void m(Object o)  { System.out.print("O "); }

    public static void main(String[] args) {
        m(null);
    }
}
""",
        steps: [
            Step(index: 0, narration: "`m(null)` は String と Object の両方に適用可能です。", highlightLines: [6], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
            Step(index: 1, narration: "より具体的な型である `String` 版が選択されます。", highlightLines: [2, 3], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: PredictPrompt(question: "この場合に選ばれるのは？", choices: ["m(String)", "m(Object)", "曖昧エラー"], answerIndex: 0, hint: "具体型優先", afterExplanation: "正解です。String版が選ばれます。")),
            Step(index: 2, narration: "出力は `S` です。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "m(String)", line: 2)], heap: [], predict: nil),
        ]
    )

    static let silverString004Explanation = Explanation(
        id: "explain-silver-string-004",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        String a = new String("java");
        String b = "java";
        System.out.print(a == b);
        System.out.print(" ");
        System.out.print(a.equals(b));
    }
}
""",
        steps: [
            Step(index: 0, narration: "`a` はnewで新規参照、`b` は文字列リテラル参照です。", highlightLines: [3, 4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "`a == b` は参照比較なので false。`a.equals(b)` は内容比較なので true。", highlightLines: [5, 7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: PredictPrompt(question: "最終出力は？", choices: ["true true", "false true", "false false"], answerIndex: 1, hint: "==は参照、equalsは内容", afterExplanation: "その通りです。false trueです。")),
            Step(index: 2, narration: "最終出力は `false true` です。", highlightLines: [5, 7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let silverException006Explanation = Explanation(
        id: "explain-silver-exception-006",
        initialCode: """
import java.io.IOException;

public class Test {
    static void read() throws IOException {
        throw new IOException();
    }
    public static void main(String[] args) {
        read();
    }
}
""",
        steps: [
            Step(index: 0, narration: "`read()` は checked例外IOExceptionをthrows宣言しています。", highlightLines: [4], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "`main` は `read()` 呼び出し時に catch または throws で処理していないため、コンパイルエラーになります。", highlightLines: [7, 8], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "これは実行時エラー？", choices: ["はい", "いいえ（コンパイルエラー）"], answerIndex: 1, hint: "checked exceptionの規則", afterExplanation: "正解です。実行前にコンパイルで止まります。")),
            Step(index: 2, narration: "結論: コンパイルエラーです。", highlightLines: [8], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    // MARK: - Gold Batch Queue-001

    static let goldStream007Explanation = Explanation(
        id: "explain-gold-stream-007",
        initialCode: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        List<String> result = Stream.of("a", "bb", "ccc")
            .map(String::length)
            .map(String::valueOf)
            .collect(Collectors.toList());
        System.out.println(result);
    }
}
""",
        steps: [
            Step(index: 0, narration: "最初のstream要素は `\"a\", \"bb\", \"ccc\"` です。", highlightLines: [6], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
            Step(index: 1, narration: "map(length) で `1,2,3`、map(valueOf)で `\"1\",\"2\",\"3\"` に変換されます。", highlightLines: [7, 8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: PredictPrompt(question: "collect後のListは？", choices: ["[a, bb, ccc]", "[1, 2, 3]", "[1, 4, 9]"], answerIndex: 1, hint: "長さ→文字列化", afterExplanation: "正解です。[1, 2, 3] になります。")),
            Step(index: 2, narration: "最終出力は `[1, 2, 3]` です。", highlightLines: [10], variables: [], callStack: [CallStackFrame(method: "main", line: 10)], heap: [], predict: nil),
        ]
    )

    static let goldGenerics005Explanation = Explanation(
        id: "explain-gold-generics-005",
        initialCode: """
import java.util.*;

public class Test {
    static int sum(List<? extends Number> list) {
        int total = 0;
        for (Number n : list) total += n.intValue();
        return total;
    }
    public static void main(String[] args) {
        List<Integer> nums = Arrays.asList(1, 2, 3);
        System.out.println(sum(nums));
    }
}
""",
        steps: [
            Step(index: 0, narration: "`List<Integer>` は `List<? extends Number>` に渡せます。", highlightLines: [4, 10], variables: [], callStack: [CallStackFrame(method: "main", line: 11)], heap: [], predict: nil),
            Step(index: 1, narration: "for文で `1+2+3` を合計して6になります。", highlightLines: [6], variables: [Variable(name: "total", type: "int", value: "6", scope: "sum")], callStack: [CallStackFrame(method: "sum", line: 6)], heap: [], predict: PredictPrompt(question: "最終出力は？", choices: ["6", "0", "コンパイルエラー"], answerIndex: 0, hint: "extendsは読み取り側", afterExplanation: "その通りです。6です。")),
            Step(index: 2, narration: "出力は `6` です。", highlightLines: [11], variables: [], callStack: [CallStackFrame(method: "main", line: 11)], heap: [], predict: nil),
        ]
    )

    static let goldOptional005Explanation = Explanation(
        id: "explain-gold-optional-005",
        initialCode: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        String result = Optional.of("java")
            .map(String::toUpperCase)
            .orElse("NONE");
        System.out.println(result);
    }
}
""",
        steps: [
            Step(index: 0, narration: "Optionalには `\"java\"` が存在します。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
            Step(index: 1, narration: "map(toUpperCase) により値は `\"JAVA\"` になります。値ありなので `orElse(\"NONE\")` は使われません。", highlightLines: [6, 7], variables: [Variable(name: "result", type: "String", value: "\"JAVA\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: PredictPrompt(question: "出力は？", choices: ["java", "JAVA", "NONE"], answerIndex: 1, hint: "map後もOptionalは値あり", afterExplanation: "正解です。JAVAです。")),
            Step(index: 2, narration: "最終出力は `JAVA` です。", highlightLines: [8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    static let silverControlFlow006Explanation = Explanation(
        id: "explain-silver-control-flow-006",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        for (int i = 1; i <= 5; i++) {
            if (i == 2) continue;
            if (i == 4) break;
            System.out.print(i + " ");
        }
    }
}
""",
        steps: [
            Step(index: 0, narration: "i=1はそのまま出力されます。", highlightLines: [3, 6], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
            Step(index: 1, narration: "i=2はcontinueでスキップ、i=3は出力、i=4でbreakして終了します。", highlightLines: [4, 5, 6], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "最終出力は？", choices: ["1 2 3", "1 3", "1 3 4"], answerIndex: 1, hint: "2はcontinue、4でbreak", afterExplanation: "正解です。1 3です。")),
            Step(index: 2, narration: "最終出力は `1 3` です。", highlightLines: [6], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
        ]
    )

    static let silverDataTypes005Explanation = Explanation(
        id: "explain-silver-data-types-005",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        char c = 'A';
        c++;
        System.out.println(c);
    }
}
""",
        steps: [
            Step(index: 0, narration: "`c` は文字 'A'(65) で開始します。", highlightLines: [3], variables: [Variable(name: "c", type: "char", value: "'A'(65)", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`c++` で文字コードが1増え、'B'(66) になります。", highlightLines: [4], variables: [Variable(name: "c", type: "char", value: "'B'(66)", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "println(c)の表示は？", choices: ["B", "66", "コンパイルエラー"], answerIndex: 0, hint: "println(char)は文字表示", afterExplanation: "正解です。Bが表示されます。")),
            Step(index: 2, narration: "最終出力は `B` です。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let silverCollections004Explanation = Explanation(
        id: "explain-silver-collections-004",
        initialCode: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Map<String, Integer> map = new HashMap<>();
        System.out.print(map.put("A", 1) + " ");
        System.out.print(map.put("A", 2) + " ");
        System.out.println(map.get("A"));
    }
}
""",
        steps: [
            Step(index: 0, narration: "最初の put(\"A\",1) は旧値がないため null を返します。", highlightLines: [6], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
            Step(index: 1, narration: "次の put(\"A\",2) は旧値1を返し、マップ内値は2に更新されます。", highlightLines: [7], variables: [Variable(name: "map[A]", type: "Integer", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: PredictPrompt(question: "最後のget(\"A\")は？", choices: ["1", "2", "null"], answerIndex: 1, hint: "Aの現在値は更新後", afterExplanation: "その通りです。2です。")),
            Step(index: 2, narration: "最終出力は `null 1 2` です。", highlightLines: [8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    static let silverInheritance003Explanation = Explanation(
        id: "explain-silver-inheritance-003",
        initialCode: """
class Parent {
    final void show() {}
}
class Child extends Parent {
    void show() {}
}
public class Test {
    public static void main(String[] args) {
        System.out.println("ok");
    }
}
""",
        steps: [
            Step(index: 0, narration: "Parent.show() は final メソッドです。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "Childで同シグネチャ show() を宣言しており、finalメソッドのオーバーライド禁止に違反します。", highlightLines: [5], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "結果は？", choices: ["実行時例外", "コンパイルエラー", "okが出力"], answerIndex: 1, hint: "finalは上書き不可", afterExplanation: "正解です。コンパイルエラーです。")),
            Step(index: 2, narration: "このコードはコンパイルエラーです。", highlightLines: [5], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldStream008Explanation = Explanation(
        id: "explain-gold-stream-008",
        initialCode: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        Optional<String> r = Stream.of("aa", "b", "ccc")
            .filter(s -> s.length() == 1)
            .findFirst();
        System.out.println(r.orElse("NONE"));
    }
}
""",
        steps: [
            Step(index: 0, narration: "stream要素は aa, b, ccc。filterで長さ1の要素だけ通します。", highlightLines: [6, 7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
            Step(index: 1, narration: "条件一致の最初は b なので findFirst は Optional.of(\"b\") を返します。", highlightLines: [8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: PredictPrompt(question: "orElse(\"NONE\") の結果は？", choices: ["b", "NONE", "aa"], answerIndex: 0, hint: "Optionalは値あり", afterExplanation: "正解です。bです。")),
            Step(index: 2, narration: "最終出力は `b` です。", highlightLines: [9], variables: [], callStack: [CallStackFrame(method: "main", line: 9)], heap: [], predict: nil),
        ]
    )

    static let goldOptional006Explanation = Explanation(
        id: "explain-gold-optional-006",
        initialCode: """
import java.util.*;

public class Test {
    static Optional<String> wrap(String s) {
        return Optional.of("[" + s + "]");
    }
    public static void main(String[] args) {
        String r = Optional.of("x")
            .flatMap(Test::wrap)
            .orElse("none");
        System.out.println(r);
    }
}
""",
        steps: [
            Step(index: 0, narration: "`Optional.of(\"x\")` から開始し、flatMapで wrap を適用します。", highlightLines: [8, 9], variables: [], callStack: [CallStackFrame(method: "main", line: 9)], heap: [], predict: nil),
            Step(index: 1, narration: "wrapは Optional.of(\"[x]\") を返し、flatMapで平坦化された結果を得ます。", highlightLines: [4, 5, 9], variables: [Variable(name: "r", type: "String", value: "\"[x]\"", scope: "main")], callStack: [CallStackFrame(method: "wrap", line: 5)], heap: [], predict: PredictPrompt(question: "orElse(\"none\") は使われる？", choices: ["使われる", "使われない"], answerIndex: 1, hint: "値ありOptionalです。", afterExplanation: "その通りです。値があるので使われません。")),
            Step(index: 2, narration: "最終出力は `[x]` です。", highlightLines: [11], variables: [], callStack: [CallStackFrame(method: "main", line: 11)], heap: [], predict: nil),
        ]
    )

    static let silverJavaBasics005Explanation = Explanation(
        id: "explain-silver-java-basics-005",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        Integer a = 127;
        Integer b = 127;
        Integer c = 128;
        Integer d = 128;
        System.out.print((a == b) + " ");
        System.out.println(c == d);
    }
}
""",
        steps: [
            Step(index: 0, narration: "127はIntegerキャッシュ範囲(-128〜127)内なので `a==b` はtrueになります。", highlightLines: [3, 4, 7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
            Step(index: 1, narration: "128は通常キャッシュ外のため `c` と `d` は別参照となり `c==d` はfalseです。", highlightLines: [5, 6, 8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: PredictPrompt(question: "最終出力は？", choices: ["true true", "true false", "false false"], answerIndex: 1, hint: "127と128の差に注目", afterExplanation: "正解です。true falseです。")),
            Step(index: 2, narration: "最終出力は `true false` です。", highlightLines: [7, 8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    static let silverOverload006Explanation = Explanation(
        id: "explain-silver-overload-006",
        initialCode: """
public class Test {
    static void m(String... s)  { System.out.print("S "); }
    static void m(Integer... i) { System.out.print("I "); }
    public static void main(String[] args) {
        m(null);
    }
}
""",
        steps: [
            Step(index: 0, narration: "`m(null)` は String... と Integer... の両方に適用可能です。", highlightLines: [2, 3, 5], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "どちらも可変長引数で優先順位が付かず、最も具体的な候補を一意に決められません。", highlightLines: [5], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "結果は？", choices: ["Sが出力", "Iが出力", "コンパイルエラー"], answerIndex: 2, hint: "曖昧解決", afterExplanation: "正解です。コンパイルエラーです。")),
            Step(index: 2, narration: "このコードはオーバーロード曖昧でコンパイルエラーになります。", highlightLines: [5], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let silverString005Explanation = Explanation(
        id: "explain-silver-string-005",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        String s = "ABCDE";
        System.out.println(s.substring(1, 4));
    }
}
""",
        steps: [
            Step(index: 0, narration: "`substring(1, 4)` は begin=1を含み、end=4を含みません。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "index1=B, index2=C, index3=D が対象になります。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "取り出される文字列は？", choices: ["BCD", "BCDE", "ABCD"], answerIndex: 0, hint: "endは含まない", afterExplanation: "その通りです。BCDです。")),
            Step(index: 2, narration: "最終出力は `BCD` です。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let silverCollections005Explanation = Explanation(
        id: "explain-silver-collections-005",
        initialCode: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> list = Arrays.asList("A", "B");
        list.set(0, "X");
        System.out.print(list + " ");
        list.add("C");
    }
}
""",
        steps: [
            Step(index: 0, narration: "`Arrays.asList` は固定長リストを返します。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
            Step(index: 1, narration: "`set` は要素置換なので成功し、`[X, B]` が出力されます。", highlightLines: [6, 7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: PredictPrompt(question: "続く add(\"C\") は？", choices: ["成功する", "UnsupportedOperationException"], answerIndex: 1, hint: "サイズ変更可否", afterExplanation: "正解です。固定長のためaddは失敗します。")),
            Step(index: 2, narration: "`add` はサイズ変更なので `UnsupportedOperationException` が発生します。", highlightLines: [8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    static let goldStream009Explanation = Explanation(
        id: "explain-gold-stream-009",
        initialCode: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        Stream.of(1, 2, 3)
            .peek(System.out::print);
        System.out.println("END");
    }
}
""",
        steps: [
            Step(index: 0, narration: "`peek` は中間操作で、終端操作が呼ばれるまで実行されません。", highlightLines: [5, 6], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
            Step(index: 1, narration: "このコードには終端操作がないため 1,2,3 は出力されません。", highlightLines: [5, 6], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: PredictPrompt(question: "実際に表示されるのは？", choices: ["123END", "END", "何もなし"], answerIndex: 1, hint: "printlnは通常実行される", afterExplanation: "正解です。ENDのみです。")),
            Step(index: 2, narration: "最終出力は `END` です。", highlightLines: [7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let goldGenerics007Explanation = Explanation(
        id: "explain-gold-generics-007",
        initialCode: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<?> list = new ArrayList<String>();
        // list.add("A");
        list.add(null);
        System.out.println(list.size());
    }
}
""",
        steps: [
            Step(index: 0, narration: "`List<?>` は要素型不明のため、型安全に追加できる値は基本的にnullのみです。", highlightLines: [5, 7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
            Step(index: 1, narration: "コメント行 `list.add(\"A\")` を有効化するとコンパイルエラーですが、`list.add(null)` は有効です。", highlightLines: [6, 7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: PredictPrompt(question: "現在のコードのsizeは？", choices: ["0", "1", "コンパイルエラー"], answerIndex: 1, hint: "nullを1件追加", afterExplanation: "その通りです。1です。")),
            Step(index: 2, narration: "最終出力は `1` です。", highlightLines: [8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    // MARK: - Backfill authored explanations for existing placeholder quizzes

    static let silverArray002Explanation = Explanation(
        id: "explain-silver-array-002",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        int[][] array = new int[2][];
        array[0] = new int[2];
        array[0][1] = 5;
        System.out.println(array[0][1] + " " + array[1][0]);
    }
}
""",
        steps: [
            Step(index: 0, narration: "`new int[2][]` では2次元目は未初期化で、`array[0]` と `array[1]` は最初nullです。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`array[0]` のみ配列を割り当てて値5を設定します。`array[1]` は依然nullです。", highlightLines: [4, 5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "`array[1][0]` アクセス時の結果は？", choices: ["0が返る", "NullPointerException", "コンパイルエラー"], answerIndex: 1, hint: "array[1] の参照先がない", afterExplanation: "正解です。null参照の要素アクセスでNPEです。")),
            Step(index: 2, narration: "`array[1][0]` で `NullPointerException` が発生します。", highlightLines: [6], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
        ]
    )

    static let silverClasses002Explanation = Explanation(
        id: "explain-silver-classes-002",
        initialCode: """
public class Test {
    static int count = 0;
    Test() { count++; }
    public static void main(String[] args) {
        Test t1 = new Test();
        Test t2 = new Test();
        t1.count = 5;
        System.out.println(t2.count);
    }
}
""",
        steps: [
            Step(index: 0, narration: "`count` はstaticなのでクラスで1つだけ共有されます。2回のnewでcountは2になります。", highlightLines: [2, 3, 5, 6], variables: [Variable(name: "Test.count", type: "int", value: "2", scope: "class")], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
            Step(index: 1, narration: "`t1.count = 5` は実体として `Test.count = 5` と同じです。", highlightLines: [7], variables: [Variable(name: "Test.count", type: "int", value: "5", scope: "class")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: PredictPrompt(question: "`t2.count` はいくつ？", choices: ["2", "5", "コンパイルエラー"], answerIndex: 1, hint: "t1/t2経由でも同じstatic変数", afterExplanation: "正解です。共有値5です。")),
            Step(index: 2, narration: "出力は `5` です。", highlightLines: [8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    static let silverCollections001Explanation = Explanation(
        id: "explain-silver-collections-001",
        initialCode: """
import java.util.List;
public class Test {
    public static void main(String[] args) {
        try {
            var list = List.of("Apple", null, "Banana");
            System.out.println(list.size());
        } catch (NullPointerException e) {
            System.out.println("NPE");
        } catch (UnsupportedOperationException e) {
            System.out.println("UOE");
        }
    }
}
""",
        steps: [
            Step(index: 0, narration: "`List.of(...)` はnull要素を許可しません。生成時に即チェックされます。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
            Step(index: 1, narration: "nullを含むため `NullPointerException` が投げられ、NPE用catchに入ります。", highlightLines: [7, 8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: PredictPrompt(question: "UOE catchに入る？", choices: ["入る", "入らない"], answerIndex: 1, hint: "今回は生成時nullチェック", afterExplanation: "正解です。UOEではなくNPEです。")),
            Step(index: 2, narration: "最終出力は `NPE` です。", highlightLines: [8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    static let silverControlFlow001Explanation = Explanation(
        id: "explain-silver-control-flow-001",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        int val = 2;
        String res = switch (val) {
            case 1 -> "One";
            case 2 -> { yield "Two"; }
            default -> "Other";
        };
        System.out.println(res);
    }
}
""",
        steps: [
            Step(index: 0, narration: "`val` は2なので switch式は `case 2` を選択します。", highlightLines: [3, 6], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
            Step(index: 1, narration: "ブロック形式のcaseでは `yield \"Two\"` で式の値を返します。", highlightLines: [6], variables: [Variable(name: "res", type: "String", value: "\"Two\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: PredictPrompt(question: "resの値は？", choices: ["Two", "Other", "コンパイルエラー"], answerIndex: 0, hint: "switch式 + yield", afterExplanation: "正解です。Twoです。")),
            Step(index: 2, narration: "`println(res)` で `Two` が出力されます。", highlightLines: [9], variables: [], callStack: [CallStackFrame(method: "main", line: 9)], heap: [], predict: nil),
        ]
    )

    static let silverDataTypes002Explanation = Explanation(
        id: "explain-silver-data-types-002",
        initialCode: """
public class Test {
    static void modify(String s, StringBuilder sb) {
        s = s.concat("World");
        sb.append("World");
    }
    public static void main(String[] args) {
        String str = "Hello";
        StringBuilder builder = new StringBuilder("Hello");
        modify(str, builder);
        System.out.println(str + " " + builder);
    }
}
""",
        steps: [
            Step(index: 0, narration: "`str` は不変String、`builder` は可変StringBuilderです。", highlightLines: [7, 8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
            Step(index: 1, narration: "`modify` 内で `s = s.concat(...)` はローカル参照の付け替えだけ。一方 `sb.append(...)` は同じオブジェクトを変更します。", highlightLines: [3, 4], variables: [], callStack: [CallStackFrame(method: "modify", line: 4)], heap: [], predict: PredictPrompt(question: "呼び出し後の出力は？", choices: ["HelloWorld HelloWorld", "Hello HelloWorld", "Hello Hello"], answerIndex: 1, hint: "String不変 / StringBuilder可変", afterExplanation: "正解です。Hello HelloWorldです。")),
            Step(index: 2, narration: "最終出力は `Hello HelloWorld` です。", highlightLines: [10], variables: [], callStack: [CallStackFrame(method: "main", line: 10)], heap: [], predict: nil),
        ]
    )

    static let silverException002Explanation = Explanation(
        id: "explain-silver-exception-002",
        initialCode: """
public class Test {
    static class Resource implements AutoCloseable {
        String name;
        Resource(String name) { this.name = name; }
        public void close() { System.out.print(name + " "); }
    }
    public static void main(String[] args) {
        try (Resource r1 = new Resource("A");
             Resource r2 = new Resource("B")) {
            System.out.print("Run ");
        }
    }
}
""",
        steps: [
            Step(index: 0, narration: "try-with-resources本体で `Run` が先に出力されます。", highlightLines: [10], variables: [], callStack: [CallStackFrame(method: "main", line: 10)], heap: [], predict: nil),
            Step(index: 1, narration: "ブロック終了時、リソースは宣言の逆順（r2→r1）で close されます。", highlightLines: [8, 9], variables: [], callStack: [CallStackFrame(method: "main", line: 11)], heap: [], predict: PredictPrompt(question: "close順は？", choices: ["A→B", "B→A"], answerIndex: 1, hint: "LIFOで解放", afterExplanation: "正解です。B→Aです。")),
            Step(index: 2, narration: "最終出力は `Run B A` です。", highlightLines: [5, 10], variables: [], callStack: [CallStackFrame(method: "main", line: 11)], heap: [], predict: nil),
        ]
    )

    static let silverJavaBasics001Explanation = Explanation(
        id: "explain-silver-java-basics-001",
        initialCode: """
public class Test {
    int instanceVar;
    public static void main(String[] args) {
        int localVar;
        Test t = new Test();
        if (t.instanceVar == 0) {
            localVar = 10;
        }
        System.out.println(localVar);
    }
}
""",
        steps: [
            Step(index: 0, narration: "instanceVarはフィールドなのでデフォルト0ですが、localVarはローカル変数で未初期化です。", highlightLines: [2, 4], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "コンパイラはif条件の実行時真偽を前提にせず、`localVar` が未代入の経路ありと判断します。", highlightLines: [6, 9], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "結果は？", choices: ["10が出力", "0が出力", "コンパイルエラー"], answerIndex: 2, hint: "ローカル変数の確実代入規則", afterExplanation: "正解です。確実代入違反でコンパイルエラーです。")),
            Step(index: 2, narration: "このコードはコンパイルエラーです。", highlightLines: [9], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let silverOverload002Explanation = Explanation(
        id: "explain-silver-overload-002",
        initialCode: """
public class Test {
    static void call(long x) { System.out.println("long"); }
    static void call(Integer x) { System.out.println("Integer"); }
    public static void main(String[] args) {
        call(10);
    }
}
""",
        steps: [
            Step(index: 0, narration: "`10` はintリテラルで、call(long)とcall(Integer)の両候補を検討します。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
            Step(index: 1, narration: "オーバーロード解決では型昇格（int→long）がボクシング（int→Integer）より優先されます。", highlightLines: [2, 3], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "選ばれるメソッドは？", choices: ["call(long)", "call(Integer)", "曖昧エラー"], answerIndex: 0, hint: "widening優先", afterExplanation: "正解です。call(long)です。")),
            Step(index: 2, narration: "最終出力は `long` です。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "call(long)", line: 2)], heap: [], predict: nil),
        ]
    )

    static let silverArrayDefaults001Explanation = Explanation(
        id: "explain-silver-array-defaults-001",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        int[] nums = new int[3];
        System.out.println(nums[1]);
    }
}
""",
        steps: [
            Step(index: 0, narration: "`new int[3]` で要素はすべて0に初期化されます。", highlightLines: [3], variables: [Variable(name: "nums", type: "int[]", value: "[0,0,0]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`nums[1]` は2番目の要素で値は0です。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "出力は？", choices: ["0", "null", "コンパイルエラー"], answerIndex: 0, hint: "int配列のデフォルト値", afterExplanation: "正解です。0です。")),
            Step(index: 2, narration: "最終出力は `0` です。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let silverConstructor001Explanation = Explanation(
        id: "explain-silver-constructor-001",
        initialCode: """
class Test {
    Test() { this(10); }
    Test(int x) { System.out.print(x); }
    public static void main(String[] args) {
        new Test();
    }
}
""",
        steps: [
            Step(index: 0, narration: "`new Test()` で引数なしコンストラクタが呼ばれ、先頭の `this(10)` で引数ありへ移動します。", highlightLines: [2, 5], variables: [], callStack: [CallStackFrame(method: "Test()", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`Test(int x)` で `10` が出力されます。", highlightLines: [3], variables: [Variable(name: "x", type: "int", value: "10", scope: "Test(int)")], callStack: [CallStackFrame(method: "Test(int)", line: 3)], heap: [], predict: PredictPrompt(question: "最終出力は？", choices: ["10", "0", "コンパイルエラー"], answerIndex: 0, hint: "this(10) の遷移先", afterExplanation: "正解です。10です。")),
            Step(index: 2, narration: "最終出力は `10` です。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let silverControlFlow002Explanation = Explanation(
        id: "explain-silver-control-flow-002",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        int i = 0;
        while (i < 3) {
            i++;
            if (i == 2) continue;
            System.out.print(i + " ");
        }
    }
}
""",
        steps: [
            Step(index: 0, narration: "i=1でcontinue条件に当たらず `1` を出力します。", highlightLines: [4, 7], variables: [Variable(name: "i", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
            Step(index: 1, narration: "i=2ではcontinueによりprintをスキップ、i=3ではprintされます。", highlightLines: [5, 6, 7], variables: [Variable(name: "i", type: "int", value: "2 -> 3", scope: "main")], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: PredictPrompt(question: "出力は？", choices: ["1 2 3", "1 3", "2 3"], answerIndex: 1, hint: "i==2はskip", afterExplanation: "正解です。1 3です。")),
            Step(index: 2, narration: "最終出力は `1 3` です。", highlightLines: [7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let silverJavaBasics002Explanation = Explanation(
        id: "explain-silver-java-basics-002",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        int x = 1;
        x = x++ + ++x;
        System.out.println(x);
    }
}
""",
        steps: [
            Step(index: 0, narration: "初期値は x=1。`x++` は評価値1を返し、その後xを2にします。", highlightLines: [3, 4], variables: [Variable(name: "x", type: "int", value: "2(途中)", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "`++x` でxは3になり評価値3。式全体は `1 + 3 = 4` となりxに代入されます。", highlightLines: [4], variables: [Variable(name: "x", type: "int", value: "4", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "最終出力は？", choices: ["3", "4", "2"], answerIndex: 1, hint: "後置と前置の評価値", afterExplanation: "正解です。4です。")),
            Step(index: 2, narration: "最終出力は `4` です。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let silverLambda001Explanation = Explanation(
        id: "explain-silver-lambda-001",
        initialCode: """
import java.util.function.Predicate;
public class Test {
    public static void main(String[] args) {
        Predicate<String> p = s -> s.length() > 2;
        System.out.println(p.test("Hi"));
    }
}
""",
        steps: [
            Step(index: 0, narration: "ラムダ `s -> s.length() > 2` は文字列長が3以上ならtrueを返します。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "`p.test(\"Hi\")` では長さ2なので条件はfalseです。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "出力は？", choices: ["true", "false", "コンパイルエラー"], answerIndex: 1, hint: "2 > 2 はfalse", afterExplanation: "正解です。falseです。")),
            Step(index: 2, narration: "最終出力は `false` です。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let silverLambda002Explanation = Explanation(
        id: "explain-silver-lambda-002",
        initialCode: """
import java.util.function.Predicate;

public class Test {
    public static void main(String[] args) {
        Predicate<String> p = s -> s.length() > 2;
        System.out.println(p.negate().test("Hi"));
    }
}
""",
        steps: [
            Step(index: 0, narration: "`p` は `s.length() > 2` を判定するPredicateです。`\"Hi\"` の長さは2なので、元の判定はfalseになります。", highlightLines: [5], variables: [Variable(name: "p", type: "Predicate<String>", value: "length > 2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
            Step(index: 1, narration: "`p.negate()` はPredicateのdefaultメソッドで、元の判定結果を反転します。falseがtrueに反転されます。", highlightLines: [6], variables: [Variable(name: "p.test(\"Hi\")", type: "boolean", value: "false", scope: "main"), Variable(name: "p.negate().test(\"Hi\")", type: "boolean", value: "true", scope: "main")], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: PredictPrompt(question: "printlnされる値は？", choices: ["true", "false", "コンパイルエラー"], answerIndex: 0, hint: "negateは結果を反転する", afterExplanation: "正解です。元がfalseなので反転してtrueです。")),
            Step(index: 2, narration: "最終出力は `true` です。", highlightLines: [6], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
        ]
    )

    static let silverLambda003Explanation = Explanation(
        id: "explain-silver-lambda-003",
        initialCode: """
import java.util.function.Predicate;

public class Test {
    public static void main(String[] args) {
        int base = 1;
        Predicate<Integer> p = x -> x > base;
        base++;
        System.out.println(p.test(2));
    }
}
""",
        steps: [
            Step(index: 0, narration: "`base` はローカル変数です。ラムダ式からローカル変数を参照するには、finalまたは実質的finalである必要があります。", highlightLines: [5, 6], variables: [Variable(name: "base", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
            Step(index: 1, narration: "後続の `base++` により、`base` は実質的finalではなくなります。したがってラムダ式 `x -> x > base` の部分でコンパイルエラーです。", highlightLines: [6, 7], variables: [Variable(name: "base", type: "int", value: "変更される", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: PredictPrompt(question: "このコードの結果は？", choices: ["true", "false", "コンパイルエラー"], answerIndex: 2, hint: "ラムダが捕捉するローカル変数は実質的finalが必要", afterExplanation: "正解です。base++があるためコンパイルエラーです。")),
            Step(index: 2, narration: "実行時例外ではなく、コンパイル時に捕捉規則違反として判定されます。", highlightLines: [6], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let silverLambda004Explanation = Explanation(
        id: "explain-silver-lambda-004",
        initialCode: """
import java.util.function.*;

public class Test {
    public static void main(String[] args) {
        Function<String, String> f = String::trim;
        System.out.println("[" + f.apply(" A ") + "]");
    }
}
""",
        steps: [
            Step(index: 0, narration: "`String::trim` は、引数として受け取ったStringに対して `trim()` を呼ぶ非staticインスタンスメソッド参照です。`Function<String, String>` に適合します。", highlightLines: [5], variables: [Variable(name: "f", type: "Function<String, String>", value: "String::trim", scope: "main")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
            Step(index: 1, narration: "`f.apply(\" A \")` は `\" A \".trim()` と同等で、前後の空白を取り除いて `\"A\"` を返します。", highlightLines: [6], variables: [Variable(name: "f.apply(\" A \")", type: "String", value: "\"A\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: PredictPrompt(question: "出力は？", choices: ["[ A ]", "[A]", "コンパイルエラー"], answerIndex: 1, hint: "trimは前後の空白を削除", afterExplanation: "正解です。角括弧の中はAだけです。")),
            Step(index: 2, narration: "最終出力は `[A]` です。", highlightLines: [6], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
        ]
    )

    static let silverMultiFileOverride001Explanation = Explanation(
        id: "explain-silver-multifile-override-001",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        System.out.println(p.name());
    }
}
""",
        steps: [
            Step(index: 0, narration: "`Parent p = new Child()` で参照型Parent・実体Childになります。", highlightLines: [3], variables: [Variable(name: "p", type: "Parent", value: "ref->Child", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`p.name()` はインスタンスメソッド呼び出しなので実体型Childで動的束縛されます。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "出力は？", choices: ["Parent", "Child", "コンパイルエラー"], answerIndex: 1, hint: "動的束縛", afterExplanation: "正解です。Childです。")),
            Step(index: 2, narration: "最終出力は `Child` です。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let silverStringBuilder001Explanation = Explanation(
        id: "explain-silver-stringbuilder-001",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("A");
        sb.append("B").reverse();
        System.out.println(sb);
    }
}
""",
        steps: [
            Step(index: 0, narration: "初期値は `A`。`append(\"B\")` で `AB` になります。", highlightLines: [3, 4], variables: [Variable(name: "sb", type: "StringBuilder", value: "\"AB\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "続く `reverse()` で `BA` に反転されます。", highlightLines: [4], variables: [Variable(name: "sb", type: "StringBuilder", value: "\"BA\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "出力は？", choices: ["AB", "BA", "A"], answerIndex: 1, hint: "append後にreverse", afterExplanation: "正解です。BAです。")),
            Step(index: 2, narration: "最終出力は `BA` です。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    // MARK: - 解説: メソッド参照の使い分け
        static let goldLambdaMethodReference001Explanation = Explanation(
            id: "explain-gold-lambda-method-ref-001",
            initialCode: """
    String str = "Javasta";
    Supplier<Integer> s = str::length; // 特定
    Function<String, Integer> f = String::length; // 任意
    """,
            steps: [
                Step(index: 1,
                     narration: "特定のオブジェクト `str` を使った参照 `str::length` を作成します。このラムダは、常に `str.length()` を実行する『引数なし・戻り値あり』の処理になるため、Supplierに適合します。",
                     highlightLines: [2, 3],
                     variables: [
                         Variable(name: "str", type: "String", value: "\"Javasta\"", scope: "main"),
                         Variable(name: "s", type: "Supplier", value: "str.length()", scope: "main")
                     ],
                     callStack: [CallStackFrame(method: "main", line: 3)],
                     heap: [], predict: nil),
                Step(index: 2,
                     narration: "クラス名 `String` を使った参照 `String::length` を作成します。これは『文字列を1つ受け取り、その文字列のlength()を呼ぶ』という処理になります。",
                     highlightLines: [6],
                     variables: [
                         Variable(name: "f", type: "Function", value: "(String x) -> x.length()", scope: "main")
                     ],
                     callStack: [CallStackFrame(method: "main", line: 6)],
                     heap: [],
                     predict: PredictPrompt(
                         question: "f.apply(\"Java\") を実行したとき、length() はどの文字列に対して呼び出されますか？",
                         choices: ["元の \"Javasta\"", "引数の \"Java\"", "コンパイルエラーになる"],
                         answerIndex: 1,
                         hint: "クラス名::メソッド名の形式（任意オブジェクトの参照）では、第一引数が呼び出し元になります。",
                         afterExplanation: "正解です！この違いが試験での最大のひっかけポイントです。"
                     )),
                Step(index: 3,
                     narration: "s.get() は固定で 7 を返し、f.apply(\"Java\") は引数に対して実行されるため 4 を返します。\n出力: 7 4",
                     highlightLines: [8],
                     variables: [],
                     callStack: [CallStackFrame(method: "main", line: 8)],
                     heap: [], predict: nil)
            ]
        )

    static let goldLambdaConstructorRef001Explanation = Explanation(
        id: "explain-gold-lambda-constructor-ref-001",
        initialCode: """
Supplier<List<String>> s = ArrayList::new;
List<String> list = s.get();
list.add("Gold");
System.out.println(list.get(0));
""",
        steps: [
            Step(index: 0, narration: "`ArrayList::new` は無引数コンストラクタ参照です。`Supplier.get()` が呼ばれた時点で新しいArrayListを生成します。", highlightLines: [1, 2], variables: [Variable(name: "s", type: "Supplier<List<String>>", value: "ArrayList::new", scope: "main")], callStack: [CallStackFrame(method: "get", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "生成されたリストに `Gold` を追加し、0番目を取り出すため出力は `Gold` です。", highlightLines: [3, 4], variables: [Variable(name: "list", type: "ArrayList<String>", value: "[Gold]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "コンストラクタが実行されるタイミングは？", choices: ["sの代入時", "s.get()呼び出し時"], answerIndex: 1, hint: "Supplierはgetで供給します。", afterExplanation: "正解です。get()でnew ArrayList()相当が動きます。")),
        ]
    )

    static let goldFunctionalLambda001Explanation = Explanation(
        id: "explain-gold-functional-lambda-001",
        initialCode: """
@FunctionalInterface
interface NamedTask {
    void run();
    String toString();
}
NamedTask task = () -> System.out.print("OK");
task.run();
""",
        steps: [
            Step(index: 0, narration: "`run()` は抽象メソッドです。`toString()` はObjectのpublicメソッドと同じシグネチャなので、関数型インターフェース判定では数えません。", highlightLines: [1, 3, 4], variables: [], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "ラムダは `run()` の実装になります。`task.run()` で本体が実行され、`OK` が出力されます。", highlightLines: [6, 7], variables: [Variable(name: "task", type: "NamedTask", value: "lambda", scope: "main")], callStack: [CallStackFrame(method: "run", line: 7)], heap: [], predict: PredictPrompt(question: "SAMとして数える抽象メソッドは？", choices: ["runだけ", "runとtoString"], answerIndex: 0, hint: "Objectメソッドは特別扱いです。", afterExplanation: "正解です。runだけです。")),
        ]
    )

    static let goldFunctionalLambda002Explanation = Explanation(
        id: "explain-gold-functional-lambda-002",
        initialCode: """
var f = (String s) -> s.length();
System.out.println(f.apply("Java"));
""",
        steps: [
            Step(index: 0, narration: "ラムダ式は単独では型が確定せず、`Function<String,Integer>` などのターゲット型が必要です。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`var` は右辺から型を推論しますが、右辺のラムダにターゲット型がないため `var f = ...` の行でコンパイルエラーです。", highlightLines: [1], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "varだけでラムダの型は決まる？", choices: ["決まる", "決まらない"], answerIndex: 1, hint: "ラムダにはターゲット型が必要です。", afterExplanation: "正解です。明示的な関数型インターフェースが必要です。")),
        ]
    )

    static let goldFunctionalLambda003Explanation = Explanation(
        id: "explain-gold-functional-lambda-003",
        initialCode: """
Predicate<String> empty = s -> s.isEmpty();
System.out.println(empty.test(""));
""",
        steps: [
            Step(index: 0, narration: "`Predicate<String>` の抽象メソッドは `boolean test(String)` です。引数1つで型を明示しないため、`s ->` の括弧を省略できます。", highlightLines: [1], variables: [Variable(name: "empty", type: "Predicate<String>", value: "s.isEmpty()", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`empty.test(\"\")` では空文字の `isEmpty()` がtrueなので、出力は `true` です。", highlightLines: [2], variables: [Variable(name: "s", type: "String", value: "\"\"", scope: "lambda")], callStack: [CallStackFrame(method: "test", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda004Explanation = Explanation(
        id: "explain-gold-functional-lambda-004",
        initialCode: """
Function<String, Integer> f = s -> { s.length(); };
System.out.println(f.apply("Java"));
""",
        steps: [
            Step(index: 0, narration: "`Function<String,Integer>` はStringを受け取りIntegerを返す必要があります。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "ブロックラムダ `{ ... }` では値を返すなら `return` が必要です。この本体は値を返していないためコンパイルエラーです。", highlightLines: [1], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "ブロックラムダで戻り値が必要な時は？", choices: ["returnを書く", "最後の式が自動で返る"], answerIndex: 0, hint: "式ラムダとの違いです。", afterExplanation: "正解です。returnが必要です。")),
        ]
    )

    static let goldFunctionalLambda005Explanation = Explanation(
        id: "explain-gold-functional-lambda-005",
        initialCode: """
Consumer<String> c = System.out::print;
c.accept("A");
""",
        steps: [
            Step(index: 0, narration: "`Consumer<String>` の抽象メソッドは `accept(String)` で戻り値はvoidです。`System.out.print(String)` と対応します。", highlightLines: [1], variables: [Variable(name: "c", type: "Consumer<String>", value: "System.out.print", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`c.accept(\"A\")` でprintが実行され、`A` が出力されます。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "accept", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda006Explanation = Explanation(
        id: "explain-gold-functional-lambda-006",
        initialCode: """
Supplier<String> s = () -> "Hi";
System.out.println(s.get());
""",
        steps: [
            Step(index: 0, narration: "`Supplier<T>` は引数なしでTを返します。引数なしラムダは `() ->` と書きます。", highlightLines: [1], variables: [Variable(name: "s", type: "Supplier<String>", value: "\"Hi\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`s.get()` でラムダが評価され、戻り値 `Hi` が出力されます。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "get", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda007Explanation = Explanation(
        id: "explain-gold-functional-lambda-007",
        initialCode: """
BiFunction<String, String, String> join = (a, b) -> a + b;
System.out.println(join.apply("A", "B"));
""",
        steps: [
            Step(index: 0, narration: "`BiFunction<T,U,R>` は2つの引数を受け取り1つの値を返します。2引数ラムダでは括弧が必要です。", highlightLines: [1], variables: [Variable(name: "join", type: "BiFunction<String,String,String>", value: "a + b", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`apply(\"A\", \"B\")` でaがA、bがBになり、連結結果 `AB` が出力されます。", highlightLines: [2], variables: [Variable(name: "a", type: "String", value: "\"A\"", scope: "lambda"), Variable(name: "b", type: "String", value: "\"B\"", scope: "lambda")], callStack: [CallStackFrame(method: "apply", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda008Explanation = Explanation(
        id: "explain-gold-functional-lambda-008",
        initialCode: """
int base = 1;
Supplier<Integer> s = () -> base;
base = 2;
System.out.println(s.get());
""",
        steps: [
            Step(index: 0, narration: "ラムダがローカル変数 `base` を参照しています。このような変数はfinalまたは実質的finalでなければなりません。", highlightLines: [1, 2], variables: [Variable(name: "base", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "3行目で `base` に再代入しているため実質的finalではありません。コンパイルエラーです。", highlightLines: [3], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "再代入されたbaseをラムダで参照できる？", choices: ["できる", "できない"], answerIndex: 1, hint: "実質的finalが必要です。", afterExplanation: "正解です。コンパイルエラーです。")),
        ]
    )

    static let goldFunctionalLambda009Explanation = Explanation(
        id: "explain-gold-functional-lambda-009",
        initialCode: """
List<String> list = new ArrayList<>();
Runnable r = () -> list.add("A");
r.run();
System.out.println(list.size());
""",
        steps: [
            Step(index: 0, narration: "`list` 変数自体は再代入されていないため実質的finalです。ラムダ内で参照できます。", highlightLines: [1, 2], variables: [Variable(name: "list", type: "ArrayList<String>", value: "[]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`r.run()` で参照先のArrayListにAを追加します。変数の再代入ではなくオブジェクトの状態変更なので許され、サイズは1です。", highlightLines: [3, 4], variables: [Variable(name: "list", type: "ArrayList<String>", value: "[A]", scope: "main")], callStack: [CallStackFrame(method: "run", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda010Explanation = Explanation(
        id: "explain-gold-functional-lambda-010",
        initialCode: """
Function<String, Integer> f = Integer::parseInt;
System.out.println(f.apply("123") + 1);
""",
        steps: [
            Step(index: 0, narration: "`Integer::parseInt` は `String -> int` の静的メソッド参照です。戻り値intはFunctionのIntegerへボクシングされます。", highlightLines: [1], variables: [Variable(name: "f", type: "Function<String,Integer>", value: "Integer.parseInt", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`f.apply(\"123\")` はIntegerの123です。`+ 1` は数値加算なので出力は `124` です。", highlightLines: [2], variables: [Variable(name: "f.apply", type: "Integer", value: "123", scope: "main")], callStack: [CallStackFrame(method: "apply", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda011Explanation = Explanation(
        id: "explain-gold-functional-lambda-011",
        initialCode: """
Function<String, String> f = String::toUpperCase;
System.out.println(f.apply("java"));
""",
        steps: [
            Step(index: 0, narration: "`String::toUpperCase` は任意オブジェクトのインスタンスメソッド参照です。Functionの引数がレシーバになります。", highlightLines: [1], variables: [Variable(name: "f", type: "Function<String,String>", value: "s -> s.toUpperCase()", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`f.apply(\"java\")` は `\"java\".toUpperCase()` と同等なので、`JAVA` を出力します。", highlightLines: [2], variables: [Variable(name: "receiver", type: "String", value: "\"java\"", scope: "lambda")], callStack: [CallStackFrame(method: "apply", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda012Explanation = Explanation(
        id: "explain-gold-functional-lambda-012",
        initialCode: """
String prefix = "Hi ";
Function<String, String> f = prefix::concat;
System.out.println(f.apply("Java"));
""",
        steps: [
            Step(index: 0, narration: "`prefix::concat` は特定オブジェクト `prefix` を固定レシーバにするメソッド参照です。", highlightLines: [1, 2], variables: [Variable(name: "prefix", type: "String", value: "\"Hi \"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`f.apply(\"Java\")` は `prefix.concat(\"Java\")` と同等です。出力は `Hi Java` です。", highlightLines: [3], variables: [Variable(name: "argument", type: "String", value: "\"Java\"", scope: "lambda")], callStack: [CallStackFrame(method: "apply", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda013Explanation = Explanation(
        id: "explain-gold-functional-lambda-013",
        initialCode: """
Function<String, StringBuilder> f = StringBuilder::new;
System.out.println(f.apply("abc").reverse());
""",
        steps: [
            Step(index: 0, narration: "`StringBuilder::new` はStringを受け取るコンストラクタ参照として、`Function<String,StringBuilder>` に適合します。", highlightLines: [1], variables: [Variable(name: "f", type: "Function<String,StringBuilder>", value: "new StringBuilder(String)", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`abc` からStringBuilderを作り、`reverse()` で反転するため出力は `cba` です。", highlightLines: [2], variables: [Variable(name: "builder", type: "StringBuilder", value: "\"cba\"", scope: "main")], callStack: [CallStackFrame(method: "apply", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda014Explanation = Explanation(
        id: "explain-gold-functional-lambda-014",
        initialCode: """
IntFunction<int[]> maker = int[]::new;
System.out.println(maker.apply(3).length);
""",
        steps: [
            Step(index: 0, narration: "`int[]::new` は配列コンストラクタ参照です。`IntFunction<int[]>` のint引数が配列長になります。", highlightLines: [1], variables: [Variable(name: "maker", type: "IntFunction<int[]>", value: "int[]::new", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`maker.apply(3)` は長さ3のint配列を返します。要素初期値ではなくlengthを出しているため `3` です。", highlightLines: [2], variables: [Variable(name: "array.length", type: "int", value: "3", scope: "main")], callStack: [CallStackFrame(method: "apply", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda015Explanation = Explanation(
        id: "explain-gold-functional-lambda-015",
        initialCode: """
IntPredicate even = i -> i % 2 == 0;
System.out.println(even.test(4));
""",
        steps: [
            Step(index: 0, narration: "`IntPredicate` はintを受け取りbooleanを返すプリミティブ特化インターフェースです。", highlightLines: [1], variables: [Variable(name: "even", type: "IntPredicate", value: "i % 2 == 0", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`even.test(4)` では4 % 2が0なので、出力は `true` です。", highlightLines: [2], variables: [Variable(name: "i", type: "int", value: "4", scope: "lambda")], callStack: [CallStackFrame(method: "test", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda016Explanation = Explanation(
        id: "explain-gold-functional-lambda-016",
        initialCode: """
IntUnaryOperator op = i -> i + 1;
System.out.println(op.applyAsInt(5));
""",
        steps: [
            Step(index: 0, narration: "`IntUnaryOperator` はintを受け取りintを返します。実行メソッドは `applyAsInt` です。", highlightLines: [1, 2], variables: [Variable(name: "op", type: "IntUnaryOperator", value: "i + 1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "5に1を足して6を返すため、出力は `6` です。", highlightLines: [2], variables: [Variable(name: "return", type: "int", value: "6", scope: "lambda")], callStack: [CallStackFrame(method: "applyAsInt", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda017Explanation = Explanation(
        id: "explain-gold-functional-lambda-017",
        initialCode: """
ToIntFunction<String> length = String::length;
System.out.println(length.applyAsInt("Gold"));
""",
        steps: [
            Step(index: 0, narration: "`ToIntFunction<String>` はStringを受け取りintを返します。`String::length` はこの形に適合します。", highlightLines: [1], variables: [Variable(name: "length", type: "ToIntFunction<String>", value: "String::length", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`Gold` の長さは4です。`applyAsInt` の戻り値はプリミティブintなので出力は `4` です。", highlightLines: [2], variables: [Variable(name: "receiver", type: "String", value: "\"Gold\"", scope: "lambda")], callStack: [CallStackFrame(method: "applyAsInt", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda018Explanation = Explanation(
        id: "explain-gold-functional-lambda-018",
        initialCode: """
DoubleBinaryOperator div = (a, b) -> a / b;
System.out.println(div.applyAsDouble(5.0, 2.0));
""",
        steps: [
            Step(index: 0, narration: "`DoubleBinaryOperator` はdoubleを2つ受け取りdoubleを返します。実行メソッドは `applyAsDouble` です。", highlightLines: [1, 2], variables: [Variable(name: "div", type: "DoubleBinaryOperator", value: "a / b", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "5.0 / 2.0 はdouble除算なので2.5です。出力は `2.5` です。", highlightLines: [2], variables: [Variable(name: "return", type: "double", value: "2.5", scope: "lambda")], callStack: [CallStackFrame(method: "applyAsDouble", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda019Explanation = Explanation(
        id: "explain-gold-functional-lambda-019",
        initialCode: """
LongSupplier s = () -> 10L;
LongUnaryOperator twice = x -> x * 2;
System.out.println(twice.applyAsLong(s.getAsLong()));
""",
        steps: [
            Step(index: 0, narration: "`LongSupplier.getAsLong()` が10Lを返します。`LongUnaryOperator` はlongを受け取りlongを返します。", highlightLines: [1, 2, 3], variables: [Variable(name: "s.getAsLong()", type: "long", value: "10", scope: "main")], callStack: [CallStackFrame(method: "getAsLong", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`twice.applyAsLong(10)` は20を返します。出力は `20` です。", highlightLines: [3], variables: [Variable(name: "return", type: "long", value: "20", scope: "lambda")], callStack: [CallStackFrame(method: "applyAsLong", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda020Explanation = Explanation(
        id: "explain-gold-functional-lambda-020",
        initialCode: """
Function<Integer, Integer> plusOne = x -> x + 1;
Function<Integer, Integer> timesTwo = x -> x * 2;
System.out.println(
    plusOne.andThen(timesTwo).apply(3) + ":" +
    plusOne.compose(timesTwo).apply(3)
);
""",
        steps: [
            Step(index: 0, narration: "`andThen` は左の関数を先に実行してから右の関数を実行します。`plusOne.andThen(timesTwo).apply(3)` は `(3 + 1) * 2` で8です。", highlightLines: [1, 2, 4], variables: [Variable(name: "andThen", type: "Integer", value: "8", scope: "main")], callStack: [CallStackFrame(method: "apply", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "`compose` は引数の関数を先に実行します。`plusOne.compose(timesTwo).apply(3)` は `(3 * 2) + 1` で7なので、出力は `8:7` です。", highlightLines: [5], variables: [Variable(name: "compose", type: "Integer", value: "7", scope: "main")], callStack: [CallStackFrame(method: "apply", line: 5)], heap: [], predict: PredictPrompt(question: "andThen側の値は？", choices: ["8", "7"], answerIndex: 0, hint: "plusOneの後にtimesTwoです。", afterExplanation: "正解です。8です。")),
        ]
    )

    static let goldFunctionalLambda021Explanation = Explanation(
        id: "explain-gold-functional-lambda-021",
        initialCode: """
Predicate<String> p = s -> { System.out.print("A"); return true; };
Predicate<String> q = s -> { System.out.print("B"); return true; };
System.out.println(p.or(q).test("x"));
""",
        steps: [
            Step(index: 0, narration: "`Predicate.or` は短絡評価します。まず左側のpが評価され、`A` を出力してtrueを返します。", highlightLines: [1, 3], variables: [Variable(name: "p.test", type: "boolean", value: "true", scope: "main")], callStack: [CallStackFrame(method: "test", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "左がtrueなのでqは実行されず、`B` は出ません。printlnが結果trueを続けて出すため、全体は `Atrue` です。", highlightLines: [2, 3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: PredictPrompt(question: "qは実行される？", choices: ["される", "されない"], answerIndex: 1, hint: "orの左がtrueです。", afterExplanation: "正解です。短絡します。")),
        ]
    )

    static let goldFunctionalLambda022Explanation = Explanation(
        id: "explain-gold-functional-lambda-022",
        initialCode: """
Function<Integer, Integer> f = x -> x + 1;
Integer result = f.apply(1);
System.out.println(result);
""",
        steps: [
            Step(index: 0, narration: "`Function<Integer,Integer>` の引数xはIntegerです。`x + 1` の演算時にxはintへアンボクシングされます。", highlightLines: [1], variables: [Variable(name: "x", type: "Integer", value: "1", scope: "lambda")], callStack: [CallStackFrame(method: "apply", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "計算結果2は戻り値Integerへボクシングされます。`result` は2なので出力は `2` です。", highlightLines: [2, 3], variables: [Variable(name: "result", type: "Integer", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda023Explanation = Explanation(
        id: "explain-gold-functional-lambda-023",
        initialCode: """
IntFunction<Integer> f = i -> i;
System.out.println(f.apply(3).getClass().getSimpleName());
""",
        steps: [
            Step(index: 0, narration: "`IntFunction<R>` はintを受け取りますが、戻り値Rは参照型です。ここではRがIntegerです。", highlightLines: [1], variables: [Variable(name: "i", type: "int", value: "3", scope: "lambda")], callStack: [CallStackFrame(method: "apply", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "戻り値のint 3はIntegerにボクシングされます。実体クラス名は `Integer` です。", highlightLines: [2], variables: [Variable(name: "f.apply(3)", type: "Integer", value: "3", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda024Explanation = Explanation(
        id: "explain-gold-functional-lambda-024",
        initialCode: """
BiFunction<String, String, String> f = (var a, var b) -> a + b;
System.out.println(f.apply("A", "B"));
""",
        steps: [
            Step(index: 0, narration: "ラムダ引数に `var` を使う場合、すべての仮引数で一貫して `var` を使えば有効です。", highlightLines: [1], variables: [Variable(name: "a", type: "String", value: "inferred", scope: "lambda"), Variable(name: "b", type: "String", value: "inferred", scope: "lambda")], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`apply(\"A\", \"B\")` でAとBを連結し、出力は `AB` です。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "apply", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda025Explanation = Explanation(
        id: "explain-gold-functional-lambda-025",
        initialCode: """
BiFunction<String, String, String> f = (var a, b) -> a + b;
System.out.println(f.apply("A", "B"));
""",
        steps: [
            Step(index: 0, narration: "`var` 付き引数と暗黙型引数を同じラムダの仮引数リストで混在させることはできません。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`(var a, b)` の `b` も `var b` にするか、両方からvarを外す必要があります。このコードはコンパイルエラーです。", highlightLines: [1], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "varと暗黙型は混在できる？", choices: ["できる", "できない"], answerIndex: 1, hint: "ラムダ引数の一貫性ルールです。", afterExplanation: "正解です。混在できません。")),
        ]
    )

    static let goldFunctionalLambda026Explanation = Explanation(
        id: "explain-gold-functional-lambda-026",
        initialCode: """
IntSupplier supplier = () -> 10;
IntConsumer consumer = x -> System.out.print(x);
consumer.accept(supplier.getAsInt());
""",
        steps: [
            Step(index: 0, narration: "`IntSupplier` は引数なしでintを返すため、`getAsInt()` の結果は10です。", highlightLines: [1, 3], variables: [Variable(name: "supplier.getAsInt()", type: "int", value: "10", scope: "main")], callStack: [CallStackFrame(method: "getAsInt", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`IntConsumer.accept(int)` が10を受け取り、そのまま出力します。Boxingは不要です。", highlightLines: [2, 3], variables: [Variable(name: "x", type: "int", value: "10", scope: "lambda")], callStack: [CallStackFrame(method: "accept", line: 3)], heap: [], predict: PredictPrompt(question: "出力は？", choices: ["10", "10.0", "何も出ない"], answerIndex: 0, hint: "getAsIntの戻り値がacceptに渡る", afterExplanation: "正解です。10です。")),
        ]
    )

    static let goldFunctionalLambda027Explanation = Explanation(
        id: "explain-gold-functional-lambda-027",
        initialCode: """
IntBinaryOperator op = (a, b) -> a * b + 1;
System.out.println(op.applyAsInt(2, 3));
""",
        steps: [
            Step(index: 0, narration: "`IntBinaryOperator` は2つのintを受け取りintを返します。`applyAsInt(2, 3)` でa=2、b=3です。", highlightLines: [1, 2], variables: [Variable(name: "a", type: "int", value: "2", scope: "lambda"), Variable(name: "b", type: "int", value: "3", scope: "lambda")], callStack: [CallStackFrame(method: "applyAsInt", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "ラムダ本体は `2 * 3 + 1` なので7。出力は `7` です。", highlightLines: [1, 2], variables: [Variable(name: "return", type: "int", value: "7", scope: "lambda")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda028Explanation = Explanation(
        id: "explain-gold-functional-lambda-028",
        initialCode: """
IntToDoubleFunction half = x -> x / 2.0;
System.out.println(half.applyAsDouble(5));
""",
        steps: [
            Step(index: 0, narration: "`IntToDoubleFunction` はintを受け取りdoubleを返します。`applyAsDouble(5)` でx=5です。", highlightLines: [1, 2], variables: [Variable(name: "x", type: "int", value: "5", scope: "lambda")], callStack: [CallStackFrame(method: "applyAsDouble", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`x / 2.0` はdouble演算なので `5 / 2.0 = 2.5`。出力は `2.5` です。", highlightLines: [1, 2], variables: [Variable(name: "return", type: "double", value: "2.5", scope: "lambda")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda029Explanation = Explanation(
        id: "explain-gold-functional-lambda-029",
        initialCode: """
DoubleUnaryOperator add = d -> d + 1.0;
DoubleUnaryOperator square = d -> d * d;
System.out.println(
    add.andThen(square).applyAsDouble(2.0) + ":" +
    add.compose(square).applyAsDouble(2.0)
);
""",
        steps: [
            Step(index: 0, narration: "`andThen` はaddを先に実行してからsquareを実行します。2.0に1.0を足して3.0、二乗して9.0です。", highlightLines: [1, 2, 4], variables: [Variable(name: "andThen", type: "double", value: "9.0", scope: "main")], callStack: [CallStackFrame(method: "applyAsDouble", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "`compose` は引数側のsquareが先です。2.0を二乗して4.0、それに1.0を足して5.0。出力は `9.0:5.0` です。", highlightLines: [5], variables: [Variable(name: "compose", type: "double", value: "5.0", scope: "main")], callStack: [CallStackFrame(method: "applyAsDouble", line: 5)], heap: [], predict: PredictPrompt(question: "compose側の値は？", choices: ["9.0", "5.0"], answerIndex: 1, hint: "composeはsquareが先", afterExplanation: "正解です。5.0です。")),
        ]
    )

    static let goldFunctionalLambda030Explanation = Explanation(
        id: "explain-gold-functional-lambda-030",
        initialCode: """
DoublePredicate p = d -> d == Double.NaN;
System.out.println(p.test(Double.NaN));
""",
        steps: [
            Step(index: 0, narration: "`DoublePredicate` はdoubleを受け取ってbooleanを返します。ここではNaNを `==` で比較しています。", highlightLines: [1, 2], variables: [Variable(name: "d", type: "double", value: "NaN", scope: "lambda")], callStack: [CallStackFrame(method: "test", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "NaNは自分自身とも `==` では等しくありません。そのため `p.test(Double.NaN)` はfalseです。", highlightLines: [1, 2], variables: [Variable(name: "return", type: "boolean", value: "false", scope: "lambda")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "NaN == NaN は？", choices: ["true", "false"], answerIndex: 1, hint: "NaN比較の特例", afterExplanation: "正解です。falseです。")),
        ]
    )

    static let goldFunctionalLambda031Explanation = Explanation(
        id: "explain-gold-functional-lambda-031",
        initialCode: """
LongBinaryOperator op = (a, b) -> a * b;
System.out.println(op.applyAsLong(6L, 7L));
""",
        steps: [
            Step(index: 0, narration: "`LongBinaryOperator` は2つのlongを受け取りlongを返します。`applyAsLong(6L, 7L)` でa=6、b=7です。", highlightLines: [1, 2], variables: [Variable(name: "a", type: "long", value: "6", scope: "lambda"), Variable(name: "b", type: "long", value: "7", scope: "lambda")], callStack: [CallStackFrame(method: "applyAsLong", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`6L * 7L` は42L。printlnでは `42` と表示されます。", highlightLines: [1, 2], variables: [Variable(name: "return", type: "long", value: "42", scope: "lambda")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda032Explanation = Explanation(
        id: "explain-gold-functional-lambda-032",
        initialCode: """
LongToIntFunction f = x -> (int) x;
System.out.println(f.applyAsInt(2147483648L));
""",
        steps: [
            Step(index: 0, narration: "`LongToIntFunction` はlongを受け取りintを返します。ラムダ内で `(int) x` と明示キャストしています。", highlightLines: [1, 2], variables: [Variable(name: "x", type: "long", value: "2147483648", scope: "lambda")], callStack: [CallStackFrame(method: "applyAsInt", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "2147483648Lはint最大値を1超えています。intへキャストすると下位32ビットが使われ、`-2147483648` になります。", highlightLines: [1, 2], variables: [Variable(name: "return", type: "int", value: "-2147483648", scope: "lambda")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "キャスト結果は？", choices: ["2147483648", "-2147483648", "例外"], answerIndex: 1, hint: "int範囲を超えています", afterExplanation: "正解です。intの最小値になります。")),
        ]
    )

    static let goldFunctionalLambda033Explanation = Explanation(
        id: "explain-gold-functional-lambda-033",
        initialCode: """
ObjIntConsumer<StringBuilder> c = (sb, i) -> sb.append(i);
StringBuilder sb = new StringBuilder("A");
c.accept(sb, 3);
System.out.println(sb);
""",
        steps: [
            Step(index: 0, narration: "`ObjIntConsumer<T>` はT型のオブジェクトとintを受け取り、戻り値なしで処理します。ここではStringBuilderと3を渡します。", highlightLines: [1, 3], variables: [Variable(name: "sb", type: "StringBuilder", value: "\"A\"", scope: "main"), Variable(name: "i", type: "int", value: "3", scope: "lambda")], callStack: [CallStackFrame(method: "accept", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`sb.append(i)` で末尾に3が追加されます。StringBuilderは同じオブジェクトを変更するので出力は `A3` です。", highlightLines: [1, 4], variables: [Variable(name: "sb", type: "StringBuilder", value: "\"A3\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda034Explanation = Explanation(
        id: "explain-gold-functional-lambda-034",
        initialCode: """
ToDoubleFunction<String> f = Double::parseDouble;
System.out.println(f.applyAsDouble("1.5") + 1);
""",
        steps: [
            Step(index: 0, narration: "`Double::parseDouble` はStringを受け取りdoubleを返すため、`ToDoubleFunction<String>` に適合します。", highlightLines: [1], variables: [Variable(name: "f", type: "ToDoubleFunction<String>", value: "Double.parseDouble", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`f.applyAsDouble(\"1.5\")` は1.5です。数値加算で1を足すため、出力は `2.5` です。", highlightLines: [2], variables: [Variable(name: "applyAsDouble", type: "double", value: "1.5", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda035Explanation = Explanation(
        id: "explain-gold-functional-lambda-035",
        initialCode: """
Predicate<String> p = s -> { System.out.print("A"); return false; };
Predicate<String> q = s -> { System.out.print("B"); return true; };
System.out.println(p.and(q).test("x"));
""",
        steps: [
            Step(index: 0, narration: "`Predicate.and` は左から評価します。まずpが実行され、`A` を出力してfalseを返します。", highlightLines: [1, 3], variables: [Variable(name: "p.test", type: "boolean", value: "false", scope: "main")], callStack: [CallStackFrame(method: "test", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "andは左がfalseなら短絡するためqは実行されません。`B` は出ず、printlnがfalseを続けて出すので `Afalse` です。", highlightLines: [2, 3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: PredictPrompt(question: "qは実行される？", choices: ["される", "されない"], answerIndex: 1, hint: "andの左がfalse", afterExplanation: "正解です。短絡します。")),
        ]
    )

    static let goldFunctionalLambda036Explanation = Explanation(
        id: "explain-gold-functional-lambda-036",
        initialCode: """
Function<String, String> id = Function.identity();
System.out.println(id.andThen(String::toUpperCase).apply("go"));
""",
        steps: [
            Step(index: 0, narration: "`Function.identity()` は入力をそのまま返す関数です。代入先型から `String -> String` と推論されます。", highlightLines: [1], variables: [Variable(name: "id", type: "Function<String,String>", value: "x -> x", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`andThen(String::toUpperCase)` により、identityで返した `\"go\"` にtoUpperCaseが適用されます。出力は `GO` です。", highlightLines: [2], variables: [Variable(name: "value", type: "String", value: "\"GO\"", scope: "main")], callStack: [CallStackFrame(method: "apply", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda037Explanation = Explanation(
        id: "explain-gold-functional-lambda-037",
        initialCode: """
UnaryOperator<String> op = String::toUpperCase;
System.out.println(op.apply("java"));
""",
        steps: [
            Step(index: 0, narration: "`UnaryOperator<T>` は `Function<T,T>` の特殊形です。`String::toUpperCase` はStringを受け取りStringを返す形に適合します。", highlightLines: [1], variables: [Variable(name: "op", type: "UnaryOperator<String>", value: "String::toUpperCase", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`op.apply(\"java\")` は `\"java\".toUpperCase()` と同等です。出力は `JAVA` です。", highlightLines: [2], variables: [Variable(name: "return", type: "String", value: "\"JAVA\"", scope: "main")], callStack: [CallStackFrame(method: "apply", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda038Explanation = Explanation(
        id: "explain-gold-functional-lambda-038",
        initialCode: """
BinaryOperator<Integer> max = BinaryOperator.maxBy(Integer::compare);
System.out.println(max.apply(3, 5));
""",
        steps: [
            Step(index: 0, narration: "`BinaryOperator.maxBy` はComparatorで大きいと判断された値を返すBinaryOperatorを作ります。", highlightLines: [1], variables: [Variable(name: "max", type: "BinaryOperator<Integer>", value: "maxBy(Integer::compare)", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`Integer::compare` で3と5を比較すると5が大きいので、`max.apply(3, 5)` は5を返します。", highlightLines: [2], variables: [Variable(name: "return", type: "Integer", value: "5", scope: "main")], callStack: [CallStackFrame(method: "apply", line: 2)], heap: [], predict: PredictPrompt(question: "maxByが返す値は？", choices: ["3", "5", "8"], answerIndex: 1, hint: "compareで大きい方", afterExplanation: "正解です。5です。")),
        ]
    )

    static let goldFunctionalLambda039Explanation = Explanation(
        id: "explain-gold-functional-lambda-039",
        initialCode: """
Integer a = 100;
Integer b = 100;
Integer c = 200;
Integer d = 200;
System.out.println((a == b) + ":" + (c == d));
""",
        steps: [
            Step(index: 0, narration: "オートボクシングでは通常 `Integer.valueOf` が使われます。標準では -128 から 127 のIntegerがキャッシュされます。", highlightLines: [1, 2, 3, 4], variables: [Variable(name: "a == b", type: "boolean", value: "true", scope: "main"), Variable(name: "c == d", type: "boolean", value: "false", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`100` はキャッシュ範囲内なので同一参照、`200` は標準範囲外なので別参照です。`==` は参照比較のため出力は `true:false` です。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "a == b の結果は？", choices: ["true", "false"], answerIndex: 0, hint: "100はIntegerキャッシュ範囲内", afterExplanation: "正解です。trueです。")),
        ]
    )

    static let goldFunctionalLambda040Explanation = Explanation(
        id: "explain-gold-functional-lambda-040",
        initialCode: """
Integer x = null;
int y = x;
System.out.println(y);
""",
        steps: [
            Step(index: 0, narration: "`Integer x = null` は参照型なので有効です。しかし `int y = x` ではIntegerからintへのアンボクシングが必要になります。", highlightLines: [1, 2], variables: [Variable(name: "x", type: "Integer", value: "null", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "アンボクシングは実質的に `x.intValue()` を呼ぶ動きです。xがnullなのでこの行でNullPointerExceptionが発生し、printlnには進みません。", highlightLines: [2, 3], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "例外が起きる行は？", choices: ["Integer x = null;", "int y = x;", "System.out.println(y);"], answerIndex: 1, hint: "nullをintに変換する瞬間", afterExplanation: "正解です。アンボクシング時です。")),
        ]
    )

    static let goldFunctionalLambda041Explanation = Explanation(
        id: "explain-gold-functional-lambda-041",
        initialCode: """
@FunctionalInterface
interface Task {
    void run();
    default void log() {}
    String toString();
}
Task task = () -> System.out.print("R");
task.run();
""",
        steps: [
            Step(index: 0, narration: "`Task` で抽象メソッドとして数えるのは `run()` だけです。`default log()` は実装済み、`toString()` はObject由来なのでSAM数に含めません。", highlightLines: [1, 2, 3, 4, 5], variables: [Variable(name: "abstract method count", type: "int", value: "1", scope: "Task")], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "ラムダは `run()` の実装になります。`task.run()` で `R` を出力します。", highlightLines: [7, 8], variables: [Variable(name: "task", type: "Task", value: "lambda run()", scope: "main")], callStack: [CallStackFrame(method: "run", line: 8)], heap: [], predict: PredictPrompt(question: "defaultメソッドは抽象メソッド数に入る？", choices: ["入る", "入らない"], answerIndex: 1, hint: "defaultは実装済みです。", afterExplanation: "正解です。入らないので関数型インターフェースです。")),
        ]
    )

    static let goldFunctionalLambda042Explanation = Explanation(
        id: "explain-gold-functional-lambda-042",
        initialCode: """
var p = (Predicate<String>) (s -> s.length() > 1);
System.out.println(p.test("Go"));
""",
        steps: [
            Step(index: 0, narration: "ラムダ式にはターゲット型が必要です。ここでは右辺のキャスト `(Predicate<String>)` がターゲット型を与えるため、`var` はPredicate<String>として推論されます。", highlightLines: [1], variables: [Variable(name: "p", type: "Predicate<String>", value: "s.length() > 1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`\"Go\"` の長さは2なので条件はtrue。出力は `true` です。", highlightLines: [2], variables: [Variable(name: "p.test(\"Go\")", type: "boolean", value: "true", scope: "main")], callStack: [CallStackFrame(method: "test", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda043Explanation = Explanation(
        id: "explain-gold-functional-lambda-043",
        initialCode: """
var f = Function.identity();
String s = f.apply("A");
System.out.println(s);
""",
        steps: [
            Step(index: 0, narration: "`var` は左辺からターゲット型を提供しません。`Function.identity()` の型引数はStringではなく、Object寄りに推論されます。", highlightLines: [1], variables: [Variable(name: "f", type: "Function<Object, Object>", value: "identity", scope: "main")], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`f.apply(\"A\")` の静的な戻り値型はObjectです。`String s` へ直接代入できないため、この行でコンパイルエラーです。", highlightLines: [2], variables: [Variable(name: "f.apply(\"A\")", type: "Object", value: "\"A\"", scope: "main")], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: PredictPrompt(question: "戻り値の静的型は？", choices: ["String", "Object"], answerIndex: 1, hint: "varはStringのターゲット型を与えません。", afterExplanation: "正解です。ObjectなのでStringへ代入できません。")),
        ]
    )

    static let goldFunctionalLambda044Explanation = Explanation(
        id: "explain-gold-functional-lambda-044",
        initialCode: """
Supplier<Integer> s = () -> { return 1 + 2; };
System.out.println(s.get());
""",
        steps: [
            Step(index: 0, narration: "`Supplier<Integer>` は引数なしでIntegerを返す関数型インターフェースです。ブロックラムダなので `return` で値を返します。", highlightLines: [1], variables: [Variable(name: "s", type: "Supplier<Integer>", value: "() -> 3", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`s.get()` でラムダが実行され、`1 + 2` の結果3が返ります。出力は `3` です。", highlightLines: [2], variables: [Variable(name: "s.get()", type: "Integer", value: "3", scope: "main")], callStack: [CallStackFrame(method: "get", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda045Explanation = Explanation(
        id: "explain-gold-functional-lambda-045",
        initialCode: """
Predicate<String> p = String s -> s.isEmpty();
System.out.println(p.test(""));
""",
        steps: [
            Step(index: 0, narration: "単一引数ラムダでは、型を省略するなら `s -> ...` と書けます。しかし型を明示する場合は括弧が必要です。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`String s -> ...` は不正です。正しくは `(String s) -> s.isEmpty()` なので、この行でコンパイルエラーです。", highlightLines: [1], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "型付き単一引数で括弧は省略できる？", choices: ["できる", "できない"], answerIndex: 1, hint: "型を明示したら括弧が必要です。", afterExplanation: "正解です。省略できません。")),
        ]
    )

    static let goldFunctionalLambda046Explanation = Explanation(
        id: "explain-gold-functional-lambda-046",
        initialCode: """
int base;
if (args.length == 0) {
    base = 1;
} else {
    base = 2;
}
Supplier<Integer> s = () -> base;
System.out.println(s.get());
""",
        steps: [
            Step(index: 0, narration: "`base` は宣言時にfinalではありませんが、各実行経路で一度だけ代入され、その後変更されません。つまり実質的finalです。", highlightLines: [1, 2, 3, 5, 7], variables: [Variable(name: "base", type: "int", value: "1 or 2", scope: "main")], callStack: [CallStackFrame(method: "compile", line: 7)], heap: [], predict: nil),
            Step(index: 1, narration: "引数なし実行では `args.length == 0` がtrueなのでbaseは1です。ラムダから参照でき、`s.get()` の出力は `1` です。", highlightLines: [2, 3, 8], variables: [Variable(name: "base", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "get", line: 8)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda047Explanation = Explanation(
        id: "explain-gold-functional-lambda-047",
        initialCode: """
int base = 1;
Runnable r = () -> System.out.print(base);
base += 1;
r.run();
""",
        steps: [
            Step(index: 0, narration: "ラムダ式 `() -> System.out.print(base)` はローカル変数baseを捕捉します。捕捉されるローカル変数は実質的finalでなければなりません。", highlightLines: [1, 2], variables: [Variable(name: "base", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`base += 1` はbaseの変更です。そのためbaseは実質的finalではなくなり、コンパイルエラーです。", highlightLines: [3], variables: [Variable(name: "base", type: "int", value: "変更される", scope: "main")], callStack: [], heap: [], predict: PredictPrompt(question: "`+=` は変更扱い？", choices: ["変更扱い", "変更ではない"], answerIndex: 0, hint: "代入を含みます。", afterExplanation: "正解です。実質的finalではありません。")),
        ]
    )

    static let goldFunctionalLambda048Explanation = Explanation(
        id: "explain-gold-functional-lambda-048",
        initialCode: """
Function<String, Integer> f = Integer::valueOf;
System.out.println(f.apply("10") + 1);
""",
        steps: [
            Step(index: 0, narration: "`Integer::valueOf` には複数のオーバーロードがありますが、ターゲット型 `Function<String,Integer>` によりString引数版が選ばれます。", highlightLines: [1], variables: [Variable(name: "f", type: "Function<String,Integer>", value: "Integer.valueOf(String)", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`f.apply(\"10\")` はInteger 10です。`+ 1` は数値加算なので出力は `11` です。", highlightLines: [2], variables: [Variable(name: "f.apply(\"10\")", type: "Integer", value: "10", scope: "main")], callStack: [CallStackFrame(method: "apply", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda049Explanation = Explanation(
        id: "explain-gold-functional-lambda-049",
        initialCode: """
IntFunction<String> f = String::valueOf;
System.out.println(f.apply(5) + 1);
""",
        steps: [
            Step(index: 0, narration: "`IntFunction<String>` はintを受け取りStringを返します。`String::valueOf` はintからStringへの変換として適合します。", highlightLines: [1], variables: [Variable(name: "f", type: "IntFunction<String>", value: "String.valueOf(int)", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`f.apply(5)` は文字列 `\"5\"` です。左辺がStringなので `+ 1` は文字列連結となり、出力は `51` です。", highlightLines: [2], variables: [Variable(name: "f.apply(5)", type: "String", value: "\"5\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda050Explanation = Explanation(
        id: "explain-gold-functional-lambda-050",
        initialCode: """
StringBuilder sb = new StringBuilder("A");
Supplier<String> s = sb::toString;
sb.append("B");
System.out.println(s.get());
""",
        steps: [
            Step(index: 0, narration: "`sb::toString` は特定オブジェクトsbをレシーバとして固定するメソッド参照です。ただしtoStringは `s.get()` の時に実行されます。", highlightLines: [1, 2], variables: [Variable(name: "sb", type: "StringBuilder", value: "\"A\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`sb.append(\"B\")` 後、同じStringBuilderの中身はABです。`s.get()` でその時点のtoStringを呼ぶため出力は `AB` です。", highlightLines: [3, 4], variables: [Variable(name: "sb", type: "StringBuilder", value: "\"AB\"", scope: "main")], callStack: [CallStackFrame(method: "get", line: 4)], heap: [], predict: PredictPrompt(question: "toStringの結果はいつ決まる？", choices: ["参照作成時", "get()呼び出し時"], answerIndex: 1, hint: "固定されるのはレシーバです。", afterExplanation: "正解です。呼び出し時です。")),
        ]
    )

    static let goldFunctionalLambda051Explanation = Explanation(
        id: "explain-gold-functional-lambda-051",
        initialCode: """
BiFunction<String, String, Boolean> f = String::startsWith;
System.out.println(f.apply("Java", "Ja"));
""",
        steps: [
            Step(index: 0, narration: "`String::startsWith` は未束縛インスタンスメソッド参照です。BiFunctionの第1引数がレシーバ、第2引数がstartsWithの引数になります。", highlightLines: [1], variables: [Variable(name: "f", type: "BiFunction<String,String,Boolean>", value: "s,prefix -> s.startsWith(prefix)", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`f.apply(\"Java\", \"Ja\")` は `\"Java\".startsWith(\"Ja\")` と同等なのでtrueです。", highlightLines: [2], variables: [Variable(name: "return", type: "Boolean", value: "true", scope: "main")], callStack: [CallStackFrame(method: "apply", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda052Explanation = Explanation(
        id: "explain-gold-functional-lambda-052",
        initialCode: """
Function<StringBuilder, String> f = String::new;
System.out.println(f.apply(new StringBuilder("Hi")));
""",
        steps: [
            Step(index: 0, narration: "`String::new` はターゲット型に合わせてコンストラクタを選びます。ここではStringBuilderを受け取りStringを返すコンストラクタに対応します。", highlightLines: [1], variables: [Variable(name: "f", type: "Function<StringBuilder,String>", value: "new String(StringBuilder)", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`new StringBuilder(\"Hi\")` からStringを生成するため、printlnの出力は `Hi` です。", highlightLines: [2], variables: [Variable(name: "result", type: "String", value: "\"Hi\"", scope: "main")], callStack: [CallStackFrame(method: "apply", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda053Explanation = Explanation(
        id: "explain-gold-functional-lambda-053",
        initialCode: """
static class Box<T> {
    T value;
    Box(T value) { this.value = value; }
    T get() { return value; }
}
Function<String, Box<String>> maker = Box::new;
System.out.println(maker.apply("A").get());
""",
        steps: [
            Step(index: 0, narration: "`Function<String, Box<String>>` がターゲット型なので、`Box::new` はStringを受け取ってBox<String>を作るコンストラクタ参照として解決されます。", highlightLines: [1, 3, 6], variables: [Variable(name: "maker", type: "Function<String,Box<String>>", value: "Box<String>::new", scope: "main")], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
            Step(index: 1, narration: "`maker.apply(\"A\")` でvalueがAのBoxを作り、`get()` でAを取り出します。出力は `A` です。", highlightLines: [7], variables: [Variable(name: "box.value", type: "String", value: "\"A\"", scope: "main")], callStack: [CallStackFrame(method: "get", line: 7)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda054Explanation = Explanation(
        id: "explain-gold-functional-lambda-054",
        initialCode: """
IntFunction<String[]> maker = String[]::new;
System.out.println(maker.apply(2).length);
""",
        steps: [
            Step(index: 0, narration: "配列コンストラクタ参照 `String[]::new` は、長さintを受け取りString配列を返す関数として扱えます。", highlightLines: [1], variables: [Variable(name: "maker", type: "IntFunction<String[]>", value: "length -> new String[length]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`maker.apply(2)` は長さ2のString配列を作ります。要素はnullでもlengthは2なので出力は `2` です。", highlightLines: [2], variables: [Variable(name: "array.length", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "apply", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda055Explanation = Explanation(
        id: "explain-gold-functional-lambda-055",
        initialCode: """
Predicate<String> p = Predicate.not(String::isBlank);
System.out.println(p.test("Java"));
""",
        steps: [
            Step(index: 0, narration: "`String::isBlank` は対象文字列が空白だけならtrueです。`\"Java\".isBlank()` はfalseです。", highlightLines: [1, 2], variables: [Variable(name: "String::isBlank", type: "Predicate<String>", value: "false for Java", scope: "main")], callStack: [CallStackFrame(method: "test", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`Predicate.not` が結果を反転するため、falseがtrueになります。出力は `true` です。", highlightLines: [1, 2], variables: [Variable(name: "p.test(\"Java\")", type: "boolean", value: "true", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "not適用後の結果は？", choices: ["true", "false"], answerIndex: 0, hint: "isBlankはfalseです。", afterExplanation: "正解です。反転してtrueです。")),
        ]
    )

    static let goldFunctionalLambda056Explanation = Explanation(
        id: "explain-gold-functional-lambda-056",
        initialCode: """
BiPredicate<List<String>, String> p = List::contains;
System.out.println(p.test(List.of("A", "B"), "B"));
""",
        steps: [
            Step(index: 0, narration: "`List::contains` は未束縛インスタンスメソッド参照です。第1引数のListがレシーバ、第2引数が検索対象になります。", highlightLines: [1], variables: [Variable(name: "p", type: "BiPredicate<List<String>,String>", value: "list,value -> list.contains(value)", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`List.of(\"A\", \"B\")` はBを含むため、`p.test(..., \"B\")` はtrueです。", highlightLines: [2], variables: [Variable(name: "return", type: "boolean", value: "true", scope: "main")], callStack: [CallStackFrame(method: "test", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda057Explanation = Explanation(
        id: "explain-gold-functional-lambda-057",
        initialCode: """
Consumer<String> first = s -> System.out.print(s);
Consumer<String> second = s -> System.out.print(s.toLowerCase());
first.andThen(second).accept("A");
""",
        steps: [
            Step(index: 0, narration: "`Consumer.andThen` は左側のConsumerを先に実行し、その後に右側を実行します。", highlightLines: [1, 2, 3], variables: [Variable(name: "first", type: "Consumer<String>", value: "print original", scope: "main"), Variable(name: "second", type: "Consumer<String>", value: "print lower", scope: "main")], callStack: [CallStackFrame(method: "accept", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "入力Aに対し、firstが `A`、secondが `a` を出力します。改行はないので全体は `Aa` です。", highlightLines: [3], variables: [Variable(name: "output", type: "String", value: "\"Aa\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda058Explanation = Explanation(
        id: "explain-gold-functional-lambda-058",
        initialCode: """
BinaryOperator<String> op = String::concat;
System.out.println(op.apply("A", "B"));
""",
        steps: [
            Step(index: 0, narration: "`String::concat` は未束縛インスタンスメソッド参照です。BinaryOperatorの第1引数がレシーバ、第2引数がconcatの引数になります。", highlightLines: [1], variables: [Variable(name: "op", type: "BinaryOperator<String>", value: "(a,b) -> a.concat(b)", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`op.apply(\"A\", \"B\")` は `\"A\".concat(\"B\")` と同等です。出力は `AB` です。", highlightLines: [2], variables: [Variable(name: "return", type: "String", value: "\"AB\"", scope: "main")], callStack: [CallStackFrame(method: "apply", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldFunctionalLambda059Explanation = Explanation(
        id: "explain-gold-functional-lambda-059",
        initialCode: """
UnaryOperator<Integer> plusOne = x -> x + 1;
Function<Integer, Integer> f = plusOne.andThen(x -> x * 2);
System.out.println(f.apply(3));
""",
        steps: [
            Step(index: 0, narration: "`UnaryOperator<Integer>` は `Function<Integer,Integer>` の特殊形です。`andThen` はFunctionのdefaultメソッドとして使えます。", highlightLines: [1, 2], variables: [Variable(name: "f", type: "Function<Integer,Integer>", value: "plusOne then timesTwo", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`f.apply(3)` はまず3+1で4、その後4*2で8です。出力は `8` です。", highlightLines: [3], variables: [Variable(name: "result", type: "Integer", value: "8", scope: "main")], callStack: [CallStackFrame(method: "apply", line: 3)], heap: [], predict: PredictPrompt(question: "先に実行されるのは？", choices: ["plusOne", "x -> x * 2"], answerIndex: 0, hint: "andThenは左から右です。", afterExplanation: "正解です。plusOneが先です。")),
        ]
    )

    static let goldFunctionalLambda060Explanation = Explanation(
        id: "explain-gold-functional-lambda-060",
        initialCode: """
Supplier<ArrayList<String>> s = ArrayList<String>::new;
ArrayList<String> list = s.get();
list.add("A");
System.out.println(list.getClass().getSimpleName() + ":" + list.get(0));
""",
        steps: [
            Step(index: 0, narration: "`ArrayList<String>::new` は無引数コンストラクタ参照です。`Supplier<ArrayList<String>>` の `get()` に対応します。", highlightLines: [1, 2], variables: [Variable(name: "s", type: "Supplier<ArrayList<String>>", value: "ArrayList<String>::new", scope: "main")], callStack: [CallStackFrame(method: "get", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`s.get()` で新しいArrayListを作り、Aを追加します。実体クラス名はArrayList、先頭要素はAなので `ArrayList:A` です。", highlightLines: [3, 4], variables: [Variable(name: "list", type: "ArrayList<String>", value: "[A]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )
    
    
    
    // MARK: - Gold placeholder backfill batch

    static let goldStream002Explanation = Explanation(
        id: "explain-gold-stream-002",
        initialCode: """
import java.util.*;
public class Test {
    public static void main(String[] args) {
        int result = List.of("a", "bb", "ccc").stream()
            .map(String::length)
            .filter(n -> n > 1)
            .findFirst()
            .orElse(0);
        System.out.println(result);
    }
}
""",
        steps: [
            Step(index: 0, narration: "文字列長は 1,2,3 に変換されます。", highlightLines: [5, 6], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
            Step(index: 1, narration: "filter(n > 1) で 2,3 が残り、findFirstで最初の2を取得します。", highlightLines: [7], variables: [Variable(name: "result", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: PredictPrompt(question: "orElse(0) が使われる？", choices: ["使われる", "使われない"], answerIndex: 1, hint: "findFirstで値あり", afterExplanation: "正解です。値2があるのでorElseは使われません。")),
            Step(index: 2, narration: "最終出力は `2` です。", highlightLines: [9], variables: [], callStack: [CallStackFrame(method: "main", line: 9)], heap: [], predict: nil),
        ]
    )

    static let goldStream003Explanation = Explanation(
        id: "explain-gold-stream-003",
        initialCode: """
import java.util.*;
import java.util.stream.*;
public class Test {
    public static void main(String[] args) {
        List<String> list = List.of("A", "BB", "C", "DDD");
        Map<Integer, List<String>> map = list.stream()
            .collect(Collectors.groupingBy(String::length));
        System.out.println(map.get(1));
    }
}
""",
        steps: [
            Step(index: 0, narration: "groupingBy(String::length) は長さをキーにしてリストを作ります。", highlightLines: [7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
            Step(index: 1, narration: "長さ1のグループには `A` と `C` が入ります。", highlightLines: [8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: PredictPrompt(question: "map.get(1) は？", choices: ["A", "[A, C]", "null"], answerIndex: 1, hint: "値はList<String>", afterExplanation: "正解です。長さ1要素のリストです。")),
            Step(index: 2, narration: "最終出力は `[A, C]` です。", highlightLines: [8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    static let goldStream004Explanation = Explanation(
        id: "explain-gold-stream-004",
        initialCode: """
import java.util.stream.Stream;
public class Test {
    public static void main(String[] args) {
        Stream.of("A", "B").peek(System.out::print);
        System.out.print("X");
    }
}
""",
        steps: [
            Step(index: 0, narration: "`peek` は中間操作で終端操作がない限り実行されません。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "このコードには終端操作がないため `A`,`B` は出力されません。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "何が表示される？", choices: ["ABX", "X", "XAB"], answerIndex: 1, hint: "print(\"X\") は普通に実行", afterExplanation: "正解です。Xのみです。")),
            Step(index: 2, narration: "最終出力は `X` です。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let goldStream005Explanation = Explanation(
        id: "explain-gold-stream-005",
        initialCode: """
import java.util.stream.Stream;
public class Test {
    public static void main(String[] args) {
        int result = Stream.of(1, 2, 3)
            .reduce(10, Integer::sum);
        System.out.println(result);
    }
}
""",
        steps: [
            Step(index: 0, narration: "reduceのidentityは10で、累積の初期値として使われます。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
            Step(index: 1, narration: "10 + 1 + 2 + 3 = 16 になります。", highlightLines: [5], variables: [Variable(name: "result", type: "int", value: "16", scope: "main")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "出力は？", choices: ["6", "10", "16"], answerIndex: 2, hint: "identityを忘れない", afterExplanation: "正解です。16です。")),
            Step(index: 2, narration: "最終出力は `16` です。", highlightLines: [6], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
        ]
    )

    static let goldOptional002Explanation = Explanation(
        id: "explain-gold-optional-002",
        initialCode: """
import java.util.*;
public class Test {
    static String fallback() {
        System.out.print("F");
        return "fallback";
    }
    public static void main(String[] args) {
        String result = Optional.of("java").orElse(fallback());
        System.out.println(result);
    }
}
""",
        steps: [
            Step(index: 0, narration: "`orElse(fallback())` は引数を先に評価するため、fallback()が必ず実行され `F` が出ます。", highlightLines: [8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
            Step(index: 1, narration: "ただしOptionalには値`java`があるため、採用される戻り値は `java` です。", highlightLines: [8], variables: [Variable(name: "result", type: "String", value: "\"java\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: PredictPrompt(question: "最終表示は？", choices: ["java", "Fjava", "Ffallback"], answerIndex: 1, hint: "副作用F + 値java", afterExplanation: "正解です。Fjavaです。")),
            Step(index: 2, narration: "最終出力は `Fjava` です。", highlightLines: [9], variables: [], callStack: [CallStackFrame(method: "main", line: 9)], heap: [], predict: nil),
        ]
    )

    static let goldOptional003Explanation = Explanation(
        id: "explain-gold-optional-003",
        initialCode: """
import java.util.Optional;
public class Test {
    public static void main(String[] args) {
        try {
            Optional.of(null);
            System.out.println("OK");
        } catch (NullPointerException e) {
            System.out.println("NPE");
        }
    }
}
""",
        steps: [
            Step(index: 0, narration: "`Optional.of(null)` はnull非許容のため即 `NullPointerException` を投げます。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
            Step(index: 1, narration: "例外はcatch節で受け取られ `NPE` を出力します。", highlightLines: [7, 8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: PredictPrompt(question: "OKは表示される？", choices: ["される", "されない"], answerIndex: 1, hint: "try途中で例外", afterExplanation: "正解です。OK行には到達しません。")),
            Step(index: 2, narration: "最終出力は `NPE` です。", highlightLines: [8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    static let goldGenerics002Explanation = Explanation(
        id: "explain-gold-generics-002",
        initialCode: """
import java.util.*;
public class Test {
    public static void main(String[] args) {
        List<? super Integer> nums = new ArrayList<Number>();
        nums.add(10);
        Object value = nums.get(0);
        System.out.println(value);
    }
}
""",
        steps: [
            Step(index: 0, narration: "`? super Integer` にはIntegerの追加が安全に行えます。", highlightLines: [4, 5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
            Step(index: 1, narration: "取り出し型はObjectですが、中身は追加した `10` です。", highlightLines: [6], variables: [Variable(name: "value", type: "Object", value: "10", scope: "main")], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: PredictPrompt(question: "出力は？", choices: ["10", "null", "コンパイルエラー"], answerIndex: 0, hint: "格納値は保持される", afterExplanation: "正解です。10です。")),
            Step(index: 2, narration: "最終出力は `10` です。", highlightLines: [7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let goldGenerics003Explanation = Explanation(
        id: "explain-gold-generics-003",
        initialCode: """
import java.util.*;
public class Test {
    static void print(List<String> values) { System.out.println("String"); }
    static void print(List<Integer> values) { System.out.println("Integer"); }
}
""",
        steps: [
            Step(index: 0, narration: "一見すると型引数違いのオーバーロードですが、Javaの型消去後は両方とも `print(List)` になります。", highlightLines: [3, 4], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "同一シグネチャ重複となるためクラス定義時点でコンパイルエラーです。", highlightLines: [3, 4], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "結果は？", choices: ["正常コンパイル", "コンパイルエラー", "実行時ClassCastException"], answerIndex: 1, hint: "erasureで衝突", afterExplanation: "正解です。コンパイルエラーです。")),
            Step(index: 2, narration: "このコードはコンパイルエラーになります。", highlightLines: [4], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldAnnotations001Explanation = Explanation(
        id: "explain-gold-annotations-001",
        initialCode: """
class Parent { void run() {} }
class Child extends Parent {
    @Override
    void run(String name) {}
}
""",
        steps: [
            Step(index: 0, narration: "`run(String)` は引数が異なるため `run()` のオーバーライドではなくオーバーロードです。", highlightLines: [1, 4], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "@Override は実際にオーバーライドしていることを要求します。", highlightLines: [3], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "結果は？", choices: ["正常コンパイル", "@Overrideでコンパイルエラー"], answerIndex: 1, hint: "シグネチャ一致が必要", afterExplanation: "正解です。@Override行でエラーです。")),
            Step(index: 2, narration: "このコードはコンパイルエラーです。", highlightLines: [3], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldClasses001Explanation = Explanation(
        id: "explain-gold-classes-001",
        initialCode: """
public class Test {
    record Item(String name) {}
    public static void main(String[] args) {
        var item = new Item("Apple");
        item.name = "Banana";
        System.out.println(item.name());
    }
}
""",
        steps: [
            Step(index: 0, narration: "recordのコンポーネントはfinalフィールドとして扱われます。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "`item.name = ...` はfinalフィールドへの再代入となりコンパイルエラーです。", highlightLines: [5], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "結果は？", choices: ["Apple出力", "コンパイルエラー"], answerIndex: 1, hint: "recordは不変データ指向", afterExplanation: "正解です。再代入不可です。")),
            Step(index: 2, narration: "このコードはコンパイルエラーです。", highlightLines: [5], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldClasses002Explanation = Explanation(
        id: "explain-gold-classes-002",
        initialCode: """
sealed interface Service permits FileService {}
final class FileService implements Service {}
final class NetworkService implements Service {}
""",
        steps: [
            Step(index: 0, narration: "sealed interface Service は permitsで許可した型のみ直接実装できます。", highlightLines: [1], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "NetworkService は permitsに含まれないため実装不可です。", highlightLines: [3], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "どこでエラー？", choices: ["FileService", "NetworkService"], answerIndex: 1, hint: "permits対象外", afterExplanation: "正解です。NetworkService宣言でエラーです。")),
            Step(index: 2, narration: "このコードは NetworkService 側でコンパイルエラーになります。", highlightLines: [3], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldCollections001Explanation = Explanation(
        id: "explain-gold-collections-001",
        initialCode: """
Set<String> set = new TreeSet<>(Comparator.comparingInt(String::length));
set.add("aa");
set.add("bb");
set.add("c");
System.out.println(set.size());
""",
        steps: [
            Step(index: 0, narration: "比較基準が長さのみなので、\"aa\" と \"bb\" は比較結果0で同値扱いです。", highlightLines: [1, 2, 3], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "\"c\" は長さ1で別要素。最終的に長さ1と長さ2の2要素が残ります。", highlightLines: [4], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "sizeは？", choices: ["1", "2", "3"], answerIndex: 1, hint: "TreeSetの重複判定はComparator", afterExplanation: "正解です。2です。")),
            Step(index: 2, narration: "最終出力は `2` です。", highlightLines: [5], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldConcurrency001Explanation = Explanation(
        id: "explain-gold-concurrency-001",
        initialCode: """
ExecutorService es = Executors.newSingleThreadExecutor();
Future<?> future = es.submit(() -> { throw new RuntimeException("Error!"); });
Thread.sleep(100);
System.out.println("Done");
es.shutdown();
""",
        steps: [
            Step(index: 0, narration: "submit() 内例外はFutureに保持され、mainスレッドへ自動伝播しません。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "future.get() を呼んでいないため例外は観測されず、mainは継続してDoneを出力します。", highlightLines: [4], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "表示されるのは？", choices: ["Done", "スタックトレースで停止"], answerIndex: 0, hint: "submit + get未呼び出し", afterExplanation: "正解です。Doneが表示されます。")),
            Step(index: 2, narration: "最終的に `Done` が表示されます。", highlightLines: [4], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldConcurrency002Explanation = Explanation(
        id: "explain-gold-concurrency-002",
        initialCode: """
AtomicInteger n = new AtomicInteger(1);
System.out.println(n.getAndIncrement() + " " + n.get());
""",
        steps: [
            Step(index: 0, narration: "getAndIncrementは現在値を返してから内部値を+1します。", highlightLines: [2], variables: [Variable(name: "n", type: "AtomicInteger", value: "2(呼び出し後)", scope: "main")], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "返り値は1、続くgetは2です。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "出力は？", choices: ["1 2", "2 2", "1 1"], answerIndex: 0, hint: "後置increment相当", afterExplanation: "正解です。1 2です。")),
            Step(index: 2, narration: "最終出力は `1 2` です。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldConcurrency003Explanation = Explanation(
        id: "explain-gold-concurrency-003",
        initialCode: """
CompletableFuture<Integer> future = CompletableFuture
    .supplyAsync(() -> 10)
    .thenApply(n -> n + 5);
System.out.println(future.join());
""",
        steps: [
            Step(index: 0, narration: "supplyAsyncで10を生成し、thenApplyで15へ変換します。", highlightLines: [2, 3], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "join() は完了待ちして結果値15を返します。", highlightLines: [4], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "出力は？", choices: ["10", "15", "CompletableFuture[15]"], answerIndex: 1, hint: "joinは値を返す", afterExplanation: "正解です。15です。")),
            Step(index: 2, narration: "最終出力は `15` です。", highlightLines: [4], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldConcurrency004Explanation = Explanation(
        id: "explain-gold-concurrency-004",
        initialCode: """
for (Future<String> f : es.invokeAll(tasks)) {
    System.out.print(f.get());
}
""",
        steps: [
            Step(index: 0, narration: "invokeAllは全タスク完了を待ち、入力タスク順でFutureリストを返します。", highlightLines: [1], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "Bが先に完了しても、取得順はタスクリスト順なのでA→Bです。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "出力は？", choices: ["AB", "BA"], answerIndex: 0, hint: "完了順ではなく返却リスト順", afterExplanation: "正解です。ABです。")),
            Step(index: 2, narration: "最終出力は `AB` です。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldDateTime001Explanation = Explanation(
        id: "explain-gold-date-time-001",
        initialCode: """
LocalDate date = LocalDate.of(2026, 4, 19);
date.plusDays(1);
System.out.println(date);
""",
        steps: [
            Step(index: 0, narration: "LocalDateは不変オブジェクトです。", highlightLines: [1], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "plusDays(1) は新しいLocalDateを返すだけで、戻り値未代入なら元のdateは変わりません。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "出力は？", choices: ["2026-04-19", "2026-04-20"], answerIndex: 0, hint: "immutable", afterExplanation: "正解です。元の値のままです。")),
            Step(index: 2, narration: "最終出力は `2026-04-19` です。", highlightLines: [3], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldIo001Explanation = Explanation(
        id: "explain-gold-io-001",
        initialCode: """
Path p1 = Path.of("/app/logs");
Path p2 = Path.of("/backup/data");
Path result = p1.resolve(p2);
System.out.println(result.getNameCount());
""",
        steps: [
            Step(index: 0, narration: "resolveに絶対パスp2を渡すと、結果はp2自身になります。", highlightLines: [3], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "`/backup/data` の名前要素は backup, data の2つです。", highlightLines: [4], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "getNameCountは？", choices: ["2", "4"], answerIndex: 0, hint: "絶対パス引数は置換扱い", afterExplanation: "正解です。2です。")),
            Step(index: 2, narration: "最終出力は `2` です。", highlightLines: [4], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldIo002Explanation = Explanation(
        id: "explain-gold-io-002",
        initialCode: """
Path base = Path.of("/app/logs");
Path file = Path.of("/app/logs/2026/app.log");
Path relative = base.relativize(file);
System.out.println(relative.getNameCount());
""",
        steps: [
            Step(index: 0, narration: "baseからfileへの相対パスは `2026/app.log` です。", highlightLines: [3], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "名前要素は `2026` と `app.log` の2つです。", highlightLines: [4], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "出力は？", choices: ["1", "2", "3"], answerIndex: 1, hint: "相対化後の要素数", afterExplanation: "正解です。2です。")),
            Step(index: 2, narration: "最終出力は `2` です。", highlightLines: [4], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldJdbc001Explanation = Explanation(
        id: "explain-gold-jdbc-001",
        initialCode: """
ResultSet rs = stmt.executeQuery("SELECT name FROM users");
System.out.println(rs.getString(1));
""",
        steps: [
            Step(index: 0, narration: "executeQuery直後のResultSetカーソルは first行の手前（before first）です。", highlightLines: [1], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "rs.next() せずに getString() すると無効カーソル位置のためSQLExceptionです。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "必要な前処理は？", choices: ["rs.next()", "stmt.next()"], answerIndex: 0, hint: "ResultSetを次行へ進める", afterExplanation: "正解です。取得前にrs.next()が必要です。")),
            Step(index: 2, narration: "このコードは実行時に SQLException になります。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldJdbc002Explanation = Explanation(
        id: "explain-gold-jdbc-002",
        initialCode: """
static void bind(PreparedStatement ps) throws SQLException {
    ps.setString(0, "Alice");
}
""",
        steps: [
            Step(index: 0, narration: "PreparedStatementのパラメータ番号は1始まりです。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "index 0 指定は実行時にSQLException原因となります（コード自体はコンパイル可）。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "正しい最初の番号は？", choices: ["0", "1"], answerIndex: 1, hint: "JDBCプレースホルダ規則", afterExplanation: "正解です。1からです。")),
            Step(index: 2, narration: "結論: 実行時エラー要因で、正しくは `setString(1, ...)` です。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldLocalization001Explanation = Explanation(
        id: "explain-gold-localization-001",
        initialCode: """
Locale loc = new Locale("fr", "CA");
ResourceBundle rb = ResourceBundle.getBundle("Msg", loc);
System.out.println(rb.getString("greet"));
""",
        steps: [
            Step(index: 0, narration: "fr_CA向け探索は `Msg_fr_CA` → `Msg_fr` → `Msg` の順です。", highlightLines: [1, 2], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "Msg_fr_CAが無い場合、次の候補 Msg_fr が採用されます。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "取得値は？", choices: ["Bonjour", "Bonjour FR", "Hello"], answerIndex: 0, hint: "FR(国)ではなくfr言語フォールバック", afterExplanation: "正解です。Bonjourです。")),
            Step(index: 2, narration: "最終的に `Bonjour` が取得されます。", highlightLines: [3], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldLocalization002Explanation = Explanation(
        id: "explain-gold-localization-002",
        initialCode: """
ResourceBundle rb = ResourceBundle.getBundle("Test$Messages", Locale.JAPAN);
System.out.println(rb.getString("greeting"));
""",
        steps: [
            Step(index: 0, narration: "Locale.JAPAN は ja_JP。`Messages_ja_JP` が無ければ `Messages_ja` を探します。", highlightLines: [1], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "`Messages_ja` があるため greeting は `ja` になります。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "出力は？", choices: ["ja", "base"], answerIndex: 0, hint: "言語バンドル優先", afterExplanation: "正解です。jaです。")),
            Step(index: 2, narration: "最終出力は `ja` です。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldLocalization003Explanation = Explanation(
        id: "explain-gold-localization-003",
        initialCode: """
Locale.setDefault(Locale.US);
LocalDate date = LocalDate.of(2026, Month.APRIL, 20);
DateTimeFormatter f = DateTimeFormatter.ofPattern("MMM", Locale.JAPAN);
System.out.println(date.format(f));
""",
        steps: [
            Step(index: 0, narration: "デフォルトLocaleはUSに設定されていますが、Formatter作成時にLocale.JAPANを明示しています。", highlightLines: [1, 3], variables: [Variable(name: "defaultLocale", type: "Locale", value: "US", scope: "JVM"), Variable(name: "formatterLocale", type: "Locale", value: "JAPAN", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`MMM` は短い月名です。Locale.JAPANでは4月の短い表記は `4月` になります。", highlightLines: [2, 3], variables: [Variable(name: "date.month", type: "Month", value: "APRIL", scope: "main")], callStack: [CallStackFrame(method: "format", line: 4)], heap: [], predict: PredictPrompt(question: "使われるLocaleは？", choices: ["Locale.JAPAN", "Locale.US"], answerIndex: 0, hint: "ofPatternの第2引数です。", afterExplanation: "正解です。Formatterに指定したLocale.JAPANです。")),
            Step(index: 2, narration: "したがって出力は `4月` です。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization024Explanation = Explanation(
        id: "explain-gold-localization-024",
        initialCode: """
Locale loc = Locale.forLanguageTag("pt-BR");
System.out.println(loc.getLanguage() + ":" + loc.getCountry());
""",
        steps: [
            Step(index: 0, narration: "`Locale.forLanguageTag(\"pt-BR\")` は、言語ptと地域BRを持つLocaleを作ります。", highlightLines: [1], variables: [Variable(name: "loc", type: "Locale", value: "pt_BR", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`getLanguage()` は言語コード、`getCountry()` は国/地域コードを返します。", highlightLines: [2], variables: [Variable(name: "language", type: "String", value: "\"pt\"", scope: "main"), Variable(name: "country", type: "String", value: "\"BR\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "出力される順は？", choices: ["pt:BR", "BR:pt"], answerIndex: 0, hint: "getLanguageの後にgetCountryです。", afterExplanation: "正解です。pt:BRです。")),
            Step(index: 2, narration: "コロンで連結しているため、出力は `pt:BR` です。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization004Explanation = Explanation(
        id: "explain-gold-localization-004",
        initialCode: """
NumberFormat nf = NumberFormat.getCurrencyInstance(Locale.US);
System.out.println(nf.format(10));
""",
        steps: [
            Step(index: 0, narration: "`getCurrencyInstance(Locale.US)` で、米国の通貨形式を使うNumberFormatを作ります。", highlightLines: [1], variables: [Variable(name: "nf.locale", type: "Locale", value: "US", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "通貨形式なので、数値10はドル記号付きかつ小数2桁の形になります。", highlightLines: [2], variables: [Variable(name: "value", type: "int", value: "10", scope: "main")], callStack: [CallStackFrame(method: "format", line: 2)], heap: [], predict: PredictPrompt(question: "Locale.USの通貨記号は？", choices: ["$", "円"], answerIndex: 0, hint: "USの通貨です。", afterExplanation: "正解です。ドル記号です。")),
            Step(index: 2, narration: "出力は `$10.00` です。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization005Explanation = Explanation(
        id: "explain-gold-localization-005",
        initialCode: """
Locale loc = new Locale.Builder()
    .setLanguage("en")
    .setRegion("US")
    .build();
System.out.println(loc.toLanguageTag());
""",
        steps: [
            Step(index: 0, narration: "`Locale.Builder` でlanguageにen、regionにUSを指定しています。", highlightLines: [1, 2, 3, 4], variables: [Variable(name: "language", type: "String", value: "\"en\"", scope: "builder"), Variable(name: "region", type: "String", value: "\"US\"", scope: "builder")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "`toLanguageTag()` はLocaleの `toString()` とは異なり、ハイフン区切りのBCP 47形式を返します。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "言語タグの区切りは？", choices: ["ハイフン", "アンダースコア"], answerIndex: 0, hint: "toLanguageTagです。", afterExplanation: "正解です。en-USです。")),
            Step(index: 2, narration: "したがって出力は `en-US` です。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization006Explanation = Explanation(
        id: "explain-gold-localization-006",
        initialCode: """
Locale.setDefault(Locale.JAPAN);
NumberFormat nf = NumberFormat.getNumberInstance(Locale.US);
System.out.println(nf.format(1234.5));
""",
        steps: [
            Step(index: 0, narration: "デフォルトLocaleはJAPANに変更されています。ただし次の行でNumberFormatにLocale.USを明示しています。", highlightLines: [1, 2], variables: [Variable(name: "defaultLocale", type: "Locale", value: "JAPAN", scope: "JVM"), Variable(name: "formatLocale", type: "Locale", value: "US", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "明示Localeがある場合、そのFormatterは指定Localeの規則で数値を整形します。", highlightLines: [2, 3], variables: [], callStack: [CallStackFrame(method: "format", line: 3)], heap: [], predict: PredictPrompt(question: "使われる数値形式は？", choices: ["Locale.US", "Locale.JAPAN"], answerIndex: 0, hint: "getNumberInstanceの引数を見ます。", afterExplanation: "正解です。明示したLocale.USです。")),
            Step(index: 2, narration: "米国形式ではカンマで桁区切り、ピリオドで小数を表すため、`1,234.5` です。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization007Explanation = Explanation(
        id: "explain-gold-localization-007",
        initialCode: """
// Messages: ok=base-ok, cancel=base-cancel
// Messages_ja: ok=ja-ok
ResourceBundle rb = ResourceBundle.getBundle("Test$Messages", Locale.JAPAN);
System.out.println(rb.getString("ok") + ":" + rb.getString("cancel"));
""",
        steps: [
            Step(index: 0, narration: "`Locale.JAPAN` はja_JPです。候補は `Messages_ja_JP`、`Messages_ja`、`Messages` の順に探されます。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "getBundle", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`ok` は `Messages_ja` にあるので `ja-ok` です。`cancel` は子にないため親の `Messages` から探します。", highlightLines: [1, 2, 4], variables: [Variable(name: "ok", type: "String", value: "\"ja-ok\"", scope: "bundle"), Variable(name: "cancel", type: "String", value: "\"base-cancel\"", scope: "parent bundle")], callStack: [CallStackFrame(method: "getString", line: 4)], heap: [], predict: PredictPrompt(question: "子にないキーは親を探す？", choices: ["探す", "探さない"], answerIndex: 0, hint: "ResourceBundleには親チェーンがあります。", afterExplanation: "正解です。キー単位で親も探します。")),
            Step(index: 2, narration: "連結結果は `ja-ok:base-cancel` です。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization008Explanation = Explanation(
        id: "explain-gold-localization-008",
        initialCode: """
ResourceBundle rb = ResourceBundle.getBundle("Test$Messages", Locale.US);
try {
    System.out.println(rb.getString("missing"));
} catch (MissingResourceException e) {
    System.out.println("missing");
}
""",
        steps: [
            Step(index: 0, narration: "バンドル自体は見つかりますが、キー `missing` は定義されていません。", highlightLines: [1, 3], variables: [Variable(name: "key", type: "String", value: "\"missing\"", scope: "main")], callStack: [CallStackFrame(method: "getString", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "ResourceBundleはキーが見つからない場合、nullではなく `MissingResourceException` を投げます。", highlightLines: [3, 4], variables: [Variable(name: "e", type: "MissingResourceException", value: "missing key", scope: "catch")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "存在しないキーの結果は？", choices: ["null", "MissingResourceException"], answerIndex: 1, hint: "getStringは例外を投げます。", afterExplanation: "正解です。例外です。")),
            Step(index: 2, narration: "catchブロックで `missing` を出力します。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization009Explanation = Explanation(
        id: "explain-gold-localization-009",
        initialCode: """
// Config ListResourceBundle: {"count", 3}
ResourceBundle rb = ResourceBundle.getBundle("Test$Config", Locale.US);
Object value = rb.getObject("count");
System.out.println(value.getClass().getSimpleName() + ":" + value);
""",
        steps: [
            Step(index: 0, narration: "`ListResourceBundle` はStringだけでなくObject値も保持できます。`3` はIntegerにボクシングされます。", highlightLines: [1], variables: [Variable(name: "count", type: "Integer", value: "3", scope: "bundle")], callStack: [CallStackFrame(method: "getContents", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`getObject(\"count\")` でIntegerオブジェクトとして取り出します。", highlightLines: [3], variables: [Variable(name: "value", type: "Object", value: "Integer(3)", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: PredictPrompt(question: "valueの実体型は？", choices: ["Integer", "String"], answerIndex: 0, hint: "getObjectです。", afterExplanation: "正解です。Integerです。")),
            Step(index: 2, narration: "実体クラス名と値を連結するため、出力は `Integer:3` です。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization010Explanation = Explanation(
        id: "explain-gold-localization-010",
        initialCode: """
NumberFormat nf = NumberFormat.getNumberInstance(Locale.GERMANY);
System.out.println(nf.format(1234.5));
""",
        steps: [
            Step(index: 0, narration: "`Locale.GERMANY` の数値形式では、桁区切りがピリオド、小数区切りがカンマです。", highlightLines: [1], variables: [Variable(name: "locale", type: "Locale", value: "GERMANY", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`1234.5` を整形すると、整数部に桁区切りが入り、小数部はカンマの後に出ます。", highlightLines: [2], variables: [Variable(name: "value", type: "double", value: "1234.5", scope: "main")], callStack: [CallStackFrame(method: "format", line: 2)], heap: [], predict: PredictPrompt(question: "ドイツ形式の小数区切りは？", choices: [",", "."], answerIndex: 0, hint: "Locale.GERMANYです。", afterExplanation: "正解です。カンマです。")),
            Step(index: 2, narration: "出力は `1.234,5` です。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization011Explanation = Explanation(
        id: "explain-gold-localization-011",
        initialCode: """
NumberFormat nf = NumberFormat.getNumberInstance(Locale.US);
Number n = nf.parse("12abc");
System.out.println(n);
""",
        steps: [
            Step(index: 0, narration: "`NumberFormat.parse(String)` は、文字列の先頭から数値として読める部分を解析します。", highlightLines: [2], variables: [Variable(name: "input", type: "String", value: "\"12abc\"", scope: "main")], callStack: [CallStackFrame(method: "parse", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "先頭の `12` は解析できます。後ろの `abc` が残っていても、`parse(String)` はこの時点でNumberを返します。", highlightLines: [2], variables: [Variable(name: "n", type: "Number", value: "12", scope: "main")], callStack: [CallStackFrame(method: "parse", line: 2)], heap: [], predict: PredictPrompt(question: "末尾にabcがあると必ず例外？", choices: ["必ず例外", "先頭が読めれば返る"], answerIndex: 1, hint: "全文消費チェックではありません。", afterExplanation: "正解です。12が返ります。")),
            Step(index: 2, narration: "`System.out.println(n)` は `12` を出力します。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization012Explanation = Explanation(
        id: "explain-gold-localization-012",
        initialCode: """
DecimalFormat df = new DecimalFormat("0000.00");
System.out.println(df.format(7.5));
""",
        steps: [
            Step(index: 0, narration: "DecimalFormatの `0` は必須桁です。整数部に4つ、小数部に2つ指定されています。", highlightLines: [1], variables: [Variable(name: "pattern", type: "String", value: "\"0000.00\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`7.5` は整数部が4桁になるように左側が0埋めされ、小数部も2桁になります。", highlightLines: [2], variables: [Variable(name: "value", type: "double", value: "7.5", scope: "main")], callStack: [CallStackFrame(method: "format", line: 2)], heap: [], predict: PredictPrompt(question: "整数部は何桁表示？", choices: ["4桁", "1桁"], answerIndex: 0, hint: "0000です。", afterExplanation: "正解です。0007になります。")),
            Step(index: 2, narration: "出力は `0007.50` です。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization013Explanation = Explanation(
        id: "explain-gold-localization-013",
        initialCode: """
NumberFormat nf = NumberFormat.getPercentInstance(Locale.US);
System.out.println(nf.format(0.25));
""",
        steps: [
            Step(index: 0, narration: "`getPercentInstance` は数値をパーセントとして整形します。内部値は表示時に100倍されます。", highlightLines: [1], variables: [Variable(name: "formatter", type: "NumberFormat", value: "percent US", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`0.25` は25パーセントです。Locale.USではパーセント記号を付けて表示します。", highlightLines: [2], variables: [Variable(name: "value", type: "double", value: "0.25", scope: "main")], callStack: [CallStackFrame(method: "format", line: 2)], heap: [], predict: PredictPrompt(question: "0.25のパーセント表示は？", choices: ["25%", "0.25%"], answerIndex: 0, hint: "100倍して%です。", afterExplanation: "正解です。25%です。")),
            Step(index: 2, narration: "出力は `25%` です。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization014Explanation = Explanation(
        id: "explain-gold-localization-014",
        initialCode: """
LocalDate d = LocalDate.of(2026, 4, 5);
DateTimeFormatter f = DateTimeFormatter.ofPattern("yyyy/MM/dd");
System.out.println(d.format(f));
""",
        steps: [
            Step(index: 0, narration: "`LocalDate.of(2026, 4, 5)` で2026年4月5日を作ります。", highlightLines: [1], variables: [Variable(name: "d", type: "LocalDate", value: "2026-04-05", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "パターン `yyyy/MM/dd` は、年4桁、月2桁、日2桁をスラッシュでつなぎます。", highlightLines: [2], variables: [Variable(name: "pattern", type: "String", value: "\"yyyy/MM/dd\"", scope: "main")], callStack: [CallStackFrame(method: "ofPattern", line: 2)], heap: [], predict: PredictPrompt(question: "月と日はゼロ埋めされる？", choices: ["される", "されない"], answerIndex: 0, hint: "MMとddです。", afterExplanation: "正解です。04と05になります。")),
            Step(index: 2, narration: "出力は `2026/04/05` です。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization015Explanation = Explanation(
        id: "explain-gold-localization-015",
        initialCode: """
LocalDate d = LocalDate.of(2026, 4, 5);
DateTimeFormatter f = DateTimeFormatter.ofPattern("MMM d", Locale.US);
System.out.println(d.format(f));
""",
        steps: [
            Step(index: 0, narration: "`MMM` は短い月名を表します。月名はLocaleに依存します。", highlightLines: [2], variables: [Variable(name: "locale", type: "Locale", value: "US", scope: "main")], callStack: [CallStackFrame(method: "ofPattern", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "Locale.USで4月の短い月名は `Apr` です。`d` は日を最小桁で表示するため5になります。", highlightLines: [1, 2], variables: [Variable(name: "monthText", type: "String", value: "\"Apr\"", scope: "format")], callStack: [CallStackFrame(method: "format", line: 3)], heap: [], predict: PredictPrompt(question: "MMMの出力は？", choices: ["Apr", "April"], answerIndex: 0, hint: "短い月名です。", afterExplanation: "正解です。Aprです。")),
            Step(index: 2, narration: "出力は `Apr 5` です。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization016Explanation = Explanation(
        id: "explain-gold-localization-016",
        initialCode: """
DateTimeFormatter f = DateTimeFormatter.ofPattern("uuuu/MM/dd");
LocalDate d = LocalDate.parse("2026/04/05", f);
System.out.println(d.getMonthValue());
""",
        steps: [
            Step(index: 0, narration: "スラッシュ区切りの日付を解析するため、`uuuu/MM/dd` のformatterを作っています。", highlightLines: [1], variables: [Variable(name: "pattern", type: "String", value: "\"uuuu/MM/dd\"", scope: "main")], callStack: [CallStackFrame(method: "ofPattern", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`LocalDate.parse` にformatterを渡しているため、`2026/04/05` をLocalDateとして解析できます。", highlightLines: [2], variables: [Variable(name: "d", type: "LocalDate", value: "2026-04-05", scope: "main")], callStack: [CallStackFrame(method: "parse", line: 2)], heap: [], predict: PredictPrompt(question: "月の数値は？", choices: ["4", "04"], answerIndex: 0, hint: "getMonthValueはintです。", afterExplanation: "正解です。4です。")),
            Step(index: 2, narration: "`getMonthValue()` はintの4を返すため、出力は `4` です。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization017Explanation = Explanation(
        id: "explain-gold-localization-017",
        initialCode: """
try {
    LocalDate.parse("2026/04/05");
} catch (DateTimeParseException e) {
    System.out.println("parse error");
}
""",
        steps: [
            Step(index: 0, narration: "formatterなしの `LocalDate.parse` は、標準のISO_LOCAL_DATE形式、つまり `yyyy-MM-dd` のようなハイフン区切りを期待します。", highlightLines: [2], variables: [Variable(name: "input", type: "String", value: "\"2026/04/05\"", scope: "main")], callStack: [CallStackFrame(method: "parse", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "入力はスラッシュ区切りなので、標準形式とは一致せず `DateTimeParseException` が発生します。", highlightLines: [2, 3], variables: [Variable(name: "e", type: "DateTimeParseException", value: "format mismatch", scope: "catch")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: PredictPrompt(question: "スラッシュ形式を読むには？", choices: ["formatterを指定する", "何もしなくてよい"], answerIndex: 0, hint: "ofPatternが必要です。", afterExplanation: "正解です。formatterを渡します。")),
            Step(index: 2, narration: "catchブロックが実行され、`parse error` が出力されます。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization018Explanation = Explanation(
        id: "explain-gold-localization-018",
        initialCode: """
LocalDateTime t = LocalDateTime.of(2026, 4, 5, 9, 7);
DateTimeFormatter f = DateTimeFormatter.ofPattern("MM:mm");
System.out.println(t.format(f));
""",
        steps: [
            Step(index: 0, narration: "DateTimeFormatterのパターン文字は大文字小文字を区別します。`MM` は月、`mm` は分です。", highlightLines: [2], variables: [Variable(name: "pattern", type: "String", value: "\"MM:mm\"", scope: "main")], callStack: [CallStackFrame(method: "ofPattern", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "日時は4月、分は7分です。2桁指定なので、それぞれ `04` と `07` になります。", highlightLines: [1, 3], variables: [Variable(name: "month", type: "int", value: "4", scope: "t"), Variable(name: "minute", type: "int", value: "7", scope: "t")], callStack: [CallStackFrame(method: "format", line: 3)], heap: [], predict: PredictPrompt(question: "`MM:mm` の前半は？", choices: ["月", "分"], answerIndex: 0, hint: "大文字Mです。", afterExplanation: "正解です。前半は月です。")),
            Step(index: 2, narration: "出力は `04:07` です。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization019Explanation = Explanation(
        id: "explain-gold-localization-019",
        initialCode: """
System.out.println(MessageFormat.format("Hello {0}", "Java"));
""",
        steps: [
            Step(index: 0, narration: "`MessageFormat.format` は、パターン内の `{0}` を0番目の引数で置換します。", highlightLines: [1], variables: [Variable(name: "arg0", type: "String", value: "\"Java\"", scope: "format")], callStack: [CallStackFrame(method: "format", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "0番目の引数は `Java` なので、`Hello {0}` は `Hello Java` になります。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: PredictPrompt(question: "{0}に入る値は？", choices: ["Java", "null"], answerIndex: 0, hint: "第2引数です。", afterExplanation: "正解です。Javaです。")),
            Step(index: 2, narration: "出力は `Hello Java` です。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization020Explanation = Explanation(
        id: "explain-gold-localization-020",
        initialCode: """
System.out.println(MessageFormat.format("'{0}' {0}", "Java"));
""",
        steps: [
            Step(index: 0, narration: "MessageFormatでは単一引用符がエスケープに使われます。`'{0}'` は置換対象ではなくリテラルの `{0}` です。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "format", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "後半の `{0}` は引用符の外なので、引数 `Java` に置換されます。", highlightLines: [1], variables: [Variable(name: "arg0", type: "String", value: "\"Java\"", scope: "format")], callStack: [CallStackFrame(method: "format", line: 1)], heap: [], predict: PredictPrompt(question: "引用符内の{0}は置換される？", choices: ["される", "されない"], answerIndex: 1, hint: "単一引用符の中です。", afterExplanation: "正解です。リテラルになります。")),
            Step(index: 2, narration: "したがって出力は `{0} Java` です。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization021Explanation = Explanation(
        id: "explain-gold-localization-021",
        initialCode: """
System.out.println(MessageFormat.format("{1} scored {0}", 90, "Ana"));
""",
        steps: [
            Step(index: 0, narration: "MessageFormatの番号は引数インデックスです。出現順ではありません。", highlightLines: [1], variables: [Variable(name: "arg0", type: "Integer", value: "90", scope: "format"), Variable(name: "arg1", type: "String", value: "\"Ana\"", scope: "format")], callStack: [CallStackFrame(method: "format", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`{1}` は2番目の引数Ana、`{0}` は1番目の引数90を参照します。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "format", line: 1)], heap: [], predict: PredictPrompt(question: "先頭に入るのは？", choices: ["Ana", "90"], answerIndex: 0, hint: "{1}です。", afterExplanation: "正解です。Anaです。")),
            Step(index: 2, narration: "出力は `Ana scored 90` です。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization022Explanation = Explanation(
        id: "explain-gold-localization-022",
        initialCode: """
MessageFormat mf = new MessageFormat("{0,number,#,##0}", Locale.US);
System.out.println(mf.format(new Object[] { 1234 }));
""",
        steps: [
            Step(index: 0, narration: "`{0,number,#,##0}` は0番目の引数を数値として、`#,##0` パターンで整形する指定です。", highlightLines: [1], variables: [Variable(name: "pattern", type: "String", value: "\"{0,number,#,##0}\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "Locale.USなので桁区切りはカンマです。1234は `1,234` になります。", highlightLines: [1, 2], variables: [Variable(name: "arg0", type: "Integer", value: "1234", scope: "format")], callStack: [CallStackFrame(method: "format", line: 2)], heap: [], predict: PredictPrompt(question: "区切り文字は？", choices: [",", "."], answerIndex: 0, hint: "Locale.USです。", afterExplanation: "正解です。カンマです。")),
            Step(index: 2, narration: "出力は `1,234` です。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldLocalization023Explanation = Explanation(
        id: "explain-gold-localization-023",
        initialCode: """
ResourceBundle rb = ResourceBundle.getBundle("Test$Texts", Locale.US);
String pattern = rb.getString("notice");
MessageFormat mf = new MessageFormat(pattern, Locale.US);
System.out.println(mf.format(new Object[] { "Taro", 3 }));
""",
        steps: [
            Step(index: 0, narration: "Locale.USでは `Texts_en` が候補になり、`notice` の値は `Hello {0}, you have {1}.` です。", highlightLines: [1, 2], variables: [Variable(name: "pattern", type: "String", value: "\"Hello {0}, you have {1}.\"", scope: "main")], callStack: [CallStackFrame(method: "getString", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "ResourceBundleは文字列パターンを返すだけです。実際の差し込みはMessageFormatで行います。", highlightLines: [2, 3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: PredictPrompt(question: "置換を行うのは？", choices: ["MessageFormat", "ResourceBundle"], answerIndex: 0, hint: "formatを呼ぶ方です。", afterExplanation: "正解です。MessageFormatです。")),
            Step(index: 2, narration: "`{0}` にTaro、`{1}` に3が入り、出力は `Hello Taro, you have 3.` です。", highlightLines: [4], variables: [Variable(name: "arg0", type: "String", value: "\"Taro\"", scope: "format"), Variable(name: "arg1", type: "Integer", value: "3", scope: "format")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let goldModule001Explanation = Explanation(
        id: "explain-gold-module-001",
        initialCode: """
module com.example.app {
    exports com.example.api;
    requires java.logging;
}
""",
        steps: [
            Step(index: 0, narration: "`exports com.example.api` でそのパッケージのみ外部公開されます。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "同一モジュール内でも非公開パッケージは他モジュールから参照できません。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "公開されるのは？", choices: ["com.example.apiのみ", "全パッケージ"], answerIndex: 0, hint: "exports対象限定", afterExplanation: "正解です。exportsしたAPIだけ公開です。")),
            Step(index: 2, narration: "モジュールのカプセル化ルールとして、exports対象のみアクセス可能です。", highlightLines: [1, 2], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldModule002Explanation = Explanation(
        id: "explain-gold-module-002",
        initialCode: """
module lib.core {
    requires transitive java.sql;
    exports lib.api;
}
module app.main {
    requires lib.core;
}
""",
        steps: [
            Step(index: 0, narration: "`requires transitive java.sql` により、lib.core依存のモジュールにもjava.sql可読性が伝播します。", highlightLines: [2, 6], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "app.mainはlib.coreだけrequiresしていても、java.sql型を利用可能です。", highlightLines: [5, 6], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "app.mainでjava.sql使用可？", choices: ["可", "不可"], answerIndex: 0, hint: "transitiveの効果", afterExplanation: "正解です。可読性が伝播します。")),
            Step(index: 2, narration: "結論: `requires transitive` により下流モジュールでもjava.sqlが読めます。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldPathNormalize001Explanation = Explanation(
        id: "explain-gold-path-normalize-001",
        initialCode: """
Path p = Path.of("a/../b/./c.txt").normalize();
System.out.println(p.getNameCount());
""",
        steps: [
            Step(index: 0, narration: "normalizeで `a/..` は相殺、`./` は除去されます。", highlightLines: [1], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "残る相対パスは `b/c.txt` で要素数2です。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "getNameCountは？", choices: ["1", "2", "4"], answerIndex: 1, hint: "正規化後で数える", afterExplanation: "正解です。2です。")),
            Step(index: 2, narration: "最終出力は `2` です。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    // MARK: - New quiz batch

    static let silverClasses006Explanation = Explanation(
        id: "explain-silver-classes-006",
        initialCode: """
public class Test {
    static { System.out.print("S "); }
    { System.out.print("I "); }
    Test() { System.out.print("C "); }
    public static void main(String[] args) {
        new Test();
    }
}
""",
        steps: [
            Step(index: 0, narration: "最初のクラス使用時に static 初期化子 `S` が実行されます。", highlightLines: [2, 6], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
            Step(index: 1, narration: "new Test() でインスタンス初期化子 `I`、続いてコンストラクタ本体 `C` が実行されます。", highlightLines: [3, 4], variables: [], callStack: [CallStackFrame(method: "Test()", line: 4)], heap: [], predict: PredictPrompt(question: "出力順は？", choices: ["S I C", "S C I", "I C S"], answerIndex: 0, hint: "static→instance init→ctor", afterExplanation: "正解です。S I Cです。")),
            Step(index: 2, narration: "最終出力は `S I C` です。", highlightLines: [2, 3, 4], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
        ]
    )

    static let silverControlFlow007Explanation = Explanation(
        id: "explain-silver-control-flow-007",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        int n = 1;
        switch (n) {
            case 1: System.out.print("A ");
            case 2: System.out.print("B "); break;
            default: System.out.print("D ");
        }
    }
}
""",
        steps: [
            Step(index: 0, narration: "n=1でcase1に入り `A` を出力します。", highlightLines: [3, 5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
            Step(index: 1, narration: "case1にbreakがないためcase2へフォールスルーし `B` を出力、breakで終了します。", highlightLines: [5, 6], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: PredictPrompt(question: "defaultに到達する？", choices: ["する", "しない"], answerIndex: 1, hint: "case2でbreak", afterExplanation: "正解です。defaultには落ちません。")),
            Step(index: 2, narration: "最終出力は `A B` です。", highlightLines: [5, 6], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
        ]
    )

    static let silverDataTypes006Explanation = Explanation(
        id: "explain-silver-data-types-006",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        double d = 9.8;
        int x = (int) d;
        System.out.println(x);
    }
}
""",
        steps: [
            Step(index: 0, narration: "dは9.8。`(int)d` でdoubleからintへ明示キャストします。", highlightLines: [3, 4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "このキャストは小数部を切り捨てるため x=9 になります。", highlightLines: [4], variables: [Variable(name: "x", type: "int", value: "9", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "丸め？切り捨て？", choices: ["丸め", "切り捨て"], answerIndex: 1, hint: "primitive narrowing conversion", afterExplanation: "正解です。切り捨てです。")),
            Step(index: 2, narration: "最終出力は `9` です。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let silverException007Explanation = Explanation(
        id: "explain-silver-exception-007",
        initialCode: """
public class Test {
    static void run() {
        throw new IllegalStateException();
    }
    public static void main(String[] args) {
        try { run(); }
        catch (RuntimeException e) { System.out.println("R"); }
    }
}
""",
        steps: [
            Step(index: 0, narration: "run() は IllegalStateException を送出します（RuntimeException系）。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "run", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "catch(RuntimeException) が一致し、例外は捕捉されます。", highlightLines: [7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: PredictPrompt(question: "出力は？", choices: ["R", "異常終了", "コンパイルエラー"], answerIndex: 0, hint: "IllegalStateException ⊂ RuntimeException", afterExplanation: "正解です。Rです。")),
            Step(index: 2, narration: "最終出力は `R` です。", highlightLines: [7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let goldStream010Explanation = Explanation(
        id: "explain-gold-stream-010",
        initialCode: """
List<String> list = Arrays.asList("b", "aa", "c");
list.stream()
    .sorted(Comparator.comparingInt(String::length))
    .forEach(System.out::print);
""",
        steps: [
            Step(index: 0, narration: "Comparatorは文字列長基準。要素長は b=1, aa=2, c=1。", highlightLines: [1, 3], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "長さ昇順で同長要素は元順を保ち、並びは b, c, aa です。", highlightLines: [3], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "連結出力は？", choices: ["bcaa", "aabc", "cbaa"], answerIndex: 0, hint: "長さ順 + 安定順序", afterExplanation: "正解です。bcaaです。")),
            Step(index: 2, narration: "最終出力は `bcaa` です。", highlightLines: [4], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldConcurrency006Explanation = Explanation(
        id: "explain-gold-concurrency-006",
        initialCode: """
Thread t = new Thread(() -> System.out.print("T"));
t.start();
t.join();
System.out.print("M");
""",
        steps: [
            Step(index: 0, narration: "start() で別スレッドtが `T` を出力します。", highlightLines: [1, 2], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "join() によりmainはt完了まで待機するため、`M` は必ず後に出力されます。", highlightLines: [3, 4], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "順序は？", choices: ["TM", "MT"], answerIndex: 0, hint: "joinは完了待ち", afterExplanation: "正解です。TMです。")),
            Step(index: 2, narration: "最終出力は `TM` です。", highlightLines: [4], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    // MARK: - Mixed Batch Queue-002 Explanations

    static let silverControlFlow010Explanation = Explanation(
        id: "explain-silver-control-flow-010",
        initialCode: """
outer:
for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
        if (i == 1 && j == 1) continue outer;
        System.out.print(i + "" + j + " ");
    }
}
""",
        steps: [
            Step(index: 0, narration: "i=0では条件に一度も一致せず、j=0,1,2で `00 01 02` を出力します。", highlightLines: [2, 3, 5], variables: [Variable(name: "i", type: "int", value: "0", scope: "outer loop")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "i=1ではj=0で `10` を出力した後、j=1で `continue outer` が実行され、j=2を飛ばします。", highlightLines: [4, 5], variables: [Variable(name: "i", type: "int", value: "1", scope: "outer loop"), Variable(name: "j", type: "int", value: "1", scope: "inner loop")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "`11` は出力される？", choices: ["出力される", "出力されない"], answerIndex: 1, hint: "continueの前にprintへ進むか", afterExplanation: "正解です。continue outerでprint行を通りません。")),
            Step(index: 2, narration: "i=2では再び内側ループを完走し、最終出力は `00 01 02 10 20 21 22` です。", highlightLines: [2, 5], variables: [Variable(name: "i", type: "int", value: "2", scope: "outer loop")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let silverStringBuilder005Explanation = Explanation(
        id: "explain-silver-string-builder-005",
        initialCode: """
StringBuilder sb = new StringBuilder("abc");
sb.append("d").insert(1, "X").delete(3, 5);
System.out.println(sb);
""",
        steps: [
            Step(index: 0, narration: "`append(\"d\")` により sb は `abcd` になります。StringBuilderは同じオブジェクトを書き換えます。", highlightLines: [1, 2], variables: [Variable(name: "sb", type: "StringBuilder", value: "\"abcd\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`insert(1,\"X\")` で index1 の前にXを挿入し `aXbcd`。続く `delete(3,5)` はindex3以上5未満、つまり `c`,`d` を削除します。", highlightLines: [2], variables: [Variable(name: "sb", type: "StringBuilder", value: "\"aXb\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "delete後の値は？", choices: ["aXb", "aXbc", "abXd"], answerIndex: 0, hint: "end indexは含まない", afterExplanation: "正解です。cとdが削除されます。")),
            Step(index: 2, narration: "最終出力は `aXb` です。", highlightLines: [3], variables: [Variable(name: "sb", type: "StringBuilder", value: "\"aXb\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let silverCollections007Explanation = Explanation(
        id: "explain-silver-collections-007",
        initialCode: """
List<String> list = new ArrayList<>(Arrays.asList("A", "B", "C"));
Iterator<String> it = list.iterator();
while (it.hasNext()) {
    String s = it.next();
    if (s.equals("B")) it.remove();
}
System.out.println(list);
""",
        steps: [
            Step(index: 0, narration: "IteratorでA, B, Cを順に取り出します。Aでは条件不一致なので削除されません。", highlightLines: [2, 3, 4, 5], variables: [Variable(name: "s", type: "String", value: "\"A\"", scope: "while")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "Bを取り出した直後、`it.remove()` は直前に返した要素Bを安全に削除します。", highlightLines: [4, 5], variables: [Variable(name: "s", type: "String", value: "\"B\"", scope: "while"), Variable(name: "list", type: "List<String>", value: "[A, C]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "例外は起きる？", choices: ["起きる", "起きない"], answerIndex: 1, hint: "Iterator経由の削除", afterExplanation: "正解です。Iterator.remove()は走査中削除のためのAPIです。")),
            Step(index: 2, narration: "Cは残り、最終出力は `[A, C]` です。", highlightLines: [7], variables: [Variable(name: "list", type: "List<String>", value: "[A, C]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let silverOverload007Explanation = Explanation(
        id: "explain-silver-overload-007",
        initialCode: """
static void m(int x) { System.out.println("int"); }
static void m(Integer x) { System.out.println("Integer"); }
short s = 1;
m(s);
""",
        steps: [
            Step(index: 0, narration: "引数sの型はshortです。shortはプリミティブ型昇格でintへ変換できます。", highlightLines: [3, 4], variables: [Variable(name: "s", type: "short", value: "1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "`m(Integer)` はshortから直接Integerへボクシングできないため候補にならず、`m(int)` が選ばれます。", highlightLines: [1, 2, 4], variables: [], callStack: [CallStackFrame(method: "m(int)", line: 1)], heap: [], predict: PredictPrompt(question: "選ばれるのは？", choices: ["m(int)", "m(Integer)", "曖昧"], answerIndex: 0, hint: "short→intは型昇格", afterExplanation: "正解です。m(int)です。")),
            Step(index: 2, narration: "最終出力は `int` です。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "m(int)", line: 1)], heap: [], predict: nil),
        ]
    )

    static let silverClasses008Explanation = Explanation(
        id: "explain-silver-classes-008",
        initialCode: """
class Box {
    static int shared = 1;
    int value = shared++;
    Box() { value += shared; }
}
Box a = new Box();
Box b = new Box();
System.out.println(a.value + " " + b.value + " " + Box.shared);
""",
        steps: [
            Step(index: 0, narration: "a生成時、フィールド初期化でvalueにsharedの旧値1が入り、sharedは2になります。続くコンストラクタでvalue += 2となりa.valueは3です。", highlightLines: [2, 3, 4, 6], variables: [Variable(name: "Box.shared", type: "int", value: "2", scope: "class"), Variable(name: "a.value", type: "int", value: "3", scope: "heap")], callStack: [CallStackFrame(method: "Box()", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "b生成時はvalueにsharedの旧値2が入り、sharedは3へ。その後value += 3でb.valueは5です。", highlightLines: [3, 4, 7], variables: [Variable(name: "Box.shared", type: "int", value: "3", scope: "class"), Variable(name: "b.value", type: "int", value: "5", scope: "heap")], callStack: [CallStackFrame(method: "Box()", line: 4)], heap: [], predict: PredictPrompt(question: "b.valueは？", choices: ["3", "4", "5"], answerIndex: 2, hint: "旧値2 + 現在shared3", afterExplanation: "正解です。2 + 3 = 5です。")),
            Step(index: 2, narration: "最終出力は `3 5 3` です。", highlightLines: [8], variables: [Variable(name: "a.value", type: "int", value: "3", scope: "main"), Variable(name: "b.value", type: "int", value: "5", scope: "main"), Variable(name: "Box.shared", type: "int", value: "3", scope: "class")], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    static let silverException008Explanation = Explanation(
        id: "explain-silver-exception-008",
        initialCode: """
static int run() {
    try {
        System.out.print("T ");
        return 1;
    } finally {
        System.out.print("F ");
    }
}
System.out.println(run());
""",
        steps: [
            Step(index: 0, narration: "run()内のtryで `T ` を出力し、戻り値1を返す準備をします。", highlightLines: [2, 3, 4], variables: [Variable(name: "return value", type: "int", value: "1", scope: "run")], callStack: [CallStackFrame(method: "run", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "returnで戻る前にfinallyが必ず実行され、`F ` が出力されます。", highlightLines: [5, 6], variables: [], callStack: [CallStackFrame(method: "run", line: 6)], heap: [], predict: PredictPrompt(question: "finallyはいつ動く？", choices: ["println(run())の後", "run()から戻る前"], answerIndex: 1, hint: "finallyはメソッド脱出前", afterExplanation: "正解です。呼び出し元へ戻る前に動きます。")),
            Step(index: 2, narration: "run()が1を返した後、main側のprintlnが1を出力します。最終出力は `T F 1` です。", highlightLines: [9], variables: [], callStack: [CallStackFrame(method: "main", line: 9)], heap: [], predict: nil),
        ]
    )

    static let silverArray009Explanation = Explanation(
        id: "explain-silver-array-009",
        initialCode: """
int[][] array = new int[2][];
array[0] = new int[] {1, 2, 3};
array[1] = new int[] {4};
System.out.println(array.length + " " + array[0].length + " " + array[1][0]);
""",
        steps: [
            Step(index: 0, narration: "`new int[2][]` は外側だけ長さ2で作ります。内側配列はあとから個別に代入しています。", highlightLines: [1, 2, 3], variables: [Variable(name: "array.length", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "array[0]は3要素、array[1]は1要素です。array[1][0]の値は4です。", highlightLines: [2, 3, 4], variables: [Variable(name: "array[0].length", type: "int", value: "3", scope: "main"), Variable(name: "array[1][0]", type: "int", value: "4", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "array[0].lengthは？", choices: ["1", "2", "3"], answerIndex: 2, hint: "{1,2,3}", afterExplanation: "正解です。3要素です。")),
            Step(index: 2, narration: "最終出力は `2 3 4` です。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let silverLambda005Explanation = Explanation(
        id: "explain-silver-lambda-005",
        initialCode: """
Predicate<String> p = s -> { System.out.print("A"); return s.length() > 2; };
Predicate<String> q = s -> { System.out.print("B"); return s.startsWith("J"); };
System.out.println(p.and(q).test("Hi"));
""",
        steps: [
            Step(index: 0, narration: "`p.and(q).test(\"Hi\")` ではまず左側pを評価し、`A` を出力します。", highlightLines: [1, 3], variables: [Variable(name: "s", type: "String", value: "\"Hi\"", scope: "p")], callStack: [CallStackFrame(method: "Predicate.test", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "\"Hi\" の長さは2なので `s.length() > 2` はfalse。andは短絡評価なのでqは実行されず、`B` は出ません。", highlightLines: [1, 2, 3], variables: [Variable(name: "p result", type: "boolean", value: "false", scope: "and")], callStack: [CallStackFrame(method: "Predicate.and", line: 3)], heap: [], predict: PredictPrompt(question: "qは実行される？", choices: ["される", "されない"], answerIndex: 1, hint: "左がfalseのAND", afterExplanation: "正解です。ANDは左がfalseなら右を評価しません。")),
            Step(index: 2, narration: "printlnがfalseを出力し、全体の出力は `Afalse` です。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldStream012Explanation = Explanation(
        id: "explain-gold-stream-012",
        initialCode: """
nested.stream()
    .flatMap(List::stream)
    .distinct()
    .sorted()
    .forEach(System.out::print);
""",
        steps: [
            Step(index: 0, narration: "flatMapで内側Listを平坦化し、要素列は `2, 1, 2, 3` になります。", highlightLines: [1, 2], variables: [Variable(name: "stream", type: "Stream<Integer>", value: "2,1,2,3", scope: "pipeline")], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "distinctで2の重複を落として `2,1,3`。その後sortedで昇順 `1,2,3` になります。", highlightLines: [3, 4], variables: [Variable(name: "stream", type: "Stream<Integer>", value: "1,2,3", scope: "pipeline")], callStack: [], heap: [], predict: PredictPrompt(question: "sorted後の順は？", choices: ["2,1,3", "1,2,3", "2,1,2,3"], answerIndex: 1, hint: "distinctの後にsorted", afterExplanation: "正解です。昇順で1,2,3です。")),
            Step(index: 2, narration: "forEachで順に出力され、最終出力は `123` です。", highlightLines: [5], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldStream013Explanation = Explanation(
        id: "explain-gold-stream-013",
        initialCode: """
Map<Boolean, Long> map = Stream.of("a", "bb", "c")
    .collect(Collectors.partitioningBy(
        s -> s.length() == 1,
        Collectors.counting()
    ));
System.out.println(map.get(true) + ":" + map.get(false));
""",
        steps: [
            Step(index: 0, narration: "partitioningByは条件結果true/falseで分けます。長さ1は `a` と `c` の2件です。", highlightLines: [1, 2, 3], variables: [Variable(name: "true bucket", type: "Long", value: "2", scope: "map")], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "false側は長さ1ではない `bb` の1件。countingにより件数Longが入ります。", highlightLines: [3, 4], variables: [Variable(name: "false bucket", type: "Long", value: "1", scope: "map")], callStack: [], heap: [], predict: PredictPrompt(question: "map.get(false)は？", choices: ["0", "1", "null"], answerIndex: 1, hint: "bbがfalse側", afterExplanation: "正解です。1件です。")),
            Step(index: 2, narration: "最終出力は `2:1` です。", highlightLines: [6], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldGenerics008Explanation = Explanation(
        id: "explain-gold-generics-008",
        initialCode: """
static void addAll(List<? super Number> list) {
    list.add(1);
    list.add(2.5);
}
List<Object> values = new ArrayList<>();
addAll(values);
System.out.println(values);
""",
        steps: [
            Step(index: 0, narration: "`List<Object>` は `List<? super Number>` として渡せます。ObjectはNumberのスーパータイプだからです。", highlightLines: [1, 5, 6], variables: [Variable(name: "values", type: "List<Object>", value: "[]", scope: "main")], callStack: [CallStackFrame(method: "addAll", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`? super Number` にはNumberおよびそのサブタイプを追加できるため、Integerの1とDoubleの2.5が入ります。", highlightLines: [2, 3], variables: [Variable(name: "values", type: "List<Object>", value: "[1, 2.5]", scope: "main")], callStack: [CallStackFrame(method: "addAll", line: 3)], heap: [], predict: PredictPrompt(question: "追加できる？", choices: ["できる", "できない"], answerIndex: 0, hint: "Consumer super", afterExplanation: "正解です。super境界は書き込み側で使えます。")),
            Step(index: 2, narration: "同じListインスタンスが更新され、最終出力は `[1, 2.5]` です。", highlightLines: [7], variables: [Variable(name: "values", type: "List<Object>", value: "[1, 2.5]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let goldOptional008Explanation = Explanation(
        id: "explain-gold-optional-008",
        initialCode: """
String result = Optional.of("Java")
    .filter(s -> s.length() > 5)
    .orElseGet(() -> "fallback");
System.out.println(result);
""",
        steps: [
            Step(index: 0, narration: "Optionalには `Java` が入っています。filter条件は長さが5より大きいことです。", highlightLines: [1, 2], variables: [Variable(name: "s", type: "String", value: "\"Java\"", scope: "filter")], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "`Java` の長さは4なので条件false。Optionalは空になり、orElseGetのSupplierが実行されます。", highlightLines: [2, 3], variables: [Variable(name: "result", type: "String", value: "\"fallback\"", scope: "main")], callStack: [], heap: [], predict: PredictPrompt(question: "orElseGetは実行される？", choices: ["される", "されない"], answerIndex: 0, hint: "filter後は空", afterExplanation: "正解です。空Optionalなので実行されます。")),
            Step(index: 2, narration: "最終出力は `fallback` です。", highlightLines: [4], variables: [Variable(name: "result", type: "String", value: "\"fallback\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let goldCollections005Explanation = Explanation(
        id: "explain-gold-collections-005",
        initialCode: """
Map<String, List<Integer>> map = new HashMap<>();
map.computeIfAbsent("A", k -> new ArrayList<>()).add(1);
map.computeIfAbsent("A", k -> new ArrayList<>()).add(2);
System.out.println(map.get("A").size());
""",
        steps: [
            Step(index: 0, narration: "1回目のcomputeIfAbsentではキーAがないため、新しいArrayListを作成してMapへ入れ、そのListに1を追加します。", highlightLines: [1, 2], variables: [Variable(name: "map[A]", type: "List<Integer>", value: "[1]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "2回目はキーAが既にあるため、ラムダで新規Listは作らず既存Listを返し、そこへ2を追加します。", highlightLines: [3], variables: [Variable(name: "map[A]", type: "List<Integer>", value: "[1, 2]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: PredictPrompt(question: "sizeは？", choices: ["1", "2", "0"], answerIndex: 1, hint: "同じListへ追加", afterExplanation: "正解です。2件になります。")),
            Step(index: 2, narration: "最終出力は `2` です。", highlightLines: [4], variables: [Variable(name: "map[A].size()", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let goldCollections006Explanation = Explanation(
        id: "explain-gold-collections-006",
        initialCode: """
List<String> list = new ArrayList<>(List.of("A", "B", "C"));
List<String> sub = list.subList(1, 3);
sub.set(0, "X");
System.out.println(list);
""",
        steps: [
            Step(index: 0, narration: "`subList(1, 3)` は元Listのインデックス1から2までを指すビューです。独立コピーではありません。", highlightLines: [1, 2], variables: [Variable(name: "list", type: "List<String>", value: "[A, B, C]", scope: "main"), Variable(name: "sub", type: "List<String>", value: "[B, C] view", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`sub.set(0, \"X\")` はビューの0番、つまり元Listのインデックス1を書き換えます。出力は `[A, X, C]` です。", highlightLines: [3, 4], variables: [Variable(name: "list", type: "List<String>", value: "[A, X, C]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "subListはコピー？", choices: ["コピー", "ビュー"], answerIndex: 1, hint: "元Listに反映されます。", afterExplanation: "正解です。subListはビューです。")),
        ]
    )

    static let goldCollections007Explanation = Explanation(
        id: "explain-gold-collections-007",
        initialCode: """
List<Integer> list = new ArrayList<>(List.of(1, 2, 3));
list.remove(1);
list.remove(Integer.valueOf(1));
System.out.println(list);
""",
        steps: [
            Step(index: 0, narration: "`list.remove(1)` は引数がintなので、値1ではなくインデックス1の要素2を削除します。", highlightLines: [1, 2], variables: [Variable(name: "list", type: "List<Integer>", value: "[1, 3]", scope: "main")], callStack: [CallStackFrame(method: "remove", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`Integer.valueOf(1)` はObject引数として扱われ、値1を削除します。最終的なListは `[3]` です。", highlightLines: [3, 4], variables: [Variable(name: "list", type: "List<Integer>", value: "[3]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "`remove(1)` で消えるのは？", choices: ["値1", "インデックス1の要素"], answerIndex: 1, hint: "int引数のオーバーロードです。", afterExplanation: "正解です。2が削除されます。")),
        ]
    )

    static let goldCollections008Explanation = Explanation(
        id: "explain-gold-collections-008",
        initialCode: """
Set<String> set = new LinkedHashSet<>();
System.out.println(set.add("A") + ":" + set.add("A") + ":" + set.size());
""",
        steps: [
            Step(index: 0, narration: "空のSetへ最初に `A` を追加すると成功し、`add` はtrueを返します。", highlightLines: [1, 2], variables: [Variable(name: "first add", type: "boolean", value: "true", scope: "main"), Variable(name: "set", type: "Set<String>", value: "[A]", scope: "main")], callStack: [CallStackFrame(method: "add", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "2回目の `add(\"A\")` は重複なのでfalseです。サイズは1のまま、出力は `true:false:1` です。", highlightLines: [2], variables: [Variable(name: "second add", type: "boolean", value: "false", scope: "main"), Variable(name: "set.size()", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldCollections009Explanation = Explanation(
        id: "explain-gold-collections-009",
        initialCode: """
Queue<String> q = new ArrayDeque<>();
q.offer("A");
q.offer("B");
System.out.print(q.peek());
System.out.print(q.poll());
System.out.print(q.poll());
System.out.print(q.peek());
""",
        steps: [
            Step(index: 0, narration: "Queueとして使うArrayDequeはFIFOです。`offer` でA、Bの順に入ります。`peek()` は先頭Aを返しますが削除しません。", highlightLines: [1, 2, 3, 4], variables: [Variable(name: "q", type: "Queue<String>", value: "[A, B]", scope: "main"), Variable(name: "peek()", type: "String", value: "A", scope: "main")], callStack: [CallStackFrame(method: "peek", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "続くpollはA、次のpollはBを削除して返します。空になった後のpeekはnullなので、全体は `AABnull` です。", highlightLines: [5, 6, 7], variables: [Variable(name: "q", type: "Queue<String>", value: "[]", scope: "main"), Variable(name: "last peek", type: "String", value: "null", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: PredictPrompt(question: "peekは削除する？", choices: ["する", "しない"], answerIndex: 1, hint: "削除するのはpollです。", afterExplanation: "正解です。peekは参照だけです。")),
        ]
    )

    static let goldCollections010Explanation = Explanation(
        id: "explain-gold-collections-010",
        initialCode: """
Queue<Integer> q = new PriorityQueue<>();
q.offer(3);
q.offer(1);
q.offer(2);
while (!q.isEmpty()) {
    System.out.print(q.poll());
}
""",
        steps: [
            Step(index: 0, narration: "`PriorityQueue<Integer>` は挿入順ではなく、Integerの自然順序で最小値を先頭にします。", highlightLines: [1, 2, 3, 4], variables: [Variable(name: "q", type: "PriorityQueue<Integer>", value: "1,2,3 priority order", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "pollするたびに現在の最小値が返るため、1、2、3の順に出力されます。最終出力は `123` です。", highlightLines: [5, 6], variables: [Variable(name: "poll sequence", type: "int", value: "1 -> 2 -> 3", scope: "main")], callStack: [CallStackFrame(method: "poll", line: 6)], heap: [], predict: nil),
        ]
    )

    static let goldCollections011Explanation = Explanation(
        id: "explain-gold-collections-011",
        initialCode: """
Map<String, Integer> map = new HashMap<>();
System.out.println(map.put("A", 1) + ":" + map.put("A", 2) + ":" + map.get("A"));
""",
        steps: [
            Step(index: 0, narration: "最初の `put(\"A\", 1)` は旧値がないためnullを返し、MapにはA=1が入ります。", highlightLines: [1, 2], variables: [Variable(name: "first put", type: "Integer", value: "null", scope: "main"), Variable(name: "map[A]", type: "Integer", value: "1", scope: "main")], callStack: [CallStackFrame(method: "put", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "2回目のputは旧値1を返し、値を2へ上書きします。`get(\"A\")` は2なので `null:1:2` です。", highlightLines: [2], variables: [Variable(name: "second put", type: "Integer", value: "1", scope: "main"), Variable(name: "map[A]", type: "Integer", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "Map.putが返すのは？", choices: ["新値", "旧値"], answerIndex: 1, hint: "初回は旧値がないのでnull", afterExplanation: "正解です。旧値です。")),
        ]
    )

    static let goldCollections012Explanation = Explanation(
        id: "explain-gold-collections-012",
        initialCode: """
Map<String, Integer> map = new HashMap<>();
map.put("A", 1);
map.merge("A", 2, (oldValue, newValue) -> oldValue + newValue);
map.merge("B", 5, (oldValue, newValue) -> oldValue + newValue);
System.out.println(map.get("A") + ":" + map.get("B"));
""",
        steps: [
            Step(index: 0, narration: "キーAは既にあるため、mergeの関数が実行されます。旧値1と新値2を足してAは3になります。", highlightLines: [1, 2, 3], variables: [Variable(name: "map[A]", type: "Integer", value: "3", scope: "main")], callStack: [CallStackFrame(method: "merge", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "キーBは未登録なので、マージ関数は使われず指定値5がそのまま入ります。出力は `3:5` です。", highlightLines: [4, 5], variables: [Variable(name: "map[B]", type: "Integer", value: "5", scope: "main")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "Bのmergeでラムダは実行される？", choices: ["される", "されない"], answerIndex: 1, hint: "未登録キーです。", afterExplanation: "正解です。値5がそのまま入ります。")),
        ]
    )

    static let goldCollections013Explanation = Explanation(
        id: "explain-gold-collections-013",
        initialCode: """
List<String> list = new ArrayList<>();
List raw = list;
raw.add(10);
try {
    String s = list.get(0);
} catch (ClassCastException e) {
    System.out.println("CCE");
}
""",
        steps: [
            Step(index: 0, narration: "`List raw = list` によりジェネリクス検査が外れます。`raw.add(10)` は警告付きでコンパイルされ、Integerが入ります。", highlightLines: [1, 2, 3], variables: [Variable(name: "list", type: "List<String>", value: "[Integer(10)]", scope: "main")], callStack: [CallStackFrame(method: "add", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`String s = list.get(0)` ではStringへのキャストが入り、実体がIntegerなのでClassCastExceptionです。catchで `CCE` が出力されます。", highlightLines: [5, 6, 7], variables: [Variable(name: "element", type: "Integer", value: "10", scope: "main")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "失敗するタイミングは？", choices: ["raw.add(10)", "Stringへ取り出す時"], answerIndex: 1, hint: "raw addは警告で通ります。", afterExplanation: "正解です。取り出してStringへ代入する時です。")),
        ]
    )

    static let goldCollections014Explanation = Explanation(
        id: "explain-gold-collections-014",
        initialCode: """
List list = new ArrayList<String>();
list.add(10);
Object value = list.get(0);
System.out.println(value.getClass().getSimpleName());
""",
        steps: [
            Step(index: 0, narration: "変数型がraw `List` なので、`add(10)` は警告付きで許可されます。実体にはIntegerが入ります。", highlightLines: [1, 2], variables: [Variable(name: "list", type: "raw List", value: "[Integer(10)]", scope: "main")], callStack: [CallStackFrame(method: "add", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`Object value` で受けているためStringへのキャストは入りません。実体クラス名は `Integer` です。", highlightLines: [3, 4], variables: [Variable(name: "value", type: "Object", value: "Integer(10)", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let goldCollections015Explanation = Explanation(
        id: "explain-gold-collections-015",
        initialCode: """
static class Box<T> {
    private T value;
    Box(T value) { this.value = value; }
    T get() { return value; }
}
Box<String> box = new Box<>("Java");
System.out.println(box.get().substring(1));
""",
        steps: [
            Step(index: 0, narration: "`Box<String>` として生成しているため、このboxの `get()` の戻り値はStringとして扱われます。", highlightLines: [1, 6], variables: [Variable(name: "box.value", type: "String", value: "\"Java\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
            Step(index: 1, narration: "`box.get()` は `\"Java\"` を返します。`substring(1)` はインデックス1以降なので、出力は `ava` です。", highlightLines: [7], variables: [Variable(name: "box.get()", type: "String", value: "\"Java\"", scope: "main")], callStack: [CallStackFrame(method: "get", line: 7)], heap: [], predict: PredictPrompt(question: "get()の静的な戻り値型は？", choices: ["Object", "String"], answerIndex: 1, hint: "Box<String>です。", afterExplanation: "正解です。Stringです。")),
        ]
    )

    static let goldCollections016Explanation = Explanation(
        id: "explain-gold-collections-016",
        initialCode: """
static <T> T first(List<T> list) {
    return list.get(0);
}
String s = first(List.of("A", "B"));
System.out.println(s);
""",
        steps: [
            Step(index: 0, narration: "`first(List<T>)` はListの要素型Tをそのまま戻り値型にします。`List.of(\"A\", \"B\")` からTはStringと推論されます。", highlightLines: [1, 4], variables: [Variable(name: "T", type: "type parameter", value: "String", scope: "first")], callStack: [CallStackFrame(method: "first", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "`list.get(0)` は先頭のAを返します。戻り値はStringとして `s` に入り、出力は `A` です。", highlightLines: [2, 5], variables: [Variable(name: "s", type: "String", value: "\"A\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let goldCollections017Explanation = Explanation(
        id: "explain-gold-collections-017",
        initialCode: """
static class Box<T extends Number> {
    private T value;
    Box(T value) { this.value = value; }
    double asDouble() { return value.doubleValue(); }
}
Box<Integer> box = new Box<>(3);
System.out.println(box.asDouble());
""",
        steps: [
            Step(index: 0, narration: "`T extends Number` なので、T型のvalueでもNumberのメソッド `doubleValue()` を呼べます。", highlightLines: [1, 4], variables: [Variable(name: "T", type: "upper bound", value: "Number", scope: "Box")], callStack: [CallStackFrame(method: "asDouble", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "実体はInteger 3です。`doubleValue()` は3.0を返し、出力は `3.0` です。", highlightLines: [6, 7], variables: [Variable(name: "box.value", type: "Integer", value: "3", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let goldCollections018Explanation = Explanation(
        id: "explain-gold-collections-018",
        initialCode: """
static class Box<T> {
    T value = new T();
}
""",
        steps: [
            Step(index: 0, narration: "Javaのジェネリクスは型消去されるため、実行時にTの具体的なコンストラクタ情報を直接使えません。", highlightLines: [1, 2], variables: [Variable(name: "T", type: "type parameter", value: "erased", scope: "Box")], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`new T()` はコンパイルエラーです。生成が必要なら `Supplier<T>` や `Class<T>` を渡す設計にします。", highlightLines: [2], variables: [], callStack: [], heap: [], predict: PredictPrompt(question: "`new T()` は可能？", choices: ["可能", "不可"], answerIndex: 1, hint: "型消去です。", afterExplanation: "正解です。型パラメータは直接newできません。")),
        ]
    )

    static let goldCollections019Explanation = Explanation(
        id: "explain-gold-collections-019",
        initialCode: """
static class Item implements Comparable<Item> {
    int price;
    Item(int price) { this.price = price; }
    public int compareTo(Item other) { return this.price - other.price; }
}
List<Item> list = new ArrayList<>(List.of(new Item(3), new Item(1), new Item(2)));
Collections.sort(list);
System.out.println(list.get(0).price);
""",
        steps: [
            Step(index: 0, narration: "`Item` は `Comparable<Item>` を実装し、priceの差で昇順の自然順序を定義しています。", highlightLines: [1, 4], variables: [Variable(name: "compareTo", type: "method", value: "price ascending", scope: "Item")], callStack: [CallStackFrame(method: "compareTo", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "`Collections.sort(list)` でprice順に1,2,3へ並び替わります。先頭のpriceは1です。", highlightLines: [6, 7, 8], variables: [Variable(name: "list", type: "List<Item>", value: "[1, 2, 3]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: PredictPrompt(question: "sort後の先頭priceは？", choices: ["1", "3"], answerIndex: 0, hint: "昇順です。", afterExplanation: "正解です。1です。")),
        ]
    )

    static let goldCollections020Explanation = Explanation(
        id: "explain-gold-collections-020",
        initialCode: """
Set<String> set = new TreeSet<>(Comparator.comparingInt(String::length));
set.add("aa");
set.add("bb");
set.add("c");
System.out.println(set.size() + ":" + set);
""",
        steps: [
            Step(index: 0, narration: "このTreeSetは文字列の長さだけで比較します。`aa` と `bb` はどちらも長さ2なので、Comparatorの結果は0です。", highlightLines: [1, 2, 3], variables: [Variable(name: "compare(\"aa\", \"bb\")", type: "int", value: "0", scope: "TreeSet")], callStack: [CallStackFrame(method: "compare", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "TreeSetでは比較結果0を重複扱いにするため、bbは追加されません。長さ1のcが先に並び、出力は `2:[c, aa]` です。", highlightLines: [4, 5], variables: [Variable(name: "set", type: "TreeSet<String>", value: "[c, aa]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "bbは保持される？", choices: ["保持される", "重複扱い"], answerIndex: 1, hint: "比較結果0です。", afterExplanation: "正解です。長さだけで見るので重複扱いです。")),
        ]
    )

    static let goldCollections021Explanation = Explanation(
        id: "explain-gold-collections-021",
        initialCode: """
List<String> list = Arrays.asList("A", "B", "A");
System.out.println(Collections.frequency(list, "A"));
""",
        steps: [
            Step(index: 0, narration: "`Arrays.asList(\"A\", \"B\", \"A\")` はAを2つ含むListを作ります。Listは重複を保持します。", highlightLines: [1], variables: [Variable(name: "list", type: "List<String>", value: "[A, B, A]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`Collections.frequency(list, \"A\")` はequalsで一致する要素数を数えるので、結果は2です。", highlightLines: [2], variables: [Variable(name: "frequency", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "frequency", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldCollections022Explanation = Explanation(
        id: "explain-gold-collections-022",
        initialCode: """
List<Integer> list = new ArrayList<>(List.of(3, 1, 2));
Collections.sort(list);
Collections.reverse(list);
System.out.println(list);
""",
        steps: [
            Step(index: 0, narration: "`Collections.sort(list)` はList自身を昇順に並べ替えます。途中状態は `[1, 2, 3]` です。", highlightLines: [1, 2], variables: [Variable(name: "list", type: "List<Integer>", value: "[1, 2, 3]", scope: "main")], callStack: [CallStackFrame(method: "sort", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "続く `Collections.reverse(list)` もList自身を反転します。最終出力は `[3, 2, 1]` です。", highlightLines: [3, 4], variables: [Variable(name: "list", type: "List<Integer>", value: "[3, 2, 1]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "reverse後は？", choices: ["[1, 2, 3]", "[3, 2, 1]"], answerIndex: 1, hint: "sort後に反転します。", afterExplanation: "正解です。[3, 2, 1]です。")),
        ]
    )

    static let goldCollections023Explanation = Explanation(
        id: "explain-gold-collections-023",
        initialCode: """
List<String> list = List.of("A");
try {
    list.add("B");
} catch (UnsupportedOperationException e) {
    System.out.println("UOE");
}
""",
        steps: [
            Step(index: 0, narration: "`List.of(\"A\")` は変更不可Listを返します。List型なのでaddメソッドは見えますが、実装としては変更を許しません。", highlightLines: [1, 3], variables: [Variable(name: "list", type: "List<String>", value: "[A] unmodifiable", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`list.add(\"B\")` でUnsupportedOperationExceptionが発生し、catchで `UOE` が出力されます。", highlightLines: [3, 4, 5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "List.ofのListは変更可能？", choices: ["可能", "不可"], answerIndex: 1, hint: "ファクトリメソッドの戻り値です。", afterExplanation: "正解です。変更不可です。")),
        ]
    )

    static let goldCollections024Explanation = Explanation(
        id: "explain-gold-collections-024",
        initialCode: """
Map<String, Integer> map = new LinkedHashMap<>();
map.put("A", 1);
map.put("B", 2);
Set<String> keys = map.keySet();
keys.remove("A");
System.out.println(map.containsKey("A") + ":" + map.size());
""",
        steps: [
            Step(index: 0, narration: "`map.keySet()` はキーのコピーではなく、Map本体と連動するビューを返します。", highlightLines: [1, 2, 3, 4], variables: [Variable(name: "map", type: "LinkedHashMap<String,Integer>", value: "{A=1, B=2}", scope: "main"), Variable(name: "keys", type: "Set<String>", value: "[A, B] view", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "`keys.remove(\"A\")` はMapからAのエントリを削除します。`containsKey(\"A\")` はfalse、サイズは1です。", highlightLines: [5, 6], variables: [Variable(name: "map", type: "LinkedHashMap<String,Integer>", value: "{B=2}", scope: "main")], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: PredictPrompt(question: "keys.removeはMapに反映される？", choices: ["される", "されない"], answerIndex: 0, hint: "keySetはビューです。", afterExplanation: "正解です。Mapからも消えます。")),
        ]
    )

    static let goldCollections025Explanation = Explanation(
        id: "explain-gold-collections-025",
        initialCode: """
Map<String, Integer> map = new LinkedHashMap<>();
map.put("A", 1);
Map.Entry<String, Integer> entry = map.entrySet().iterator().next();
entry.setValue(9);
System.out.println(map.get("A"));
""",
        steps: [
            Step(index: 0, narration: "`entrySet()` から得たEntryはMap本体のエントリを表します。ここではキーA、値1のEntryです。", highlightLines: [1, 2, 3], variables: [Variable(name: "entry", type: "Map.Entry<String,Integer>", value: "A=1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`entry.setValue(9)` はEntryだけでなくMap本体の値を更新します。`map.get(\"A\")` は9です。", highlightLines: [4, 5], variables: [Variable(name: "map[A]", type: "Integer", value: "9", scope: "main")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "setValueはMap本体を変える？", choices: ["変える", "変えない"], answerIndex: 0, hint: "EntryはビューのようにMapと連動します。", afterExplanation: "正解です。Mapの値が9になります。")),
        ]
    )

    static let goldConcurrency009Explanation = Explanation(
        id: "explain-gold-concurrency-009",
        initialCode: """
CompletableFuture<Integer> future = CompletableFuture.<Integer>supplyAsync(() -> {
    throw new RuntimeException();
}).exceptionally(ex -> 10)
  .thenApply(n -> n + 5);
System.out.println(future.join());
""",
        steps: [
            Step(index: 0, narration: "supplyAsync内でRuntimeExceptionが投げられ、CompletableFutureは例外完了します。", highlightLines: [1, 2], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "exceptionallyが例外を受け取り、代替値10で正常系へ回復します。その後thenApplyで10+5になります。", highlightLines: [3, 4], variables: [Variable(name: "n", type: "Integer", value: "10 -> 15", scope: "future")], callStack: [], heap: [], predict: PredictPrompt(question: "joinで得る値は？", choices: ["10", "15", "例外"], answerIndex: 1, hint: "回復後にthenApply", afterExplanation: "正解です。10に5を足して15です。")),
            Step(index: 2, narration: "最終出力は `15` です。", highlightLines: [5], variables: [Variable(name: "future result", type: "Integer", value: "15", scope: "main")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let goldDateTime005Explanation = Explanation(
        id: "explain-gold-date-time-005",
        initialCode: """
LocalTime time = LocalTime.of(23, 30).plusMinutes(90);
System.out.println(time);
""",
        steps: [
            Step(index: 0, narration: "`LocalTime.of(23,30)` は23:30です。ここへ90分を加算します。", highlightLines: [1], variables: [Variable(name: "time", type: "LocalTime", value: "23:30 + 90min", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "90分後は翌日の01:00ですが、LocalTimeは日付を持たないため時刻だけが循環します。", highlightLines: [1], variables: [Variable(name: "time", type: "LocalTime", value: "01:00", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: PredictPrompt(question: "表示される時刻は？", choices: ["25:00", "01:00", "00:60"], answerIndex: 1, hint: "24時をまたぐ", afterExplanation: "正解です。01:00です。")),
            Step(index: 2, narration: "最終出力は `01:00` です。", highlightLines: [2], variables: [Variable(name: "time", type: "LocalTime", value: "01:00", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldIo006Explanation = Explanation(
        id: "explain-gold-io-006",
        initialCode: """
Path path = Path.of("/app/logs/app.log");
System.out.println(path.resolveSibling("old.log"));
""",
        steps: [
            Step(index: 0, narration: "pathの親は `/app/logs`、ファイル名は `app.log` です。", highlightLines: [1], variables: [Variable(name: "path", type: "Path", value: "/app/logs/app.log", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "resolveSiblingは同じ親ディレクトリ配下で、ファイル名部分を `old.log` に置き換えます。", highlightLines: [2], variables: [Variable(name: "result", type: "Path", value: "/app/logs/old.log", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "親ディレクトリは残る？", choices: ["残る", "消える"], answerIndex: 0, hint: "Sibling = 同じ親", afterExplanation: "正解です。同じ親の兄弟パスです。")),
            Step(index: 2, narration: "最終出力は `/app/logs/old.log` です。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldClasses007Explanation = Explanation(
        id: "explain-gold-classes-007",
        initialCode: """
record Point(int x, int y) {
    Point {
        if (x < 0) x = 0;
    }
}
Point p = new Point(-1, 2);
System.out.println(p.x() + "," + p.y());
""",
        steps: [
            Step(index: 0, narration: "new Point(-1,2) でコンパクトコンストラクタに入り、パラメータxは-1、yは2です。", highlightLines: [2, 6], variables: [Variable(name: "x", type: "int", value: "-1", scope: "Point ctor"), Variable(name: "y", type: "int", value: "2", scope: "Point ctor")], callStack: [CallStackFrame(method: "Point", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`x < 0` がtrueなので、コンストラクタパラメータxを0へ補正します。その後recordコンポーネントへ代入されます。", highlightLines: [3], variables: [Variable(name: "x", type: "int", value: "0", scope: "Point ctor")], callStack: [CallStackFrame(method: "Point", line: 3)], heap: [], predict: PredictPrompt(question: "p.x()は？", choices: ["-1", "0", "コンパイルエラー"], answerIndex: 1, hint: "パラメータ補正後にフィールドへ", afterExplanation: "正解です。0です。")),
            Step(index: 2, narration: "yは2のままなので、最終出力は `0,2` です。", highlightLines: [7], variables: [Variable(name: "p.x()", type: "int", value: "0", scope: "main"), Variable(name: "p.y()", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    // MARK: - Modifier / Static / Enum / Object Batch

    static let silverFinal001Explanation = Explanation(
        id: "explain-silver-final-001",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        final int x = 10;
        x++;
        System.out.println(x);
    }
}
""",
        steps: [
            Step(index: 0, narration: "`final int x = 10;` で、ローカル変数xは一度だけ代入された状態になります。", highlightLines: [3], variables: [Variable(name: "x", type: "int", value: "10", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`x++` は見た目は短くても、読み取り後にxへ新しい値を書き戻す操作です。つまりfinal変数への再代入になります。", highlightLines: [4], variables: [Variable(name: "x", type: "int", value: "10", scope: "main")], callStack: [CallStackFrame(method: "compile", line: 4)], heap: [], predict: PredictPrompt(question: "x++は許される？", choices: ["許される", "コンパイルエラー"], answerIndex: 1, hint: "++ は代入を含みます。", afterExplanation: "正解です。finalローカル変数には再代入できません。")),
            Step(index: 2, narration: "コンパイルエラーになるため、`System.out.println(x);` までは実行されません。", highlightLines: [5], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let silverFinal002Explanation = Explanation(
        id: "explain-silver-final-002",
        initialCode: """
class Card {
    final String rank;
    static final String SUIT = "S";

    Card(String rank) {
        this.rank = rank;
    }

    String label() {
        return rank + SUIT;
    }
}

Card card = new Card("A");
System.out.println(card.label());
""",
        steps: [
            Step(index: 0, narration: "`static final String SUIT` はクラス側の定数として `S` に初期化されています。`rank` はblank finalフィールドなので、コンストラクタで一度だけ代入できます。", highlightLines: [2, 3], variables: [Variable(name: "SUIT", type: "String", value: "\"S\"", scope: "Card")], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "`new Card(\"A\")` でコンストラクタに入り、`this.rank = rank;` により各インスタンスのfinalフィールドrankへAを保存します。", highlightLines: [5, 6, 14], variables: [Variable(name: "rank", type: "String", value: "\"A\"", scope: "Card ctor")], callStack: [CallStackFrame(method: "Card", line: 6)], heap: [HeapObject(id: "card", type: "Card", fields: ["rank": "\"A\""])], predict: PredictPrompt(question: "finalフィールドrankはここで代入できる？", choices: ["できる", "できない"], answerIndex: 0, hint: "blank finalはコンストラクタで初期化できます。", afterExplanation: "正解です。全コンストラクタ経路で一度だけ代入されれば有効です。")),
            Step(index: 2, narration: "`label()` はインスタンスフィールドrankとstaticフィールドSUITを同じクラス内から参照し、`AS` を返します。", highlightLines: [9, 10, 15], variables: [Variable(name: "card.label()", type: "String", value: "\"AS\"", scope: "main")], callStack: [CallStackFrame(method: "label", line: 10)], heap: [HeapObject(id: "card", type: "Card", fields: ["rank": "\"A\""])], predict: nil),
        ]
    )

    static let silverFinal003Explanation = Explanation(
        id: "explain-silver-final-003",
        initialCode: """
class Parent {
    final void show() {
        System.out.print("P");
    }
}

class Child extends Parent {
    void show() {
        System.out.print("C");
    }
}
""",
        steps: [
            Step(index: 0, narration: "`Parent.show()` には `final` が付いています。これはサブクラスで同じシグネチャのメソッドとしてオーバーライドできない、という意味です。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`Child` は `void show()` を宣言しており、`Parent.show()` をオーバーライドしようとしています。", highlightLines: [7, 8], variables: [], callStack: [CallStackFrame(method: "compile", line: 8)], heap: [], predict: PredictPrompt(question: "エラーになる場所は？", choices: ["extends Parent", "Childのshow()", "mainメソッド"], answerIndex: 1, hint: "継承自体は可能です。禁止されるのはfinalメソッドの上書きです。", afterExplanation: "正解です。Childのshow()宣言がfinalメソッドのオーバーライドとして拒否されます。")),
            Step(index: 2, narration: "したがってこのコードはコンパイルエラーです。finalメソッドを持つクラスを継承すること自体はできます。", highlightLines: [8], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let silverStatic001Explanation = Explanation(
        id: "explain-silver-static-001",
        initialCode: """
class Counter {
    static int total = 0;
    int id = ++total;
}

Counter a = new Counter();
Counter b = new Counter();
System.out.println(a.id + ":" + b.id + ":" + Counter.total);
""",
        steps: [
            Step(index: 0, narration: "Counterクラスのstaticフィールドtotalはクラスに1つだけあり、初期値は0です。", highlightLines: [2], variables: [Variable(name: "total", type: "int", value: "0", scope: "Counter")], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "1つ目の `new Counter()` で `++total` が先にtotalを1へ増やし、その値がa.idになります。", highlightLines: [3, 6], variables: [Variable(name: "total", type: "int", value: "1", scope: "Counter"), Variable(name: "a.id", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "Counter init", line: 3)], heap: [HeapObject(id: "a", type: "Counter", fields: ["id": "1"])], predict: nil),
            Step(index: 2, narration: "2つ目の生成でも同じtotalを共有するため、b.idは2、Counter.totalも2です。", highlightLines: [7, 8], variables: [Variable(name: "total", type: "int", value: "2", scope: "Counter"), Variable(name: "b.id", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 8)], heap: [HeapObject(id: "a", type: "Counter", fields: ["id": "1"]), HeapObject(id: "b", type: "Counter", fields: ["id": "2"])], predict: PredictPrompt(question: "出力は？", choices: ["1:2:2", "1:1:0", "0:1:2"], answerIndex: 0, hint: "totalは共有、++totalは前置です。", afterExplanation: "正解です。出力は1:2:2です。")),
        ]
    )

    static let silverStatic002Explanation = Explanation(
        id: "explain-silver-static-002",
        initialCode: """
class Tool {
    int size = 3;

    static int twice() {
        return size * 2;
    }
}
""",
        steps: [
            Step(index: 0, narration: "`size` はstaticではないため、Toolインスタンスごとに存在するフィールドです。", highlightLines: [2], variables: [Variable(name: "size", type: "int", value: "3", scope: "Tool instance")], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`twice()` はstaticメソッドです。static文脈には暗黙の `this` がないので、どのToolインスタンスのsizeか決められません。", highlightLines: [4, 5], variables: [], callStack: [CallStackFrame(method: "compile", line: 5)], heap: [], predict: PredictPrompt(question: "staticメソッドからsizeを直接読める？", choices: ["読める", "読めない"], answerIndex: 1, hint: "非staticメンバには対象インスタンスが必要です。", afterExplanation: "正解です。`new Tool().size` のような対象が必要です。")),
            Step(index: 2, narration: "そのため `return size * 2;` がコンパイルエラーになります。実行時の例外ではありません。", highlightLines: [5], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let silverStatic003Explanation = Explanation(
        id: "explain-silver-static-003",
        initialCode: """
class Item {
    static int rate = 2;
    int price;
    Item(int price) { this.price = price; }
    int total() { return price * rate; }
    static void change(int newRate) { rate = newRate; }
}

Item item = new Item(5);
System.out.print(item.total() + " ");
Item.change(3);
System.out.println(item.total());
""",
        steps: [
            Step(index: 0, narration: "Itemクラスのrateはstaticで共有され、最初は2です。`new Item(5)` でitem.priceは5になります。", highlightLines: [2, 4, 9], variables: [Variable(name: "rate", type: "int", value: "2", scope: "Item"), Variable(name: "item.price", type: "int", value: "5", scope: "main")], callStack: [CallStackFrame(method: "Item", line: 4)], heap: [HeapObject(id: "item", type: "Item", fields: ["price": "5"])], predict: nil),
            Step(index: 1, narration: "インスタンスメソッド `total()` では、インスタンス側のpriceとクラス側のrateの両方を参照できます。最初は5 * 2で10です。", highlightLines: [5, 10], variables: [Variable(name: "price", type: "int", value: "5", scope: "item"), Variable(name: "rate", type: "int", value: "2", scope: "Item")], callStack: [CallStackFrame(method: "total", line: 5)], heap: [], predict: PredictPrompt(question: "最初のtotal()は？", choices: ["5", "10", "15"], answerIndex: 1, hint: "rateは2です。", afterExplanation: "正解です。5 * 2で10です。")),
            Step(index: 2, narration: "`Item.change(3)` で共有rateが3になります。同じitemで再度total()を呼ぶと5 * 3で15です。", highlightLines: [6, 11, 12], variables: [Variable(name: "rate", type: "int", value: "3", scope: "Item"), Variable(name: "item.total()", type: "int", value: "15", scope: "main")], callStack: [CallStackFrame(method: "main", line: 12)], heap: [HeapObject(id: "item", type: "Item", fields: ["price": "5"])], predict: nil),
        ]
    )

    static let silverStatic004Explanation = Explanation(
        id: "explain-silver-static-004",
        initialCode: """
class Config {
    static int value = 7;
    static String name() { return "OK"; }
}

Config config = null;
System.out.println(config.name() + ":" + config.value);
""",
        steps: [
            Step(index: 0, narration: "Configクラスのstaticフィールドvalueは7、staticメソッドname()はOKを返すメソッドです。どちらもインスタンスではなくクラスに属します。", highlightLines: [2, 3], variables: [Variable(name: "value", type: "int", value: "7", scope: "Config")], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "`config` にはnullが入っています。ただし `config.name()` と `config.value` はstaticメンバなので、実際にはConfigのメンバとして解決されます。", highlightLines: [6, 7], variables: [Variable(name: "config", type: "Config", value: "null", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: PredictPrompt(question: "NullPointerExceptionになる？", choices: ["なる", "ならない"], answerIndex: 1, hint: "呼んでいる先はstaticメンバです。", afterExplanation: "正解です。推奨される書き方ではありませんが、staticメンバはクラス側で解決されます。")),
            Step(index: 2, narration: "name()はOK、valueは7なので、最終出力は `OK:7` です。", highlightLines: [7], variables: [Variable(name: "出力", type: "String", value: "\"OK:7\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let goldStatic005Explanation = Explanation(
        id: "explain-gold-static-005",
        initialCode: """
class Parent {
    static String name() { return "P"; }
    String label() { return "PI"; }
}
class Child extends Parent {
    static String name() { return "C"; }
    String label() { return "CI"; }
}
Parent p = new Child();
System.out.println(p.name() + ":" + p.label());
""",
        steps: [
            Step(index: 0, narration: "`p` の宣言型はParent、実体はChildです。この2つを分けて読みます。", highlightLines: [9], variables: [Variable(name: "p", type: "Parent", value: "Child instance", scope: "main")], callStack: [CallStackFrame(method: "main", line: 9)], heap: [HeapObject(id: "p", type: "Child", fields: [:])], predict: nil),
            Step(index: 1, narration: "`p.name()` はstaticメソッドです。staticメソッドはオーバーライドではなく隠蔽なので、参照型Parentに基づきParent.name()が選ばれます。", highlightLines: [2, 6, 10], variables: [Variable(name: "p.name()", type: "String", value: "\"P\"", scope: "main")], callStack: [CallStackFrame(method: "Parent.name", line: 2)], heap: [], predict: PredictPrompt(question: "name()はどちら？", choices: ["Parent.name()", "Child.name()"], answerIndex: 0, hint: "staticは参照型で決まります。", afterExplanation: "正解です。Parent版でPです。")),
            Step(index: 2, narration: "`p.label()` はインスタンスメソッドなので、実体Childに基づいてChild.label()が呼ばれます。出力は `P:CI` です。", highlightLines: [3, 7, 10], variables: [Variable(name: "p.label()", type: "String", value: "\"CI\"", scope: "main")], callStack: [CallStackFrame(method: "Child.label", line: 7)], heap: [HeapObject(id: "p", type: "Child", fields: [:])], predict: nil),
        ]
    )

    static let goldStatic006Explanation = Explanation(
        id: "explain-gold-static-006",
        initialCode: """
class Logger {
    static int n = init();
    static {
        System.out.print("B" + n + " ");
        n++;
    }
    Logger() { System.out.print("C" + n + " "); }
    static int init() {
        System.out.print("A ");
        return 1;
    }
}

new Logger();
new Logger();
System.out.println(Logger.n);
""",
        steps: [
            Step(index: 0, narration: "最初にLoggerを使うタイミングでクラス初期化が始まります。宣言順に `static int n = init();` が実行され、Aを出力してnは1になります。", highlightLines: [2, 8, 9, 14], variables: [Variable(name: "n", type: "int", value: "1", scope: "Logger")], callStack: [CallStackFrame(method: "init", line: 8)], heap: [], predict: nil),
            Step(index: 1, narration: "次にstaticブロックが一度だけ実行されます。現在のnは1なのでB1を出力し、その後nを2に増やします。", highlightLines: [3, 4, 5], variables: [Variable(name: "n", type: "int", value: "2", scope: "Logger")], callStack: [CallStackFrame(method: "static init", line: 5)], heap: [], predict: PredictPrompt(question: "staticブロックは2回目のnewでも走る？", choices: ["走る", "走らない"], answerIndex: 1, hint: "クラス初期化は一度だけです。", afterExplanation: "正解です。2回目以降のnewではコンストラクタだけです。")),
            Step(index: 2, narration: "コンストラクタはインスタンス生成ごとに2回実行され、どちらもC2を出力します。最後にLogger.nの2を出力するため、全体は `A B1 C2 C2 2` です。", highlightLines: [7, 14, 15, 16], variables: [Variable(name: "n", type: "int", value: "2", scope: "Logger")], callStack: [CallStackFrame(method: "main", line: 16)], heap: [HeapObject(id: "logger1", type: "Logger", fields: [:]), HeapObject(id: "logger2", type: "Logger", fields: [:])], predict: nil),
        ]
    )

    static let silverEnum001Explanation = Explanation(
        id: "explain-silver-enum-001",
        initialCode: """
enum Level { LOW, MEDIUM, HIGH }
Level level = Level.MEDIUM;
System.out.println(level.name() + ":" + level.ordinal());
""",
        steps: [
            Step(index: 0, narration: "LevelにはLOW、MEDIUM、HIGHの3つの定数があります。宣言順の番号ordinalは0始まりです。", highlightLines: [1], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "`level` には2番目の定数MEDIUMが入ります。name()は定数名そのものを返します。", highlightLines: [2, 3], variables: [Variable(name: "level", type: "Level", value: "MEDIUM", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: PredictPrompt(question: "MEDIUMのordinalは？", choices: ["0", "1", "2"], answerIndex: 1, hint: "LOWが0です。", afterExplanation: "正解です。MEDIUMは1です。")),
            Step(index: 2, narration: "したがって出力は `MEDIUM:1` です。", highlightLines: [3], variables: [Variable(name: "level.name()", type: "String", value: "\"MEDIUM\"", scope: "main"), Variable(name: "level.ordinal()", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let silverEnum002Explanation = Explanation(
        id: "explain-silver-enum-002",
        initialCode: """
enum Size {
    SMALL(1), LARGE(3);
    private final int code;
    Size(int code) { this.code = code; }
    int code() { return code; }
}
System.out.println(Size.LARGE.code());
""",
        steps: [
            Step(index: 0, narration: "enum定数SMALLとLARGEは、それぞれコンストラクタ引数1と3を持って生成されます。", highlightLines: [2, 4], variables: [], callStack: [CallStackFrame(method: "Size", line: 4)], heap: [HeapObject(id: "SMALL", type: "Size", fields: ["code": "1"]), HeapObject(id: "LARGE", type: "Size", fields: ["code": "3"])], predict: nil),
            Step(index: 1, narration: "`Size.LARGE.code()` はLARGE定数のインスタンスメソッドを呼び、LARGEが持つcodeフィールドを返します。", highlightLines: [5, 7], variables: [Variable(name: "Size.LARGE.code", type: "int", value: "3", scope: "Size")], callStack: [CallStackFrame(method: "code", line: 5)], heap: [], predict: PredictPrompt(question: "LARGEのcodeは？", choices: ["1", "3", "0"], answerIndex: 1, hint: "LARGE(3)です。", afterExplanation: "正解です。LARGEのコンストラクタ引数は3です。")),
            Step(index: 2, narration: "最終出力は `3` です。enumは単なる名前の列ではなく、フィールドやメソッドも持てます。", highlightLines: [7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let silverEnum003Explanation = Explanation(
        id: "explain-silver-enum-003",
        initialCode: """
enum Day { MON, TUE }
System.out.print(Day.values().length + " ");
System.out.println(Day.valueOf("MON") == Day.MON);
""",
        steps: [
            Step(index: 0, narration: "`Day.values()` は宣言済みの全enum定数を配列で返します。MONとTUEの2件なのでlengthは2です。", highlightLines: [1, 2], variables: [Variable(name: "Day.values().length", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`Day.valueOf(\"MON\")` は文字列名に一致する既存のenum定数Day.MONを返します。新しいインスタンスは作りません。", highlightLines: [3], variables: [Variable(name: "Day.valueOf(\"MON\")", type: "Day", value: "MON", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: PredictPrompt(question: "== の結果は？", choices: ["true", "false"], answerIndex: 0, hint: "enum定数は固定インスタンスです。", afterExplanation: "正解です。同じDay.MONなのでtrueです。")),
            Step(index: 2, narration: "最終出力は `2 true` です。", highlightLines: [2, 3], variables: [Variable(name: "出力", type: "String", value: "\"2 true\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldEnum004Explanation = Explanation(
        id: "explain-gold-enum-004",
        initialCode: """
enum Op {
    PLUS { int apply(int a, int b) { return a + b; } },
    TIMES { int apply(int a, int b) { return a * b; } };
    abstract int apply(int a, int b);
}
System.out.println(Op.PLUS.apply(2, 3) + ":" + Op.TIMES.apply(2, 3));
""",
        steps: [
            Step(index: 0, narration: "Opは抽象メソッドapplyを持つenumです。各定数PLUS/TIMESが自分用のクラス本体でapplyを実装しています。", highlightLines: [1, 2, 3, 4], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "`Op.PLUS.apply(2, 3)` はPLUS定数側の実装を使うため、2 + 3で5です。", highlightLines: [2, 6], variables: [Variable(name: "PLUS.apply(2,3)", type: "int", value: "5", scope: "main")], callStack: [CallStackFrame(method: "PLUS.apply", line: 2)], heap: [], predict: PredictPrompt(question: "TIMES.apply(2,3)は？", choices: ["5", "6"], answerIndex: 1, hint: "TIMESは掛け算です。", afterExplanation: "正解です。2 * 3で6です。")),
            Step(index: 2, narration: "`Op.TIMES.apply(2, 3)` はTIMES定数側の実装を使い、2 * 3で6です。出力は `5:6` です。", highlightLines: [3, 6], variables: [Variable(name: "TIMES.apply(2,3)", type: "int", value: "6", scope: "main")], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
        ]
    )

    static let goldEnum005Explanation = Explanation(
        id: "explain-gold-enum-005",
        initialCode: """
enum Color { RED, BLUE }
static String label(Color color) {
    return switch (color) {
        case RED -> "R";
        case BLUE -> "B";
    };
}
System.out.println(label(Color.BLUE));
""",
        steps: [
            Step(index: 0, narration: "Color enumにはREDとBLUEの2定数だけがあります。switch式ではこの2つをcaseで扱っています。", highlightLines: [1, 3, 4, 5], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "`label(Color.BLUE)` ではcolorがBLUEなので、BLUEケースの式 `\"B\"` がswitch式の値になります。", highlightLines: [5, 8], variables: [Variable(name: "color", type: "Color", value: "BLUE", scope: "label")], callStack: [CallStackFrame(method: "label", line: 5)], heap: [], predict: PredictPrompt(question: "defaultなしでコンパイルできる？", choices: ["できる", "できない"], answerIndex: 0, hint: "enumの全定数がcaseにあります。", afterExplanation: "正解です。REDとBLUEを網羅しているためdefaultなしで成立します。")),
            Step(index: 2, narration: "labelはBを返し、printlnが `B` を出力します。", highlightLines: [8], variables: [Variable(name: "label(Color.BLUE)", type: "String", value: "\"B\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    static let silverObject001Explanation = Explanation(
        id: "explain-silver-object-001",
        initialCode: """
Object a = new Object();
Object b = a;
Object c = new Object();
System.out.println(a.equals(b) + ":" + a.equals(c));
""",
        steps: [
            Step(index: 0, narration: "`a` は新しいObjectを参照し、`b = a` によってbも同じObjectを参照します。", highlightLines: [1, 2], variables: [Variable(name: "a", type: "Object", value: "obj1", scope: "main"), Variable(name: "b", type: "Object", value: "obj1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [HeapObject(id: "obj1", type: "Object", fields: [:])], predict: nil),
            Step(index: 1, narration: "`c` は別の `new Object()` なので、a/bとは異なる参照です。Objectのデフォルトequalsは参照同一性を比較します。", highlightLines: [3, 4], variables: [Variable(name: "c", type: "Object", value: "obj2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [HeapObject(id: "obj1", type: "Object", fields: [:]), HeapObject(id: "obj2", type: "Object", fields: [:])], predict: PredictPrompt(question: "a.equals(c)は？", choices: ["true", "false"], answerIndex: 1, hint: "cは別インスタンスです。", afterExplanation: "正解です。Object.equalsのままなら別参照はfalseです。")),
            Step(index: 2, narration: "`a.equals(b)` はtrue、`a.equals(c)` はfalseなので、出力は `true:false` です。", highlightLines: [4], variables: [Variable(name: "a.equals(b)", type: "boolean", value: "true", scope: "main"), Variable(name: "a.equals(c)", type: "boolean", value: "false", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let silverObject002Explanation = Explanation(
        id: "explain-silver-object-002",
        initialCode: """
Object value = "Java";
System.out.println(value.getClass().getSimpleName() + ":" + value.toString());
""",
        steps: [
            Step(index: 0, narration: "`value` の宣言型はObjectですが、実体は文字列リテラル `Java`、つまりStringインスタンスです。", highlightLines: [1], variables: [Variable(name: "value", type: "Object", value: "\"Java\" (String)", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`getClass()` は変数の宣言型ではなく実行時クラスを返します。そのためsimpleNameはStringです。", highlightLines: [2], variables: [Variable(name: "value.getClass().getSimpleName()", type: "String", value: "\"String\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "toString()はどの実装？", choices: ["Objectの実装", "Stringの実装"], answerIndex: 1, hint: "インスタンスメソッドは実体側で動的に選ばれます。", afterExplanation: "正解です。String.toString()が呼ばれ、Java自身を返します。")),
            Step(index: 2, narration: "`value.toString()` はStringの実装でJavaを返すので、出力は `String:Java` です。", highlightLines: [2], variables: [Variable(name: "value.toString()", type: "String", value: "\"Java\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    // MARK: - Silver: Core Reinforcement Batch

    static let silverJavaBasics007Explanation = Explanation(
        id: "explain-silver-java-basics-007",
        initialCode: """
int x = 0;
System.out.println(x++ + ":" + x);
""",
        steps: [
            Step(index: 0, narration: "`x` は0で初期化されます。式の左側にある `x++` は後置インクリメントです。", highlightLines: [1, 2], variables: [Variable(name: "x", type: "int", value: "0", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`x++` は式の値として0を渡し、その直後にxを1へ更新します。", highlightLines: [2], variables: [Variable(name: "x++の式値", type: "int", value: "0", scope: "main"), Variable(name: "x", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "右側のxは？", choices: ["0", "1"], answerIndex: 1, hint: "x++の後に評価されます。", afterExplanation: "正解です。右側のxは更新後の1です。")),
            Step(index: 2, narration: "文字列連結により `0:1` が出力されます。", highlightLines: [2], variables: [Variable(name: "出力", type: "String", value: "\"0:1\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let silverDataTypes013Explanation = Explanation(
        id: "explain-silver-data-types-013",
        initialCode: """
byte b = 1;
b += 2;
System.out.println(b);
""",
        steps: [
            Step(index: 0, narration: "`byte b = 1;` でbは1です。通常の `b + 2` は数値昇格によりintとして計算されます。", highlightLines: [1], variables: [Variable(name: "b", type: "byte", value: "1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`b += 2` は複合代入なので、計算後にbyteへ戻す暗黙キャストを含みます。", highlightLines: [2], variables: [Variable(name: "b", type: "byte", value: "3", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "b += 2 はコンパイルできる？", choices: ["できる", "できない"], answerIndex: 0, hint: "複合代入は暗黙キャストを含みます。", afterExplanation: "正解です。b = b + 2とは扱いが違います。")),
            Step(index: 2, narration: "bの値は3なので、出力は `3` です。", highlightLines: [3], variables: [Variable(name: "b", type: "byte", value: "3", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let silverDataTypes014Explanation = Explanation(
        id: "explain-silver-data-types-014",
        initialCode: """
System.out.println(10 / 4);
""",
        steps: [
            Step(index: 0, narration: "`10` も `4` もintリテラルなので、`10 / 4` はint同士の除算です。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "int除算では小数部が捨てられます。10 ÷ 4 は2余り2なので、式の値は2です。", highlightLines: [1], variables: [Variable(name: "10 / 4", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: PredictPrompt(question: "小数部はどうなる？", choices: ["保持される", "捨てられる"], answerIndex: 1, hint: "doubleが出てきません。", afterExplanation: "正解です。int結果の2になります。")),
            Step(index: 2, narration: "printlnは `2` を出力します。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
        ]
    )

    static let silverString007Explanation = Explanation(
        id: "explain-silver-string-007",
        initialCode: """
String s = " Java ";
System.out.println("[" + s.trim() + "]:" + s.length());
""",
        steps: [
            Step(index: 0, narration: "`s` は前後に空白を含む `\" Java \"` を参照します。長さは空白2文字を含めて6です。", highlightLines: [1], variables: [Variable(name: "s", type: "String", value: "\" Java \"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`s.trim()` は前後空白を除いた新しい文字列 `\"Java\"` を返します。Stringは不変なのでs自体は変わりません。", highlightLines: [2], variables: [Variable(name: "s.trim()", type: "String", value: "\"Java\"", scope: "main"), Variable(name: "s.length()", type: "int", value: "6", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "s.length()は？", choices: ["4", "6"], answerIndex: 1, hint: "trim()はsを書き換えません。", afterExplanation: "正解です。元のsの長さは6です。")),
            Step(index: 2, narration: "連結結果は `[` + `Java` + `]:` + `6` なので、出力は `[Java]:6` です。", highlightLines: [2], variables: [Variable(name: "出力", type: "String", value: "\"[Java]:6\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let silverStringBuilder006Explanation = Explanation(
        id: "explain-silver-stringbuilder-006",
        initialCode: """
StringBuilder sb = new StringBuilder("ab");
sb.append("c").delete(0, 1);
System.out.println(sb);
""",
        steps: [
            Step(index: 0, narration: "`sb` は内容 `ab` のStringBuilderです。StringBuilderは可変オブジェクトです。", highlightLines: [1], variables: [Variable(name: "sb", type: "StringBuilder", value: "\"ab\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [HeapObject(id: "sb", type: "StringBuilder", fields: ["value": "\"ab\""])], predict: nil),
            Step(index: 1, narration: "`append(\"c\")` で同じsbが `abc` になり、その戻り値に対して `delete(0, 1)` が呼ばれます。", highlightLines: [2], variables: [Variable(name: "sb", type: "StringBuilder", value: "\"abc\"", scope: "main")], callStack: [CallStackFrame(method: "append/delete", line: 2)], heap: [], predict: PredictPrompt(question: "delete(0,1)で消えるのは？", choices: ["aだけ", "aとb"], answerIndex: 0, hint: "終了位置は含まれません。", afterExplanation: "正解です。0番目のaだけが削除されます。")),
            Step(index: 2, narration: "delete後の内容は `bc` なので、printlnは `bc` を出力します。", highlightLines: [3], variables: [Variable(name: "sb", type: "StringBuilder", value: "\"bc\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [HeapObject(id: "sb", type: "StringBuilder", fields: ["value": "\"bc\""])], predict: nil),
        ]
    )

    static let silverArray010Explanation = Explanation(
        id: "explain-silver-array-010",
        initialCode: """
int[] a = new int[2];
System.out.println(a[0] + ":" + a.length);
""",
        steps: [
            Step(index: 0, narration: "`new int[2]` でint要素を2つ持つ配列を作ります。int配列の各要素は0で初期化されます。", highlightLines: [1], variables: [Variable(name: "a.length", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [HeapObject(id: "a", type: "int[]", fields: ["0": "0", "1": "0"])], predict: nil),
            Step(index: 1, narration: "`a[0]` は先頭要素なので0、`a.length` は最大インデックスではなく要素数なので2です。", highlightLines: [2], variables: [Variable(name: "a[0]", type: "int", value: "0", scope: "main"), Variable(name: "a.length", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "a.lengthは？", choices: ["1", "2"], answerIndex: 1, hint: "要素数です。", afterExplanation: "正解です。長さは2です。")),
            Step(index: 2, narration: "最終出力は `0:2` です。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let silverArray011Explanation = Explanation(
        id: "explain-silver-array-011",
        initialCode: """
String[] names = {"A", "B"};
Object obj = names;
System.out.println(obj instanceof String[]);
""",
        steps: [
            Step(index: 0, narration: "`names` の実体はString[]です。Javaの配列はオブジェクトなのでObject型変数へ代入できます。", highlightLines: [1, 2], variables: [Variable(name: "obj", type: "Object", value: "String[] instance", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [HeapObject(id: "names", type: "String[]", fields: ["0": "\"A\"", "1": "\"B\""])], predict: nil),
            Step(index: 1, narration: "Object型で参照していても実行時型はString[]のままです。`instanceof String[]` はその実体型を調べます。", highlightLines: [3], variables: [Variable(name: "obj instanceof String[]", type: "boolean", value: "true", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: PredictPrompt(question: "判定結果は？", choices: ["true", "false"], answerIndex: 0, hint: "参照型ではなく実体型です。", afterExplanation: "正解です。実体はString[]です。")),
            Step(index: 2, narration: "printlnは `true` を出力します。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let silverCollections008Explanation = Explanation(
        id: "explain-silver-collections-008",
        initialCode: """
List<String> list = new ArrayList<>();
list.add("A");
list.add(0, "B");
System.out.println(list);
""",
        steps: [
            Step(index: 0, narration: "空のArrayListを作り、`list.add(\"A\")` で末尾にAを追加します。", highlightLines: [1, 2], variables: [Variable(name: "list", type: "List<String>", value: "[A]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`list.add(0, \"B\")` は0番目への挿入です。既存のAは削除されず、右へずれます。", highlightLines: [3], variables: [Variable(name: "list", type: "List<String>", value: "[B, A]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: PredictPrompt(question: "add(0, \"B\")後は？", choices: ["[B, A]", "[B]"], answerIndex: 0, hint: "addは置換ではなく挿入です。", afterExplanation: "正解です。Aは後ろへずれます。")),
            Step(index: 2, narration: "ArrayListのtoString表記で `[B, A]` が出力されます。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let silverCollections009Explanation = Explanation(
        id: "explain-silver-collections-009",
        initialCode: """
Set<String> set = new HashSet<>();
set.add("A");
set.add("A");
System.out.println(set.size());
""",
        steps: [
            Step(index: 0, narration: "空のHashSetへ1回目の `\"A\"` を追加します。この時点のサイズは1です。", highlightLines: [1, 2], variables: [Variable(name: "set.size()", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "2回目も同じ `\"A\"` です。Setは重複を保持しないため、新しい要素としては追加されません。", highlightLines: [3], variables: [Variable(name: "set.size()", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: PredictPrompt(question: "サイズは増える？", choices: ["増える", "増えない"], answerIndex: 1, hint: "Setは重複なしです。", afterExplanation: "正解です。同じAは1つだけです。")),
            Step(index: 2, narration: "サイズは1のままなので、出力は `1` です。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let silverControlFlow011Explanation = Explanation(
        id: "explain-silver-control-flow-011",
        initialCode: """
int x = 2;
switch (x) {
    case 1:
        System.out.print("A");
    case 2:
        System.out.print("B");
    default:
        System.out.print("C");
}
""",
        steps: [
            Step(index: 0, narration: "`x` は2なので、switchは `case 2` の位置から実行を開始します。case 1のAは実行されません。", highlightLines: [1, 5], variables: [Variable(name: "x", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
            Step(index: 1, narration: "case 2でBを出力します。その後にbreakがないため、次のdefaultへフォールスルーします。", highlightLines: [6, 7], variables: [Variable(name: "出力途中", type: "String", value: "\"B\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: PredictPrompt(question: "defaultも実行される？", choices: ["される", "されない"], answerIndex: 0, hint: "breakがありません。", afterExplanation: "正解です。Cも続けて出力されます。")),
            Step(index: 2, narration: "defaultでCを出力し、最終出力は `BC` です。", highlightLines: [7, 8], variables: [Variable(name: "出力", type: "String", value: "\"BC\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    static let silverControlFlow012Explanation = Explanation(
        id: "explain-silver-control-flow-012",
        initialCode: """
for (int i = 0; i < 3; i++) {
    if (i == 1) {
        continue;
    }
    System.out.print(i);
}
""",
        steps: [
            Step(index: 0, narration: "i=0では条件 `i == 1` がfalseなので、continueせず0を出力します。", highlightLines: [1, 2, 5], variables: [Variable(name: "i", type: "int", value: "0", scope: "for")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
            Step(index: 1, narration: "i=1では条件がtrueになり、continueでその回の残り処理を飛ばします。1は出力されません。", highlightLines: [2, 3], variables: [Variable(name: "i", type: "int", value: "1", scope: "for")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: PredictPrompt(question: "continueはループを終了する？", choices: ["終了する", "次の反復へ進む"], answerIndex: 1, hint: "終了はbreakです。", afterExplanation: "正解です。更新式へ進み、次の反復に入ります。")),
            Step(index: 2, narration: "i=2では再び出力されます。したがって全体の出力は `02` です。", highlightLines: [1, 5], variables: [Variable(name: "i", type: "int", value: "2", scope: "for"), Variable(name: "出力", type: "String", value: "\"02\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let silverClasses009Explanation = Explanation(
        id: "explain-silver-classes-009",
        initialCode: """
class A {
    A() {
        this(1);
        System.out.print("A");
    }
    A(int x) {
        System.out.print(x);
    }
}
new A();
""",
        steps: [
            Step(index: 0, narration: "`new A()` で引数なしコンストラクタA()に入ります。先頭文の `this(1)` が別コンストラクタA(int)を呼びます。", highlightLines: [2, 3, 10], variables: [], callStack: [CallStackFrame(method: "A()", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "A(int)ではxが1なので、まず `1` を出力します。その後、呼び出し元のA()へ戻ります。", highlightLines: [6, 7], variables: [Variable(name: "x", type: "int", value: "1", scope: "A(int)")], callStack: [CallStackFrame(method: "A(int)", line: 7)], heap: [], predict: PredictPrompt(question: "先に出る文字は？", choices: ["1", "A"], answerIndex: 0, hint: "this(1)が先です。", afterExplanation: "正解です。A(int)の1が先です。")),
            Step(index: 2, narration: "A()の続きで `A` を出力するため、最終出力は `1A` です。", highlightLines: [4], variables: [Variable(name: "出力", type: "String", value: "\"1A\"", scope: "main")], callStack: [CallStackFrame(method: "A()", line: 4)], heap: [HeapObject(id: "A instance", type: "A", fields: [:])], predict: nil),
        ]
    )

    static let silverClasses010Explanation = Explanation(
        id: "explain-silver-classes-010",
        initialCode: """
class Box {
    int value;
}
Box box = new Box();
System.out.println(box.value);
""",
        steps: [
            Step(index: 0, narration: "`value` はインスタンスフィールドです。intフィールドはオブジェクト生成時に0で初期化されます。", highlightLines: [2, 4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [HeapObject(id: "box", type: "Box", fields: ["value": "0"])], predict: nil),
            Step(index: 1, narration: "ローカル変数なら未初期化で読めませんが、フィールドにはデフォルト値があります。`box.value` は0です。", highlightLines: [5], variables: [Variable(name: "box.value", type: "int", value: "0", scope: "main")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "box.valueは読める？", choices: ["読める", "コンパイルエラー"], answerIndex: 0, hint: "フィールドは初期化済みです。", afterExplanation: "正解です。0として読めます。")),
            Step(index: 2, narration: "printlnは `0` を出力します。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let silverInheritance008Explanation = Explanation(
        id: "explain-silver-inheritance-008",
        initialCode: """
class Parent {
    String name() { return "P"; }
}
class Child extends Parent {
    String name() { return "C"; }
}
Parent p = new Child();
System.out.println(p.name());
""",
        steps: [
            Step(index: 0, narration: "`p` の宣言型はParentですが、実体はChildです。この区別がポリモーフィズムの読みどころです。", highlightLines: [7], variables: [Variable(name: "p", type: "Parent", value: "Child instance", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [HeapObject(id: "p", type: "Child", fields: [:])], predict: nil),
            Step(index: 1, narration: "`name()` はインスタンスメソッドで、Childがオーバーライドしています。実行時の実体Childに基づいてChild.name()が選ばれます。", highlightLines: [2, 5, 8], variables: [Variable(name: "p.name()", type: "String", value: "\"C\"", scope: "main")], callStack: [CallStackFrame(method: "Child.name", line: 5)], heap: [], predict: PredictPrompt(question: "呼ばれるname()は？", choices: ["Parent", "Child"], answerIndex: 1, hint: "インスタンスメソッドは実体で選ばれます。", afterExplanation: "正解です。Child.name()です。")),
            Step(index: 2, narration: "Child.name()の戻り値は `C` なので、出力は `C` です。", highlightLines: [8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    static let silverInheritance009Explanation = Explanation(
        id: "explain-silver-inheritance-009",
        initialCode: """
class Parent {
    String value = "P";
}
class Child extends Parent {
    String value = "C";
}
Parent p = new Child();
System.out.println(p.value);
""",
        steps: [
            Step(index: 0, narration: "ChildインスタンスにはParent由来のvalueとChild自身のvalueがあり、Child側のフィールドは親フィールドを隠蔽します。", highlightLines: [2, 5, 7], variables: [Variable(name: "p", type: "Parent", value: "Child instance", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [HeapObject(id: "p", type: "Child", fields: ["Parent.value": "\"P\"", "Child.value": "\"C\""])], predict: nil),
            Step(index: 1, narration: "フィールドアクセスはメソッドのように動的ディスパッチされません。`p.value` は参照型Parentに基づいてParent.valueを読みます。", highlightLines: [8], variables: [Variable(name: "p.value", type: "String", value: "\"P\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: PredictPrompt(question: "読まれるフィールドは？", choices: ["Parent.value", "Child.value"], answerIndex: 0, hint: "フィールドは参照型で決まります。", afterExplanation: "正解です。Parent側のPです。")),
            Step(index: 2, narration: "したがって出力は `P` です。メソッドのオーバーライドとは違う点に注意します。", highlightLines: [8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    static let silverException009Explanation = Explanation(
        id: "explain-silver-exception-009",
        initialCode: """
try {
    System.out.print("T");
    throw new RuntimeException();
} catch (RuntimeException e) {
    System.out.print("C");
} finally {
    System.out.print("F");
}
""",
        steps: [
            Step(index: 0, narration: "tryブロックに入り、まず `T` を出力します。続いてRuntimeExceptionをthrowします。", highlightLines: [1, 2, 3], variables: [Variable(name: "出力途中", type: "String", value: "\"T\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "throwされた例外は `catch (RuntimeException e)` に一致するため捕捉され、`C` を出力します。", highlightLines: [4, 5], variables: [Variable(name: "出力途中", type: "String", value: "\"TC\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "finallyは実行される？", choices: ["される", "されない"], answerIndex: 0, hint: "catchされた後でもfinallyへ進みます。", afterExplanation: "正解です。finallyも実行されます。")),
            Step(index: 2, narration: "finallyブロックで `F` が出力され、最終出力は `TCF` です。", highlightLines: [6, 7], variables: [Variable(name: "出力", type: "String", value: "\"TCF\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let silverException010Explanation = Explanation(
        id: "explain-silver-exception-010",
        initialCode: """
import java.io.IOException;
static void read() throws IOException {
}
read();
""",
        steps: [
            Step(index: 0, narration: "`read()` は `throws IOException` を宣言しています。IOExceptionは検査例外です。", highlightLines: [1, 2], variables: [], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "main側で `read();` を呼ぶなら、try-catchで捕捉するか、mainにも `throws IOException` を宣言する必要があります。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "compile", line: 4)], heap: [], predict: PredictPrompt(question: "この呼び出しはそのまま通る？", choices: ["通る", "通らない"], answerIndex: 1, hint: "検査例外の処理がありません。", afterExplanation: "正解です。未処理のIOExceptionとしてコンパイルエラーです。")),
            Step(index: 2, narration: "このコードではどちらもないため、`read();` の行でコンパイルエラーになります。", highlightLines: [4], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let silverLambda006Explanation = Explanation(
        id: "explain-silver-lambda-006",
        initialCode: """
Predicate<String> p = s -> s.startsWith("J");
System.out.println(p.test("Java"));
""",
        steps: [
            Step(index: 0, narration: "Predicate<String>の抽象メソッドは `boolean test(String)` です。ラムダ `s -> s.startsWith(\"J\")` はStringを受け取りbooleanを返します。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`p.test(\"Java\")` ではsに `\"Java\"` が入り、`startsWith(\"J\")` を評価します。", highlightLines: [2], variables: [Variable(name: "s", type: "String", value: "\"Java\"", scope: "lambda"), Variable(name: "s.startsWith(\"J\")", type: "boolean", value: "true", scope: "lambda")], callStack: [CallStackFrame(method: "Predicate.test", line: 1)], heap: [], predict: PredictPrompt(question: "testの戻り値は？", choices: ["true", "false"], answerIndex: 0, hint: "JavaはJで始まります。", afterExplanation: "正解です。trueです。")),
            Step(index: 2, narration: "printlnはboolean値 `true` を出力します。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let silverStatic005Explanation = Explanation(
        id: "explain-silver-static-005",
        initialCode: """
class Counter {
    static int count;
    Counter() { count++; }
}
new Counter();
new Counter();
System.out.println(Counter.count);
""",
        steps: [
            Step(index: 0, narration: "`count` はstaticフィールドなのでCounterクラスに1つだけ存在します。初期値はintのデフォルト値0です。", highlightLines: [2], variables: [Variable(name: "Counter.count", type: "int", value: "0", scope: "Counter")], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "1回目と2回目の `new Counter()` でコンストラクタがそれぞれ実行され、共有countが1、2へ増えます。", highlightLines: [3, 5, 6], variables: [Variable(name: "Counter.count", type: "int", value: "2", scope: "Counter")], callStack: [CallStackFrame(method: "Counter", line: 3)], heap: [HeapObject(id: "counter1", type: "Counter", fields: [:]), HeapObject(id: "counter2", type: "Counter", fields: [:])], predict: PredictPrompt(question: "countはインスタンスごと？", choices: ["共有", "別々"], answerIndex: 0, hint: "staticです。", afterExplanation: "正解です。クラスに1つだけです。")),
            Step(index: 2, narration: "`Counter.count` は2なので、出力は `2` です。", highlightLines: [7], variables: [Variable(name: "Counter.count", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let silverFinal004Explanation = Explanation(
        id: "explain-silver-final-004",
        initialCode: """
final int x = 1;
x = 2;
System.out.println(x);
""",
        steps: [
            Step(index: 0, narration: "`final int x = 1;` により、xは一度だけ代入済みのローカル変数になります。", highlightLines: [1], variables: [Variable(name: "x", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "次の `x = 2;` は同じfinal変数への再代入です。finalローカル変数には再代入できません。", highlightLines: [2], variables: [Variable(name: "x", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: PredictPrompt(question: "x = 2 は？", choices: ["有効", "コンパイルエラー"], answerIndex: 1, hint: "xはfinalです。", afterExplanation: "正解です。再代入として拒否されます。")),
            Step(index: 2, narration: "コンパイルエラーになるため、printlnは実行されません。", highlightLines: [3], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let silverJavaBasics008Explanation = Explanation(
        id: "explain-silver-java-basics-008",
        initialCode: """
public static void main(String[] args) {
    main(1);
}
static void main(int x) {
    System.out.println("int " + x);
}
""",
        steps: [
            Step(index: 0, narration: "JVMのエントリポイントは `main(String[] args)` です。同じ名前でも `main(int)` は通常のオーバーロードメソッドです。", highlightLines: [1, 4], variables: [], callStack: [CallStackFrame(method: "main(String[])", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`main(1)` はint引数なので、`static void main(int x)` が選ばれます。xには1が入ります。", highlightLines: [2, 4], variables: [Variable(name: "x", type: "int", value: "1", scope: "main(int)")], callStack: [CallStackFrame(method: "main(int)", line: 4)], heap: [], predict: PredictPrompt(question: "呼ばれるmainは？", choices: ["main(String[])", "main(int)"], answerIndex: 1, hint: "引数が1つのintです。", afterExplanation: "正解です。オーバーロードされたmain(int)です。")),
            Step(index: 2, narration: "`\"int \" + x` により、最終出力は `int 1` です。", highlightLines: [5], variables: [Variable(name: "出力", type: "String", value: "\"int 1\"", scope: "main(int)")], callStack: [CallStackFrame(method: "main(int)", line: 5)], heap: [], predict: nil),
        ]
    )

    static let silverDataTypes015Explanation = Explanation(
        id: "explain-silver-data-types-015",
        initialCode: """
char c = 'A';
c++;
System.out.println((int) c + ":" + c);
""",
        steps: [
            Step(index: 0, narration: "`char c = 'A';` でcは文字Aを保持します。Aの数値コードは65です。", highlightLines: [1], variables: [Variable(name: "c", type: "char", value: "'A' (65)", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`c++` によりcharの値が1増え、次の文字Bになります。数値コードは66です。", highlightLines: [2], variables: [Variable(name: "c", type: "char", value: "'B' (66)", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "(int)c は？", choices: ["65", "66"], answerIndex: 1, hint: "c++の後です。", afterExplanation: "正解です。Bのコード値66です。")),
            Step(index: 2, narration: "`(int)c` は66、文字としてのcはBなので、出力は `66:B` です。", highlightLines: [3], variables: [Variable(name: "出力", type: "String", value: "\"66:B\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let silverDataTypes016Explanation = Explanation(
        id: "explain-silver-data-types-016",
        initialCode: """
short s = 1;
s = s + 1;
System.out.println(s);
""",
        steps: [
            Step(index: 0, narration: "`s` はshortとして1で初期化されます。ただし算術演算に入るとshortはintへ昇格します。", highlightLines: [1], variables: [Variable(name: "s", type: "short", value: "1", scope: "main")], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`s + 1` の式全体の型はintです。intをshort変数sへそのまま代入することはできません。", highlightLines: [2], variables: [Variable(name: "s + 1", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: PredictPrompt(question: "式 `s + 1` の型は？", choices: ["short", "int"], answerIndex: 1, hint: "小さい整数型は演算で昇格します。", afterExplanation: "正解です。intです。")),
            Step(index: 2, narration: "そのため `s = s + 1;` でコンパイルエラーとなり、printlnは実行されません。", highlightLines: [2, 3], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let silverDataTypes017Explanation = Explanation(
        id: "explain-silver-data-types-017",
        initialCode: """
boolean flag = false;
if (flag = true) {
    System.out.println("T");
} else {
    System.out.println("F");
}
""",
        steps: [
            Step(index: 0, narration: "flagは最初falseです。ただしif条件にあるのは比較 `==` ではなく代入 `=` です。", highlightLines: [1, 2], variables: [Variable(name: "flag", type: "boolean", value: "false", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`flag = true` はflagへtrueを代入し、式の値としてtrueを返します。if条件はtrueになります。", highlightLines: [2], variables: [Variable(name: "flag", type: "boolean", value: "true", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "if条件の値は？", choices: ["true", "false"], answerIndex: 0, hint: "代入後の値が式の値です。", afterExplanation: "正解です。then側に進みます。")),
            Step(index: 2, narration: "then側のprintlnが実行され、出力は `T` です。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let silverString008Explanation = Explanation(
        id: "explain-silver-string-008",
        initialCode: """
String s = "abcdef";
System.out.println(s.substring(1, 4));
""",
        steps: [
            Step(index: 0, narration: "`abcdef` のインデックスは a=0、b=1、c=2、d=3、e=4、f=5 です。", highlightLines: [1], variables: [Variable(name: "s", type: "String", value: "\"abcdef\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`substring(1, 4)` は開始1を含み、終了4を含みません。したがって取り出す範囲はb、c、dです。", highlightLines: [2], variables: [Variable(name: "s.substring(1,4)", type: "String", value: "\"bcd\"", scope: "main")], callStack: [CallStackFrame(method: "substring", line: 2)], heap: [], predict: PredictPrompt(question: "index 4のeは含む？", choices: ["含む", "含まない"], answerIndex: 1, hint: "endIndexは非包含です。", afterExplanation: "正解です。eは含まれません。")),
            Step(index: 2, narration: "printlnは `bcd` を出力します。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let silverStringBuilder007Explanation = Explanation(
        id: "explain-silver-stringbuilder-007",
        initialCode: """
StringBuilder sb = new StringBuilder("ace");
sb.insert(1, "b");
sb.replace(2, 3, "D");
System.out.println(sb);
""",
        steps: [
            Step(index: 0, narration: "`sb` の初期内容は `ace` です。`insert(1, \"b\")` はindex 1の位置へbを挿入し、内容は `abce` になります。", highlightLines: [1, 2], variables: [Variable(name: "sb", type: "StringBuilder", value: "\"abce\"", scope: "main")], callStack: [CallStackFrame(method: "insert", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`replace(2, 3, \"D\")` は開始2を含み、終了3を含まない範囲、つまりcだけをDに置換します。", highlightLines: [3], variables: [Variable(name: "sb", type: "StringBuilder", value: "\"abDe\"", scope: "main")], callStack: [CallStackFrame(method: "replace", line: 3)], heap: [], predict: PredictPrompt(question: "置換される文字は？", choices: ["cだけ", "cとe"], answerIndex: 0, hint: "終了indexは含みません。", afterExplanation: "正解です。cだけです。")),
            Step(index: 2, narration: "最終的なStringBuilderの内容は `abDe` です。", highlightLines: [4], variables: [Variable(name: "出力", type: "String", value: "\"abDe\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let silverArray012Explanation = Explanation(
        id: "explain-silver-array-012",
        initialCode: """
int[] nums = {1, 2, 3};
for (int n : nums) {
    n *= 2;
}
System.out.println(nums[0] + ":" + nums[1] + ":" + nums[2]);
""",
        steps: [
            Step(index: 0, narration: "numsは `[1, 2, 3]` です。拡張forの `n` は各要素の値を受け取るローカル変数です。", highlightLines: [1, 2], variables: [Variable(name: "nums", type: "int[]", value: "[1, 2, 3]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`n *= 2` はローカル変数nを書き換えますが、配列の要素そのものを書き換える代入ではありません。", highlightLines: [3], variables: [Variable(name: "n", type: "int", value: "一時的に2/4/6", scope: "for")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: PredictPrompt(question: "nums[0]は変わる？", choices: ["変わる", "変わらない"], answerIndex: 1, hint: "nはコピーです。", afterExplanation: "正解です。配列は元のままです。")),
            Step(index: 2, narration: "配列は `[1, 2, 3]` のままなので、出力は `1:2:3` です。", highlightLines: [5], variables: [Variable(name: "出力", type: "String", value: "\"1:2:3\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let silverArray013Explanation = Explanation(
        id: "explain-silver-array-013",
        initialCode: """
Object[] values = new String[1];
values[0] = 10;
System.out.println(values[0]);
""",
        steps: [
            Step(index: 0, narration: "String[]はObject[]へ代入できます。これは配列の共変性です。ただし実行時の配列型はString[]のままです。", highlightLines: [1], variables: [Variable(name: "values", type: "Object[]", value: "String[1]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [HeapObject(id: "values", type: "String[]", fields: ["0": "null"])], predict: nil),
            Step(index: 1, narration: "`10` はIntegerとして扱われます。実体がString[]の配列へIntegerを格納しようとするため、実行時チェックに失敗します。", highlightLines: [2], variables: [Variable(name: "values[0]", type: "Integer", value: "10", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "発生する例外は？", choices: ["ArrayStoreException", "ClassCastException"], answerIndex: 0, hint: "配列への格納時です。", afterExplanation: "正解です。ArrayStoreExceptionです。")),
            Step(index: 2, narration: "2行目で `ArrayStoreException` が発生するため、printlnには進みません。", highlightLines: [2, 3], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let silverCollections010Explanation = Explanation(
        id: "explain-silver-collections-010",
        initialCode: """
List<Integer> list = new ArrayList<>(List.of(1, 2, 3));
list.remove(1);
System.out.println(list);
""",
        steps: [
            Step(index: 0, narration: "`new ArrayList<>(List.of(1, 2, 3))` により、変更可能なArrayList `[1, 2, 3]` を作ります。", highlightLines: [1], variables: [Variable(name: "list", type: "List<Integer>", value: "[1, 2, 3]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`remove(1)` の引数1はintリテラルなので、`remove(int index)` が選ばれます。index 1の要素2が削除されます。", highlightLines: [2], variables: [Variable(name: "list", type: "List<Integer>", value: "[1, 3]", scope: "main")], callStack: [CallStackFrame(method: "remove", line: 2)], heap: [], predict: PredictPrompt(question: "削除されるのは？", choices: ["値1", "index 1の値2"], answerIndex: 1, hint: "int引数のオーバーロードです。", afterExplanation: "正解です。値2が消えます。")),
            Step(index: 2, narration: "残ったリストは `[1, 3]` なので、そのまま出力されます。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let silverCollections011Explanation = Explanation(
        id: "explain-silver-collections-011",
        initialCode: """
List<String> list = Arrays.asList("A", "B");
list.set(1, "C");
try {
    list.add("D");
} catch (UnsupportedOperationException e) {
    System.out.println(list);
}
""",
        steps: [
            Step(index: 0, narration: "`Arrays.asList(\"A\", \"B\")` は固定サイズのListを返します。要素数は変えられませんが、既存要素の置換はできます。", highlightLines: [1], variables: [Variable(name: "list", type: "List<String>", value: "[A, B]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`list.set(1, \"C\")` はindex 1のBをCへ置換します。ここまでは成功し、リストは `[A, C]` です。", highlightLines: [2], variables: [Variable(name: "list", type: "List<String>", value: "[A, C]", scope: "main")], callStack: [CallStackFrame(method: "set", line: 2)], heap: [], predict: PredictPrompt(question: "setは成功する？", choices: ["成功する", "失敗する"], answerIndex: 0, hint: "サイズは変えていません。", afterExplanation: "正解です。置換は可能です。")),
            Step(index: 2, narration: "`add(\"D\")` はサイズ変更なので `UnsupportedOperationException` です。catchで現在のリスト `[A, C]` を出力します。", highlightLines: [4, 5, 6], variables: [Variable(name: "list", type: "List<String>", value: "[A, C]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
        ]
    )

    static let silverControlFlow013Explanation = Explanation(
        id: "explain-silver-control-flow-013",
        initialCode: """
int i = 5;
do {
    System.out.print(i);
    i++;
} while (i < 5);
""",
        steps: [
            Step(index: 0, narration: "iは5です。do-whileは条件判定より先に本体へ入るため、まず5を出力します。", highlightLines: [1, 2, 3], variables: [Variable(name: "i", type: "int", value: "5", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`i++` でiは6になります。その後で条件 `i < 5` を判定します。", highlightLines: [4, 5], variables: [Variable(name: "i", type: "int", value: "6", scope: "main")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "もう一度ループする？", choices: ["する", "しない"], answerIndex: 1, hint: "6 < 5です。", afterExplanation: "正解です。falseなので終了です。")),
            Step(index: 2, narration: "1回だけ実行されたため、出力は `5` です。", highlightLines: [3], variables: [Variable(name: "出力", type: "String", value: "\"5\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let silverControlFlow014Explanation = Explanation(
        id: "explain-silver-control-flow-014",
        initialCode: """
outer:
for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 2; j++) {
        if (i + j == 1) {
            break outer;
        }
        System.out.print(i + ":" + j + " ");
    }
}
""",
        steps: [
            Step(index: 0, narration: "最初はi=0、j=0です。`i + j == 1` はfalseなので、`0:0 ` を出力します。", highlightLines: [2, 3, 4, 7], variables: [Variable(name: "i", type: "int", value: "0", scope: "outer"), Variable(name: "j", type: "int", value: "0", scope: "inner")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
            Step(index: 1, narration: "次にi=0、j=1です。`i + j == 1` がtrueになり、`break outer` が実行されます。", highlightLines: [4, 5], variables: [Variable(name: "i + j", type: "int", value: "1", scope: "inner")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "抜ける範囲は？", choices: ["内側だけ", "outerの外まで"], answerIndex: 1, hint: "break outerです。", afterExplanation: "正解です。外側ループも終了します。")),
            Step(index: 2, narration: "その後の出力は行われないため、最終出力は `0:0 ` だけです。", highlightLines: [5, 7], variables: [Variable(name: "出力", type: "String", value: "\"0:0 \"", scope: "main")], callStack: [], heap: [], predict: nil),
        ]
    )

    static let silverClasses011Explanation = Explanation(
        id: "explain-silver-classes-011",
        initialCode: """
class A {
    static { System.out.print("S"); }
    { System.out.print("I"); }
    A() { System.out.print("C"); }
}
new A();
new A();
""",
        steps: [
            Step(index: 0, narration: "最初の `new A()` の前にAクラスが初期化され、staticブロックが一度だけ実行されてSを出力します。", highlightLines: [2, 6], variables: [], callStack: [CallStackFrame(method: "A static init", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "1つ目のインスタンス生成では、インスタンス初期化ブロックI、その後コンストラクタCの順に出力します。ここまで `SIC` です。", highlightLines: [3, 4, 6], variables: [Variable(name: "出力途中", type: "String", value: "\"SIC\"", scope: "main")], callStack: [CallStackFrame(method: "A()", line: 4)], heap: [HeapObject(id: "a1", type: "A", fields: [:])], predict: PredictPrompt(question: "2回目のnewでSは出る？", choices: ["出る", "出ない"], answerIndex: 1, hint: "static初期化は一度だけです。", afterExplanation: "正解です。2回目はIとCだけです。")),
            Step(index: 2, narration: "2つ目の生成ではI、Cだけが出ます。全体の出力は `SICIC` です。", highlightLines: [7], variables: [Variable(name: "出力", type: "String", value: "\"SICIC\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [HeapObject(id: "a1", type: "A", fields: [:]), HeapObject(id: "a2", type: "A", fields: [:])], predict: nil),
        ]
    )

    static let silverClasses012Explanation = Explanation(
        id: "explain-silver-classes-012",
        initialCode: """
class A {
    A(int x) {
    }
}
new A();
""",
        steps: [
            Step(index: 0, narration: "クラスAには `A(int x)` という引数ありコンストラクタが明示されています。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "コンストラクタを1つでも宣言すると、引数なしのデフォルトコンストラクタは自動生成されません。", highlightLines: [1, 2], variables: [], callStack: [CallStackFrame(method: "compile", line: 5)], heap: [], predict: PredictPrompt(question: "A()は存在する？", choices: ["存在する", "存在しない"], answerIndex: 1, hint: "明示コンストラクタがあります。", afterExplanation: "正解です。A(int)だけです。")),
            Step(index: 2, narration: "`new A();` は引数なしコンストラクタを探しますが存在しないため、コンパイルエラーです。", highlightLines: [5], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let silverInheritance010Explanation = Explanation(
        id: "explain-silver-inheritance-010",
        initialCode: """
class Parent {
    Parent() { System.out.print("P"); }
}
class Child extends Parent {
    Child() { System.out.print("C"); }
}
new Child();
""",
        steps: [
            Step(index: 0, narration: "`new Child()` でChildコンストラクタに入ります。明示していなくても先頭に `super();` があるものとして扱われます。", highlightLines: [4, 5, 7], variables: [], callStack: [CallStackFrame(method: "Child()", line: 5)], heap: [], predict: nil),
            Step(index: 1, narration: "暗黙のsuper()によりParentコンストラクタが先に実行され、Pを出力します。", highlightLines: [2], variables: [Variable(name: "出力途中", type: "String", value: "\"P\"", scope: "Parent()")], callStack: [CallStackFrame(method: "Parent()", line: 2)], heap: [], predict: PredictPrompt(question: "先に出るのは？", choices: ["P", "C"], answerIndex: 0, hint: "親の初期化が先です。", afterExplanation: "正解です。Pが先です。")),
            Step(index: 2, narration: "その後Childコンストラクタ本体でCを出力します。最終出力は `PC` です。", highlightLines: [5], variables: [Variable(name: "出力", type: "String", value: "\"PC\"", scope: "main")], callStack: [CallStackFrame(method: "Child()", line: 5)], heap: [HeapObject(id: "child", type: "Child", fields: [:])], predict: nil),
        ]
    )

    static let silverInheritance011Explanation = Explanation(
        id: "explain-silver-inheritance-011",
        initialCode: """
interface Named {
    default String name() { return "N"; }
}
class User implements Named {
}
System.out.println(new User().name());
""",
        steps: [
            Step(index: 0, narration: "Namedインターフェースの `name()` はdefaultメソッドなので、本体を持っています。", highlightLines: [1, 2], variables: [], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "UserはNamedをimplementsしていますが、name()をオーバーライドしていません。この場合、Namedのdefault実装を継承します。", highlightLines: [4, 5], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [HeapObject(id: "user", type: "User", fields: [:])], predict: PredictPrompt(question: "Userはname()を呼べる？", choices: ["呼べる", "呼べない"], answerIndex: 0, hint: "default実装があります。", afterExplanation: "正解です。Namedのdefaultメソッドが使われます。")),
            Step(index: 2, narration: "`new User().name()` は `N` を返すため、出力は `N` です。", highlightLines: [2, 6], variables: [Variable(name: "new User().name()", type: "String", value: "\"N\"", scope: "main")], callStack: [CallStackFrame(method: "Named.name", line: 2)], heap: [], predict: nil),
        ]
    )

    static let silverException011Explanation = Explanation(
        id: "explain-silver-exception-011",
        initialCode: """
static int value() {
    try {
        return 1;
    } finally {
        return 2;
    }
}
System.out.println(value());
""",
        steps: [
            Step(index: 0, narration: "`value()` が呼ばれ、tryブロックで `return 1` が実行されます。ただしメソッドを抜ける前にfinallyが必ず実行されます。", highlightLines: [2, 3, 8], variables: [Variable(name: "戻り値候補", type: "int", value: "1", scope: "value")], callStack: [CallStackFrame(method: "value", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "finally内にも `return 2` があります。これがtry側の戻り値候補1を上書きします。", highlightLines: [4, 5], variables: [Variable(name: "戻り値", type: "int", value: "2", scope: "value")], callStack: [CallStackFrame(method: "value", line: 5)], heap: [], predict: PredictPrompt(question: "最終戻り値は？", choices: ["1", "2"], answerIndex: 1, hint: "finallyのreturnが後です。", afterExplanation: "正解です。2が返ります。")),
            Step(index: 2, narration: "printlnはvalue()の戻り値2を出力します。", highlightLines: [8], variables: [Variable(name: "value()", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    static let silverException012Explanation = Explanation(
        id: "explain-silver-exception-012",
        initialCode: """
try {
    throw new RuntimeException();
} catch (Exception e) {
    System.out.println("E");
} catch (RuntimeException e) {
    System.out.println("R");
}
""",
        steps: [
            Step(index: 0, narration: "RuntimeExceptionはExceptionのサブクラスです。catchは上から順番に検査されます。", highlightLines: [2, 3, 5], variables: [], callStack: [CallStackFrame(method: "compile", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "先に `catch (Exception e)` があるため、RuntimeExceptionもここで捕捉されます。後続の `catch (RuntimeException e)` に到達する可能性がありません。", highlightLines: [3, 5], variables: [], callStack: [CallStackFrame(method: "compile", line: 5)], heap: [], predict: PredictPrompt(question: "正しい順番は？", choices: ["Exceptionが先", "RuntimeExceptionが先"], answerIndex: 1, hint: "具体的な型から先です。", afterExplanation: "正解です。サブクラスを先に書きます。")),
            Step(index: 2, narration: "そのため `catch (RuntimeException e)` が到達不能catchとしてコンパイルエラーになります。", highlightLines: [5], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let silverLambda007Explanation = Explanation(
        id: "explain-silver-lambda-007",
        initialCode: """
StringBuilder sb = new StringBuilder("A");
Consumer<String> c = s -> sb.append(s);
c.accept("B");
System.out.println(sb);
""",
        steps: [
            Step(index: 0, narration: "`sb` 変数はStringBuilderオブジェクトを参照し、その後再代入されていません。したがってラムダから捕捉できる実質的finalです。", highlightLines: [1, 2], variables: [Variable(name: "sb", type: "StringBuilder", value: "\"A\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [HeapObject(id: "sb", type: "StringBuilder", fields: ["value": "\"A\""])], predict: nil),
            Step(index: 1, narration: "`c.accept(\"B\")` でラムダが実行されます。禁止されるのはsb変数への再代入であり、参照先のStringBuilderへappendすることは可能です。", highlightLines: [2, 3], variables: [Variable(name: "s", type: "String", value: "\"B\"", scope: "lambda"), Variable(name: "sb", type: "StringBuilder", value: "\"AB\"", scope: "main")], callStack: [CallStackFrame(method: "Consumer.accept", line: 2)], heap: [], predict: PredictPrompt(question: "appendは実質的final違反？", choices: ["違反", "違反ではない"], answerIndex: 1, hint: "変数の再代入ではありません。", afterExplanation: "正解です。参照先の変更はできます。")),
            Step(index: 2, narration: "StringBuilderの内容は `AB` になっているため、出力は `AB` です。", highlightLines: [4], variables: [Variable(name: "出力", type: "String", value: "\"AB\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let silverLambda008Explanation = Explanation(
        id: "explain-silver-lambda-008",
        initialCode: """
Function<String, Integer> f = String::length;
System.out.println(f.apply("abc"));
""",
        steps: [
            Step(index: 0, narration: "`String::length` は未束縛インスタンスメソッド参照です。Functionの引数Stringが、length()を呼ぶ対象になります。", highlightLines: [1], variables: [Variable(name: "f", type: "Function<String,Integer>", value: "s -> s.length()", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`f.apply(\"abc\")` は `\"abc\".length()` と同じです。文字数は3です。", highlightLines: [2], variables: [Variable(name: "f.apply(\"abc\")", type: "Integer", value: "3", scope: "main")], callStack: [CallStackFrame(method: "Function.apply", line: 2)], heap: [], predict: PredictPrompt(question: "戻り値は？", choices: ["abc", "3"], answerIndex: 1, hint: "length()の結果です。", afterExplanation: "正解です。Integerの3です。")),
            Step(index: 2, narration: "printlnは `3` を出力します。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )


    static let silverJavaBasics009Explanation = Explanation(
        id: "explain-silver-java-basics-009",
        initialCode: """
public static void main(String[] args) {
    System.out.println(args.length);
}
// 実行: java Test a b
""",
        steps: [
            Step(index: 0, narration: "実行引数はa,bの2つなので、args配列の長さは2です。", highlightLines: [1, 4], variables: [Variable(name: "args", type: "String[]", value: "[\"a\", \"b\"]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`args.length` は2を返し、その値がprintlnされます。", highlightLines: [2], variables: [Variable(name: "args.length", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let silverDataTypes018Explanation = Explanation(
        id: "explain-silver-data-types-018",
        initialCode: """
double d = 9.8;
int i = (int) d;
System.out.println(i);
""",
        steps: [
            Step(index: 0, narration: "dは9.8です。", highlightLines: [1], variables: [Variable(name: "d", type: "double", value: "9.8", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`(int)d` は小数部を切り捨てて9になります。", highlightLines: [2], variables: [Variable(name: "i", type: "int", value: "9", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 2, narration: "出力は9です。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let silverDataTypes019Explanation = Explanation(
        id: "explain-silver-data-types-019",
        initialCode: """
Integer n = null;
System.out.println(n + 1);
""",
        steps: [
            Step(index: 0, narration: "nはInteger参照でnullです。", highlightLines: [1], variables: [Variable(name: "n", type: "Integer", value: "null", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`n + 1` ではnをintへアンボクシングしようとしますが、nullのためNullPointerExceptionになります。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let silverString009Explanation = Explanation(
        id: "explain-silver-string-009",
        initialCode: """
String a = new String("java");
String b = "java";
System.out.println(a == b);
System.out.println(a.equals(b));
""",
        steps: [
            Step(index: 0, narration: "aはnewで作られた別オブジェクト、bは文字列リテラル参照です。", highlightLines: [1, 2], variables: [], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`a == b` は参照比較なのでfalseです。", highlightLines: [3], variables: [Variable(name: "a == b", type: "boolean", value: "false", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 2, narration: "`a.equals(b)` は内容比較なのでtrueです。", highlightLines: [4], variables: [Variable(name: "a.equals(b)", type: "boolean", value: "true", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let silverStringBuilder008Explanation = Explanation(
        id: "explain-silver-stringbuilder-008",
        initialCode: """
StringBuilder sb = new StringBuilder("ab");
sb.reverse().append("c");
System.out.println(sb);
""",
        steps: [
            Step(index: 0, narration: "初期値はabです。", highlightLines: [1], variables: [Variable(name: "sb", type: "StringBuilder", value: "\"ab\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "reverseでba、そのままappendでbacになります。", highlightLines: [2], variables: [Variable(name: "sb", type: "StringBuilder", value: "\"bac\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 2, narration: "最終出力はbacです。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let silverArray014Explanation = Explanation(
        id: "explain-silver-array-014",
        initialCode: """
int[][] a = {{1, 2}, {3, 4, 5}};
System.out.println(a.length + ":" + a[1].length);
""",
        steps: [
            Step(index: 0, narration: "aは2行のジャグ配列です。", highlightLines: [1], variables: [Variable(name: "a.length", type: "int", value: "2", scope: "main"), Variable(name: "a[1].length", type: "int", value: "3", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "式の評価結果は`2:3`です。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let silverCollections012Explanation = Explanation(
        id: "explain-silver-collections-012",
        initialCode: """
Set<String> set = new HashSet<>();
set.add("A");
set.add("A");
System.out.println(set.size());
""",
        steps: [
            Step(index: 0, narration: "HashSetは重複を許しません。", highlightLines: [1, 2, 3], variables: [Variable(name: "set", type: "Set<String>", value: "[A]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "同じAを2回addしても要素数は1です。", highlightLines: [4], variables: [Variable(name: "set.size()", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let silverCollections013Explanation = Explanation(
        id: "explain-silver-collections-013",
        initialCode: """
Map<String, Integer> map = new HashMap<>();
map.put("x", 1);
map.put("x", 2);
System.out.println(map.get("x"));
""",
        steps: [
            Step(index: 0, narration: "同じキーxに対する2回目のputで値が上書きされます。", highlightLines: [2, 3], variables: [Variable(name: "map[x]", type: "Integer", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`map.get(\"x\")` は2を返し、2が出力されます。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let silverControlFlow015Explanation = Explanation(
        id: "explain-silver-control-flow-015",
        initialCode: """
int n = 1;
switch (n) {
    case 1:
        System.out.print("A");
    case 2:
        System.out.print("B");
        break;
    default:
        System.out.print("C");
}
""",
        steps: [
            Step(index: 0, narration: "n=1なのでcase1から開始します。", highlightLines: [1, 2, 3], variables: [Variable(name: "n", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "case1にbreakがないためcase2へfall-throughし、A,Bを出力してbreakします。", highlightLines: [4, 5, 6, 7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let silverClasses013Explanation = Explanation(
        id: "explain-silver-classes-013",
        initialCode: """
class A { int x; }
A a = new A();
System.out.println(a.x);
""",
        steps: [
            Step(index: 0, narration: "intフィールドxはデフォルト値0で初期化されます。", highlightLines: [1, 2], variables: [Variable(name: "a.x", type: "int", value: "0", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "出力は0です。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let silverInheritance012Explanation = Explanation(
        id: "explain-silver-inheritance-012",
        initialCode: """
Parent p = new Child();
System.out.println(p.name());
""",
        steps: [
            Step(index: 0, narration: "参照型はParentでも、実体はChildです。", highlightLines: [1], variables: [Variable(name: "p", type: "Parent", value: "Child instance", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "インスタンスメソッドは実行時型で動的バインディングされるためChild.name()が呼ばれ、Cが出力されます。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "Child.name", line: 2)], heap: [], predict: nil),
        ]
    )

    static let silverException013Explanation = Explanation(
        id: "explain-silver-exception-013",
        initialCode: """
try {
    System.out.print("T");
    throw new RuntimeException();
} catch (RuntimeException e) {
    System.out.print("C");
} finally {
    System.out.print("F");
}
""",
        steps: [
            Step(index: 0, narration: "tryでTを出力し、例外をthrowします。", highlightLines: [1, 2, 3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "RuntimeExceptionがcatchされてCを出力します。", highlightLines: [4, 5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
            Step(index: 2, narration: "finallyが必ず実行されFを出力し、全体はTCFです。", highlightLines: [6, 7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let silverLambda009Explanation = Explanation(
        id: "explain-silver-lambda-009",
        initialCode: """
Predicate<String> p = s -> s.isEmpty();
System.out.println(p.negate().test(""));
""",
        steps: [
            Step(index: 0, narration: "空文字に対する`p.test(\"\")`はtrueです。", highlightLines: [1], variables: [Variable(name: "p.test(\"\")", type: "boolean", value: "true", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "negateで真偽が反転するため結果はfalseです。", highlightLines: [2], variables: [Variable(name: "result", type: "boolean", value: "false", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let silverStatic006Explanation = Explanation(
        id: "explain-silver-static-006",
        initialCode: """
A a = null;
System.out.println(a.n);
""",
        steps: [
            Step(index: 0, narration: "aはnullですが、nはstaticフィールドです。", highlightLines: [1, 2], variables: [Variable(name: "a", type: "A", value: "null", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "staticアクセスは型Aに解決されるためNPEは発生せず、nの値1が出力されます。", highlightLines: [2], variables: [Variable(name: "A.n", type: "int", value: "1", scope: "class")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let silverFinal005Explanation = Explanation(
        id: "explain-silver-final-005",
        initialCode: """
final class A {}
class B extends A {}
""",
        steps: [
            Step(index: 0, narration: "Aはfinal classなので継承禁止です。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`class B extends A` が規則違反となりコンパイルエラーです。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: nil),
        ]
    )

    static let silverEnum004Explanation = Explanation(
        id: "explain-silver-enum-004",
        initialCode: """
enum Level { LOW, HIGH }
System.out.println(Level.HIGH.name() + ":" + Level.HIGH.ordinal());
""",
        steps: [
            Step(index: 0, narration: "name()は定数名HIGHを返します。", highlightLines: [2], variables: [Variable(name: "Level.HIGH.name()", type: "String", value: "\"HIGH\"", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "ordinal()は0始まりでLOW=0,HIGH=1なので出力はHIGH:1です。", highlightLines: [2], variables: [Variable(name: "Level.HIGH.ordinal()", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let silverObject003Explanation = Explanation(
        id: "explain-silver-object-003",
        initialCode: """
A a = new A();
System.out.println(a.toString() != null);
""",
        steps: [
            Step(index: 0, narration: "AはObjectを継承するためtoString()を利用できます。", highlightLines: [1, 2], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "Object.toStringの既定実装はnullでない文字列を返すため比較結果はtrueです。", highlightLines: [2], variables: [Variable(name: "result", type: "boolean", value: "true", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let silverOverload008Explanation = Explanation(
        id: "explain-silver-overload-008",
        initialCode: """
static void m(int x) { System.out.print("I"); }
static void m(Integer... x) { System.out.print("V"); }
m(1);
""",
        steps: [
            Step(index: 0, narration: "m(1)はint固定引数に完全一致します。", highlightLines: [1, 3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "固定引数メソッドがvarargsより優先されるためm(int)が選ばれ、Iを出力します。", highlightLines: [1, 2], variables: [], callStack: [CallStackFrame(method: "m(int)", line: 1)], heap: [], predict: nil),
        ]
    )

    static let silverOperators003Explanation = Explanation(
        id: "explain-silver-operators-003",
        initialCode: """
int x = 0;
boolean r = (x > 0) && (++x > 0);
System.out.println(r + ":" + x);
""",
        steps: [
            Step(index: 0, narration: "左辺`x > 0`はfalseです。", highlightLines: [1, 2], variables: [Variable(name: "x", type: "int", value: "0", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "&&は短絡評価なので右辺`++x > 0`は評価されず、xは0のままです。", highlightLines: [2], variables: [Variable(name: "r", type: "boolean", value: "false", scope: "main"), Variable(name: "x", type: "int", value: "0", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 2, narration: "出力はfalse:0です。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let silverJavaBasics010Explanation = Explanation(
        id: "explain-silver-java-basics-010",
        initialCode: """
for (int i = 0; i < 3; i++) {
    if (i == 1) continue;
    System.out.print(i);
}
""",
        steps: [
            Step(index: 0, narration: "i=0ではifがfalseなので0を出力します。", highlightLines: [1, 2, 3], variables: [Variable(name: "i", type: "int", value: "0", scope: "loop")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "i=1ではcontinueによりprintをスキップします。", highlightLines: [2], variables: [Variable(name: "i", type: "int", value: "1", scope: "loop")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 2, narration: "i=2では2を出力し、最終出力は02です。", highlightLines: [3], variables: [Variable(name: "i", type: "int", value: "2", scope: "loop")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldObject003Explanation = Explanation(
        id: "explain-gold-object-003",
        initialCode: """
class Key {
    private final int id;
    Key(int id) { this.id = id; }
    public boolean equals(Object obj) {
        return obj instanceof Key other && other.id == id;
    }
    public int hashCode() { return id; }
}
Set<Key> set = new HashSet<>();
set.add(new Key(1));
set.add(new Key(1));
System.out.println(set.size());
""",
        steps: [
            Step(index: 0, narration: "Keyは `equals(Object)` と `hashCode()` をidベースでオーバーライドしています。HashSetはこの2つを使って同値性を判定します。", highlightLines: [4, 7, 9], variables: [], callStack: [], heap: [], predict: nil),
            Step(index: 1, narration: "1つ目の `new Key(1)` はSetに追加されます。hashCodeは1です。", highlightLines: [10], variables: [Variable(name: "set.size()", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "HashSet.add", line: 10)], heap: [HeapObject(id: "key1", type: "Key", fields: ["id": "1"])], predict: nil),
            Step(index: 2, narration: "2つ目の `new Key(1)` も別インスタンスですが、hashCodeが同じでequalsもtrueになるため、重複として追加されません。", highlightLines: [5, 7, 11, 12], variables: [Variable(name: "set.size()", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 12)], heap: [HeapObject(id: "key1", type: "Key", fields: ["id": "1"]), HeapObject(id: "key2", type: "Key", fields: ["id": "1"])], predict: PredictPrompt(question: "最終サイズは？", choices: ["1", "2"], answerIndex: 0, hint: "equals/hashCodeがidベースです。", afterExplanation: "正解です。同値な要素なのでSet内では1件です。")),
        ]
    )

    static let goldObject004Explanation = Explanation(
        id: "explain-gold-object-004",
        initialCode: """
class Key {
    private final int id;
    Key(int id) { this.id = id; }
    public boolean equals(Key other) {
        return other != null && other.id == id;
    }
}
Object a = new Key(1);
Object b = new Key(1);
System.out.println(a.equals(b));
""",
        steps: [
            Step(index: 0, narration: "Keyには `equals(Key)` がありますが、Objectクラスの `equals(Object)` とシグネチャが違います。これはオーバーライドではなくオーバーロードです。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "compile", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "`a` と `b` の宣言型はどちらもObjectです。`a.equals(b)` の呼び出しで選ばれるシグネチャはObjectにある `equals(Object)` です。", highlightLines: [8, 9, 10], variables: [Variable(name: "a", type: "Object", value: "Key(1)", scope: "main"), Variable(name: "b", type: "Object", value: "Key(1)", scope: "main")], callStack: [CallStackFrame(method: "main", line: 10)], heap: [HeapObject(id: "keyA", type: "Key", fields: ["id": "1"]), HeapObject(id: "keyB", type: "Key", fields: ["id": "1"])], predict: PredictPrompt(question: "Key.equals(Key)は呼ばれる？", choices: ["呼ばれる", "呼ばれない"], answerIndex: 1, hint: "選ばれた引数型はObjectです。", afterExplanation: "正解です。equals(Object)をオーバーライドしていないため呼ばれません。")),
            Step(index: 2, narration: "Keyは `equals(Object)` をオーバーライドしていないので、Objectの参照比較が使われます。aとbは別インスタンスのため出力は `false` です。", highlightLines: [10], variables: [Variable(name: "a.equals(b)", type: "boolean", value: "false", scope: "main")], callStack: [CallStackFrame(method: "Object.equals", line: 10)], heap: [], predict: nil),
        ]
    )

    static let goldAnnotations003Explanation = Explanation(
        id: "explain-gold-annotations-003",
        initialCode: """
@FunctionalInterface
interface Task {
    void run();
    default void log() {}
    static Task of(Task task) { return task; }
}
Task task = Task.of(() -> System.out.print("R"));
task.run();
""",
        steps: [
            Step(index: 0, narration: "`Task` の抽象メソッドは `run()` だけです。`default` と `static` は実装を持つため、関数型インターフェースの抽象メソッド数には入りません。", highlightLines: [1, 2, 3, 4, 5], variables: [], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "ラムダは `run()` の実装として扱われ、`Task.of` はそのTaskをそのまま返します。", highlightLines: [7], variables: [Variable(name: "task", type: "Task", value: "lambda", scope: "main")], callStack: [CallStackFrame(method: "of", line: 5)], heap: [], predict: PredictPrompt(question: "@FunctionalInterfaceは有効？", choices: ["有効", "コンパイルエラー"], answerIndex: 0, hint: "数えるのは抽象メソッドだけです。", afterExplanation: "正解です。run()だけなので有効です。")),
            Step(index: 2, narration: "`task.run()` でラムダ本体が実行され、`R` が出力されます。", highlightLines: [8], variables: [], callStack: [CallStackFrame(method: "run", line: 8)], heap: [], predict: nil),
        ]
    )

    static let goldAnnotations004Explanation = Explanation(
        id: "explain-gold-annotations-004",
        initialCode: """
@FunctionalInterface
interface Parser {
    String parse(String text);
    int size();
}
""",
        steps: [
            Step(index: 0, narration: "`parse` と `size` はどちらも本体を持たない抽象メソッドです。", highlightLines: [3, 4], variables: [], callStack: [CallStackFrame(method: "compile", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`@FunctionalInterface` は抽象メソッドが1つであることをコンパイラに検査させます。2つあるためParser宣言でコンパイルエラーです。", highlightLines: [1, 2], variables: [], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: PredictPrompt(question: "size()はdefault扱いになる？", choices: ["なる", "ならない"], answerIndex: 1, hint: "`default` キーワードがありません。", afterExplanation: "正解です。size()も抽象メソッドです。")),
            Step(index: 2, narration: "実行時まで進まず、関数型インターフェースではないというコンパイルエラーで止まります。", highlightLines: [2, 4], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldAnnotations005Explanation = Explanation(
        id: "explain-gold-annotations-005",
        initialCode: """
class Api {
    @Deprecated
    static String oldName() { return "old"; }
}
System.out.println(Api.oldName());
""",
        steps: [
            Step(index: 0, narration: "`@Deprecated` は非推奨であることを表す組み込みアノテーションです。通常は使用箇所に警告を出しますが、呼び出しは禁止しません。", highlightLines: [2, 3], variables: [], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`Api.oldName()` は通常通り呼び出され、戻り値は `old` です。", highlightLines: [3, 5], variables: [Variable(name: "Api.oldName()", type: "String", value: "\"old\"", scope: "main")], callStack: [CallStackFrame(method: "oldName", line: 3)], heap: [], predict: PredictPrompt(question: "実行結果を変える？", choices: ["変える", "変えない"], answerIndex: 1, hint: "メタデータです。", afterExplanation: "正解です。出力はoldです。")),
            Step(index: 2, narration: "最終出力は `old` です。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let goldAnnotations006Explanation = Explanation(
        id: "explain-gold-annotations-006",
        initialCode: """
@interface Info { String value(); }
@Info("service")
class Service {}
System.out.println(Service.class.isAnnotationPresent(Info.class));
""",
        steps: [
            Step(index: 0, narration: "`Info` には `@Retention` が付いていません。省略時の保持方針は `CLASS` です。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`CLASS` 保持のアノテーションはclassファイルには残りますが、実行時反射の対象にはなりません。", highlightLines: [2, 4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "isAnnotationPresentは？", choices: ["true", "false"], answerIndex: 1, hint: "RUNTIME保持ではありません。", afterExplanation: "正解です。反射では見えないためfalseです。")),
            Step(index: 2, narration: "したがって出力は `false` です。", highlightLines: [4], variables: [Variable(name: "result", type: "boolean", value: "false", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let goldAnnotations007Explanation = Explanation(
        id: "explain-gold-annotations-007",
        initialCode: """
@Retention(RetentionPolicy.RUNTIME)
@interface Info {
    String value();
    int version() default 1;
}
@Info(value = "service", version = 2)
class Service {}
Info info = Service.class.getAnnotation(Info.class);
System.out.println(info.value() + ":" + info.version());
""",
        steps: [
            Step(index: 0, narration: "`@Retention(RUNTIME)` により、Infoは実行時にも反射で取得できます。`version` にはdefaultがありますが、今回は2を明示しています。", highlightLines: [1, 3, 4, 6], variables: [], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`Service.class.getAnnotation(Info.class)` はInfoインスタンスを返します。valueはservice、versionは2です。", highlightLines: [8, 9], variables: [Variable(name: "info.value()", type: "String", value: "\"service\"", scope: "main"), Variable(name: "info.version()", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 9)], heap: [], predict: PredictPrompt(question: "versionは？", choices: ["1", "2"], answerIndex: 1, hint: "明示指定がdefaultより優先です。", afterExplanation: "正解です。version=2です。")),
            Step(index: 2, narration: "最終出力は `service:2` です。", highlightLines: [9], variables: [], callStack: [CallStackFrame(method: "main", line: 9)], heap: [], predict: nil),
        ]
    )

    static let goldAnnotations008Explanation = Explanation(
        id: "explain-gold-annotations-008",
        initialCode: """
@Target(ElementType.METHOD)
@interface Run {}
@Run
class Job {}
""",
        steps: [
            Step(index: 0, narration: "`@Target(ElementType.METHOD)` はRunをメソッド専用のアノテーションにします。", highlightLines: [1, 2], variables: [], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`@Run` を付けている対象は `class Job`、つまり型宣言です。METHOD対象ではないためコンパイルエラーです。", highlightLines: [3, 4], variables: [], callStack: [CallStackFrame(method: "compile", line: 3)], heap: [], predict: PredictPrompt(question: "エラーになる付与先は？", choices: ["Run宣言", "Jobクラス"], answerIndex: 1, hint: "Run自体は宣言できます。", afterExplanation: "正解です。Jobクラスへの付与がTarget違反です。")),
            Step(index: 2, narration: "Target違反は実行時ではなくコンパイル時に検出されます。", highlightLines: [3], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldAnnotations009Explanation = Explanation(
        id: "explain-gold-annotations-009",
        initialCode: """
@Target(ElementType.ANNOTATION_TYPE)
@interface Role {}
@Role
@interface Secured {}
@Role
class Service {}
""",
        steps: [
            Step(index: 0, narration: "`ElementType.ANNOTATION_TYPE` は、アノテーション型宣言にだけ付けられるという意味です。", highlightLines: [1, 2], variables: [], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`@Role` を `@interface Secured` に付けるのは有効です。これはアノテーションをアノテーションで修飾するメタアノテーションの形です。", highlightLines: [3, 4], variables: [], callStack: [CallStackFrame(method: "compile", line: 4)], heap: [], predict: nil),
            Step(index: 2, narration: "一方、`class Service` は通常クラスです。RoleのTarget外なのでここでコンパイルエラーになります。", highlightLines: [5, 6], variables: [], callStack: [CallStackFrame(method: "compile", line: 5)], heap: [], predict: PredictPrompt(question: "Roleを通常クラスに付けられる？", choices: ["付けられる", "付けられない"], answerIndex: 1, hint: "ANNOTATION_TYPEだけです。", afterExplanation: "正解です。Serviceへの付与がエラーです。")),
        ]
    )

    static let goldAnnotations010Explanation = Explanation(
        id: "explain-gold-annotations-010",
        initialCode: """
@Inherited
@Retention(RetentionPolicy.RUNTIME)
@interface Mark {}
@Mark
class Parent {}
class Child extends Parent {}
System.out.println(Child.class.isAnnotationPresent(Mark.class));
""",
        steps: [
            Step(index: 0, narration: "`Mark` は `@Inherited` かつ `RUNTIME` 保持です。親クラスに付けたクラスアノテーションが、サブクラスの反射取得でも見える条件がそろっています。", highlightLines: [1, 2, 4], variables: [], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`Child` 自体には `@Mark` を書いていませんが、Parentを継承しているため `isAnnotationPresent` はtrueになります。", highlightLines: [5, 6, 7], variables: [Variable(name: "result", type: "boolean", value: "true", scope: "main")], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: PredictPrompt(question: "Childから見える？", choices: ["見える", "見えない"], answerIndex: 0, hint: "@Inherited + class annotationです。", afterExplanation: "正解です。trueです。")),
            Step(index: 2, narration: "出力は `true` です。", highlightLines: [7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let goldAnnotations011Explanation = Explanation(
        id: "explain-gold-annotations-011",
        initialCode: """
@Repeatable(Tags.class)
@Retention(RetentionPolicy.RUNTIME)
@interface Tag { String value(); }
@Retention(RetentionPolicy.RUNTIME)
@interface Tags { Tag[] value(); }
@Tag("A")
@Tag("B")
class Service {}
System.out.println(Service.class.getAnnotationsByType(Tag.class).length);
""",
        steps: [
            Step(index: 0, narration: "`Tag` は `@Repeatable(Tags.class)` を持ち、コンテナアノテーション `Tags` は `Tag[] value()` を持っています。", highlightLines: [1, 3, 5], variables: [], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`Service` には `@Tag(\"A\")` と `@Tag(\"B\")` が2回付いています。どちらもRUNTIME保持なので反射で読めます。", highlightLines: [6, 7, 8], variables: [], callStack: [CallStackFrame(method: "main", line: 9)], heap: [], predict: PredictPrompt(question: "Tagは何件取得される？", choices: ["1", "2"], answerIndex: 1, hint: "getAnnotationsByTypeは繰り返しを展開します。", afterExplanation: "正解です。2件です。")),
            Step(index: 2, narration: "`getAnnotationsByType(Tag.class).length` は2なので、出力は `2` です。", highlightLines: [9], variables: [Variable(name: "length", type: "int", value: "2", scope: "main")], callStack: [CallStackFrame(method: "main", line: 9)], heap: [], predict: nil),
        ]
    )

    static let goldAnnotations012Explanation = Explanation(
        id: "explain-gold-annotations-012",
        initialCode: """
@interface Label {
    String name();
}
@Label("service")
class Service {}
""",
        steps: [
            Step(index: 0, narration: "`Label` の必須要素名は `name` です。`default` がないため、使用時に値を指定する必要があります。", highlightLines: [1, 2], variables: [], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`@Label(\"service\")` の省略記法が使えるのは、要素名が `value` の場合だけです。今回は `name` なので省略できません。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "compile", line: 4)], heap: [], predict: PredictPrompt(question: "正しい指定は？", choices: ["@Label(name = \"service\")", "@Label(value = \"service\")"], answerIndex: 0, hint: "要素名はnameです。", afterExplanation: "正解です。name = ... と書く必要があります。")),
            Step(index: 2, narration: "したがって `@Label(\"service\")` の行でコンパイルエラーです。", highlightLines: [4], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldException007Explanation = Explanation(
        id: "explain-gold-exception-007",
        initialCode: """
try {
    throw new FileNotFoundException();
} catch (IOException | FileNotFoundException e) {
    System.out.println("caught");
}
""",
        steps: [
            Step(index: 0, narration: "`FileNotFoundException` は `IOException` のサブクラスです。", highlightLines: [2, 3], variables: [], callStack: [CallStackFrame(method: "compile", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "multi-catchの代替型同士に親子関係があると、片方がもう片方を含んでしまうためコンパイルエラーです。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "compile", line: 3)], heap: [], predict: PredictPrompt(question: "親子型をmulti-catchに並べられる？", choices: ["並べられる", "並べられない"], answerIndex: 1, hint: "冗長なcatchになります。", afterExplanation: "正解です。IOException | FileNotFoundException は不可です。")),
            Step(index: 2, narration: "実行時の捕捉まで進まず、catch句の型指定でコンパイルが止まります。", highlightLines: [3], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldException008Explanation = Explanation(
        id: "explain-gold-exception-008",
        initialCode: """
try (R r = new R()) {
    throw new RuntimeException("body");
} catch (RuntimeException e) {
    System.out.println(e.getMessage() + ":" + e.getSuppressed()[0].getMessage());
}
// R.close() throws new RuntimeException("close")
""",
        steps: [
            Step(index: 0, narration: "try本体で `RuntimeException(\"body\")` が発生します。この例外が主例外になります。", highlightLines: [1, 2], variables: [Variable(name: "primary", type: "RuntimeException", value: "\"body\"", scope: "try")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "try-with-resourcesを抜けるために `close()` が呼ばれ、そこで `RuntimeException(\"close\")` が発生します。主例外が既にあるので、これはsuppressedに追加されます。", highlightLines: [1, 6], variables: [Variable(name: "suppressed[0]", type: "RuntimeException", value: "\"close\"", scope: "catch")], callStack: [CallStackFrame(method: "close", line: 6)], heap: [], predict: PredictPrompt(question: "catchで受け取る主例外は？", choices: ["body", "close"], answerIndex: 0, hint: "try本体の例外が先です。", afterExplanation: "正解です。closeは抑制例外です。")),
            Step(index: 2, narration: "出力は主例外のメッセージbodyと、抑制例外closeを連結した `body:close` です。", highlightLines: [4], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let goldException009Explanation = Explanation(
        id: "explain-gold-exception-009",
        initialCode: """
try (R a = new R("A"); R b = new R("B")) {
    throw new RuntimeException("T");
} catch (RuntimeException e) {
    System.out.println(e.getMessage() + ":" +
        e.getSuppressed()[0].getMessage() +
        e.getSuppressed()[1].getMessage());
}
""",
        steps: [
            Step(index: 0, narration: "try本体で `T` 例外が発生します。これが主例外です。", highlightLines: [1, 2], variables: [Variable(name: "primary", type: "RuntimeException", value: "\"T\"", scope: "try")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "リソースは宣言と逆順、つまりb→aでcloseされます。close例外はその順でsuppressedに追加されます。", highlightLines: [1, 5, 6], variables: [Variable(name: "suppressed[0]", type: "RuntimeException", value: "\"B\"", scope: "catch"), Variable(name: "suppressed[1]", type: "RuntimeException", value: "\"A\"", scope: "catch")], callStack: [CallStackFrame(method: "close", line: 1)], heap: [], predict: PredictPrompt(question: "suppressedの順は？", choices: ["A then B", "B then A"], answerIndex: 1, hint: "closeはLIFOです。", afterExplanation: "正解です。B、Aの順です。")),
            Step(index: 2, narration: "出力は `T:BA` です。", highlightLines: [4, 5, 6], variables: [], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let goldException010Explanation = Explanation(
        id: "explain-gold-exception-010",
        initialCode: """
static void run() {
    try {
        throw new RuntimeException("try");
    } finally {
        throw new RuntimeException("finally");
    }
}
try { run(); } catch (RuntimeException e) { System.out.println(e.getMessage()); }
""",
        steps: [
            Step(index: 0, narration: "`try` ブロックで `try` 例外が発生します。この時点では呼び出し元へ戻る準備に入ります。", highlightLines: [2, 3], variables: [Variable(name: "pending", type: "RuntimeException", value: "\"try\"", scope: "run")], callStack: [CallStackFrame(method: "run", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "戻る前にfinallyが実行され、今度は `finally` 例外を投げます。finallyが突然完了したため、try側の例外は上書きされます。", highlightLines: [4, 5], variables: [Variable(name: "outgoing", type: "RuntimeException", value: "\"finally\"", scope: "run")], callStack: [CallStackFrame(method: "run", line: 5)], heap: [], predict: PredictPrompt(question: "catchで見えるメッセージは？", choices: ["try", "finally"], answerIndex: 1, hint: "finallyのthrowが優先されます。", afterExplanation: "正解です。finallyです。")),
            Step(index: 2, narration: "catchが受け取る例外のメッセージはfinallyなので、出力は `finally` です。", highlightLines: [8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    static let goldException011Explanation = Explanation(
        id: "explain-gold-exception-011",
        initialCode: """
static void read() throws IOException { throw new IOException(); }
static void run() throws IOException {
    try { read(); }
    catch (Exception e) { throw e; }
}
try { run(); } catch (IOException e) { System.out.println("IO"); }
""",
        steps: [
            Step(index: 0, narration: "`read()` が投げ得る検査例外はIOExceptionです。run内ではcatch型をExceptionにしています。", highlightLines: [1, 3, 4], variables: [], callStack: [CallStackFrame(method: "compile", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "catchパラメータeは再代入されていません。Java 7以降のprecise rethrowにより、`throw e` は実際に投げ得るIOExceptionとして解析されます。", highlightLines: [4], variables: [Variable(name: "e", type: "Exception", value: "IOException", scope: "catch")], callStack: [CallStackFrame(method: "run", line: 4)], heap: [], predict: PredictPrompt(question: "runのthrowsはIOExceptionで足りる？", choices: ["足りる", "Exceptionが必要"], answerIndex: 0, hint: "precise rethrowです。", afterExplanation: "正解です。再代入していないため狭く解析されます。")),
            Step(index: 2, narration: "main側の `catch(IOException)` が捕捉し、`IO` を出力します。", highlightLines: [6], variables: [], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
        ]
    )

    static let goldException012Explanation = Explanation(
        id: "explain-gold-exception-012",
        initialCode: """
static void run() throws IOException {
    try { read(); }
    catch (Exception e) {
        e = new Exception();
        throw e;
    }
}
""",
        steps: [
            Step(index: 0, narration: "catchパラメータ `e` は単一catchなので再代入自体は可能です。", highlightLines: [3, 4], variables: [Variable(name: "e", type: "Exception", value: "new Exception()", scope: "catch")], callStack: [CallStackFrame(method: "compile", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "ただし再代入したためprecise rethrowの絞り込みが効きません。`throw e` はExceptionを投げる可能性として扱われます。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "compile", line: 5)], heap: [], predict: PredictPrompt(question: "throws IOExceptionだけで足りる？", choices: ["足りる", "足りない"], answerIndex: 1, hint: "eはExceptionとして再代入済みです。", afterExplanation: "正解です。throws Exceptionが必要になります。")),
            Step(index: 2, narration: "runは `throws IOException` しか宣言していないため、`throw e;` でコンパイルエラーです。", highlightLines: [1, 5], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldException013Explanation = Explanation(
        id: "explain-gold-exception-013",
        initialCode: """
R r = new R();
try (r) {
    System.out.print("T");
}
// close prints C
""",
        steps: [
            Step(index: 0, narration: "Java 9以降、try-with-resourcesにはeffectively finalな既存変数を書けます。`r` は再代入されていないため条件を満たします。", highlightLines: [1, 2], variables: [Variable(name: "r", type: "R", value: "resource", scope: "main")], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "try本体で `T` が出力されます。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: PredictPrompt(question: "try終了後にcloseされる？", choices: ["される", "されない"], answerIndex: 0, hint: "try-with-resourcesに指定しています。", afterExplanation: "正解です。既存変数でもclose対象です。")),
            Step(index: 2, narration: "ブロック終了時に `r.close()` が呼ばれ、`C` が出力されます。全体は `TC` です。", highlightLines: [4, 5], variables: [], callStack: [CallStackFrame(method: "close", line: 5)], heap: [], predict: nil),
        ]
    )

    static let goldException014Explanation = Explanation(
        id: "explain-gold-exception-014",
        initialCode: """
class Bad {
    static int value = init();
    static int init() { throw new RuntimeException("boom"); }
}
try {
    System.out.println(Bad.value);
} catch (Throwable e) {
    System.out.println(e.getClass().getSimpleName());
}
""",
        steps: [
            Step(index: 0, narration: "`Bad.value` へ初めてアクセスすると、Badクラスの初期化が始まります。`value = init()` が評価されます。", highlightLines: [2, 6], variables: [], callStack: [CallStackFrame(method: "class init", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`init()` がRuntimeExceptionを投げます。クラス初期化中の例外は `ExceptionInInitializerError` にラップされます。", highlightLines: [3], variables: [Variable(name: "cause", type: "RuntimeException", value: "\"boom\"", scope: "Bad.init")], callStack: [CallStackFrame(method: "init", line: 3)], heap: [], predict: PredictPrompt(question: "catchで見える型名は？", choices: ["RuntimeException", "ExceptionInInitializerError"], answerIndex: 1, hint: "クラス初期化中です。", afterExplanation: "正解です。ExceptionInInitializerErrorです。")),
            Step(index: 2, narration: "catch(Throwable)がそれを捕捉し、クラス名 `ExceptionInInitializerError` を出力します。", highlightLines: [7, 8], variables: [], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    static let goldException015Explanation = Explanation(
        id: "explain-gold-exception-015",
        initialCode: """
try {
    Integer.parseInt("12x");
} catch (NumberFormatException e) {
    System.out.println("NFE");
} catch (IllegalArgumentException e) {
    System.out.println("IAE");
}
""",
        steps: [
            Step(index: 0, narration: "`Integer.parseInt(\"12x\")` は数値に変換できない文字を含むため、NumberFormatExceptionを投げます。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "parseInt", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "catchは上から順に判定されます。最初の `catch(NumberFormatException)` が一致するため、そこで `NFE` を出力します。", highlightLines: [3, 4], variables: [Variable(name: "e", type: "NumberFormatException", value: "parse failure", scope: "catch")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "後続のIllegalArgumentException catchへ進む？", choices: ["進む", "進まない"], answerIndex: 1, hint: "最初に一致したcatchだけです。", afterExplanation: "正解です。NFEだけです。")),
            Step(index: 2, narration: "NumberFormatExceptionはIllegalArgumentExceptionのサブクラスですが、サブクラスcatchを先に置いているためこの順序は有効です。", highlightLines: [3, 5], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldException016Explanation = Explanation(
        id: "explain-gold-exception-016",
        initialCode: """
try {
    String s = null;
    System.out.print(s.length());
} catch (NullPointerException e) {
    System.out.print("NPE");
} finally {
    System.out.print("F");
}
""",
        steps: [
            Step(index: 0, narration: "`s` はnullです。`s.length()` でnull参照に対するインスタンスメソッド呼び出しになり、NullPointerExceptionが発生します。", highlightLines: [2, 3], variables: [Variable(name: "s", type: "String", value: "null", scope: "try")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "例外型が `catch(NullPointerException)` に一致し、`NPE` が出力されます。", highlightLines: [4, 5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "finallyはこの後動く？", choices: ["動く", "動かない"], answerIndex: 0, hint: "catch後にもfinallyです。", afterExplanation: "正解です。finallyは必ず実行されます。")),
            Step(index: 2, narration: "finallyで `F` が出力され、全体は `NPEF` です。", highlightLines: [6, 7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let goldException017Explanation = Explanation(
        id: "explain-gold-exception-017",
        initialCode: """
try {
    int[] values = {1};
    System.out.print(values[1]);
} catch (IndexOutOfBoundsException e) {
    System.out.println(e.getClass().getSimpleName());
}
""",
        steps: [
            Step(index: 0, narration: "`values` の有効な添字は0だけです。`values[1]` で配列範囲外アクセスになります。", highlightLines: [2, 3], variables: [Variable(name: "values.length", type: "int", value: "1", scope: "try")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "発生する具体例外は `ArrayIndexOutOfBoundsException` です。これは `IndexOutOfBoundsException` のサブクラスなのでcatchできます。", highlightLines: [4], variables: [Variable(name: "e", type: "IndexOutOfBoundsException", value: "ArrayIndexOutOfBoundsException", scope: "catch")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "getClass().getSimpleName()は？", choices: ["IndexOutOfBoundsException", "ArrayIndexOutOfBoundsException"], answerIndex: 1, hint: "実体の例外クラス名です。", afterExplanation: "正解です。ArrayIndexOutOfBoundsExceptionです。")),
            Step(index: 2, narration: "catch変数の宣言型ではなく実体クラス名を出すため、出力は `ArrayIndexOutOfBoundsException` です。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let goldException018Explanation = Explanation(
        id: "explain-gold-exception-018",
        initialCode: """
static void run() throws IOException {
    new IOException("created");
}
run();
System.out.println("OK");
""",
        steps: [
            Step(index: 0, narration: "`throws IOException` は、このメソッドがIOExceptionを投げる可能性を宣言するものです。必ず投げるという意味ではありません。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`new IOException(\"created\")` は例外オブジェクトを作るだけです。`throw` がないため例外は送出されません。", highlightLines: [2], variables: [Variable(name: "created", type: "IOException", value: "\"created\"", scope: "run")], callStack: [CallStackFrame(method: "run", line: 2)], heap: [], predict: PredictPrompt(question: "例外処理が始まる？", choices: ["始まる", "始まらない"], answerIndex: 1, hint: "throwしていません。", afterExplanation: "正解です。生成だけでは投げません。")),
            Step(index: 2, narration: "runは普通に終了し、main側で `OK` が出力されます。", highlightLines: [4, 5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let goldException019Explanation = Explanation(
        id: "explain-gold-exception-019",
        initialCode: """
static void run() {
    throw null;
}
try {
    run();
} catch (NullPointerException e) {
    System.out.println("NPE");
}
""",
        steps: [
            Step(index: 0, narration: "`throw null;` はコンパイル自体は通ります。nullはThrowable参照として扱われます。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "実行時にthrow対象がnullだと、JVMはNullPointerExceptionを発生させます。", highlightLines: [2, 5], variables: [], callStack: [CallStackFrame(method: "run", line: 2)], heap: [], predict: PredictPrompt(question: "catchされる型は？", choices: ["NullPointerException", "RuntimeException"], answerIndex: 0, hint: "throw null専用の挙動です。", afterExplanation: "正解です。NPEです。")),
            Step(index: 2, narration: "`catch(NullPointerException)` が一致し、`NPE` を出力します。", highlightLines: [6, 7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let goldException020Explanation = Explanation(
        id: "explain-gold-exception-020",
        initialCode: """
try {
    String s = null;
    s.length();
} catch (RuntimeException e) {
    System.out.println("R");
} catch (NullPointerException e) {
    System.out.println("N");
}
""",
        steps: [
            Step(index: 0, narration: "`NullPointerException` は `RuntimeException` のサブクラスです。", highlightLines: [4, 6], variables: [], callStack: [CallStackFrame(method: "compile", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "先に `catch(RuntimeException)` があるため、その後ろの `catch(NullPointerException)` に到達する例外は残りません。", highlightLines: [4, 6], variables: [], callStack: [CallStackFrame(method: "compile", line: 6)], heap: [], predict: PredictPrompt(question: "サブクラスcatchを後ろに置ける？", choices: ["置ける", "置けない"], answerIndex: 1, hint: "すでに親型で捕捉済みです。", afterExplanation: "正解です。到達不能catchです。")),
            Step(index: 2, narration: "したがって `catch(NullPointerException e)` の行でコンパイルエラーになります。", highlightLines: [6], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding001Explanation = Explanation(
        id: "explain-gold-secure-coding-001",
        initialCode: """
class R implements AutoCloseable {
    public void close() { System.out.print("C"); }
}
try (final R r = new R()) {
    System.out.print("T");
}
""",
        steps: [
            Step(index: 0, narration: "try-with-resourcesのリソース宣言では、ローカル変数に `final` を明示できます。`r` はtryブロック終了時に自動クローズされる対象です。", highlightLines: [4], variables: [Variable(name: "r", type: "R", value: "open", scope: "try")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "try本体で `System.out.print(\"T\")` が実行され、まず `T` が出力されます。", highlightLines: [5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: PredictPrompt(question: "ブロックを抜ける時に呼ばれるのは？", choices: ["r.close()", "何も呼ばれない"], answerIndex: 0, hint: "AutoCloseableです。", afterExplanation: "正解です。try-with-resourcesなのでcloseされます。")),
            Step(index: 2, narration: "ブロック終了時に `r.close()` が呼ばれ、`C` が続きます。出力は `TC` です。", highlightLines: [2, 6], variables: [Variable(name: "r", type: "R", value: "closed", scope: "try")], callStack: [CallStackFrame(method: "close", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding002Explanation = Explanation(
        id: "explain-gold-secure-coding-002",
        initialCode: """
final R r = new R();
try (r) {
    System.out.print("T");
}
// close prints C
""",
        steps: [
            Step(index: 0, narration: "Java 9以降、try-with-resourcesには既に宣言済みの `final` 変数をそのまま指定できます。", highlightLines: [1, 2], variables: [Variable(name: "r", type: "R", value: "open", scope: "main")], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "try本体で `T` が出力されます。既存変数を書いた場合でも、try-with-resourcesに指定した以上はクローズ対象です。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: PredictPrompt(question: "`try (r)` の後にcloseされる？", choices: ["される", "されない"], answerIndex: 0, hint: "宣言済み変数でもリソース指定です。", afterExplanation: "正解です。r.close()が呼ばれます。")),
            Step(index: 2, narration: "ブロック終了時に `close()` が実行され、`C` が出力されます。全体は `TC` です。", highlightLines: [4, 5], variables: [], callStack: [CallStackFrame(method: "close", line: 5)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding003Explanation = Explanation(
        id: "explain-gold-secure-coding-003",
        initialCode: """
R r = new R();
r = new R();
try (r) {
    System.out.print("T");
}
""",
        steps: [
            Step(index: 0, narration: "既存変数を `try (r)` に指定するには、その変数が `final` またはeffectively finalである必要があります。", highlightLines: [1, 3], variables: [Variable(name: "r", type: "R", value: "first resource", scope: "main")], callStack: [CallStackFrame(method: "compile", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "このコードでは2行目で `r` に再代入しています。再代入されたローカル変数はeffectively finalではありません。", highlightLines: [2], variables: [Variable(name: "r", type: "R", value: "second resource", scope: "main")], callStack: [CallStackFrame(method: "compile", line: 2)], heap: [], predict: PredictPrompt(question: "この `r` はeffectively final？", choices: ["はい", "いいえ"], answerIndex: 1, hint: "再代入があるかを見ます。", afterExplanation: "正解です。再代入があるので条件を満たしません。")),
            Step(index: 2, narration: "したがって `try (r)` の行でコンパイルエラーです。", highlightLines: [3], variables: [], callStack: [], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding004Explanation = Explanation(
        id: "explain-gold-secure-coding-004",
        initialCode: """
assert false : "bad";
System.out.println("OK");
""",
        steps: [
            Step(index: 0, narration: "assert文は、通常の起動では無効です。`-ea` などで明示的に有効化しない限り、assert条件は評価されません。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "`assert false : \"bad\";` は一見失敗しそうですが、assert無効時は丸ごとスキップされます。", highlightLines: [1], variables: [], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: PredictPrompt(question: "このassertは実行される？", choices: ["実行される", "スキップされる"], answerIndex: 1, hint: "-eaがありません。", afterExplanation: "正解です。デフォルトではassertは無効です。")),
            Step(index: 2, narration: "次の行に進んで `OK` が出力されます。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding005Explanation = Explanation(
        id: "explain-gold-secure-coding-005",
        initialCode: """
// java -ea Test
int n = -1;
try {
    assert n > 0 : "positive";
    System.out.println("OK");
} catch (AssertionError e) {
    System.out.println(e.getMessage());
}
""",
        steps: [
            Step(index: 0, narration: "`-ea` でassertが有効です。`n` は `-1` なので、条件 `n > 0` はfalseになります。", highlightLines: [1, 2, 4], variables: [Variable(name: "n", type: "int", value: "-1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
            Step(index: 1, narration: "assert条件がfalseのため、右側の詳細式 `\"positive\"` を持つ `AssertionError` が投げられます。", highlightLines: [4, 6], variables: [Variable(name: "e.message", type: "String", value: "\"positive\"", scope: "catch")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "catchされる例外型は？", choices: ["AssertionError", "RuntimeException"], answerIndex: 0, hint: "assertが投げるのはError系です。", afterExplanation: "正解です。AssertionErrorです。")),
            Step(index: 2, narration: "`catch (AssertionError e)` が捕捉し、メッセージ `positive` を出力します。`OK` の行には進みません。", highlightLines: [5, 6, 7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding006Explanation = Explanation(
        id: "explain-gold-secure-coding-006",
        initialCode: """
// java -ea -da Test
assert false;
System.out.println("OK");
""",
        steps: [
            Step(index: 0, narration: "assertの有効・無効オプションは左から処理されます。`-ea` で有効化した後、`-da` で無効化しています。", highlightLines: [1], variables: [Variable(name: "assertions", type: "boolean", value: "disabled", scope: "class")], callStack: [CallStackFrame(method: "launcher", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "最終状態が無効なので、`assert false;` は評価されません。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "この起動条件でAssertionErrorは出る？", choices: ["出る", "出ない"], answerIndex: 1, hint: "最後に -da が指定されています。", afterExplanation: "正解です。assertは無効です。")),
            Step(index: 2, narration: "次の行が実行され、`OK` が出力されます。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding007Explanation = Explanation(
        id: "explain-gold-secure-coding-007",
        initialCode: """
static int count;
public static void main(String[] args) {
    assert ++count > 0;
    System.out.println(count);
}
""",
        steps: [
            Step(index: 0, narration: "assertが無効な通常起動では、assert条件式そのものが評価されません。", highlightLines: [3], variables: [Variable(name: "count", type: "int", value: "0", scope: "class")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`++count` は副作用を持ちますが、assert無効時はこのインクリメントも起きません。", highlightLines: [3], variables: [Variable(name: "count", type: "int", value: "0", scope: "class")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: PredictPrompt(question: "assert無効時にcountは増える？", choices: ["増える", "増えない"], answerIndex: 1, hint: "条件式が評価されるかを考えます。", afterExplanation: "正解です。副作用も実行されません。")),
            Step(index: 2, narration: "そのまま `System.out.println(count)` に進むため、出力は `0` です。", highlightLines: [4], variables: [Variable(name: "count", type: "int", value: "0", scope: "class")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding008Explanation = Explanation(
        id: "explain-gold-secure-coding-008",
        initialCode: """
static int divide(int x) {
    assert x > 0;
    return 100 / x;
}
System.out.println(divide(-10));
""",
        steps: [
            Step(index: 0, narration: "assertはデバッグ用の内部不変条件チェック向けです。公開メソッドの引数検証をassertだけに任せると、無効時に検証されません。", highlightLines: [1, 2], variables: [Variable(name: "x", type: "int", value: "-10", scope: "divide")], callStack: [CallStackFrame(method: "divide", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "通常起動では `assert x > 0;` がスキップされます。`x` が負数でも例外は発生しません。", highlightLines: [2], variables: [Variable(name: "x", type: "int", value: "-10", scope: "divide")], callStack: [CallStackFrame(method: "divide", line: 2)], heap: [], predict: PredictPrompt(question: "この引数チェックは常に効く？", choices: ["効く", "効かない"], answerIndex: 1, hint: "assertは無効化できます。", afterExplanation: "正解です。外部入力の検証には通常のifと例外を使います。")),
            Step(index: 2, narration: "`100 / -10` が計算され、戻り値は `-10` です。したがって出力も `-10` です。", highlightLines: [3, 5], variables: [Variable(name: "return", type: "int", value: "-10", scope: "divide")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding009Explanation = Explanation(
        id: "explain-gold-secure-coding-009",
        initialCode: """
Path base = Path.of("/app/data");
Path target = base.resolve("../secret.txt").normalize();
System.out.println(target.startsWith(base));
""",
        steps: [
            Step(index: 0, narration: "`resolve` は基準パスに相対パスを結合します。まず `/app/data/../secret.txt` という形になります。", highlightLines: [1, 2], variables: [Variable(name: "base", type: "Path", value: "/app/data", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`normalize()` が `..` を整理し、結果は `/app/secret.txt` になります。これは `/app/data` の外側です。", highlightLines: [2], variables: [Variable(name: "target", type: "Path", value: "/app/secret.txt", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "正規化後もbase配下？", choices: ["配下", "配下ではない"], answerIndex: 1, hint: "`..` で1階層上がっています。", afterExplanation: "正解です。パストラバーサルの典型です。")),
            Step(index: 2, narration: "`target.startsWith(base)` はfalseです。FIOでは正規化後に許可ディレクトリ配下か検証する必要があります。", highlightLines: [3], variables: [Variable(name: "startsWith", type: "boolean", value: "false", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding010Explanation = Explanation(
        id: "explain-gold-secure-coding-010",
        initialCode: """
Path base = Path.of("/safe/base");
Path target = base.resolve("/etc/passwd").normalize();
System.out.println(target);
""",
        steps: [
            Step(index: 0, narration: "`Path.resolve` は右辺が相対パスならbase配下へ結合しますが、右辺が絶対パスの場合は右辺が優先されます。", highlightLines: [1, 2], variables: [Variable(name: "base", type: "Path", value: "/safe/base", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "引数 `\"/etc/passwd\"` は絶対パスなので、`/safe/base` は結果に含まれません。", highlightLines: [2], variables: [Variable(name: "target", type: "Path", value: "/etc/passwd", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "resolve結果はbase配下に固定される？", choices: ["固定される", "固定されない"], answerIndex: 1, hint: "絶対パスの右辺が優先です。", afterExplanation: "正解です。入力値の絶対パスも検証対象です。")),
            Step(index: 2, narration: "`normalize()` してもパスは `/etc/passwd` のままなので、その文字列が出力されます。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding011Explanation = Explanation(
        id: "explain-gold-secure-coding-011",
        initialCode: """
class Account implements Serializable {
    String name = "alice";
    transient String password = "secret";
}
// serialize and deserialize new Account()
System.out.println(a.name + ":" + a.password);
""",
        steps: [
            Step(index: 0, narration: "`Account` は `Serializable` を実装しているため、通常フィールドはシリアライズ対象になります。", highlightLines: [1, 2], variables: [Variable(name: "name", type: "String", value: "\"alice\"", scope: "Account")], callStack: [CallStackFrame(method: "writeObject", line: 5)], heap: [], predict: nil),
            Step(index: 1, narration: "`password` は `transient` なので、オブジェクトストリームには保存されません。機密値をそのまま永続化しないための基本です。", highlightLines: [3], variables: [Variable(name: "password", type: "String", value: "not serialized", scope: "Account")], callStack: [CallStackFrame(method: "writeObject", line: 5)], heap: [], predict: PredictPrompt(question: "復元後のpasswordは？", choices: ["secret", "null"], answerIndex: 1, hint: "参照型のデフォルト値です。", afterExplanation: "正解です。transientフィールドはnullに戻ります。")),
            Step(index: 2, narration: "復元後、`name` は `alice`、`password` は参照型デフォルトのnullです。出力は `alice:null` です。", highlightLines: [6], variables: [Variable(name: "a.password", type: "String", value: "null", scope: "main")], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding012Explanation = Explanation(
        id: "explain-gold-secure-coding-012",
        initialCode: """
class User implements Serializable {
    int age;
    private void readObject(ObjectInputStream in)
        throws IOException, ClassNotFoundException {
        in.defaultReadObject();
        if (age < 0) throw new InvalidObjectException("age");
    }
}
// deserialize new User(-1)
""",
        steps: [
            Step(index: 0, narration: "デシリアライズ時、クラスにprivateな `readObject` があればフックとして呼ばれます。", highlightLines: [3, 4], variables: [], callStack: [CallStackFrame(method: "readObject", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`defaultReadObject()` により、ストリーム内の `age = -1` が復元されます。コンストラクタの通常チェックだけに頼ると、この経路を見落とします。", highlightLines: [5], variables: [Variable(name: "age", type: "int", value: "-1", scope: "User")], callStack: [CallStackFrame(method: "readObject", line: 5)], heap: [], predict: PredictPrompt(question: "復元後の不変条件チェックは必要？", choices: ["必要", "不要"], answerIndex: 0, hint: "ストリームは外部入力です。", afterExplanation: "正解です。readObject内で検証します。")),
            Step(index: 2, narration: "`age < 0` がtrueなので `InvalidObjectException(\"age\")` を投げます。catch側でメッセージ `age` が出力されます。", highlightLines: [6], variables: [Variable(name: "e.message", type: "String", value: "\"age\"", scope: "catch")], callStack: [CallStackFrame(method: "readObject", line: 6)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding013Explanation = Explanation(
        id: "explain-gold-secure-coding-013",
        initialCode: """
ObjectInputStream in = new ObjectInputStream(bytes);
in.setObjectInputFilter(info ->
    info.serialClass() == Box.class
        ? ObjectInputFilter.Status.REJECTED
        : ObjectInputFilter.Status.UNDECIDED);
try {
    in.readObject();
} catch (InvalidClassException e) {
    System.out.println("rejected");
}
""",
        steps: [
            Step(index: 0, narration: "`ObjectInputFilter` はデシリアライズされるクラスや深さなどを見て、許可・拒否・未決定を返せます。", highlightLines: [2, 3, 4, 5], variables: [], callStack: [CallStackFrame(method: "readObject", line: 7)], heap: [], predict: nil),
            Step(index: 1, narration: "ストリーム内のオブジェクトは `Box` です。フィルタは `Box.class` に対して `REJECTED` を返します。", highlightLines: [3, 4], variables: [Variable(name: "serialClass", type: "Class<?>", value: "Box.class", scope: "filter")], callStack: [CallStackFrame(method: "filter", line: 3)], heap: [], predict: PredictPrompt(question: "`REJECTED` の結果は？", choices: ["読み込み拒否", "そのまま読み込み"], answerIndex: 0, hint: "名前通り拒否です。", afterExplanation: "正解です。InvalidClassExceptionにつながります。")),
            Step(index: 2, narration: "`readObject()` は `InvalidClassException` を投げ、catchで `rejected` が出力されます。", highlightLines: [7, 8, 9], variables: [], callStack: [CallStackFrame(method: "main", line: 9)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding014Explanation = Explanation(
        id: "explain-gold-secure-coding-014",
        initialCode: """
String value = AccessController.doPrivileged(
    (PrivilegedAction<String>) () -> System.getProperty("user.home"));
return sanitize(value);
""",
        steps: [
            Step(index: 0, narration: "`doPrivileged` は、渡した `PrivilegedAction` の中だけを特権境界として実行します。", highlightLines: [1, 2], variables: [], callStack: [CallStackFrame(method: "load", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "この例で特権化されるのは `System.getProperty(\"user.home\")` のラムダ本体だけです。", highlightLines: [2], variables: [Variable(name: "value", type: "String", value: "user.home", scope: "load")], callStack: [CallStackFrame(method: "doPrivileged", line: 2)], heap: [], predict: PredictPrompt(question: "sanitizeも特権内？", choices: ["特権内", "特権外"], answerIndex: 1, hint: "doPrivilegedの引数の中だけです。", afterExplanation: "正解です。sanitizeは戻った後に実行されます。")),
            Step(index: 2, narration: "`sanitize(value)` は特権ブロックの外です。セキュアコーディングでは、特権範囲を必要最小限にします。", highlightLines: [3], variables: [], callStack: [CallStackFrame(method: "load", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding015Explanation = Explanation(
        id: "explain-gold-secure-coding-015",
        initialCode: """
static void check() {
    throw new SecurityException("deny");
}
try {
    check();
} catch (RuntimeException e) {
    System.out.println(e.getClass().getSimpleName());
}
""",
        steps: [
            Step(index: 0, narration: "`SecurityException` はプラットフォームセキュリティ関連で現れることがある非検査例外です。`RuntimeException` のサブクラスです。", highlightLines: [2, 6], variables: [], callStack: [CallStackFrame(method: "check", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "`check()` が `SecurityException` を投げると、`catch (RuntimeException e)` で捕捉できます。", highlightLines: [5, 6], variables: [Variable(name: "e", type: "RuntimeException", value: "SecurityException", scope: "catch")], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: PredictPrompt(question: "catch変数eの実体型は？", choices: ["RuntimeException", "SecurityException"], answerIndex: 1, hint: "宣言型と実体型を分けます。", afterExplanation: "正解です。実体はSecurityExceptionです。")),
            Step(index: 2, narration: "`getClass().getSimpleName()` は実体クラス名を返すため、出力は `SecurityException` です。", highlightLines: [7], variables: [], callStack: [CallStackFrame(method: "main", line: 7)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding016Explanation = Explanation(
        id: "explain-gold-secure-coding-016",
        initialCode: """
List<String> base = new ArrayList<>();
base.add("A");
List<String> view = Collections.unmodifiableList(base);
List<String> copy = List.copyOf(base);
base.add("B");
System.out.println(view.size() + ":" + copy.size());
""",
        steps: [
            Step(index: 0, narration: "`Collections.unmodifiableList(base)` は変更不可ビューを作ります。ビューなので、元の `base` を見続けます。", highlightLines: [1, 2, 3], variables: [Variable(name: "base", type: "List<String>", value: "[A]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
            Step(index: 1, narration: "`List.copyOf(base)` はその時点の要素から独立した変更不可リストを作ります。", highlightLines: [4], variables: [Variable(name: "copy", type: "List<String>", value: "[A]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 4)], heap: [], predict: PredictPrompt(question: "`base.add(\"B\")` はcopyに反映される？", choices: ["反映される", "反映されない"], answerIndex: 1, hint: "copyOfはコピーです。", afterExplanation: "正解です。copyは[A]のままです。")),
            Step(index: 2, narration: "`base.add(\"B\")` 後、viewは元リストの変化を見てサイズ2、copyはサイズ1です。出力は `2:1` です。", highlightLines: [5, 6], variables: [Variable(name: "view.size()", type: "int", value: "2", scope: "main"), Variable(name: "copy.size()", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 6)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding017Explanation = Explanation(
        id: "explain-gold-secure-coding-017",
        initialCode: """
List<String> list = Collections.checkedList(new ArrayList<>(), String.class);
List raw = list;
try {
    raw.add(10);
} catch (ClassCastException e) {
    System.out.println("CCE");
}
System.out.println(list.size());
""",
        steps: [
            Step(index: 0, narration: "`checkedList` は、コレクションへ要素を追加するときに実行時型チェックを行うラッパーです。", highlightLines: [1], variables: [Variable(name: "list", type: "List<String>", value: "checked empty list", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "raw型へ代入しても、実体はcheckedListのラッパーです。`raw.add(10)` はIntegerを追加しようとして検査に失敗します。", highlightLines: [2, 4], variables: [Variable(name: "element", type: "Integer", value: "10", scope: "main")], callStack: [CallStackFrame(method: "add", line: 4)], heap: [], predict: PredictPrompt(question: "追加は成功する？", choices: ["成功する", "ClassCastException"], answerIndex: 1, hint: "ラッパーが実行時に検査します。", afterExplanation: "正解です。String以外なので拒否されます。")),
            Step(index: 2, narration: "`CCE` が出力され、要素は追加されません。続くサイズ出力は `0` です。", highlightLines: [5, 6, 8], variables: [Variable(name: "list.size()", type: "int", value: "0", scope: "main")], callStack: [CallStackFrame(method: "main", line: 8)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding018Explanation = Explanation(
        id: "explain-gold-secure-coding-018",
        initialCode: """
List<String>[] array = new List[1];
Object[] objects = array;
objects[0] = List.of(10);
try {
    String s = array[0].get(0);
} catch (ClassCastException e) {
    System.out.println("CCE");
}
""",
        steps: [
            Step(index: 0, narration: "`new List[1]` から `List<String>[]` への代入はunchecked警告ですが、通常はコンパイルできます。実行時の配列要素型は生の `List` です。", highlightLines: [1], variables: [Variable(name: "array", type: "List<String>[]", value: "List[]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "配列は共変なので `Object[]` として扱えます。`List.of(10)` は実行時には `List` なので代入自体は通ります。", highlightLines: [2, 3], variables: [Variable(name: "array[0]", type: "List", value: "[10]", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: PredictPrompt(question: "3行目でArrayStoreExceptionになる？", choices: ["なる", "ならない"], answerIndex: 1, hint: "実行時の配列要素型はListです。", afterExplanation: "正解です。代入は通って後で壊れます。")),
            Step(index: 2, narration: "`array[0].get(0)` の結果はIntegerですが、代入先がStringなので暗黙キャストが入り、`ClassCastException` になります。出力は `CCE` です。", highlightLines: [5, 6, 7], variables: [Variable(name: "value", type: "Integer", value: "10", scope: "main")], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding019Explanation = Explanation(
        id: "explain-gold-secure-coding-019",
        initialCode: """
List<?> values = new ArrayList<String>();
values.add(null);
System.out.println(values.size());
""",
        steps: [
            Step(index: 0, narration: "`List<?>` は要素型が不明なリストです。具体的な非null値は安全に追加できません。", highlightLines: [1], variables: [Variable(name: "values", type: "List<?>", value: "empty ArrayList<String>", scope: "main")], callStack: [CallStackFrame(method: "compile", line: 1)], heap: [], predict: nil),
            Step(index: 1, narration: "ただし `null` はすべての参照型に代入可能なので、`values.add(null)` はコンパイルできます。", highlightLines: [2], variables: [Variable(name: "added", type: "null", value: "null", scope: "main")], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: PredictPrompt(question: "`List<?>` に追加できる値は？", choices: ["任意のObject", "nullだけ"], answerIndex: 1, hint: "実際の要素型が不明です。", afterExplanation: "正解です。nullだけは例外的に追加できます。")),
            Step(index: 2, narration: "ArrayListはnull要素を許容するため、サイズは1になります。出力は `1` です。", highlightLines: [3], variables: [Variable(name: "values.size()", type: "int", value: "1", scope: "main")], callStack: [CallStackFrame(method: "main", line: 3)], heap: [], predict: nil),
        ]
    )

    static let goldSecureCoding020Explanation = Explanation(
        id: "explain-gold-secure-coding-020",
        initialCode: """
try {
    List<String> list = List.of("A", null);
    System.out.println(list.size());
} catch (NullPointerException e) {
    System.out.println("NPE");
}
""",
        steps: [
            Step(index: 0, narration: "`List.of` で作る変更不可リストは、null要素を許容しません。", highlightLines: [2], variables: [], callStack: [CallStackFrame(method: "main", line: 2)], heap: [], predict: nil),
            Step(index: 1, narration: "2つ目の要素がnullなので、リスト生成時点で `NullPointerException` が発生します。`list.size()` には進みません。", highlightLines: [2, 3], variables: [], callStack: [CallStackFrame(method: "List.of", line: 2)], heap: [], predict: PredictPrompt(question: "例外が出るタイミングは？", choices: ["生成時", "add時"], answerIndex: 0, hint: "addは呼んでいません。", afterExplanation: "正解です。List.ofの引数検査です。")),
            Step(index: 2, narration: "`catch (NullPointerException e)` が捕捉し、`NPE` を出力します。", highlightLines: [4, 5], variables: [], callStack: [CallStackFrame(method: "main", line: 5)], heap: [], predict: nil),
        ]
    )
}
