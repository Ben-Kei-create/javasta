import Foundation

enum MockCenturyQuestionData {
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
        let level: JavaLevel
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

    static let silverSpecs: [Spec] = [
        q(
            "silver-mock-century-increment-assignment-001",
            level: .silver,
            category: "data-types",
            tags: ["模試専用", "increment", "evaluation order"],
            code: """
public class Test {
    public static void main(String[] args) {
        int x = 1;
        x = x++ + ++x;
        System.out.println(x);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "3", misconception: "左辺のx++後の値だけを足していると誤解", explanation: "左オペランドは1を返した後にxを2へ増やし、右の++xで3になります。"),
                choice("b", "4", correct: true, explanation: "x++は1を返してxを2にし、++xは3を返します。1 + 3が代入されて4です。"),
                choice("c", "5", misconception: "代入前のx更新も加算結果にさらに反映されると誤解", explanation: "最後は計算結果4がxへ代入されます。"),
                choice("d", "コンパイルエラー", misconception: "同じ変数を1式で複数回更新できないと誤解", explanation: "Javaではコンパイル可能で、左から右に評価されます。"),
            ],
            intent: "インクリメント式の評価順と代入の最終結果を確認する。",
            steps: [
                step("xは1で開始します。", [3], [variable("x", "int", "1", "main")]),
                step("左のx++は1を返し、その後xを2にします。右の++xはxを3にして3を返します。", [4], [variable("left", "int", "1", "expression"), variable("right", "int", "3", "expression")]),
                step("1 + 3 の結果4がxへ代入され、出力は4です。", [4, 5], [variable("x", "int", "4", "main"), variable("output", "String", "4", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-string-compound-concat-001",
            level: .silver,
            category: "strings",
            tags: ["模試専用", "String", "compound assignment", "operator"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = "A";
        s += 1 + 2;
        System.out.println(s);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A12", misconception: "1と2が先に文字列として連結されると誤解", explanation: "右辺の `1 + 2` はまず数値加算として評価されます。"),
                choice("b", "A3", correct: true, explanation: "`1 + 2` が3になり、`s += 3` で `A3` になります。"),
                choice("c", "3A", misconception: "複合代入で右辺が前に連結されると誤解", explanation: "`s += expr` は現在のsの後ろにexprを連結します。"),
                choice("d", "コンパイルエラー", misconception: "Stringに数値を+=できないと誤解", explanation: "Stringへの+=は文字列連結として扱われます。"),
            ],
            intent: "Stringの複合代入で右辺の数値演算が先に行われることを確認する。",
            steps: [
                step("sは最初 `A` です。", [3], [variable("s", "String", "A", "main")]),
                step("右辺 `1 + 2` はどちらもintなので、先に数値加算され3になります。", [4], [variable("1 + 2", "int", "3", "expression")]),
                step("`A` と3が文字列連結され、sは `A3` になります。", [4, 5], [variable("output", "String", "A3", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-char-string-order-001",
            level: .silver,
            category: "data-types",
            tags: ["模試専用", "char", "String", "operator"],
            code: """
public class Test {
    public static void main(String[] args) {
        char c = 'A';
        System.out.println("" + c + 1 + (char) (c + 1));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "66B", misconception: "先頭の空文字による文字列連結を見落としている", explanation: "最初に空文字とcを連結した時点で、以降は文字列連結になります。"),
                choice("b", "A1B", correct: true, explanation: "`\"\" + c` でAになり、1は文字列として連結、最後のcharはBとして連結されます。"),
                choice("c", "A66", misconception: "最後のcharキャストを忘れて数値のままだと誤解", explanation: "`(char)(c + 1)` はコード値66の文字Bです。"),
                choice("d", "コンパイルエラー", misconception: "charの加算結果をcharへキャストできないと誤解", explanation: "明示キャストしているためコンパイルできます。"),
            ],
            intent: "charの数値昇格とString連結の左結合を確認する。",
            steps: [
                step("cは文字Aです。`\"\" + c` により式は文字列 `A` になります。", [3, 4], [variable("prefix", "String", "A", "expression")]),
                step("すでにString式なので、続く `+ 1` は数値加算ではなく文字列連結です。", [4], [variable("partial", "String", "A1", "expression")]),
                step("`(char)(c + 1)` はBなので、最終出力は `A1B` です。", [4], [variable("output", "String", "A1B", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-switch-fallthrough-002",
            level: .silver,
            category: "control-flow",
            tags: ["模試専用", "switch", "fall-through"],
            code: """
public class Test {
    public static void main(String[] args) {
        int n = 2;
        switch (n) {
            case 1:
                System.out.print("A");
            case 2:
                System.out.print("B");
            default:
                System.out.print("D");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "B", misconception: "case 2の後で自動的にswitchを抜けると誤解", explanation: "コロン形式のswitchではbreakがないと次へフォールスルーします。"),
                choice("b", "BD", correct: true, explanation: "case 2に一致してBを出力し、breakがないためdefaultでDも出力します。"),
                choice("c", "ABD", misconception: "case 1から実行が始まると誤解", explanation: "n=2なのでcase 2から開始します。"),
                choice("d", "D", misconception: "defaultが常に優先されると誤解", explanation: "defaultは一致caseがない場合、またはフォールスルーした場合に実行されます。"),
            ],
            intent: "switchのフォールスルーと開始位置を確認する。",
            steps: [
                step("nは2なので、switchはcase 2から実行を開始します。", [3, 4, 7], [variable("n", "int", "2", "main")]),
                step("case 2でBを出力しますが、breakがありません。", [7, 8], [variable("partial output", "String", "B", "stdout")]),
                step("そのままdefaultへ進みDを出力するため、結果は `BD` です。", [9, 10], [variable("output", "String", "BD", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-enhanced-for-copy-001",
            level: .silver,
            category: "arrays",
            tags: ["模試専用", "enhanced for", "array"],
            code: """
public class Test {
    public static void main(String[] args) {
        int[] nums = { 1, 2, 3 };
        for (int n : nums) {
            n *= 2;
        }
        System.out.println(nums[1]);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2", correct: true, explanation: "拡張forの変数nは各要素値のコピーなので、nを変更しても配列要素は変わりません。"),
                choice("b", "4", misconception: "nへの代入が配列要素へ反映されると誤解", explanation: "プリミティブ配列の拡張for変数は要素そのものではなく値のコピーです。"),
                choice("c", "6", misconception: "最後の要素を出力していると誤解", explanation: "出力しているのはインデックス1、つまり2番目の要素です。"),
                choice("d", "コンパイルエラー", misconception: "拡張for変数へ代入できないと誤解", explanation: "ループ変数nへの代入は可能ですが、元配列には反映されません。"),
            ],
            intent: "拡張forでプリミティブ要素の値を書き換えられないことを確認する。",
            steps: [
                step("numsは `[1, 2, 3]` です。", [3], [variable("nums", "int[]", "[1, 2, 3]", "main")]),
                step("各反復でnは要素値のコピーです。nを2倍にしてもnumsの中身は変わりません。", [4, 5], [variable("nums", "int[]", "[1, 2, 3]", "main")]),
                step("nums[1]は元のまま2なので、出力は2です。", [7], [variable("output", "String", "2", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-array-clone-shallow-001",
            level: .silver,
            difficulty: .tricky,
            category: "arrays",
            tags: ["模試専用", "array", "clone", "shallow copy"],
            code: """
public class Test {
    public static void main(String[] args) {
        int[][] a = { { 1 }, { 2 } };
        int[][] b = a.clone();
        b[0][0] = 9;
        System.out.println(a[0][0] + ":" + (a == b) + ":" + (a[0] == b[0]));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1:false:false", misconception: "cloneが深いコピーだと誤解", explanation: "2次元配列のcloneは外側配列だけをコピーし、内側配列は共有します。"),
                choice("b", "9:false:true", correct: true, explanation: "外側配列は別参照ですが、a[0]とb[0]は同じ内側配列を参照しています。"),
                choice("c", "9:true:true", misconception: "clone後も外側配列が同じ参照だと誤解", explanation: "cloneは外側配列の新しい配列オブジェクトを返します。"),
                choice("d", "1:false:true", misconception: "内側配列を共有していても値変更は見えないと誤解", explanation: "共有している内側配列の要素を更新するため、aからも9が見えます。"),
            ],
            intent: "多次元配列cloneが浅いコピーであることを確認する。",
            steps: [
                step("aは外側配列の中に2つのint配列参照を持ちます。", [3], [variable("a[0][0]", "int", "1", "heap")]),
                step("`a.clone()` は外側配列だけを複製するため、aとbは別参照ですがa[0]とb[0]は同じ配列です。", [4], [variable("a == b", "boolean", "false", "heap"), variable("a[0] == b[0]", "boolean", "true", "heap")]),
                step("b[0][0]を9にすると共有内側配列が変わり、a[0][0]も9です。", [5, 6], [variable("output", "String", "9:false:true", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-overload-null-string-object-001",
            level: .silver,
            difficulty: .tricky,
            category: "overload-resolution",
            tags: ["模試専用", "overload", "null"],
            code: """
public class Test {
    static void call(Object o) {
        System.out.println("Object");
    }
    static void call(String s) {
        System.out.println("String");
    }
    public static void main(String[] args) {
        call(null);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "Object", misconception: "nullはObject型として扱われると誤解", explanation: "StringはObjectのサブクラスなので、より具体的なString版が選ばれます。"),
                choice("b", "String", correct: true, explanation: "nullはどちらにも渡せますが、Stringの方がObjectより具体的なのでString版が選ばれます。"),
                choice("c", "コンパイルエラー", misconception: "null呼び出しは常に曖昧になると誤解", explanation: "候補間に親子関係がある場合は、より具体的な型を選べます。"),
                choice("d", "NullPointerException", misconception: "nullを渡した時点で例外になると誤解", explanation: "メソッド内で参照を使っていないため例外は発生しません。"),
            ],
            intent: "null実引数のオーバーロード解決でより具体的な参照型が選ばれることを確認する。",
            steps: [
                step("call(Object)とcall(String)が候補になります。", [2, 5, 9], [variable("candidates", "method set", "Object / String", "compiler")]),
                step("nullはObjectにもStringにも代入可能ですが、StringはObjectのサブクラスです。", [9], [variable("selected overload", "method", "call(String)", "compiler")]),
                step("String版が呼ばれ、出力は `String` です。", [6], [variable("output", "String", "String", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-private-method-not-override-001",
            level: .silver,
            difficulty: .tricky,
            category: "inheritance",
            tags: ["模試専用", "private method", "override"],
            code: """
class Parent {
    private void print() {
        System.out.print("P");
    }
    void run() {
        print();
    }
}

class Child extends Parent {
    void print() {
        System.out.print("C");
    }
}

public class Test {
    public static void main(String[] args) {
        new Child().run();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "P", correct: true, explanation: "Parentのprivateメソッドはオーバーライドされず、Parent.run内のprintはParent.printを呼びます。"),
                choice("b", "C", misconception: "Child.printがParent.printをオーバーライドすると誤解", explanation: "privateメソッドはサブクラスから見えないためオーバーライド対象ではありません。"),
                choice("c", "PC", misconception: "両方のprintが呼ばれると誤解", explanation: "run内の呼び出しは1回だけです。"),
                choice("d", "コンパイルエラー", misconception: "Childで同名メソッドを定義できないと誤解", explanation: "privateメソッドとは別メソッドとして定義できます。"),
            ],
            intent: "new Child().run() でも、Parent.run内のprivate `print()` は親クラス版に束縛されることを確認する。",
            steps: [
                step("ChildはParentを継承していますが、Parent.printはprivateです。", [1, 2, 10], [variable("Parent.print", "private method", "not inherited", "class Parent")]),
                step("new Child().run()で実行されるrunはParentのメソッドです。run内のprintはParent.printへ静的に結びつきます。", [5, 6, 17], [variable("called method", "method", "Parent.print", "runtime")]),
                step("Parent.printがPを出力します。", [3], [variable("output", "String", "P", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-final-override-compile-001",
            level: .silver,
            difficulty: .tricky,
            validatedByJavac: false,
            category: "inheritance",
            tags: ["模試専用", "final", "override", "compile"],
            code: """
class Parent {
    final void run() {}
}

class Child extends Parent {
    void run() {}
}

public class Test {
    public static void main(String[] args) {
        System.out.println("test");
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "test", misconception: "runを呼んでいないので問題ないと誤解", explanation: "finalメソッドをオーバーライドするクラス定義自体が不正です。"),
                choice("b", "何も出力されない", misconception: "mainだけ無視されると誤解", explanation: "コンパイルできないため実行されません。"),
                choice("c", "コンパイルエラー", correct: true, explanation: "Parent.runはfinalなので、Childで同じシグネチャのrunを定義してオーバーライドできません。"),
                choice("d", "実行時例外", misconception: "final違反が実行時に検出されると誤解", explanation: "finalメソッドのオーバーライド禁止はコンパイル時に検出されます。"),
            ],
            intent: "final `run()` を持つ親クラスに対し、子クラスで同シグネチャを宣言するとコンパイルエラーになることを確認する。",
            steps: [
                step("Parent.runはfinal付きのインスタンスメソッドです。", [1, 2], [variable("Parent.run", "final method", "cannot override", "class Parent")]),
                step("Child.runは同じシグネチャで定義され、Parent.runをオーバーライドしようとします。", [5, 6], [variable("Child.run", "method", "invalid override", "class Child")]),
                step("finalメソッドのオーバーライドは禁止されるため、コンパイルエラーです。", [6], [variable("result", "compile", "error", "javac")]),
            ]
        ),
        q(
            "silver-mock-century-constructor-super-order-001",
            level: .silver,
            difficulty: .tricky,
            category: "classes",
            tags: ["模試専用", "constructor", "initializer", "inheritance"],
            code: """
class A {
    A() {
        System.out.print("A");
    }
}

class B extends A {
    {
        System.out.print("B");
    }
    B() {
        System.out.print("C");
    }
}

public class Test {
    public static void main(String[] args) {
        new B();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "ABC", correct: true, explanation: "親コンストラクタA、子のインスタンス初期化ブロックB、子コンストラクタ本体Cの順です。"),
                choice("b", "BAC", misconception: "子の初期化ブロックがsuperより先だと誤解", explanation: "サブクラスのインスタンス初期化前に、親クラスのコンストラクタが実行されます。"),
                choice("c", "BCA", misconception: "親コンストラクタが最後だと誤解", explanation: "コンストラクタ連鎖では親側が先です。"),
                choice("d", "ACB", misconception: "子コンストラクタ本体が初期化ブロックより先だと誤解", explanation: "インスタンス初期化ブロックはコンストラクタ本体より先です。"),
            ],
            intent: "継承時のコンストラクタとインスタンス初期化ブロックの順序を確認する。",
            steps: [
                step("new B()では、まず暗黙のsuper()によりAのコンストラクタが実行されます。", [17, 2, 3], [variable("partial output", "String", "A", "stdout")]),
                step("Aの初期化後、Bのインスタンス初期化ブロックが実行されBが出力されます。", [7, 8, 9], [variable("partial output", "String", "AB", "stdout")]),
                step("最後にBコンストラクタ本体がCを出力し、結果は `ABC` です。", [11, 12], [variable("output", "String", "ABC", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-static-null-field-002",
            level: .silver,
            difficulty: .tricky,
            category: "classes",
            tags: ["模試専用", "static", "null reference"],
            code: """
class Counter {
    static int count = 5;
}

public class Test {
    public static void main(String[] args) {
        Counter c = null;
        System.out.println(c.count);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "5", correct: true, explanation: "staticフィールドはクラスに属するため、null参照式経由でも実体を参照せずCounter.countとして解決されます。"),
                choice("b", "0", misconception: "null参照なら既定値になると誤解", explanation: "参照先インスタンスは不要で、staticフィールドcountの値5が使われます。"),
                choice("c", "NullPointerException", misconception: "null参照式が必ず実体参照を行うと誤解", explanation: "staticメンバアクセスではインスタンスのフィールドを読みに行きません。"),
                choice("d", "コンパイルエラー", misconception: "参照変数経由でstaticフィールドへアクセスできないと誤解", explanation: "推奨されませんがコンパイル可能です。"),
            ],
            intent: "null参照を経由したstaticフィールドアクセスの挙動を確認する。",
            steps: [
                step("cはnullですが、型はCounterです。", [7], [variable("c", "Counter", "null", "main")]),
                step("`c.count` はstaticフィールドアクセスとして、コンパイル時にCounter.countへ解決されます。", [8], [variable("Counter.count", "static int", "5", "class")]),
                step("インスタンス参照は不要なので例外は起きず、5が出力されます。", [8], [variable("output", "String", "5", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-shadow-this-001",
            level: .silver,
            category: "classes",
            tags: ["模試専用", "this", "shadowing"],
            code: """
public class Test {
    int x = 1;
    void run() {
        int x = 2;
        System.out.println(x + ":" + this.x);
    }
    public static void main(String[] args) {
        new Test().run();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1:1", misconception: "ローカル変数が使われないと誤解", explanation: "単純名xは最も内側のローカル変数を指します。"),
                choice("b", "2:1", correct: true, explanation: "xはローカル変数2、this.xはインスタンスフィールド1です。"),
                choice("c", "2:2", misconception: "this.xもローカル変数を指すと誤解", explanation: "this.xは現在のインスタンスのフィールドを指します。"),
                choice("d", "コンパイルエラー", misconception: "フィールドと同名のローカル変数を宣言できないと誤解", explanation: "ローカル変数がフィールドを隠すことは可能です。"),
            ],
            intent: "ローカル変数によるフィールド隠蔽とthisによるフィールド参照を確認する。",
            steps: [
                step("Testのフィールドxは1です。", [2], [variable("this.x", "int", "1", "instance")]),
                step("run内ではローカル変数xが2として宣言され、単純名xはこのローカル変数を指します。", [3, 4], [variable("x", "int", "2", "run local")]),
                step("`x + \":\" + this.x` は `2:1` になります。", [5], [variable("output", "String", "2:1", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-string-intern-new-001",
            level: .silver,
            difficulty: .tricky,
            category: "strings",
            tags: ["模試専用", "String", "intern", "=="],
            code: """
public class Test {
    public static void main(String[] args) {
        String a = new String("ja");
        String b = "ja";
        System.out.println((a == b) + ":" + (a.intern() == b));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true:true", misconception: "new Stringもリテラルと同じ参照だと誤解", explanation: "new Stringは新しいStringオブジェクトを作るため、bとは別参照です。"),
                choice("b", "false:true", correct: true, explanation: "aとbは別参照ですが、a.intern()は文字列プールの `ja` を返すためbと同じ参照です。"),
                choice("c", "false:false", misconception: "internも新しいオブジェクトを返すと誤解", explanation: "internはプール中の代表参照を返します。"),
                choice("d", "true:false", misconception: "==とinternの働きを逆に理解している", explanation: "new Stringの参照比較はfalse、intern後のプール参照比較はtrueです。"),
            ],
            intent: "new String、文字列プール、intern、参照比較を確認する。",
            steps: [
                step("aはnewにより作られた新しいString、bは文字列プールのリテラル参照です。", [3, 4], [variable("a == b", "boolean", "false", "heap/pool")]),
                step("`a.intern()` は内容 `ja` に対応するプール上の参照を返します。", [5], [variable("a.intern() == b", "boolean", "true", "pool")]),
                step("したがって出力は `false:true` です。", [5], [variable("output", "String", "false:true", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-substring-end-exclusive-001",
            level: .silver,
            category: "strings",
            tags: ["模試専用", "String", "substring"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = "abcdef";
        System.out.println(s.substring(2, 5));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "cde", correct: true, explanation: "substringの開始は含み、終了インデックス5は含まないため、2,3,4のcdeです。"),
                choice("b", "cdef", misconception: "終了インデックスを含むと誤解", explanation: "第2引数の位置は含まれません。"),
                choice("c", "bcd", misconception: "インデックスを1始まりで考えている", explanation: "JavaのStringインデックスは0始まりです。"),
                choice("d", "IndexOutOfBoundsException", misconception: "終了インデックス5が範囲外だと誤解", explanation: "長さ6の文字列では終了インデックス5は有効です。"),
            ],
            intent: "substringの開始含む・終了含まない規則を確認する。",
            steps: [
                step("文字列abcdefのインデックスはa=0, b=1, c=2, d=3, e=4, f=5です。", [3], [variable("s", "String", "abcdef", "main")]),
                step("`substring(2, 5)` は2以上5未満を取り出します。", [4], [variable("selected range", "index", "2,3,4", "expression")]),
                step("該当文字はcdeなので、出力は `cde` です。", [4], [variable("output", "String", "cde", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-stringbuilder-reverse-alias-001",
            level: .silver,
            category: "strings",
            tags: ["模試専用", "StringBuilder", "alias"],
            code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("ab");
        StringBuilder same = sb.reverse();
        same.append("c");
        System.out.println(sb);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "ab", misconception: "reverseやappendが元のsbを変更しないと誤解", explanation: "StringBuilderの多くのメソッドは自身を変更し、自身の参照を返します。"),
                choice("b", "ba", misconception: "appendが別オブジェクトだけを変更すると誤解", explanation: "sameとsbは同じStringBuilderを参照しています。"),
                choice("c", "bac", correct: true, explanation: "reverseでsbはbaになり、sameはsbと同じ参照なのでappendによりbacになります。"),
                choice("d", "abc", misconception: "reverse結果が別のオブジェクトにだけ入ると誤解", explanation: "reverseは元のStringBuilderを反転します。"),
            ],
            intent: "StringBuilderの破壊的変更とメソッド戻り値が同一参照であることを確認する。",
            steps: [
                step("sbは最初 `ab` です。", [3], [variable("sb", "StringBuilder", "ab", "main")]),
                step("`sb.reverse()` はsb自身を `ba` に変更し、その同じ参照をsameへ返します。", [4], [variable("sb", "StringBuilder", "ba", "main"), variable("same == sb", "boolean", "true", "heap")]),
                step("same.append(\"c\") は同じオブジェクトを変更するため、sbの内容は `bac` です。", [5, 6], [variable("output", "String", "bac", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-localdate-immutable-001",
            level: .silver,
            category: "date-time",
            tags: ["模試専用", "LocalDate", "immutable"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.time.LocalDate date = java.time.LocalDate.of(2024, 2, 28);
        date.plusDays(1);
        System.out.println(date);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2024-02-28", correct: true, explanation: "LocalDateは不変で、plusDaysの戻り値を代入していないためdateは変わりません。"),
                choice("b", "2024-02-29", misconception: "plusDaysが元のdateを変更すると誤解", explanation: "plusDaysは新しいLocalDateを返します。"),
                choice("c", "2024-03-01", misconception: "うるう年の2月29日を飛ばしている", explanation: "2024年はうるう年ですが、今回は戻り値を捨てているため変化しません。"),
                choice("d", "コンパイルエラー", misconception: "LocalDate.ofを完全修飾名で呼べないと誤解", explanation: "完全修飾名での呼び出しは有効です。"),
            ],
            intent: "LocalDateの不変性と戻り値の扱いを確認する。",
            steps: [
                step("dateは2024-02-28を参照しています。", [3], [variable("date", "LocalDate", "2024-02-28", "main")]),
                step("`date.plusDays(1)` は2024-02-29を返しますが、戻り値は代入されていません。", [4], [variable("discarded return", "LocalDate", "2024-02-29", "expression")]),
                step("date自体は変わらないため、出力は `2024-02-28` です。", [5], [variable("output", "String", "2024-02-28", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-integer-cache-001",
            level: .silver,
            difficulty: .tricky,
            category: "data-types",
            tags: ["模試専用", "wrapper", "Integer cache", "=="],
            code: """
public class Test {
    public static void main(String[] args) {
        Integer a = 127;
        Integer b = 127;
        Integer c = 128;
        Integer d = 128; // standard cache boundary example
        System.out.println((a == b) + ":" + (c == d));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true:true", misconception: "Integerの==が常に値比較だと誤解", explanation: "ラッパー型同士の==は参照比較です。"),
                choice("b", "true:false", correct: true, explanation: "127はIntegerキャッシュ範囲内で同じ参照、128は通常別インスタンスになるためfalseです。"),
                choice("c", "false:false", misconception: "127も必ず別インスタンスだと誤解", explanation: "自動ボクシングでは少なくとも-128から127のIntegerはキャッシュされます。"),
                choice("d", "コンパイルエラー", misconception: "Integer同士を==で比較できないと誤解", explanation: "参照比較としてコンパイルできます。"),
            ],
            intent: "Integerキャッシュとラッパー型の==を確認する。",
            steps: [
                step("aとbには127がボクシングされ、Integerキャッシュ上の同じ参照になります。", [3, 4], [variable("a == b", "boolean", "true", "heap/cache")]),
                step("cとdの128は標準の必須キャッシュ範囲外なので、通常は別参照になります。", [5, 6], [variable("c == d", "boolean", "false", "heap")]),
                step("したがって出力は `true:false` です。", [7], [variable("output", "String", "true:false", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-unboxing-null-caught-001",
            level: .silver,
            category: "exceptions",
            tags: ["模試専用", "unboxing", "NullPointerException"],
            code: """
public class Test {
    public static void main(String[] args) {
        Integer value = null;
        try {
            int n = value; // null Integer cannot unbox
            System.out.println(n);
        } catch (NullPointerException e) {
            System.out.println("NPE");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", misconception: "nullのIntegerがintの既定値0になると誤解", explanation: "ローカル変数nへの代入前にunboxingで例外が発生します。"),
                choice("b", "null", misconception: "intにnullを保持できると誤解", explanation: "intはプリミティブなのでnullを保持できません。"),
                choice("c", "NPE", correct: true, explanation: "nullのIntegerをintへunboxingしようとしてNullPointerExceptionが発生し、catchでNPEが出力されます。"),
                choice("d", "コンパイルエラー", misconception: "Integerからintへの代入ができないと誤解", explanation: "自動unboxingによりコンパイルは可能です。"),
            ],
            intent: "nullラッパーの自動unboxingがNullPointerExceptionになることを確認する。",
            steps: [
                step("valueはnullのInteger参照です。", [3], [variable("value", "Integer", "null", "main")]),
                step("`int n = value;` ではIntegerからintへのunboxingが必要です。nullなのでNullPointerExceptionが発生します。", [5], [variable("result", "exception", "NullPointerException", "runtime")]),
                step("Integerのアンボクシング失敗をcatchし、`NPE` が出力されます。", [7, 8], [variable("output", "String", "NPE", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-default-method-class-wins-001",
            level: .silver,
            difficulty: .tricky,
            category: "inheritance",
            tags: ["模試専用", "default method", "class wins"],
            code: """
interface Named {
    default String name() {
        return "I";
    }
}

class Base {
    public String name() {
        return "B";
    }
}

class Child extends Base implements Named {}

public class Test {
    public static void main(String[] args) {
        System.out.println(new Child().name());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "I", misconception: "interfaceのdefaultがクラスメソッドより優先されると誤解", explanation: "同じシグネチャではクラス側のメソッドが優先されます。"),
                choice("b", "B", correct: true, explanation: "ChildはBase.nameを継承しており、interfaceのdefaultよりクラス階層のメソッドが優先されます。"),
                choice("c", "コンパイルエラー", misconception: "Base.nameとNamed.nameが衝突すると誤解", explanation: "クラス側のメソッドが優先されるため衝突は解決されます。"),
                choice("d", "null", misconception: "defaultメソッドが実装されないと誤解", explanation: "Base.nameが実装として使われます。"),
            ],
            intent: "defaultメソッドとクラスメソッドが競合した場合の優先順位を確認する。",
            steps: [
                step("Namedはdefault nameを持ち、Baseもpublic nameを持ちます。", [1, 2, 7, 8], [variable("Named.name", "default method", "returns I", "interface"), variable("Base.name", "method", "returns B", "class")]),
                step("ChildはBaseを継承しNamedを実装します。クラス階層のBase.nameがdefaultより優先されます。", [13], [variable("selected method", "method", "Base.name", "runtime")]),
                step("Base.nameの戻り値Bが出力されます。", [17], [variable("output", "String", "B", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-enum-ordinal-valueof-001",
            level: .silver,
            category: "classes",
            tags: ["模試専用", "enum", "ordinal", "valueOf"],
            code: """
enum Size {
    SMALL, MEDIUM, LARGE
}

public class Test {
    public static void main(String[] args) {
        System.out.println(Size.MEDIUM.ordinal() + ":" + Size.valueOf("LARGE").ordinal());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0:1", misconception: "ordinalが1始まりだと誤解", explanation: "ordinalは宣言順の0始まりです。"),
                choice("b", "1:2", correct: true, explanation: "MEDIUMは2番目なのでordinal 1、LARGEは3番目なのでordinal 2です。"),
                choice("c", "2:3", misconception: "ordinalが1始まりだと誤解", explanation: "enumのordinalは0から始まります。"),
                choice("d", "IllegalArgumentException", misconception: "valueOfでLARGEを取得できないと誤解", explanation: "文字列が列挙定数名と完全一致しているため取得できます。"),
            ],
            intent: "enumのordinalとvalueOfの基本挙動を確認する。",
            steps: [
                step("Sizeの宣言順はSMALL, MEDIUM, LARGEです。ordinalは0始まりです。", [1, 2], [variable("Size.MEDIUM.ordinal()", "int", "1", "main")]),
                step("`Size.valueOf(\"LARGE\")` はLARGE定数を返し、そのordinalは2です。", [7], [variable("Size.valueOf(\"LARGE\").ordinal()", "int", "2", "main")]),
                step("2つを文字列連結し、出力は `1:2` です。", [7], [variable("output", "String", "1:2", "stdout")]),
            ]
        ),
        q(
            "silver-mock-century-var-field-compile-001",
            level: .silver,
            difficulty: .tricky,
            validatedByJavac: false,
            category: "java-basics",
            tags: ["模試専用", "var", "field", "compile"],
            code: """
public class Test {
    var value = 1;
    public static void main(String[] args) {
        System.out.println("test");
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "test", misconception: "varをフィールドでも使えると誤解", explanation: "varはローカル変数の型推論用であり、フィールド宣言には使えません。"),
                choice("b", "1", misconception: "valueが自動的に出力されると誤解", explanation: "printlnしている文字列はtestですが、その前にコンパイルエラーです。"),
                choice("c", "コンパイルエラー", correct: true, explanation: "varはメソッド内のローカル変数などに限定され、インスタンスフィールドには使用できません。"),
                choice("d", "実行時例外", misconception: "varの制約が実行時に判定されると誤解", explanation: "varの使用可否はコンパイル時に判定されます。"),
            ],
            intent: "varはローカル変数に使うもので、フィールドには使えないことを確認する。",
            steps: [
                step("valueはクラスのインスタンスフィールドとして宣言されています。", [2], [variable("value", "field", "declared with var", "class Test")]),
                step("Javaのvarはローカル変数の型推論であり、フィールド宣言には使えません。", [2], [variable("result", "compile", "invalid var use", "compiler")]),
                step("そのためmainを実行する前にコンパイルエラーです。", [3], [variable("result", "compile", "error", "javac")]),
            ]
        ),
        q(
            "silver-mock-century-lambda-effectively-final-compile-001",
            level: .silver,
            difficulty: .tricky,
            validatedByJavac: false,
            category: "lambda",
            tags: ["模試専用", "lambda", "effectively final", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        int count = 0;
        Runnable r = () -> System.out.println(count);
        count++; // local is no longer effectively final
        r.run();
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "0", misconception: "ラムダ作成時の値がコピーされると誤解", explanation: "countが後で変更されているため、ラムダから参照できません。"),
                choice("b", "1", misconception: "変更後のcountをラムダが読めると誤解", explanation: "ラムダが捕捉するローカル変数はfinalまたは実質的finalである必要があります。"),
                choice("c", "コンパイルエラー", correct: true, explanation: "countはラムダで参照された後にcount++で変更されるため、実質的finalではありません。"),
                choice("d", "IllegalStateException", misconception: "実質的final違反が実行時例外になると誤解", explanation: "コンパイル時に検出されます。"),
            ],
            intent: "ラムダが捕捉するローカル変数は実質的finalでなければならないことを確認する。",
            steps: [
                step("countはローカル変数で、ラムダ式の中から参照されています。", [3, 4], [variable("count", "int", "captured", "main")]),
                step("その後 `count++` によりcountが変更されるため、countは実質的finalではありません。", [5], [variable("count", "int", "not effectively final", "compiler")]),
                step("ラムダから参照できる条件を満たさないため、コンパイルエラーです。", [4], [variable("result", "compile", "error", "javac")]),
            ]
        ),
        q(
            "silver-mock-century-multicatch-assign-compile-001",
            level: .silver,
            difficulty: .tricky,
            validatedByJavac: false,
            category: "exceptions",
            tags: ["模試専用", "multi-catch", "effectively final", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        try {
            throw new java.io.IOException();
        } catch (java.io.IOException | RuntimeException e) {
            e = new RuntimeException();
            System.out.println(e.getClass().getSimpleName());
        }
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "IOException", misconception: "代入行が無視されると誤解", explanation: "代入しようとしている時点でコンパイルエラーです。"),
                choice("b", "RuntimeException", misconception: "multi-catchパラメータへ再代入できると誤解", explanation: "multi-catchの例外パラメータは暗黙的にfinalです。"),
                choice("c", "コンパイルエラー", correct: true, explanation: "multi-catchのパラメータeに再代入することはできません。"),
                choice("d", "ClassCastException", misconception: "例外パラメータ代入を実行時キャストと混同", explanation: "型変換以前に、再代入自体が禁止されています。"),
            ],
            intent: "multi-catchの例外パラメータへ再代入できないことを確認する。",
            steps: [
                step("catchはIOExceptionまたはRuntimeExceptionを1つのパラメータeで受けます。", [5], [variable("e", "multi-catch parameter", "implicitly final", "catch")]),
                step("multi-catchのeは暗黙的にfinal扱いのため、`e = ...` は不正です。", [6], [variable("assignment", "statement", "invalid", "compiler")]),
                step("そのためコンパイルエラーになり、printlnまでは到達しません。", [7], [variable("result", "compile", "error", "javac")]),
            ]
        ),
        q(
            "silver-mock-century-overload-widening-varargs-001",
            level: .silver,
            difficulty: .tricky,
            category: "overload-resolution",
            tags: ["模試専用", "overload", "widening", "varargs"],
            code: """
public class Test {
    static void call(short s) {
        System.out.println("short");
    }
    static void call(byte... b) {
        System.out.println("varargs");
    }
    public static void main(String[] args) {
        byte b = 1;
        call(b);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "short", correct: true, explanation: "byteからshortへの拡大変換は固定引数メソッドとして選ばれ、可変長引数より優先されます。"),
                choice("b", "varargs", misconception: "byte...が完全一致なので優先されると誤解", explanation: "可変長引数メソッドは固定引数候補の後に検討されます。"),
                choice("c", "コンパイルエラー", misconception: "short版とvarargs版が曖昧になると誤解", explanation: "オーバーロード解決の段階によりshort版が選ばれます。"),
                choice("d", "1", misconception: "引数値がそのまま出力されると誤解", explanation: "各メソッドは固定文字列を出力します。"),
            ],
            intent: "固定引数の拡大変換が可変長引数より優先されることを確認する。",
            steps: [
                step("実引数bの型はbyteです。", [9, 10], [variable("b", "byte", "1", "main")]),
                step("call(short)はbyteからshortへの拡大変換で呼べます。call(byte...)は可変長引数です。", [2, 5, 10], [variable("selected overload", "method", "call(short)", "compiler")]),
                step("固定引数メソッドが先に選ばれるため、出力は `short` です。", [3], [variable("output", "String", "short", "stdout")]),
            ]
        ),
    ]

    static let goldSpecs: [Spec] = [
        q(
            "gold-mock-century-optional-map-null-001",
            level: .gold,
            category: "optional",
            tags: ["模試専用", "Optional", "map", "null"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.util.Optional<String> value = java.util.Optional.of("x").map(s -> null);
        System.out.println(value.isPresent());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", misconception: "Optionalがnullを値として保持すると誤解", explanation: "Optional.mapはマッピング結果をOptional.ofNullable相当で包むため、nullならemptyになります。"),
                choice("b", "false", correct: true, explanation: "mapのラムダがnullを返すため、結果のOptionalはemptyです。"),
                choice("c", "null", misconception: "Optional変数自体がnullになると誤解", explanation: "valueはOptional.emptyであり、参照自体はnullではありません。"),
                choice("d", "NullPointerException", misconception: "mapがnull戻り値を許可しないと誤解", explanation: "mapの結果がnullの場合はemptyとして扱われます。"),
            ],
            intent: "Optional.mapでマッピング結果がnullの場合はemptyになることを確認する。",
            steps: [
                step("Optional.of(\"x\") は値xを持つOptionalです。", [3], [variable("source", "Optional<String>", "Optional[x]", "main")]),
                step("mapのラムダはsを使わずnullを返します。mapはその戻り値をofNullable相当で扱います。", [3], [variable("mapped", "Optional<String>", "Optional.empty", "main")]),
                step("emptyなのでisPresentはfalseです。", [4], [variable("output", "String", "false", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-optional-orelse-eager-001",
            level: .gold,
            category: "optional",
            tags: ["模試専用", "Optional", "orElse", "eager evaluation"],
            code: """
public class Test {
    static String fallback() {
        System.out.print("F");
        return "B";
    }
    public static void main(String[] args) {
        System.out.print(java.util.Optional.of("A").orElse(fallback()));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", misconception: "値があるとorElseの引数が評価されないと誤解", explanation: "orElseの引数式はメソッド呼び出し前に評価されます。"),
                choice("b", "FB", misconception: "orElseがfallbackの戻り値を採用すると誤解", explanation: "Optionalに値Aがあるため戻り値はAです。ただしfallbackは評価されます。"),
                choice("c", "FA", correct: true, explanation: "fallback()が先に実行されFを出力し、orElse自体は値Aを返してAが出力されます。"),
                choice("d", "コンパイルエラー", misconception: "orElseにメソッド呼び出しを渡せないと誤解", explanation: "Stringを返す式なので渡せます。"),
            ],
            intent: "orElseの引数が値の有無に関係なく先に評価されることを確認する。",
            steps: [
                step("Optional.of(\"A\") は値Aを持ちます。", [7], [variable("optional", "Optional<String>", "Optional[A]", "main")]),
                step("orElseの引数式fallback()はメソッド呼び出し前に評価され、Fを出力してBを返します。", [2, 3, 7], [variable("partial output", "String", "F", "stdout")]),
                step("Optionalには値AがあるためorElseの戻り値はAで、最終出力は `FA` です。", [7], [variable("output", "String", "FA", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-optional-orelseget-lazy-001",
            level: .gold,
            category: "optional",
            tags: ["模試専用", "Optional", "orElseGet", "lazy evaluation"],
            code: """
public class Test {
    static String fallback() {
        System.out.print("F");
        return "B";
    }
    public static void main(String[] args) {
        System.out.print(java.util.Optional.of("A").orElseGet(() -> fallback()));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", correct: true, explanation: "Optionalに値があるため、orElseGetのSupplierは実行されずAだけが出力されます。"),
                choice("b", "FA", misconception: "orElseGetもorElseと同じく引数が即評価されると誤解", explanation: "orElseGetはSupplierを受け取り、必要な場合だけ実行します。"),
                choice("c", "FB", misconception: "fallbackの戻り値が採用されると誤解", explanation: "Optionalに値Aがあるためfallbackは呼ばれません。"),
                choice("d", "コンパイルエラー", misconception: "ラムダからstaticメソッドを呼べないと誤解", explanation: "Supplierラムダとして有効です。"),
            ],
            intent: "orElseGetが遅延評価されることを確認する。",
            steps: [
                step("Optional.of(\"A\") は値を持っています。", [7], [variable("optional", "Optional<String>", "Optional[A]", "main")]),
                step("orElseGetにはSupplierが渡されますが、値が存在するためSupplierは実行されません。", [7], [variable("fallback called", "boolean", "false", "runtime")]),
                step("Optional内のAだけが出力されます。", [7], [variable("output", "String", "A", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-stream-peek-count-optimized-001",
            level: .gold,
            difficulty: .tricky,
            category: "streams",
            tags: ["模試専用", "Stream", "peek", "count", "optimization"],
            code: """
public class Test {
    public static void main(String[] args) {
        long count = java.util.List.of("A", "B").stream()
                .peek(System.out::print)
                .count();
        System.out.println(count);
    }
}
""",
            question: "Java 17でこのコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "AB2", misconception: "peekが必ず各要素で実行されると誤解", explanation: "サイズが既知のストリームでcountだけを行う場合、peekを実行せず要素数を返せます。"),
                choice("b", "2", correct: true, explanation: "List由来でサイズが既知のため、countは走査を省略でき、peekの出力なしに2だけが出力されます。"),
                choice("c", "0", misconception: "peekがないとcountも計算されないと誤解", explanation: "終端操作countはサイズ情報から2を返します。"),
                choice("d", "コンパイルエラー", misconception: "peekにSystem.out::printを渡せないと誤解", explanation: "Consumerとして有効です。"),
            ],
            intent: "Stream.countがサイズ既知ソースでpeekを実行しない場合があることを確認する。",
            steps: [
                step("List.of(\"A\", \"B\") 由来のストリームは要素数が既知です。", [3], [variable("source size", "long", "2", "stream")]),
                step("終端操作countは、要素を実際に流さなくてもサイズから結果を得られます。peekのprintは実行されません。", [4, 5], [variable("peek executions", "int", "0", "stream pipeline")]),
                step("countは2なので、printlnにより `2` が出力されます。", [6], [variable("output", "String", "2", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-stream-filter-count-001",
            level: .gold,
            category: "streams",
            tags: ["模試専用", "Stream", "filter", "count"],
            code: """
public class Test {
    public static void main(String[] args) {
        long count = java.util.stream.Stream.of("a", "bb", "ccc")
                .filter(s -> s.length() > 1)
                .count();
        System.out.println(count);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1", misconception: "最初に条件を満たす要素だけ数えると誤解", explanation: "countはフィルタ後のすべての要素数を数えます。"),
                choice("b", "2", correct: true, explanation: "長さが2以上なのはbbとcccの2つです。"),
                choice("c", "3", misconception: "filterを無視して全要素を数えている", explanation: "filterによりaは除外されます。"),
                choice("d", "bbccc", misconception: "要素内容が連結されると誤解", explanation: "終端操作はcountなので数値を返します。"),
            ],
            intent: "filter後にcountが残った要素数を数えることを確認する。",
            steps: [
                step("元の要素はa, bb, cccです。", [3], [variable("source", "Stream<String>", "a, bb, ccc", "stream")]),
                step("filterは長さが1のaを除外し、bbとcccを残します。", [4], [variable("remaining", "Stream<String>", "bb, ccc", "stream")]),
                step("残った要素数は2なので、出力は `2` です。", [5, 6], [variable("output", "String", "2", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-stream-reduce-identity-001",
            level: .gold,
            category: "streams",
            tags: ["模試専用", "Stream", "reduce", "identity"],
            code: """
public class Test {
    public static void main(String[] args) {
        int result = java.util.stream.Stream.of(1, 2, 3)
                .reduce(10, (a, b) -> a + b);
        System.out.println(result);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "6", misconception: "identityが初期値として加算されることを見落としている", explanation: "reduceのidentity 10から始めて1,2,3を加算します。"),
                choice("b", "16", correct: true, explanation: "10 + 1 + 2 + 3 で16になります。"),
                choice("c", "10", misconception: "要素が処理されないと誤解", explanation: "ストリームには3要素あります。"),
                choice("d", "コンパイルエラー", misconception: "Integerストリームをintへreduceできないと誤解", explanation: "Integerの結果がunboxingされてintへ代入されます。"),
            ],
            intent: "reduceのidentityが初期値として使われることを確認する。",
            steps: [
                step("reduceはidentityの10から始めます。", [4], [variable("accumulator", "int", "10", "reduce")]),
                step("順に1,2,3を加算し、10 + 1 + 2 + 3になります。", [3, 4], [variable("result", "int", "16", "main")]),
                step("resultを出力するため、出力は `16` です。", [5], [variable("output", "String", "16", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-stream-flatmap-skip-001",
            level: .gold,
            category: "streams",
            tags: ["模試専用", "Stream", "flatMap", "skip", "findFirst"],
            code: """
public class Test {
    public static void main(String[] args) {
        String value = java.util.stream.Stream.of(java.util.List.of("A", "B"), java.util.List.of("C"))
                .flatMap(java.util.List::stream)
                .skip(1)
                .findFirst()
                .orElse("X");
        System.out.println(value);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", misconception: "skipを見落としている", explanation: "flatMap後の先頭Aはskip(1)で読み飛ばされます。"),
                choice("b", "B", correct: true, explanation: "flatMapでA,B,Cの順になり、skip(1)後の最初はBです。"),
                choice("c", "C", misconception: "最初のList全体をskipすると誤解", explanation: "skipはflatMap後の要素単位で1つだけ飛ばします。"),
                choice("d", "X", misconception: "findFirstが空になると誤解", explanation: "skip後もB,Cが残っています。"),
            ],
            intent: "flatMap後の要素列にskipとfindFirstが適用される順序を確認する。",
            steps: [
                step("Stream.ofは2つのListを要素に持ちます。", [3], [variable("source", "Stream<List<String>>", "[A, B], [C]", "stream")]),
                step("flatMapにより要素列はA, B, Cになります。skip(1)でAを飛ばします。", [4, 5], [variable("after skip", "Stream<String>", "B, C", "stream")]),
                step("findFirstはBを返すため、orElseは使われずBが出力されます。", [6, 7, 8], [variable("output", "String", "B", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-collectors-grouping-counting-001",
            level: .gold,
            category: "streams",
            tags: ["模試専用", "Collectors", "groupingBy", "counting"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.util.Map<Integer, Long> map = java.util.stream.Stream.of("a", "bb", "c")
                .collect(java.util.stream.Collectors.groupingBy(String::length, java.util.stream.Collectors.counting()));
        System.out.println(map.get(1) + ":" + map.get(2));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1:2", misconception: "長さ1と長さ2の件数を逆にしている", explanation: "長さ1はaとcで2件、長さ2はbbで1件です。"),
                choice("b", "2:1", correct: true, explanation: "groupingByで文字列長ごとに数え、長さ1が2、長さ2が1になります。"),
                choice("c", "a:bb", misconception: "グループの代表要素が入ると誤解", explanation: "下流Collectorがcountingなので値はLongの件数です。"),
                choice("d", "NullPointerException", misconception: "map.get(2)が存在しないと誤解", explanation: "長さ2のbbがあるためキー2は存在します。"),
            ],
            intent: "groupingByとcountingの結果Mapを確認する。",
            steps: [
                step("入力はa, bb, cで、それぞれ長さ1, 2, 1です。", [3], [variable("lengths", "int", "1, 2, 1", "stream")]),
                step("groupingBy(String::length, counting())により、キー1に2件、キー2に1件が集計されます。", [4], [variable("map", "Map<Integer, Long>", "{1=2, 2=1}", "main")]),
                step("map.get(1)とmap.get(2)を連結し、出力は `2:1` です。", [5], [variable("output", "String", "2:1", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-collectors-tomap-duplicate-001",
            level: .gold,
            difficulty: .tricky,
            category: "streams",
            tags: ["模試専用", "Collectors", "toMap", "duplicate key"],
            code: """
public class Test {
    public static void main(String[] args) {
        try {
            java.util.stream.Stream.of("a", "b")
                    .collect(java.util.stream.Collectors.toMap(String::length, s -> s));
            System.out.println("OK");
        } catch (IllegalStateException e) {
            System.out.println("DUP");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "OK", misconception: "後の値で上書きされると誤解", explanation: "マージ関数なしのtoMapは重複キーでIllegalStateExceptionを投げます。"),
                choice("b", "DUP", correct: true, explanation: "aとbはいずれも長さ1でキーが重複し、catchでDUPが出力されます。"),
                choice("c", "{1=b}", misconception: "自動的に後勝ちになると誤解", explanation: "後勝ちにするには明示的なマージ関数が必要です。"),
                choice("d", "NullPointerException", misconception: "キーがnullになると誤解", explanation: "キーは長さ1でnullではありません。問題は重複です。"),
            ],
            intent: "Collectors.toMapの重複キー処理を確認する。",
            steps: [
                step("aとbはいずれもString::lengthでキー1になります。", [4, 5], [variable("keys", "int", "1, 1", "collector")]),
                step("マージ関数なしのtoMapでは同じキーに2つ目の値を入れようとするとIllegalStateExceptionです。", [5], [variable("result", "exception", "IllegalStateException", "collector")]),
                step("catch節でDUPが出力されます。", [7, 8], [variable("output", "String", "DUP", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-treeset-comparator-length-001",
            level: .gold,
            difficulty: .tricky,
            category: "collections-generics",
            tags: ["模試専用", "TreeSet", "Comparator", "ordering"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.util.Set<String> set = new java.util.TreeSet<>(java.util.Comparator.comparingInt(String::length));
        set.add("aa");
        set.add("bb");
        set.add("c");
        System.out.println(set.size() + ":" + set);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "3:[c, aa, bb]", misconception: "equalsが違えばすべて入ると誤解", explanation: "TreeSetはComparatorで0と比較される要素を同一扱いします。"),
                choice("b", "2:[c, aa]", correct: true, explanation: "aaとbbは長さが同じでComparator上同一扱いになり、先に入ったaaだけ残ります。"),
                choice("c", "2:[aa, c]", misconception: "自然順で表示されると誤解", explanation: "TreeSetの順序は指定Comparatorの長さ順です。"),
                choice("d", "1:[c]", misconception: "長さが違うものも重複扱いすると誤解", explanation: "長さ1のcと長さ2のaaはComparator上別です。"),
            ],
            intent: "TreeSetがComparatorの比較結果で重複判定することを確認する。",
            steps: [
                step("Comparatorは文字列長だけを比較します。", [3], [variable("comparator", "Comparator<String>", "by length", "TreeSet")]),
                step("aaとbbはどちらも長さ2なので比較結果0となり、bbは追加されません。cは長さ1なので別要素です。", [4, 5, 6], [variable("set", "TreeSet<String>", "[c, aa]", "main")]),
                step("サイズ2と集合内容が出力され、結果は `2:[c, aa]` です。", [7], [variable("output", "String", "2:[c, aa]", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-map-merge-001",
            level: .gold,
            category: "collections-generics",
            tags: ["模試専用", "Map", "merge"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.util.Map<String, Integer> map = new java.util.HashMap<>();
        map.put("a", 1);
        map.merge("a", 2, Integer::sum);
        map.merge("b", 3, Integer::sum);
        System.out.println(map.get("a") + ":" + map.get("b"));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2:3", misconception: "既存値が上書きされるだけだと誤解", explanation: "キーaは既存値1と新値2がremapping関数で合算されます。"),
                choice("b", "3:3", correct: true, explanation: "aは1+2で3、bは未存在なので3がそのまま入ります。"),
                choice("c", "1:3", misconception: "mergeが既存キーを変更しないと誤解", explanation: "既存キーにはremapping関数が適用されます。"),
                choice("d", "NullPointerException", misconception: "未存在キーbで関数が呼ばれてnullになると誤解", explanation: "未存在キーでは値3がそのまま関連付けられます。"),
            ],
            intent: "Map.mergeの既存キー・未存在キーの違いを確認する。",
            steps: [
                step("mapには最初a=1だけがあります。", [3, 4], [variable("map", "Map<String,Integer>", "{a=1}", "main")]),
                step("merge(\"a\", 2, sum)は既存値1と新値2を合算し、a=3にします。bは未存在なので3が入ります。", [5, 6], [variable("map", "Map<String,Integer>", "{a=3, b=3}", "main")]),
                step("aとbを取り出して連結し、出力は `3:3` です。", [7], [variable("output", "String", "3:3", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-computeifabsent-null-001",
            level: .gold,
            difficulty: .tricky,
            category: "collections-generics",
            tags: ["模試専用", "Map", "computeIfAbsent", "null"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.util.Map<String, String> map = new java.util.HashMap<>();
        map.computeIfAbsent("a", key -> null);
        System.out.println(map.containsKey("a"));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", misconception: "null値でキーが登録されると誤解", explanation: "computeIfAbsentのマッピング関数がnullを返すと、関連付けは行われません。"),
                choice("b", "false", correct: true, explanation: "関数の戻り値がnullなので、キーaはmapに追加されません。"),
                choice("c", "null", misconception: "containsKeyがnullを返すと誤解", explanation: "containsKeyの戻り値はbooleanです。"),
                choice("d", "NullPointerException", misconception: "マッピング関数のnull戻り値が例外になると誤解", explanation: "HashMapのcomputeIfAbsentではnull戻り値なら登録しないだけです。"),
            ],
            intent: "computeIfAbsentで関数がnullを返した場合は登録されないことを確認する。",
            steps: [
                step("mapは空で開始します。", [3], [variable("map", "Map<String,String>", "{}", "main")]),
                step("キーaは未存在なので関数が呼ばれますが、戻り値はnullです。", [4], [variable("mapping result", "String", "null", "lambda")]),
                step("nullの場合はマッピングが記録されず、containsKey(\"a\")はfalseです。", [5], [variable("output", "String", "false", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-concurrenthashmap-null-001",
            level: .gold,
            category: "concurrency",
            tags: ["模試専用", "ConcurrentHashMap", "null"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.util.concurrent.ConcurrentHashMap<String, String> map = new java.util.concurrent.ConcurrentHashMap<>();
        try {
            map.put("a", null);
            System.out.println("OK");
        } catch (NullPointerException e) {
            System.out.println("NPE");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "OK", misconception: "HashMapと同じくnull値を許可すると誤解", explanation: "ConcurrentHashMapはnullキー・null値を許可しません。"),
                choice("b", "NPE", correct: true, explanation: "null値をputしようとしてNullPointerExceptionが発生し、catchでNPEが出力されます。"),
                choice("c", "null", misconception: "nullが文字列として保存されると誤解", explanation: "保存前に例外が発生します。"),
                choice("d", "コンパイルエラー", misconception: "ConcurrentHashMapにnullを渡せないことがコンパイル時に分かると誤解", explanation: "型としてはString参照なのでコンパイル可能です。実行時に拒否されます。"),
            ],
            intent: "ConcurrentHashMapがnullキー・null値を許可しないことを確認する。",
            steps: [
                step("空のConcurrentHashMapを作成します。", [3], [variable("map", "ConcurrentHashMap<String,String>", "{}", "main")]),
                step("`put(\"a\", null)` でnull値を入れようとします。ConcurrentHashMapはnull値を許可しません。", [5], [variable("result", "exception", "NullPointerException", "runtime")]),
                step("ConcurrentHashMapのnull拒否をcatchし、`NPE` が出力されます。", [7, 8], [variable("output", "String", "NPE", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-atomicinteger-getandincrement-001",
            level: .gold,
            category: "concurrency",
            tags: ["模試専用", "AtomicInteger", "getAndIncrement", "incrementAndGet"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.util.concurrent.atomic.AtomicInteger value = new java.util.concurrent.atomic.AtomicInteger(1);
        System.out.println(value.getAndIncrement() + ":" + value.incrementAndGet());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1:2", misconception: "incrementAndGetの更新後値を見落としている", explanation: "getAndIncrement後に値は2、incrementAndGetで3になって返ります。"),
                choice("b", "1:3", correct: true, explanation: "getAndIncrementは更新前の1を返し、次のincrementAndGetは更新後の3を返します。"),
                choice("c", "2:3", misconception: "getAndIncrementも更新後値を返すと誤解", explanation: "getAndIncrementは更新前の値を返します。"),
                choice("d", "2:2", misconception: "2回目のインクリメントが行われないと誤解", explanation: "両方のメソッドがそれぞれインクリメントします。"),
            ],
            intent: "AtomicIntegerの前置・後置的な戻り値の違いを確認する。",
            steps: [
                step("AtomicIntegerの初期値は1です。", [3], [variable("value", "AtomicInteger", "1", "main")]),
                step("getAndIncrementは1を返して内部値を2にします。続くincrementAndGetは3に更新して3を返します。", [4], [variable("first", "int", "1", "expression"), variable("second", "int", "3", "expression")]),
                step("2つを連結し、出力は `1:3` です。", [4], [variable("output", "String", "1:3", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-completablefuture-handle-001",
            level: .gold,
            category: "concurrency",
            tags: ["模試専用", "CompletableFuture", "handle", "exception"],
            code: """
public class Test {
    public static void main(String[] args) {
        String value = java.util.concurrent.CompletableFuture.<String>failedFuture(new RuntimeException())
                .handle((result, error) -> error == null ? result : "X")
                .join();
        System.out.println(value);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "null", misconception: "例外時のresultがそのまま返ると誤解", explanation: "handle内でerrorがnullでない場合はXを返しています。"),
                choice("b", "X", correct: true, explanation: "failedFutureは例外完了しており、handleが例外を受け取ってXに変換します。"),
                choice("c", "RuntimeException", misconception: "joinが例外名を返すと誤解", explanation: "handleで通常値Xへ回復しているためjoinはXを返します。"),
                choice("d", "CompletionException", misconception: "handle後も例外完了のままだと誤解", explanation: "handleが正常に値を返すと後続は通常完了になります。"),
            ],
            intent: "CompletableFuture.handleで例外完了を通常値へ変換できることを確認する。",
            steps: [
                step("failedFutureはRuntimeExceptionで例外完了したCompletableFutureです。", [3], [variable("future", "CompletableFuture<String>", "failed", "main")]),
                step("handleはresultとerrorを受け取り、errorがnullでないためXを返します。", [4], [variable("handled value", "String", "X", "handle")]),
                step("joinは回復後の値Xを返し、出力は `X` です。", [5, 6], [variable("output", "String", "X", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-executor-submit-exception-001",
            level: .gold,
            difficulty: .tricky,
            category: "concurrency",
            tags: ["模試専用", "ExecutorService", "submit", "Future", "ExecutionException"],
            code: """
public class Test {
    public static void main(String[] args) throws Exception {
        java.util.concurrent.ExecutorService service = java.util.concurrent.Executors.newSingleThreadExecutor();
        java.util.concurrent.Future<?> future = service.submit(() -> { throw new RuntimeException("boom"); });
        try {
            future.get();
            System.out.println("OK");
        } catch (java.util.concurrent.ExecutionException e) {
            System.out.println("EE");
        } finally {
            service.shutdown();
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "OK", misconception: "submit内の例外が無視されると誤解", explanation: "例外はFutureに保持され、getでExecutionExceptionとして取り出されます。"),
                choice("b", "EE", correct: true, explanation: "submitされたタスクのRuntimeExceptionはfuture.get()でExecutionExceptionとして通知されます。"),
                choice("c", "boom", misconception: "RuntimeExceptionのメッセージが直接出力されると誤解", explanation: "catch内で出力しているのは固定文字列EEです。"),
                choice("d", "コンパイルエラー", misconception: "ラムダ内でRuntimeExceptionを投げられないと誤解", explanation: "RuntimeExceptionは非チェック例外なので投げられます。"),
            ],
            intent: "ExecutorService.submitでタスク例外がFuture.get時にExecutionExceptionとして表れることを確認する。",
            steps: [
                step("submitでRuntimeExceptionを投げるタスクを投入します。", [3, 4], [variable("future", "Future<?>", "task submitted", "main")]),
                step("submitは例外を呼び出し元へ直接投げず、Futureに記録します。future.getでExecutionExceptionが発生します。", [6], [variable("result", "exception", "ExecutionException", "future.get")]),
                step("catch節でEEを出力し、finallyでExecutorServiceをshutdownします。", [8, 9, 10, 11], [variable("output", "String", "EE", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-trywithresources-close-order-001",
            level: .gold,
            category: "exceptions",
            tags: ["模試専用", "try-with-resources", "close order"],
            code: """
class R implements AutoCloseable {
    private final String name;
    R(String name) {
        this.name = name;
    }
    public void close() {
        System.out.print(name);
    }
}

public class Test {
    public static void main(String[] args) {
        try (R a = new R("A"); R b = new R("B")) { // closes B then A
            System.out.print("T");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "TAB", misconception: "リソースが宣言順にcloseされると誤解", explanation: "try-with-resourcesのcloseは宣言と逆順です。"),
                choice("b", "TBA", correct: true, explanation: "try本体でT、終了時にb、aの逆順でcloseされるためTBAです。"),
                choice("c", "ABT", misconception: "try本体より先にcloseされると誤解", explanation: "closeはtry本体の後です。"),
                choice("d", "BT A", misconception: "空白が入ると誤解", explanation: "printは空白や改行を出力していません。"),
            ],
            intent: "try-with-resourcesでリソースが逆順にcloseされることを確認する。",
            steps: [
                step("リソースa, bの順に生成され、try本体に入ります。", [13], [variable("resources", "R", "a then b", "try")]),
                step("try本体でTを出力します。", [14], [variable("partial output", "String", "T", "stdout")]),
                step("終了時にb.close、a.closeの順で実行され、B、Aが続きます。", [6, 13, 15], [variable("output", "String", "TBA", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-trywithresources-suppressed-001",
            level: .gold,
            difficulty: .tricky,
            category: "exceptions",
            tags: ["模試専用", "try-with-resources", "suppressed exception"],
            code: """
class R implements AutoCloseable {
    public void close() throws Exception {
        throw new Exception("close");
    }
}

public class Test {
    public static void main(String[] args) {
        try (R r = new R()) {
            throw new Exception("body"); // primary exception
        } catch (Exception e) {
            System.out.println(e.getMessage() + ":" + e.getSuppressed()[0].getMessage());
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "close:body", misconception: "closeの例外が主例外になると誤解", explanation: "try本体で先に例外が発生しているため、bodyが主例外になります。"),
                choice("b", "body:close", correct: true, explanation: "try本体の例外bodyが主例外、closeの例外closeがsuppressedになります。"),
                choice("c", "body", misconception: "suppressed例外が保存されないと誤解", explanation: "try-with-resourcesはclose時の例外をsuppressedとして主例外に保持します。"),
                choice("d", "close", misconception: "本体例外がclose例外で上書きされると誤解", explanation: "本体例外が主例外としてcatchされます。"),
            ],
            intent: "try-with-resourcesの主例外とsuppressed例外の関係を確認する。",
            steps: [
                step("try本体でException(\"body\")が投げられます。", [9, 10], [variable("primary exception", "Exception", "body", "try")]),
                step("リソースcloseでもException(\"close\")が投げられますが、これはsuppressedに追加されます。", [2, 3], [variable("suppressed[0]", "Exception", "close", "exception")]),
                step("catchで主例外メッセージとsuppressedメッセージを出力し、`body:close` です。", [11, 12], [variable("output", "String", "body:close", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-effective-final-resource-001",
            level: .gold,
            category: "exceptions",
            tags: ["模試専用", "try-with-resources", "effectively final"],
            code: """
class R implements AutoCloseable {
    public void close() {
        System.out.print("C");
    }
}

public class Test {
    public static void main(String[] args) {
        R r = new R();
        try (r) { // reusing effectively final resource
            System.out.print("T");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "T", misconception: "外で宣言したリソースはcloseされないと誤解", explanation: "try-with-resourcesに指定されたリソースは終了時にcloseされます。"),
                choice("b", "TC", correct: true, explanation: "rは実質的finalなのでtry-with-resourcesに指定でき、try本体後にcloseされます。"),
                choice("c", "C", misconception: "try本体が実行されないと誤解", explanation: "try本体でTが先に出力されます。"),
                choice("d", "コンパイルエラー", misconception: "try()内では必ず新規変数宣言が必要だと誤解", explanation: "Java 9以降はfinalまたは実質的finalな既存変数を指定できます。"),
            ],
            intent: "try-with-resourcesで実質的finalな既存変数を利用できることを確認する。",
            steps: [
                step("rはnew R()を参照し、その後再代入されないため実質的finalです。", [9, 10], [variable("r", "R", "effectively final", "main")]),
                step("try本体でTを出力します。", [11], [variable("partial output", "String", "T", "stdout")]),
                step("try終了時にr.closeが呼ばれCが出力され、結果は `TC` です。", [2, 3, 12], [variable("output", "String", "TC", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-path-normalize-002",
            level: .gold,
            category: "io-nio",
            tags: ["模試専用", "Path", "normalize"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.nio.file.Path path = java.nio.file.Path.of("a/./b/../c");
        System.out.println(path.normalize());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "a/b/c", misconception: "`..` の効果を見落としている", explanation: "`b/..` は直前のbと相殺されます。"),
                choice("b", "a/c", correct: true, explanation: "`.` は除去され、`b/..` が相殺されるため `a/c` になります。"),
                choice("c", "c", misconception: "先頭のaも消えると誤解", explanation: "`..` が消すのは直前のbだけです。"),
                choice("d", "a/./b/../c", misconception: "normalizeが何もしないと誤解", explanation: "冗長な名前要素は正規化されます。"),
            ],
            intent: "Path.normalizeが`.`と`..`を構文的に整理することを確認する。",
            steps: [
                step("pathは相対パス `a/./b/../c` です。", [3], [variable("path", "Path", "a/./b/../c", "main")]),
                step("`.` は現在ディレクトリなので除去され、`b/..` はbを打ち消します。", [4], [variable("normalized", "Path", "a/c", "NIO")]),
                step("正規化後のパスが出力され、結果は `a/c` です。", [4], [variable("output", "String", "a/c", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-path-resolve-absolute-001",
            level: .gold,
            difficulty: .tricky,
            category: "io-nio",
            tags: ["模試専用", "Path", "resolve", "absolute path"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.nio.file.Path base = java.nio.file.Path.of("base");
        java.nio.file.Path other = java.nio.file.Path.of("/tmp/file");
        System.out.println(base.resolve(other));
    }
}
""",
            question: "Unix系環境でこのコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "base/tmp/file", misconception: "絶対パスもbaseに連結されると誤解", explanation: "resolveの引数が絶対パスの場合、baseは無視されます。"),
                choice("b", "/tmp/file", correct: true, explanation: "otherが絶対パスなので、base.resolve(other)はother自身を返します。"),
                choice("c", "base/../../tmp/file", misconception: "絶対パスを相対化してから結合すると誤解", explanation: "resolveはそのような変換を行いません。"),
                choice("d", "InvalidPathException", misconception: "絶対パスをresolveに渡せないと誤解", explanation: "絶対パスもPathとして有効です。"),
            ],
            intent: "Path.resolveで引数が絶対パスの場合の挙動を確認する。",
            steps: [
                step("baseは相対パスbase、otherはUnix系の絶対パス/tmp/fileです。", [3, 4], [variable("base", "Path", "base", "main"), variable("other", "Path", "/tmp/file", "main")]),
                step("resolveは引数が絶対パスなら、左側のbaseを使わずotherを返します。", [5], [variable("resolved", "Path", "/tmp/file", "NIO")]),
                step("出力は `/tmp/file` です。", [5], [variable("output", "String", "/tmp/file", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-localdate-plusyears-leap-001",
            level: .gold,
            category: "date-time",
            tags: ["模試専用", "LocalDate", "leap year", "plusYears"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.time.LocalDate date = java.time.LocalDate.of(2024, 2, 29);
        System.out.println(date.plusYears(1));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2025-02-28", correct: true, explanation: "2025年には2月29日がないため、plusYearsは有効な日付である2月28日に調整します。"),
                choice("b", "2025-03-01", misconception: "存在しない日付を翌日に繰り越すと誤解", explanation: "LocalDate.plusYearsは結果月の有効な末日に調整します。"),
                choice("c", "2025-02-29", misconception: "存在しない日付でも保持できると誤解", explanation: "LocalDateは有効な日付だけを表します。"),
                choice("d", "DateTimeException", misconception: "調整されず例外になると誤解", explanation: "plusYearsはこのケースで例外ではなく日付調整を行います。"),
            ],
            intent: "うるう日の年加算における日付調整を確認する。",
            steps: [
                step("dateはうるう年の2024-02-29です。", [3], [variable("date", "LocalDate", "2024-02-29", "main")]),
                step("1年後の2025年には2月29日が存在しません。", [4], [variable("candidate", "LocalDate", "2025-02-29 invalid", "calculation")]),
                step("有効な月末日へ調整され、出力は `2025-02-28` です。", [4], [variable("output", "String", "2025-02-28", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-datetimeformatter-parse-001",
            level: .gold,
            category: "date-time",
            tags: ["模試専用", "DateTimeFormatter", "ofPattern", "parse"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("yyyy/MM/dd");
        java.time.LocalDate date = java.time.LocalDate.parse("2024/03/02", formatter);
        System.out.println(date.getMonthValue() + ":" + date.getDayOfMonth());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2024:3", misconception: "年と月を出力していると誤解", explanation: "出力しているのは月の値と日の値です。"),
                choice("b", "3:2", correct: true, explanation: "パターンyyyy/MM/ddで2024年3月2日としてparseされ、月3、日2が出力されます。"),
                choice("c", "03:02", misconception: "getMonthValueやgetDayOfMonthがゼロ埋め文字列を返すと誤解", explanation: "これらはintを返すためゼロ埋めされません。"),
                choice("d", "DateTimeParseException", misconception: "パターンと文字列が一致していないと誤解", explanation: "yyyy/MM/ddと2024/03/02は一致しています。"),
            ],
            intent: "DateTimeFormatter.ofPatternとLocalDate.parseの結果を確認する。",
            steps: [
                step("formatterは `yyyy/MM/dd` のパターンです。", [3], [variable("formatter", "DateTimeFormatter", "yyyy/MM/dd", "main")]),
                step("文字列2024/03/02は2024年3月2日としてparseされます。", [4], [variable("date", "LocalDate", "2024-03-02", "main")]),
                step("月値3と日値2を連結し、出力は `3:2` です。", [5], [variable("output", "String", "3:2", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-numberformat-germany-001",
            level: .gold,
            category: "localization-formatting",
            tags: ["模試専用", "NumberFormat", "Locale", "format"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.text.NumberFormat format = java.text.NumberFormat.getNumberInstance(java.util.Locale.GERMANY);
        System.out.println(format.format(1234.5));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1,234.5", misconception: "US形式の区切りを想定している", explanation: "Locale.GERMANYでは桁区切りがピリオド、小数区切りがカンマです。"),
                choice("b", "1.234,5", correct: true, explanation: "ドイツロケールでは1234.5は `1.234,5` と整形されます。"),
                choice("c", "1234.5", misconception: "ロケールが反映されないと誤解", explanation: "NumberFormat.getNumberInstance(Locale.GERMANY)によりロケール形式が使われます。"),
                choice("d", "1 234,5", misconception: "空白区切りのロケールと混同", explanation: "Locale.GERMANYの桁区切りはピリオドです。"),
            ],
            intent: "NumberFormatがロケールに応じた区切り記号を使うことを確認する。",
            steps: [
                step("NumberFormatはLocale.GERMANYで作成されます。", [3], [variable("locale", "Locale", "GERMANY", "main")]),
                step("ドイツ形式では桁区切りが`.`、小数区切りが`,`です。", [4], [variable("formatted", "String", "1.234,5", "formatter")]),
                step("format結果が出力され、`1.234,5` です。", [4], [variable("output", "String", "1.234,5", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-messageformat-quotes-002",
            level: .gold,
            difficulty: .tricky,
            category: "localization-formatting",
            tags: ["模試専用", "MessageFormat", "quotes"],
            code: """
public class Test {
    public static void main(String[] args) {
        System.out.println(java.text.MessageFormat.format("'{0}' {0}", "X"));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "X X", misconception: "引用符内の{0}も置換されると誤解", explanation: "MessageFormatでは単引用符で囲まれた部分はリテラル扱いです。"),
                choice("b", "{0} X", correct: true, explanation: "最初の`{0}`は引用符でリテラル化され、後半の{0}だけXに置換されます。"),
                choice("c", "'X' X", misconception: "引用符が文字として残りつつ置換もされると誤解", explanation: "引用符は構文用で、引用された{0}は置換されません。"),
                choice("d", "IllegalArgumentException", misconception: "引用符付きパターンが不正だと誤解", explanation: "このパターンは有効です。"),
            ],
            intent: "MessageFormatの単引用符によるリテラル化を確認する。",
            steps: [
                step("パターンは `'{0}' {0}` です。最初の{0}は単引用符で囲まれています。", [3], [variable("pattern", "String", "'{0}' {0}", "MessageFormat")]),
                step("引用符内の{0}は置換対象ではなく文字列リテラルとして扱われ、後半の{0}だけXになります。", [3], [variable("formatted", "String", "{0} X", "formatter")]),
                step("出力は `{0} X` です。", [3], [variable("output", "String", "{0} X", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-annotation-runtime-retention-001",
            level: .gold,
            category: "annotations",
            tags: ["模試専用", "annotation", "Retention", "reflection"],
            code: """
@java.lang.annotation.Retention(java.lang.annotation.RetentionPolicy.RUNTIME)
@interface Mark {}

@Mark
public class Test {
    public static void main(String[] args) {
        System.out.println(Test.class.isAnnotationPresent(Mark.class));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", correct: true, explanation: "MarkはRUNTIME保持なので、実行時リフレクションで検出できます。"),
                choice("b", "false", misconception: "アノテーションは実行時に必ず消えると誤解", explanation: "RetentionPolicy.RUNTIMEなら実行時にも保持されます。"),
                choice("c", "null", misconception: "isAnnotationPresentがnullを返すと誤解", explanation: "戻り値はbooleanです。"),
                choice("d", "コンパイルエラー", misconception: "同じファイル内でアノテーション型を定義できないと誤解", explanation: "非publicのトップレベルアノテーション型として定義できます。"),
            ],
            intent: "RUNTIME保持のアノテーションがリフレクションで取得できることを確認する。",
            steps: [
                step("MarkにはRetentionPolicy.RUNTIMEが指定されています。", [1, 2], [variable("Mark retention", "RetentionPolicy", "RUNTIME", "annotation")]),
                step("Testクラスには@Markが付いています。", [4, 5], [variable("Test annotation", "Mark", "present", "class")]),
                step("isAnnotationPresentはtrueを返し、出力は `true` です。", [7], [variable("output", "String", "true", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-annotation-default-value-001",
            level: .gold,
            category: "annotations",
            tags: ["模試専用", "annotation", "default value"],
            code: """
@java.lang.annotation.Retention(java.lang.annotation.RetentionPolicy.RUNTIME)
@interface Level {
    int value() default 3;
}

@Level
public class Test {
    public static void main(String[] args) {
        System.out.println(Test.class.getAnnotation(Level.class).value());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", misconception: "int要素の既定値が0になると誤解", explanation: "アノテーション要素valueにはdefault 3が明示されています。"),
                choice("b", "3", correct: true, explanation: "@Levelで値を指定していないため、value()のdefault 3が使われます。"),
                choice("c", "null", misconception: "アノテーション要素がnullになると誤解", explanation: "int要素はプリミティブで、default 3が返ります。"),
                choice("d", "NullPointerException", misconception: "getAnnotationがnullになると誤解", explanation: "RUNTIME保持で@Levelが付いているため取得できます。"),
            ],
            intent: "カスタムアノテーションのdefault値と実行時取得を確認する。",
            steps: [
                step("Levelアノテーションのvalue要素にはdefault 3が指定されています。", [1, 2, 3], [variable("Level.value default", "int", "3", "annotation")]),
                step("Testには@Levelだけが付いており、valueは明示されていません。", [6, 7], [variable("annotation value", "int", "3", "reflection")]),
                step("getAnnotationで取得したLevelのvalue()を出力し、結果は3です。", [9], [variable("output", "String", "3", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-enum-constant-body-001",
            level: .gold,
            category: "classes",
            tags: ["模試専用", "enum", "constant-specific class body"],
            code: """
enum Op {
    PLUS {
        int apply(int a, int b) { return a + b; }
    },
    TIMES {
        int apply(int a, int b) { return a * b; }
    };
    abstract int apply(int a, int b);
}

public class Test {
    public static void main(String[] args) {
        System.out.println(Op.TIMES.apply(2, 3));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "5", misconception: "PLUSの実装が呼ばれると誤解", explanation: "呼び出している定数はTIMESです。"),
                choice("b", "6", correct: true, explanation: "TIMES定数固有のapplyが呼ばれ、2 * 3で6を返します。"),
                choice("c", "0", misconception: "abstractメソッドが既定値を返すと誤解", explanation: "各enum定数が具体実装を持っています。"),
                choice("d", "コンパイルエラー", misconception: "enum定数にクラス本体を書けないと誤解", explanation: "enum定数固有クラス本体で抽象メソッドを実装できます。"),
            ],
            intent: "enum定数固有クラス本体によるメソッド実装を確認する。",
            steps: [
                step("Opは抽象メソッドapplyを持つenumで、PLUSとTIMESがそれぞれ実装しています。", [1, 2, 5, 8], [variable("Op.TIMES.apply", "method", "multiplication", "enum")]),
                step("mainではOp.TIMES.apply(2, 3)を呼びます。", [13], [variable("arguments", "int,int", "2,3", "main")]),
                step("TIMESの実装はa*bなので6が出力されます。", [6, 13], [variable("output", "String", "6", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-record-equals-accessor-001",
            level: .gold,
            category: "classes",
            tags: ["模試専用", "record", "equals", "accessor"],
            code: """
record Point(int x, int y) {}

public class Test {
    public static void main(String[] args) {
        Point p1 = new Point(1, 2);
        Point p2 = new Point(1, 2);
        System.out.println(p1.equals(p2) + ":" + p1.x());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "false:1", misconception: "recordのequalsが参照比較だと誤解", explanation: "recordはコンポーネント値に基づくequalsを自動生成します。"),
                choice("b", "true:1", correct: true, explanation: "p1とp2は同じコンポーネント値なのでequalsはtrue、x()は1を返します。"),
                choice("c", "true:2", misconception: "x()が2番目の成分を返すと誤解", explanation: "x()はxコンポーネントのアクセサです。"),
                choice("d", "コンパイルエラー", misconception: "recordをトップレベルで定義できないと誤解", explanation: "非publicトップレベルrecordとして定義できます。"),
            ],
            intent: "recordの自動equalsとアクセサメソッドを確認する。",
            steps: [
                step("Point recordはxとyをコンポーネントに持ちます。", [1], [variable("Point components", "record", "x,y", "class")]),
                step("p1とp2はどちらもx=1,y=2なので、recordのequalsはtrueです。", [5, 6, 7], [variable("p1.equals(p2)", "boolean", "true", "main")]),
                step("p1.x()はxコンポーネント1を返し、出力は `true:1` です。", [7], [variable("output", "String", "true:1", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-sealed-permits-compile-001",
            level: .gold,
            difficulty: .tricky,
            validatedByJavac: false,
            category: "inheritance",
            tags: ["模試専用", "sealed", "permits", "compile"],
            code: """
sealed class Base permits Allowed {}
final class Allowed extends Base {}
final class Other extends Base {}

public class Test {
    public static void main(String[] args) {
        System.out.println("test");
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "test", misconception: "mainでOtherを使っていないので問題ないと誤解", explanation: "sealedの継承制約はクラス宣言時に検査されます。"),
                choice("b", "何も出力されない", misconception: "Otherだけ無視されると誤解", explanation: "不正なクラス宣言があるためコンパイルできません。"),
                choice("c", "コンパイルエラー", correct: true, explanation: "BaseのpermitsにOtherが含まれていないため、OtherはBaseを継承できません。"),
                choice("d", "ClassCastException", misconception: "sealed違反が実行時に発生すると誤解", explanation: "sealedの許可リスト違反はコンパイル時に検出されます。"),
            ],
            intent: "sealedクラスのpermitsにないクラスは直接継承できないことを確認する。",
            steps: [
                step("Baseはsealedで、permitsにはAllowedだけが指定されています。", [1], [variable("permitted subclasses", "class list", "Allowed", "Base")]),
                step("OtherもBaseをextendsしていますが、permitsに含まれていません。", [3], [variable("Other", "class", "not permitted", "compiler")]),
                step("許可されていない直接サブクラスなのでコンパイルエラーです。", [3], [variable("result", "compile", "error", "javac")]),
            ]
        ),
        q(
            "gold-mock-century-generics-extends-add-compile-001",
            level: .gold,
            difficulty: .tricky,
            validatedByJavac: false,
            category: "collections-generics",
            tags: ["模試専用", "generics", "wildcard", "extends", "compile"],
            code: """
public class Test {
    static void add(java.util.List<? extends Number> list) {
        list.add(1);
    }
    public static void main(String[] args) {
        add(new java.util.ArrayList<Integer>());
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "何も出力されず正常終了する", misconception: "Integerなら? extends Numberへ追加できると誤解", explanation: "実際のリスト型がIntegerとは限らないため、具体値の追加はできません。"),
                choice("b", "1", misconception: "addした値が出力されると誤解", explanation: "printlnはありませんし、そもそもコンパイルできません。"),
                choice("c", "コンパイルエラー", correct: true, explanation: "`List<? extends Number>` にはnull以外の具体的なNumber値を追加できません。"),
                choice("d", "ClassCastException", misconception: "ジェネリクス制約が実行時例外になると誤解", explanation: "不正なaddはコンパイル時に拒否されます。"),
            ],
            intent: "上限境界ワイルドカードのリストへ具体値を追加できないことを確認する。",
            steps: [
                step("引数型は `List<? extends Number>` で、Numberの何らかのサブタイプのリストを表します。", [2], [variable("list", "List<? extends Number>", "unknown subtype", "method")]),
                step("実体がList<Double>などの可能性もあるため、Integerの1を安全に追加できません。", [3], [variable("list.add(1)", "statement", "invalid", "compiler")]),
                step("そのためコンパイルエラーです。", [3], [variable("result", "compile", "error", "javac")]),
            ]
        ),
        q(
            "gold-mock-century-generics-super-read-001",
            level: .gold,
            difficulty: .tricky,
            category: "collections-generics",
            tags: ["模試専用", "generics", "wildcard", "super"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.util.List<? super Integer> list = new java.util.ArrayList<Number>();
        list.add(1);
        Object value = list.get(0);
        System.out.println(value.getClass().getSimpleName());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "Integer", correct: true, explanation: "? super IntegerにはIntegerを追加でき、getした値の実体はIntegerです。"),
                choice("b", "Number", misconception: "ArrayList<Number>に格納されるとNumberオブジェクトへ変換されると誤解", explanation: "IntegerオブジェクトはNumber型として保持できますが、実体クラスはIntegerのままです。"),
                choice("c", "Object", misconception: "getの変数型Objectが実体クラス名になると誤解", explanation: "getClassは実行時クラスを返します。"),
                choice("d", "コンパイルエラー", misconception: "? super Integerからgetできないと誤解", explanation: "getはできますが、型として安全に扱えるのはObjectです。"),
            ],
            intent: "下限境界ワイルドカードでは追加可能だが読み取り型はObjectになることを確認する。",
            steps: [
                step("listは `List<? super Integer>` なのでIntegerを追加できます。", [3, 4], [variable("stored value", "Integer", "1", "list")]),
                step("getの静的型はObjectですが、取り出した実体は追加したIntegerです。", [5], [variable("value", "Object", "Integer(1)", "main")]),
                step("getClass().getSimpleName()は実体クラス名Integerを返します。", [6], [variable("output", "String", "Integer", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-raw-list-classcast-001",
            level: .gold,
            difficulty: .tricky,
            category: "collections-generics",
            tags: ["模試専用", "raw type", "heap pollution", "ClassCastException"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.util.List<String> strings = new java.util.ArrayList<>();
        java.util.List raw = strings;
        raw.add(10);
        try {
            String s = strings.get(0);
            System.out.println(s);
        } catch (ClassCastException e) {
            System.out.println("CCE");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "10", misconception: "IntegerがStringへ自動変換されると誤解", explanation: "IntegerはStringへキャストできません。"),
                choice("b", "CCE", correct: true, explanation: "raw型経由でIntegerが入り、Stringとして取り出す時にClassCastExceptionが発生します。"),
                choice("c", "null", misconception: "不正な値がnullとして扱われると誤解", explanation: "格納されたIntegerはnullではなく、取り出し時のキャストで失敗します。"),
                choice("d", "コンパイルエラー", misconception: "raw型への代入が禁止されると誤解", explanation: "警告は出ますがコンパイルは可能です。"),
            ],
            intent: "raw型によるヒープ汚染と取り出し時ClassCastExceptionを確認する。",
            steps: [
                step("stringsはList<String>ですが、raw型参照rawにも代入されています。", [3, 4], [variable("raw", "List", "same list as strings", "main")]),
                step("raw.add(10)によりIntegerが実際のリストへ入ります。", [5], [variable("list contents", "List", "[10]", "heap")]),
                step("strings.get(0)はStringへのキャストを伴い、IntegerをStringにできないためCCEが出力されます。", [7, 9, 10], [variable("output", "String", "CCE", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-comparator-nullslast-001",
            level: .gold,
            category: "collections-generics",
            tags: ["模試専用", "Comparator", "nullsLast", "sort"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.util.List<String> list = new java.util.ArrayList<>(java.util.Arrays.asList("b", null, "a"));
        list.sort(java.util.Comparator.nullsLast(java.util.Comparator.naturalOrder()));
        System.out.println(list);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "[null, a, b]", misconception: "nullsFirstと混同している", explanation: "指定しているのはnullsLastです。"),
                choice("b", "[a, b, null]", correct: true, explanation: "null以外は自然順でa,bとなり、nullは最後に置かれます。"),
                choice("c", "[b, null, a]", misconception: "sortが元リストを変更しないと誤解", explanation: "List.sortはリスト自身を並べ替えます。"),
                choice("d", "NullPointerException", misconception: "naturalOrderがnullを必ず拒否すると誤解", explanation: "nullsLastでラップしているためnullを最後に扱えます。"),
            ],
            intent: "Comparator.nullsLastとList.sortの結果を確認する。",
            steps: [
                step("listはb, null, aの順です。", [3], [variable("list", "List<String>", "[b, null, a]", "main")]),
                step("Comparator.nullsLast(naturalOrder())により、非nullは自然順、nullは最後になります。", [4], [variable("list", "List<String>", "[a, b, null]", "main")]),
                step("並べ替え後のlistを出力し、結果は `[a, b, null]` です。", [5], [variable("output", "String", "[a, b, null]", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-optional-stream-001",
            level: .gold,
            category: "optional",
            tags: ["模試専用", "Optional", "stream", "map"],
            code: """
public class Test {
    public static void main(String[] args) {
        String value = java.util.Optional.of("A").stream()
                .map(s -> s + "B")
                .findFirst()
                .orElse("X");
        System.out.println(value);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", misconception: "mapの変換を見落としている", explanation: "Optional.stream後の1要素AはmapでABになります。"),
                choice("b", "AB", correct: true, explanation: "Optional.of(\"A\")のstreamは1要素を流し、mapでABに変換されます。"),
                choice("c", "X", misconception: "Optional.streamが空になると誤解", explanation: "値を持つOptionalなので1要素のStreamになります。"),
                choice("d", "コンパイルエラー", misconception: "Optionalにstreamメソッドがないと誤解", explanation: "Java 9以降、Optionalにはstreamメソッドがあります。"),
            ],
            intent: "Optional.streamで値を0または1要素のStreamとして扱えることを確認する。",
            steps: [
                step("Optional.of(\"A\") は値Aを持つOptionalです。streamにより1要素Streamになります。", [3], [variable("stream", "Stream<String>", "A", "pipeline")]),
                step("mapでAにBを連結し、ABになります。findFirstはABを返します。", [4, 5], [variable("value", "String", "AB", "main")]),
                step("orElseは使われず、ABが出力されます。", [6, 7], [variable("output", "String", "AB", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-pattern-instanceof-001",
            level: .gold,
            category: "classes",
            tags: ["模試専用", "pattern matching", "instanceof"],
            code: """
public class Test {
    public static void main(String[] args) {
        Object value = "java";
        if (value instanceof String s && s.length() > 3) {
            System.out.println(s.toUpperCase());
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "java", misconception: "toUpperCaseを見落としている", explanation: "条件成立後にs.toUpperCase()を出力しています。"),
                choice("b", "JAVA", correct: true, explanation: "valueはStringで長さ4なので条件が成立し、パターン変数sを使ってJAVAを出力します。"),
                choice("c", "何も出力されない", misconception: "s.length() > 3がfalseだと誤解", explanation: "javaの長さは4です。"),
                choice("d", "コンパイルエラー", misconception: "instanceofのパターン変数を使えないと誤解", explanation: "Java 17ではinstanceofパターンマッチングを利用できます。"),
            ],
            intent: "instanceofパターン変数のスコープと条件評価を確認する。",
            steps: [
                step("valueの実体はStringの `java` です。", [3], [variable("value", "Object", "String(\"java\")", "main")]),
                step("instanceof String s がtrueになり、右辺の `s.length() > 3` も4 > 3でtrueです。", [4], [variable("s", "String", "java", "if scope")]),
                step("if本体でs.toUpperCase()が実行され、`JAVA` が出力されます。", [5], [variable("output", "String", "JAVA", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-switch-expression-yield-001",
            level: .gold,
            category: "control-flow",
            tags: ["模試専用", "switch expression", "yield"],
            code: """
public class Test {
    public static void main(String[] args) {
        int n = 2;
        String result = switch (n) {
            case 1 -> "one";
            default -> {
                yield "many";
            }
        };
        System.out.println(result);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "one", misconception: "case 1が実行されると誤解", explanation: "nは2なのでcase 1には一致しません。"),
                choice("b", "many", correct: true, explanation: "defaultのブロックが実行され、yieldでswitch式の値manyを返します。"),
                choice("c", "2", misconception: "switch対象の値が出力されると誤解", explanation: "出力しているのはswitch式の結果文字列です。"),
                choice("d", "コンパイルエラー", misconception: "ブロック形式のswitch式でyieldを使えないと誤解", explanation: "ブロックから値を返すにはyieldを使います。"),
            ],
            intent: "switch式のブロックcaseでyieldにより値を返すことを確認する。",
            steps: [
                step("nは2です。switch式はcase 1に一致しません。", [3, 4, 5], [variable("n", "int", "2", "main")]),
                step("defaultブロックに入り、yield \"many\" によりswitch式の値がmanyになります。", [6, 7, 9], [variable("result", "String", "many", "main")]),
                step("resultを出力するため、出力は `many` です。", [10], [variable("output", "String", "many", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-jdbc-nosuitable-driver-001",
            level: .gold,
            category: "jdbc",
            tags: ["模試専用", "JDBC", "DriverManager", "SQLException"],
            code: """
public class Test {
    public static void main(String[] args) {
        try {
            java.sql.DriverManager.getConnection("jdbc:invalid:");
            System.out.println("OK");
        } catch (java.sql.SQLException e) {
            System.out.println("SQL");
        }
    }
}
""",
            question: "標準JDKのみでこのコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "OK", misconception: "無効URLでもConnectionが作られると誤解", explanation: "対応するJDBCドライバがないためSQLExceptionになります。"),
                choice("b", "SQL", correct: true, explanation: "jdbc:invalid: に対応するドライバが見つからず、SQLExceptionがcatchされます。"),
                choice("c", "ClassNotFoundException", misconception: "明示的なClass.forNameが必要だと誤解", explanation: "このコードでcatchしているのはgetConnectionからのSQLExceptionです。"),
                choice("d", "コンパイルエラー", misconception: "java.sqlを完全修飾名で使えないと誤解", explanation: "java.sql.DriverManagerは標準APIです。"),
            ],
            intent: "DriverManager.getConnectionが適切なドライバなしでSQLExceptionを投げることを確認する。",
            steps: [
                step("getConnectionに `jdbc:invalid:` というURLを渡しています。", [4], [variable("url", "String", "jdbc:invalid:", "main")]),
                step("標準JDKだけではこのURLに対応するドライバがないためSQLExceptionが発生します。", [4], [variable("result", "exception", "SQLException", "JDBC")]),
                step("catch節でSQLが出力されます。", [6, 7], [variable("output", "String", "SQL", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-sqlexception-chain-001",
            level: .gold,
            category: "jdbc",
            tags: ["模試専用", "SQLException", "getNextException"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.sql.SQLException first = new java.sql.SQLException("one");
        java.sql.SQLException second = new java.sql.SQLException("two");
        first.setNextException(second);
        System.out.println(first.getNextException().getMessage());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "one", misconception: "getNextExceptionが自分自身を返すと誤解", explanation: "getNextExceptionはsetNextExceptionでつないだ次の例外を返します。"),
                choice("b", "two", correct: true, explanation: "firstの次例外としてsecondを設定しているため、そのメッセージtwoが出力されます。"),
                choice("c", "null", misconception: "setNextExceptionが効かないと誤解", explanation: "secondが次例外として登録されています。"),
                choice("d", "SQLException", misconception: "クラス名が出力されると誤解", explanation: "getMessageを呼んでいるためメッセージ文字列が出力されます。"),
            ],
            intent: "SQLExceptionの例外チェーンを確認する。",
            steps: [
                step("firstはメッセージone、secondはメッセージtwoを持つSQLExceptionです。", [3, 4], [variable("first.message", "String", "one", "main"), variable("second.message", "String", "two", "main")]),
                step("first.setNextException(second)により、firstの次例外がsecondになります。", [5], [variable("first.next", "SQLException", "second", "main")]),
                step("次例外のメッセージを出力するため、結果は `two` です。", [6], [variable("output", "String", "two", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-serialization-transient-001",
            level: .gold,
            difficulty: .tricky,
            category: "io-nio",
            tags: ["模試専用", "serialization", "transient"],
            code: """
class User implements java.io.Serializable {
    String name = "A";
    transient int token = 7;
}

public class Test {
    public static void main(String[] args) throws Exception {
        User user = new User();
        java.io.ByteArrayOutputStream bytes = new java.io.ByteArrayOutputStream();
        try (java.io.ObjectOutputStream out = new java.io.ObjectOutputStream(bytes)) {
            out.writeObject(user);
        }
        try (java.io.ObjectInputStream in = new java.io.ObjectInputStream(new java.io.ByteArrayInputStream(bytes.toByteArray()))) {
            User copy = (User) in.readObject();
            System.out.println(copy.name + ":" + copy.token);
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A:7", misconception: "transientフィールドもシリアライズされると誤解", explanation: "transientフィールドtokenはシリアライズ対象外です。"),
                choice("b", "A:0", correct: true, explanation: "nameは復元されますが、transientなint tokenは既定値0になります。"),
                choice("c", "null:0", misconception: "すべてのフィールドが復元されないと誤解", explanation: "transientでないnameはシリアライズされます。"),
                choice("d", "NotSerializableException", misconception: "UserがSerializableでないと誤解", explanation: "UserはSerializableを実装しています。"),
            ],
            intent: "シリアライズ時にtransientフィールドが保存されないことを確認する。",
            steps: [
                step("UserはSerializableで、nameは通常フィールド、tokenはtransientです。", [1, 2, 3], [variable("user.name", "String", "A", "heap"), variable("user.token", "int", "7", "heap")]),
                step("writeObjectではtransientでないnameは保存されますが、tokenは保存されません。", [10, 11], [variable("serialized token", "int", "not stored", "serialization")]),
                step("readObject後のcopyではnameはA、tokenはintの既定値0となり、`A:0` が出力されます。", [13, 14, 15], [variable("output", "String", "A:0", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-objects-requirenonnullelse-001",
            level: .gold,
            category: "classes",
            tags: ["模試専用", "Objects", "requireNonNullElse"],
            code: """
public class Test {
    public static void main(String[] args) {
        String value = java.util.Objects.requireNonNullElse(null, "B");
        System.out.println(value);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "null", misconception: "第1引数がそのまま返ると誤解", explanation: "第1引数がnullの場合、第2引数のデフォルト値が返ります。"),
                choice("b", "B", correct: true, explanation: "第1引数がnullなので、非nullの第2引数Bが返されます。"),
                choice("c", "Optional[B]", misconception: "Optionalを返すAPIと混同", explanation: "requireNonNullElseは直接値を返します。"),
                choice("d", "NullPointerException", misconception: "第1引数がnullなら必ず例外になると誤解", explanation: "第2引数が非nullなので例外ではなくBが返ります。"),
            ],
            intent: "Objects.requireNonNullElseのnull時デフォルト値を確認する。",
            steps: [
                step("第1引数はnull、第2引数は文字列Bです。", [3], [variable("primary", "String", "null", "main"), variable("default", "String", "B", "main")]),
                step("requireNonNullElseは第1引数がnullなら第2引数を返します。", [3], [variable("value", "String", "B", "main")]),
                step("valueを出力するため、結果は `B` です。", [4], [variable("output", "String", "B", "stdout")]),
            ]
        ),
        q(
            "gold-mock-century-localdate-minusmonths-leap-001",
            level: .gold,
            category: "date-time",
            tags: ["模試専用", "LocalDate", "minusMonths", "leap year"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.time.LocalDate date = java.time.LocalDate.of(2024, 3, 31);
        System.out.println(date.minusMonths(1));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2024-02-29", correct: true, explanation: "2024年2月には31日がないため、うるう年の月末2月29日に調整されます。"),
                choice("b", "2024-02-28", misconception: "2024年を平年として扱っている", explanation: "2024年はうるう年です。"),
                choice("c", "2024-03-02", misconception: "差分日数として単純計算している", explanation: "minusMonthsは月単位の操作で、結果月の有効な日へ調整します。"),
                choice("d", "DateTimeException", misconception: "存在しない日付で例外になると誤解", explanation: "LocalDateは月末へ調整します。"),
            ],
            intent: "LocalDate.minusMonthsの月末調整とうるう年を確認する。",
            steps: [
                step("dateは2024-03-31です。", [3], [variable("date", "LocalDate", "2024-03-31", "main")]),
                step("1か月戻すと2024年2月ですが、2月31日は存在しません。2024年2月の月末は29日です。", [4], [variable("adjusted date", "LocalDate", "2024-02-29", "calculation")]),
                step("出力は `2024-02-29` です。", [4], [variable("output", "String", "2024-02-29", "stdout")]),
            ]
        ),
    ]

    static func q(
        _ id: String,
        level: JavaLevel,
        difficulty: QuizDifficulty = .tricky,
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
            level: level,
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

extension MockCenturyQuestionData.Spec {
    var quiz: Quiz {
        Quiz(
            id: id,
            level: level,
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
    static let silverMockCenturyExpansion: [Quiz] = MockCenturyQuestionData.silverSpecs.map(\.quiz)
    static let goldMockCenturyExpansion: [Quiz] = MockCenturyQuestionData.goldSpecs.map(\.quiz)
}
