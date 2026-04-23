import Foundation

enum SilverFinalPushQuestionData {
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
        let isMockExamOnly: Bool
        let category: String
        let tags: [String]
        let code: String
        let question: String
        let choices: [ChoiceSpec]
        let explanationRef: String
        let designIntent: String
        let steps: [StepSpec]
    }

    static let practiceSpecs: [Spec] = [
        q(
            "silver-finalpush-string-constant-concat-001",
            category: "strings",
            tags: ["String", "final", "compile-time constant", "=="],
            code: """
public class Test {
    public static void main(String[] args) {
        final String a = "Ja";
        final String b = "va";
        String c = "Java";
        System.out.println((a + b) == c);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", correct: true, explanation: "finalな文字列定数同士の連結はコンパイル時定数になり、文字列リテラルと同じ参照を使います。"),
                choice("b", "false", misconception: "連結は必ず新しいStringを作ると誤解", explanation: "変数がfinalで値もコンパイル時定数なので、今回は実行時連結ではありません。"),
                choice("c", "Java", misconception: "比較結果ではなく連結結果が出力されると誤解", explanation: "printlnしているのは `(a + b) == c` のboolean値です。"),
                choice("d", "コンパイルエラー", misconception: "String同士を==で比較できないと誤解", explanation: "参照比較としてコンパイル可能です。"),
            ],
            intent: "finalなString定数の連結とStringプール、参照比較の関係を確認する。",
            steps: [
                step("aとbはfinalで、右辺も文字列リテラルなのでコンパイル時定数です。", [3, 4], [variable("a", "String", "Ja", "main"), variable("b", "String", "va", "main")]),
                step("`a + b` はコンパイル時に `Java` として扱われ、Stringプール上の同じリテラルを参照します。", [6], [variable("a + b", "String", "Java / pooled", "expression")]),
                step("cも文字列リテラル `Java` を参照するため、参照比較はtrueです。", [5, 6], [variable("output", "String", "true", "stdout")]),
            ]
        ),
        q(
            "silver-finalpush-stringbuilder-delete-insert-001",
            category: "strings",
            tags: ["StringBuilder", "delete", "insert"],
            code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("abcd");
        sb.delete(1, 3);
        sb.insert(1, "XY");
        System.out.println(sb);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "aXYd", correct: true, explanation: "`delete(1, 3)` は1以上3未満を削除し、その後インデックス1へXYを挿入します。"),
                choice("b", "aXYcd", misconception: "deleteの終了位置を含まないことは理解しているが、削除範囲を1文字だけと誤解", explanation: "`delete(1, 3)` ではインデックス1と2のb,cが削除されます。"),
                choice("c", "abXYd", misconception: "insert位置を削除前の文字列で考えている", explanation: "insertはdelete後の `ad` に対して実行されます。"),
                choice("d", "aXY", misconception: "deleteの終了位置を末尾までと誤解", explanation: "終了位置3は含まれないため、dは残ります。"),
            ],
            intent: "StringBuilderの破壊的変更とdeleteの範囲指定を確認する。",
            steps: [
                step("sbは最初 `abcd` です。", [3], [variable("sb", "StringBuilder", "abcd", "main")]),
                step("`delete(1, 3)` はインデックス1のbから2のcまでを削除し、sbは `ad` になります。", [4], [variable("sb", "StringBuilder", "ad", "main")]),
                step("`insert(1, \"XY\")` でaとdの間にXYが入り、出力は `aXYd` です。", [5, 6], [variable("output", "String", "aXYd", "stdout")]),
            ]
        ),
        q(
            "silver-finalpush-jagged-array-null-001",
            category: "arrays",
            tags: ["array", "jagged array", "default value"],
            code: """
public class Test {
    public static void main(String[] args) {
        int[][] nums = new int[2][];
        nums[0] = new int[] { 1, 2 };
        System.out.println(nums.length + ":" + nums[0][1] + ":" + nums[1]);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2:2:null", correct: true, explanation: "外側配列の長さは2、nums[0][1]は2、未代入のnums[1]はnullです。"),
                choice("b", "2:2:0", misconception: "内側配列も自動生成されると誤解", explanation: "`new int[2][]` では内側配列参照の初期値はnullです。"),
                choice("c", "2:1:null", misconception: "配列インデックスを1始まりで考えている", explanation: "`nums[0][1]` はnums[0]の2番目の要素なので2です。"),
                choice("d", "NullPointerException", misconception: "nums[1]を連結するだけでも参照先へアクセスすると誤解", explanation: "null参照そのものを文字列連結すると `null` と表示されます。"),
            ],
            intent: "ジャグ配列の初期値と文字列連結時のnull表示を確認する。",
            steps: [
                step("`new int[2][]` は外側配列だけを作り、各要素はint配列への参照です。初期値はnullです。", [3], [variable("nums.length", "int", "2", "main"), variable("nums[1]", "int[]", "null", "main")]),
                step("nums[0]には長さ2のint配列が代入され、nums[0][1]は2です。", [4, 5], [variable("nums[0][1]", "int", "2", "main")]),
                step("文字列連結ではnums[1]のnullが文字列 `null` になり、出力は `2:2:null` です。", [5], [variable("output", "String", "2:2:null", "stdout")]),
            ]
        ),
        q(
            "silver-finalpush-labelled-continue-001",
            difficulty: .tricky,
            category: "control-flow",
            tags: ["for", "label", "continue"],
            code: """
public class Test {
    public static void main(String[] args) {
        outer:
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                if (i + j == 2) continue outer;
                System.out.print(i + ":" + j + "|");
            }
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0:0|0:1|1:0|", correct: true, explanation: "i+jが2になった時点で外側ループの次回へ進むため、この3回だけ出力されます。"),
                choice("b", "0:0|0:1|0:2|1:0|", misconception: "continue前に出力されると誤解", explanation: "if文がprintより先なので、i=0,j=2では出力せず外側ループへ戻ります。"),
                choice("c", "0:0|0:1|1:0|2:0|", misconception: "i=2,j=0でも出力されると誤解", explanation: "i=2,j=0ではi+jが2なので、print前にcontinue outerします。"),
                choice("d", "0:0|0:1|", misconception: "i=1の内側ループ開始直後にスキップすると誤解", explanation: "i=1,j=0ではi+jは1なので出力されます。"),
            ],
            intent: "ラベル付きcontinueが外側ループの次の反復へ移ることを確認する。",
            steps: [
                step("i=0ではj=0とj=1で条件がfalseになり、`0:0|0:1|` を出力します。", [4, 5, 7], [variable("partial output", "String", "0:0|0:1|", "stdout")]),
                step("i=0,j=2でi+jが2になり、`continue outer` によりi=1へ進みます。", [6], [variable("i,j", "int,int", "0,2", "loop")]),
                step("i=1,j=0は出力され、i=1,j=1で再び外側へ。i=2,j=0は即continueなので追加出力はありません。", [4, 5, 6, 7], [variable("output", "String", "0:0|0:1|1:0|", "stdout")]),
            ]
        ),
        q(
            "silver-finalpush-switch-expression-arrow-001",
            category: "control-flow",
            tags: ["switch expression", "arrow", "case label"],
            code: """
public class Test {
    public static void main(String[] args) {
        int score = 2;
        String rank = switch (score) {
            case 1 -> "A";
            case 2, 3 -> "B";
            default -> "C";
        };
        System.out.println(rank);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", misconception: "case 1からフォールスルーすると誤解", explanation: "アロー形式のswitchラベルではフォールスルーしません。"),
                choice("b", "B", correct: true, explanation: "scoreは2なので `case 2, 3` が選ばれ、rankはBになります。"),
                choice("c", "C", misconception: "複数ラベルのcaseが使えないと誤解", explanation: "Java 17のswitch式では `case 2, 3 ->` のような複数ラベルを使えます。"),
                choice("d", "コンパイルエラー", misconception: "switch式そのものを使えないと誤解", explanation: "Java 17ではswitch式とアローラベルを利用できます。"),
            ],
            intent: "switch式のアロー形式と複数caseラベルを確認する。",
            steps: [
                step("scoreには2が代入されています。", [3], [variable("score", "int", "2", "main")]),
                step("switch式は `case 2, 3` に一致し、式の値として `B` を返します。", [4, 6, 8], [variable("rank", "String", "B", "main")]),
                step("rankを出力するため、結果は `B` です。", [9], [variable("output", "String", "B", "stdout")]),
            ]
        ),
        q(
            "silver-finalpush-overload-widening-boxing-001",
            difficulty: .tricky,
            category: "overload-resolution",
            tags: ["overload", "widening", "boxing"],
            code: """
public class Test {
    static void call(long value) {
        System.out.println("long");
    }
    static void call(Integer value) {
        System.out.println("Integer");
    }
    public static void main(String[] args) {
        call(10);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "long", correct: true, explanation: "int実引数はlongへ拡大変換でき、拡大変換はボクシングより優先されます。"),
                choice("b", "Integer", misconception: "intはIntegerへ自動的に包まれる方が優先されると誤解", explanation: "オーバーロード解決では、拡大変換の方がボクシングより優先されます。"),
                choice("c", "コンパイルエラー", misconception: "候補が2つあると常に曖昧になると誤解", explanation: "優先順位によりlong版が選べます。"),
                choice("d", "実行時例外", misconception: "オーバーロード解決を実行時処理と混同", explanation: "オーバーロードはコンパイル時に決まります。"),
            ],
            intent: "オーバーロード解決で拡大変換がボクシングより優先されることを確認する。",
            steps: [
                step("実引数10の型はintです。", [9], [variable("argument", "int", "10", "main")]),
                step("候補はlong版とInteger版です。intからlongへは拡大変換、intからIntegerへはボクシングです。", [2, 5, 9], [variable("selected overload", "method", "call(long)", "compiler")]),
                step("拡大変換が優先されるため、`long` と出力されます。", [3], [variable("output", "String", "long", "stdout")]),
            ]
        ),
        q(
            "silver-finalpush-overload-boxing-varargs-001",
            difficulty: .tricky,
            category: "overload-resolution",
            tags: ["overload", "boxing", "varargs"],
            code: """
public class Test {
    static void call(Integer value) {
        System.out.println("Integer");
    }
    static void call(int... values) {
        System.out.println("varargs");
    }
    public static void main(String[] args) {
        call(1);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "Integer", correct: true, explanation: "固定引数のボクシング候補が、可変長引数より優先されます。"),
                choice("b", "varargs", misconception: "intのまま渡せる可変長引数が最優先だと誤解", explanation: "可変長引数は最後の段階で検討されます。"),
                choice("c", "コンパイルエラー", misconception: "Integer版とint...版が曖昧になると誤解", explanation: "優先順位によりInteger版が選ばれます。"),
                choice("d", "1", misconception: "引数の値が直接出力されると誤解", explanation: "各メソッドは固定文字列を出力します。"),
            ],
            intent: "ボクシングと可変長引数が競合したときの優先順位を確認する。",
            steps: [
                step("`call(1)` の実引数はintです。", [9], [variable("argument", "int", "1", "main")]),
                step("Integer版はボクシングで呼び出せ、int...版は可変長引数として呼び出せます。", [2, 5, 9], [variable("selected overload", "method", "call(Integer)", "compiler")]),
                step("固定引数のボクシングが可変長引数より先に選ばれるため、出力は `Integer` です。", [3], [variable("output", "String", "Integer", "stdout")]),
            ]
        ),
        q(
            "silver-finalpush-initializer-order-field-001",
            difficulty: .tricky,
            category: "classes",
            tags: ["initializer", "field initializer", "constructor"],
            code: """
public class Test {
    int x = print("A", 1);
    {
        x = print("B", 2);
    }
    Test() {
        print("C", x);
    }
    static int print(String label, int value) {
        System.out.print(label + value);
        return value;
    }
    public static void main(String[] args) {
        new Test();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A1B2C2", correct: true, explanation: "フィールド初期化、インスタンス初期化ブロック、コンストラクタ本体の順に実行されます。"),
                choice("b", "B2A1C1", misconception: "インスタンス初期化ブロックがフィールド初期化より先だと誤解", explanation: "同一クラス内ではソースコード上の初期化順に従います。"),
                choice("c", "C0A1B2", misconception: "コンストラクタ本体が最初に実行されると誤解", explanation: "コンストラクタ本体の前にフィールド初期化とインスタンス初期化ブロックが実行されます。"),
                choice("d", "A1C1B2", misconception: "コンストラクタ本体がブロックより先だと誤解", explanation: "インスタンス初期化ブロックはコンストラクタ本体より先です。"),
            ],
            intent: "フィールド初期化、初期化ブロック、コンストラクタ本体の順序を確認する。",
            steps: [
                step("new Test()でインスタンス生成が始まり、まずフィールドxの初期化で `A1` が出力されます。", [2, 14], [variable("x", "int", "1", "instance"), variable("partial output", "String", "A1", "stdout")]),
                step("次にインスタンス初期化ブロックが実行され、xは2へ更新され `B2` が続きます。", [3, 4], [variable("x", "int", "2", "instance"), variable("partial output", "String", "A1B2", "stdout")]),
                step("最後にコンストラクタ本体がx=2を使って `C2` を出力します。", [6, 7], [variable("output", "String", "A1B2C2", "stdout")]),
            ]
        ),
        q(
            "silver-finalpush-field-hiding-polymorphism-001",
            difficulty: .tricky,
            category: "inheritance",
            tags: ["field hiding", "override", "polymorphism"],
            code: """
class Parent {
    int value = 1;
    int get() { return value; }
}

class Child extends Parent {
    int value = 2;
    int get() { return value; }
}

public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        System.out.println(p.value + ":" + p.get());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1:1", misconception: "メソッド呼び出しも参照型だけで決まると誤解", explanation: "オーバーライドされたインスタンスメソッドは実行時のオブジェクト型で決まります。"),
                choice("b", "1:2", correct: true, explanation: "フィールド参照は参照型Parentで決まり、get()はChild版が呼ばれます。"),
                choice("c", "2:2", misconception: "フィールドもポリモーフィックに解決されると誤解", explanation: "フィールドは隠蔽であり、参照型に基づいて解決されます。"),
                choice("d", "コンパイルエラー", misconception: "Parent型変数にChildを代入できないと誤解", explanation: "継承関係があるため、Parent型参照でChildインスタンスを保持できます。"),
            ],
            intent: "フィールド隠蔽とメソッドオーバーライドの解決タイミングの違いを確認する。",
            steps: [
                step("pの参照型はParentですが、実体はChildです。", [13], [variable("p", "Parent", "Child instance", "main")]),
                step("`p.value` はフィールド参照なので参照型Parentに基づき、Parent.valueの1になります。", [14], [variable("p.value", "int", "1", "main")]),
                step("`p.get()` はオーバーライドされたインスタンスメソッドなのでChild版が呼ばれ、Child.valueの2を返します。", [8, 14], [variable("output", "String", "1:2", "stdout")]),
            ]
        ),
        q(
            "silver-finalpush-interface-default-conflict-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "inheritance",
            tags: ["interface", "default method", "compile"],
            code: """
interface A {
    default void run() {}
}

interface B {
    default void run() {}
}

class C implements A, B {
}

public class Test {
    public static void main(String[] args) {
        new C().run();
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "何も出力されず正常終了する", misconception: "同じ実装なら衝突しないと誤解", explanation: "AとBは別々のdefaultメソッドを提供しているため、Cで解決が必要です。"),
                choice("b", "Aのrunが呼ばれる", misconception: "先にimplementsしたインターフェースが優先されると誤解", explanation: "implementsの記述順ではdefaultメソッド衝突は解決されません。"),
                choice("c", "Bのrunが呼ばれる", misconception: "後にimplementsしたインターフェースが優先されると誤解", explanation: "どちらも自動的には選ばれません。"),
                choice("d", "コンパイルエラー", correct: true, explanation: "CはAとBのrunの衝突を解決するため、自分でrunをオーバーライドする必要があります。"),
            ],
            intent: "複数インターフェースのdefaultメソッド衝突がコンパイルエラーになることを確認する。",
            steps: [
                step("AとBはいずれも同じシグネチャのdefaultメソッドrunを持ちます。", [1, 2, 5, 6], [variable("A.run", "default method", "exists", "interface"), variable("B.run", "default method", "exists", "interface")]),
                step("CはAとBを同時にimplementsしていますが、runをオーバーライドしていません。", [9, 10], [variable("C.run", "method", "not declared", "class")]),
                step("コンパイラはどちらのdefaultを継承するか決められないため、コンパイルエラーです。", [14], [variable("result", "compile", "error", "javac")]),
            ]
        ),
        q(
            "silver-finalpush-catch-order-compile-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "exceptions",
            tags: ["catch", "exception hierarchy", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        try {
            throw new RuntimeException();
        } catch (Exception e) { // subtype catch below is unreachable
            System.out.println("E");
        } catch (RuntimeException e) {
            System.out.println("R");
        }
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "E", misconception: "先のcatchに入るから問題ないと誤解", explanation: "後続のRuntimeException catchが到達不能になるため、コンパイルできません。"),
                choice("b", "R", misconception: "より具体的なcatchが実行時に優先されると誤解", explanation: "catchは上から順に検査されるため、より広いExceptionを先に置けません。"),
                choice("c", "コンパイルエラー", correct: true, explanation: "ExceptionのcatchがRuntimeExceptionも捕捉するため、後ろのRuntimeException catchは到達不能です。"),
                choice("d", "RuntimeExceptionがそのまま送出される", misconception: "catch順序を無視して例外が外へ出ると誤解", explanation: "そもそもコンパイルエラーなので実行されません。"),
            ],
            intent: "catchブロックは具体的な例外型から順に書く必要があることを確認する。",
            steps: [
                step("RuntimeExceptionはExceptionのサブクラスです。", [4, 5, 7], [variable("RuntimeException", "class", "subclass of Exception", "type system")]),
                step("先に `catch (Exception e)` があるため、RuntimeExceptionもそこで捕捉されます。", [5], [variable("first catch", "Exception", "covers RuntimeException", "compiler")]),
                step("後ろの `catch (RuntimeException e)` は到達不能となり、コンパイルエラーです。", [7], [variable("result", "compile", "error", "javac")]),
            ]
        ),
        q(
            "silver-finalpush-finally-after-return-001",
            category: "exceptions",
            tags: ["try-finally", "return", "flow"],
            code: """
public class Test {
    static void run() {
        try {
            System.out.print("T");
            return;
        } finally {
            System.out.print("F");
        }
    }
    public static void main(String[] args) {
        run();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "T", misconception: "returnでfinallyが実行されないと誤解", explanation: "tryからreturnする場合でもfinallyは実行されます。"),
                choice("b", "F", misconception: "finallyだけが実行されると誤解", explanation: "tryブロックのprintが先に実行されます。"),
                choice("c", "TF", correct: true, explanation: "tryでTを出力してreturnしようとした後、finallyでFを出力してから戻ります。"),
                choice("d", "FT", misconception: "finallyがtryより先に実行されると誤解", explanation: "finallyはtryブロックの後に実行されます。"),
            ],
            intent: "tryブロック内のreturn前後でもfinallyが必ず実行されることを確認する。",
            steps: [
                step("mainからrunが呼ばれ、tryブロックに入ります。", [10, 11, 3], [variable("call stack", "stack", "main -> run", "runtime")]),
                step("try内で `T` を出力し、returnしようとします。", [4, 5], [variable("partial output", "String", "T", "stdout")]),
                step("メソッドから戻る前にfinallyが実行され、`F` が追加されます。", [6, 7], [variable("output", "String", "TF", "stdout")]),
            ]
        ),
        q(
            "silver-finalpush-arraylist-remove-overloads-001",
            difficulty: .tricky,
            category: "collections",
            tags: ["ArrayList", "remove", "overload"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.util.ArrayList<Integer> list = new java.util.ArrayList<>(java.util.List.of(1, 2, 3));
        list.remove(1);
        list.remove(Integer.valueOf(3));
        System.out.println(list);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "[1]", correct: true, explanation: "remove(1)はインデックス1の要素2を削除し、Integer.valueOf(3)は要素3を削除します。"),
                choice("b", "[2]", misconception: "最初のremove(1)を要素1の削除と誤解", explanation: "int引数では `remove(int index)` が選ばれます。"),
                choice("c", "[1, 3]", misconception: "2回目の削除が失敗すると誤解", explanation: "Integerオブジェクトを渡すと `remove(Object)` として要素3が削除されます。"),
                choice("d", "IndexOutOfBoundsException", misconception: "2回目もインデックス3削除だと誤解", explanation: "2回目はIntegerオブジェクトなのでインデックスではなく要素として扱われます。"),
            ],
            intent: "ArrayListのremove(int)とremove(Object)のオーバーロードを確認する。",
            steps: [
                step("listは最初 `[1, 2, 3]` です。", [3], [variable("list", "ArrayList<Integer>", "[1, 2, 3]", "main")]),
                step("`list.remove(1)` はintなのでインデックス1の要素2を削除し、listは `[1, 3]` になります。", [4], [variable("list", "ArrayList<Integer>", "[1, 3]", "main")]),
                step("`Integer.valueOf(3)` を渡すとremove(Object)が使われ、要素3が削除されて `[1]` です。", [5, 6], [variable("output", "String", "[1]", "stdout")]),
            ]
        ),
        q(
            "silver-finalpush-localdate-plusmonths-001",
            category: "data-types",
            tags: ["LocalDate", "plusMonths", "month end"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.time.LocalDate date = java.time.LocalDate.of(2023, 1, 31);
        System.out.println(date.plusMonths(1));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2023-02-28", correct: true, explanation: "2023年2月には31日がないため、月末日の2月28日に調整されます。"),
                choice("b", "2023-03-03", misconception: "存在しない日数分を翌月へ繰り越すと誤解", explanation: "LocalDate.plusMonthsは月末を有効な日付に調整します。"),
                choice("c", "2023-02-31", misconception: "存在しない日付でも保持できると誤解", explanation: "LocalDateは有効な日付だけを表します。"),
                choice("d", "DateTimeException", misconception: "月末調整が行われず例外になると誤解", explanation: "plusMonthsは結果月に合わせて日を調整します。"),
            ],
            intent: "LocalDate.plusMonthsの月末調整を確認する。",
            steps: [
                step("dateは2023年1月31日です。", [3], [variable("date", "LocalDate", "2023-01-31", "main")]),
                step("1か月加算すると2023年2月になりますが、2023年2月31日は存在しません。", [4], [variable("candidate", "LocalDate", "2023-02-31 invalid", "calculation")]),
                step("LocalDateは有効な月末日へ調整し、出力は `2023-02-28` です。", [4], [variable("output", "String", "2023-02-28", "stdout")]),
            ]
        ),
        q(
            "silver-finalpush-interface-static-call-001",
            category: "classes",
            tags: ["interface", "static method", "method call"],
            code: """
interface Tool {
    static String name() {
        return "Tool";
    }
}

public class Test {
    public static void main(String[] args) {
        System.out.println(Tool.name());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "Tool", correct: true, explanation: "インターフェースのstaticメソッドはインターフェース名で呼び出します。"),
                choice("b", "null", misconception: "staticメソッドにインスタンスが必要だと誤解", explanation: "staticメソッドは型に属するため、インスタンスなしで呼び出せます。"),
                choice("c", "コンパイルエラー", misconception: "インターフェースにstaticメソッドを書けないと誤解", explanation: "Javaではインターフェースにstaticメソッドを定義できます。"),
                choice("d", "実行時例外", misconception: "インターフェースのstatic呼び出しを実行時解決と混同", explanation: "型名で直接呼び出される通常のstatic呼び出しです。"),
            ],
            intent: "インターフェースstaticメソッドの定義と呼び出し方を確認する。",
            steps: [
                step("Toolにはstaticメソッドnameが定義されています。", [1, 2, 4], [variable("Tool.name", "static method", "returns Tool", "interface")]),
                step("mainではインターフェース名 `Tool` を使ってstaticメソッドを呼び出しています。", [8, 9], [variable("Tool.name()", "String", "Tool", "main")]),
                step("戻り値がprintlnへ渡され、出力は `Tool` です。", [9], [variable("output", "String", "Tool", "stdout")]),
            ]
        ),
        q(
            "silver-finalpush-do-while-once-001",
            category: "control-flow",
            tags: ["do-while", "post-increment", "loop"],
            code: """
public class Test {
    public static void main(String[] args) {
        int i = 0;
        do {
            System.out.print(i++);
        } while (i < 0);
        System.out.println(":" + i);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0:1", correct: true, explanation: "doブロックは条件判定前に1回実行され、i++で0を出力してからiは1になります。"),
                choice("b", ":0", misconception: "while条件がfalseならdo本体も実行されないと誤解", explanation: "do-whileは少なくとも1回本体を実行します。"),
                choice("c", "1:1", misconception: "後置インクリメントの出力値を誤解", explanation: "`i++` は現在値0を出力してから1へ増やします。"),
                choice("d", "0:0", misconception: "i++で変数が更新されないと誤解", explanation: "後置でも式の評価後にiは1へ増えます。"),
            ],
            intent: "do-whileの最低1回実行と後置インクリメントを確認する。",
            steps: [
                step("iは0で開始します。", [3], [variable("i", "int", "0", "main")]),
                step("do本体は条件判定より先に実行されます。`i++` は0を出力し、その後iは1になります。", [4, 5], [variable("partial output", "String", "0", "stdout"), variable("i", "int", "1", "main")]),
                step("while条件 `i < 0` はfalseなのでループは終了し、`:1` が追加されます。", [6, 7], [variable("output", "String", "0:1", "stdout")]),
            ]
        ),
    ]

    static let mockSpecs: [Spec] = [
        q(
            "silver-mock-finalpush-ternary-wrapper-promotion-001",
            difficulty: .tricky,
            isMockExamOnly: true,
            category: "data-types",
            tags: ["模試専用", "ternary", "boxing", "numeric promotion"],
            code: """
public class Test {
    public static void main(String[] args) {
        Object value = true ? Integer.valueOf(1) : Double.valueOf(2.0);
        System.out.println(value.getClass().getSimpleName() + ":" + value);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "Integer:1", misconception: "条件がtrueなのでIntegerのまま残ると誤解", explanation: "条件演算子は第2・第3オペランドの型から全体の型を決めます。"),
                choice("b", "Double:1.0", correct: true, explanation: "IntegerとDoubleは数値条件式として扱われ、unbox後にdoubleへ昇格し、Doubleとして保持されます。"),
                choice("c", "Object:1", misconception: "左辺のObject型が実体の型名になると誤解", explanation: "getClassは実行時オブジェクトのクラスを返します。"),
                choice("d", "コンパイルエラー", misconception: "IntegerとDoubleを条件演算子で混在できないと誤解", explanation: "数値条件式として型が決定されるためコンパイル可能です。"),
            ],
            intent: "条件演算子におけるラッパー型のunboxingと数値昇格を確認する。",
            steps: [
                step("条件はtrueですが、条件演算子の型決定ではInteger側とDouble側の両方が考慮されます。", [3], [variable("condition", "boolean", "true", "main")]),
                step("IntegerとDoubleはunboxingされ、数値昇格により全体はdouble型相当になります。true側の1も1.0になります。", [3], [variable("value", "Double", "1.0", "main")]),
                step("Object変数にはDoubleインスタンスが入り、出力は `Double:1.0` です。", [4], [variable("output", "String", "Double:1.0", "stdout")]),
            ]
        ),
        q(
            "silver-mock-finalpush-lambda-overload-callable-001",
            difficulty: .tricky,
            isMockExamOnly: true,
            category: "lambda",
            tags: ["模試専用", "lambda", "overload", "Callable"],
            code: """
public class Test {
    static void run(Runnable r) {
        System.out.println("R");
    }
    static void run(java.util.concurrent.Callable<Integer> c) {
        try {
            System.out.println("C" + c.call());
        } catch (Exception e) {
            System.out.println("E");
        }
    }
    public static void main(String[] args) {
        run(() -> 1);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "R", misconception: "引数なしラムダはRunnableが優先されると誤解", explanation: "`() -> 1` は値を返すラムダなのでRunnableのvoidメソッドには適合しません。"),
                choice("b", "C1", correct: true, explanation: "ラムダはIntegerを返すCallableに適合し、callの戻り値1が出力されます。"),
                choice("c", "E", misconception: "Callable.callはthrowsがあるので必ず例外になると誤解", explanation: "ラムダ本体は1を返すだけで例外を投げません。"),
                choice("d", "コンパイルエラー", misconception: "RunnableとCallableで曖昧になると誤解", explanation: "このラムダは値互換であり、Callable側だけに適合します。"),
            ],
            intent: "戻り値を持つラムダがvoid関数型インターフェースに適合しないケースを確認する。",
            steps: [
                step("`run` にはRunnable版とCallable版があります。", [2, 5], [variable("overloads", "method set", "Runnable / Callable", "compiler")]),
                step("`()->1` は値を返す式ラムダです。数値リテラルだけの式はvoid互換ではないため、Runnableには適合しません。", [13], [variable("selected overload", "method", "run(Callable<Integer>)", "compiler")]),
                step("Callable.callが1を返し、`C` と連結されて `C1` が出力されます。", [6, 7], [variable("output", "String", "C1", "stdout")]),
            ]
        ),
        q(
            "silver-mock-finalpush-string-switch-null-001",
            difficulty: .tricky,
            isMockExamOnly: true,
            category: "control-flow",
            tags: ["模試専用", "switch", "String", "null"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = null;
        try {
            switch (s) {
                default:
                    System.out.println("default");
            }
        } catch (NullPointerException e) {
            System.out.println("NPE");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "default", misconception: "nullはdefaultに流れると誤解", explanation: "通常のString switchではnull値を評価しようとしてNullPointerExceptionになります。"),
                choice("b", "何も出力されず正常終了する", misconception: "switch対象がnullなら分岐しないと誤解", explanation: "switchの評価時点で例外が発生します。"),
                choice("c", "NPE", correct: true, explanation: "switch対象のStringがnullなのでNullPointerExceptionが発生し、catchでNPEが出力されます。"),
                choice("d", "コンパイルエラー", misconception: "Stringをswitchに使えないと誤解", explanation: "Stringのswitch自体は有効です。null実行時値が問題です。"),
            ],
            intent: "String switchの対象がnullの場合、defaultではなくNullPointerExceptionになることを確認する。",
            steps: [
                step("sにはnullが代入されています。", [3], [variable("s", "String", "null", "main")]),
                step("try内でswitchはsの値を評価して分岐先を決めようとします。", [4, 5], [variable("switch target", "String", "null", "runtime")]),
                step("nullに対するString switch評価でNullPointerExceptionが発生し、defaultのprintlnには到達しません。catchで `NPE` が出力されます。", [5, 7, 9, 10], [variable("output", "String", "NPE", "stdout")]),
            ]
        ),
        q(
            "silver-mock-finalpush-arrays-aslist-fixed-001",
            difficulty: .tricky,
            isMockExamOnly: true,
            category: "collections",
            tags: ["模試専用", "Arrays.asList", "UnsupportedOperationException"],
            code: """
public class Test {
    public static void main(String[] args) {
        java.util.List<String> list = java.util.Arrays.asList("A", "B");
        list.set(1, "X");
        try {
            list.add("Y");
            System.out.println(list);
        } catch (UnsupportedOperationException e) {
            System.out.println(list);
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "[A, X]", correct: true, explanation: "Arrays.asListのリストは要素の置換は可能ですが、サイズ変更のaddはUnsupportedOperationExceptionになります。"),
                choice("b", "[A, X, Y]", misconception: "addも通常のArrayListと同じく可能だと誤解", explanation: "Arrays.asListは固定サイズのリストを返します。"),
                choice("c", "[A, B]", misconception: "setも失敗すると誤解", explanation: "固定サイズでも既存要素の置換はできます。"),
                choice("d", "UnsupportedOperationException と表示される", misconception: "catchで例外名が自動出力されると誤解", explanation: "catch内ではlistをprintlnしているため、例外名は出力されません。"),
            ],
            intent: "Arrays.asListが固定サイズリストであることと、set/addの違いを確認する。",
            steps: [
                step("listは `Arrays.asList(\"A\", \"B\")` で作られた固定サイズリストです。", [3], [variable("list", "List<String>", "[A, B]", "main")]),
                step("`set(1, \"X\")` は既存要素の置換なので成功し、listは `[A, X]` になります。", [4], [variable("list", "List<String>", "[A, X]", "main")]),
                step("`add(\"Y\")` はサイズ変更なのでUnsupportedOperationExceptionとなり、catchで現在のlistを出力します。", [5, 6, 8, 9], [variable("output", "String", "[A, X]", "stdout")]),
            ]
        ),
        q(
            "silver-mock-finalpush-listof-null-001",
            difficulty: .tricky,
            isMockExamOnly: true,
            category: "collections",
            tags: ["模試専用", "List.of", "null", "NullPointerException"],
            code: """
public class Test {
    public static void main(String[] args) {
        try {
            java.util.List<String> list = java.util.List.of("A", null);
            System.out.println(list.size());
        } catch (NullPointerException e) {
            System.out.println("NPE");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2", misconception: "List.ofがnull要素を許可すると誤解", explanation: "List.ofで作る不変リストはnull要素を許可しません。"),
                choice("b", "1", misconception: "nullだけ無視されると誤解", explanation: "nullを含めた時点でNullPointerExceptionです。"),
                choice("c", "NPE", correct: true, explanation: "`List.of(\"A\", null)` の評価中にNullPointerExceptionが発生し、catchでNPEが出力されます。"),
                choice("d", "UnsupportedOperationException", misconception: "不変リストの変更時例外と混同", explanation: "今回は変更前の作成時にnullで失敗します。"),
            ],
            intent: "List.ofがnull要素を許可しないことを確認する。",
            steps: [
                step("try内でList.ofにAとnullを渡しています。", [3, 4], [variable("arguments", "String...", "A, null", "main")]),
                step("List.ofはnull要素を検出するとNullPointerExceptionを投げ、list変数への代入は完了しません。", [4], [variable("result", "exception", "NullPointerException", "runtime")]),
                step("catch節で `NPE` が出力されます。", [6, 7], [variable("output", "String", "NPE", "stdout")]),
            ]
        ),
        q(
            "silver-mock-finalpush-string-replace-immutable-001",
            isMockExamOnly: true,
            category: "strings",
            tags: ["模試専用", "String", "replace", "immutable"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = "aba";
        s.replace('a', 'x');
        System.out.println(s);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "aba", correct: true, explanation: "Stringは不変で、replaceの戻り値を代入していないためsは変わりません。"),
                choice("b", "xbx", misconception: "replaceが元のStringを変更すると誤解", explanation: "replaceは新しいStringを返します。元のsは不変です。"),
                choice("c", "xba", misconception: "最初の1文字だけ置換されると誤解", explanation: "replaceは全対象を置換しますが、今回は戻り値を捨てています。"),
                choice("d", "コンパイルエラー", misconception: "replace(char,char)を使えないと誤解", explanation: "メソッド呼び出し自体は有効です。"),
            ],
            intent: "Stringの不変性と戻り値を受け取る必要性を確認する。",
            steps: [
                step("sは文字列 `aba` を参照しています。", [3], [variable("s", "String", "aba", "main")]),
                step("`s.replace('a', 'x')` は `xbx` という新しいStringを返しますが、戻り値は代入されていません。", [4], [variable("discarded return", "String", "xbx", "expression")]),
                step("sは元の `aba` のままなので、出力は `aba` です。", [5], [variable("output", "String", "aba", "stdout")]),
            ]
        ),
        q(
            "silver-mock-finalpush-stringbuilder-equals-001",
            difficulty: .tricky,
            isMockExamOnly: true,
            category: "strings",
            tags: ["模試専用", "StringBuilder", "equals", "toString"],
            code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder a = new StringBuilder("x");
        StringBuilder b = new StringBuilder("x");
        System.out.println(a.equals(b) + ":" + a.toString().equals(b.toString()));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true:true", misconception: "StringBuilder.equalsが内容比較だと誤解", explanation: "StringBuilderはequalsを内容比較としてオーバーライドしていません。"),
                choice("b", "false:true", correct: true, explanation: "StringBuilder同士のequalsは参照比較相当ですが、String同士のequalsは内容比較です。"),
                choice("c", "true:false", misconception: "toStringで別参照になるとequalsもfalseだと誤解", explanation: "String.equalsは参照ではなく内容を比較します。"),
                choice("d", "false:false", misconception: "どちらも参照比較だと誤解", explanation: "toString後のString同士は内容比較されます。"),
            ],
            intent: "StringBuilder.equalsとString.equalsの違いを確認する。",
            steps: [
                step("aとbはどちらも内容xですが、別々のStringBuilderインスタンスです。", [3, 4], [variable("a == b", "boolean", "false", "heap")]),
                step("StringBuilderはequalsを内容比較としてオーバーライドしないため、`a.equals(b)` はfalseです。", [5], [variable("a.equals(b)", "boolean", "false", "main")]),
                step("toString後のStringは内容比較されるためtrueになり、出力は `false:true` です。", [5], [variable("output", "String", "false:true", "stdout")]),
            ]
        ),
        q(
            "silver-mock-finalpush-interface-private-static-001",
            difficulty: .tricky,
            isMockExamOnly: true,
            category: "classes",
            tags: ["模試専用", "interface", "private static method"],
            code: """
interface Tool {
    private static String value() {
        return "P";
    }
    static void print() {
        System.out.println(value());
    }
}

public class Test {
    public static void main(String[] args) {
        Tool.print();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "P", correct: true, explanation: "インターフェース内のprivate staticメソッドは、同じインターフェース内のstaticメソッドから呼び出せます。"),
                choice("b", "Tool", misconception: "インターフェース名が自動的に出力されると誤解", explanation: "printはvalueの戻り値Pを出力します。"),
                choice("c", "コンパイルエラー", misconception: "インターフェースにprivate staticメソッドを定義できないと誤解", explanation: "Java 17ではインターフェースにprivate staticメソッドを定義できます。"),
                choice("d", "IllegalAccessError", misconception: "private呼び出しが実行時エラーになると誤解", explanation: "同じインターフェース内からの呼び出しなのでアクセス可能です。"),
            ],
            intent: "インターフェースのprivate staticメソッドの利用範囲を確認する。",
            steps: [
                step("Toolにはprivate staticメソッドvalueとpublic staticメソッドprintがあります。", [1, 2, 5], [variable("Tool.value", "private static method", "returns P", "interface")]),
                step("mainから呼べるのはTool.printで、printの内部からvalueを呼びます。", [5, 6, 11], [variable("value()", "String", "P", "Tool.print")]),
                step("valueの戻り値がprintlnされ、出力は `P` です。", [6], [variable("output", "String", "P", "stdout")]),
            ]
        ),
        q(
            "silver-mock-finalpush-var-array-initializer-compile-001",
            difficulty: .tricky,
            validatedByJavac: false,
            isMockExamOnly: true,
            category: "java-basics",
            tags: ["模試専用", "var", "array initializer", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        var values = { 1, 2, 3 };
        System.out.println(values.length);
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "3", misconception: "varがint[]を推論すると誤解", explanation: "配列初期化子だけではvarの型推論に必要な明示的型がありません。"),
                choice("b", "0", misconception: "配列が空になると誤解", explanation: "初期化子には要素がありますが、その前にコンパイルできません。"),
                choice("c", "コンパイルエラー", correct: true, explanation: "`var values = { ... };` のように配列初期化子だけをvarへ代入することはできません。"),
                choice("d", "NullPointerException", misconception: "valuesがnullになると誤解", explanation: "ローカル変数の型推論に失敗するため実行されません。"),
            ],
            intent: "varと配列初期化子を組み合わせるときの制約を確認する。",
            steps: [
                step("`var` は右辺からローカル変数の型を推論します。", [3], [variable("values", "var", "needs inferred type", "compiler")]),
                step("`{ 1, 2, 3 }` は単独では型を持つ式ではなく、`int[] values = { ... }` のような文脈が必要です。", [3], [variable("initializer", "array initializer", "no standalone type", "compiler")]),
                step("そのためvaluesの型を推論できず、コンパイルエラーになります。", [3], [variable("result", "compile", "error", "javac")]),
            ]
        ),
        q(
            "silver-mock-finalpush-final-array-mutation-001",
            isMockExamOnly: true,
            category: "data-types",
            tags: ["模試専用", "final", "array", "mutation"],
            code: """
public class Test {
    public static void main(String[] args) {
        final int[] nums = { 1 };
        nums[0]++;
        System.out.println(nums[0]);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1", misconception: "final配列の要素は変更できないと誤解", explanation: "finalなのは参照変数numsへの再代入であり、配列要素の変更は可能です。"),
                choice("b", "2", correct: true, explanation: "nums[0]は1から後置インクリメントで2になります。"),
                choice("c", "コンパイルエラー", misconception: "final参照先の状態変更も禁止されると誤解", explanation: "配列要素の変更は再代入ではないためコンパイルできます。"),
                choice("d", "UnsupportedOperationException", misconception: "finalを不変コレクションと混同", explanation: "配列要素の更新でこの例外は発生しません。"),
            ],
            intent: "final参照と参照先オブジェクトの変更可能性を区別する。",
            steps: [
                step("numsはfinalな参照変数で、長さ1のint配列を指しています。", [3], [variable("nums[0]", "int", "1", "main")]),
                step("`nums[0]++` は配列要素を1から2に更新します。参照変数numsへの再代入ではありません。", [4], [variable("nums[0]", "int", "2", "main")]),
                step("更新後の要素を出力するため、結果は `2` です。", [5], [variable("output", "String", "2", "stdout")]),
            ]
        ),
        q(
            "silver-mock-finalpush-equals-overload-trap-001",
            difficulty: .tricky,
            isMockExamOnly: true,
            category: "classes",
            tags: ["模試専用", "equals", "overload", "Object"],
            code: """
class Box {
    int value;
    Box(int value) {
        this.value = value;
    }
    public boolean equals(Box other) {
        return value == other.value;
    }
}

public class Test {
    public static void main(String[] args) {
        Object a = new Box(1);
        Object b = new Box(1);
        System.out.println(a.equals(b));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", misconception: "equals(Box)がObject.equalsをオーバーライドすると誤解", explanation: "Object.equalsのシグネチャはequals(Object)なので、equals(Box)はオーバーロードです。"),
                choice("b", "false", correct: true, explanation: "aのコンパイル時型はObjectで、実行時にもBoxはequals(Object)をオーバーライドしていないため参照比較になります。"),
                choice("c", "コンパイルエラー", misconception: "Object型からequalsを呼べないと誤解", explanation: "equals(Object)はObjectに定義されています。"),
                choice("d", "ClassCastException", misconception: "equals(Box)内でキャストされると誤解", explanation: "equals(Box)は呼ばれていません。"),
            ],
            intent: "equalsの正しいオーバーライドシグネチャとオーバーロードのひっかけを確認する。",
            steps: [
                step("Boxには `equals(Box)` が定義されていますが、これは `equals(Object)` ではありません。", [6], [variable("Box.equals(Box)", "method", "overload", "class Box")]),
                step("aとbの参照型はObjectです。`a.equals(b)` はObjectの `equals(Object)` 呼び出しとして解決されます。", [12, 13, 14], [variable("selected method", "method", "Object.equals(Object)", "compiler/runtime")]),
                step("Boxはequals(Object)をオーバーライドしていないので参照比較となり、別インスタンスのためfalseです。", [14], [variable("output", "String", "false", "stdout")]),
            ]
        ),
        q(
            "silver-mock-finalpush-static-forward-method-001",
            difficulty: .tricky,
            isMockExamOnly: true,
            category: "classes",
            tags: ["模試専用", "static initialization", "forward reference"],
            code: """
public class Test {
    static {
        print();
    }
    static int value = 3;
    static void print() {
        System.out.print(value);
    }
    public static void main(String[] args) {
        print();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "03", correct: true, explanation: "staticブロックからメソッド経由でvalueを読む時点では既定値0、その後value=3となりmainで3を出力します。"),
                choice("b", "33", misconception: "staticフィールド初期化がstaticブロックより先だと誤解", explanation: "同じクラス内ではソース上の順にstatic初期化が進みます。"),
                choice("c", "0", misconception: "mainのprintが実行されないと誤解", explanation: "クラス初期化後にmainが実行され、2回目のprintがあります。"),
                choice("d", "コンパイルエラー", misconception: "メソッド経由の前方参照も禁止されると誤解", explanation: "単純名で直接読む前方参照とは異なり、メソッド経由の読み取りはコンパイル可能です。"),
            ],
            intent: "static初期化順とメソッド経由の前方参照の挙動を確認する。",
            steps: [
                step("クラス初期化では、まずstaticブロックが実行されます。この時点でvalueは既定値0です。", [2, 3, 5], [variable("value", "int", "0", "class initialization")]),
                step("staticブロックからprintが呼ばれ、0が出力されます。その後 `static int value = 3` が実行されます。", [3, 5, 6, 7], [variable("partial output", "String", "0", "stdout"), variable("value", "int", "3", "class")]),
                step("mainで再度printが呼ばれ、今度は3が出力されます。", [9, 10], [variable("output", "String", "03", "stdout")]),
            ]
        ),
        q(
            "silver-mock-finalpush-array-alias-001",
            isMockExamOnly: true,
            category: "arrays",
            tags: ["模試専用", "array", "alias", "reference"],
            code: """
public class Test {
    public static void main(String[] args) {
        int[] row = { 1, 2 };
        int[][] table = { row, row };
        table[0][0] = 9;
        System.out.println(table[1][0]);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1", misconception: "2次元配列の各行がコピーされると誤解", explanation: "tableの2つの行は同じrow配列を参照しています。"),
                choice("b", "2", misconception: "列インデックスと初期値を取り違えている", explanation: "参照しているのはインデックス0の要素です。"),
                choice("c", "9", correct: true, explanation: "table[0]とtable[1]は同じ配列rowを指すため、一方の更新がもう一方からも見えます。"),
                choice("d", "ArrayIndexOutOfBoundsException", misconception: "table[1][0]が存在しないと誤解", explanation: "tableは2要素を持ち、各要素は長さ2のrowを参照しています。"),
            ],
            intent: "多次元配列が配列参照の配列であることとエイリアスを確認する。",
            steps: [
                step("rowは `[1, 2]` のint配列です。", [3], [variable("row", "int[]", "[1, 2]", "heap")]),
                step("tableの0行目と1行目はいずれも同じrow参照を保持しています。", [4], [variable("table[0] == table[1]", "boolean", "true", "heap")]),
                step("`table[0][0] = 9` でrow[0]が9になり、table[1][0]からも9が見えます。", [5, 6], [variable("output", "String", "9", "stdout")]),
            ]
        ),
        q(
            "silver-mock-finalpush-static-hidden-call-001",
            difficulty: .tricky,
            isMockExamOnly: true,
            category: "inheritance",
            tags: ["模試専用", "static method", "hiding", "reference type"],
            code: """
class Parent {
    static void print() {
        System.out.print("P");
    }
}

class Child extends Parent {
    static void print() {
        System.out.print("C");
    }
}

public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        p.print();
        ((Child) p).print();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "PP", misconception: "キャスト後も変数pの宣言型だけで決まると誤解", explanation: "2回目は式の型がChildになるためChild.printが選ばれます。"),
                choice("b", "PC", correct: true, explanation: "staticメソッドは隠蔽であり、呼び出し式のコンパイル時型でParent版、Child版が選ばれます。"),
                choice("c", "CC", misconception: "staticメソッドもポリモーフィックに実行時型で決まると誤解", explanation: "staticメソッドはオーバーライドされません。"),
                choice("d", "コンパイルエラー", misconception: "インスタンス参照でstaticメソッドを呼べないと誤解", explanation: "推奨はされませんが、コンパイルは可能で式の型に基づいて解決されます。"),
            ],
            intent: "staticメソッドの隠蔽と参照式のコンパイル時型による解決を確認する。",
            steps: [
                step("pの宣言型はParent、実体はChildです。", [15], [variable("p", "Parent", "Child instance", "main")]),
                step("`p.print()` はstaticメソッド呼び出しなので、pのコンパイル時型Parentに基づきParent.printが選ばれます。", [16], [variable("partial output", "String", "P", "stdout")]),
                step("`((Child) p).print()` は式の型がChildなのでChild.printが選ばれ、最終出力は `PC` です。", [17], [variable("output", "String", "PC", "stdout")]),
            ]
        ),
        q(
            "silver-mock-finalpush-anonymous-class-this-001",
            difficulty: .tricky,
            isMockExamOnly: true,
            category: "classes",
            tags: ["模試専用", "anonymous class", "this"],
            code: """
public class Test {
    String name = "outer";
    Runnable r = new Runnable() {
        String name = "inner";
        public void run() {
            System.out.println(this.name);
        }
    };
    public static void main(String[] args) {
        new Test().r.run();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "outer", misconception: "thisが常に外側Testを指すと誤解", explanation: "匿名クラス内のthisは匿名クラス自身を指します。"),
                choice("b", "inner", correct: true, explanation: "run内のthisは匿名Runnableオブジェクトであり、そのnameフィールドはinnerです。"),
                choice("c", "null", misconception: "匿名クラスのフィールドが初期化されないと誤解", explanation: "匿名クラスのnameにはinnerが代入されています。"),
                choice("d", "コンパイルエラー", misconception: "匿名クラス内で同名フィールドを定義できないと誤解", explanation: "外側クラスのフィールドとは別フィールドとして定義できます。"),
            ],
            intent: "匿名クラス内のthisが外側インスタンスではなく匿名クラス自身を指すことを確認する。",
            steps: [
                step("Testにはname=outerがあり、匿名Runnableにもname=innerがあります。", [2, 3, 4], [variable("Test.name", "String", "outer", "outer instance"), variable("anonymous.name", "String", "inner", "anonymous instance")]),
                step("run内の `this` は匿名クラス自身を指します。", [5, 6], [variable("this.name", "String", "inner", "anonymous run")]),
                step("new Test().r.run()によりrunが実行され、出力は `inner` です。", [9, 10], [variable("output", "String", "inner", "stdout")]),
            ]
        ),
        q(
            "silver-mock-finalpush-override-throws-compile-001",
            difficulty: .tricky,
            validatedByJavac: false,
            isMockExamOnly: true,
            category: "inheritance",
            tags: ["模試専用", "override", "throws", "compile"],
            code: """
class Parent {
    void read() throws java.io.IOException {}
}

class Child extends Parent {
    void read() throws Exception {}
}

public class Test {
    public static void main(String[] args) {
        System.out.println("test");
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "test", misconception: "readを呼んでいないので問題ないと誤解", explanation: "クラス定義自体で不正なオーバーライドがあるため、呼び出し有無に関係なくコンパイルエラーです。"),
                choice("b", "何も出力されない", misconception: "mainは実行されるがprintlnが無視されると誤解", explanation: "そもそもコンパイルできません。"),
                choice("c", "コンパイルエラー", correct: true, explanation: "オーバーライド時に、チェック例外のthrowsを親メソッドより広くすることはできません。"),
                choice("d", "IOException", misconception: "例外宣言だけで例外が投げられると誤解", explanation: "throwsは宣言であり、実行時に自動で例外を投げるものではありません。"),
            ],
            intent: "オーバーライド時のthrows句でチェック例外を広げられないことを確認する。",
            steps: [
                step("Parent.readはIOExceptionをthrowsします。", [1, 2], [variable("Parent.read throws", "checked exception", "IOException", "class Parent")]),
                step("Child.readは同じメソッドをオーバーライドしようとしていますが、throws ExceptionはIOExceptionより広い型です。", [5, 6], [variable("Child.read throws", "checked exception", "Exception", "class Child")]),
                step("チェック例外を広げるオーバーライドは不正なので、mainを実行する前にコンパイルエラーです。", [6, 10], [variable("result", "compile", "error", "javac")]),
            ]
        ),
    ]

    static func q(
        _ id: String,
        difficulty: QuizDifficulty = .standard,
        estimatedSeconds: Int = 75,
        validatedByJavac: Bool = true,
        isMockExamOnly: Bool = false,
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
            isMockExamOnly: isMockExamOnly,
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

extension SilverFinalPushQuestionData.Spec {
    var quiz: Quiz {
        Quiz(
            id: id,
            level: .silver,
            difficulty: difficulty,
            estimatedSeconds: estimatedSeconds,
            validatedByJavac: validatedByJavac,
            isMockExamOnly: isMockExamOnly,
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
    static let silverFinalPushExpansion: [Quiz] = SilverFinalPushQuestionData.practiceSpecs.map(\.quiz)
    static let silverFinalPushMockExpansion: [Quiz] = SilverFinalPushQuestionData.mockSpecs.map(\.quiz)
}
