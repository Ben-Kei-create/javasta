import Foundation

enum SilverMockFurtherQuestionData {
    struct ChoiceSpec {
        let id: String
        let text: String
        let correct: Bool
        let misconception: String?
        let explanation: String
    }

    struct VariableSpec {
        let name: String
        let type: String
        let value: String
        let scope: String
    }

    struct StepSpec {
        let narration: String
        let highlightLines: [Int]
        let variables: [VariableSpec]
    }

    struct Spec {
        let id: String
        let difficulty: QuizDifficulty
        let estimatedSeconds: Int
        let validatedByJavac: Bool
        let category: String
        let tags: [String]
        let code: String
        let question: String
        let choices: [ChoiceSpec]
        let explanationRef: String
        let designIntent: String
        let steps: [StepSpec]
    }

    static let specs: [Spec] = [
        q(
            "silver-mock-further-integer-cache-001",
            category: "data-types",
            tags: ["模試専用", "wrapper", "Integer cache", "=="],
            code: """
public class Test {
    public static void main(String[] args) {
        Integer a = 100;
        Integer b = 100;
        Integer c = 200;
        Integer d = 200; // outside cache range example
        System.out.println((a == b) + ":" + (c == d));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true:true", misconception: "Integerの==が常に値比較だと誤解", explanation: "`==` は参照比較です。キャッシュ範囲外では別オブジェクトになり得ます。"),
                choice("b", "true:false", correct: true, explanation: "通常 -128〜127 のIntegerはキャッシュされ、100は同一参照。200は別参照です。"),
                choice("c", "false:false", misconception: "オートボクシングは常にnewすると誤解", explanation: "小さいInteger値はキャッシュされます。"),
                choice("d", "コンパイルエラー", misconception: "Integer同士を==で比較できないと誤解", explanation: "参照型同士なので==比較できます。"),
            ],
            intent: "Integerキャッシュと参照比較のひっかけを確認する。",
            steps: [
                step("`Integer a = 100; b = 100;` はオートボクシングされます。100はIntegerキャッシュ範囲内なので同じ参照になるのが通常です。", [3, 4], [variable("a == b", "boolean", "true", "main")]),
                step("`200` は標準のキャッシュ範囲外なので、cとdは別々のIntegerオブジェクトになります。", [5, 6], [variable("c == d", "boolean", "false", "main")]),
                step("`==` は値ではなく参照を比較するため、出力は `true:false` です。", [7], [variable("output", "String", "true:false", "stdout")]),
            ]
        ),
        q(
            "silver-mock-further-stringbuilder-substring-001",
            category: "string",
            tags: ["模試専用", "StringBuilder", "substring", "mutable"],
            code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("abcd");
        String s = sb.substring(1, 3);
        System.out.println(sb + ":" + s);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "abcd:bc", correct: true, explanation: "`substring` はStringを返すだけで、StringBuilder本体は変更しません。"),
                choice("b", "bc:bc", misconception: "substringがStringBuilderを切り詰めると誤解", explanation: "StringBuilderを変更するのはdeleteなどです。"),
                choice("c", "abcd:bcd", misconception: "終了インデックスを含むと誤解", explanation: "第2引数3は含まれないため、1と2の文字だけです。"),
                choice("d", "コンパイルエラー", misconception: "StringBuilderにsubstringがないと誤解", explanation: "StringBuilderにもsubstringメソッドがあります。"),
            ],
            intent: "StringBuilder.substringが本体を変更しないことを確認する。",
            steps: [
                step("sbは最初 `abcd` です。", [3], [variable("sb", "StringBuilder", "abcd", "main")]),
                step("`substring(1, 3)` はインデックス1以上3未満の `bc` をStringとして返します。sb自体は変更されません。", [4], [variable("s", "String", "bc", "main"), variable("sb", "StringBuilder", "abcd", "main")]),
                step("そのため出力は `abcd:bc` です。", [5], [variable("output", "String", "abcd:bc", "stdout")]),
            ]
        ),
        q(
            "silver-mock-further-switch-expression-missing-default-001",
            difficulty: .exam,
            validatedByJavac: false,
            category: "control-flow",
            tags: ["模試専用", "switch expression", "compile", "exhaustive"],
            code: """
public class Test {
    public static void main(String[] args) {
        int n = 2;
        int result = switch (n) {
            case 1 -> 10;
        };
        System.out.println(result);
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "10と出力される", misconception: "case 1がなければ0になると誤解", explanation: "nは2であり、さらにswitch式として網羅性が必要です。"),
                choice("b", "0と出力される", misconception: "switch式がデフォルト値0を返すと誤解", explanation: "値を返す式なので、全経路で値が必要です。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "intのswitch式でdefaultなどがなく、すべての可能性を網羅していません。"),
                choice("d", "実行時にIllegalStateExceptionになる", misconception: "網羅性を実行時に判定すると誤解", explanation: "この不足はコンパイル時に検出されます。"),
            ],
            intent: "switch式には値を返すための網羅性が必要であることを確認する。",
            steps: [
                step("`switch (n)` は式として `int result` に値を返す必要があります。", [4], [variable("switch kind", "String", "expression", "compiler")]),
                step("caseは1だけで、nがそれ以外の場合に返す値がありません。intの可能性はcase 1だけでは網羅できません。", [4, 5], [variable("exhaustive", "boolean", "false", "compiler")]),
                step("defaultなどがないため、コンパイルエラーになります。", [4, 6], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-mock-further-overload-null-object-string-001",
            category: "overload-resolution",
            tags: ["模試専用", "overload", "null", "most specific"],
            code: """
public class Test {
    static void call(Object o) { System.out.println("Object"); }
    static void call(String s) { System.out.println("String"); }
    public static void main(String[] args) {
        call(null); // String overload is more specific
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "Object", misconception: "Objectがすべての参照型の親なので優先と誤解", explanation: "オーバーロードではより具体的な型が優先されます。"),
                choice("b", "String", correct: true, explanation: "nullはObjectにもStringにも渡せますが、Stringの方がObjectより具体的です。"),
                choice("c", "コンパイルエラー", misconception: "null呼び出しは常に曖昧と誤解", explanation: "候補間に継承関係があるため、より具体的なStringを選べます。"),
                choice("d", "NullPointerException", misconception: "nullを渡すと呼び出し前に例外になると誤解", explanation: "メソッド本体ではnullを参照していないため例外になりません。"),
            ],
            intent: "null実引数のオーバーロードで最も具体的な型が選ばれることを確認する。",
            steps: [
                step("`call(null)` のnullはObject型にもString型にも代入可能です。", [2, 3, 5], [variable("applicable methods", "String", "Object, String", "compiler")]),
                step("候補のうちStringはObjectのサブクラスなので、Stringの方がより具体的です。", [2, 3], [variable("selected method", "String", "call(String)", "compiler")]),
                step("`call(String)` が実行され、出力は `String` です。", [3], [variable("output", "String", "String", "stdout")]),
            ]
        ),
        q(
            "silver-mock-further-lambda-overload-ambiguous-001",
            difficulty: .exam,
            validatedByJavac: false,
            category: "lambda-streams",
            tags: ["模試専用", "lambda", "overload", "ambiguous"],
            code: """
interface A { void run(); }
interface B { void run(); }

public class Test {
    static void call(A a) { }
    static void call(B b) { }
    public static void main(String[] args) {
        call(() -> {});
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "A版が呼ばれる", misconception: "先に宣言されたメソッドが優先されると誤解", explanation: "宣言順では決まりません。"),
                choice("b", "B版が呼ばれる", misconception: "後に宣言されたメソッドが優先されると誤解", explanation: "宣言順では決まりません。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "ラムダ `() -> {}` はAにもBにも適合し、どちらがより具体的か決められないため曖昧です。"),
                choice("d", "実行時にClassCastExceptionになる", misconception: "ラムダの型決定を実行時問題と誤解", explanation: "ラムダのターゲット型はコンパイル時に決定されます。"),
            ],
            intent: "同じ形の関数型インターフェース間でラムダのオーバーロードが曖昧になることを確認する。",
            steps: [
                step("AもBも引数なし・戻り値voidの抽象メソッドを1つ持つ関数型インターフェースです。", [1, 2], [variable("lambda shape", "functional descriptor", "() -> void", "compiler")]),
                step("`call(() -> {})` はA版にもB版にも適用できます。AとBに継承関係はなく、より具体的な候補を選べません。", [5, 6, 8], [variable("ambiguous", "boolean", "true", "compiler")]),
                step("したがってコンパイルエラーになります。", [8], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-mock-further-default-method-conflict-001",
            difficulty: .exam,
            validatedByJavac: false,
            category: "inheritance",
            tags: ["模試専用", "interface", "default method", "conflict"],
            code: """
interface Left {
    default void run() { System.out.println("L"); }
}
interface Right {
    default void run() { System.out.println("R"); }
}
class Both implements Left, Right {
}
public class Test {
    public static void main(String[] args) {
        new Both().run();
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "Lと出力される", misconception: "先にimplementsしたLeftが優先されると誤解", explanation: "競合するdefaultメソッドはクラス側で解決が必要です。"),
                choice("b", "Rと出力される", misconception: "後にimplementsしたRightが優先されると誤解", explanation: "implementsの順序では解決されません。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "LeftとRightが同じシグネチャのdefaultメソッドを持つため、Bothはrunを明示的にオーバーライドする必要があります。"),
                choice("d", "実行時にAbstractMethodErrorになる", misconception: "競合解決を実行時まで遅らせると誤解", explanation: "競合はコンパイル時に検出されます。"),
            ],
            intent: "複数interfaceのdefaultメソッド競合を確認する。",
            steps: [
                step("LeftとRightはどちらも `default void run()` を提供しています。", [1, 2, 4, 5], [variable("Left.run", "default", "L", "interface"), variable("Right.run", "default", "R", "interface")]),
                step("Bothは両方をimplementsしていますが、runを自分でオーバーライドしていません。どちらを継承するか決められません。", [7, 8], [variable("conflict resolved", "boolean", "false", "compiler")]),
                step("そのためクラス宣言でコンパイルエラーになります。", [7], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-mock-further-static-instance-override-001",
            difficulty: .exam,
            validatedByJavac: false,
            category: "inheritance",
            tags: ["模試専用", "static", "override", "compile"],
            code: """
class Parent {
    static void run() { }
}
class Child extends Parent {
    void run() { }
}
public class Test {
    public static void main(String[] args) {
        System.out.println("ok");
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "okと出力される", misconception: "staticメソッドをインスタンスメソッドで置き換えられると誤解", explanation: "staticメソッドをインスタンスメソッドでオーバーライドすることはできません。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "Parentのstatic runと同じシグネチャをChildでインスタンスメソッドとして宣言できません。"),
                choice("c", "Child.runが優先される", misconception: "staticも動的ディスパッチされると誤解", explanation: "そもそも宣言が不正です。"),
                choice("d", "Parent.runが隠蔽される", misconception: "隠蔽には同じstaticが必要なことを見落とし", explanation: "隠蔽できるのはstaticメソッドをstaticメソッドで宣言した場合です。"),
            ],
            intent: "staticメソッドとインスタンスメソッドの同一シグネチャ衝突を確認する。",
            steps: [
                step("Parentには `static void run()` があります。", [1, 2], [variable("Parent.run", "static method", "run()", "Parent")]),
                step("Childは同じシグネチャで `void run()` をインスタンスメソッドとして宣言しています。これはstaticメソッドのオーバーライドにも隠蔽にもなりません。", [4, 5], [variable("declaration valid", "boolean", "false", "compiler")]),
                step("したがってコンパイルエラーです。", [5], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-mock-further-this-and-super-001",
            difficulty: .exam,
            validatedByJavac: false,
            category: "classes",
            tags: ["模試専用", "constructor", "this", "super"],
            code: """
class Parent {
    Parent(int value) { }
}
public class Test extends Parent {
    Test() {
        this(1);
        super(2);
    }
    Test(int value) {
        super(value);
    }
    public static void main(String[] args) {
        new Test();
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "正常にコンパイルされる", misconception: "thisとsuperを同じコンストラクタに両方書けると誤解", explanation: "どちらもコンストラクタ本体の先頭文でなければならず、両方は書けません。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "`this(1)` の後に `super(2)` は書けません。コンストラクタ呼び出しは先頭に1つだけです。"),
                choice("c", "実行時にStackOverflowErrorになる", misconception: "this呼び出しの循環と混同", explanation: "このコードは実行前にコンパイルエラーです。"),
                choice("d", "2が出力される", misconception: "Parentコンストラクタが出力すると誤解", explanation: "出力処理はありません。さらにコンパイルできません。"),
            ],
            intent: "コンストラクタ内のthis(...)とsuper(...)呼び出し規則を確認する。",
            steps: [
                step("Testの引数なしコンストラクタでは最初に `this(1)` を呼んでいます。これは同じクラスの別コンストラクタ呼び出しです。", [5, 6], [variable("first statement", "constructor invocation", "this(1)", "Test()")]),
                step("同じコンストラクタ内で続けて `super(2)` を書いていますが、super呼び出しも先頭文でなければなりません。", [7], [variable("second constructor invocation", "super(2)", "invalid", "compiler")]),
                step("コンストラクタ呼び出し文は先頭に1つだけなので、コンパイルエラーです。", [6, 7], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-mock-further-finally-return-override-001",
            category: "exception-handling",
            tags: ["模試専用", "finally", "return"],
            code: """
public class Test {
    static int value() {
        try {
            return 1;
        } finally {
            return 2; // finally return overrides earlier result
        }
    }
    public static void main(String[] args) {
        System.out.println(value());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1", misconception: "tryのreturnが確定してfinallyで変わらないと誤解", explanation: "finally内でreturnすると、try側のreturnを置き換えます。"),
                choice("b", "2", correct: true, explanation: "tryでreturn 1が準備されますが、finallyのreturn 2が最終的な戻り値になります。"),
                choice("c", "12", misconception: "両方のreturn値が出力されると誤解", explanation: "メソッドの戻り値は1つだけです。"),
                choice("d", "コンパイルエラー", misconception: "finally内でreturnできないと誤解", explanation: "推奨はされませんが、構文上は可能です。"),
            ],
            intent: "finally内のreturnがtryのreturnを上書きすることを確認する。",
            steps: [
                step("`try` ブロックで `return 1` が実行され、戻り値1が準備されます。", [3, 4], [variable("pending return", "int", "1", "value")]),
                step("メソッドを抜ける前にfinallyが実行され、そこで `return 2` が実行されます。", [5, 6], [variable("final return", "int", "2", "finally")]),
                step("finallyのreturnが優先されるため、mainでは2が出力されます。", [10], [variable("output", "String", "2", "stdout")]),
            ]
        ),
        q(
            "silver-mock-further-catch-polymorphism-001",
            category: "exception-handling",
            tags: ["模試専用", "catch", "polymorphism"],
            code: """
public class Test {
    public static void main(String[] args) {
        try {
            throw new IllegalArgumentException();
        } catch (RuntimeException e) {
            System.out.println("R");
        } catch (Exception e) {
            System.out.println("E");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "R", correct: true, explanation: "IllegalArgumentExceptionはRuntimeExceptionのサブクラスなので、最初のcatchで捕捉されます。"),
                choice("b", "E", misconception: "より広いExceptionが最終的に選ばれると誤解", explanation: "catchは上から順に最初に一致したものだけが実行されます。"),
                choice("c", "RE", misconception: "一致するcatchがすべて実行されると誤解", explanation: "catchブロックは1つだけ実行されます。"),
                choice("d", "コンパイルエラー", misconception: "RuntimeException後にExceptionを書けないと誤解", explanation: "サブクラス側を先に書いているため到達可能です。"),
            ],
            intent: "catchブロックの上から順の一致と例外継承関係を確認する。",
            steps: [
                step("投げているのは `IllegalArgumentException` です。これはRuntimeExceptionのサブクラスです。", [3, 4], [variable("thrown", "IllegalArgumentException", "is RuntimeException", "try")]),
                step("最初のcatch `RuntimeException` に一致するため、そこで捕捉されます。", [5], [variable("selected catch", "String", "RuntimeException", "catch")]),
                step("後続のException catchには進まず、出力は `R` です。", [6, 7], [variable("output", "String", "R", "stdout")]),
            ]
        ),
        q(
            "silver-mock-further-array-covariance-ok-001",
            category: "data-types",
            tags: ["模試専用", "array", "covariance"],
            code: """
public class Test {
    public static void main(String[] args) {
        Object[] values = new String[1];
        values[0] = "A";
        System.out.println(values[0]);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", correct: true, explanation: "実体はString[]で、格納する値もStringなので実行時の配列型検査に通ります。"),
                choice("b", "null", misconception: "Object[]参照から代入できないと誤解", explanation: "代入は成功して先頭要素がAになります。"),
                choice("c", "ArrayStoreException", misconception: "配列共変性では常に格納エラーになると誤解", explanation: "String[]へStringを格納するのは有効です。"),
                choice("d", "コンパイルエラー", misconception: "String[]をObject[]へ代入できないと誤解", explanation: "配列は共変なので代入できます。"),
            ],
            intent: "配列共変性が許可される場合と実行時格納検査を確認する。",
            steps: [
                step("`new String[1]` はString配列ですが、配列は共変なのでObject[]参照へ代入できます。", [3], [variable("values runtime type", "Class", "String[]", "main")]),
                step("`values[0] = \"A\"` は実体のString[]にStringを格納しているため、実行時検査に通ります。", [4], [variable("values[0]", "String", "A", "array")]),
                step("先頭要素を出力して `A` です。", [5], [variable("output", "String", "A", "stdout")]),
            ]
        ),
        q(
            "silver-mock-further-init-order-002",
            category: "classes",
            tags: ["模試専用", "initialization", "constructor"],
            code: """
class Parent {
    { System.out.print("A"); }
    Parent() { System.out.print("B"); }
}
class Child extends Parent {
    int x = print("C");
    { System.out.print("D"); }
    Child() { System.out.print("E"); }
    static int print(String s) {
        System.out.print(s);
        return 0;
    }
}
public class Test {
    public static void main(String[] args) {
        new Child();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "ABCDE", correct: true, explanation: "親のインスタンス初期化A、親コンストラクタB、子フィールド初期化C、子初期化ブロックD、子コンストラクタEの順です。"),
                choice("b", "ACDBE", misconception: "子のフィールド初期化が親コンストラクタより先だと誤解", explanation: "まずsuper()により親側の初期化とコンストラクタが完了します。"),
                choice("c", "BACDE", misconception: "親コンストラクタが親初期化ブロックより先と誤解", explanation: "インスタンス初期化ブロックはコンストラクタ本体より前です。"),
                choice("d", "ABDEC", misconception: "子の初期化ブロックがフィールド初期化より先と誤解", explanation: "子クラス内ではソース上の順にフィールド初期化C、初期化ブロックDです。"),
            ],
            intent: "継承時の親子インスタンス初期化順を模試レベルで確認する。",
            steps: [
                step("`new Child()` では、暗黙の `super()` によりまずParent側へ進みます。Parentのインスタンス初期化A、ParentコンストラクタBの順です。", [1, 2, 3, 16], [variable("parent phase", "String", "AB", "construction")]),
                step("親側が終わるとChild側のインスタンス初期化へ戻ります。フィールド `x = print(\"C\")` がC、次の初期化ブロックがDです。", [5, 6, 7], [variable("child init", "String", "CD", "construction")]),
                step("最後にChildコンストラクタ本体Eが実行され、全体は `ABCDE` です。", [8], [variable("output", "String", "ABCDE", "stdout")]),
            ]
        ),
        q(
            "silver-mock-further-labelled-break-001",
            category: "control-flow",
            tags: ["模試専用", "label", "break", "nested loop"],
            code: """
public class Test {
    public static void main(String[] args) {
        outer:
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                if (i + j == 2) break outer;
                System.out.print(i + "" + j + " ");
            }
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "00 01 ", correct: true, explanation: "i=0,j=0とj=1は出力。j=2で条件が成立し、外側ループごと終了します。"),
                choice("b", "00 01 02 ", misconception: "breakが出力後に行われると誤解", explanation: "条件判定は出力より前です。i=0,j=2は出力されません。"),
                choice("c", "00 01 10 ", misconception: "内側ループだけを抜けると誤解", explanation: "`break outer` は外側ラベルの文を終了します。"),
                choice("d", "00 01 10 11 ", misconception: "条件成立のタイミングを誤解", explanation: "最初にi+jが2になるのはi=0,j=2です。"),
            ],
            intent: "ラベル付きbreakで外側ループを抜ける動きを確認する。",
            steps: [
                step("i=0,j=0では合計0なので出力 `00 `、j=1では合計1なので `01 ` を出力します。", [4, 5, 6, 7], [variable("output so far", "String", "00 01 ", "stdout")]),
                step("次のj=2で `i + j == 2` がtrueになり、`break outer` が実行されます。", [6], [variable("break target", "String", "outer loop", "control")]),
                step("外側for全体を抜けるため、それ以降は出力されません。結果は `00 01 ` です。", [3, 6], [variable("output", "String", "00 01 ", "stdout")]),
            ]
        ),
        q(
            "silver-mock-further-remove-index-vs-value-001",
            category: "collections",
            tags: ["模試専用", "List", "remove", "overload"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<Integer> list = new ArrayList<>(List.of(10, 20, 30));
        list.remove(1);
        System.out.println(list);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "[10, 30]", correct: true, explanation: "`remove(1)` の引数はintなので、インデックス1の要素20が削除されます。"),
                choice("b", "[20, 30]", misconception: "インデックス0が削除されると誤解", explanation: "指定インデックスは1です。"),
                choice("c", "[10, 20, 30]", misconception: "値1がないので何も消えないと誤解", explanation: "これは値削除ではなくインデックス削除です。"),
                choice("d", "IndexOutOfBoundsException", misconception: "インデックス1が範囲外と誤解", explanation: "3要素のリストでインデックス1は有効です。"),
            ],
            intent: "List<Integer>でのremove(int)とremove(Object)のひっかけを確認する。",
            steps: [
                step("listは最初 `[10, 20, 30]` です。", [5], [variable("list", "List<Integer>", "[10, 20, 30]", "main")]),
                step("`list.remove(1)` はintリテラルを渡しているため、`remove(int index)` が選ばれます。", [6], [variable("selected overload", "String", "remove(int)", "compiler")]),
                step("インデックス1の20が削除され、出力は `[10, 30]` です。", [7], [variable("output", "String", "[10, 30]", "stdout")]),
            ]
        ),
        q(
            "silver-mock-further-var-null-001",
            difficulty: .exam,
            validatedByJavac: false,
            category: "java-basics",
            tags: ["模試専用", "var", "null", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        var value = null; // compiler cannot infer a concrete type
        System.out.println(value);
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "nullと出力される", misconception: "varがObjectに推論されると誤解", explanation: "nullだけでは具体的な型を推論できません。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "`var value = null;` は初期化式から型を決定できないためコンパイルエラーです。"),
                choice("c", "Object型として扱われる", misconception: "nullリテラルの型をObjectと誤解", explanation: "varは明確な初期化式の型を必要とします。"),
                choice("d", "NullPointerExceptionになる", misconception: "型推論失敗を実行時例外と混同", explanation: "実行前にコンパイルできません。"),
            ],
            intent: "varの型推論にnull単独の初期化式を使えないことを確認する。",
            steps: [
                step("`var` はローカル変数の型を初期化式から推論します。", [3], [variable("declaration", "String", "var value", "compiler")]),
                step("初期化式が `null` だけだと、StringなのかObjectなのかなど、具体的な型を決められません。", [3], [variable("inferred type", "String", "none", "compiler")]),
                step("そのため3行目でコンパイルエラーになります。", [3], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-mock-further-lambda-array-capture-001",
            category: "lambda-streams",
            tags: ["模試専用", "lambda", "effectively final", "array"],
            code: """
public class Test {
    public static void main(String[] args) {
        int[] count = {0};
        Runnable r = () -> count[0]++;
        r.run();
        System.out.println(count[0]);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", misconception: "ラムダ内の更新が外に反映されないと誤解", explanation: "同じ配列オブジェクトの要素を更新しています。"),
                choice("b", "1", correct: true, explanation: "ローカル変数count自体は再代入されていないため実質的final。配列要素の更新は可能です。"),
                choice("c", "コンパイルエラー", misconception: "配列要素の変更も実質的final違反と誤解", explanation: "禁止されるのはローカル変数countへの再代入です。"),
                choice("d", "ArrayIndexOutOfBoundsException", misconception: "count[0]が存在しないと誤解", explanation: "配列は1要素あり、インデックス0は有効です。"),
            ],
            intent: "ラムダの実質的final制約と参照先オブジェクトの変更を区別する。",
            steps: [
                step("`count` は1要素のint配列を参照するローカル変数です。この変数自体は後で再代入されません。", [3], [variable("count variable", "int[]", "effectively final reference", "main")]),
                step("ラムダ内では `count[0]++` と配列要素を更新しています。これはローカル変数countの再代入ではありません。", [4], [variable("count[0]", "int", "will increment", "lambda")]),
                step("`r.run()` で要素が0から1になり、出力は `1` です。", [5, 6], [variable("output", "String", "1", "stdout")]),
            ]
        ),
        q(
            "silver-mock-further-runnable-checked-exception-001",
            difficulty: .exam,
            validatedByJavac: false,
            category: "lambda-streams",
            tags: ["模試専用", "lambda", "checked exception", "Runnable"],
            code: """
import java.io.*;

public class Test {
    public static void main(String[] args) {
        Runnable r = () -> {
            throw new IOException();
        };
        r.run();
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "IOExceptionが実行時に投げられる", misconception: "Runnable.runが検査例外を投げられると誤解", explanation: "Runnable.runにはthrows IOExceptionがありません。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "ラムダのターゲットであるRunnable.runは検査例外IOExceptionを宣言していないため、ラムダ本体から投げられません。"),
                choice("c", "何も起きず正常終了する", misconception: "throw文が無視されると誤解", explanation: "throw文は有効な制御フローですが、検査例外の扱いが不正です。"),
                choice("d", "RuntimeExceptionに自動変換される", misconception: "検査例外が自動ラップされると誤解", explanation: "Javaは検査例外を自動でRuntimeExceptionに変換しません。"),
            ],
            intent: "ラムダ本体で投げる検査例外はターゲット型のthrowsに従うことを確認する。",
            steps: [
                step("ラムダは `Runnable` に代入されます。Runnableの抽象メソッド `run()` は検査例外をthrows宣言していません。", [5], [variable("target type", "Runnable", "run() throws none", "compiler")]),
                step("ラムダ本体では `new IOException()` を投げています。IOExceptionは検査例外です。", [6], [variable("thrown", "IOException", "checked", "lambda")]),
                step("ターゲット型のthrowsに合わないため、コンパイルエラーです。", [5, 6], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-mock-further-private-method-not-override-001",
            category: "inheritance",
            tags: ["模試専用", "private", "method", "override"],
            code: """
class Parent {
    private void run() { System.out.print("P"); }
    void call() { run(); }
}
class Child extends Parent {
    public void run() { System.out.print("C"); }
}
public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        p.call();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "P", correct: true, explanation: "Parentのprivate runはオーバーライドされません。Parent.call内のrunはParentのprivateメソッドを呼びます。"),
                choice("b", "C", misconception: "privateメソッドもオーバーライドされると誤解", explanation: "privateメソッドは継承されず、オーバーライド対象ではありません。"),
                choice("c", "PC", misconception: "両方のrunが呼ばれると誤解", explanation: "call内の呼び出しは1回だけです。"),
                choice("d", "コンパイルエラー", misconception: "Childに同名publicメソッドを書けないと誤解", explanation: "別メソッドとして宣言できます。"),
            ],
            intent: "Parent.call内のprivate `run()` がChildのpublic `run()` へ動的ディスパッチされないことを確認する。",
            steps: [
                step("Parentの `run()` はprivateなので、Childへ継承されず、オーバーライド対象にもなりません。", [1, 2, 5, 6], [variable("Parent.run", "private method", "not overridden", "Parent")]),
                step("`p.call()` はParentで定義されたcallを実行し、その中の `run()` はParent自身のprivate runへ束縛されます。", [3, 10, 11], [variable("called method", "String", "Parent.run", "call")]),
                step("したがって出力は `P` です。", [2], [variable("output", "String", "P", "stdout")]),
            ]
        ),
        q(
            "silver-mock-further-field-hiding-cast-001",
            category: "inheritance",
            tags: ["模試専用", "field hiding", "cast"],
            code: """
class Parent {
    String value = "P";
}
class Child extends Parent {
    String value = "C";
}
public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        System.out.println(p.value + ":" + ((Child) p).value);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "P:P", misconception: "キャスト後もフィールドがParent基準だと誤解", explanation: "フィールド参照はその式のコンパイル時型で決まります。"),
                choice("b", "P:C", correct: true, explanation: "`p.value` はParent型なのでP、`((Child)p).value` はChild型なのでCです。"),
                choice("c", "C:C", misconception: "フィールドが実行時型で選ばれると誤解", explanation: "フィールドはポリモーフィックではありません。"),
                choice("d", "ClassCastException", misconception: "Childへのキャストが失敗すると誤解", explanation: "実体はChildなのでキャストは成功します。"),
            ],
            intent: "フィールド隠蔽とキャスト後のコンパイル時型を確認する。",
            steps: [
                step("`Parent p = new Child();` で、pのコンパイル時型はParent、実体はChildです。", [9], [variable("p", "Parent ref", "runtime Child", "main")]),
                step("`p.value` は式の型がParentなのでParentのフィールドPを参照します。", [10], [variable("p.value", "String", "P", "main")]),
                step("`((Child) p).value` はキャスト後の式の型がChildなのでChildのフィールドCを参照します。出力は `P:C` です。", [10], [variable("output", "String", "P:C", "stdout")]),
            ]
        ),
        q(
            "silver-mock-further-string-switch-null-001",
            category: "control-flow",
            tags: ["模試専用", "switch", "String", "null"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = null;
        try {
            switch (s) {
                case "A": System.out.println("A"); break;
                default: System.out.println("D");
            }
        } catch (NullPointerException e) {
            System.out.println("NPE");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "D", misconception: "nullがdefaultに進むと誤解", explanation: "従来のString switchではnullはdefaultではなくNullPointerExceptionになります。"),
                choice("b", "NPE", correct: true, explanation: "switch式の値がnullのためNullPointerExceptionが発生し、catchでNPEを出力します。"),
                choice("c", "A", misconception: "最初のcaseに一致すると誤解", explanation: "sはnullであり文字列Aではありません。"),
                choice("d", "コンパイルエラー", misconception: "Stringをswitchに使えないと誤解", explanation: "Stringはswitch式に使えます。問題は実行時のnullです。"),
            ],
            intent: "String switchにnullを渡した場合の挙動を確認する。",
            steps: [
                step("`s` はnullです。String型ですが、参照先オブジェクトはありません。", [3], [variable("s", "String", "null", "main")]),
                step("`switch (s)` の評価時にnullが渡されるため、case/defaultの照合前にNullPointerExceptionが発生します。", [5], [variable("exception", "NullPointerException", "thrown", "switch")]),
                step("nullをswitch対象にした例外がcatchで捕捉され、`NPE` が出力されます。", [9, 10], [variable("output", "String", "NPE", "stdout")]),
            ]
        ),
        q(
            "silver-mock-further-equals-overload-001",
            category: "classes",
            tags: ["模試専用", "equals", "overload", "Object"],
            code: """
class Box {
    int value;
    Box(int value) { this.value = value; }
    public boolean equals(Box other) {
        return other != null && value == other.value;
    }
}
public class Test {
    public static void main(String[] args) {
        Object box = new Box(1);
        System.out.println(box.equals(new Box(1)));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", misconception: "equals(Box)がObject.equalsをオーバーライドしていると誤解", explanation: "Object.equalsの引数はObjectです。equals(Box)はオーバーロードです。"),
                choice("b", "false", correct: true, explanation: "変数boxの型はObjectなので、呼び出しはObject.equals(Object)。Boxはこれをオーバーライドしていないため参照比較になります。"),
                choice("c", "コンパイルエラー", misconception: "Object参照でequalsを呼べないと誤解", explanation: "Objectにはequals(Object)があります。"),
                choice("d", "ClassCastException", misconception: "equals呼び出しで自動キャストされると誤解", explanation: "Box.equals(Box)は呼ばれません。"),
            ],
            intent: "equalsのオーバーロードとオーバーライドの違いを確認する。",
            steps: [
                step("Boxには `equals(Box other)` がありますが、Objectの `equals(Object)` とは引数型が違います。これはオーバーライドではありません。", [4], [variable("equals(Box)", "method", "overload", "Box")]),
                step("`Object box` から `box.equals(new Box(1))` を呼ぶため、コンパイル時に見えるのはObject.equals(Object)です。", [10, 11], [variable("selected method", "String", "Object.equals(Object)", "compiler")]),
                step("BoxはObject.equalsをオーバーライドしていないため参照比較になり、別インスタンスなのでfalseです。", [11], [variable("output", "String", "false", "stdout")]),
            ]
        ),
        q(
            "silver-mock-further-cast-runtime-failure-001",
            category: "inheritance",
            tags: ["模試専用", "cast", "ClassCastException"],
            code: """
class Animal {}
class Dog extends Animal {}
class Cat extends Animal {}
public class Test {
    public static void main(String[] args) {
        Animal a = new Dog();
        try {
            Cat c = (Cat) a;
            System.out.println("OK");
        } catch (ClassCastException e) {
            System.out.println("CCE");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "OK", misconception: "AnimalならCatへ必ずキャストできると誤解", explanation: "実体はDogなのでCatではありません。"),
                choice("b", "CCE", correct: true, explanation: "コンパイルは可能ですが、実行時の実体DogをCatへキャストできずClassCastExceptionになります。"),
                choice("c", "コンパイルエラー", misconception: "兄弟クラスへのキャストは常にコンパイル不可と誤解", explanation: "参照型AnimalからCatへのダウンキャストはコンパイル可能です。"),
                choice("d", "null", misconception: "失敗したキャストがnullを返すと誤解", explanation: "失敗したキャストはClassCastExceptionを投げます。"),
            ],
            intent: "コンパイル可能なダウンキャストでも実体型が合わないと実行時例外になることを確認する。",
            steps: [
                step("`Animal a = new Dog();` で、aの実体はDogです。", [6], [variable("a runtime type", "Class", "Dog", "main")]),
                step("`Cat c = (Cat) a;` は構文上は可能ですが、実行時にはDogをCatとして扱えないためClassCastExceptionが発生します。", [8], [variable("cast result", "ClassCastException", "thrown", "try")]),
                step("catchで捕捉され、`CCE` が出力されます。", [10, 11], [variable("output", "String", "CCE", "stdout")]),
            ]
        ),
        q(
            "silver-mock-further-do-while-condition-001",
            category: "control-flow",
            tags: ["模試専用", "do-while", "post-increment"],
            code: """
public class Test {
    public static void main(String[] args) {
        int i = 0;
        do {
            System.out.print(i);
        } while (i++ < 1);
        System.out.println(":" + i);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0:1", misconception: "ループが1回だけと誤解", explanation: "1回目の条件評価で `0 < 1` がtrueなので2回目も実行されます。"),
                choice("b", "01:2", correct: true, explanation: "本体で0、条件でiが1へ。2回目本体で1、条件でiが2へ進んで終了します。"),
                choice("c", "012:2", misconception: "i=2の本体も実行されると誤解", explanation: "2回目の条件評価は `1 < 1` がfalseなので、i=2の本体は実行しません。"),
                choice("d", "コンパイルエラー", misconception: "do-while条件に後置インクリメントを書けないと誤解", explanation: "`i++ < 1` はboolean式なので有効です。"),
            ],
            intent: "do-whileの本体実行タイミングと後置インクリメントを確認する。",
            steps: [
                step("最初に本体が必ず実行され、i=0を出力します。その後条件 `i++ < 1` は0<1を判定してtrue、iは1になります。", [3, 4, 5, 6], [variable("after first condition", "int", "i=1", "main")]),
                step("2回目の本体でi=1を出力します。条件では1<1がfalseですが、後置インクリメントによりiは2になります。", [5, 6], [variable("after second condition", "int", "i=2", "main")]),
                step("最後に `:` とiを出力するため、全体は `01:2` です。", [7], [variable("output", "String", "01:2", "stdout")]),
            ]
        ),
        q(
            "silver-mock-further-main-varargs-final-001",
            category: "java-basics",
            tags: ["模試専用", "main", "final", "varargs"],
            code: """
public class Test {
    public static final void main(String... args) {
        System.out.println(args.length);
    }
}
""",
            question: "`java Test A B C` として起動した場合、結果として正しいものはどれか？",
            choices: [
                choice("a", "3", correct: true, explanation: "`public static final void main(String... args)` は起動用mainとして有効で、引数は3個です。"),
                choice("b", "0", misconception: "コマンドライン引数が渡らないと誤解", explanation: "A B Cがargsに入ります。"),
                choice("c", "起動用mainとして認識されない", misconception: "finalやvarargsだとmainにならないと誤解", explanation: "finalは問題なく、String...はString[]と同等です。"),
                choice("d", "コンパイルエラー", misconception: "mainにfinalを付けられないと誤解", explanation: "staticメソッドにfinalを付けることはできます。"),
            ],
            intent: "mainメソッドのfinal修飾子とvarargs形式が有効であることを確認する。",
            steps: [
                step("mainは `public static final void` で、引数は `String... args` です。finalが付いていても起動用mainとして有効です。", [2], [variable("entrypoint valid", "boolean", "true", "launcher")]),
                step("`String...` は `String[]` と同等に扱われ、コマンドライン引数A, B, Cが3要素として入ります。", [2], [variable("args", "String[]", "[A, B, C]", "main")]),
                step("`args.length` は3なので、出力は `3` です。", [3], [variable("output", "String", "3", "stdout")]),
            ]
        ),
    ]

    static func q(
        _ id: String,
        difficulty: QuizDifficulty = .exam,
        estimatedSeconds: Int = 90,
        validatedByJavac: Bool = true,
        category: String,
        tags: [String],
        code: String,
        question: String,
        choices: [ChoiceSpec],
        intent: String,
        steps: [StepSpec]
    ) -> Spec {
        Spec(
            id: id,
            difficulty: difficulty,
            estimatedSeconds: estimatedSeconds,
            validatedByJavac: validatedByJavac,
            category: category,
            tags: tags,
            code: code,
            question: question,
            choices: choices,
            explanationRef: "explain-\(id)",
            designIntent: intent,
            steps: steps
        )
    }

    static func choice(
        _ id: String,
        _ text: String,
        correct: Bool = false,
        misconception: String? = nil,
        explanation: String
    ) -> ChoiceSpec {
        ChoiceSpec(id: id, text: text, correct: correct, misconception: misconception, explanation: explanation)
    }

    static func step(
        _ narration: String,
        _ highlightLines: [Int],
        _ variables: [VariableSpec] = []
    ) -> StepSpec {
        StepSpec(narration: narration, highlightLines: highlightLines, variables: variables)
    }

    static func variable(_ name: String, _ type: String, _ value: String, _ scope: String) -> VariableSpec {
        VariableSpec(name: name, type: type, value: value, scope: scope)
    }
}

extension SilverMockFurtherQuestionData.Spec {
    var quiz: Quiz {
        Quiz(
            id: id,
            level: .silver,
            difficulty: difficulty,
            estimatedSeconds: estimatedSeconds,
            validatedByJavac: validatedByJavac,
            isMockExamOnly: true,
            category: category,
            tags: tags,
            code: code,
            question: question,
            choices: choices.map {
                Quiz.Choice(
                    id: $0.id,
                    text: $0.text,
                    correct: $0.correct,
                    misconception: $0.misconception,
                    explanation: $0.explanation
                )
            },
            explanationRef: explanationRef,
            designIntent: designIntent
        )
    }
}

extension QuizExpansion {
    static let silverMockFurtherExpansion: [Quiz] = SilverMockFurtherQuestionData.specs.map(\.quiz)
}
