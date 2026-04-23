import Foundation

enum SilverBalancedQuestionData {
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
            "silver-balanced-main-varargs-001",
            category: "java-basics",
            tags: ["main", "varargs", "entrypoint"],
            code: """
public class Test {
    public static void main(String... args) {
        System.out.println(args.length);
    }
}
""",
            question: "このクラスを `java Test A B` として実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", misconception: "コマンドライン引数がmainに渡らないと誤解", explanation: "AとBの2つが `args` に入ります。"),
                choice("b", "1", misconception: "引数全体を1つの文字列として数えると誤解", explanation: "空白で区切られたAとBは別要素です。"),
                choice("c", "2", correct: true, explanation: "`String...` は `String[]` と同じくエントリポイントとして有効で、AとBの2要素です。"),
                choice("d", "起動できない", misconception: "varargs形式のmainを認識しないと誤解", explanation: "`main(String... args)` は `main(String[] args)` と同等に扱われます。"),
            ],
            intent: "mainメソッドのString可変長引数形式とコマンドライン引数数を確認する。",
            steps: [
                step("`String... args` はコンパイル後には `String[]` と同じ引数形です。mainメソッドとして認識されます。", [2], [variable("args type", "String[]", "varargs form", "main")]),
                step("`java Test A B` で起動すると、`args[0]` はA、`args[1]` はBです。", [2], [variable("args", "String[]", "[A, B]", "main")]),
                step("`args.length` は2なので、出力は `2` です。", [3], [variable("output", "int", "2", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-java-lang-import-001",
            category: "java-basics",
            tags: ["java.lang", "import", "Math"],
            code: """
public class Test {
    public static void main(String[] args) {
        System.out.println(Math.max(3, 7));
    }
}
""",
            question: "このコードについて正しい説明はどれか？",
            choices: [
                choice("a", "import java.lang.Math; がないのでコンパイルエラー", misconception: "java.langの自動インポートを見落とし", explanation: "`java.lang` パッケージは自動的にインポートされます。"),
                choice("b", "正常にコンパイルでき、7を出力する", correct: true, explanation: "`Math` は `java.lang` にあり、`max(3, 7)` は7を返します。"),
                choice("c", "正常にコンパイルでき、3を出力する", misconception: "maxの意味を逆に理解", explanation: "`Math.max` は大きい方を返します。"),
                choice("d", "実行時にClassNotFoundExceptionになる", misconception: "標準クラスの解決を実行時問題と誤解", explanation: "`java.lang.Math` は標準ライブラリのクラスです。"),
            ],
            intent: "java.langの自動インポートとMath.maxの基本を確認する。",
            steps: [
                step("`Math` は `java.lang.Math` のクラスです。`java.lang` は明示importなしで使えます。", [3], [variable("Math", "Class", "java.lang.Math", "compiler")]),
                step("`Math.max(3, 7)` は2つのintの大きい方、つまり7を返します。", [3], [variable("max result", "int", "7", "main")]),
                step("その値をprintlnして、出力は `7` です。", [3], [variable("output", "String", "7", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-public-class-file-name-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "java-basics",
            tags: ["public class", "source file", "compile"],
            code: """
// ファイル名: Test.java
public class Sample {
    public static void main(String[] args) {
        System.out.println("ok");
    }
}
""",
            question: "このソースファイルを `Test.java` としてコンパイルした場合、結果はどうなるか？",
            choices: [
                choice("a", "正常にコンパイルされ、okを出力できる", misconception: "publicクラス名とファイル名の規則を見落とし", explanation: "publicトップレベルクラス名はファイル名と一致する必要があります。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "`public class Sample` を含むファイル名は `Sample.java` でなければなりません。"),
                choice("c", "実行時にNoClassDefFoundErrorになる", misconception: "コンパイル時の規則を実行時問題と誤解", explanation: "ファイル名不一致はコンパイル時に検出されます。"),
                choice("d", "publicを付けるほど優先され、ファイル名は自由になる", misconception: "publicの意味を逆に理解", explanation: "publicだからこそ、外部公開名とファイル名を一致させる必要があります。"),
            ],
            intent: "publicトップレベルクラスとソースファイル名の一致規則を確認する。",
            steps: [
                step("ソースファイル名は `Test.java` とされています。", [1], [variable("file name", "String", "Test.java", "source")]),
                step("ファイル内のpublicトップレベルクラス名は `Sample` です。Javaではpublicトップレベルクラス名とファイル名が一致する必要があります。", [2], [variable("public class", "String", "Sample", "source")]),
                step("`Sample.java` ではないためコンパイルエラーです。実行時まで進みません。", [2], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-balanced-main-return-type-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "java-basics",
            tags: ["main", "return type", "entrypoint"],
            code: """
public class Test {
    public static int main(String[] args) {
        System.out.println("A");
        return 0;
    }
}
""",
            question: "`java Test` として起動しようとした場合の説明として正しいものはどれか？",
            choices: [
                choice("a", "Aと出力される", misconception: "戻り値intのmainもエントリポイントになると誤解", explanation: "起動エントリポイントのmainは `void` 戻り値である必要があります。"),
                choice("b", "0と出力される", misconception: "mainの戻り値が標準出力へ出ると誤解", explanation: "mainの戻り値が標準出力へ自動表示されることはありません。そもそもこの形は起動用mainではありません。"),
                choice("c", "起動用mainメソッドとして認識されない", correct: true, explanation: "`public static void main(String[] args)` ではないため、Javaランチャーのエントリポイントとしては使えません。"),
                choice("d", "コンパイル自体が必ず失敗する", misconception: "mainという名前のintメソッドを定義できないと誤解", explanation: "通常のstaticメソッドとしては定義できますが、起動用mainではありません。"),
            ],
            intent: "Javaランチャーが認識するmainメソッドの戻り値条件を確認する。",
            steps: [
                step("このメソッド名はmainで、引数も `String[]` ですが、戻り値が `int` です。", [2], [variable("return type", "String", "int", "main")]),
                step("Javaランチャーが起動時に探すのは `public static void main(String[] args)` です。戻り値がvoidである必要があります。", [2], [variable("required return type", "String", "void", "launcher")]),
                step("したがって通常メソッドとしては存在しても、起動用mainとして認識されません。", [2], [variable("entrypoint", "boolean", "false", "launcher")]),
            ]
        ),
        q(
            "silver-balanced-int-division-001",
            category: "data-types",
            tags: ["int", "division", "operator"],
            code: """
public class Test {
    public static void main(String[] args) {
        int result = 5 / 2 * 2;
        System.out.println(result);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "4", correct: true, explanation: "`5 / 2` はint同士なので2になり、その後 `2 * 2` で4です。"),
                choice("b", "5", misconception: "小数計算してから丸めると誤解", explanation: "int除算はその時点で小数部分を切り捨てます。"),
                choice("c", "4.0", misconception: "結果がdoubleになると誤解", explanation: "すべてint演算なので結果もintです。"),
                choice("d", "コンパイルエラー", misconception: "割り切れないint除算が不可と誤解", explanation: "int除算は可能で、小数部が切り捨てられます。"),
            ],
            intent: "int除算の小数切り捨てと演算順を確認する。",
            steps: [
                step("`5 / 2` はint同士の除算なので、2.5ではなく2になります。", [3], [variable("5 / 2", "int", "2", "main")]),
                step("乗除算は左から評価されるため、次に `2 * 2` を計算します。", [3], [variable("result", "int", "4", "main")]),
                step("printlnで `4` が出力されます。", [4], [variable("output", "String", "4", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-compound-short-001",
            category: "data-types",
            tags: ["compound assignment", "short", "cast"],
            code: """
public class Test {
    public static void main(String[] args) {
        short s = 1;
        s += 2;
        System.out.println(s);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "3", correct: true, explanation: "`s += 2` は暗黙のキャストを含む複合代入なので、shortへ代入できます。"),
                choice("b", "2", misconception: "加算値だけが入ると誤解", explanation: "`+=` は現在値1に2を足します。"),
                choice("c", "コンパイルエラー", misconception: "`s = s + 2` と完全に同じだと誤解", explanation: "`s = s + 2` はint結果の代入でエラーですが、`s += 2` は暗黙キャストを含みます。"),
                choice("d", "ClassCastException", misconception: "プリミティブ変換を実行時キャストと混同", explanation: "これはプリミティブの代入変換であり、実行時のClassCastExceptionではありません。"),
            ],
            intent: "複合代入演算子が暗黙キャストを含むことを確認する。",
            steps: [
                step("`short s = 1;` でsは1です。", [3], [variable("s", "short", "1", "main")]),
                step("`s += 2` は `s = (short)(s + 2)` に近い扱いで、int計算結果をshortへ暗黙的に戻します。", [4], [variable("s", "short", "3", "main")]),
                step("そのためコンパイルでき、出力は `3` です。", [5], [variable("output", "String", "3", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-byte-overflow-001",
            category: "data-types",
            tags: ["byte", "overflow", "increment"],
            code: """
public class Test {
    public static void main(String[] args) {
        byte b = 127;
        b++;
        System.out.println(b);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "128", misconception: "byteの範囲を超えて保持できると誤解", explanation: "byteの範囲は -128 から 127 です。"),
                choice("b", "-128", correct: true, explanation: "byteの最大値127をインクリメントするとオーバーフローして -128 になります。"),
                choice("c", "コンパイルエラー", misconception: "byteの++が不可と誤解", explanation: "インクリメント演算子はbyteにも使え、結果はbyteへ戻されます。"),
                choice("d", "ArithmeticException", misconception: "整数オーバーフローで例外が出ると誤解", explanation: "Javaの整数オーバーフローは通常例外になりません。"),
            ],
            intent: "byteの範囲とインクリメント時のオーバーフローを確認する。",
            steps: [
                step("byteの最大値は127です。`b` は最大値で初期化されます。", [3], [variable("b", "byte", "127", "main")]),
                step("`b++` により1増やすと、byteの範囲を超えて循環し -128 になります。", [4], [variable("b", "byte", "-128", "main")]),
                step("整数オーバーフローは例外ではなく値の循環として現れるため、出力は `-128` です。", [5], [variable("output", "String", "-128", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-char-compound-001",
            category: "data-types",
            tags: ["char", "compound assignment", "unicode"],
            code: """
public class Test {
    public static void main(String[] args) {
        char c = 'A';
        c += 2;
        System.out.println(c);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A2", misconception: "文字列連結と誤解", explanation: "`c += 2` はcharの数値コードへの加算です。"),
                choice("b", "C", correct: true, explanation: "'A' の文字コードに2を足すと 'C' になります。"),
                choice("c", "67", misconception: "println(char)が数値を出すと誤解", explanation: "charをprintlnすると文字として表示されます。"),
                choice("d", "コンパイルエラー", misconception: "charへの複合代入が不可と誤解", explanation: "複合代入は暗黙キャストを含むためコンパイルできます。"),
            ],
            intent: "charの数値的性質と複合代入後の表示を確認する。",
            steps: [
                step("`char c = 'A';` でcは文字Aです。内部的には数値コードを持ちます。", [3], [variable("c", "char", "A", "main")]),
                step("`c += 2` によりAから2つ進んだ文字Cになります。", [4], [variable("c", "char", "C", "main")]),
                step("`println(char)` は数値ではなく文字として表示するため、出力は `C` です。", [5], [variable("output", "String", "C", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-boolean-precedence-001",
            category: "data-types",
            tags: ["boolean", "operator precedence", "&", "||"],
            code: """
public class Test {
    public static void main(String[] args) {
        boolean result = true & false || true;
        System.out.println(result);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", correct: true, explanation: "`&` が先に評価されてfalse、その後 `false || true` でtrueです。"),
                choice("b", "false", misconception: "||が先に評価されると誤解", explanation: "`&` は `||` より優先順位が高いです。"),
                choice("c", "コンパイルエラー", misconception: "booleanに&を使えないと誤解", explanation: "`&` はbooleanにも使えます。ただし短絡評価はしません。"),
                choice("d", "NullPointerException", misconception: "boolean演算を参照型処理と混同", explanation: "プリミティブbooleanの演算なのでnullは関係ありません。"),
            ],
            intent: "boolean演算における&と||の優先順位を確認する。",
            steps: [
                step("`&` はbooleanにも使え、`||` より優先順位が高いです。まず `true & false` が評価されます。", [3], [variable("true & false", "boolean", "false", "main")]),
                step("次に `false || true` を評価し、結果はtrueです。", [3], [variable("result", "boolean", "true", "main")]),
                step("printlnで `true` が出力されます。", [4], [variable("output", "String", "true", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-var-null-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "data-types",
            tags: ["var", "null", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        var value = null; // null alone gives no inferred type
        System.out.println(value);
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "nullと出力される", misconception: "varがObject型に推論されると誤解", explanation: "`null` だけでは具体的な型を推論できません。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "`var` の初期化式が `null` だけの場合、ローカル変数の型を決められないためコンパイルエラーです。"),
                choice("c", "Object型として扱われる", misconception: "nullリテラルの推論を広く取りすぎ", explanation: "Javaの `var` は `null` 単独からObjectを推論しません。"),
                choice("d", "実行時にNullPointerExceptionになる", misconception: "コンパイル時の型推論エラーを実行時問題と誤解", explanation: "実行前にコンパイルで拒否されます。"),
            ],
            intent: "varの型推論にnull単独の初期化式が使えないことを確認する。",
            steps: [
                step("`var` はローカル変数の型を初期化式から推論します。", [3], [variable("declaration", "var", "requires initializer type", "compiler")]),
                step("初期化式が `null` だけだと、StringなのかObjectなのか具体的な型が決まりません。", [3], [variable("initializer", "null literal", "no standalone type", "compiler")]),
                step("そのためコンパイルエラーです。`String value = null;` のような明示型なら別です。", [3], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-balanced-integer-cache-001",
            category: "data-types",
            tags: ["Integer", "==", "cache", "boxing"],
            code: """
public class Test {
    public static void main(String[] args) {
        Integer a = 127;
        Integer b = 127;
        Integer c = 128; // typical cache miss
        Integer d = 128;
        System.out.println((a == b) + ":" + (c == d));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true:true", misconception: "Integerの==が常に値比較だと誤解", explanation: "`==` は参照比較です。128は通常キャッシュ範囲外です。"),
                choice("b", "true:false", correct: true, explanation: "127はIntegerキャッシュの範囲内で同じ参照になり、128は通常別オブジェクトになります。"),
                choice("c", "false:false", misconception: "すべてnewされると誤解", explanation: "オートボクシングでは小さい整数値がキャッシュされます。"),
                choice("d", "false:true", misconception: "キャッシュ範囲を逆に理解", explanation: "標準的なキャッシュ範囲は少なくとも -128 から 127 です。"),
            ],
            intent: "Integerのオートボクシングと==による参照比較を確認する。",
            steps: [
                step("`Integer a = 127;` と `b = 127;` はキャッシュ範囲の値なので、同じIntegerインスタンスを参照します。", [3, 4], [variable("a == b", "boolean", "true", "main")]),
                step("`128` は通常キャッシュ範囲外なので、`c` と `d` は別インスタンスになります。", [5, 6], [variable("c == d", "boolean", "false", "main")]),
                step("`==` は値比較ではなく参照比較なので、出力は `true:false` です。", [7], [variable("output", "String", "true:false", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-double-nan-001",
            category: "data-types",
            tags: ["double", "NaN", "division"],
            code: """
public class Test {
    public static void main(String[] args) {
        double value = 0.0 / 0.0;
        System.out.println(value);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "NaN", correct: true, explanation: "浮動小数点の `0.0 / 0.0` は例外ではなくNaNになります。"),
                choice("b", "0.0", misconception: "0を0で割ると0になると誤解", explanation: "未定義の浮動小数点演算なのでNaNです。"),
                choice("c", "ArithmeticException", misconception: "intのゼロ除算と混同", explanation: "整数の0除算は例外ですが、doubleの演算はNaNやInfinityを返します。"),
                choice("d", "Infinity", misconception: "非ゼロを0.0で割る場合と混同", explanation: "`1.0 / 0.0` ならInfinityですが、`0.0 / 0.0` はNaNです。"),
            ],
            intent: "浮動小数点除算におけるNaNと整数除算例外の違いを確認する。",
            steps: [
                step("`0.0 / 0.0` はdouble同士の浮動小数点演算です。", [3], [variable("operation", "double division", "0.0 / 0.0", "main")]),
                step("浮動小数点ではこの演算は `NaN` になります。整数の0除算とは違い、ArithmeticExceptionではありません。", [3], [variable("value", "double", "NaN", "main")]),
                step("printlnで `NaN` が出力されます。", [4], [variable("output", "String", "NaN", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-string-substring-empty-001",
            category: "string",
            tags: ["String", "substring", "length"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = "abc";
        System.out.println(s.substring(1, 1).length());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", correct: true, explanation: "`substring(1, 1)` は開始と終了が同じなので空文字列になり、長さは0です。"),
                choice("b", "1", misconception: "終了位置を含むと誤解", explanation: "substringの第2引数は含まれません。開始と終了が同じなら空です。"),
                choice("c", "b", misconception: "lengthではなく文字そのものを出すと誤解", explanation: "出力しているのは `length()` の戻り値です。"),
                choice("d", "StringIndexOutOfBoundsException", misconception: "同じ開始・終了を不正と誤解", explanation: "開始と終了が同じ範囲は有効で、空文字列になります。"),
            ],
            intent: "substringの終了インデックスが排他的で、空範囲が有効なことを確認する。",
            steps: [
                step("`s` は `abc` です。インデックス1は文字bの位置です。", [3], [variable("s", "String", "abc", "main")]),
                step("`substring(1, 1)` は開始位置と終了位置が同じなので、取り出す文字はありません。結果は空文字列です。", [4], [variable("substring", "String", "\"\"", "main")]),
                step("空文字列の `length()` は0です。", [4], [variable("output", "int", "0", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-stringbuilder-chain-001",
            category: "string",
            tags: ["StringBuilder", "delete", "insert", "reverse"],
            code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("abcd");
        sb.delete(1, 3).insert(1, "X").reverse();
        System.out.println(sb);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "dXa", correct: true, explanation: "`delete(1,3)` でbcを削除してad、insertでaXd、reverseでdXaです。"),
                choice("b", "aXd", misconception: "reverseを見落とし", explanation: "最後に `reverse()` を呼んでいます。"),
                choice("c", "dXba", misconception: "deleteの終了位置を含むと誤解", explanation: "`delete(1,3)` はインデックス1と2を削除し、3は含みません。"),
                choice("d", "abcd", misconception: "StringBuilderが不変だと誤解", explanation: "StringBuilderは可変で、各メソッドは同じオブジェクトを変更します。"),
            ],
            intent: "StringBuilderの破壊的変更とメソッドチェーンの順序を確認する。",
            steps: [
                step("初期値は `abcd` です。`delete(1, 3)` はインデックス1以上3未満、つまりbとcを削除します。", [3, 4], [variable("after delete", "StringBuilder", "ad", "main")]),
                step("`insert(1, \"X\")` でaとdの間にXが入り、`aXd` になります。", [4], [variable("after insert", "StringBuilder", "aXd", "main")]),
                step("最後に `reverse()` で全体を反転し、出力は `dXa` です。", [4, 5], [variable("output", "String", "dXa", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-string-concat-immutable-001",
            category: "string",
            tags: ["String", "immutable", "concat"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = "A";
        s.concat("B");
        System.out.println(s);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", correct: true, explanation: "Stringは不変です。`concat` は新しいStringを返しますが、戻り値を代入していません。"),
                choice("b", "AB", misconception: "concatが元のStringを変更すると誤解", explanation: "Stringは変更されません。`s = s.concat(\"B\")` ならABです。"),
                choice("c", "B", misconception: "concatが置換だと誤解", explanation: "concatは連結した新しい文字列を返すメソッドです。"),
                choice("d", "コンパイルエラー", misconception: "戻り値を使わないメソッド呼び出しが不可と誤解", explanation: "戻り値を無視すること自体はコンパイル可能です。"),
            ],
            intent: "Stringの不変性と戻り値代入の必要性を確認する。",
            steps: [
                step("`s` は文字列 `A` を参照しています。", [3], [variable("s", "String", "A", "main")]),
                step("`s.concat(\"B\")` は `AB` という新しいStringを返しますが、その戻り値をどこにも代入していません。", [4], [variable("ignored result", "String", "AB", "main")]),
                step("変数 `s` は引き続き `A` を参照するため、出力は `A` です。", [5], [variable("output", "String", "A", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-string-equals-reference-001",
            category: "string",
            tags: ["String", "equals", "=="],
            code: """
public class Test {
    public static void main(String[] args) {
        String a = new String("x");
        String b = new String("x");
        System.out.println((a == b) + ":" + a.equals(b));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true:true", misconception: "==も内容比較だと誤解", explanation: "`new` で別オブジェクトを作っているため、参照は異なります。"),
                choice("b", "false:true", correct: true, explanation: "`==` は参照比較でfalse、`equals` はStringの内容比較でtrueです。"),
                choice("c", "true:false", misconception: "equalsが参照比較だと誤解", explanation: "Stringはequalsを内容比較としてオーバーライドしています。"),
                choice("d", "false:false", misconception: "内容も違うと誤解", explanation: "どちらも内容は `x` です。"),
            ],
            intent: "Stringでの参照比較と内容比較の違いを確認する。",
            steps: [
                step("`new String(\"x\")` を2回呼んでいるため、`a` と `b` は別々のStringオブジェクトです。", [3, 4], [variable("a == b", "boolean", "false", "main")]),
                step("一方、内容はいずれも `x` なので `a.equals(b)` はtrueです。", [5], [variable("a.equals(b)", "boolean", "true", "main")]),
                step("文字列連結により、出力は `false:true` です。", [5], [variable("output", "String", "false:true", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-string-trim-001",
            category: "string",
            tags: ["String", "trim", "length"],
            code: """
public class Test {
    public static void main(String[] args) {
        String s = " A ";
        System.out.println(s.trim().length() + ":" + s.length());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1:3", correct: true, explanation: "`trim()` の結果は `A` で長さ1。元の `s` は不変なので長さ3のままです。"),
                choice("b", "1:1", misconception: "trimが元のStringを書き換えると誤解", explanation: "Stringは不変で、trimは新しいStringを返します。"),
                choice("c", "3:3", misconception: "trimの効果を見落とし", explanation: "`trim()` は前後の空白を除いた文字列を返します。"),
                choice("d", "3:1", misconception: "出力順を逆に読んでいる", explanation: "先に `s.trim().length()`、次に `s.length()` を出力しています。"),
            ],
            intent: "trimの戻り値とString不変性を確認する。",
            steps: [
                step("`s` は前後に半角空白を持つ3文字の文字列です。", [3], [variable("s", "String", "\" A \"", "main")]),
                step("`s.trim()` は前後の空白を除いた新しい文字列 `A` を返します。その長さは1です。", [4], [variable("s.trim().length()", "int", "1", "main")]),
                step("元の `s` は変更されないため `s.length()` は3です。出力は `1:3` です。", [4], [variable("output", "String", "1:3", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-labelled-continue-001",
            difficulty: .tricky,
            category: "control-flow",
            tags: ["label", "continue", "loop"],
            code: """
public class Test {
    public static void main(String[] args) {
        outer:
        for (int i = 0; i < 2; i++) {
            for (int j = 0; j < 3; j++) {
                if (j == 1) continue outer;
                System.out.print(i + "" + j + " ");
            }
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "00 10 ", correct: true, explanation: "各iでj=0だけ出力し、j=1で外側ループの次回へcontinueします。"),
                choice("b", "00 02 10 12 ", misconception: "内側ループだけcontinueすると誤解", explanation: "`continue outer` は外側ループの次回反復へ進みます。"),
                choice("c", "00 01 02 10 11 12 ", misconception: "continueを無視している", explanation: "j=1でcontinueされるため、j=1以降の出力は行われません。"),
                choice("d", "コンパイルエラー", misconception: "ラベル付きcontinueが使えないと誤解", explanation: "ラベル付きcontinueはループラベルに対して使用できます。"),
            ],
            intent: "ラベル付きcontinueが指定した外側ループの次反復へ進むことを確認する。",
            steps: [
                step("i=0のとき、j=0では条件に当たらず `00 ` を出力します。", [4, 5, 6, 7], [variable("output so far", "String", "00 ", "stdout")]),
                step("j=1になると `continue outer;` により内側ループの続きではなく外側ループの次のiへ進みます。", [6], [variable("control", "String", "next outer iteration", "loop")]),
                step("i=1でも同じくj=0だけ `10 ` を出力し、j=1で終了方向へ進みます。最終出力は `00 10 ` です。", [4, 7], [variable("output", "String", "00 10 ", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-switch-fallthrough-002",
            category: "control-flow",
            tags: ["switch", "fall-through", "break"],
            code: """
public class Test {
    public static void main(String[] args) {
        int n = 1;
        switch (n) {
            case 1: System.out.print("A");
            case 2: System.out.print("B"); break;
            default: System.out.print("D");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", misconception: "case 1の後に自動で抜けると誤解", explanation: "breakがないためcase 2へフォールスルーします。"),
                choice("b", "AB", correct: true, explanation: "case 1から開始し、breakがないためcase 2も実行してからbreakで抜けます。"),
                choice("c", "ABD", misconception: "breakを見落とし", explanation: "case 2の後にbreakがあるためdefaultへは進みません。"),
                choice("d", "D", misconception: "defaultが常に実行されると誤解", explanation: "defaultは一致caseがない場合の開始位置です。今回はcase 1から始まります。"),
            ],
            intent: "switch文のフォールスルーとbreakの位置を確認する。",
            steps: [
                step("`n` は1なので、実行開始位置は `case 1` です。", [3, 5], [variable("n", "int", "1", "main")]),
                step("case 1ではAを出力しますが、breakがありません。そのためcase 2へ続き、Bも出力します。", [5, 6], [variable("output so far", "String", "AB", "stdout")]),
                step("case 2の末尾にbreakがあるのでswitchを抜け、defaultは実行されません。", [6, 7], [variable("output", "String", "AB", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-do-while-once-001",
            category: "control-flow",
            tags: ["do-while", "loop"],
            code: """
public class Test {
    public static void main(String[] args) {
        int n = 5;
        do {
            System.out.print(n);
            n++;
        } while (n < 5);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "何も出力されない", misconception: "whileと同じく先に条件判定すると誤解", explanation: "do-whileは本体を一度実行してから条件判定します。"),
                choice("b", "5", correct: true, explanation: "本体で5を出力してからnが6になり、条件 `n < 5` はfalseで終了します。"),
                choice("c", "56", misconception: "条件判定前に2回実行されると誤解", explanation: "条件判定は1回目の本体実行後に行われ、falseなので2回目はありません。"),
                choice("d", "無限ループ", misconception: "n++を見落とし", explanation: "nは6になり条件がfalseになります。"),
            ],
            intent: "do-whileが最低1回本体を実行することを確認する。",
            steps: [
                step("`n` は5で開始します。do-whileは条件を見る前に本体を実行します。", [3, 4], [variable("n", "int", "5", "main")]),
                step("本体で5を出力し、その後 `n++` によりnは6になります。", [5, 6], [variable("output so far", "String", "5", "stdout"), variable("n", "int", "6", "main")]),
                step("条件 `n < 5` はfalseなのでループを終了します。最終出力は `5` です。", [7], [variable("condition", "boolean", "false", "loop")]),
            ]
        ),
        q(
            "silver-balanced-enhanced-for-copy-001",
            category: "control-flow",
            tags: ["enhanced for", "array", "assignment"],
            code: """
public class Test {
    public static void main(String[] args) {
        int[] nums = {1, 2, 3};
        for (int n : nums) { // loop variable is just a copy
            n *= 2;
        }
        System.out.println(nums[0] + ":" + nums[1] + ":" + nums[2]);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1:2:3", correct: true, explanation: "拡張forの変数nは各要素値のコピーです。nを書き換えても配列要素は変わりません。"),
                choice("b", "2:4:6", misconception: "ループ変数代入が配列要素を変更すると誤解", explanation: "`n *= 2` はローカル変数nを変更するだけです。"),
                choice("c", "0:0:0", misconception: "nの値が配列へ戻ると誤解", explanation: "配列要素への代入は行っていません。"),
                choice("d", "コンパイルエラー", misconception: "拡張forの変数を変更できないと誤解", explanation: "ループ変数自体の再代入は可能です。ただし配列要素は変わりません。"),
            ],
            intent: "拡張forのループ変数代入が配列要素を変更しないことを確認する。",
            steps: [
                step("配列 `nums` は `[1, 2, 3]` で作成されます。", [3], [variable("nums", "int[]", "[1, 2, 3]", "main")]),
                step("拡張forの `n` は各要素値を受け取るローカル変数です。`n *= 2` はnだけを変更し、`nums` には代入していません。", [4, 5], [variable("n", "int", "temporary doubled value", "loop")]),
                step("配列は元のままなので、出力は `1:2:3` です。", [7], [variable("output", "String", "1:2:3", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-if-assignment-001",
            difficulty: .tricky,
            category: "control-flow",
            tags: ["if", "assignment", "boolean"],
            code: """
public class Test {
    public static void main(String[] args) {
        boolean flag = false;
        if (flag = true) { // assignment result becomes condition
            System.out.println("T");
        } else {
            System.out.println("F");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "T", correct: true, explanation: "`flag = true` は比較ではなく代入式です。代入後の値trueがif条件になります。"),
                choice("b", "F", misconception: "初期値falseのままと誤解", explanation: "if条件の中でflagへtrueを代入しています。"),
                choice("c", "コンパイルエラー", misconception: "if条件内の代入が常に禁止と誤解", explanation: "booleanへの代入式はboolean値を返すため、if条件として使えます。"),
                choice("d", "NullPointerException", misconception: "プリミティブbooleanを参照型と混同", explanation: "flagはプリミティブbooleanなのでnullは関係ありません。"),
            ],
            intent: "boolean代入式がif条件として成立することと、==との違いを確認する。",
            steps: [
                step("`flag` はfalseで初期化されます。", [3], [variable("flag", "boolean", "false", "main")]),
                step("`if (flag = true)` は比較ではなく代入です。flagへtrueを入れ、代入式全体の値もtrueになります。", [4], [variable("flag", "boolean", "true", "if condition")]),
                step("条件がtrueなのでthen側に入り、`T` を出力します。", [5], [variable("output", "String", "T", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-constructor-default-missing-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "classes",
            tags: ["constructor", "default constructor", "compile"],
            code: """
class Box {
    Box(int size) {}
}

public class Test {
    public static void main(String[] args) {
        new Box();
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "正常にコンパイルできる", misconception: "常にデフォルトコンストラクタがあると誤解", explanation: "コンストラクタを1つでも宣言すると、引数なしコンストラクタは自動生成されません。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "`Box(int)` だけが存在し、`new Box()` に対応する引数なしコンストラクタがありません。"),
                choice("c", "実行時にNullPointerExceptionになる", misconception: "コンストラクタ解決を実行時問題と誤解", explanation: "コンストラクタ呼び出しの不一致はコンパイル時に検出されます。"),
                choice("d", "sizeには0が自動で渡される", misconception: "引数のデフォルト値が渡ると誤解", explanation: "Javaはメソッドやコンストラクタ引数に自動デフォルト値を渡しません。"),
            ],
            intent: "明示コンストラクタがあるとデフォルトコンストラクタが生成されないことを確認する。",
            steps: [
                step("`Box` には `Box(int size)` というコンストラクタが明示されています。", [1, 2], [variable("constructors", "Box", "Box(int)", "class")]),
                step("コンストラクタを宣言した場合、コンパイラは引数なしコンストラクタを自動生成しません。", [2], [variable("default constructor", "boolean", "not generated", "compiler")]),
                step("`new Box()` に対応するコンストラクタがないため、コンパイルエラーです。", [7], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-balanced-init-order-simple-001",
            category: "classes",
            tags: ["initialization", "static", "constructor"],
            code: """
class A {
    static { System.out.print("S"); }
    { System.out.print("I"); }
    A() { System.out.print("C"); }
}

public class Test {
    public static void main(String[] args) {
        new A(); // triggers class init once
        new A();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "SICIC", correct: true, explanation: "static初期化は一度だけ。各newでインスタンス初期化I、コンストラクタCが実行されます。"),
                choice("b", "SICSIC", misconception: "static初期化がnewごとに実行されると誤解", explanation: "static初期化ブロックはクラス初期化時に一度だけです。"),
                choice("c", "ICIC", misconception: "static初期化を見落とし", explanation: "最初にAを使う前にstatic初期化Sが実行されます。"),
                choice("d", "SCIIC", misconception: "インスタンス初期化とコンストラクタの順を誤解", explanation: "インスタンス初期化ブロックはコンストラクタ本体より前です。"),
            ],
            intent: "static初期化、インスタンス初期化、コンストラクタの基本順序を確認する。",
            steps: [
                step("最初の `new A()` の前にクラスAのstatic初期化が一度だけ実行され、Sが出力されます。", [2, 9], [variable("output", "String", "S", "class init")]),
                step("1回目の生成ではインスタンス初期化I、コンストラクタCの順に出力します。", [3, 4, 9], [variable("first new", "String", "IC", "object init")]),
                step("2回目はstatic初期化なしで、再びIとCだけです。全体は `SICIC` です。", [10], [variable("output", "String", "SICIC", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-this-first-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "classes",
            tags: ["constructor", "this()", "compile"],
            code: """
class A {
    A() {
        System.out.println("A");
        this(10);
    }
    A(int n) {}
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "正常にコンパイルできる", misconception: "this()の位置制約を見落とし", explanation: "コンストラクタ内の `this(...)` 呼び出しは最初の文でなければなりません。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "`System.out.println` の後に `this(10)` を書いているため、コンストラクタ呼び出しの位置規則に違反します。"),
                choice("c", "Aと出力してからA(int)へ進む", misconception: "実行順だけで考えている", explanation: "このコードは実行前にコンパイルで拒否されます。"),
                choice("d", "再帰呼び出しでStackOverflowErrorになる", misconception: "this(10)の先を誤解", explanation: "`A(int)` は引数なしコンストラクタを呼んでいません。問題はthis呼び出しの位置です。"),
            ],
            intent: "コンストラクタ内のthis(...)呼び出しは先頭文でなければならないことを確認する。",
            steps: [
                step("引数なしコンストラクタ内で、まず `System.out.println(\"A\")` が書かれています。", [2, 3], [variable("first statement", "String", "println", "constructor")]),
                step("その後に `this(10)` がありますが、`this(...)` や `super(...)` はコンストラクタの最初の文でなければなりません。", [4], [variable("constructor invocation", "String", "this(10)", "constructor")]),
                step("位置規則に違反するため、コンパイルエラーです。", [3, 4], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-balanced-static-instance-field-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "classes",
            tags: ["static", "instance field", "compile"],
            code: """
class A {
    int value = 10;
    static void print() {
        System.out.println(value);
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "10と出力される", misconception: "staticメソッドが暗黙のthisを持つと誤解", explanation: "staticメソッドには特定インスタンスの `this` がありません。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "staticメソッドからインスタンスフィールド `value` をインスタンスなしで参照しているためエラーです。"),
                choice("c", "0と出力される", misconception: "インスタンスフィールドのデフォルト値が使われると誤解", explanation: "そもそもどのインスタンスのvalueか決められません。"),
                choice("d", "NullPointerExceptionになる", misconception: "暗黙のthisがnullだと誤解", explanation: "staticコンテキストには暗黙のthisが存在しません。"),
            ],
            intent: "staticメソッドからインスタンスメンバへ直接アクセスできないことを確認する。",
            steps: [
                step("`value` はインスタンスフィールドです。各Aオブジェクトごとに値を持ちます。", [2], [variable("value", "int", "instance field", "A")]),
                step("`print` はstaticメソッドなので、暗黙の `this` がありません。", [3], [variable("print", "method", "static", "A")]),
                step("インスタンスを指定せず `value` を参照しているため、コンパイルエラーです。", [4], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-balanced-final-local-reassign-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "classes",
            tags: ["final", "local variable", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        final int x = 1;
        x = 2; // final local cannot be reassigned
        System.out.println(x);
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "2と出力される", misconception: "finalを読み取り専用と理解していない", explanation: "finalローカル変数は一度代入したら再代入できません。"),
                choice("b", "1と出力される", misconception: "再代入が無視されると誤解", explanation: "再代入文は無視されるのではなく、コンパイルエラーになります。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "`final int x` に値1を代入済みなので、`x = 2` は許可されません。"),
                choice("d", "実行時にIllegalStateExceptionになる", misconception: "final違反を実行時検出と誤解", explanation: "final変数の再代入はコンパイル時に検出されます。"),
            ],
            intent: "finalローカル変数の再代入禁止を確認する。",
            steps: [
                step("`final int x = 1;` により、xは一度だけ代入できるローカル変数になります。", [3], [variable("x", "final int", "1", "main")]),
                step("次の `x = 2;` は同じfinal変数への再代入です。", [4], [variable("assignment", "String", "x = 2", "compiler")]),
                step("final変数は再代入できないため、コンパイルエラーです。", [4], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-balanced-access-private-field-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "classes",
            tags: ["private", "access modifier", "compile"],
            code: """
class A {
    private int value = 10;
}

public class Test {
    public static void main(String[] args) {
        A a = new A();
        System.out.println(a.value);
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "10と出力される", misconception: "同じファイルならprivateへアクセスできると誤解", explanation: "privateは同じトップレベルファイルではなく、宣言されたクラス内だけからアクセスできます。"),
                choice("b", "0と出力される", misconception: "アクセスできない場合にデフォルト値になると誤解", explanation: "アクセス制御違反はコンパイルエラーです。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "`value` はAのprivateフィールドなので、別クラスTestから `a.value` と参照できません。"),
                choice("d", "実行時にIllegalAccessErrorになる", misconception: "ソースコードのアクセス制御を実行時問題と誤解", explanation: "通常のJavaコンパイルではコンパイル時に拒否されます。"),
            ],
            intent: "privateメンバのアクセス可能範囲を確認する。",
            steps: [
                step("`value` はクラスAの `private` フィールドです。", [1, 2], [variable("value", "int", "private", "A")]),
                step("mainメソッドは別クラスTest内にあります。同じファイルに書かれていてもAのprivateメンバへ直接アクセスできません。", [5, 6, 8], [variable("access from", "Class", "Test", "source")]),
                step("`a.value` がアクセス制御違反となり、コンパイルエラーです。", [8], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-balanced-static-null-call-001",
            category: "classes",
            tags: ["static", "null", "method call"],
            code: """
class Tool {
    static void print() {
        System.out.println("static");
    }
}

public class Test {
    public static void main(String[] args) {
        Tool t = null;
        t.print();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "static", correct: true, explanation: "staticメソッド呼び出しはコンパイル時に型Toolへ解決され、インスタンス参照のnullを実体として使いません。"),
                choice("b", "NullPointerException", misconception: "staticメソッド呼び出しでも参照先オブジェクトが必要と誤解", explanation: "推奨は `Tool.print()` ですが、`t.print()` もstatic呼び出しとして解決されます。"),
                choice("c", "コンパイルエラー", misconception: "null参照からstaticメソッドを書けないと誤解", explanation: "警告対象になり得ますが、コンパイルはできます。"),
                choice("d", "何も出力されない", misconception: "nullなので呼び出しが無視されると誤解", explanation: "呼び出しはTool.printとして実行されます。"),
            ],
            intent: "null参照経由に見えるstaticメソッド呼び出しが型で解決されることを確認する。",
            steps: [
                step("変数 `t` の値はnullですが、宣言型は `Tool` です。", [9], [variable("t", "Tool", "null", "main")]),
                step("`print` はstaticメソッドです。`t.print()` と書いても、実際には型Toolのstaticメソッド呼び出しとして解決されます。", [2, 10], [variable("resolved call", "method", "Tool.print()", "compiler")]),
                step("オブジェクトの実体を参照しないためNullPointerExceptionにはならず、`static` が出力されます。", [3], [variable("output", "String", "static", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-instance-init-field-order-001",
            category: "classes",
            tags: ["field initializer", "instance initializer", "constructor"],
            code: """
class A {
    int x = 1;
    { x += 2; }
    A() { x += 3; }
}

public class Test {
    public static void main(String[] args) {
        System.out.println(new A().x);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1", misconception: "フィールド初期化だけを見る誤解", explanation: "その後にインスタンス初期化ブロックとコンストラクタが実行されます。"),
                choice("b", "3", misconception: "コンストラクタを見落とし", explanation: "1に2を足した後、さらにコンストラクタで3を足します。"),
                choice("c", "6", correct: true, explanation: "フィールド初期化で1、インスタンス初期化で3、コンストラクタで6になります。"),
                choice("d", "0", misconception: "明示初期化前のデフォルト値だけを見る誤解", explanation: "デフォルト値0の後、明示初期化と初期化処理が順に実行されます。"),
            ],
            intent: "フィールド初期化、インスタンス初期化ブロック、コンストラクタの順序を確認する。",
            steps: [
                step("Aオブジェクト生成時、まずintのデフォルト値0の後、フィールド初期化 `x = 1` が実行されます。", [2], [variable("x", "int", "1", "object init")]),
                step("次にインスタンス初期化ブロック `{ x += 2; }` が実行され、xは3になります。", [3], [variable("x", "int", "3", "object init")]),
                step("最後にコンストラクタ本体で3を足し、xは6です。`new A().x` は6を出力します。", [4, 9], [variable("output", "int", "6", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-override-access-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "inheritance",
            tags: ["override", "access modifier", "compile"],
            code: """
class Parent {
    protected void run() {}
}

class Child extends Parent {
    void run() {}
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "正常にコンパイルできる", misconception: "オーバーライドでアクセスを狭められると誤解", explanation: "オーバーライドではアクセス権を狭くできません。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "親の `protected` メソッドを、子でパッケージプライベートに狭めているためエラーです。"),
                choice("c", "実行時にIllegalAccessErrorになる", misconception: "アクセス制御を実行時問題と誤解", explanation: "ソース上のオーバーライド規則違反はコンパイル時に検出されます。"),
                choice("d", "privateにしなければ常に正しい", misconception: "protectedからデフォルトへの縮小を見落とし", explanation: "protectedよりパッケージプライベートは狭いアクセスです。"),
            ],
            intent: "オーバーライド時にアクセス修飾子を狭められないことを確認する。",
            steps: [
                step("親クラスの `run()` は `protected` です。", [1, 2], [variable("Parent.run", "method", "protected", "Parent")]),
                step("子クラスの `run()` は修飾子なし、つまりパッケージプライベートです。これはprotectedより狭いアクセスです。", [5, 6], [variable("Child.run", "method", "package-private", "Child")]),
                step("オーバーライドではアクセスを狭められないため、コンパイルエラーです。", [6], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-balanced-overload-not-override-001",
            category: "inheritance",
            tags: ["overload", "override", "polymorphism"],
            code: """
class Parent {
    void print(int n) {
        System.out.println("Parent");
    }
}
class Child extends Parent {
    void print(long n) {
        System.out.println("Child");
    }
}
public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        p.print(10);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "Parent", correct: true, explanation: "`Child.print(long)` はオーバーライドではなくオーバーロードです。参照型Parentから見える `print(int)` が呼ばれます。"),
                choice("b", "Child", misconception: "long版がint版をオーバーライドすると誤解", explanation: "引数型が違うためオーバーライドではありません。"),
                choice("c", "コンパイルエラー", misconception: "Child実体へParent参照を代入できないと誤解", explanation: "サブクラスインスタンスを親型参照へ代入できます。"),
                choice("d", "実行時にClassCastException", misconception: "ポリモーフィズムをキャストと混同", explanation: "キャストは行っていません。"),
            ],
            intent: "引数型が違うメソッドはオーバーライドではなくオーバーロードであることを確認する。",
            steps: [
                step("`Child` は `print(long)` を持ちますが、親の `print(int)` と引数型が違うためオーバーライドではありません。", [2, 7], [variable("Child.print(long)", "method", "overload", "Child")]),
                step("変数 `p` の宣言型はParentなので、コンパイル時に見える候補はParentの `print(int)` です。", [13, 14], [variable("selected method", "method", "Parent.print(int)", "compiler")]),
                step("`print(int)` はChildでオーバーライドされていないため、Parent版が実行され `Parent` と出力されます。", [3], [variable("output", "String", "Parent", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-covariant-return-001",
            category: "inheritance",
            tags: ["override", "covariant return"],
            code: """
class Parent {
    Number value() {
        return 1;
    }
}
class Child extends Parent {
    Integer value() {
        return 2;
    }
}
public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        System.out.println(p.value());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1", misconception: "戻り値型が違うのでオーバーライドされないと誤解", explanation: "IntegerはNumberのサブタイプなので共変戻り値としてオーバーライドできます。"),
                choice("b", "2", correct: true, explanation: "Childの `value()` がParentのメソッドを共変戻り値でオーバーライドしており、実行時型Childの実装が呼ばれます。"),
                choice("c", "コンパイルエラー", misconception: "戻り値型が完全一致でないと不可と誤解", explanation: "参照型の戻り値はサブタイプへ狭める共変戻り値が許可されます。"),
                choice("d", "ClassCastException", misconception: "IntegerをNumberとして返せないと誤解", explanation: "IntegerはNumberのサブクラスなので問題ありません。"),
            ],
            intent: "共変戻り値によるオーバーライドと動的ディスパッチを確認する。",
            steps: [
                step("Parentの `value()` はNumberを返します。Childの `value()` はIntegerを返します。IntegerはNumberのサブタイプです。", [2, 7], [variable("return type", "String", "Integer <: Number", "override")]),
                step("戻り値型をサブタイプへ狭める共変戻り値はオーバーライドとして有効です。", [7], [variable("override", "boolean", "true", "compiler")]),
                step("実体はChildなのでChild版が呼ばれ、2が出力されます。", [13, 14], [variable("output", "String", "2", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-field-hiding-002",
            category: "inheritance",
            tags: ["field hiding", "polymorphism"],
            code: """
class Parent {
    String name = "P";
}
class Child extends Parent {
    String name = "C";
}
public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        System.out.println(p.name); // field lookup uses reference type
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "P", correct: true, explanation: "フィールドアクセスは参照変数の宣言型Parentで決まり、Parentのnameが読まれます。"),
                choice("b", "C", misconception: "フィールドにもオーバーライドが働くと誤解", explanation: "フィールドは隠蔽されるだけで、インスタンスメソッドのような動的ディスパッチはありません。"),
                choice("c", "PC", misconception: "両方のフィールドが連結されると誤解", explanation: "参照しているフィールドは1つだけです。"),
                choice("d", "コンパイルエラー", misconception: "同名フィールドを宣言できないと誤解", explanation: "サブクラスで同名フィールドを宣言することは可能です。"),
            ],
            intent: "フィールドアクセスは参照型で静的に決まることを確認する。",
            steps: [
                step("ParentとChildの両方に `name` フィールドがあります。これはメソッドのオーバーライドではなくフィールドの隠蔽です。", [2, 5], [variable("fields", "String", "Parent.name / Child.name", "classes")]),
                step("変数 `p` の宣言型はParent、実体はChildです。フィールドアクセスは宣言型Parentで決まります。", [9, 10], [variable("p.name resolved to", "field", "Parent.name", "compiler")]),
                step("Parentのnameは `P` なので、出力は `P` です。", [2, 10], [variable("output", "String", "P", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-constructor-chain-002",
            category: "inheritance",
            tags: ["constructor", "super", "inheritance"],
            code: """
class Parent {
    Parent() {
        System.out.print("P");
    }
}
class Child extends Parent {
    Child() {
        System.out.print("C");
    }
}
public class Test {
    public static void main(String[] args) {
        new Child(); // implicit super() runs first
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "PC", correct: true, explanation: "Childコンストラクタの先頭で暗黙にsuper()が呼ばれ、ParentのPが先、その後ChildのCです。"),
                choice("b", "CP", misconception: "子コンストラクタ本体が先と誤解", explanation: "親クラスのコンストラクタ処理が先に完了します。"),
                choice("c", "C", misconception: "親コンストラクタ呼び出しを見落とし", explanation: "明示しなくても `super()` が暗黙に呼ばれます。"),
                choice("d", "コンパイルエラー", misconception: "super()を明示しないと不可と誤解", explanation: "親に引数なしコンストラクタがあるため、暗黙のsuper()でコンパイルできます。"),
            ],
            intent: "サブクラス生成時の暗黙super()とコンストラクタ実行順を確認する。",
            steps: [
                step("`new Child()` によりChildコンストラクタが呼ばれますが、その先頭では暗黙に `super()` が実行されます。", [7, 13], [variable("implicit call", "String", "super()", "Child constructor")]),
                step("Parentコンストラクタが先に実行され、`P` を出力します。", [2, 3], [variable("output so far", "String", "P", "stdout")]),
                step("その後Childコンストラクタ本体で `C` を出力します。全体は `PC` です。", [8], [variable("output", "String", "PC", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-overload-widening-boxing-001",
            category: "overload-resolution",
            tags: ["overload", "widening", "boxing"],
            code: """
public class Test {
    static void m(long x) {
        System.out.println("long");
    }
    static void m(Integer x) {
        System.out.println("Integer");
    }
    public static void main(String[] args) {
        m(10);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "long", correct: true, explanation: "int実引数に対して、ワイドニング変換longがボクシングIntegerより優先されます。"),
                choice("b", "Integer", misconception: "ボクシングがワイドニングより優先されると誤解", explanation: "オーバーロード解決では、基本的にワイドニングがボクシングより優先されます。"),
                choice("c", "コンパイルエラー", misconception: "候補が複数あると常に曖昧と誤解", explanation: "優先順位により `m(long)` が選ばれます。"),
                choice("d", "実行時にClassCastException", misconception: "オーバーロード解決を実行時処理と誤解", explanation: "オーバーロード解決はコンパイル時に行われます。"),
            ],
            intent: "オーバーロード解決でワイドニングがボクシングより優先されることを確認する。",
            steps: [
                step("実引数 `10` はintリテラルです。候補は `m(long)` と `m(Integer)` です。", [2, 5, 9], [variable("argument", "int", "10", "overload")]),
                step("intからlongへのワイドニングと、intからIntegerへのボクシングの両方が可能です。この場合ワイドニングが優先されます。", [2, 5], [variable("selected", "method", "m(long)", "compiler")]),
                step("選ばれた `m(long)` が実行され、`long` と出力されます。", [3], [variable("output", "String", "long", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-overload-boxing-varargs-001",
            category: "overload-resolution",
            tags: ["overload", "boxing", "varargs"],
            code: """
public class Test {
    static void m(Integer x) {
        System.out.println("Integer");
    }
    static void m(int... x) {
        System.out.println("varargs");
    }
    public static void main(String[] args) {
        m(10);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "Integer", correct: true, explanation: "固定長引数へのボクシングは、可変長引数より優先されます。"),
                choice("b", "varargs", misconception: "varargsが最優先だと誤解", explanation: "可変長引数は通常、固定長候補で決まらない場合の後段で検討されます。"),
                choice("c", "コンパイルエラー", misconception: "Integerとint...で曖昧になると誤解", explanation: "優先順位により `m(Integer)` が選ばれます。"),
                choice("d", "10", misconception: "引数値が自動出力されると誤解", explanation: "メソッド内で出力している文字列が表示されます。"),
            ],
            intent: "ボクシングと可変長引数のオーバーロード優先順位を確認する。",
            steps: [
                step("実引数10はintです。`m(Integer)` へはボクシング、`m(int...)` へは可変長引数として適合できます。", [2, 5, 9], [variable("argument", "int", "10", "overload")]),
                step("固定長引数のボクシング候補は、可変長引数候補より先に選ばれます。", [2, 5], [variable("selected", "method", "m(Integer)", "compiler")]),
                step("したがって `Integer` が出力されます。", [3], [variable("output", "String", "Integer", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-overload-null-specific-001",
            category: "overload-resolution",
            tags: ["overload", "null", "specific"],
            code: """
public class Test {
    static void m(Object o) {
        System.out.println("Object");
    }
    static void m(String s) {
        System.out.println("String");
    }
    public static void main(String[] args) {
        m(null);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "Object", misconception: "Objectが最も広いので選ばれると誤解", explanation: "オーバーロードでは適合する候補のうち、より具体的なStringが選ばれます。"),
                choice("b", "String", correct: true, explanation: "nullはObjectにもStringにも代入可能ですが、Stringの方がObjectより具体的です。"),
                choice("c", "コンパイルエラー", misconception: "null呼び出しが常に曖昧と誤解", explanation: "StringはObjectのサブクラスなので、より具体的な候補を決められます。"),
                choice("d", "NullPointerException", misconception: "nullを渡すと呼び出し前に例外になると誤解", explanation: "nullを引数として渡すこと自体は可能です。"),
            ],
            intent: "null実引数でより具体的な参照型オーバーロードが選ばれることを確認する。",
            steps: [
                step("`null` は参照型であるObjectにもStringにも代入可能です。両方のmが候補になります。", [2, 5, 9], [variable("argument", "null", "applicable to Object and String", "overload")]),
                step("候補のうちStringはObjectのサブタイプなので、String版がより具体的です。", [2, 5], [variable("selected", "method", "m(String)", "compiler")]),
                step("`m(String)` が実行され、`String` が出力されます。", [6], [variable("output", "String", "String", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-overload-char-widening-001",
            category: "overload-resolution",
            tags: ["overload", "char", "widening", "boxing"],
            code: """
public class Test {
    static void m(int x) {
        System.out.println("int");
    }
    static void m(Character x) {
        System.out.println("Character");
    }
    public static void main(String[] args) {
        char c = 'A';
        m(c);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "int", correct: true, explanation: "charからintへのワイドニングが、Characterへのボクシングより優先されます。"),
                choice("b", "Character", misconception: "charは必ずCharacterへボクシングされると誤解", explanation: "オーバーロード解決ではワイドニングが優先されます。"),
                choice("c", "A", misconception: "引数の文字がそのまま出力されると誤解", explanation: "メソッド内で出力しているのは文字列 `int` または `Character` です。"),
                choice("d", "コンパイルエラー", misconception: "charからintへ変換できないと誤解", explanation: "charはintへワイドニング変換できます。"),
            ],
            intent: "char実引数のオーバーロードでワイドニングがボクシングより優先されることを確認する。",
            steps: [
                step("`c` はchar型です。候補は `m(int)` と `m(Character)` です。", [8, 9, 2, 5], [variable("c", "char", "A", "main")]),
                step("charからintへはワイドニング可能で、charからCharacterへはボクシング可能です。優先されるのはワイドニングです。", [2, 5, 9], [variable("selected", "method", "m(int)", "compiler")]),
                step("`m(int)` が実行され、`int` が出力されます。", [3], [variable("output", "String", "int", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-try-catch-finally-order-001",
            category: "exception-handling",
            tags: ["try", "catch", "finally", "order"],
            code: """
public class Test {
    public static void main(String[] args) {
        try {
            System.out.print("A");
            int x = 1 / 0;
            System.out.print("B");
        } catch (ArithmeticException e) {
            System.out.print("C");
        } finally {
            System.out.print("D");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "ACD", correct: true, explanation: "Aを出力後、1/0で例外。Bは飛ばされ、catchでC、finallyでDです。"),
                choice("b", "ABCD", misconception: "例外後もtryの残りが実行されると誤解", explanation: "例外発生後、tryブロックの残りBには進みません。"),
                choice("c", "AD", misconception: "catchを見落とし", explanation: "ArithmeticExceptionをcatchしてCを出力します。"),
                choice("d", "A", misconception: "finallyを見落とし", explanation: "finallyは例外処理後にも実行されます。"),
            ],
            intent: "try内例外発生後のcatch/finally実行順を確認する。",
            steps: [
                step("tryブロックに入り、まず `A` を出力します。", [3, 4], [variable("output so far", "String", "A", "stdout")]),
                step("`1 / 0` で `ArithmeticException` が発生し、以降の `B` は実行されません。", [5, 6], [variable("exception", "ArithmeticException", "/ by zero", "try")]),
                step("catchで `C`、finallyで `D` を出力するため、全体は `ACD` です。", [7, 8, 9, 10], [variable("output", "String", "ACD", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-checked-exception-unhandled-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "exception-handling",
            tags: ["checked exception", "throws", "compile"],
            code: """
import java.io.*;

public class Test {
    static void read() throws IOException {
        throw new IOException();
    }
    public static void main(String[] args) {
        read();
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "正常にコンパイルできる", misconception: "IOExceptionを非検査例外と誤解", explanation: "IOExceptionは検査例外なので、処理または宣言が必要です。"),
                choice("b", "コンパイルエラーになる", correct: true, explanation: "`read()` はIOExceptionを投げる可能性があり、mainでcatchもthrows宣言もしていません。"),
                choice("c", "実行時にIOExceptionが自動的に無視される", misconception: "検査例外処理を実行時任せと誤解", explanation: "検査例外はコンパイル時に処理を要求されます。"),
                choice("d", "mainは例外宣言不要なので常に通る", misconception: "mainメソッドの例外規則を誤解", explanation: "mainでも検査例外を呼び出すならcatchするかthrows宣言が必要です。"),
            ],
            intent: "検査例外の呼び出し側処理またはthrows宣言の必要性を確認する。",
            steps: [
                step("`read()` は `throws IOException` と宣言され、検査例外を投げる可能性があります。", [4, 5], [variable("read throws", "checked exception", "IOException", "method")]),
                step("main内で `read()` を呼んでいますが、try-catchも `throws IOException` 宣言もありません。", [7, 8], [variable("handling", "String", "none", "main")]),
                step("検査例外が未処理なので、コンパイルエラーです。", [8], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-balanced-catch-order-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "exception-handling",
            tags: ["catch order", "Exception", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        try {
            throw new RuntimeException();
        } catch (Exception e) { // broader catch first makes next one unreachable
            System.out.println("E");
        } catch (RuntimeException e) {
            System.out.println("R");
        }
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "Eと出力される", misconception: "到達不能catchを見落とし", explanation: "RuntimeExceptionはExceptionのサブクラスなので、後続catchは到達不能です。"),
                choice("b", "Rと出力される", misconception: "より具体的なcatchが後でも選ばれると誤解", explanation: "catchは上から評価されるため、サブクラスを先に書く必要があります。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "`catch (Exception)` の後に `catch (RuntimeException)` を書くと、後者が到達不能になります。"),
                choice("d", "実行時にどちらかランダムに選ばれる", misconception: "catch選択を非決定的と誤解", explanation: "catchは上から順に、最初に適合したものが選ばれます。"),
            ],
            intent: "catchブロックはサブクラスから先に書く必要があることを確認する。",
            steps: [
                step("`RuntimeException` は `Exception` のサブクラスです。", [4, 5, 7], [variable("hierarchy", "Class", "RuntimeException extends Exception", "exception")]),
                step("先に `catch (Exception)` があるため、RuntimeExceptionもそこで捕捉されます。", [5], [variable("first catch", "Exception", "catches RuntimeException", "compiler")]),
                step("後続の `catch (RuntimeException)` には到達できないため、コンパイルエラーです。", [7], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-balanced-finally-return-local-001",
            difficulty: .tricky,
            category: "exception-handling",
            tags: ["finally", "return", "local variable"],
            code: """
public class Test {
    static int value() {
        int x = 1;
        try {
            return x;
        } finally {
            x = 2;
        }
    }
    public static void main(String[] args) {
        System.out.println(value());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1", correct: true, explanation: "`return x` の戻り値1が先に評価されます。finallyでxを2にしても戻り値は変わりません。"),
                choice("b", "2", misconception: "finallyでローカル変数を書き換えると戻り値も変わると誤解", explanation: "return式の値はfinally実行前に評価済みです。"),
                choice("c", "0", misconception: "intのデフォルト値に戻ると誤解", explanation: "xは明示的に1で初期化されています。"),
                choice("d", "コンパイルエラー", misconception: "finallyで代入できないと誤解", explanation: "finally内でローカル変数を変更すること自体は可能です。"),
            ],
            intent: "return式評価後にfinallyが実行されても、プリミティブ戻り値は変わらないことを確認する。",
            steps: [
                step("`x` は1で初期化されます。", [3], [variable("x", "int", "1", "value")]),
                step("try内の `return x;` で戻り値として1が評価されます。その後メソッドを抜ける前にfinallyへ進みます。", [4, 5], [variable("pending return", "int", "1", "value")]),
                step("finallyでxを2に変更しても、評価済みの戻り値1は変わりません。出力は `1` です。", [6, 7, 11], [variable("output", "int", "1", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-runtime-exception-catch-001",
            category: "exception-handling",
            tags: ["RuntimeException", "catch", "unchecked"],
            code: """
public class Test {
    public static void main(String[] args) {
        try {
            throw new RuntimeException("R");
        } catch (RuntimeException e) {
            System.out.println(e.getMessage());
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "R", correct: true, explanation: "RuntimeExceptionがcatchされ、メッセージ `R` が出力されます。"),
                choice("b", "RuntimeException", misconception: "クラス名が自動出力されると誤解", explanation: "出力しているのは `e.getMessage()` です。"),
                choice("c", "コンパイルエラー", misconception: "RuntimeExceptionも必ずthrows宣言が必要と誤解", explanation: "RuntimeExceptionは非検査例外で、throws宣言は必須ではありません。"),
                choice("d", "何も出力されない", misconception: "throw後にcatchされないと誤解", explanation: "対応するcatchブロックがあります。"),
            ],
            intent: "RuntimeExceptionは非検査例外だがcatch可能であることを確認する。",
            steps: [
                step("tryブロックでメッセージ `R` を持つRuntimeExceptionを投げます。", [3, 4], [variable("exception", "RuntimeException", "message=R", "try")]),
                step("直後の `catch (RuntimeException e)` がその例外を捕捉します。", [5], [variable("e", "RuntimeException", "message=R", "catch")]),
                step("`e.getMessage()` を出力するため、結果は `R` です。", [6], [variable("output", "String", "R", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-arraylist-remove-index-001",
            category: "collections",
            tags: ["ArrayList", "remove", "overload"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<Integer> list = new ArrayList<>(List.of(1, 2, 3));
        list.remove(1); // int argument chooses remove(index)
        System.out.println(list);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "[1, 3]", correct: true, explanation: "`remove(1)` はint引数なのでインデックス1の要素2を削除します。"),
                choice("b", "[2, 3]", misconception: "値1を削除すると誤解", explanation: "値としてのInteger 1を削除したい場合は `remove(Integer.valueOf(1))` です。"),
                choice("c", "[1, 2]", misconception: "最後の要素が削除されると誤解", explanation: "インデックス1、つまり2番目の要素が削除されます。"),
                choice("d", "IndexOutOfBoundsException", misconception: "インデックス1が範囲外と誤解", explanation: "サイズ3のリストでインデックス1は有効です。"),
            ],
            intent: "List<Integer>でremove(int index)とremove(Object)の違いを確認する。",
            steps: [
                step("初期リストは `[1, 2, 3]` です。", [5], [variable("list", "List<Integer>", "[1, 2, 3]", "main")]),
                step("`list.remove(1)` の引数1はintとして扱われ、値1ではなくインデックス1を指定します。", [6], [variable("removed element", "Integer", "2", "list")]),
                step("残る要素は1と3なので、出力は `[1, 3]` です。", [7], [variable("output", "String", "[1, 3]", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-arrays-aslist-fixed-001",
            category: "collections",
            tags: ["Arrays.asList", "fixed size", "set"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> list = Arrays.asList("A", "B");
        list.set(0, "X");
        try {
            list.add("C");
        } catch (UnsupportedOperationException e) {
            System.out.println(list);
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "[X, B]", correct: true, explanation: "`Arrays.asList` のリストは固定サイズです。setは可能ですが、addはUnsupportedOperationExceptionです。"),
                choice("b", "[A, B, C]", misconception: "addも可能と誤解", explanation: "固定サイズなので要素数を変えるaddはできません。"),
                choice("c", "[A, B]", misconception: "setも失敗すると誤解", explanation: "要素の置き換えsetは可能です。"),
                choice("d", "NullPointerException", misconception: "例外型を取り違え", explanation: "発生するのは固定サイズリストへのaddによるUnsupportedOperationExceptionです。"),
            ],
            intent: "Arrays.asListが固定サイズリストを返し、setは可能だがadd/removeは不可であることを確認する。",
            steps: [
                step("`Arrays.asList(\"A\", \"B\")` は固定サイズのListを返します。", [5], [variable("list", "List<String>", "[A, B]", "main")]),
                step("`set(0, \"X\")` は要素数を変えない置換なので成功し、リストは `[X, B]` になります。", [6], [variable("list", "List<String>", "[X, B]", "main")]),
                step("`add(\"C\")` はサイズ変更なので `UnsupportedOperationException`。catchで現在のlistを出力します。", [8, 9, 10], [variable("output", "String", "[X, B]", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-hashset-duplicate-001",
            category: "collections",
            tags: ["HashSet", "duplicate", "size"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Set<String> set = new HashSet<>();
        System.out.print(set.add("A"));
        System.out.print(":" + set.add("A"));
        System.out.println(":" + set.size());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true:false:1", correct: true, explanation: "1回目のA追加は成功、2回目は重複でfalse。要素数は1です。"),
                choice("b", "true:true:2", misconception: "Setが重複を許すと誤解", explanation: "Setは重複要素を保持しません。"),
                choice("c", "false:true:1", misconception: "addの戻り値を逆に理解", explanation: "新しく追加できたときtrue、既にあるため変更なしならfalseです。"),
                choice("d", "A:A:1", misconception: "addの戻り値を要素そのものと誤解", explanation: "`Set.add` の戻り値はbooleanです。"),
            ],
            intent: "Set.addの戻り値と重複要素の扱いを確認する。",
            steps: [
                step("空のHashSetへ最初に `A` を追加すると、セットが変更されるため `add` はtrueを返します。", [5, 6], [variable("first add", "boolean", "true", "set")]),
                step("2回目の `A` は重複なので追加されず、`add` はfalseを返します。", [7], [variable("second add", "boolean", "false", "set")]),
                step("保持している要素はAの1つだけなので、sizeは1です。出力は `true:false:1` です。", [8], [variable("output", "String", "true:false:1", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-collections-sort-strings-001",
            category: "collections",
            tags: ["Collections.sort", "String", "natural order"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>(List.of("b", "aa", "a"));
        Collections.sort(list);
        System.out.println(list);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "[a, aa, b]", correct: true, explanation: "Stringの自然順は辞書順です。長さ順ではなく、a, aa, bの順になります。"),
                choice("b", "[a, b, aa]", misconception: "長さ順で並ぶと誤解", explanation: "Comparatorを指定していないためStringの自然順で並びます。"),
                choice("c", "[b, aa, a]", misconception: "sortが元の順序を保つと誤解", explanation: "`Collections.sort` はリストを並べ替えます。"),
                choice("d", "コンパイルエラー", misconception: "Stringをsortできないと誤解", explanation: "StringはComparableを実装しており自然順でソートできます。"),
            ],
            intent: "Collections.sortによるString自然順ソートを確認する。",
            steps: [
                step("初期リストは `[b, aa, a]` です。", [5], [variable("list", "List<String>", "[b, aa, a]", "main")]),
                step("`Collections.sort(list)` はStringの自然順、つまり辞書順で並べ替えます。", [6], [variable("list", "List<String>", "[a, aa, b]", "main")]),
                step("並べ替え後のリストを出力するため、結果は `[a, aa, b]` です。", [7], [variable("output", "String", "[a, aa, b]", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-predicate-test-001",
            category: "lambda-streams",
            tags: ["Predicate", "lambda", "test"],
            code: """
import java.util.function.*;

public class Test {
    public static void main(String[] args) {
        Predicate<String> p = s -> s.length() > 1;
        System.out.println(p.test("A") + ":" + p.test("AB"));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "false:true", correct: true, explanation: "Aの長さは1なのでfalse、ABの長さは2なのでtrueです。"),
                choice("b", "true:true", misconception: "1文字も条件を満たすと誤解", explanation: "条件は `> 1` なので長さ1はfalseです。"),
                choice("c", "false:false", misconception: "ラムダが一度しか実行されないと誤解", explanation: "`test` を呼ぶたびにラムダが評価されます。"),
                choice("d", "コンパイルエラー", misconception: "Predicateの抽象メソッド名を誤解", explanation: "Predicateは `test` メソッドでbooleanを返します。"),
            ],
            intent: "Predicateラムダとtestメソッドの基本を確認する。",
            steps: [
                step("`Predicate<String>` はStringを受け取りbooleanを返す関数型インターフェースです。", [5], [variable("p", "Predicate<String>", "s.length() > 1", "main")]),
                step("`p.test(\"A\")` は長さ1なのでfalse、`p.test(\"AB\")` は長さ2なのでtrueです。", [6], [variable("first", "boolean", "false", "main"), variable("second", "boolean", "true", "main")]),
                step("文字列連結により、出力は `false:true` です。", [6], [variable("output", "String", "false:true", "stdout")]),
            ]
        ),
        q(
            "silver-balanced-lambda-effectively-final-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "lambda-streams",
            tags: ["lambda", "effectively final", "compile"],
            code: """
public class Test {
    public static void main(String[] args) {
        int count = 0;
        Runnable r = () -> System.out.println(count);
        count++; // reassignment breaks effectively final
        r.run();
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "0と出力される", misconception: "ラムダが値をコピーするので後の変更は関係ないと誤解", explanation: "ラムダから参照するローカル変数はfinalまたは実質的finalである必要があります。"),
                choice("b", "1と出力される", misconception: "変更後の値をラムダが読めると誤解", explanation: "countが後で変更されるため、ラムダから参照できません。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "`count` はラムダ内で参照された後に `count++` されており、実質的finalではありません。"),
                choice("d", "実行時にIllegalStateExceptionになる", misconception: "実質的final制約を実行時検査と誤解", explanation: "この制約はコンパイル時に検査されます。"),
            ],
            intent: "ラムダがキャプチャするローカル変数はfinalまたは実質的finalである必要があることを確認する。",
            steps: [
                step("ラムダ `() -> System.out.println(count)` はローカル変数 `count` を参照しています。", [3, 4], [variable("captured variable", "int", "count", "lambda")]),
                step("その後 `count++` でcountを変更しています。これによりcountは実質的finalではありません。", [5], [variable("effectively final", "boolean", "false", "compiler")]),
                step("ラムダから参照されるローカル変数の条件を満たさないため、コンパイルエラーです。", [4, 5], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "silver-balanced-runnable-lambda-001",
            category: "lambda-streams",
            tags: ["Runnable", "lambda", "run"],
            code: """
public class Test {
    public static void main(String[] args) {
        Runnable r = () -> System.out.print("A");
        System.out.print("B");
        r.run();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", misconception: "ラムダ作成時に実行されると誤解", explanation: "ラムダ式はRunnableオブジェクトを作るだけで、作成時には本体を実行しません。"),
                choice("b", "BA", correct: true, explanation: "先にBを出力し、その後 `r.run()` でラムダ本体が実行されAを出力します。"),
                choice("c", "AB", misconception: "ラムダ本体が代入時に実行されると誤解", explanation: "代入時には実行されず、`run()` 呼び出し時に実行されます。"),
                choice("d", "コンパイルエラー", misconception: "Runnableをラムダで書けないと誤解", explanation: "Runnableは抽象メソッド `run()` を1つ持つ関数型インターフェースです。"),
            ],
            intent: "ラムダ式は関数型インターフェースの実装を作り、呼び出し時に本体が実行されることを確認する。",
            steps: [
                step("`Runnable r = () -> System.out.print(\"A\");` はRunnableの実装を作るだけで、この時点ではAを出力しません。", [3], [variable("r", "Runnable", "prints A when run", "main")]),
                step("次に `System.out.print(\"B\")` が実行され、まずBが出力されます。", [4], [variable("output so far", "String", "B", "stdout")]),
                step("最後に `r.run()` でラムダ本体が実行されAが続きます。全体は `BA` です。", [5], [variable("output", "String", "BA", "stdout")]),
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

extension SilverBalancedQuestionData.Spec {
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
    static let silverBalancedExpansion: [Quiz] = SilverBalancedQuestionData.specs.map(\.quiz)
}
