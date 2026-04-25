import Foundation

enum SilverCapstoneQuestionData {
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
            "silver-capstone-literal-underscore-001",
            category: "data-types",
            tags: ["numeric literal", "underscore", "operator"],
            code: """
public class Test {
    public static void main(String[] args) {
        int n = 1_2 + 3;
        System.out.println(n);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "6", misconception: "1_2を1と2の加算のように解釈", explanation: "数値リテラル中のアンダースコアは桁区切りで、値は12です。"),
                choice("b", "15", correct: true, explanation: "`1_2` は整数リテラル12なので、12 + 3 = 15です。"),
                choice("c", "123", misconception: "文字列連結と混同", explanation: "これはint同士の加算です。"),
                choice("d", "コンパイルエラー", misconception: "数値リテラルにアンダースコアを使えないと誤解", explanation: "桁の間に置いたアンダースコアは有効です。"),
            ],
            intent: "数値リテラル内アンダースコアの扱いを確認する。",
            steps: [
                step("`1_2` のアンダースコアは桁区切りで、数値としては12です。", [3], [variable("1_2", "int literal", "12", "main")]),
                step("`12 + 3` が計算され、nは15になります。", [3], [variable("n", "int", "15", "main")]),
                step("printlnで `15` が出力されます。", [4], [variable("output", "String", "15", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-float-literal-compile-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "data-types",
            tags: ["float", "literal", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        float f = 1.0;
        System.out.println(f);
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "1.0と出力される", misconception: "小数リテラルがfloatだと誤解", explanation: "小数リテラル `1.0` はデフォルトでdoubleです。"),
                choice("b", "1と出力される", misconception: "float代入で整数表示になると誤解", explanation: "そもそも代入がコンパイルできません。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "doubleリテラルをfloatへ暗黙に縮小変換できません。`1.0f` かキャストが必要です。"),
                choice("d", "実行時にClassCastExceptionになる", misconception: "プリミティブ変換を実行時キャストと混同", explanation: "これはコンパイル時の型チェックです。"),
            ],
            intent: "float変数へ `1.0` を代入すると、doubleリテラルの縮小変換不足でコンパイルエラーになることを確認する。",
            steps: [
                step("`1.0` はサフィックスなしの小数リテラルなのでdouble型です。", [3], [variable("1.0", "double literal", "1.0", "compiler")]),
                step("doubleからfloatへの代入は縮小変換であり、明示キャストなしではできません。", [3], [variable("assignment", "double -> float", "not allowed", "compiler")]),
                step("そのため3行目でコンパイルエラーになります。", [3], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-capstone-long-suffix-001",
            category: "data-types",
            tags: ["long", "literal", "promotion"],
            code: """
public class Test {
    public static void main(String[] args) {
        long n = 2L;
        System.out.println(n + 1);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2", misconception: "加算が行われないと誤解", explanation: "`n + 1` を出力しています。"),
                choice("b", "3", correct: true, explanation: "`2L` はlongリテラルで、intの1はlongへ昇格して3になります。"),
                choice("c", "3L", misconception: "longサフィックスが出力にも付くと誤解", explanation: "数値の表示にリテラルサフィックスは付きません。"),
                choice("d", "コンパイルエラー", misconception: "longとintを加算できないと誤解", explanation: "intはlongへ数値昇格されます。"),
            ],
            intent: "longリテラルと二項数値昇格を確認する。",
            steps: [
                step("`2L` によりnはlong値2になります。", [3], [variable("n", "long", "2", "main")]),
                step("`n + 1` ではintの1がlongへ昇格し、longの3になります。", [4], [variable("n + 1", "long", "3", "main")]),
                step("出力は数値文字列 `3` です。", [4], [variable("output", "String", "3", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-mod-negative-001",
            category: "data-types",
            tags: ["remainder", "negative", "operator"],
            code: """
public class Test {
    public static void main(String[] args) {
        int r = -5 % 2;
        System.out.println(r);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "-1", correct: true, explanation: "Javaの剰余は左オペランドの符号を持つため、-5 % 2 は -1 です。"),
                choice("b", "1", misconception: "剰余は常に正になると誤解", explanation: "Javaでは左側が負なら結果も負になり得ます。"),
                choice("c", "0", misconception: "5が2で割り切れると誤解", explanation: "5は2で割ると余り1です。符号により-1になります。"),
                choice("d", "ArithmeticException", misconception: "負数の剰余が例外になると誤解", explanation: "0除算ではないため例外になりません。"),
            ],
            intent: "負数を含む剰余演算の符号を確認する。",
            steps: [
                step("`-5 / 2` は0方向へ丸められて -2 です。", [3], [variable("-5 / 2", "int", "-2", "calculation")]),
                step("剰余は `-5 - (-2 * 2)` なので -1 になります。", [3], [variable("r", "int", "-1", "main")]),
                step("したがって出力は `-1` です。", [4], [variable("output", "String", "-1", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-string-constant-concat-001",
            category: "string",
            tags: ["String", "constant expression", "pool"],
            code: """
public class Test {
    public static void main(String[] args) {
        String a = "Ja" + "va";
        String b = "Java";
        System.out.println(a == b);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", correct: true, explanation: "文字列リテラル同士の連結はコンパイル時定数式となり、同じ文字列プールの参照になります。"),
                choice("b", "false", misconception: "文字列連結は常に実行時に新規生成すると誤解", explanation: "リテラル同士の連結はコンパイル時に畳み込まれます。"),
                choice("c", "Java", misconception: "比較結果ではなく文字列本体が出ると誤解", explanation: "出力しているのは `a == b` のboolean結果です。"),
                choice("d", "コンパイルエラー", misconception: "Stringを==で比較できないと誤解", explanation: "参照比較としてコンパイルできます。"),
            ],
            intent: "文字列定数式とStringプールを確認する。",
            steps: [
                step("`\"Ja\" + \"va\"` はリテラル同士なのでコンパイル時に `\"Java\"` へ畳み込まれます。", [3], [variable("a", "String", "pooled Java", "main")]),
                step("`b` も同じ文字列リテラル `\"Java\"` を参照します。", [4], [variable("b", "String", "same pooled Java", "main")]),
                step("`a == b` は同じ参照の比較なのでtrueです。", [5], [variable("output", "String", "true", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-string-runtime-concat-001",
            category: "string",
            tags: ["String", "runtime concat", "equals"],
            code: """
public class Test {
    public static void main(String[] args) {
        String x = "Ja";
        String a = x + "va";
        String b = "Java";
        System.out.println((a == b) + ":" + a.equals(b));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true:true", misconception: "実行時連結もプール参照になると誤解", explanation: "変数を含む連結は実行時に新しいStringを作ります。"),
                choice("b", "false:true", correct: true, explanation: "参照は別ですが、文字列内容は同じなのでequalsはtrueです。"),
                choice("c", "false:false", misconception: "equalsも参照比較だと誤解", explanation: "String.equalsは内容比較です。"),
                choice("d", "コンパイルエラー", misconception: "Stringとbooleanの連結ができないと誤解", explanation: "boolean結果は文字列連結できます。"),
            ],
            intent: "実行時文字列連結と==/equalsの違いを確認する。",
            steps: [
                step("`x + \"va\"` は変数xを含むため実行時連結で、新しいStringオブジェクトになります。", [3, 4], [variable("a", "String", "new Java", "main")]),
                step("`b` は文字列プール上の `Java` です。aとbは内容は同じでも参照は通常異なります。", [5], [variable("a == b", "boolean", "false", "main")]),
                step("`a.equals(b)` は内容比較なのでtrueとなり、出力は `false:true` です。", [6], [variable("output", "String", "false:true", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-string-startswith-offset-001",
            category: "string",
            tags: ["String", "startsWith", "offset"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = "java";
        System.out.println(s.startsWith("va", 2));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", correct: true, explanation: "`java` のインデックス2からは `va` が始まるためtrueです。"),
                choice("b", "false", misconception: "文字列全体の先頭だけを見ると誤解", explanation: "第2引数により、比較開始位置を指定しています。"),
                choice("c", "2", misconception: "開始位置が返ると誤解", explanation: "`startsWith` の戻り値はbooleanです。"),
                choice("d", "コンパイルエラー", misconception: "startsWithに第2引数を指定できないと誤解", explanation: "`startsWith(String prefix, int toffset)` が存在します。"),
            ],
            intent: "startsWithのオフセット指定版を確認する。",
            steps: [
                step("`s` は `java` で、インデックス0=j, 1=a, 2=v, 3=aです。", [3], [variable("s", "String", "java", "main")]),
                step("`startsWith(\"va\", 2)` はインデックス2から `va` で始まるかを調べます。", [4], [variable("substring from 2", "String", "va", "main")]),
                step("条件を満たすため、出力は `true` です。", [4], [variable("output", "String", "true", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-stringbuilder-reverse-001",
            category: "string",
            tags: ["StringBuilder", "reverse", "append"],
            code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("ab");
        sb.reverse().append("c"); // reverse mutates the same builder
        System.out.println(sb);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "abc", misconception: "reverseが戻り値だけで本体を変えないと誤解", explanation: "StringBuilder.reverseは本体を変更します。"),
                choice("b", "bac", correct: true, explanation: "`ab` が `ba` に反転し、そこへ `c` が追加されます。"),
                choice("c", "cba", misconception: "append後にreverseされると誤解", explanation: "呼び出し順はreverseが先、appendが後です。"),
                choice("d", "コンパイルエラー", misconception: "reverseとappendを連鎖できないと誤解", explanation: "どちらもStringBuilderを返すため連鎖できます。"),
            ],
            intent: "StringBuilderの可変操作とメソッドチェーンを確認する。",
            steps: [
                step("初期状態のsbは `ab` です。", [3], [variable("sb", "StringBuilder", "ab", "main")]),
                step("`reverse()` により同じStringBuilderが `ba` に変更されます。", [4], [variable("after reverse", "StringBuilder", "ba", "main")]),
                step("続く `append(\"c\")` で `bac` になり、それが出力されます。", [4, 5], [variable("output", "String", "bac", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-arrays-binarysearch-001",
            category: "data-types",
            tags: ["Arrays", "binarySearch", "insertion point"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        int[] values = {1, 3, 5};
        System.out.println(Arrays.binarySearch(values, 4));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2", misconception: "挿入位置がそのまま返ると誤解", explanation: "見つからない場合は `-(挿入位置) - 1` です。"),
                choice("b", "-2", misconception: "挿入位置1と誤解", explanation: "4は3と5の間なので挿入位置は2です。"),
                choice("c", "-3", correct: true, explanation: "4の挿入位置は2なので、戻り値は `-2 - 1 = -3` です。"),
                choice("d", "ArrayIndexOutOfBoundsException", misconception: "未発見時に例外になると誤解", explanation: "binarySearchは未発見時に負の値を返します。"),
            ],
            intent: "Arrays.binarySearchの未発見時戻り値を確認する。",
            steps: [
                step("配列はソート済みの `[1, 3, 5]` です。4は存在しません。", [5, 6], [variable("values", "int[]", "[1, 3, 5]", "main")]),
                step("4を挿入するとインデックス2に入ります。未発見時の戻り値は `-(insertionPoint) - 1` です。", [6], [variable("insertion point", "int", "2", "binarySearch")]),
                step("`-2 - 1` で -3 が出力されます。", [6], [variable("output", "String", "-3", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-arrays-compare-001",
            category: "data-types",
            tags: ["Arrays", "compare", "lexicographic"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        int[] a = {1, 2};
        int[] b = {1, 3};
        System.out.println(Arrays.compare(a, b));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "-1", correct: true, explanation: "先頭は同じ1、次に2と3を比較し、2 < 3なので負の値になります。このケースでは-1です。"),
                choice("b", "0", misconception: "先頭要素だけで等しいと判断", explanation: "辞書順比較では次の要素も比較します。"),
                choice("c", "1", misconception: "配列長が同じなら正になると誤解", explanation: "要素2と3の比較でaの方が小さいです。"),
                choice("d", "コンパイルエラー", misconception: "int配列をcompareできないと誤解", explanation: "Arrays.compareにはint[]用のオーバーロードがあります。"),
            ],
            intent: "Arrays.compareの辞書順比較を確認する。",
            steps: [
                step("aは `[1, 2]`、bは `[1, 3]` です。", [5, 6], [variable("a", "int[]", "[1, 2]", "main"), variable("b", "int[]", "[1, 3]", "main")]),
                step("最初の要素1と1は等しいため、次に2と3を比較します。", [7], [variable("first differing pair", "int", "2 vs 3", "Arrays.compare")]),
                step("2は3より小さいため負の値、このケースでは `-1` が出力されます。", [7], [variable("output", "String", "-1", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-list-of-immutable-001",
            category: "collections",
            tags: ["List.of", "immutable", "UnsupportedOperationException"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> list = List.of("A");
        try {
            list.add("B");
        } catch (UnsupportedOperationException e) {
            System.out.println(list.size());
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1", correct: true, explanation: "`List.of` のリストは変更不可なのでaddで例外になり、元のサイズ1を出力します。"),
                choice("b", "2", misconception: "addが成功すると誤解", explanation: "`List.of` の戻り値は変更不可です。"),
                choice("c", "0", misconception: "例外時にリストが空になると誤解", explanation: "元の要素Aは残っています。"),
                choice("d", "コンパイルエラー（List.of）", misconception: "List.ofをList<String>へ代入できないと誤解", explanation: "代入は可能です。変更操作が実行時例外になります。"),
            ],
            intent: "List.ofの変更不可リストを確認する。",
            steps: [
                step("`List.of(\"A\")` で要素Aを持つ変更不可リストを作ります。", [5], [variable("list", "List<String>", "[A]", "main")]),
                step("`list.add(\"B\")` は変更操作なのでUnsupportedOperationExceptionが発生します。", [7], [variable("exception", "UnsupportedOperationException", "thrown", "try")]),
                step("catchで元のlist.size()を出力し、サイズは1です。", [8, 9], [variable("output", "String", "1", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-arraylist-contains-builder-001",
            category: "collections",
            tags: ["ArrayList", "contains", "equals", "StringBuilder"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<StringBuilder> list = new ArrayList<>();
        list.add(new StringBuilder("A"));
        System.out.println(list.contains(new StringBuilder("A")));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", misconception: "StringBuilder.equalsが内容比較だと誤解", explanation: "StringBuilderはequalsを内容比較としてオーバーライドしていません。"),
                choice("b", "false", correct: true, explanation: "containsはequalsで比較しますが、別のStringBuilder同士は参照が違うためfalseです。"),
                choice("c", "A", misconception: "要素そのものが出力されると誤解", explanation: "出力しているのはcontainsのboolean結果です。"),
                choice("d", "コンパイルエラー", misconception: "List<StringBuilder>にStringBuilderを追加できないと誤解", explanation: "型は一致しています。"),
            ],
            intent: "containsがequalsを使うこととStringBuilder.equalsの挙動を確認する。",
            steps: [
                step("listには `new StringBuilder(\"A\")` が1つ入ります。", [5, 6], [variable("stored object", "StringBuilder", "A", "list")]),
                step("containsには別インスタンスの `new StringBuilder(\"A\")` を渡しています。StringBuilderは内容equalsではありません。", [7], [variable("equals result", "boolean", "false", "contains")]),
                step("したがってcontainsはfalseを返し、出力は `false` です。", [7], [variable("output", "String", "false", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-for-update-order-001",
            category: "control-flow",
            tags: ["for", "update expression", "evaluation order"],
            code: """
public class Test {
    public static void main(String[] args) {
        for (int i = 0; i < 3; System.out.print("u" + i), i++) {
            System.out.print(i);
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "012u0u1u2", misconception: "更新式が最後にまとめて実行されると誤解", explanation: "更新式は各反復の本体後に実行されます。"),
                choice("b", "0u01u12u2", correct: true, explanation: "各本体でiを出力し、その直後の更新式で `u` と現在のiを出力してからi++します。"),
                choice("c", "u00u11u22", misconception: "更新式が本体より先に実行されると誤解", explanation: "forの更新式は本体の後です。"),
                choice("d", "コンパイルエラー", misconception: "for更新式にメソッド呼び出しを書けないと誤解", explanation: "更新式には式文として有効なメソッド呼び出しやインクリメントを書けます。"),
            ],
            intent: "for文の本体と更新式の実行順を確認する。",
            steps: [
                step("i=0で本体が先に実行され、`0` を出力します。その後更新式で `u0` を出力してiが1になります。", [3, 4], [variable("after first", "String", "0u0", "stdout")]),
                step("同様にi=1で `1u1`、i=2で `2u2` が続きます。", [3, 4], [variable("sequence", "String", "0u0 1u1 2u2", "loop")]),
                step("連結された全体の出力は `0u01u12u2` です。", [3, 4], [variable("output", "String", "0u01u12u2", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-break-inner-001",
            category: "control-flow",
            tags: ["break", "nested loop", "inner loop"],
            code: """
public class Test {
    public static void main(String[] args) {
        for (int i = 0; i < 2; i++) {
            for (int j = 0; j < 3; j++) {
                if (j == 1) break;
                System.out.print(i + "" + j + " ");
            }
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "00 10 ", correct: true, explanation: "各iでj=0だけ出力し、j=1で内側ループをbreakします。"),
                choice("b", "00 01 10 11 ", misconception: "break条件を出力後に見ていると誤解", explanation: "j==1のときは出力前にbreakします。"),
                choice("c", "00 ", misconception: "breakが外側ループまで抜けると誤解", explanation: "ラベルなしbreakは内側ループだけを抜けます。"),
                choice("d", "00 01 02 10 11 12 ", misconception: "breakを無視している", explanation: "j==1で内側ループが終了します。"),
            ],
            intent: "ラベルなしbreakが最も内側のループだけを抜けることを確認する。",
            steps: [
                step("i=0ではj=0で `00 ` を出力し、j=1でbreakして内側ループを抜けます。", [3, 4, 5, 6], [variable("output after i=0", "String", "00 ", "stdout")]),
                step("外側ループは続くためi=1に進み、j=0で `10 ` を出力して、j=1で再び内側だけbreakします。", [3, 4, 5, 6], [variable("output after i=1", "String", "00 10 ", "stdout")]),
                step("最終出力は `00 10 ` です。", [6], [variable("output", "String", "00 10 ", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-switch-statement-no-match-001",
            category: "control-flow",
            tags: ["switch", "statement", "default"],
            code: """
public class Test {
    public static void main(String[] args) {
        int n = 3;
        switch (n) {
            case 1: System.out.print("A");
        }
        System.out.print("X");
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", misconception: "case 1が実行されると誤解", explanation: "nは3なのでcase 1には一致しません。"),
                choice("b", "X", correct: true, explanation: "一致するcaseもdefaultもないためswitch内では何も実行されず、その後Xを出力します。"),
                choice("c", "AX", misconception: "caseが順に実行されると誤解", explanation: "一致するcaseがなければcase本体は実行されません。"),
                choice("d", "コンパイルエラー", misconception: "switch文にはdefaultが必須と誤解", explanation: "switch文ではdefaultは必須ではありません。"),
            ],
            intent: "switch文で一致なし・defaultなしの場合の流れを確認する。",
            steps: [
                step("switch式の値nは3です。caseは1だけなので一致しません。", [3, 4, 5], [variable("n", "int", "3", "main")]),
                step("defaultもないためswitchブロック内では何も出力されません。", [4, 5, 6], [variable("switch output", "String", "", "stdout")]),
                step("switch後の `System.out.print(\"X\")` が実行され、出力は `X` です。", [7], [variable("output", "String", "X", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-switch-duplicate-compile-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "control-flow",
            tags: ["switch", "duplicate case", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        int n = 1;
        switch (n) {
            case 1: System.out.print("A");
            case 1: System.out.print("B");
        }
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "ABと出力される", misconception: "重複caseが許可されると誤解", explanation: "同じswitch内で同じcaseラベルは使えません。"),
                choice("b", "Aと出力される", misconception: "2つ目のcaseが無視されると誤解", explanation: "重複caseはコンパイルエラーです。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "`case 1` が重複しているためコンパイルエラーです。"),
                choice("d", "実行時にIllegalStateExceptionになる", misconception: "case重複を実行時検査と誤解", explanation: "switchラベルの重複はコンパイル時に検出されます。"),
            ],
            intent: "switchのcaseラベル重複がコンパイルエラーになることを確認する。",
            steps: [
                step("switch内に `case 1` が2回現れています。", [5, 6], [variable("case labels", "int", "1, 1", "switch")]),
                step("同じswitchブロック内で同じ定数ラベルは重複できません。", [5, 6], [variable("duplicate", "boolean", "true", "compiler")]),
                step("そのためコンパイルエラーになります。", [6], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-capstone-overload-char-exact-001",
            category: "overload-resolution",
            tags: ["overload", "char", "exact match"],
            code: """
public class Test {
    static void call(char c) { System.out.println("char"); }
    static void call(int i) { System.out.println("int"); }
    public static void main(String[] args) {
        call('A');
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "char", correct: true, explanation: "実引数はcharリテラルなので、完全一致する `call(char)` が選ばれます。"),
                choice("b", "int", misconception: "charは常にintへ昇格されると誤解", explanation: "完全一致候補があるためchar版が優先されます。"),
                choice("c", "A", misconception: "引数そのものが出力されると誤解", explanation: "メソッド本体は固定文字列を出力しています。"),
                choice("d", "コンパイルエラー", misconception: "charとintのオーバーロードが曖昧と誤解", explanation: "完全一致のcharがあるため曖昧ではありません。"),
            ],
            intent: "オーバーロード解決で完全一致が優先されることを確認する。",
            steps: [
                step("`'A'` の型はcharです。", [5], [variable("argument", "char", "A", "main")]),
                step("候補にはchar版とint版があります。char版は完全一致、int版は拡大変換です。", [2, 3], [variable("selected method", "String", "call(char)", "compiler")]),
                step("char版が実行され、出力は `char` です。", [2], [variable("output", "String", "char", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-overload-long-literal-001",
            category: "overload-resolution",
            tags: ["overload", "long", "literal"],
            code: """
public class Test {
    static void call(int i) { System.out.println("int"); }
    static void call(long l) { System.out.println("long"); }
    public static void main(String[] args) {
        call(1L);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "int", misconception: "値がint範囲ならint版が選ばれると誤解", explanation: "リテラル `1L` の型はlongです。"),
                choice("b", "long", correct: true, explanation: "`1L` はlongリテラルなので、完全一致するlong版が選ばれます。"),
                choice("c", "コンパイルエラー", misconception: "longからintへ自動変換されないため全体がエラーと誤解", explanation: "long版があるため問題ありません。"),
                choice("d", "1", misconception: "引数の値が出力されると誤解", explanation: "メソッド本体は文字列 `long` を出力します。"),
            ],
            intent: "longリテラルによるオーバーロード選択を確認する。",
            steps: [
                step("`1L` はlong型のリテラルです。", [5], [variable("argument", "long", "1", "main")]),
                step("`call(long)` が完全一致し、`call(int)` への縮小変換は自動では行われません。", [2, 3], [variable("selected method", "String", "call(long)", "compiler")]),
                step("long版が実行され、出力は `long` です。", [3], [variable("output", "String", "long", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-private-constructor-other-class-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "classes",
            tags: ["constructor", "private", "access"],
            code: """
class Box {
    private Box() {
    }
}
public class Test {
    public static void main(String[] args) {
        new Box();
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "正常にコンパイルできる", misconception: "同じファイルならprivateにアクセスできると誤解", explanation: "privateは同じトップレベルクラス内に限定されます。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "`Box()` はBoxクラス内からしか呼べないprivateコンストラクタです。Testからは呼べません。"),
                choice("c", "実行時にIllegalAccessErrorになる", misconception: "アクセス制御を実行時まで遅らせると誤解", explanation: "ソースからの不正アクセスはコンパイル時に検出されます。"),
                choice("d", "nullが代入される", misconception: "new失敗時にnullになると誤解", explanation: "new式はアクセス不可ならコンパイルできません。"),
            ],
            intent: "privateコンストラクタは別トップレベルクラスの `new Box()` から呼べないことを確認する。",
            steps: [
                step("Boxのコンストラクタはprivateです。", [1, 2], [variable("Box()", "constructor", "private", "Box")]),
                step("`new Box()` はTestクラスのmainから呼ばれています。TestはBoxとは別のトップレベルクラスです。", [5, 6, 7], [variable("access allowed", "boolean", "false", "compiler")]),
                step("そのため7行目でコンパイルエラーになります。", [7], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-capstone-blank-final-constructor-001",
            category: "classes",
            tags: ["final", "field", "constructor"],
            code: """
public class Test {
    final int value;
    Test() {
        value = 5;
    }
    public static void main(String[] args) {
        System.out.println(new Test().value);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", misconception: "finalフィールドがデフォルト値のまま固定されると誤解", explanation: "blank finalはコンストラクタで一度だけ代入できます。"),
                choice("b", "5", correct: true, explanation: "finalフィールドvalueはコンストラクタで確実に1回代入され、その値5が出力されます。"),
                choice("c", "コンパイルエラー", misconception: "finalフィールドは宣言時に必ず初期化が必要と誤解", explanation: "blank finalはコンストラクタで初期化できます。"),
                choice("d", "IllegalAccessError", misconception: "finalフィールドの読み取りが実行時エラーになると誤解", explanation: "同じクラス内から読み取っており問題ありません。"),
            ],
            intent: "blank finalフィールドをコンストラクタで初期化できることを確認する。",
            steps: [
                step("`final int value;` は宣言時には未代入のblank finalフィールドです。", [2], [variable("value", "final int", "unassigned", "object")]),
                step("コンストラクタで `value = 5;` と一度だけ代入しています。", [3, 4], [variable("value", "final int", "5", "object")]),
                step("生成したTestのvalueを出力するため、結果は `5` です。", [7], [variable("output", "String", "5", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-static-final-reassign-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "classes",
            tags: ["static final", "blank final", "compile"],
            code: """
public class Test {
    static final int VALUE;
    static {
        VALUE = 1;
        VALUE = 2;
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "正常にコンパイルされ、VALUEは2になる", misconception: "static finalをstaticブロック内なら何度も代入できると誤解", explanation: "blank finalでも代入は一度だけです。"),
                choice("b", "正常にコンパイルされ、VALUEは1になる", misconception: "2回目の代入が無視されると誤解", explanation: "2回目の代入はコンパイルエラーです。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "static finalフィールドVALUEに2回代入しているためエラーです。"),
                choice("d", "実行時にIllegalStateExceptionになる", misconception: "final再代入を実行時検査と誤解", explanation: "finalへの再代入はコンパイル時に検出されます。"),
            ],
            intent: "blank static finalへの代入は一度だけであることを確認する。",
            steps: [
                step("`VALUE` は初期化式なしのstatic finalフィールドです。", [2], [variable("VALUE", "static final int", "blank", "Test")]),
                step("static初期化ブロック内で最初の `VALUE = 1;` は初期化として有効です。", [3, 4], [variable("VALUE", "int", "1", "static init")]),
                step("続く `VALUE = 2;` はfinalフィールドへの再代入になるため、コンパイルエラーです。", [5], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-capstone-interface-field-assign-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "inheritance",
            tags: ["interface", "field", "final"],
            code: """
interface Config {
    int VALUE = 1;
}
public class Test {
    public static void main(String[] args) {
        Config.VALUE = 2;
        System.out.println(Config.VALUE);
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "2と出力される", misconception: "interfaceフィールドを書き換えられると誤解", explanation: "interfaceのフィールドは暗黙的にpublic static finalです。"),
                choice("b", "1と出力される", misconception: "代入が無視されると誤解", explanation: "代入行がコンパイルエラーです。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "`Config.VALUE` はfinal定数なので再代入できません。"),
                choice("d", "実行時にUnsupportedOperationExceptionになる", misconception: "final代入を実行時例外と混同", explanation: "コンパイル時に禁止されます。"),
            ],
            intent: "interfaceフィールドが暗黙的にpublic static finalであることを確認する。",
            steps: [
                step("interface内の `int VALUE = 1;` は暗黙的に `public static final` です。", [1, 2], [variable("Config.VALUE", "public static final int", "1", "Config")]),
                step("mainで `Config.VALUE = 2;` と再代入しようとしています。", [6], [variable("assignment", "String", "final field reassignment", "compiler")]),
                step("final定数には再代入できないため、コンパイルエラーになります。", [6], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-capstone-super-method-001",
            category: "inheritance",
            tags: ["super", "override", "method call"],
            code: """
class Parent {
    void show() { System.out.print("P"); }
}
class Child extends Parent {
    @Override
    void show() {
        System.out.print("C");
        super.show();
    }
}
public class Test {
    public static void main(String[] args) {
        new Child().show();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "P", misconception: "super.showだけが実行されると誤解", explanation: "Child.showの本体で先にCを出力します。"),
                choice("b", "C", misconception: "super.showを無視している", explanation: "Child.show内で明示的にsuper.showを呼んでいます。"),
                choice("c", "CP", correct: true, explanation: "Child.showでCを出力し、その後super.showでPを出力します。"),
                choice("d", "PC", misconception: "親メソッドが自動的に先に呼ばれると誤解", explanation: "オーバーライドメソッドではsuper呼び出しを書いた位置で親メソッドが実行されます。"),
            ],
            intent: "superによる親クラスメソッド呼び出しの位置を確認する。",
            steps: [
                step("`new Child().show()` はChildでオーバーライドされたshowを呼びます。", [13], [variable("selected method", "String", "Child.show", "runtime")]),
                step("Child.showの最初でCを出力し、その後 `super.show()` を呼びます。", [6, 7, 8], [variable("output so far", "String", "C", "stdout")]),
                step("Parent.showがPを出力するため、全体は `CP` です。", [2, 8], [variable("output", "String", "CP", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-polymorphic-array-001",
            category: "inheritance",
            tags: ["polymorphism", "array", "override"],
            code: """
class Parent {
    String name() { return "P"; }
}
class Child extends Parent {
    @Override String name() { return "C"; }
}
public class Test {
    public static void main(String[] args) {
        Parent[] values = { new Child() };
        System.out.println(values[0].name());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "P", misconception: "配列の宣言型Parentでメソッドが固定されると誤解", explanation: "インスタンスメソッドは実行時型で動的に選ばれます。"),
                choice("b", "C", correct: true, explanation: "配列要素の参照型はParentでも、実体はChildなのでChild.nameが実行されます。"),
                choice("c", "Parent", misconception: "クラス名が出力されると誤解", explanation: "nameメソッドの戻り値を出力しています。"),
                choice("d", "コンパイルエラー", misconception: "Parent[]にChildを入れられないと誤解", explanation: "ChildはParentのサブクラスなので格納できます。"),
            ],
            intent: "配列要素経由でもオーバーライドメソッドが動的ディスパッチされることを確認する。",
            steps: [
                step("`values` はParent[]ですが、0番目の実体は `new Child()` です。", [9], [variable("values[0] runtime type", "Class", "Child", "main")]),
                step("`values[0].name()` はインスタンスメソッド呼び出しなので、実行時型Childのnameが選ばれます。", [10], [variable("selected method", "String", "Child.name", "runtime")]),
                step("Child.nameはCを返すため、出力は `C` です。", [5, 10], [variable("output", "String", "C", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-abstract-method-nonabstract-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "inheritance",
            tags: ["abstract", "method", "compile"],
            code: """
class Service {
    abstract void run();
}
public class Test {
    public static void main(String[] args) {
        System.out.println("ok");
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "okと出力される", misconception: "abstractメソッドを普通のクラスに置けると誤解", explanation: "abstractメソッドを持つクラスはabstractでなければなりません。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "Serviceがabstractではないのにabstractメソッドrunを宣言しているためエラーです。"),
                choice("c", "実行時にAbstractMethodErrorになる", misconception: "抽象メソッド問題を実行時まで遅らせると誤解", explanation: "クラス宣言がコンパイルできません。"),
                choice("d", "Serviceだけ無視される", misconception: "未使用クラスのコンパイルエラーが無視されると誤解", explanation: "同じソース内のクラス宣言はコンパイル対象です。"),
            ],
            intent: "abstractメソッドを含むクラスはabstract宣言が必要であることを確認する。",
            steps: [
                step("Serviceクラスには `abstract void run();` があります。", [1, 2], [variable("run", "abstract method", "no body", "Service")]),
                step("しかしService自体は `abstract class` ではなく通常のclassとして宣言されています。", [1], [variable("Service abstract", "boolean", "false", "compiler")]),
                step("abstractメソッドを持つ非abstractクラスは不正なので、コンパイルエラーです。", [1, 2], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-capstone-overload-throws-only-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "exception-handling",
            tags: ["method signature", "throws", "compile"],
            code: """
import java.io.*;

public class Test {
    void read() throws IOException {
    }
    void read() throws Exception {
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "正常にコンパイルされる", misconception: "throws句の違いだけでオーバーロードできると誤解", explanation: "メソッドシグネチャにthrows句は含まれません。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "2つのreadは引数リストが同じで、throws句だけが異なるため重複メソッドです。"),
                choice("c", "IOException版だけが残る", misconception: "より具体的なthrowsが優先されると誤解", explanation: "宣言の重複としてコンパイルエラーです。"),
                choice("d", "実行時にExceptionになる", misconception: "宣言重複を実行時問題と混同", explanation: "実行前にコンパイルできません。"),
            ],
            intent: "throws句だけではメソッドをオーバーロードできないことを確認する。",
            steps: [
                step("2つの `read()` はどちらもメソッド名read、引数なしです。", [4, 6], [variable("signature", "String", "read()", "compiler")]),
                step("throws句はメソッドシグネチャに含まれないため、`throws IOException` と `throws Exception` の違いでは区別できません。", [4, 6], [variable("distinguishable", "boolean", "false", "compiler")]),
                step("同じシグネチャのメソッド重複としてコンパイルエラーです。", [6], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-capstone-checked-catch-unthrown-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "exception-handling",
            tags: ["checked exception", "catch", "compile"],
            code: """
import java.io.*;

public class Test {
    public static void main(String[] args) {
        try {
            System.out.println("A");
        } catch (IOException e) {
            System.out.println("I");
        }
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "Aと出力される", misconception: "未到達catchが許可されると誤解", explanation: "try内でIOExceptionが発生し得ないためcatchが不正です。"),
                choice("b", "Iと出力される", misconception: "catchが必ず実行されると誤解", explanation: "try内で例外が起きていません。そもそもコンパイルできません。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "検査例外IOExceptionはtryブロックから投げられないため、このcatchはコンパイルエラーです。"),
                choice("d", "RuntimeExceptionになる", misconception: "検査例外catchの問題を実行時例外と混同", explanation: "コンパイル時に検出されます。"),
            ],
            intent: "投げられない検査例外をcatchできないことを確認する。",
            steps: [
                step("tryブロック内は `System.out.println(\"A\")` だけで、IOExceptionを投げる可能性がありません。", [5, 6], [variable("throws IOException", "boolean", "false", "try")]),
                step("IOExceptionは検査例外なので、発生し得ないtryに対してcatchすると不正です。", [7], [variable("catch valid", "boolean", "false", "compiler")]),
                step("そのためコンパイルエラーになります。", [7], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-capstone-function-apply-001",
            category: "lambda-streams",
            tags: ["Function", "lambda", "apply"],
            code: """
import java.util.function.*;

public class Test {
    public static void main(String[] args) {
        Function<String, Integer> f = s -> s.length();
        System.out.println(f.apply("Hi"));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2", correct: true, explanation: "Functionは引数を受け取り結果を返します。`Hi` の長さは2です。"),
                choice("b", "Hi", misconception: "Functionが入力値をそのまま返すと誤解", explanation: "ラムダ本体は `s.length()` です。"),
                choice("c", "true", misconception: "Predicateと混同", explanation: "Predicate.testではなくFunction.applyを使っています。"),
                choice("d", "コンパイルエラー", misconception: "ラムダの戻り値intをIntegerへ返せないと誤解", explanation: "intはIntegerへボクシングされます。"),
            ],
            intent: "Function<T,R>のapplyと戻り値型を確認する。",
            steps: [
                step("`Function<String, Integer>` はStringを受け取りIntegerを返す関数型インターフェースです。", [5], [variable("f", "Function<String,Integer>", "s.length()", "main")]),
                step("`f.apply(\"Hi\")` でラムダが実行され、`\"Hi\".length()` は2です。", [6], [variable("apply result", "Integer", "2", "main")]),
                step("その結果が出力され、`2` です。", [6], [variable("output", "String", "2", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-supplier-lazy-001",
            category: "lambda-streams",
            tags: ["Supplier", "lambda", "lazy"],
            code: """
import java.util.function.*;

public class Test {
    public static void main(String[] args) {
        int[] count = {0};
        Supplier<Integer> s = () -> ++count[0];
        System.out.println(count[0] + ":" + s.get() + ":" + count[0]);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0:1:1", correct: true, explanation: "Supplierは作成時には実行されず、get時にcount[0]を1へ増やします。"),
                choice("b", "1:1:1", misconception: "ラムダ作成時に実行されると誤解", explanation: "ラムダ本体は `get()` を呼ぶまで実行されません。"),
                choice("c", "0:0:0", misconception: "getしてもラムダ本体が動かないと誤解", explanation: "`s.get()` で `++count[0]` が実行されます。"),
                choice("d", "コンパイルエラー", misconception: "配列要素をラムダ内で変更できないと誤解", explanation: "再代入していないのはローカル変数count自体で、配列要素の変更は可能です。"),
            ],
            intent: "Supplierの遅延実行と配列キャプチャを確認する。",
            steps: [
                step("`count[0]` は最初0です。Supplierを作ってもラムダ本体はまだ実行されません。", [5, 6], [variable("count[0]", "int", "0", "main")]),
                step("出力式は左から評価され、最初の `count[0]` は0です。次に `s.get()` で `++count[0]` が実行され1を返します。", [7], [variable("s.get()", "Integer", "1", "main")]),
                step("最後の `count[0]` も1なので、出力は `0:1:1` です。", [7], [variable("output", "String", "0:1:1", "stdout")]),
            ]
        ),
        q(
            "silver-capstone-string-charat-exception-001",
            category: "string",
            tags: ["String", "charAt", "StringIndexOutOfBoundsException"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = "abc";
        try {
            System.out.println(s.charAt(3));
        } catch (StringIndexOutOfBoundsException e) {
            System.out.println("OOB");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "c", misconception: "インデックス3が3文字目だと誤解", explanation: "Stringのインデックスは0始まりです。3文字目はインデックス2です。"),
                choice("b", "OOB", correct: true, explanation: "`abc` の有効なインデックスは0,1,2なので、charAt(3)で例外が発生しcatchされます。"),
                choice("c", "空文字", misconception: "範囲外が空文字になると誤解", explanation: "範囲外アクセスは例外です。"),
                choice("d", "コンパイルエラー", misconception: "charAtにintを渡せないと誤解", explanation: "charAt(int)は有効です。問題は実行時のインデックス範囲です。"),
            ],
            intent: "String.charAtの0始まりインデックスと範囲外例外を確認する。",
            steps: [
                step("`s` は長さ3の文字列 `abc` で、有効なインデックスは0,1,2です。", [3], [variable("s.length()", "int", "3", "main")]),
                step("`s.charAt(3)` は長さと同じインデックスを指定しているため範囲外です。StringIndexOutOfBoundsExceptionが発生します。", [5], [variable("exception", "StringIndexOutOfBoundsException", "thrown", "try")]),
                step("catchで捕捉され、`OOB` が出力されます。", [6, 7], [variable("output", "String", "OOB", "stdout")]),
            ]
        ),
    ]

    static let mockSpecs: [Spec] = [
        q(
            "silver-mock-capstone-unboxing-null-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "data-types",
            tags: ["模試専用", "unboxing", "NullPointerException"],
            code: """
public class Test {
    public static void main(String[] args) {
        Integer value = null;
        try {
            int n = value;
            System.out.println(n);
        } catch (NullPointerException e) {
            System.out.println("NPE");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", misconception: "nullのIntegerが0にアンボクシングされると誤解", explanation: "nullをアンボクシングするとNullPointerExceptionです。"),
                choice("b", "NPE", correct: true, explanation: "`int n = value;` でnullのIntegerをアンボクシングしようとしてNullPointerExceptionになります。"),
                choice("c", "null", misconception: "intにnullが入ると誤解", explanation: "intはプリミティブ型なのでnullを保持できません。"),
                choice("d", "コンパイルエラー", misconception: "Integerをintへ代入できないと誤解", explanation: "オートアンボクシングによりコンパイルは可能です。問題は実行時のnullです。"),
            ],
            intent: "nullラッパーのアンボクシングでNullPointerExceptionになることを確認する。",
            steps: [
                step("`value` はInteger型ですが値はnullです。", [3], [variable("value", "Integer", "null", "main")]),
                step("`int n = value;` ではIntegerからintへのアンボクシングが必要です。nullから値を取り出せないためNullPointerExceptionになります。", [5], [variable("exception", "NullPointerException", "thrown", "try")]),
                step("アンボクシング時のNullPointerExceptionがcatchで捕捉され、`NPE` が出力されます。", [7, 8], [variable("output", "String", "NPE", "stdout")]),
            ]
        ),
        q(
            "silver-mock-capstone-string-left-to-right-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "string",
            tags: ["模試専用", "String", "operator", "left-to-right"],
            code: """
public class Test {
    public static void main(String[] args) {
        System.out.println(1 + 2 + "A" + 3 + 4); // left-to-right after String appears
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "3A34", correct: true, explanation: "左から評価され、1+2は数値加算で3。その後は文字列連結になります。"),
                choice("b", "12A34", misconception: "最初からすべて文字列連結になると誤解", explanation: "文字列が現れる前の `1 + 2` は数値加算です。"),
                choice("c", "3A7", misconception: "文字列後の3+4も数値加算されると誤解", explanation: "一度String連結になった後は文字列連結として進みます。"),
                choice("d", "10A", misconception: "数値だけが先にまとめて足されると誤解", explanation: "`+` は左結合で左から評価されます。"),
            ],
            intent: "String連結における+演算子の左結合を確認する。",
            steps: [
                step("`1 + 2` は左から最初に評価され、どちらもintなので3になります。", [3], [variable("first", "int", "3", "expression")]),
                step("次に `3 + \"A\"` で文字列連結となり `3A` になります。以降の `+ 3 + 4` も文字列連結です。", [3], [variable("expression", "String", "3A34", "main")]),
                step("出力は `3A34` です。", [3], [variable("output", "String", "3A34", "stdout")]),
            ]
        ),
        q(
            "silver-mock-capstone-arrays-aslist-backing-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "collections",
            tags: ["模試専用", "Arrays.asList", "backing array"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        String[] array = {"A", "B"};
        List<String> list = Arrays.asList(array);
        list.set(0, "X");
        System.out.println(array[0] + ":" + list);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A:[X, B]", misconception: "list.setが配列に反映されないと誤解", explanation: "Arrays.asListのリストは元配列を背後に持ちます。"),
                choice("b", "X:[X, B]", correct: true, explanation: "`list.set(0, \"X\")` は背後のarray[0]も変更します。"),
                choice("c", "X:[A, B]", misconception: "配列だけ変わると誤解", explanation: "同じ要素を共有しているためlist表示もXです。"),
                choice("d", "UnsupportedOperationException", misconception: "setも禁止されると誤解", explanation: "サイズ変更は不可ですが、既存要素のsetは可能です。"),
            ],
            intent: "Arrays.asListが配列を背後に持つ固定サイズリストを返すことを確認する。",
            steps: [
                step("arrayは `[A, B]` で、`Arrays.asList(array)` はこの配列を背後に持つ固定サイズリストを返します。", [5, 6], [variable("array/list", "shared storage", "[A, B]", "main")]),
                step("`list.set(0, \"X\")` は既存要素の置換なので可能で、背後のarray[0]もXになります。", [7], [variable("array[0]", "String", "X", "main")]),
                step("出力は `X:[X, B]` です。", [8], [variable("output", "String", "X:[X, B]", "stdout")]),
            ]
        ),
        q(
            "silver-mock-capstone-list-of-null-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "collections",
            tags: ["模試専用", "List.of", "null", "NullPointerException"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        try {
            List<String> list = List.of("A", null);
            System.out.println(list.size());
        } catch (NullPointerException e) {
            System.out.println("NPE");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2", misconception: "List.ofがnull要素を許可すると誤解", explanation: "List.ofはnull要素を許可しません。"),
                choice("b", "1", misconception: "nullだけ無視されると誤解", explanation: "nullを含むとリスト作成時に例外です。"),
                choice("c", "NPE", correct: true, explanation: "`List.of(\"A\", null)` の時点でNullPointerExceptionが発生します。"),
                choice("d", "コンパイルエラー", misconception: "nullをString要素として書けないと誤解", explanation: "コンパイルは可能ですが、List.ofが実行時に拒否します。"),
            ],
            intent: "List.ofに `\"A\", null` を渡した時点でNullPointerExceptionが発生することを確認する。",
            steps: [
                step("`List.of(\"A\", null)` を呼び出しています。nullはString参照としては書けます。", [6], [variable("argument", "String", "null", "main")]),
                step("しかしList.ofはnull要素を禁止しているため、作成時にNullPointerExceptionが発生します。", [6], [variable("exception", "NullPointerException", "thrown", "List.of")]),
                step("List.ofのnull拒否で発生した例外がcatchで捕捉され、`NPE` が出力されます。", [8, 9], [variable("output", "String", "NPE", "stdout")]),
            ]
        ),
        q(
            "silver-mock-capstone-switch-duplicate-constant-001",
            difficulty: .exam,
            validatedByJavac: false,
            isMockExamOnly: true,
            category: "control-flow",
            tags: ["模試専用", "switch", "constant expression", "duplicate case"],
            code: """
public class Test {
    public static void main(String[] args) {
        final int a = 1;
        int n = 1;
        switch (n) {
            case a: System.out.print("A");
            case 1: System.out.print("B");
        }
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "ABと出力される", misconception: "case aとcase 1が別扱いになると誤解", explanation: "aはfinalな定数変数なのでcase aはcase 1と同じです。"),
                choice("b", "Aと出力される", misconception: "2つ目のcaseが無視されると誤解", explanation: "重複caseは無視ではなくコンパイルエラーです。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "`final int a = 1` は定数式なので、`case a` と `case 1` が重複します。"),
                choice("d", "実行時にIllegalStateExceptionになる", misconception: "case重複を実行時問題と誤解", explanation: "重複はコンパイル時に検出されます。"),
            ],
            intent: "final定数変数を使ったcaseラベル重複を確認する。",
            steps: [
                step("`final int a = 1;` はコンパイル時定数です。", [3], [variable("a", "constant int", "1", "compiler")]),
                step("`case a` は実質的に `case 1` なので、次の `case 1` と重複します。", [6, 7], [variable("duplicate labels", "String", "1 and 1", "switch")]),
                step("同じswitch内で重複caseは許可されないため、コンパイルエラーです。", [7], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-mock-capstone-overload-null-ambiguous-001",
            difficulty: .exam,
            validatedByJavac: false,
            isMockExamOnly: true,
            category: "overload-resolution",
            tags: ["模試専用", "overload", "null", "ambiguous"],
            code: """
import java.io.*;

public class Test {
    static void call(Serializable s) { }
    static void call(CharSequence s) { }
    public static void main(String[] args) {
        call(null);
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "Serializable版が呼ばれる", misconception: "importされている型が優先されると誤解", explanation: "import有無はオーバーロード優先度に関係しません。"),
                choice("b", "CharSequence版が呼ばれる", misconception: "文字列系の型が優先されると誤解", explanation: "nullだけではどちらが具体的か決められません。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "nullは両方に適用できますが、SerializableとCharSequenceに上下関係がないため曖昧です。"),
                choice("d", "NullPointerExceptionになる", misconception: "null渡しが実行時例外になると誤解", explanation: "呼び出し先を決められず、実行前にコンパイルエラーです。"),
            ],
            intent: "null実引数と無関係な参照型オーバーロードの曖昧性を確認する。",
            steps: [
                step("`null` はSerializableにもCharSequenceにも代入可能なので、両方のcallが候補になります。", [4, 5, 7], [variable("applicable methods", "String", "Serializable, CharSequence", "compiler")]),
                step("SerializableとCharSequenceは互いにサブタイプ関係ではないため、より具体的な候補を選べません。", [4, 5], [variable("most specific", "String", "none", "compiler")]),
                step("呼び出しが曖昧となり、コンパイルエラーです。", [7], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-mock-capstone-parent-constructor-dispatch-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "inheritance",
            tags: ["模試専用", "constructor", "override", "initialization order"],
            code: """
class Parent {
    Parent() { show(); }
    void show() { System.out.print("P"); }
}
class Child extends Parent {
    int value = 1;
    @Override void show() { System.out.print(value); }
}
public class Test {
    public static void main(String[] args) {
        new Child();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "P", misconception: "親コンストラクタ内では親メソッドが固定で呼ばれると誤解", explanation: "オーバーライドされたインスタンスメソッドはコンストラクタ中でも動的ディスパッチされます。"),
                choice("b", "0", correct: true, explanation: "ParentコンストラクタからChild.showが呼ばれますが、その時点でChildのフィールド初期化はまだなのでvalueはデフォルト0です。"),
                choice("c", "1", misconception: "Childフィールド初期化が親コンストラクタより先と誤解", explanation: "親コンストラクタ完了後に子フィールド初期化が行われます。"),
                choice("d", "コンパイルエラー", misconception: "コンストラクタからオーバーライドメソッドを呼べないと誤解", explanation: "推奨されない設計ですが、コンパイルは可能です。"),
            ],
            intent: "親コンストラクタ内の動的ディスパッチと子フィールド初期化前状態を確認する。",
            steps: [
                step("`new Child()` では、まずParentコンストラクタが実行されます。", [10, 11, 2], [variable("construction phase", "String", "Parent constructor", "runtime")]),
                step("Parentコンストラクタ内の `show()` は動的ディスパッチされ、Child.showが呼ばれます。ただしChildの `value = 1` はまだ実行前です。", [2, 6, 7], [variable("value", "int", "0", "Child before field init")]),
                step("Child.showは現在のvalueである0を出力します。", [7], [variable("output", "String", "0", "stdout")]),
            ]
        ),
        q(
            "silver-mock-capstone-override-primitive-return-001",
            difficulty: .exam,
            validatedByJavac: false,
            isMockExamOnly: true,
            category: "inheritance",
            tags: ["模試専用", "override", "return type", "compile"],
            code: """
class Parent {
    int value() { return 1; }
}
class Child extends Parent {
    long value() { return 2L; }
}
public class Test {
    public static void main(String[] args) {
        System.out.println(new Child().value());
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "2と出力される", misconception: "戻り値だけlongへ変えられると誤解", explanation: "同じ引数リストのオーバーライドで、プリミティブ戻り値を別型に変更できません。"),
                choice("b", "1と出力される", misconception: "Child.valueが無視されると誤解", explanation: "宣言自体が不正です。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "戻り値型intとlongは共変戻り値の関係ではないため、Child.valueは不正です。"),
                choice("d", "ClassCastExceptionになる", misconception: "戻り値型違いを実行時キャストと混同", explanation: "コンパイル時に検出されます。"),
            ],
            intent: "プリミティブ戻り値型だけを変えたオーバーライドが不可であることを確認する。",
            steps: [
                step("Parentの `value()` は引数なしでintを返します。", [1, 2], [variable("Parent.value", "method", "int value()", "Parent")]),
                step("Childは同じ引数リストでlongを返す `value()` を宣言しています。戻り値型だけではオーバーロードできず、プリミティブ型は共変戻り値にもなりません。", [4, 5], [variable("return compatible", "boolean", "false", "compiler")]),
                step("そのためコンパイルエラーになります。", [5], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-mock-capstone-catch-order-001",
            difficulty: .exam,
            validatedByJavac: false,
            isMockExamOnly: true,
            category: "exception-handling",
            tags: ["模試専用", "catch order", "unreachable"],
            code: """
public class Test {
    public static void main(String[] args) {
        try {
            throw new RuntimeException();
        } catch (Exception e) { // superclass catch before subclass
            System.out.println("E");
        } catch (RuntimeException e) {
            System.out.println("R");
        }
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "Eと出力される", misconception: "先に一致するcatchだけ見ればよいと誤解", explanation: "後続catchの到達不能性もコンパイル時に検査されます。"),
                choice("b", "Rと出力される", misconception: "より具体的なRuntimeExceptionが後から選ばれると誤解", explanation: "catchは上から順で、さらにこの順序は不正です。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "Exceptionを先にcatchすると、その後のRuntimeException catchは到達不能になります。"),
                choice("d", "ERと出力される", misconception: "複数catchが連続実行されると誤解", explanation: "catchは1つだけ実行されます。今回はコンパイル不可です。"),
            ],
            intent: "catch(Exception) を先に置くと、後続の RuntimeException catch が到達不能になることを確認する。",
            steps: [
                step("`Exception` は `RuntimeException` の親クラスです。", [5, 7], [variable("relationship", "String", "RuntimeException extends Exception", "compiler")]),
                step("先にExceptionをcatchすると、RuntimeExceptionもそこで必ず捕捉されるため、後続のRuntimeException catchには到達できません。", [5, 7], [variable("second catch reachable", "boolean", "false", "compiler")]),
                step("到達不能catchとしてコンパイルエラーになります。", [7], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-mock-capstone-finally-mutate-return-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "exception-handling",
            tags: ["模試専用", "finally", "return", "array"],
            code: """
public class Test {
    static int[] make() {
        int[] data = {1};
        try {
            return data;
        } finally {
            data[0] = 2;
        }
    }
    public static void main(String[] args) {
        System.out.println(make()[0]);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1", misconception: "return時点で配列内容が固定されると誤解", explanation: "returnする参照先の配列はfinallyで変更されます。"),
                choice("b", "2", correct: true, explanation: "returnする配列参照は準備されますが、メソッドを抜ける前にfinallyでdata[0]が2へ変更されます。"),
                choice("c", "0", misconception: "配列がデフォルト値に戻ると誤解", explanation: "配列要素は1から2へ更新されます。"),
                choice("d", "コンパイルエラー", misconception: "finallyでreturn予定のオブジェクトを変更できないと誤解", explanation: "参照先オブジェクトの変更は可能です。"),
            ],
            intent: "finallyがreturn予定の参照先オブジェクトを変更できることを確認する。",
            steps: [
                step("`data` は `[1]` の配列を参照しています。tryでその配列参照をreturnしようとします。", [3, 4, 5], [variable("pending return", "int[]", "[1]", "make")]),
                step("メソッドを抜ける前にfinallyが実行され、同じ配列の `data[0]` が2へ変更されます。", [6, 7], [variable("data[0]", "int", "2", "finally")]),
                step("mainが受け取る配列の0番目は2なので、出力は `2` です。", [11], [variable("output", "String", "2", "stdout")]),
            ]
        ),
        q(
            "silver-mock-capstone-stringbuilder-equals-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "string",
            tags: ["模試専用", "StringBuilder", "equals"],
            code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder a = new StringBuilder("x");
        StringBuilder b = new StringBuilder("x");
        System.out.println(a.equals(b) + ":" + (a.toString().equals(b.toString())));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true:true", misconception: "StringBuilder.equalsが内容比較だと誤解", explanation: "StringBuilderはequalsを内容比較としてオーバーライドしていません。"),
                choice("b", "false:true", correct: true, explanation: "StringBuilder同士のequalsは参照比較相当でfalse。Stringへ変換したequalsは内容比較でtrueです。"),
                choice("c", "false:false", misconception: "String.equalsも参照比較だと誤解", explanation: "String.equalsは内容比較です。"),
                choice("d", "コンパイルエラー", misconception: "StringBuilderにtoStringがないと誤解", explanation: "Object由来のtoStringがあり、StringBuilderは内容文字列を返します。"),
            ],
            intent: "StringBuilder同士のequalsはfalseでも、toString後のString.equalsはtrueになることを確認する。",
            steps: [
                step("aとbはどちらも内容はxですが、別々にnewされたStringBuilderです。", [3, 4], [variable("a/b", "StringBuilder", "different objects", "main")]),
                step("`a.equals(b)` は内容比較ではないためfalseです。一方、toString後のString同士は内容比較になります。", [5], [variable("first", "boolean", "false", "main"), variable("second", "boolean", "true", "main")]),
                step("出力は `false:true` です。", [5], [variable("output", "String", "false:true", "stdout")]),
            ]
        ),
        q(
            "silver-mock-capstone-main-overload-entry-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "java-basics",
            tags: ["模試専用", "main", "overload", "entrypoint"],
            code: """
public class Test {
    public static void main(String args) {
        System.out.println("single");
    }
    public static void main(String[] args) {
        System.out.println("array");
    }
}
""",
            question: "`java Test` として起動したとき、出力されるのはどれか？",
            choices: [
                choice("a", "single", misconception: "先に宣言されたmainが選ばれると誤解", explanation: "Javaランチャーが探すのはString[]引数のmainです。"),
                choice("b", "array", correct: true, explanation: "`public static void main(String[] args)` が起動用mainとして呼ばれます。"),
                choice("c", "singlearray", misconception: "mainが両方呼ばれると誤解", explanation: "エントリポイントとして呼ばれるのは1つだけです。"),
                choice("d", "起動できない", misconception: "mainのオーバーロードがあると起動不可と誤解", explanation: "有効なString[]版があるため起動できます。"),
            ],
            intent: "mainメソッドをオーバーロードしても起動用mainはString[]版であることを確認する。",
            steps: [
                step("このクラスには `main(String)` と `main(String[])` の2つがあります。", [2, 5], [variable("main overloads", "String", "String, String[]", "Test")]),
                step("Javaランチャーがエントリポイントとして認識するのは `public static void main(String[] args)` です。", [5], [variable("entrypoint", "String", "main(String[])", "launcher")]),
                step("String[]版が実行され、`array` が出力されます。", [6], [variable("output", "String", "array", "stdout")]),
            ]
        ),
        q(
            "silver-mock-capstone-varargs-null-array-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "overload-resolution",
            tags: ["模試専用", "varargs", "null array"],
            code: """
public class Test {
    static void call(int... values) {
        System.out.println(values == null ? "null" : values.length);
    }
    public static void main(String[] args) {
        call((int[]) null);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", misconception: "null配列が空配列に変換されると誤解", explanation: "明示的に `(int[]) null` を渡しているため、valuesはnullです。"),
                choice("b", "null", correct: true, explanation: "varargsメソッドにint[]としてnullを渡しているため、仮引数values自体がnullになります。"),
                choice("c", "1", misconception: "nullが1要素として扱われると誤解", explanation: "int[]のnull参照を渡しています。"),
                choice("d", "コンパイルエラー", misconception: "varargsにnull配列を渡せないと誤解", explanation: "明示キャストしたnull配列は渡せます。"),
            ],
            intent: "varargsに配列nullを渡したときの仮引数値を確認する。",
            steps: [
                step("`call((int[]) null)` は、int配列としてのnull参照を1つ渡しています。", [6], [variable("argument", "int[]", "null", "main")]),
                step("varargs仮引数 `values` は、そのnull配列参照を受け取ります。空配列は作られません。", [2], [variable("values", "int[]", "null", "call")]),
                step("三項演算子でnull判定がtrueになり、`null` と出力されます。", [3], [variable("output", "String", "null", "stdout")]),
            ]
        ),
        q(
            "silver-mock-capstone-array-covariance-number-001",
            difficulty: .exam,
            isMockExamOnly: true,
            category: "data-types",
            tags: ["模試専用", "array covariance", "ArrayStoreException"],
            code: """
public class Test {
    public static void main(String[] args) {
        Number[] numbers = new Integer[1];
        try {
            numbers[0] = Double.valueOf(1.0);
            System.out.println("OK");
        } catch (ArrayStoreException e) {
            System.out.println("ASE");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "OK", misconception: "参照型Number[]ならDoubleを格納できると誤解", explanation: "実体はInteger[]なのでDoubleは格納できません。"),
                choice("b", "ASE", correct: true, explanation: "配列の実体型はInteger[]であり、Doubleを格納しようとしてArrayStoreExceptionになります。"),
                choice("c", "ClassCastException", misconception: "配列格納エラーとキャストエラーを混同", explanation: "配列への不正格納はArrayStoreExceptionです。"),
                choice("d", "コンパイルエラー", misconception: "Integer[]をNumber[]へ代入できないと誤解", explanation: "配列は共変なので代入自体は可能です。"),
            ],
            intent: "配列共変性と実行時の配列要素型検査を確認する。",
            steps: [
                step("`numbers` の参照型はNumber[]ですが、実体は `new Integer[1]` です。", [3], [variable("runtime array type", "Class", "Integer[]", "main")]),
                step("`Double.valueOf(1.0)` はNumberではありますが、Integer[]には格納できません。", [5], [variable("stored value", "Double", "1.0", "try")]),
                step("実行時の配列型検査でArrayStoreExceptionが発生し、catchで `ASE` が出力されます。", [7, 8], [variable("output", "String", "ASE", "stdout")]),
            ]
        ),
        q(
            "silver-mock-capstone-local-class-capture-001",
            difficulty: .exam,
            validatedByJavac: false,
            isMockExamOnly: true,
            category: "classes",
            tags: ["模試専用", "local class", "effectively final", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        int value = 1;
        class Local {
            int get() { return value; }
        }
        value++;
        System.out.println(new Local().get());
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "1と出力される", misconception: "ローカルクラスが宣言時の値をコピーすると誤解", explanation: "ローカルクラスから参照するローカル変数も実質的finalが必要です。"),
                choice("b", "2と出力される", misconception: "変更後のvalueを読めると誤解", explanation: "valueが後で変更されるため、ローカルクラスから参照できません。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "Local.getがvalueを参照しているのに、後でvalue++しているため実質的finalではありません。"),
                choice("d", "NullPointerExceptionになる", misconception: "ローカルクラス生成を実行時問題と誤解", explanation: "実質的final制約はコンパイル時に検査されます。"),
            ],
            intent: "ローカルクラスから参照するローカル変数にも実質的final制約があることを確認する。",
            steps: [
                step("Localクラスの `get()` は、mainのローカル変数 `value` を参照しています。", [3, 4, 5], [variable("captured variable", "int", "value", "Local")]),
                step("その後 `value++` によりvalueを変更しているため、valueは実質的finalではありません。", [7], [variable("effectively final", "boolean", "false", "compiler")]),
                step("ローカルクラスから参照する条件を満たさず、コンパイルエラーです。", [5, 7], [variable("result", "String", "compile error", "compiler")]),
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

extension SilverCapstoneQuestionData.Spec {
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
    static let silverCapstoneExpansion: [Quiz] = SilverCapstoneQuestionData.practiceSpecs.map(\.quiz)
    static let silverCapstoneMockExpansion: [Quiz] = SilverCapstoneQuestionData.mockSpecs.map(\.quiz)
}
