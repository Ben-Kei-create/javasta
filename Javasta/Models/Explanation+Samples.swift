import Foundation

extension Explanation {
    static func sample(for ref: String) -> Explanation? {
        switch ref {
        case "explain-silver-overload-001":   return silverOverload001
        case "explain-silver-exception-001":  return silverException001
        case "explain-silver-string-001":     return silverString001
        case "explain-silver-autoboxing-001": return silverAutoboxing001
        case "explain-silver-switch-001":     return silverSwitch001
        case "explain-gold-generics-001":     return goldGenerics001
        case "explain-gold-stream-001":       return goldStream001
        case "explain-gold-optional-001":     return goldOptional001
        default:
            if let quiz = Quiz.samples.first(where: { $0.explanationRef == ref }) {
                return quickTrace(for: quiz, ref: ref)
            }
            return nil
        }
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
}
