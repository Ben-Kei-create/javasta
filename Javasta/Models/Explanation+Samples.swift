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
            goldOptional001.id: goldOptional001,
        ]

        return base.merging(generatedAuthoredSamples, uniquingKeysWith: { _, new in new })
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
        goldConcurrency009Explanation.id: goldConcurrency009Explanation,
        goldDateTime005Explanation.id: goldDateTime005Explanation,
        goldIo006Explanation.id: goldIo006Explanation,
        goldClasses007Explanation.id: goldClasses007Explanation,
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
}
