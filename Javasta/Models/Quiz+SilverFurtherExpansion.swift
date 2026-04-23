import Foundation

enum SilverFurtherQuestionData {
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
            "silver-further-increment-order-001",
            category: "data-types",
            tags: ["increment", "operator", "evaluation order"],
            code: """
public class Test {
    public static void main(String[] args) {
        int x = 1;
        int y = x++ + ++x;
        System.out.println(y + ":" + x);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "4:3", correct: true, explanation: "`x++` は1を使ってから2へ、`++x` は3へ増やしてから使うため、yは4です。"),
                choice("b", "3:3", misconception: "前置インクリメントの値を2のままと誤解", explanation: "`x++` の後にxは2となり、`++x` で3になります。"),
                choice("c", "4:2", misconception: "前置インクリメント後のx更新を見落とし", explanation: "`++x` は変数自体も3に更新します。"),
                choice("d", "コンパイルエラー", misconception: "同じ変数を1式で複数回使えないと誤解", explanation: "Javaでは評価順が定義されており、この式はコンパイルできます。"),
            ],
            intent: "後置・前置インクリメントの評価値と変数更新順を確認する。",
            steps: [
                step("`x` は最初1です。`x++` は現在値1を式へ渡した後、xを2にします。", [3, 4], [variable("left value", "int", "1", "main"), variable("x", "int", "2", "main")]),
                step("続く `++x` は先にxを3へ増やし、その3を式へ渡します。", [4], [variable("right value", "int", "3", "main"), variable("x", "int", "3", "main")]),
                step("`y` は `1 + 3` で4、最終的なxは3なので、出力は `4:3` です。", [4, 5], [variable("y", "int", "4", "main"), variable("output", "String", "4:3", "stdout")]),
            ]
        ),
        q(
            "silver-further-ternary-promotion-001",
            category: "data-types",
            tags: ["ternary", "numeric promotion", "boxing"],
            code: """
public class Test {
    public static void main(String[] args) {
        Object value = true ? 1 : 2.0;
        System.out.println(value.getClass().getSimpleName() + ":" + value);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "Integer:1", misconception: "true側のint型だけで決まると誤解", explanation: "三項演算子では両辺の数値型から型が決まります。"),
                choice("b", "Double:1.0", correct: true, explanation: "`1` と `2.0` は数値昇格でdoubleになり、Objectへ代入されるとDoubleにボクシングされます。"),
                choice("c", "Double:2.0", misconception: "false側が選ばれると誤解", explanation: "条件がtrueなので値として使われるのは左側です。"),
                choice("d", "コンパイルエラー", misconception: "intとdoubleを三項演算子で混ぜられないと誤解", explanation: "数値昇格により共通型へ変換されます。"),
            ],
            intent: "三項演算子の数値昇格とボクシングを確認する。",
            steps: [
                step("条件は `true` なので値としては左側の `1` が選ばれます。", [3], [variable("selected operand", "int literal", "1", "main")]),
                step("ただし式全体の型は、右側の `2.0` と合わせてdoubleになります。`1` は `1.0` として扱われます。", [3], [variable("conditional type", "double", "1.0", "expression")]),
                step("double値をObjectへ代入するためDoubleへボクシングされ、出力は `Double:1.0` です。", [3, 4], [variable("value", "Double", "1.0", "main")]),
            ]
        ),
        q(
            "silver-further-short-add-compile-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "data-types",
            tags: ["short", "numeric promotion", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        short s = 1;
        s = s + 1; // arithmetic promotion yields int
        System.out.println(s);
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "2と出力される", misconception: "計算結果がshortに戻ると誤解", explanation: "`s + 1` はintへ昇格します。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "`s + 1` の結果はintなので、明示キャストなしでshortへ代入できません。"),
                choice("c", "1と出力される", misconception: "代入が無視されると誤解", explanation: "代入以前にコンパイルエラーです。"),
                choice("d", "ArithmeticExceptionになる", misconception: "型変換を実行時例外と混同", explanation: "これはコンパイル時の型不一致です。"),
            ],
            intent: "byte/short/charの算術演算がintへ昇格することを確認する。",
            steps: [
                step("`short s = 1;` は範囲内の定数代入なので有効です。", [3], [variable("s", "short", "1", "main")]),
                step("`s + 1` では、shortのsがintへ昇格してから加算されます。式全体の型はintです。", [4], [variable("s + 1", "int", "2", "expression")]),
                step("intをshortへ暗黙に代入できないため、4行目でコンパイルエラーになります。", [4], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-further-char-to-int-001",
            category: "data-types",
            tags: ["char", "numeric promotion", "unicode"],
            code: """
public class Test {
    public static void main(String[] args) {
        char c = 'A';
        int n = c + 1;
        System.out.println(n);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A1", misconception: "文字列連結になると誤解", explanation: "左辺の代入先がintであり、charは数値として加算されます。"),
                choice("b", "B", misconception: "charのまま文字へ戻ると誤解", explanation: "`c + 1` の式はintです。"),
                choice("c", "66", correct: true, explanation: "`'A'` の文字コード65に1を足して66になります。"),
                choice("d", "コンパイルエラー", misconception: "charをintへ変換できないと誤解", explanation: "charはintへ拡大変換できます。"),
            ],
            intent: "charが算術演算でintとして扱われることを確認する。",
            steps: [
                step("`char c = 'A'` で、Aのコード値は65です。", [3], [variable("c", "char", "A / 65", "main")]),
                step("`c + 1` は数値演算なので、charはintへ昇格して65 + 1になります。", [4], [variable("n", "int", "66", "main")]),
                step("printlnして出力は `66` です。文字Bとして出力したいならcharへキャストする必要があります。", [5], [variable("output", "String", "66", "stdout")]),
            ]
        ),
        q(
            "silver-further-short-circuit-001",
            category: "control-flow",
            tags: ["short-circuit", "&&", "side effect"],
            code: """
public class Test {
    public static void main(String[] args) {
        int x = 0;
        boolean result = false && ++x > 0;
        System.out.println(result + ":" + x);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "false:0", correct: true, explanation: "`&&` は左辺がfalseなら右辺を評価しないため、`++x` は実行されません。"),
                choice("b", "false:1", misconception: "右辺も必ず評価されると誤解", explanation: "`&&` は短絡評価します。"),
                choice("c", "true:1", misconception: "右辺だけで結果が決まると誤解", explanation: "左辺がfalseなので全体はfalseです。"),
                choice("d", "コンパイルエラー", misconception: "副作用のある式をboolean式に使えないと誤解", explanation: "`++x > 0` はbooleanを返す有効な式です。"),
            ],
            intent: "&&の短絡評価と副作用の有無を確認する。",
            steps: [
                step("左辺の `false` を評価した時点で、`&&` の結果はfalseに決まります。", [4], [variable("left operand", "boolean", "false", "main")]),
                step("短絡評価により右辺 `++x > 0` は実行されず、xは0のままです。", [4], [variable("x", "int", "0", "main")]),
                step("結果はfalse、xは0なので、出力は `false:0` です。", [5], [variable("output", "String", "false:0", "stdout")]),
            ]
        ),
        q(
            "silver-further-boolean-assignment-if-001",
            category: "control-flow",
            tags: ["if", "assignment", "boolean"],
            code: """
public class Test {
    public static void main(String[] args) {
        boolean flag = false;
        if (flag = true) {
            System.out.println(flag);
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", correct: true, explanation: "`flag = true` は代入式で、代入後の値trueを返すためif本体が実行されます。"),
                choice("b", "false", misconception: "比較式だと誤解", explanation: "`=` は比較ではなく代入です。"),
                choice("c", "何も出力されない", misconception: "初期値falseのままだと誤解", explanation: "if条件の中でtrueが代入されます。"),
                choice("d", "コンパイルエラー", misconception: "if条件に代入式を書けないと誤解", explanation: "booleanへの代入式はboolean値を返すため、if条件として有効です。"),
            ],
            intent: "boolean代入式がif条件として成立することを確認する。",
            steps: [
                step("`flag` は最初falseです。", [3], [variable("flag", "boolean", "false", "main")]),
                step("if条件の `flag = true` は比較ではなく代入です。flagへtrueを入れ、式の値もtrueになります。", [4], [variable("flag", "boolean", "true", "main")]),
                step("if本体が実行され、`true` が出力されます。", [5], [variable("output", "String", "true", "stdout")]),
            ]
        ),
        q(
            "silver-further-string-indexof-001",
            category: "string",
            tags: ["String", "indexOf", "fromIndex"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = "banana";
        System.out.println(s.indexOf("na", 3));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2", misconception: "最初のnaの位置を答えている", explanation: "第2引数3があるため、検索開始位置はインデックス3です。"),
                choice("b", "3", misconception: "検索開始位置そのものが返ると誤解", explanation: "返るのは見つかった部分文字列の開始位置です。"),
                choice("c", "4", correct: true, explanation: "`banana` のインデックス3以降で `na` が始まるのは4です。"),
                choice("d", "-1", misconception: "3以降にnaがないと誤解", explanation: "インデックス4から `na` が見つかります。"),
            ],
            intent: "String.indexOf(String, fromIndex)の検索開始位置を確認する。",
            steps: [
                step("`banana` の文字位置は b=0, a=1, n=2, a=3, n=4, a=5 です。", [3], [variable("s", "String", "banana", "main")]),
                step("`indexOf(\"na\", 3)` はインデックス3から検索します。最初の `na` は2ですが、これは開始位置より前なので対象外です。", [4], [variable("fromIndex", "int", "3", "main")]),
                step("3以降ではインデックス4から `na` が始まるため、出力は `4` です。", [4], [variable("result", "int", "4", "stdout")]),
            ]
        ),
        q(
            "silver-further-string-replace-immutable-001",
            category: "string",
            tags: ["String", "replace", "immutable"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = "java";
        s.replace('a', 'o');
        System.out.println(s);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "java", correct: true, explanation: "Stringは不変で、replaceの戻り値を代入していないためsは元のままです。"),
                choice("b", "jovo", misconception: "replaceが元のStringを書き換えると誤解", explanation: "replaceは新しいStringを返します。"),
                choice("c", "jova", misconception: "最初の1文字だけ置換されると誤解", explanation: "戻り値を使えばすべてのaがoになりますが、このコードでは捨てています。"),
                choice("d", "コンパイルエラー", misconception: "replace(char,char)が存在しないと誤解", explanation: "このオーバーロードは存在します。問題は戻り値を使っていない点です。"),
            ],
            intent: "Stringの不変性とメソッド戻り値の扱いを確認する。",
            steps: [
                step("`s` は文字列 `java` を参照しています。", [3], [variable("s", "String", "java", "main")]),
                step("`s.replace('a', 'o')` は `jovo` という新しいStringを返しますが、その戻り値はどこにも代入されません。", [4], [variable("replace result", "String", "jovo (discarded)", "main")]),
                step("`s` の参照先は変わらないため、出力は `java` です。", [5], [variable("output", "String", "java", "stdout")]),
            ]
        ),
        q(
            "silver-further-stringbuilder-delete-insert-001",
            category: "string",
            tags: ["StringBuilder", "delete", "insert"],
            code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("abcdef");
        sb.delete(1, 4).insert(1, "X");
        System.out.println(sb);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "aXef", correct: true, explanation: "`delete(1,4)` でbcdを削除してaef、そこへXを挿入します。"),
                choice("b", "aXdef", misconception: "deleteの終端を含まない規則を誤解", explanation: "deleteの第2引数は含まれないため、1から3までのbcdが消えます。"),
                choice("c", "abcdXef", misconception: "insert位置を末尾寄りに見ている", explanation: "delete後の文字列aefのインデックス1に挿入します。"),
                choice("d", "コンパイルエラー", misconception: "StringBuilderメソッドを連鎖できないと誤解", explanation: "deleteもinsertも同じStringBuilderを返すため連鎖できます。"),
            ],
            intent: "StringBuilder.deleteの範囲とメソッドチェーンを確認する。",
            steps: [
                step("初期状態は `abcdef` です。", [3], [variable("sb", "StringBuilder", "abcdef", "main")]),
                step("`delete(1, 4)` はインデックス1以上4未満、つまりbcdを削除し、`aef` にします。", [4], [variable("after delete", "StringBuilder", "aef", "main")]),
                step("続けてインデックス1へXを挿入するため、最終的な出力は `aXef` です。", [4, 5], [variable("sb", "StringBuilder", "aXef", "main")]),
            ]
        ),
        q(
            "silver-further-stringbuilder-alias-001",
            category: "string",
            tags: ["StringBuilder", "reference", "alias"],
            code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder a = new StringBuilder("x");
        StringBuilder b = a;
        b.append("y");
        a.append("z");
        System.out.println(b);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "xy", misconception: "a.appendの影響がbに出ないと誤解", explanation: "aとbは同じStringBuilderを参照しています。"),
                choice("b", "xz", misconception: "b.appendの影響がaに出ないと誤解", explanation: "同じオブジェクトに対する更新です。"),
                choice("c", "xyz", correct: true, explanation: "b.appendでxy、a.appendで同じオブジェクトがxyzになります。"),
                choice("d", "x", misconception: "StringBuilderも不変と誤解", explanation: "StringBuilderは可変です。"),
            ],
            intent: "参照コピーとStringBuilderの可変性を確認する。",
            steps: [
                step("`a` は `x` を持つStringBuilderを参照し、`b = a` でbも同じオブジェクトを参照します。", [3, 4], [variable("a/b", "StringBuilder ref", "same object: x", "main")]),
                step("`b.append(\"y\")` により同じオブジェクトは `xy` になります。", [5], [variable("builder", "StringBuilder", "xy", "heap")]),
                step("`a.append(\"z\")` も同じオブジェクトを更新するため、bから見ても `xyz` です。", [6, 7], [variable("output", "String", "xyz", "stdout")]),
            ]
        ),
        q(
            "silver-further-array-boolean-default-001",
            category: "data-types",
            tags: ["array", "default value", "boolean"],
            code: """
public class Test {
    public static void main(String[] args) {
        boolean[] flags = new boolean[2];
        System.out.println(flags[0] + ":" + flags[1]);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "false:false", correct: true, explanation: "boolean配列の要素はfalseで初期化されます。"),
                choice("b", "true:true", misconception: "booleanのデフォルトをtrueと誤解", explanation: "booleanのデフォルト値はfalseです。"),
                choice("c", "null:null", misconception: "プリミティブ配列要素がnullになると誤解", explanation: "booleanはプリミティブ型なのでnullにはなりません。"),
                choice("d", "コンパイルエラー", misconception: "配列要素の初期化が必須と誤解", explanation: "newで作った配列要素は型ごとのデフォルト値で初期化されます。"),
            ],
            intent: "プリミティブ配列要素のデフォルト値を確認する。",
            steps: [
                step("`new boolean[2]` は2要素のboolean配列を作ります。", [3], [variable("flags.length", "int", "2", "main")]),
                step("boolean配列の各要素は明示代入しなくてもfalseで初期化されます。", [3], [variable("flags[0]", "boolean", "false", "heap"), variable("flags[1]", "boolean", "false", "heap")]),
                step("2つを連結して、出力は `false:false` です。", [4], [variable("output", "String", "false:false", "stdout")]),
            ]
        ),
        q(
            "silver-further-array-length-method-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "data-types",
            tags: ["array", "length", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        int[] values = {1, 2, 3};
        System.out.println(values.length());
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "3と出力される", misconception: "配列のlengthをメソッドと誤解", explanation: "配列の長さはフィールド `length` で参照します。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "配列には `length()` メソッドはありません。`values.length` が正しい形です。"),
                choice("c", "0と出力される", misconception: "length()が初期化済み要素数を返すと誤解", explanation: "そもそもメソッド呼び出しができません。"),
                choice("d", "NullPointerExceptionになる", misconception: "配列参照がnullだと誤解", explanation: "配列は初期化されています。問題はコンパイル時のメンバ指定です。"),
            ],
            intent: "配列のlengthはメソッドではなくフィールドであることを確認する。",
            steps: [
                step("`values` は3要素のint配列として作成されます。", [3], [variable("values", "int[]", "[1, 2, 3]", "main")]),
                step("配列の長さは `values.length` で参照します。`length()` というメソッド呼び出しは存在しません。", [4], [variable("member", "array length", "field, not method", "compiler")]),
                step("そのため4行目でコンパイルエラーになります。", [4], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-further-ragged-array-001",
            category: "data-types",
            tags: ["array", "multidimensional", "ragged"],
            code: """
public class Test {
    public static void main(String[] args) {
        int[][] values = {{1}, {2, 3}};
        System.out.println(values.length + ":" + values[1].length);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2:2", correct: true, explanation: "外側の配列は2要素で、2番目の内側配列 `{2, 3}` は2要素です。"),
                choice("b", "2:3", misconception: "全要素数をvalues[1].lengthと誤解", explanation: "`values[1].length` は2番目の内側配列だけの長さです。"),
                choice("c", "3:2", misconception: "外側配列の長さを全int数と誤解", explanation: "外側配列の要素数は内側配列2つです。"),
                choice("d", "コンパイルエラー", misconception: "2次元配列の内側長が不揃いだと不可と誤解", explanation: "Javaの多次元配列は配列の配列なので、内側長は不揃いにできます。"),
            ],
            intent: "不規則な多次元配列のlengthを確認する。",
            steps: [
                step("`values` は外側に2つの配列を持ちます。1つ目は `{1}`、2つ目は `{2, 3}` です。", [3], [variable("values.length", "int", "2", "main")]),
                step("`values[1]` は2つ目の内側配列 `{2, 3}` なので、長さは2です。", [4], [variable("values[1].length", "int", "2", "main")]),
                step("したがって出力は `2:2` です。", [4], [variable("output", "String", "2:2", "stdout")]),
            ]
        ),
        q(
            "silver-further-array-reference-assignment-001",
            category: "data-types",
            tags: ["array", "reference", "alias"],
            code: """
public class Test {
    public static void main(String[] args) {
        int[] a = {1, 2};
        int[] b = a; // alias points to the same array
        b[0] = 9;
        System.out.println(a[0]);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1", misconception: "配列代入でコピーされると誤解", explanation: "配列変数の代入は参照のコピーです。"),
                choice("b", "2", misconception: "b[0]がa[1]に対応すると誤解", explanation: "インデックス0の同じ要素を書き換えています。"),
                choice("c", "9", correct: true, explanation: "aとbは同じ配列を参照しているため、b[0]の変更はa[0]にも見えます。"),
                choice("d", "コンパイルエラー", misconception: "配列参照を別変数へ代入できないと誤解", explanation: "同じ型の配列参照へ代入できます。"),
            ],
            intent: "配列変数の代入が配列本体のコピーではなく参照コピーであることを確認する。",
            steps: [
                step("`a` は `[1, 2]` の配列を参照します。", [3], [variable("a", "int[]", "[1, 2]", "main")]),
                step("`b = a` により、bも同じ配列を参照します。配列の複製は作られません。", [4], [variable("a/b", "int[] ref", "same array", "main")]),
                step("`b[0] = 9` は同じ配列の先頭要素を更新するため、`a[0]` も9です。", [5, 6], [variable("output", "String", "9", "stdout")]),
            ]
        ),
        q(
            "silver-further-switch-char-fallthrough-001",
            category: "control-flow",
            tags: ["switch", "char", "fallthrough"],
            code: """
public class Test {
    public static void main(String[] args) {
        char c = 'b';
        switch (c) {
            case 'a': System.out.print("A");
            case 'b': System.out.print("B");
            default: System.out.print("D");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "B", misconception: "case bだけで止まると誤解", explanation: "breakがないためdefaultへフォールスルーします。"),
                choice("b", "BD", correct: true, explanation: "case 'b' から実行され、breakがないのでdefaultも実行されます。"),
                choice("c", "ABD", misconception: "case aから順に評価されると誤解", explanation: "実行開始位置は一致したcaseです。case aは実行されません。"),
                choice("d", "D", misconception: "defaultが常に先に実行されると誤解", explanation: "一致するcaseがある場合はそこから実行されます。"),
            ],
            intent: "switch文の一致位置とbreakなしフォールスルーを確認する。",
            steps: [
                step("switch式の値は文字 `'b'` です。", [3, 4], [variable("c", "char", "b", "main")]),
                step("`case 'b'` に一致するため、そこから `B` を出力します。`case 'a'` は飛ばされます。", [6], [variable("output so far", "String", "B", "stdout")]),
                step("`break` がないため次の `default` に流れ、`D` も出力されます。全体は `BD` です。", [7], [variable("output", "String", "BD", "stdout")]),
            ]
        ),
        q(
            "silver-further-switch-expression-yield-001",
            category: "control-flow",
            tags: ["switch expression", "yield", "Java 17"],
            code: """
public class Test {
    public static void main(String[] args) {
        int n = 2;
        int result = switch (n) {
            case 1 -> 10;
            default -> {
                yield 20;
            }
        };
        System.out.println(result);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "10", misconception: "case 1が常に選ばれると誤解", explanation: "nは2なのでcase 1には一致しません。"),
                choice("b", "20", correct: true, explanation: "defaultブロックが選ばれ、`yield 20` がswitch式の値になります。"),
                choice("c", "0", misconception: "defaultの値が代入されないと誤解", explanation: "switch式は値を返し、resultへ代入されます。"),
                choice("d", "コンパイルエラー", misconception: "switch式のブロックでyieldを使えないと誤解", explanation: "Java 17ではブロック形式のswitch式で `yield` を使って値を返します。"),
            ],
            intent: "Java 17のswitch式とyieldの基本を確認する。",
            steps: [
                step("`n` は2なので `case 1` には一致せず、defaultが選ばれます。", [3, 4, 5, 6], [variable("n", "int", "2", "main")]),
                step("defaultブロック内の `yield 20;` がswitch式の値になります。", [6, 7], [variable("switch result", "int", "20", "expression")]),
                step("resultへ20が代入され、出力は `20` です。", [4, 10], [variable("result", "int", "20", "main")]),
            ]
        ),
        q(
            "silver-further-for-scope-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "control-flow",
            tags: ["for", "scope", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        for (int i = 0; i < 1; i++) {
        }
        System.out.println(i);
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "0と出力される", misconception: "for内のiが外でも見えると誤解", explanation: "for初期化部で宣言したiのスコープはfor文内です。"),
                choice("b", "1と出力される", misconception: "ループ後のiを参照できると誤解", explanation: "ループ後にはiはスコープ外です。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "5行目の `i` はスコープ外なので解決できません。"),
                choice("d", "実行時にNullPointerExceptionになる", misconception: "スコープエラーを実行時問題と誤解", explanation: "コンパイル時に検出されます。"),
            ],
            intent: "for文の初期化部で宣言した変数のスコープを確認する。",
            steps: [
                step("`int i = 0` はfor文の初期化部で宣言されています。", [3], [variable("i", "int", "for-scope variable", "for")]),
                step("このiのスコープはfor文の本体と更新式・条件式までです。for文の外へ出ると見えません。", [3, 4, 5], [variable("i visible after loop", "boolean", "false", "compiler")]),
                step("5行目の `System.out.println(i)` でiを解決できないため、コンパイルエラーです。", [5], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-further-while-false-compile-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "control-flow",
            tags: ["while", "unreachable", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        while (false) {
            System.out.println("A");
        }
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "何も出力されず正常終了する", misconception: "到達不能なwhile本体が許可されると誤解", explanation: "`while(false)` の本体は到達不能文として扱われます。"),
                choice("b", "Aと出力される", misconception: "while条件を無視している", explanation: "条件はfalse固定です。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "定数falseのwhile文は本体が到達不能となり、コンパイルエラーです。"),
                choice("d", "実行時にIllegalStateExceptionになる", misconception: "到達不能文を実行時検査と誤解", explanation: "到達不能文はコンパイル時に検査されます。"),
            ],
            intent: "while(false)が到達不能文としてコンパイルエラーになることを確認する。",
            steps: [
                step("while条件がリテラル `false` なので、ループ本体へ到達する可能性がありません。", [3], [variable("condition", "boolean", "false", "compiler")]),
                step("Javaでは到達不能な文は原則コンパイルエラーです。`while(false)` の本体も該当します。", [3, 4], [variable("body reachable", "boolean", "false", "compiler")]),
                step("そのため実行前にコンパイルエラーになります。", [3], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-further-constructor-this-001",
            category: "classes",
            tags: ["constructor", "this", "overload"],
            code: """
public class Test {
    Test() {
        this(2);
        System.out.print("A");
    }
    Test(int value) {
        System.out.print(value);
    }
    public static void main(String[] args) {
        new Test();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2A", correct: true, explanation: "引数なしコンストラクタは最初に `this(2)` で別コンストラクタを呼び、その後Aを出力します。"),
                choice("b", "A2", misconception: "this呼び出しより前に本体が実行されると誤解", explanation: "コンストラクタ呼び出し `this(...)` は必ず先頭で実行されます。"),
                choice("c", "2", misconception: "this呼び出し後に戻らないと誤解", explanation: "呼び出し先コンストラクタ終了後、元のコンストラクタ本体へ戻ります。"),
                choice("d", "コンパイルエラー", misconception: "thisで別コンストラクタを呼べないと誤解", explanation: "同じクラス内の別コンストラクタを `this(...)` で呼び出せます。"),
            ],
            intent: "コンストラクタから別コンストラクタを呼ぶthis(...)の順序を確認する。",
            steps: [
                step("`new Test()` により引数なしコンストラクタが呼ばれます。", [9, 10], [variable("constructor", "Test()", "selected", "main")]),
                step("その先頭の `this(2)` が実行され、`Test(int value)` へ移動して2を出力します。", [2, 3, 6, 7], [variable("value", "int", "2", "Test(int)")]),
                step("呼び出し先から戻ると、引数なしコンストラクタの残りでAを出力します。全体は `2A` です。", [4], [variable("output", "String", "2A", "stdout")]),
            ]
        ),
        q(
            "silver-further-constructor-return-001",
            category: "classes",
            tags: ["constructor", "return"],
            code: """
public class Test {
    Test() {
        System.out.print("A");
        if (true) return;
        System.out.print("B");
    }
    public static void main(String[] args) {
        new Test();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", correct: true, explanation: "コンストラクタ内の `return;` はそこでコンストラクタ処理を終了します。"),
                choice("b", "AB", misconception: "return後も次の文へ進むと誤解", explanation: "`return;` でコンストラクタを抜けます。"),
                choice("c", "B", misconception: "return前の出力を見落とし", explanation: "returnより前にAを出力しています。"),
                choice("d", "コンパイルエラー", misconception: "コンストラクタでreturn文を使えないと誤解", explanation: "値を返さない `return;` はコンストラクタ内で使えます。"),
            ],
            intent: "コンストラクタ内の値なしreturn文の扱いを確認する。",
            steps: [
                step("`new Test()` でコンストラクタが実行され、まずAを出力します。", [7, 8, 3], [variable("output so far", "String", "A", "stdout")]),
                step("`if (true) return;` は必ず実行され、コンストラクタをそこで終了します。", [4], [variable("constructor state", "String", "returned", "Test()")]),
                step("その後のB出力には到達しないため、全体の出力は `A` です。", [5], [variable("output", "String", "A", "stdout")]),
            ]
        ),
        q(
            "silver-further-static-init-before-main-001",
            category: "classes",
            tags: ["static", "initialization", "main"],
            code: """
public class Test {
    static int value = init();
    static int init() {
        System.out.print("A");
        return 1;
    }
    public static void main(String[] args) {
        System.out.print("B");
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "AB", correct: true, explanation: "main実行前にクラス初期化でstaticフィールド初期化が行われ、Aの後にBです。"),
                choice("b", "BA", misconception: "mainがstatic初期化より先に走ると誤解", explanation: "main呼び出し前にクラス初期化が完了します。"),
                choice("c", "B", misconception: "staticフィールド初期化が使われないと実行されないと誤解", explanation: "クラス初期化時にstaticフィールド初期化子は実行されます。"),
                choice("d", "コンパイルエラー", misconception: "staticフィールド初期化でメソッドを呼べないと誤解", explanation: "staticメソッドはstaticフィールド初期化式から呼び出せます。"),
            ],
            intent: "main実行前のstatic初期化順を確認する。",
            steps: [
                step("`java Test` でmainを呼ぶ前に、Testクラスの初期化が必要になります。", [7], [variable("class init", "String", "before main", "JVM")]),
                step("staticフィールド `value` の初期化で `init()` が呼ばれ、Aを出力して1を返します。", [2, 3, 4, 5], [variable("value", "int", "1", "Test")]),
                step("クラス初期化後にmainが実行され、Bを出力します。全体は `AB` です。", [7, 8], [variable("output", "String", "AB", "stdout")]),
            ]
        ),
        q(
            "silver-further-instance-init-field-order-001",
            category: "classes",
            tags: ["instance initializer", "field initialization", "constructor"],
            code: """
public class Test {
    int value = 1;
    { value = 2; }
    Test() {
        System.out.println(value);
    }
    public static void main(String[] args) {
        new Test();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1", misconception: "フィールド初期化だけで止まると誤解", explanation: "インスタンス初期化ブロックがその後に実行されます。"),
                choice("b", "2", correct: true, explanation: "フィールド初期化で1になった後、インスタンス初期化ブロックで2に更新され、コンストラクタで出力されます。"),
                choice("c", "0", misconception: "明示初期化がコンストラクタ後だと誤解", explanation: "明示初期化と初期化ブロックはコンストラクタ本体より前です。"),
                choice("d", "コンパイルエラー", misconception: "初期化ブロックでフィールドを書き換えられないと誤解", explanation: "インスタンス初期化ブロックからインスタンスフィールドへ代入できます。"),
            ],
            intent: "フィールド初期化、インスタンス初期化ブロック、コンストラクタ本体の順序を確認する。",
            steps: [
                step("オブジェクト生成時、まずintフィールドは0になり、その後 `int value = 1;` が実行されます。", [2], [variable("value", "int", "1", "object")]),
                step("次にインスタンス初期化ブロック `{ value = 2; }` が実行され、valueは2になります。", [3], [variable("value", "int", "2", "object")]),
                step("コンストラクタ本体でvalueを出力するため、出力は `2` です。", [4, 5], [variable("output", "String", "2", "stdout")]),
            ]
        ),
        q(
            "silver-further-private-constructor-001",
            category: "classes",
            tags: ["constructor", "private", "access"],
            code: """
public class Test {
    private Test() {
        System.out.print("A");
    }
    static Test create() {
        return new Test();
    }
    public static void main(String[] args) {
        create();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", correct: true, explanation: "privateコンストラクタでも同じクラス内からは呼び出せます。"),
                choice("b", "何も出力されない", misconception: "createがオブジェクトを作らないと誤解", explanation: "`create()` 内で `new Test()` を呼んでいます。"),
                choice("c", "コンパイルエラー", misconception: "privateコンストラクタは常に呼べないと誤解", explanation: "privateは同じクラス内からアクセス可能です。"),
                choice("d", "IllegalAccessError", misconception: "アクセス制御を実行時エラーと誤解", explanation: "このアクセスはコンパイル時にも実行時にも有効です。"),
            ],
            intent: "privateコンストラクタのアクセス範囲を確認する。",
            steps: [
                step("`main` は同じクラス内のstaticメソッド `create()` を呼びます。", [8, 9], [variable("method", "String", "create", "main")]),
                step("`create()` もTestクラス内にあるため、privateコンストラクタ `new Test()` を呼び出せます。", [2, 5, 6], [variable("access", "boolean", "allowed", "Test")]),
                step("コンストラクタが実行されAを出力します。", [2, 3], [variable("output", "String", "A", "stdout")]),
            ]
        ),
        q(
            "silver-further-final-class-extends-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "inheritance",
            tags: ["final", "class", "compile"],
            code: """
final class Parent {
}

class Child extends Parent {
}

public class Test {
    public static void main(String[] args) {
        System.out.println("ok");
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "okと出力される", misconception: "final classを継承できると誤解", explanation: "finalクラスはサブクラス化できません。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "`Parent` はfinalなので、`Child extends Parent` は許可されません。"),
                choice("c", "実行時にClassCastExceptionになる", misconception: "継承禁止を実行時問題と誤解", explanation: "継承宣言時点でコンパイルエラーです。"),
                choice("d", "Childだけ無視されてTestは実行できる", misconception: "使っていないクラスのエラーが無視されると誤解", explanation: "同じソース内のクラス宣言はすべてコンパイル対象です。"),
            ],
            intent: "finalクラスを継承できないことを確認する。",
            steps: [
                step("`Parent` は `final class` として宣言されています。", [1], [variable("Parent", "class", "final", "source")]),
                step("`Child extends Parent` はfinalクラスを継承しようとしているため、Javaの規則に反します。", [4], [variable("extends allowed", "boolean", "false", "compiler")]),
                step("mainの中身に到達する前に、クラス宣言でコンパイルエラーになります。", [4, 8], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-further-overload-byte-specific-001",
            category: "overload-resolution",
            tags: ["overload", "byte", "specific"],
            code: """
public class Test {
    static void call(byte x) { System.out.println("byte"); }
    static void call(short x) { System.out.println("short"); }
    public static void main(String[] args) {
        call((byte) 1);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "byte", correct: true, explanation: "実引数の型がbyteなので、完全一致する `call(byte)` が選ばれます。"),
                choice("b", "short", misconception: "byteがshortへ必ず拡大されると誤解", explanation: "完全一致のbyte候補があるため、それが最優先です。"),
                choice("c", "コンパイルエラー", misconception: "byteへのキャストが無効と誤解", explanation: "`(byte) 1` は有効です。"),
                choice("d", "実行時にClassCastException", misconception: "プリミティブキャストを参照型キャストと混同", explanation: "これはコンパイル時に解決されるプリミティブのオーバーロードです。"),
            ],
            intent: "オーバーロード解決で完全一致が優先されることを確認する。",
            steps: [
                step("実引数 `(byte) 1` の型はbyteです。", [5], [variable("argument", "byte", "1", "main")]),
                step("候補は `call(byte)` と `call(short)` です。byteはshortへ拡大できますが、byte完全一致の方がより適合します。", [2, 3], [variable("selected method", "String", "call(byte)", "compiler")]),
                step("`call(byte)` が実行され、出力は `byte` です。", [2], [variable("output", "String", "byte", "stdout")]),
            ]
        ),
        q(
            "silver-further-overload-empty-varargs-001",
            category: "overload-resolution",
            tags: ["overload", "varargs", "empty arguments"],
            code: """
public class Test {
    static void call(int... values) { System.out.println("varargs"); }
    static void call(Integer value) { System.out.println("Integer"); }
    public static void main(String[] args) {
        call();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "varargs", correct: true, explanation: "引数なし呼び出しに適用できるのは `int...` の可変長引数メソッドです。"),
                choice("b", "Integer", misconception: "nullが自動で渡されると誤解", explanation: "引数なし呼び出しでInteger引数のメソッドは適用できません。"),
                choice("c", "コンパイルエラー", misconception: "可変長引数に0個を渡せないと誤解", explanation: "varargsは0個の実引数でも呼び出せます。"),
                choice("d", "NullPointerException", misconception: "空のvarargs配列がnullだと誤解", explanation: "varargsには空配列が渡されます。"),
            ],
            intent: "可変長引数メソッドが0個の実引数でも適用されることを確認する。",
            steps: [
                step("`call()` は実引数が0個です。", [5], [variable("argument count", "int", "0", "main")]),
                step("`call(Integer)` は1個の引数が必要なので適用できません。一方、`call(int...)` は0個でも呼べます。", [2, 3], [variable("selected method", "String", "call(int...)", "compiler")]),
                step("可変長引数版が実行され、出力は `varargs` です。", [2], [variable("output", "String", "varargs", "stdout")]),
            ]
        ),
        q(
            "silver-further-overload-widening-vs-varargs-001",
            category: "overload-resolution",
            tags: ["overload", "widening", "varargs"],
            code: """
public class Test {
    static void call(long value) { System.out.println("long"); }
    static void call(int... values) { System.out.println("varargs"); }
    public static void main(String[] args) {
        call(1);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "long", correct: true, explanation: "固定長引数の拡大変換 `int -> long` は、可変長引数より優先されます。"),
                choice("b", "varargs", misconception: "intに完全一致するvarargsが優先と誤解", explanation: "varargsは最終段階で検討され、固定長の拡大変換より後です。"),
                choice("c", "コンパイルエラー", misconception: "候補が複数あると常に曖昧と誤解", explanation: "解決規則によりlong版が選ばれます。"),
                choice("d", "Integer", misconception: "ボクシング候補があると誤解", explanation: "Integer引数のメソッドは宣言されていません。"),
            ],
            intent: "オーバーロード解決で固定長の拡大変換がvarargsより優先されることを確認する。",
            steps: [
                step("実引数 `1` はintリテラルです。", [5], [variable("argument", "int", "1", "main")]),
                step("`call(long)` はintからlongへの拡大変換で適用可能です。`call(int...)` も可能ですが、varargsは後回しです。", [2, 3], [variable("selected method", "String", "call(long)", "compiler")]),
                step("そのため出力は `long` です。", [2], [variable("output", "String", "long", "stdout")]),
            ]
        ),
        q(
            "silver-further-override-unchecked-throws-001",
            category: "inheritance",
            tags: ["override", "throws", "RuntimeException"],
            code: """
class Parent {
    void run() { System.out.println("P"); }
}
class Child extends Parent {
    @Override
    void run() throws RuntimeException { System.out.println("C"); }
}
public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        p.run();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "P", misconception: "参照型Parentのメソッド本体が実行されると誤解", explanation: "インスタンスメソッドは実行時型で動的ディスパッチされます。"),
                choice("b", "C", correct: true, explanation: "Childのrunがオーバーライドされ、非検査例外のthrows追加は許可されます。"),
                choice("c", "コンパイルエラー", misconception: "RuntimeExceptionのthrows追加も禁止と誤解", explanation: "検査例外の拡大は不可ですが、非検査例外は宣言できます。"),
                choice("d", "RuntimeExceptionが必ず発生する", misconception: "throws宣言だけで例外が投げられると誤解", explanation: "throwsは投げる可能性の宣言であり、この本体は例外を投げていません。"),
            ],
            intent: "オーバーライドと非検査例外throws宣言の扱いを確認する。",
            steps: [
                step("`Child.run` は `Parent.run` と同じシグネチャで、`RuntimeException` をthrows宣言しています。これは非検査例外なので許可されます。", [4, 5, 6], [variable("override", "boolean", "true", "compiler")]),
                step("`Parent p = new Child();` なので参照型はParentでも実体はChildです。", [10], [variable("p runtime type", "Class", "Child", "main")]),
                step("インスタンスメソッド呼び出しは実行時型に基づき、Child側のrunが実行されて `C` を出力します。", [11, 6], [variable("output", "String", "C", "stdout")]),
            ]
        ),
        q(
            "silver-further-static-method-hiding-001",
            category: "inheritance",
            tags: ["static", "method hiding", "reference type"],
            code: """
class Parent {
    static void show() { System.out.println("P"); }
}
class Child extends Parent {
    static void show() { System.out.println("C"); }
}
public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        p.show();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "P", correct: true, explanation: "staticメソッドはオーバーライドではなく隠蔽で、参照型Parentに基づいてParent.showが選ばれます。"),
                choice("b", "C", misconception: "staticメソッドも動的ディスパッチされると誤解", explanation: "staticメソッドの解決は参照型に基づきます。"),
                choice("c", "PC", misconception: "両方のstaticメソッドが実行されると誤解", explanation: "呼び出されるメソッドは1つです。"),
                choice("d", "コンパイルエラー", misconception: "インスタンス参照経由でstaticを呼べないと誤解", explanation: "推奨はされませんが、コンパイルは可能です。"),
            ],
            intent: "staticメソッド隠蔽と参照型による解決を確認する。",
            steps: [
                step("`Parent p = new Child();` により、変数pのコンパイル時型はParentです。", [9], [variable("p compile-time type", "Class", "Parent", "main")]),
                step("`show` はstaticメソッドなので、インスタンスメソッドのような実行時型ディスパッチは行われません。", [1, 4, 10], [variable("dispatch", "String", "static / by reference type", "compiler")]),
                step("参照型Parentに基づき `Parent.show()` が選ばれ、出力は `P` です。", [2, 10], [variable("output", "String", "P", "stdout")]),
            ]
        ),
        q(
            "silver-further-interface-default-001",
            category: "inheritance",
            tags: ["interface", "default method", "override"],
            code: """
interface Printable {
    default void print() { System.out.println("I"); }
}
class Book implements Printable {
}
public class Test {
    public static void main(String[] args) {
        new Book().print();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "I", correct: true, explanation: "Bookはprintを実装していないため、Printableのdefaultメソッドを継承して使います。"),
                choice("b", "何も出力されない", misconception: "defaultメソッドが自動実行されないと誤解", explanation: "`print()` を明示的に呼んでいます。"),
                choice("c", "コンパイルエラー", misconception: "defaultメソッドも必ず実装が必要と誤解", explanation: "defaultメソッドは実装を持つため、クラス側で必ずオーバーライドする必要はありません。"),
                choice("d", "AbstractMethodError", misconception: "interfaceメソッドは実行時に本体がないと誤解", explanation: "defaultメソッドには本体があります。"),
            ],
            intent: "interfaceのdefaultメソッドを実装クラスが継承できることを確認する。",
            steps: [
                step("`Printable` はdefaultメソッド `print()` を持っています。", [1, 2], [variable("Printable.print", "default method", "prints I", "interface")]),
                step("`Book` はPrintableを実装していますが、printをオーバーライドしていません。そのためdefault実装を利用できます。", [4], [variable("Book.print", "method", "inherited default", "Book")]),
                step("`new Book().print()` によりdefaultメソッドが呼ばれ、`I` が出力されます。", [8, 2], [variable("output", "String", "I", "stdout")]),
            ]
        ),
        q(
            "silver-further-abstract-instantiation-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "inheritance",
            tags: ["abstract", "instantiate", "compile"],
            code: """
abstract class Animal {
}
public class Test {
    public static void main(String[] args) {
        Animal a = new Animal();
        System.out.println(a);
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "Animalの参照文字列が出力される", misconception: "abstractクラスを直接newできると誤解", explanation: "abstractクラスはインスタンス化できません。"),
                choice("b", "nullと出力される", misconception: "newに失敗してnullになると誤解", explanation: "new式自体がコンパイルできません。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "`Animal` はabstractなので `new Animal()` はできません。"),
                choice("d", "InstantiationExceptionになる", misconception: "コンパイル時規則を実行時例外と混同", explanation: "直接newするコードはコンパイル時に拒否されます。"),
            ],
            intent: "abstractクラスを直接インスタンス化できないことを確認する。",
            steps: [
                step("`Animal` はabstractクラスとして宣言されています。", [1], [variable("Animal", "class", "abstract", "source")]),
                step("abstractクラスは共通の型として参照変数には使えますが、直接 `new` できません。", [5], [variable("new Animal()", "expression", "invalid", "compiler")]),
                step("そのため5行目でコンパイルエラーになります。", [5], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-further-downcast-valid-001",
            category: "inheritance",
            tags: ["cast", "polymorphism", "downcast"],
            code: """
class Animal {}
class Cat extends Animal {}
public class Test {
    public static void main(String[] args) {
        Animal a = new Cat();
        Cat c = (Cat) a;
        System.out.println(c instanceof Cat);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", correct: true, explanation: "aの実体はCatなので、Catへのダウンキャストは成功します。"),
                choice("b", "false", misconception: "参照型Animalのままだと誤解", explanation: "キャスト後のcはCat参照で、実体もCatです。"),
                choice("c", "ClassCastException", misconception: "ダウンキャストは常に失敗すると誤解", explanation: "実体がCatなので成功します。"),
                choice("d", "コンパイルエラー", misconception: "親型から子型へのキャストを書けないと誤解", explanation: "明示キャストがあればコンパイルできます。"),
            ],
            intent: "実体型に合うダウンキャストが成功することを確認する。",
            steps: [
                step("`Animal a = new Cat();` で、参照型はAnimalですが実体はCatです。", [5], [variable("a runtime type", "Class", "Cat", "main")]),
                step("`(Cat) a` は実体型Catに合っているため、実行時チェックに成功します。", [6], [variable("c", "Cat", "same Cat object", "main")]),
                step("`c instanceof Cat` はtrueなので、出力は `true` です。", [7], [variable("output", "String", "true", "stdout")]),
            ]
        ),
        q(
            "silver-further-instanceof-null-001",
            category: "inheritance",
            tags: ["instanceof", "null"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = null;
        System.out.println(s instanceof String);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", misconception: "変数の宣言型Stringだけで判定すると誤解", explanation: "instanceofは実体オブジェクトを確認します。nullはどの型のインスタンスでもありません。"),
                choice("b", "false", correct: true, explanation: "`null instanceof String` はfalseです。NullPointerExceptionにはなりません。"),
                choice("c", "NullPointerException", misconception: "nullに対するinstanceofが例外になると誤解", explanation: "instanceofの左辺がnullの場合はfalseを返します。"),
                choice("d", "コンパイルエラー", misconception: "nullをString変数に代入できないと誤解", explanation: "参照型変数にはnullを代入できます。"),
            ],
            intent: "instanceofの左辺がnullの場合の結果を確認する。",
            steps: [
                step("`s` はString型の参照変数ですが、値はnullです。", [3], [variable("s", "String", "null", "main")]),
                step("`instanceof` は左辺の実体オブジェクトが指定型かを調べます。nullには実体がありません。", [4], [variable("s instanceof String", "boolean", "false", "main")]),
                step("例外ではなくfalseが返り、そのまま `false` と出力されます。", [4], [variable("output", "String", "false", "stdout")]),
            ]
        ),
        q(
            "silver-further-try-finally-normal-001",
            category: "exception-handling",
            tags: ["try", "finally", "normal flow"],
            code: """
public class Test {
    public static void main(String[] args) {
        try {
            System.out.print("T");
        } finally {
            System.out.print("F");
        }
        System.out.print("C");
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "TF", misconception: "finally後に処理が続かないと誤解", explanation: "例外やreturnがなければfinally後の文へ進みます。"),
                choice("b", "TFC", correct: true, explanation: "tryでT、finallyでF、その後の通常処理でCを出力します。"),
                choice("c", "TCF", misconception: "finallyが最後にまとめて実行されると誤解", explanation: "finallyはtryブロックを抜ける直前、次の文Cより先に実行されます。"),
                choice("d", "コンパイルエラー", misconception: "catchなしtry-finallyが不可と誤解", explanation: "tryにはcatchまたはfinallyのどちらかがあれば有効です。"),
            ],
            intent: "catchなしtry-finallyと通常フローの順序を確認する。",
            steps: [
                step("tryブロックでTを出力します。", [3, 4], [variable("output so far", "String", "T", "stdout")]),
                step("tryを抜ける前にfinallyが必ず実行され、Fを出力します。", [5, 6], [variable("output so far", "String", "TF", "stdout")]),
                step("finally後、例外もreturnもないため次の文へ進みCを出力します。全体は `TFC` です。", [8], [variable("output", "String", "TFC", "stdout")]),
            ]
        ),
        q(
            "silver-further-finally-throws-replaces-001",
            category: "exception-handling",
            tags: ["finally", "exception", "replacement"],
            code: """
public class Test {
    public static void main(String[] args) {
        try {
            try {
                throw new IllegalArgumentException();
            } finally {
                throw new RuntimeException();
            }
        } catch (Exception e) {
            System.out.println(e.getClass().getSimpleName());
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "IllegalArgumentException", misconception: "tryで最初に投げた例外が必ず残ると誤解", explanation: "finallyで別の例外を投げると、元の例外は置き換えられます。"),
                choice("b", "RuntimeException", correct: true, explanation: "finallyがRuntimeExceptionを投げるため、外側catchで捕まる例外はRuntimeExceptionです。"),
                choice("c", "Exception", misconception: "catch型名が出力されると誤解", explanation: "出力しているのは実際の例外オブジェクトのクラス名です。"),
                choice("d", "コンパイルエラー", misconception: "finallyで例外を投げられないと誤解", explanation: "非検査例外RuntimeExceptionはthrows宣言なしで投げられます。"),
            ],
            intent: "finallyで投げた例外がtry内の例外を置き換えるケースを確認する。",
            steps: [
                step("内側tryで `IllegalArgumentException` が投げられます。", [4, 5], [variable("original exception", "IllegalArgumentException", "thrown", "inner try")]),
                step("しかしtryを抜ける前にfinallyが実行され、そこで `RuntimeException` が新たに投げられます。", [6, 7], [variable("replacing exception", "RuntimeException", "thrown", "finally")]),
                step("外側catchが受け取るのはfinallyからのRuntimeExceptionなので、出力は `RuntimeException` です。", [9, 10], [variable("caught", "Exception", "RuntimeException", "catch")]),
            ]
        ),
        q(
            "silver-further-multicatch-final-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "exception-handling",
            tags: ["multi-catch", "effectively final", "compile"],
            code: """
import java.io.*;

public class Test {
    public static void main(String[] args) {
        try {
            throw new IOException();
        } catch (IOException | RuntimeException e) {
            e = null;
            System.out.println(e);
        }
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "nullと出力される", misconception: "multi-catch変数へ再代入できると誤解", explanation: "multi-catchの例外パラメータは暗黙的にfinalです。"),
                choice("b", "IOExceptionと出力される", misconception: "再代入行が無視されると誤解", explanation: "再代入しようとした時点でコンパイルエラーです。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "multi-catchのcatchパラメータ `e` には再代入できません。"),
                choice("d", "RuntimeExceptionになる", misconception: "IOExceptionがRuntimeExceptionへ変換されると誤解", explanation: "例外型は変換されません。問題はcatchパラメータへの代入です。"),
            ],
            intent: "multi-catchの例外パラメータが暗黙的にfinalであることを確認する。",
            steps: [
                step("catch句は `IOException | RuntimeException e` のmulti-catchです。", [7], [variable("catch parameter", "Exception", "e", "catch")]),
                step("multi-catchの例外パラメータは暗黙的にfinal扱いとなり、catchブロック内で再代入できません。", [7, 8], [variable("assignable", "boolean", "false", "compiler")]),
                step("8行目の `e = null;` によりコンパイルエラーになります。", [8], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-further-arraylist-set-return-001",
            category: "collections",
            tags: ["ArrayList", "set", "return value"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        ArrayList<String> list = new ArrayList<>(List.of("A", "B"));
        String old = list.set(0, "X");
        System.out.println(old + ":" + list);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A:[X, B]", correct: true, explanation: "`set` は指定位置を置換し、戻り値として古い要素Aを返します。"),
                choice("b", "X:[X, B]", misconception: "setの戻り値が新しい要素だと誤解", explanation: "setの戻り値は置換前の要素です。"),
                choice("c", "A:[A, B, X]", misconception: "setをaddと混同", explanation: "setは追加ではなく置換です。"),
                choice("d", "コンパイルエラー", misconception: "List.ofからArrayListを作れないと誤解", explanation: "コンストラクタにCollectionとして渡せます。"),
            ],
            intent: "ArrayList.setの置換と戻り値を確認する。",
            steps: [
                step("listは最初 `[A, B]` です。", [5], [variable("list", "ArrayList<String>", "[A, B]", "main")]),
                step("`list.set(0, \"X\")` はインデックス0をXに置き換え、古い値Aを返します。", [6], [variable("old", "String", "A", "main"), variable("list", "ArrayList<String>", "[X, B]", "main")]),
                step("古い値とlistを出力し、結果は `A:[X, B]` です。", [7], [variable("output", "String", "A:[X, B]", "stdout")]),
            ]
        ),
        q(
            "silver-further-list-remove-object-001",
            category: "collections",
            tags: ["List", "remove", "Integer"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<Integer> list = new ArrayList<>(List.of(1, 2, 3));
        list.remove(Integer.valueOf(2));
        System.out.println(list);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "[1, 3]", correct: true, explanation: "`Integer.valueOf(2)` を渡しているため、値2の要素が削除されます。"),
                choice("b", "[1, 2]", misconception: "インデックス2の要素が削除されると誤解", explanation: "引数型がIntegerなので `remove(Object)` が選ばれます。"),
                choice("c", "[2, 3]", misconception: "インデックス0が削除されると誤解", explanation: "削除対象は値2です。"),
                choice("d", "IndexOutOfBoundsException", misconception: "remove(int)が選ばれると誤解", explanation: "`Integer.valueOf(2)` はObjectとして扱われ、値削除です。"),
            ],
            intent: "List.removeのint版とObject版の違いを確認する。",
            steps: [
                step("listは最初 `[1, 2, 3]` です。", [5], [variable("list", "List<Integer>", "[1, 2, 3]", "main")]),
                step("引数は `Integer.valueOf(2)` なので、インデックス指定の `remove(int)` ではなく、要素指定の `remove(Object)` が選ばれます。", [6], [variable("selected overload", "String", "remove(Object)", "compiler")]),
                step("値2が削除され、出力は `[1, 3]` です。", [7], [variable("output", "String", "[1, 3]", "stdout")]),
            ]
        ),
        q(
            "silver-further-predicate-and-001",
            category: "lambda-streams",
            tags: ["Predicate", "lambda", "and"],
            code: """
import java.util.function.*;

public class Test {
    public static void main(String[] args) {
        Predicate<String> p = s -> s.length() > 1;
        Predicate<String> q = s -> s.startsWith("A");
        System.out.println(p.and(q).test("AB"));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", correct: true, explanation: "`AB` は長さ2で、かつAで始まるため、p.and(q)はtrueです。"),
                choice("b", "false", misconception: "片方のPredicateだけを見ている", explanation: "どちらの条件も満たしています。"),
                choice("c", "AB", misconception: "Predicateが元の値を返すと誤解", explanation: "Predicate.testはbooleanを返します。"),
                choice("d", "コンパイルエラー", misconception: "Predicate同士をandで合成できないと誤解", explanation: "Predicateにはdefaultメソッド `and` があります。"),
            ],
            intent: "Predicateのand合成とtest結果を確認する。",
            steps: [
                step("pは文字列長が1より大きいか、qはAで始まるかを判定します。", [5, 6], [variable("p", "Predicate<String>", "length > 1", "main"), variable("q", "Predicate<String>", "startsWith A", "main")]),
                step("`p.and(q)` は、pとqの両方がtrueのときだけtrueを返すPredicateです。", [7], [variable("combined", "Predicate<String>", "p && q", "main")]),
                step("`AB` は長さ2でA開始なので、出力は `true` です。", [7], [variable("output", "String", "true", "stdout")]),
            ]
        ),
        q(
            "silver-further-consumer-andthen-001",
            category: "lambda-streams",
            tags: ["Consumer", "lambda", "andThen"],
            code: """
import java.util.function.*;

public class Test {
    public static void main(String[] args) {
        Consumer<String> c = s -> System.out.print(s);
        c.andThen(s -> System.out.print(s.toLowerCase())).accept("A");
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", misconception: "andThen側が実行されないと誤解", explanation: "`accept` すると元のConsumerの後にandThenのConsumerも実行されます。"),
                choice("b", "a", misconception: "後続Consumerだけが実行されると誤解", explanation: "先に元のConsumerが実行されます。"),
                choice("c", "Aa", correct: true, explanation: "最初にAを出力し、次に小文字化したaを出力します。"),
                choice("d", "コンパイルエラー", misconception: "Consumerは値を返す必要があると誤解", explanation: "Consumer.acceptは戻り値なしの処理です。"),
            ],
            intent: "Consumer.andThenの実行順を確認する。",
            steps: [
                step("最初のConsumer `c` は受け取った文字列をそのまま出力します。", [5], [variable("c", "Consumer<String>", "prints input", "main")]),
                step("`andThen` で後続Consumerをつなぎ、`accept(\"A\")` を呼びます。まずcがAを出力します。", [6], [variable("output so far", "String", "A", "stdout")]),
                step("次に後続Consumerが `A` を小文字化してaを出力するため、全体は `Aa` です。", [6], [variable("output", "String", "Aa", "stdout")]),
            ]
        ),
        q(
            "silver-further-var-for-loop-001",
            category: "java-basics",
            tags: ["var", "for", "local variable type inference"],
            code: """
public class Test {
    public static void main(String[] args) {
        for (var i = 0; i < 2; i++) {
            System.out.print(i);
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "01", correct: true, explanation: "`var i = 0` はintと推論され、iが0,1の2回出力されます。"),
                choice("b", "12", misconception: "iの初期値を1と誤解", explanation: "初期値は0です。"),
                choice("c", "0", misconception: "ループが1回だけと誤解", explanation: "i=0とi=1で条件 `i < 2` を満たします。"),
                choice("d", "コンパイルエラー", misconception: "for初期化部でvarを使えないと誤解", explanation: "ローカル変数宣言としてのfor初期化部ではvarを使えます。"),
            ],
            intent: "for文のローカル変数宣言でvarが使えることを確認する。",
            steps: [
                step("`var i = 0` は初期値0からint型と推論されます。", [3], [variable("i", "int", "0", "for")]),
                step("i=0で0を出力し、更新式でiは1になります。次も `1 < 2` なので1を出力します。", [3, 4], [variable("output so far", "String", "01", "stdout")]),
                step("iが2になると条件がfalseになり、全体の出力は `01` です。", [3], [variable("output", "String", "01", "stdout")]),
            ]
        ),
        q(
            "silver-further-block-scope-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "java-basics",
            tags: ["scope", "block", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        {
            int value = 10;
        }
        System.out.println(value);
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "10と出力される", misconception: "ブロック内のローカル変数が外でも使えると誤解", explanation: "valueのスコープは宣言されたブロック内だけです。"),
                choice("b", "0と出力される", misconception: "ローカル変数にデフォルト値があると誤解", explanation: "ローカル変数にはデフォルト値はありません。今回はスコープ外です。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "6行目のvalueは宣言ブロックの外なので参照できません。"),
                choice("d", "NullPointerExceptionになる", misconception: "未初期化を実行時nullと混同", explanation: "スコープ外参照はコンパイル時エラーです。"),
            ],
            intent: "ブロック内で宣言したローカル変数のスコープを確認する。",
            steps: [
                step("`value` は内側の `{ ... }` ブロックで宣言されています。", [3, 4, 5], [variable("value", "int", "10", "inner block")]),
                step("ブロックを閉じた後、valueはスコープ外になります。", [5, 6], [variable("value visible", "boolean", "false", "compiler")]),
                step("6行目でvalueを参照しようとしているため、コンパイルエラーです。", [6], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-further-main-order-modifiers-001",
            category: "java-basics",
            tags: ["main", "modifier order", "entrypoint"],
            code: """
public class Test {
    static public void main(String[] args) {
        System.out.println("ok");
    }
}
""",
            question: "`java Test` として起動したとき、結果として正しいものはどれか？",
            choices: [
                choice("a", "okと出力される", correct: true, explanation: "`static public` の順でも `public static` と同じ修飾子なので、mainとして認識されます。"),
                choice("b", "起動用mainとして認識されない", misconception: "修飾子の順序が固定だと誤解", explanation: "修飾子の順序はこの場合問題になりません。"),
                choice("c", "コンパイルエラー", misconception: "static publicの順が禁止だと誤解", explanation: "複数の修飾子は順序を入れ替えても書けます。"),
                choice("d", "何も出力されない", misconception: "main本体が呼ばれないと誤解", explanation: "Javaランチャーが有効なmainとして呼び出します。"),
            ],
            intent: "mainメソッドの修飾子順序が起動可否に影響しないことを確認する。",
            steps: [
                step("メソッドは `static public void main(String[] args)` と宣言されています。", [2], [variable("method", "String", "main(String[])", "Test")]),
                step("`public` と `static` の順序は入れ替わっていても、どちらの修飾子も付いています。戻り値もvoidです。", [2], [variable("entrypoint valid", "boolean", "true", "launcher")]),
                step("Javaランチャーから呼び出され、`ok` が出力されます。", [3], [variable("output", "String", "ok", "stdout")]),
            ]
        ),
        q(
            "silver-further-string-isblank-strip-001",
            category: "string",
            tags: ["String", "isBlank", "strip"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = "  ";
        System.out.println(s.isBlank() + ":" + s.strip().length());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true:0", correct: true, explanation: "`isBlank()` は空白だけの文字列でtrue。`strip()` 後は空文字なので長さ0です。"),
                choice("b", "false:0", misconception: "空白だけでもblankではないと誤解", explanation: "空白のみの文字列はblankです。"),
                choice("c", "true:2", misconception: "stripが元の空白を残すと誤解", explanation: "`strip()` は前後の空白を取り除いた新しいStringを返します。"),
                choice("d", "コンパイルエラー", misconception: "Java 17でisBlank/stripが使えないと誤解", explanation: "Java 11以降で利用できます。"),
            ],
            intent: "String.isBlankとstripの基本挙動を確認する。",
            steps: [
                step("`s` は半角スペース2つだけの文字列です。", [3], [variable("s", "String", "\"  \"", "main")]),
                step("`isBlank()` は空文字または空白だけならtrueです。`strip()` は前後の空白を取り除きます。", [4], [variable("s.isBlank()", "boolean", "true", "main"), variable("s.strip()", "String", "\"\"", "main")]),
                step("strip後の長さは0なので、出力は `true:0` です。", [4], [variable("output", "String", "true:0", "stdout")]),
            ]
        ),
        q(
            "silver-further-string-repeat-001",
            category: "string",
            tags: ["String", "repeat", "concat"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = "ha".repeat(2).concat("!");
        System.out.println(s);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "ha!", misconception: "repeat(2)を1回追加と誤解", explanation: "`repeat(2)` は元文字列を2回繰り返します。"),
                choice("b", "haha!", correct: true, explanation: "`ha` を2回繰り返して `haha`、そこへ `!` を連結します。"),
                choice("c", "hahaha!", misconception: "repeat(2)を2回追加と誤解", explanation: "合計2回の繰り返しです。"),
                choice("d", "コンパイルエラー", misconception: "repeatの戻り値にconcatできないと誤解", explanation: "repeatもconcatもStringを返すため連鎖できます。"),
            ],
            intent: "String.repeatとconcatの戻り値連鎖を確認する。",
            steps: [
                step("`\"ha\".repeat(2)` は `ha` を2回並べて `haha` を返します。", [3], [variable("repeat result", "String", "haha", "main")]),
                step("その戻り値に `.concat(\"!\")` を呼び、`haha!` になります。", [3], [variable("s", "String", "haha!", "main")]),
                step("printlnで `haha!` が出力されます。", [4], [variable("output", "String", "haha!", "stdout")]),
            ]
        ),
        q(
            "silver-further-array-copyof-001",
            category: "data-types",
            tags: ["Arrays", "copyOf", "default value"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        int[] src = {1, 2};
        int[] copy = Arrays.copyOf(src, 4);
        System.out.println(Arrays.toString(copy));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "[1, 2]", misconception: "新しい長さ指定を無視すると誤解", explanation: "copyOfの第2引数はコピー先配列の長さです。"),
                choice("b", "[1, 2, 0, 0]", correct: true, explanation: "長さ4へ拡張され、追加されたint要素はデフォルト値0になります。"),
                choice("c", "[1, 2, null, null]", misconception: "int配列にnullが入ると誤解", explanation: "intはプリミティブ型なので追加要素は0です。"),
                choice("d", "IndexOutOfBoundsException", misconception: "元配列より長いコピーが不可と誤解", explanation: "長くコピーすると不足分はデフォルト値で埋まります。"),
            ],
            intent: "Arrays.copyOfで配列を拡張したときのデフォルト値を確認する。",
            steps: [
                step("元配列srcは `[1, 2]` です。", [5], [variable("src", "int[]", "[1, 2]", "main")]),
                step("`Arrays.copyOf(src, 4)` は長さ4の新しいint配列を作り、先頭2要素をコピーします。", [6], [variable("copy length", "int", "4", "main")]),
                step("残り2要素はintのデフォルト値0なので、出力は `[1, 2, 0, 0]` です。", [7], [variable("copy", "int[]", "[1, 2, 0, 0]", "main")]),
            ]
        ),
        q(
            "silver-further-polymorphic-field-method-001",
            category: "inheritance",
            tags: ["polymorphism", "field hiding", "method override"],
            code: """
class Parent {
    String name = "P";
    String getName() { return name; }
}
class Child extends Parent {
    String name = "C";
    @Override String getName() { return name; }
}
public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        System.out.println(p.name + ":" + p.getName());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "P:P", misconception: "メソッドも参照型で固定されると誤解", explanation: "インスタンスメソッドはオーバーライドにより実行時型で選ばれます。"),
                choice("b", "P:C", correct: true, explanation: "フィールド参照は参照型ParentでP、メソッド呼び出しはChild側でCです。"),
                choice("c", "C:C", misconception: "フィールドもポリモーフィックに選ばれると誤解", explanation: "フィールドは隠蔽であり、参照型に基づきます。"),
                choice("d", "コンパイルエラー", misconception: "同名フィールドをサブクラスに宣言できないと誤解", explanation: "フィールドは隠蔽できます。"),
            ],
            intent: "フィールド隠蔽とメソッドオーバーライドの違いを確認する。",
            steps: [
                step("`Parent p = new Child();` で、参照型はParent、実体はChildです。", [11], [variable("p compile/runtime", "type", "Parent / Child", "main")]),
                step("`p.name` はフィールド参照なので参照型Parentに基づき、Parentの `name = \"P\"` が使われます。", [2, 12], [variable("p.name", "String", "P", "main")]),
                step("`p.getName()` はインスタンスメソッドなのでChild側が実行され、ChildのnameでCを返します。出力は `P:C` です。", [7, 12], [variable("p.getName()", "String", "C", "main")]),
            ]
        ),
        q(
            "silver-further-catch-unchecked-no-throws-001",
            category: "exception-handling",
            tags: ["RuntimeException", "catch", "throws"],
            code: """
public class Test {
    static void run() {
        throw new RuntimeException();
    }
    public static void main(String[] args) {
        try {
            run();
        } catch (RuntimeException e) {
            System.out.println("R");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "R", correct: true, explanation: "RuntimeExceptionは非検査例外なのでthrows宣言不要で、catchで捕捉されます。"),
                choice("b", "何も出力されない", misconception: "例外でプログラムが即終了すると誤解", explanation: "try-catchでRuntimeExceptionを捕捉しています。"),
                choice("c", "コンパイルエラー", misconception: "RuntimeExceptionにもthrows宣言が必須と誤解", explanation: "非検査例外は宣言または捕捉が必須ではありません。"),
                choice("d", "Exception", misconception: "例外クラス名が自動出力されると誤解", explanation: "catch内で明示的にRを出力しています。"),
            ],
            intent: "非検査例外のthrows宣言不要とcatch捕捉を確認する。",
            steps: [
                step("`run()` は `RuntimeException` を投げますが、RuntimeExceptionは非検査例外なのでthrows宣言は必須ではありません。", [2, 3], [variable("exception type", "RuntimeException", "unchecked", "run")]),
                step("mainでは `run()` をtryブロック内で呼び出しています。例外が発生するとcatchへ制御が移ります。", [6, 7, 8], [variable("caught", "RuntimeException", "yes", "catch")]),
                step("catchブロックでRを出力するため、結果は `R` です。", [9], [variable("output", "String", "R", "stdout")]),
            ]
        ),
        q(
            "silver-further-local-variable-uninitialized-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "java-basics",
            tags: ["local variable", "definite assignment", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        int value;
        System.out.println(value);
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "0と出力される", misconception: "ローカル変数にもデフォルト値があると誤解", explanation: "ローカル変数は自動初期化されません。"),
                choice("b", "nullと出力される", misconception: "intがnullになると誤解", explanation: "intはプリミティブ型であり、さらにローカル変数は未初期化です。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "ローカル変数 `value` は使用前に確実に代入されていません。"),
                choice("d", "実行時にNullPointerExceptionになる", misconception: "未初期化を実行時nullと混同", explanation: "コンパイル時の definite assignment エラーです。"),
            ],
            intent: "ローカル変数にはデフォルト値がなく、使用前の代入が必要であることを確認する。",
            steps: [
                step("`int value;` はローカル変数の宣言だけで、値を代入していません。", [3], [variable("value", "int", "unassigned", "main")]),
                step("フィールドや配列要素と違い、ローカル変数はデフォルト値で自動初期化されません。", [3], [variable("default initialization", "boolean", "false", "local variable")]),
                step("4行目で未代入のvalueを読もうとするため、コンパイルエラーです。", [4], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-further-method-parameter-passbyvalue-001",
            category: "classes",
            tags: ["method", "pass by value", "reference"],
            code: """
class Box {
    int value;
}
public class Test {
    static void change(Box b) {
        b.value = 5;
        b = new Box();
        b.value = 9;
    }
    public static void main(String[] args) {
        Box box = new Box();
        change(box);
        System.out.println(box.value);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", misconception: "メソッド内のフィールド変更も呼び出し元へ影響しないと誤解", explanation: "参照先オブジェクトのフィールド変更は見えます。"),
                choice("b", "5", correct: true, explanation: "最初の `b.value = 5` は元のBoxを変更します。その後bを新しいBoxに向けても呼び出し元boxは変わりません。"),
                choice("c", "9", misconception: "仮引数bの再代入が呼び出し元boxにも反映されると誤解", explanation: "参照値そのものは値渡しなので、仮引数の再代入は呼び出し元に影響しません。"),
                choice("d", "コンパイルエラー", misconception: "同じ名前のbへ再代入できないと誤解", explanation: "仮引数はfinalでなければ再代入できます。"),
            ],
            intent: "Javaが参照値を値渡しすることと、オブジェクト内容の変更の違いを確認する。",
            steps: [
                step("mainの `box` はvalueが0のBoxを参照し、その参照値が `change` の仮引数bへコピーされます。", [10, 11, 12], [variable("box/b", "Box ref", "same Box(value=0)", "change")]),
                step("`b.value = 5` は同じBoxオブジェクトのフィールドを変更するため、main側のboxからも見えます。", [6], [variable("box.value", "int", "5", "heap")]),
                step("その後 `b = new Box()` で仮引数bだけが別Boxを指します。mainのboxは元のBoxのままなので、出力は5です。", [7, 8, 13], [variable("output", "String", "5", "stdout")]),
            ]
        ),
    ]

    static func q(
        _ id: String,
        difficulty: QuizDifficulty = .standard,
        estimatedSeconds: Int = 75,
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

extension SilverFurtherQuestionData.Spec {
    var quiz: Quiz {
        Quiz(
            id: id,
            level: .silver,
            difficulty: difficulty,
            estimatedSeconds: estimatedSeconds,
            validatedByJavac: validatedByJavac,
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
    static let silverFurtherExpansion: [Quiz] = SilverFurtherQuestionData.specs.map(\.quiz)
}
