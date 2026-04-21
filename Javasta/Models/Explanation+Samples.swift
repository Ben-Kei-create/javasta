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
}
