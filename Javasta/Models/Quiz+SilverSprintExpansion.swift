import Foundation

enum SilverSprintQuestionData {
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
            "silver-sprint-binary-literal-001",
            category: "data-types",
            tags: ["binary literal", "int", "operator"],
            code: """
public class Test {
    public static void main(String[] args) {
        int n = 0b1010;
        System.out.println(n + 1);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1011", misconception: "2進表記の見た目のまま出力されると誤解", explanation: "int値として扱われ、10進表記で出力されます。"),
                choice("b", "11", correct: true, explanation: "`0b1010` は10なので、1を足して11です。"),
                choice("c", "0b1011", misconception: "リテラル接頭辞が出力にも残ると誤解", explanation: "printlnはint値を通常の10進文字列として出力します。"),
                choice("d", "コンパイルエラー", misconception: "2進リテラルを使えないと誤解", explanation: "Javaでは `0b` 接頭辞の2進整数リテラルを使えます。"),
            ],
            intent: "2進整数リテラルがint値として扱われることを確認する。",
            steps: [
                step("`0b1010` は2進数で10を表すintリテラルです。", [3], [variable("n", "int", "10", "main")]),
                step("`n + 1` は10 + 1なので11です。", [4], [variable("n + 1", "int", "11", "main")]),
                step("出力は10進表記の `11` です。", [4], [variable("output", "String", "11", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-hex-literal-001",
            category: "data-types",
            tags: ["hex literal", "int", "operator"],
            code: """
public class Test {
    public static void main(String[] args) {
        int n = 0x10 + 10;
        System.out.println(n);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "20", misconception: "0x10を10と読むと誤解", explanation: "`0x10` は16進数で16です。"),
                choice("b", "26", correct: true, explanation: "`0x10` は16、そこへ10を足して26です。"),
                choice("c", "0x20", misconception: "16進表記で出力されると誤解", explanation: "printlnはint値を通常の10進表記で出力します。"),
                choice("d", "コンパイルエラー", misconception: "16進リテラルを使えないと誤解", explanation: "`0x` 接頭辞の整数リテラルは有効です。"),
            ],
            intent: "16進整数リテラルと出力表記を確認する。",
            steps: [
                step("`0x10` は16進数の10なので、10進では16です。", [3], [variable("0x10", "int literal", "16", "compiler")]),
                step("`16 + 10` でnは26になります。", [3], [variable("n", "int", "26", "main")]),
                step("int値として出力されるため、結果は `26` です。", [4], [variable("output", "String", "26", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-char-unicode-001",
            category: "data-types",
            tags: ["char", "unicode", "numeric promotion"],
            code: #"""
public class Test {
    public static void main(String[] args) {
        char c = '\u0041';
        System.out.println(c + 1);
    }
}
"""#,
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A1", misconception: "文字列連結になると誤解", explanation: "charとintの `+` は数値演算です。"),
                choice("b", "B", misconception: "charのまま文字に戻ると誤解", explanation: "`c + 1` の式の型はintです。"),
                choice("c", "66", correct: true, explanation: "`\\u0041` はAでコード値65。1を足して66です。"),
                choice("d", "コンパイルエラー", misconception: "Unicodeエスケープをcharに使えないと誤解", explanation: "`'\\u0041'` は有効なcharリテラルです。"),
            ],
            intent: "Unicode charリテラルとcharの数値昇格を確認する。",
            steps: [
                step("`'\\u0041'` は文字Aを表し、コード値は65です。", [3], [variable("c", "char", "A / 65", "main")]),
                step("`c + 1` ではcharがintへ昇格し、65 + 1になります。", [4], [variable("c + 1", "int", "66", "main")]),
                step("したがって出力は `66` です。", [4], [variable("output", "String", "66", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-byte-compound-overflow-001",
            category: "data-types",
            tags: ["byte", "compound assignment", "overflow"],
            code: """
public class Test {
    public static void main(String[] args) {
        byte b = 126;
        b += 2;
        System.out.println(b);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "128", misconception: "byteの範囲を超えて保持できると誤解", explanation: "byteの範囲は -128 から 127 です。"),
                choice("b", "-128", correct: true, explanation: "`b += 2` は暗黙キャストを含み、128がbyteへ戻されて -128 になります。"),
                choice("c", "コンパイルエラー", misconception: "`b = b + 2` と完全に同じだと誤解", explanation: "複合代入は暗黙のキャストを含みます。"),
                choice("d", "ArithmeticException", misconception: "整数オーバーフローで例外が出ると誤解", explanation: "Javaの整数オーバーフローは通常例外になりません。"),
            ],
            intent: "複合代入とbyteオーバーフローを確認する。",
            steps: [
                step("bは最初126です。", [3], [variable("b", "byte", "126", "main")]),
                step("`b += 2` は `b = (byte)(b + 2)` に近い扱いです。計算上は128になります。", [4], [variable("b + 2", "int", "128", "expression")]),
                step("128をbyteへ戻すと範囲を回り込み -128 になります。", [4, 5], [variable("output", "String", "-128", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-non-short-circuit-or-001",
            category: "data-types",
            tags: ["boolean operator", "|", "side effect"],
            code: """
public class Test {
    public static void main(String[] args) {
        int x = 0;
        boolean result = (x++ == 0) | (x++ == 0);
        System.out.println(result + ":" + x);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true:1", misconception: "`|` も短絡評価すると誤解", explanation: "`|` はboolean演算でも右辺を評価します。"),
                choice("b", "true:2", correct: true, explanation: "左辺はtrueですが、`|` は右辺も評価するためxは2になります。"),
                choice("c", "false:2", misconception: "右辺の比較結果だけを見ると誤解", explanation: "左辺がtrueなので全体はtrueです。"),
                choice("d", "コンパイルエラー", misconception: "boolean式に `|` を使えないと誤解", explanation: "`|` はboolean同士にも使えます。"),
            ],
            intent: "`|` と `||` の評価方法の違いを確認する。",
            steps: [
                step("左辺 `(x++ == 0)` は現在のx=0を比較してtrueになり、その後xは1になります。", [3, 4], [variable("left", "boolean", "true", "main"), variable("x", "int", "1", "main")]),
                step("演算子が `|` なので、左辺がtrueでも右辺が評価されます。右辺では1 == 0がfalseとなり、その後xは2です。", [4], [variable("right", "boolean", "false", "main"), variable("x", "int", "2", "main")]),
                step("true | false はtrueなので、出力は `true:2` です。", [5], [variable("output", "String", "true:2", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-definite-assignment-constant-001",
            category: "java-basics",
            tags: ["definite assignment", "if", "local variable"],
            code: """
public class Test {
    public static void main(String[] args) {
        int value;
        if (true) {
            value = 7;
        }
        System.out.println(value);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", misconception: "ローカル変数にデフォルト値があると誤解", explanation: "ローカル変数は使用前に確実に代入される必要があります。"),
                choice("b", "7", correct: true, explanation: "`if (true)` は必ず実行されるため、valueは7に確実に代入されます。"),
                choice("c", "コンパイルエラー", misconception: "if内代入は確実な代入にならないと誤解", explanation: "条件が定数trueなので、コンパイラは代入されると判断できます。"),
                choice("d", "NullPointerException", misconception: "未初期化をnullと混同", explanation: "valueはintで、今回は代入済みです。"),
            ],
            intent: "定数trueのifによる確定代入を確認する。",
            steps: [
                step("`value` は宣言時点では未代入のローカル変数です。", [3], [variable("value", "int", "unassigned", "main")]),
                step("`if (true)` の本体は必ず実行され、valueに7が代入されます。", [4, 5], [variable("value", "int", "7", "main")]),
                step("使用時点で確実に代入済みなので、出力は `7` です。", [7], [variable("output", "String", "7", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-definite-assignment-compile-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "java-basics",
            tags: ["definite assignment", "local variable", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        boolean flag = false;
        int value;
        if (flag) {
            value = 7;
        }
        System.out.println(value);
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "7と出力される", misconception: "if本体が必ず実行されると誤解", explanation: "flagは変数なので、コンパイラは本体が必ず実行されるとは扱いません。"),
                choice("b", "0と出力される", misconception: "ローカル変数にデフォルト値があると誤解", explanation: "ローカル変数は自動初期化されません。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "valueが代入されない経路があるため、printlnで読むことができません。"),
                choice("d", "falseと出力される", misconception: "出力対象をflagと取り違え", explanation: "出力しているのはvalueです。"),
            ],
            intent: "ローカル変数の確定代入解析を確認する。",
            steps: [
                step("`value` は宣言だけで初期化されていません。", [4], [variable("value", "int", "unassigned", "main")]),
                step("代入は `if (flag)` の中だけです。flagは変数なので、コンパイラはこのifが必ず実行されるとは判断しません。", [3, 5, 6], [variable("definitely assigned", "boolean", "false", "compiler")]),
                step("8行目で未代入の可能性があるvalueを読むため、コンパイルエラーになります。", [8], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-sprint-switch-arrow-001",
            category: "control-flow",
            tags: ["switch", "arrow label", "no fallthrough"],
            code: """
public class Test {
    public static void main(String[] args) {
        int n = 1;
        switch (n) {
            case 1 -> System.out.print("A");
            default -> System.out.print("D");
        }
        System.out.print("X");
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "AD", misconception: "arrow caseでもdefaultへフォールスルーすると誤解", explanation: "`->` 形式ではフォールスルーしません。"),
                choice("b", "AX", correct: true, explanation: "case 1でAを出力し、switch後にXを出力します。defaultへは進みません。"),
                choice("c", "DX", misconception: "defaultが優先されると誤解", explanation: "nは1なのでcase 1に一致します。"),
                choice("d", "コンパイルエラー", misconception: "switch文でarrowラベルを使えないと誤解", explanation: "Java 17ではswitch文でもarrowラベルを使えます。"),
            ],
            intent: "switchのarrowラベルがフォールスルーしないことを確認する。",
            steps: [
                step("nは1なので `case 1` に一致します。", [3, 4, 5], [variable("n", "int", "1", "main")]),
                step("`case 1 ->` の処理でAを出力します。arrow形式はdefaultへ流れません。", [5, 6], [variable("output so far", "String", "A", "stdout")]),
                step("switch後のXが続き、全体は `AX` です。", [8], [variable("output", "String", "AX", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-string-replace-string-001",
            category: "string",
            tags: ["String", "replace", "immutable"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = "banana";
        s = s.replace("na", "NA");
        System.out.println(s);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "baNAna", misconception: "最初の1箇所だけ置換されると誤解", explanation: "String.replaceは一致するすべての部分を置換します。"),
                choice("b", "baNANA", correct: true, explanation: "`banana` 内の `na` は2箇所あり、どちらも `NA` に置換されます。"),
                choice("c", "banana", misconception: "Stringが不変なので戻り値代入も効かないと誤解", explanation: "新しいStringを返し、それをsへ代入しています。"),
                choice("d", "コンパイルエラー", misconception: "replace(String,String)が存在しないと誤解", explanation: "CharSequence版として利用できます。"),
            ],
            intent: "String.replaceの全置換と戻り値代入を確認する。",
            steps: [
                step("sは最初 `banana` です。`na` はインデックス2と4から始まる2箇所にあります。", [3], [variable("s", "String", "banana", "main")]),
                step("`replace(\"na\", \"NA\")` は一致箇所をすべて置換した新しいString `baNANA` を返します。", [4], [variable("replace result", "String", "baNANA", "main")]),
                step("戻り値をsへ代入しているため、出力は `baNANA` です。", [4, 5], [variable("output", "String", "baNANA", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-substring-empty-001",
            category: "string",
            tags: ["String", "substring", "empty string"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = "abc";
        System.out.println(s.substring(2, 2).length());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", correct: true, explanation: "開始位置と終了位置が同じsubstringは空文字列になり、長さは0です。"),
                choice("b", "1", misconception: "インデックス2の文字cを含むと誤解", explanation: "終了インデックスは含まれず、開始と終了が同じなので文字は含まれません。"),
                choice("c", "2", misconception: "開始インデックスが長さになると誤解", explanation: "substring結果の長さを出力しています。"),
                choice("d", "StringIndexOutOfBoundsException", misconception: "同じ開始・終了位置が不正と誤解", explanation: "0以上length以下で start <= end なら有効です。"),
            ],
            intent: "substring(start,end)でstartとendが同じ場合を確認する。",
            steps: [
                step("`s` は長さ3の文字列です。インデックス2は有効で、終了位置2も範囲内です。", [3], [variable("s.length()", "int", "3", "main")]),
                step("`substring(2, 2)` は開始と終了が同じなので、文字を含まない空文字列を返します。", [4], [variable("substring", "String", "\"\"", "main")]),
                step("空文字列の長さは0なので、出力は `0` です。", [4], [variable("output", "String", "0", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-stringbuilder-insert-boolean-001",
            category: "string",
            tags: ["StringBuilder", "insert", "boolean"],
            code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("abc");
        sb.insert(1, false);
        System.out.println(sb);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "afalsebc", correct: true, explanation: "インデックス1、つまりaの後ろに文字列 `false` が挿入されます。"),
                choice("b", "falseabc", misconception: "先頭に挿入されると誤解", explanation: "挿入位置は1です。"),
                choice("c", "abcfalse", misconception: "末尾に追加されると誤解", explanation: "`append` ではなく `insert(1, ...)` です。"),
                choice("d", "コンパイルエラー", misconception: "booleanをStringBuilderへinsertできないと誤解", explanation: "StringBuilderにはbooleanを受け取るinsertオーバーロードがあります。"),
            ],
            intent: "StringBuilder.insertの位置とboolean変換を確認する。",
            steps: [
                step("初期状態は `abc` です。インデックス1はaとbの間です。", [3, 4], [variable("sb", "StringBuilder", "abc", "main")]),
                step("`insert(1, false)` はboolean値を文字列 `false` としてその位置に挿入します。", [4], [variable("sb", "StringBuilder", "afalsebc", "main")]),
                step("出力は `afalsebc` です。", [5], [variable("output", "String", "afalsebc", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-arrays-mismatch-001",
            category: "data-types",
            tags: ["Arrays", "mismatch", "array"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        int[] a = {1, 2, 3};
        int[] b = {1, 4, 3};
        System.out.println(Arrays.mismatch(a, b));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", misconception: "最初の要素位置を返すと誤解", explanation: "最初の要素同士は等しいので不一致ではありません。"),
                choice("b", "1", correct: true, explanation: "インデックス1で2と4が初めて異なるため、1が返ります。"),
                choice("c", "2", misconception: "値の差を返すと誤解", explanation: "返るのは不一致が見つかったインデックスです。"),
                choice("d", "-1", misconception: "配列が同じだと誤解", explanation: "インデックス1の値が違います。"),
            ],
            intent: "Arrays.mismatchが最初に異なるインデックスを返すことを確認する。",
            steps: [
                step("aは `[1, 2, 3]`、bは `[1, 4, 3]` です。", [5, 6], [variable("a", "int[]", "[1, 2, 3]", "main"), variable("b", "int[]", "[1, 4, 3]", "main")]),
                step("インデックス0はどちらも1で一致します。インデックス1で2と4が異なります。", [7], [variable("first mismatch", "int", "1", "Arrays.mismatch")]),
                step("したがって出力は `1` です。", [7], [variable("output", "String", "1", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-array-clone-shallow-001",
            category: "data-types",
            tags: ["array", "clone", "shallow copy"],
            code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder[] a = { new StringBuilder("A") };
        StringBuilder[] b = a.clone();
        b[0].append("B");
        System.out.println(a[0]);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", misconception: "配列cloneで要素オブジェクトも複製されると誤解", explanation: "配列cloneは浅いコピーで、要素参照は共有されます。"),
                choice("b", "AB", correct: true, explanation: "b[0]とa[0]は同じStringBuilderを参照しているため、appendの結果がa側にも見えます。"),
                choice("c", "B", misconception: "appendが元の内容を置き換えると誤解", explanation: "appendは末尾に追加します。"),
                choice("d", "コンパイルエラー", misconception: "配列をcloneできないと誤解", explanation: "配列はcloneできます。"),
            ],
            intent: "配列cloneが浅いコピーであることを確認する。",
            steps: [
                step("a[0] は `A` を持つStringBuilderを参照しています。", [3], [variable("a[0]", "StringBuilder", "A", "heap")]),
                step("`a.clone()` は新しい配列を作りますが、要素のStringBuilder自体は共有されます。", [4], [variable("b[0]", "StringBuilder ref", "same as a[0]", "heap")]),
                step("`b[0].append(\"B\")` で共有オブジェクトが `AB` になり、a[0]を出力しても `AB` です。", [5, 6], [variable("output", "String", "AB", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-overload-float-001",
            category: "overload-resolution",
            tags: ["overload", "float", "literal"],
            code: """
public class Test {
    static void call(float f) { System.out.println("float"); }
    static void call(double d) { System.out.println("double"); }
    public static void main(String[] args) {
        call(1.0f);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "float", correct: true, explanation: "`1.0f` はfloatリテラルなので、完全一致するfloat版が選ばれます。"),
                choice("b", "double", misconception: "小数は常にdouble版へ行くと誤解", explanation: "`f` サフィックスによりfloat型です。"),
                choice("c", "コンパイルエラー", misconception: "floatとdoubleのオーバーロードが曖昧と誤解", explanation: "完全一致のfloat版があるため曖昧ではありません。"),
                choice("d", "1.0", misconception: "引数の値が出力されると誤解", explanation: "メソッド本体は固定文字列を出力しています。"),
            ],
            intent: "floatリテラルによるオーバーロード選択を確認する。",
            steps: [
                step("`1.0f` はfloat型のリテラルです。", [5], [variable("argument", "float", "1.0", "main")]),
                step("float版は完全一致、double版は拡大変換です。完全一致が優先されます。", [2, 3], [variable("selected method", "String", "call(float)", "compiler")]),
                step("float版が実行され、出力は `float` です。", [2], [variable("output", "String", "float", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-overload-widening-before-varargs-001",
            category: "overload-resolution",
            tags: ["overload", "widening", "varargs"],
            code: """
public class Test {
    static void call(short s) { System.out.println("short"); }
    static void call(byte... b) { System.out.println("varargs"); }
    public static void main(String[] args) {
        byte value = 1;
        call(value);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "short", correct: true, explanation: "固定長引数の拡大変換byte→shortは、varargsより優先されます。"),
                choice("b", "varargs", misconception: "byte完全一致のvarargsが優先と誤解", explanation: "varargsは通常の固定長候補がない場合の後段で検討されます。"),
                choice("c", "コンパイルエラー", misconception: "byteからshortへ変換できないと誤解", explanation: "byteからshortは拡大変換です。"),
                choice("d", "byte", misconception: "byte版メソッドがあると誤解", explanation: "宣言されている固定長メソッドはshort版です。"),
            ],
            intent: "オーバーロード解決で固定長の拡大変換がvarargsより先に選ばれることを確認する。",
            steps: [
                step("実引数valueの型はbyteです。", [5, 6], [variable("value", "byte", "1", "main")]),
                step("`call(short)` はbyteからshortへの拡大変換で適用できます。`call(byte...)` はvarargs候補です。", [2, 3], [variable("selected method", "String", "call(short)", "compiler")]),
                step("固定長の拡大変換が優先されるため、出力は `short` です。", [2], [variable("output", "String", "short", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-parent-no-default-constructor-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "classes",
            tags: ["constructor", "super", "compile"],
            code: """
class Parent {
    Parent(int value) { }
}
class Child extends Parent {
    Child() { }
}
public class Test {
    public static void main(String[] args) {
        new Child();
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "正常にコンパイルされる", misconception: "親の引数付きコンストラクタが自動で呼ばれると誤解", explanation: "子コンストラクタ先頭には暗黙に `super()` が入ります。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "Parentには引数なしコンストラクタがないため、暗黙の `super()` を呼べません。"),
                choice("c", "実行時にNoSuchMethodErrorになる", misconception: "コンストラクタ解決を実行時問題と誤解", explanation: "ソースのコンパイル時に検出されます。"),
                choice("d", "Parent(int)に0が渡される", misconception: "デフォルト値で引数が補われると誤解", explanation: "Javaはコンストラクタ引数を自動補完しません。"),
            ],
            intent: "親クラスに引数なしコンストラクタがない場合の暗黙super呼び出しを確認する。",
            steps: [
                step("Parentには `Parent(int value)` だけがあり、引数なしコンストラクタはありません。", [1, 2], [variable("Parent()", "constructor", "missing", "Parent")]),
                step("Childのコンストラクタは明示的なthis/super呼び出しがないため、先頭に暗黙の `super()` が挿入されます。", [4, 5], [variable("implicit call", "String", "super()", "Child()")]),
                step("呼び出せるParent()がないため、コンパイルエラーになります。", [5], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-sprint-static-text-order-001",
            category: "classes",
            tags: ["static initialization", "field", "order"],
            code: """
public class Test {
    static int a = print("A");
    static {
        print("B");
    }
    static int print(String s) {
        System.out.print(s);
        return 0;
    }
    public static void main(String[] args) {
        System.out.print("C");
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "ABC", correct: true, explanation: "staticフィールド初期化A、staticブロックB、mainのCの順です。"),
                choice("b", "CAB", misconception: "mainがstatic初期化より先と誤解", explanation: "main実行前にクラス初期化が完了します。"),
                choice("c", "BAC", misconception: "staticブロックがフィールド初期化より先と誤解", explanation: "static初期化はソース上の順序で実行されます。"),
                choice("d", "C", misconception: "staticフィールドが使われないと初期化されないと誤解", explanation: "mainを呼ぶためにTestクラスが初期化されます。"),
            ],
            intent: "staticフィールド初期化とstaticブロックのソース順を確認する。",
            steps: [
                step("main実行前にTestクラスが初期化されます。まずソース上先にある `static int a = print(\"A\")` が実行されます。", [2, 6, 7], [variable("output so far", "String", "A", "class init")]),
                step("次にstaticブロックが実行され、Bを出力します。", [3, 4], [variable("output so far", "String", "AB", "class init")]),
                step("クラス初期化後にmainが実行され、Cを出力します。全体は `ABC` です。", [10, 11], [variable("output", "String", "ABC", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-enum-name-ordinal-001",
            category: "classes",
            tags: ["enum", "name", "ordinal"],
            code: """
enum Day {
    SUN, MON, TUE
}
public class Test {
    public static void main(String[] args) {
        Day d = Day.MON;
        System.out.println(d.name() + ":" + d.ordinal());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "MON:0", misconception: "ordinalが1始まりだと誤解", explanation: "ordinalは宣言順の0始まりです。"),
                choice("b", "MON:1", correct: true, explanation: "MONのnameはMON、宣言順では2番目なのでordinalは1です。"),
                choice("c", "Day.MON:1", misconception: "nameに型名も含まれると誤解", explanation: "`name()` は列挙定数名だけを返します。"),
                choice("d", "コンパイルエラー", misconception: "enumにname/ordinalがないと誤解", explanation: "すべてのenumはjava.lang.Enum由来のnameとordinalを持ちます。"),
            ],
            intent: "enumのname()とordinal()を確認する。",
            steps: [
                step("Dayの定数は `SUN, MON, TUE` の順です。ordinalは0始まりなのでSUN=0, MON=1です。", [1, 2], [variable("Day.MON.ordinal()", "int", "1", "main")]),
                step("`d.name()` は列挙定数の宣言名 `MON` を返します。", [6, 7], [variable("d.name()", "String", "MON", "main")]),
                step("連結して出力は `MON:1` です。", [7], [variable("output", "String", "MON:1", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-enum-switch-001",
            category: "control-flow",
            tags: ["enum", "switch", "case label"],
            code: """
enum Size {
    S, M, L
}
public class Test {
    public static void main(String[] args) {
        Size size = Size.M;
        switch (size) {
            case S -> System.out.print("small");
            case M -> System.out.print("medium");
            case L -> System.out.print("large");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "small", misconception: "最初のcaseから実行されると誤解", explanation: "switch式の値に一致するcaseだけが実行されます。"),
                choice("b", "medium", correct: true, explanation: "sizeはSize.Mなのでcase Mの処理が実行されます。"),
                choice("c", "Size.M", misconception: "列挙定数名が自動出力されると誤解", explanation: "case Mでは固定文字列mediumを出力しています。"),
                choice("d", "コンパイルエラー", misconception: "enum switchのcaseに型名が必須と誤解", explanation: "enum switchのcaseラベルでは `M` のように定数名だけを書きます。"),
            ],
            intent: "enumをswitchで扱う基本とcaseラベルの書き方を確認する。",
            steps: [
                step("`size` には `Size.M` が代入されています。", [6], [variable("size", "Size", "M", "main")]),
                step("switchはcase Mに一致し、arrow形式なのでその処理だけを実行します。", [7, 9], [variable("selected case", "Size", "M", "switch")]),
                step("`medium` が出力されます。", [9], [variable("output", "String", "medium", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-equals-object-override-001",
            category: "classes",
            tags: ["equals", "override", "Object"],
            code: """
class Box {
    int value;
    Box(int value) { this.value = value; }
    @Override
    public boolean equals(Object obj) {
        return obj instanceof Box b && b.value == value;
    }
}
public class Test {
    public static void main(String[] args) {
        System.out.println(new Box(1).equals(new Box(1)));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", correct: true, explanation: "equals(Object)を正しくオーバーライドしており、valueが同じなのでtrueです。"),
                choice("b", "false", misconception: "Object.equalsの参照比較のままだと誤解", explanation: "Boxはequals(Object)をオーバーライドしています。"),
                choice("c", "1", misconception: "valueが出力されると誤解", explanation: "出力しているのはequalsのboolean結果です。"),
                choice("d", "コンパイルエラー", misconception: "instanceofのパターン変数を使えないと誤解", explanation: "Java 17では `obj instanceof Box b` が利用できます。"),
            ],
            intent: "equals(Object)のオーバーライドとinstanceofパターンを確認する。",
            steps: [
                step("Boxは `equals(Object obj)` をオーバーライドしています。引数型がObjectなのでObject.equalsの正しい上書きです。", [4, 5], [variable("override", "boolean", "true", "compiler")]),
                step("比較対象は `new Box(1)` 同士です。`obj instanceof Box b` はtrueで、b.valueもvalueも1です。", [6, 11], [variable("comparison", "boolean", "1 == 1", "equals")]),
                step("equalsはtrueを返し、出力は `true` です。", [11], [variable("output", "String", "true", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-interface-static-method-001",
            category: "inheritance",
            tags: ["interface", "static method", "call"],
            code: """
interface Tool {
    static void print() {
        System.out.println("T");
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
                choice("a", "T", correct: true, explanation: "interfaceのstaticメソッドはインターフェース名で呼び出せます。"),
                choice("b", "Tool", misconception: "型名が出力されると誤解", explanation: "printメソッド本体はTを出力します。"),
                choice("c", "何も出力されない", misconception: "staticメソッドが自動実行されないと誤解", explanation: "mainから `Tool.print()` を明示的に呼んでいます。"),
                choice("d", "コンパイルエラー", misconception: "interfaceにstaticメソッドを定義できないと誤解", explanation: "interfaceにはstaticメソッドを定義できます。"),
            ],
            intent: "interface staticメソッドの定義と呼び出しを確認する。",
            steps: [
                step("Toolにはstaticメソッド `print()` が定義されています。", [1, 2], [variable("Tool.print", "static method", "prints T", "Tool")]),
                step("mainでは `Tool.print()` とインターフェース名で呼び出しています。これは有効です。", [7, 8], [variable("call", "String", "Tool.print()", "main")]),
                step("メソッド本体により `T` が出力されます。", [3], [variable("output", "String", "T", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-this-shadowing-001",
            category: "classes",
            tags: ["this", "shadowing", "constructor"],
            code: """
public class Test {
    int value;
    Test(int value) {
        value = value;
    }
    public static void main(String[] args) {
        System.out.println(new Test(5).value);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", correct: true, explanation: "`value = value` は仮引数同士の代入になり、フィールドはデフォルト値0のままです。"),
                choice("b", "5", misconception: "左辺が自動的にフィールドを指すと誤解", explanation: "仮引数がフィールドを隠しているため、フィールドには `this.value` と書く必要があります。"),
                choice("c", "コンパイルエラー", misconception: "同名の仮引数を使えないと誤解", explanation: "フィールド名と仮引数名は同じにできます。"),
                choice("d", "NullPointerException", misconception: "intフィールドをnullと混同", explanation: "intフィールドのデフォルト値は0です。"),
            ],
            intent: "フィールドと仮引数の名前が同じ場合のthisの必要性を確認する。",
            steps: [
                step("コンストラクタの仮引数 `value` はフィールド `value` を隠します。", [2, 3], [variable("parameter value", "int", "5", "Test(int)")]),
                step("`value = value;` は左辺も右辺も仮引数を指すため、フィールドには代入されません。", [4], [variable("field value", "int", "0", "object")]),
                step("生成後のフィールドvalueはデフォルト値0のままなので、出力は `0` です。", [7], [variable("output", "String", "0", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-passbyvalue-string-001",
            category: "classes",
            tags: ["method", "pass by value", "String"],
            code: """
public class Test {
    static void change(String s) {
        s.concat("B");
    }
    public static void main(String[] args) {
        String text = "A";
        change(text);
        System.out.println(text);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", correct: true, explanation: "Stringは不変で、concatの戻り値を代入していません。さらに仮引数の操作は呼び出し元textを変えません。"),
                choice("b", "AB", misconception: "concatが元のStringを書き換えると誤解", explanation: "concatは新しいStringを返します。"),
                choice("c", "B", misconception: "concatが置換だと誤解", explanation: "concatは連結ですが、この戻り値は捨てられています。"),
                choice("d", "コンパイルエラー", misconception: "Stringをメソッドへ渡せないと誤解", explanation: "参照値を値渡しできます。"),
            ],
            intent: "Stringの不変性とJavaの値渡しを確認する。",
            steps: [
                step("mainのtextは `A` を参照し、その参照値がchangeの仮引数sにコピーされます。", [5, 6, 7], [variable("text/s", "String ref", "A", "change")]),
                step("`s.concat(\"B\")` は `AB` という新しいStringを返しますが、戻り値を代入していません。", [2, 3], [variable("concat result", "String", "AB (discarded)", "change")]),
                step("mainのtextは元の `A` のままなので、出力は `A` です。", [8], [variable("output", "String", "A", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-finally-before-break-001",
            category: "exception-handling",
            tags: ["finally", "break", "loop"],
            code: """
public class Test {
    public static void main(String[] args) {
        for (int i = 0; i < 2; i++) {
            try {
                break;
            } finally {
                System.out.print("F");
            }
        }
        System.out.print("X");
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "X", misconception: "breakでfinallyがスキップされると誤解", explanation: "breakでtryを抜ける場合もfinallyは実行されます。"),
                choice("b", "FX", correct: true, explanation: "breakする前にfinallyでFを出力し、その後ループを抜けてXを出力します。"),
                choice("c", "FFX", misconception: "break後もループが続くと誤解", explanation: "breakによりforループ全体を抜けるため、finallyは1回だけです。"),
                choice("d", "コンパイルエラー", misconception: "try-finally内でbreakできないと誤解", explanation: "breakは有効で、finallyが先に実行されます。"),
            ],
            intent: "breakでtryを抜けるときもfinallyが実行されることを確認する。",
            steps: [
                step("i=0の反復でtryブロックに入り、`break` が実行されます。", [3, 4, 5], [variable("control", "String", "break pending", "try")]),
                step("breakでループを抜ける前にfinallyが実行され、Fを出力します。", [6, 7], [variable("output so far", "String", "F", "stdout")]),
                step("finally後にbreakが完了し、ループ後のXが出力されます。全体は `FX` です。", [10], [variable("output", "String", "FX", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-multicatch-related-compile-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "exception-handling",
            tags: ["multi-catch", "related types", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        try {
            throw new IllegalArgumentException();
        } catch (RuntimeException | IllegalArgumentException e) {
            System.out.println("E");
        }
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "Eと出力される", misconception: "multi-catchに親子型を並べられると誤解", explanation: "multi-catchの選択肢同士にサブクラス関係があると不正です。"),
                choice("b", "IllegalArgumentExceptionと出力される", misconception: "例外クラス名が自動出力されると誤解", explanation: "catch本体はEを出力するだけですが、そもそもコンパイルできません。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "IllegalArgumentExceptionはRuntimeExceptionのサブクラスなので、同じmulti-catchに並べられません。"),
                choice("d", "実行時にClassCastExceptionになる", misconception: "catch型の問題を実行時問題と誤解", explanation: "catch句の型関係はコンパイル時に検査されます。"),
            ],
            intent: "multi-catchで親子関係のある例外型を同時指定できないことを確認する。",
            steps: [
                step("catch句には `RuntimeException | IllegalArgumentException` が指定されています。", [5], [variable("catch alternatives", "String", "RuntimeException, IllegalArgumentException", "compiler")]),
                step("IllegalArgumentExceptionはRuntimeExceptionのサブクラスです。multi-catchでは代替型同士が親子関係にあってはいけません。", [5], [variable("related types", "boolean", "true", "compiler")]),
                step("そのためcatch句でコンパイルエラーになります。", [5], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-sprint-method-reference-length-001",
            category: "lambda-streams",
            tags: ["method reference", "Function", "String::length"],
            code: """
import java.util.function.*;

public class Test {
    public static void main(String[] args) {
        Function<String, Integer> f = String::length;
        System.out.println(f.apply("cat"));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "3", correct: true, explanation: "`String::length` は受け取ったStringのlengthを返し、`cat` の長さは3です。"),
                choice("b", "cat", misconception: "Functionが入力文字列を返すと誤解", explanation: "Functionの戻り値はIntegerで、lengthの結果です。"),
                choice("c", "true", misconception: "Predicateと混同", explanation: "Function.applyは指定した戻り値型を返します。"),
                choice("d", "コンパイルエラー", misconception: "String::lengthをFunction<String,Integer>に代入できないと誤解", explanation: "引数String、戻り値int/Integerの形に合っています。"),
            ],
            intent: "インスタンスメソッド参照 `String::length` の基本を確認する。",
            steps: [
                step("`Function<String, Integer>` はStringを受け取りIntegerを返します。`String::length` はこの形に合います。", [5], [variable("f", "Function<String,Integer>", "String::length", "main")]),
                step("`f.apply(\"cat\")` は `\"cat\".length()` と同じように評価されます。", [6], [variable("apply result", "Integer", "3", "main")]),
                step("出力は `3` です。", [6], [variable("output", "String", "3", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-predicate-negate-001",
            category: "lambda-streams",
            tags: ["Predicate", "negate", "lambda"],
            code: """
import java.util.function.*;

public class Test {
    public static void main(String[] args) {
        Predicate<String> empty = String::isEmpty;
        System.out.println(empty.negate().test("A"));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", correct: true, explanation: "`A` は空ではないため `isEmpty` はfalse。negateによりtrueになります。"),
                choice("b", "false", misconception: "negateを見落とし", explanation: "元のPredicate結果falseが反転されます。"),
                choice("c", "A", misconception: "Predicateが値を返すと誤解", explanation: "Predicate.testはbooleanを返します。"),
                choice("d", "コンパイルエラー", misconception: "Predicateにnegateがないと誤解", explanation: "Predicateにはdefaultメソッド `negate()` があります。"),
            ],
            intent: "Predicate.negateによる条件反転を確認する。",
            steps: [
                step("`empty` は `String::isEmpty` なので、文字列が空かどうかを判定します。", [5], [variable("empty", "Predicate<String>", "String::isEmpty", "main")]),
                step("`empty.test(\"A\")` はfalseです。`negate()` により結果が反転されます。", [6], [variable("negated result", "boolean", "true", "main")]),
                step("出力は `true` です。", [6], [variable("output", "String", "true", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-arraylist-add-index-001",
            category: "collections",
            tags: ["ArrayList", "add", "index"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>(List.of("A", "C"));
        list.add(1, "B");
        System.out.println(list);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "[A, B, C]", correct: true, explanation: "`add(1, \"B\")` はインデックス1へ挿入し、元のCは後ろへずれます。"),
                choice("b", "[B, A, C]", misconception: "インデックス1を先頭と誤解", explanation: "インデックスは0始まりです。"),
                choice("c", "[A, B]", misconception: "Cが置換されると誤解", explanation: "addは挿入です。置換はsetです。"),
                choice("d", "UnsupportedOperationException", misconception: "List.of由来なので変更不可と誤解", explanation: "new ArrayList<>(...) で変更可能なArrayListを作っています。"),
            ],
            intent: "ArrayList.add(index, element)の挿入動作を確認する。",
            steps: [
                step("`new ArrayList<>(List.of(\"A\", \"C\"))` により、変更可能な `[A, C]` のArrayListができます。", [5], [variable("list", "ArrayList<String>", "[A, C]", "main")]),
                step("`add(1, \"B\")` はインデックス1へBを挿入します。元のCはインデックス2へずれます。", [6], [variable("list", "ArrayList<String>", "[A, B, C]", "main")]),
                step("出力は `[A, B, C]` です。", [7], [variable("output", "String", "[A, B, C]", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-arrays-sort-mutates-001",
            category: "data-types",
            tags: ["Arrays", "sort", "mutation"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        int[] values = {3, 1, 2};
        Arrays.sort(values);
        System.out.println(Arrays.toString(values));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "[3, 1, 2]", misconception: "sortが新しい配列を返すだけで元を変えないと誤解", explanation: "Arrays.sortは渡された配列自体を並べ替えます。"),
                choice("b", "[1, 2, 3]", correct: true, explanation: "`Arrays.sort(values)` によりvalues自身が昇順に並び替えられます。"),
                choice("c", "[1, 3, 2]", misconception: "先頭だけが最小になると誤解", explanation: "配列全体が昇順にソートされます。"),
                choice("d", "コンパイルエラー", misconception: "int配列をArrays.sortできないと誤解", explanation: "Arrays.sortにはint[]用のオーバーロードがあります。"),
            ],
            intent: "Arrays.sortが配列を破壊的に並べ替えることを確認する。",
            steps: [
                step("valuesは最初 `[3, 1, 2]` です。", [5], [variable("values", "int[]", "[3, 1, 2]", "main")]),
                step("`Arrays.sort(values)` は戻り値を使うのではなく、渡された配列そのものを昇順に並べ替えます。", [6], [variable("values", "int[]", "[1, 2, 3]", "main")]),
                step("`Arrays.toString(values)` により `[1, 2, 3]` が出力されます。", [7], [variable("output", "String", "[1, 2, 3]", "stdout")]),
            ]
        ),
        q(
            "silver-sprint-catch-finally-continue-001",
            category: "exception-handling",
            tags: ["catch", "finally", "flow"],
            code: """
public class Test {
    public static void main(String[] args) {
        try {
            throw new RuntimeException();
        } catch (RuntimeException e) {
            System.out.print("C");
        } finally {
            System.out.print("F");
        }
        System.out.print("A");
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "C", misconception: "catch後にfinallyや後続処理が実行されないと誤解", explanation: "catch後にfinallyが実行され、例外が処理済みなら後続文へ進みます。"),
                choice("b", "CF", misconception: "finally後の通常処理を見落とし", explanation: "catchで例外が処理されているため、finally後にAも出力します。"),
                choice("c", "CFA", correct: true, explanation: "例外をcatchしてC、finallyでF、その後の通常処理でAを出力します。"),
                choice("d", "RuntimeException", misconception: "catchされずに例外名が出ると誤解", explanation: "RuntimeExceptionはcatchで捕捉されています。"),
            ],
            intent: "catchで処理した後のfinallyと通常処理の順序を確認する。",
            steps: [
                step("tryブロックでRuntimeExceptionが投げられ、対応するcatchへ移ります。", [3, 4, 5], [variable("exception", "RuntimeException", "caught", "catch")]),
                step("catchでCを出力し、その後finallyでFを出力します。", [6, 7, 8], [variable("output so far", "String", "CF", "stdout")]),
                step("例外は処理済みなのでfinally後の文へ進み、Aを出力します。全体は `CFA` です。", [10], [variable("output", "String", "CFA", "stdout")]),
            ]
        ),
    ]

    static let mockSpecs: [Spec] = [
        q(
            "silver-mock-sprint-postincrement-assignment-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "data-types",
            tags: ["模試専用", "post-increment", "assignment"],
            code: """
public class Test {
    public static void main(String[] args) {
        int i = 0;
        i = i++;
        System.out.println(i);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", correct: true, explanation: "`i++` は古い値0を式の値として返し、代入でその0がiへ戻されます。"),
                choice("b", "1", misconception: "インクリメント結果が最終的に残ると誤解", explanation: "一度iは1になりますが、式の値0が代入され直します。"),
                choice("c", "2", misconception: "インクリメントと代入で2回増えると誤解", explanation: "代入は増加ではありません。"),
                choice("d", "コンパイルエラー", misconception: "同じ変数へi++を代入できないと誤解", explanation: "式としては有効です。"),
            ],
            intent: "`i = i++` の評価順を模試レベルで確認する。",
            steps: [
                step("`i++` は式の値として古いiの値0を返し、その副作用でiを1にします。", [3, 4], [variable("i++ expression value", "int", "0", "main"), variable("i after increment", "int", "1", "main")]),
                step("代入 `i = ...` により、式の値0がiへ代入され直します。", [4], [variable("i", "int", "0", "main")]),
                step("最終的なiは0なので、出力は `0` です。", [5], [variable("output", "String", "0", "stdout")]),
            ]
        ),
        q(
            "silver-mock-sprint-null-array-length-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "data-types",
            tags: ["模試専用", "array", "null", "NullPointerException"],
            code: """
public class Test {
    public static void main(String[] args) {
        int[] values = null;
        try {
            System.out.println(values.length);
        } catch (NullPointerException e) {
            System.out.println("NPE");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", misconception: "null配列の長さを0と誤解", explanation: "nullは配列オブジェクトを参照していません。"),
                choice("b", "NPE", correct: true, explanation: "null参照に対して `length` を参照しようとしてNullPointerExceptionになります。"),
                choice("c", "null", misconception: "lengthがnullを返すと誤解", explanation: "lengthはintフィールドですが、参照先がないため例外です。"),
                choice("d", "コンパイルエラー", misconception: "nullをint[]へ代入できないと誤解", explanation: "参照型である配列変数にはnullを代入できます。"),
            ],
            intent: "null配列参照に対するlengthアクセスを確認する。",
            steps: [
                step("`values` はint[]型の変数ですが、値はnullです。", [3], [variable("values", "int[]", "null", "main")]),
                step("`values.length` は配列オブジェクトのlengthを読もうとしますが、参照先がないためNullPointerExceptionです。", [5], [variable("exception", "NullPointerException", "thrown", "try")]),
                step("null配列参照のlengthアクセスで発生した例外がcatchで捕捉され、`NPE` が出力されます。", [6, 7], [variable("output", "String", "NPE", "stdout")]),
            ]
        ),
        q(
            "silver-mock-sprint-isempty-isblank-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "string",
            tags: ["模試専用", "String", "isEmpty", "isBlank"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = " ";
        System.out.println(s.isEmpty() + ":" + s.isBlank());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true:true", misconception: "空白1文字を空文字と誤解", explanation: "`isEmpty()` は長さ0の場合だけtrueです。"),
                choice("b", "false:true", correct: true, explanation: "空白1文字なのでemptyではありませんが、blankではあります。"),
                choice("c", "true:false", misconception: "blankの意味を逆に理解", explanation: "空白だけの文字列はblankです。"),
                choice("d", "false:false", misconception: "空白だけでもblankではないと誤解", explanation: "`isBlank()` は空白のみならtrueです。"),
            ],
            intent: "isEmptyとisBlankの違いを確認する。",
            steps: [
                step("sは半角スペース1文字で、長さは1です。", [3], [variable("s.length()", "int", "1", "main")]),
                step("`isEmpty()` は長さ0かを見るためfalse、`isBlank()` は空白のみかを見るためtrueです。", [4], [variable("s.isEmpty()", "boolean", "false", "main"), variable("s.isBlank()", "boolean", "true", "main")]),
                step("出力は `false:true` です。", [4], [variable("output", "String", "false:true", "stdout")]),
            ]
        ),
        q(
            "silver-mock-sprint-switch-blank-final-case-001",
            difficulty: .exam,
            validatedByJavac: false,
            isMockExamOnly: true,
            category: "control-flow",
            tags: ["模試専用", "switch", "constant expression", "blank final"],
            code: """
public class Test {
    public static void main(String[] args) {
        final int value;
        value = 1;
        int n = 1;
        switch (n) {
            case value -> System.out.println("A");
        }
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "Aと出力される", misconception: "finalなら必ずcaseラベルに使えると誤解", explanation: "caseラベルにはコンパイル時定数式が必要です。"),
                choice("b", "何も出力されない", misconception: "case不一致だと誤解", explanation: "不一致以前にcaseラベルが不正です。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "blank finalを後から代入しても定数変数ではないため、caseラベルに使えません。"),
                choice("d", "実行時にIllegalStateExceptionになる", misconception: "caseラベルの検査を実行時問題と誤解", explanation: "コンパイル時に検査されます。"),
            ],
            intent: "switch caseラベルに使えるfinal変数の条件を確認する。",
            steps: [
                step("`value` はfinalですが、宣言時に初期化されていないblank finalです。", [3, 4], [variable("value", "final int", "assigned later", "main")]),
                step("switchのcaseラベルにはコンパイル時定数式が必要です。blank finalに後から代入した値は定数変数として扱われません。", [6, 7], [variable("constant expression", "boolean", "false", "compiler")]),
                step("そのため `case value` でコンパイルエラーになります。", [7], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-mock-sprint-nested-ternary-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "data-types",
            tags: ["模試専用", "ternary", "associativity"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = true ? false ? "A" : "B" : "C";
        System.out.println(s);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", misconception: "trueだけを見て最初の値が選ばれると誤解", explanation: "true側の式はさらに三項演算子です。"),
                choice("b", "B", correct: true, explanation: "三項演算子は右結合で、外側trueにより `false ? \"A\" : \"B\"` が評価され、Bになります。"),
                choice("c", "C", misconception: "外側のfalse側が選ばれると誤解", explanation: "外側条件はtrueです。"),
                choice("d", "コンパイルエラー", misconception: "三項演算子を入れ子にできないと誤解", explanation: "三項演算子は入れ子にできます。"),
            ],
            intent: "入れ子の三項演算子の結合と評価を確認する。",
            steps: [
                step("式は `true ? (false ? \"A\" : \"B\") : \"C\"` と解釈されます。", [3], [variable("outer condition", "boolean", "true", "expression")]),
                step("外側がtrueなので、true側の `false ? \"A\" : \"B\"` を評価します。ここでは条件がfalseなのでBです。", [3], [variable("inner result", "String", "B", "expression")]),
                step("sはBになり、出力は `B` です。", [4], [variable("output", "String", "B", "stdout")]),
            ]
        ),
        q(
            "silver-mock-sprint-static-field-null-ref-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "classes",
            tags: ["模試専用", "static", "null reference"],
            code: """
class Counter {
    static int value = 3;
}
public class Test {
    public static void main(String[] args) {
        Counter c = null;
        System.out.println(c.value);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "3", correct: true, explanation: "staticフィールドは参照式の実体ではなく型に属するため、null参照経由でもCounter.valueとして解決されます。"),
                choice("b", "0", misconception: "null経由だとデフォルト値になると誤解", explanation: "参照先オブジェクトは使われず、staticフィールドの値3を読みます。"),
                choice("c", "NullPointerException", misconception: "staticフィールドでもnull参照を評価して落ちると誤解", explanation: "推奨されない書き方ですが、staticメンバは型で解決されます。"),
                choice("d", "コンパイルエラー", misconception: "インスタンス参照経由でstaticフィールドを読めないと誤解", explanation: "警告相当のスタイルですがコンパイルは可能です。"),
            ],
            intent: "null参照経由のstaticフィールドアクセスを確認する。",
            steps: [
                step("`Counter.value` はstaticフィールドで、クラスCounterに属します。", [1, 2], [variable("Counter.value", "static int", "3", "Counter")]),
                step("変数cはnullですが、`c.value` はコンパイル時型Counterに基づいてstaticフィールド参照として解決されます。", [6, 7], [variable("c", "Counter", "null", "main")]),
                step("オブジェクトの参照先を読まないためNullPointerExceptionにはならず、`3` が出力されます。", [7], [variable("output", "String", "3", "stdout")]),
            ]
        ),
        q(
            "silver-mock-sprint-enum-valueof-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "classes",
            tags: ["模試専用", "enum", "valueOf", "IllegalArgumentException"],
            code: """
enum Level {
    LOW, HIGH
}
public class Test {
    public static void main(String[] args) {
        try {
            System.out.println(Level.valueOf("low"));
        } catch (IllegalArgumentException e) {
            System.out.println("IAE");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "LOW", misconception: "valueOfが大文字小文字を無視すると誤解", explanation: "enumのvalueOfは宣言名と完全一致が必要です。"),
                choice("b", "low", misconception: "入力文字列がそのまま返ると誤解", explanation: "valueOfは列挙定数を探します。"),
                choice("c", "IAE", correct: true, explanation: "`low` は宣言名 `LOW` と一致しないためIllegalArgumentExceptionが発生します。"),
                choice("d", "コンパイルエラー", misconception: "enumにvalueOfがないと誤解", explanation: "各enum型にはvalueOf(String)が用意されます。"),
            ],
            intent: "enum.valueOfの大文字小文字の厳密さを確認する。",
            steps: [
                step("Levelの定数名は `LOW` と `HIGH` です。", [1, 2], [variable("constants", "Level[]", "LOW, HIGH", "Level")]),
                step("`Level.valueOf(\"low\")` は小文字のlowを探しますが、宣言名と完全一致しません。", [7], [variable("lookup", "String", "low", "valueOf")]),
                step("IllegalArgumentExceptionが発生し、catchで `IAE` が出力されます。", [8, 9], [variable("output", "String", "IAE", "stdout")]),
            ]
        ),
        q(
            "silver-mock-sprint-interface-static-instance-call-001",
            difficulty: .exam,
            validatedByJavac: false,
            isMockExamOnly: true,
            category: "inheritance",
            tags: ["模試専用", "interface", "static method", "compile"],
            code: """
interface Tool {
    static void print() {
        System.out.println("T");
    }
}
class Hammer implements Tool {
}
public class Test {
    public static void main(String[] args) {
        new Hammer().print();
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "Tと出力される", misconception: "interface staticメソッドが実装クラスのインスタンスから呼べると誤解", explanation: "interfaceのstaticメソッドは継承されません。"),
                choice("b", "何も出力されない", misconception: "呼び出しが無視されると誤解", explanation: "不正な呼び出しとしてコンパイルエラーです。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "Tool.printは `Tool.print()` として呼ぶ必要があり、Hammerインスタンスからは呼べません。"),
                choice("d", "NullPointerExceptionになる", misconception: "インスタンス呼び出しを実行時問題と誤解", explanation: "そもそもメソッド解決ができずコンパイルエラーです。"),
            ],
            intent: "interface staticメソッドは実装クラスへ継承されないことを確認する。",
            steps: [
                step("Toolの `print()` はstaticメソッドです。interface staticメソッドは実装クラスへインスタンスメソッドとして継承されません。", [1, 2, 6], [variable("Tool.print", "static method", "not inherited", "Tool")]),
                step("`new Hammer().print()` はHammerインスタンスからprintを探しますが、該当するインスタンスメソッドはありません。", [10], [variable("method lookup", "String", "not found", "compiler")]),
                step("そのためコンパイルエラーです。正しくは `Tool.print()` です。", [10], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-mock-sprint-private-constructor-factory-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "classes",
            tags: ["模試専用", "private constructor", "factory"],
            code: """
class Box {
    private Box() {
        System.out.print("B");
    }
    static Box create() {
        return new Box();
    }
}
public class Test {
    public static void main(String[] args) {
        Box.create();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "B", correct: true, explanation: "privateコンストラクタはBoxクラス内のstaticメソッドcreateから呼び出せます。"),
                choice("b", "何も出力されない", misconception: "createがコンストラクタを呼ばないと誤解", explanation: "`return new Box();` でコンストラクタが実行されます。"),
                choice("c", "コンパイルエラー", misconception: "privateコンストラクタがあるクラスは外部から一切使えないと誤解", explanation: "外部から直接newはできませんが、公開されたstaticメソッドは呼べます。"),
                choice("d", "IllegalAccessError", misconception: "同じクラス内のprivateアクセスを実行時エラーと誤解", explanation: "Box内からのprivateコンストラクタ呼び出しは有効です。"),
            ],
            intent: "privateコンストラクタとstatic factoryメソッドの関係を確認する。",
            steps: [
                step("mainは `Box.create()` を呼びます。createはBoxクラス内のstaticメソッドです。", [10, 11, 5], [variable("method", "String", "Box.create", "main")]),
                step("create内の `new Box()` はBoxクラス自身からprivateコンストラクタを呼んでいるため有効です。", [2, 6], [variable("access", "boolean", "allowed", "Box")]),
                step("コンストラクタ本体でBを出力します。", [3], [variable("output", "String", "B", "stdout")]),
            ]
        ),
        q(
            "silver-mock-sprint-lambda-capture-reassign-reference-001",
            difficulty: .exam,
            validatedByJavac: false,
            isMockExamOnly: true,
            category: "lambda-streams",
            tags: ["模試専用", "lambda", "effectively final", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("A");
        Runnable r = () -> System.out.println(sb);
        sb = new StringBuilder("B");
        r.run();
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "Aと出力される", misconception: "ラムダが最初の参照をコピーするので再代入してもよいと誤解", explanation: "ラムダから参照するローカル変数は実質的finalである必要があります。"),
                choice("b", "Bと出力される", misconception: "変更後の参照を読めると誤解", explanation: "再代入があるためコンパイルできません。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "sbはラムダ内で参照された後に再代入されており、実質的finalではありません。"),
                choice("d", "NullPointerExceptionになる", misconception: "実質的final制約を実行時問題と誤解", explanation: "コンパイル時に検査されます。"),
            ],
            intent: "ラムダが参照するローカル変数の再代入禁止を確認する。",
            steps: [
                step("ラムダ `() -> System.out.println(sb)` はローカル変数sbを参照しています。", [3, 4], [variable("captured variable", "StringBuilder", "sb", "lambda")]),
                step("その後 `sb = new StringBuilder(\"B\")` でsb自体を再代入しています。これによりsbは実質的finalではありません。", [5], [variable("effectively final", "boolean", "false", "compiler")]),
                step("ラムダから参照できる条件を満たさないため、コンパイルエラーです。", [4, 5], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-mock-sprint-arraylist-remove-chain-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "collections",
            tags: ["模試専用", "ArrayList", "remove", "index"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>(List.of("A", "B", "C"));
        System.out.print(list.remove(1));
        System.out.println(":" + list);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "B:[A, C]", correct: true, explanation: "`remove(1)` はインデックス1のBを削除し、その削除された要素Bを返します。"),
                choice("b", "true:[A, C]", misconception: "remove(int)の戻り値をbooleanと誤解", explanation: "remove(Object)はbooleanですが、remove(int)は削除要素を返します。"),
                choice("c", "A:[B, C]", misconception: "インデックス1を先頭と誤解", explanation: "インデックスは0始まりなので1はBです。"),
                choice("d", "IndexOutOfBoundsException", misconception: "インデックス1が範囲外と誤解", explanation: "3要素のリストでインデックス1は有効です。"),
            ],
            intent: "ArrayList.remove(int)の戻り値とリスト更新を確認する。",
            steps: [
                step("listは最初 `[A, B, C]` です。", [5], [variable("list", "List<String>", "[A, B, C]", "main")]),
                step("`list.remove(1)` はインデックス1のBを削除し、戻り値としてBを返します。listは `[A, C]` になります。", [6], [variable("removed", "String", "B", "main"), variable("list", "List<String>", "[A, C]", "main")]),
                step("続けて `:` とlistを出力し、全体は `B:[A, C]` です。", [7], [variable("output", "String", "B:[A, C]", "stdout")]),
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

extension SilverSprintQuestionData.Spec {
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
    static let silverSprintExpansion: [Quiz] = SilverSprintQuestionData.practiceSpecs.map(\.quiz)
    static let silverSprintMockExpansion: [Quiz] = SilverSprintQuestionData.mockSpecs.map(\.quiz)
}
