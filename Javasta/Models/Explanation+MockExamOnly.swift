import Foundation

extension Explanation {
    static let mockExamOnlyAuthoredSamples: [String: Explanation] = [
        silverMockOverloadNull001Explanation.id: silverMockOverloadNull001Explanation,
        silverMockInitOrder001Explanation.id: silverMockInitOrder001Explanation,
        silverMockArrayStore001Explanation.id: silverMockArrayStore001Explanation,
        silverMockFinallyReturn001Explanation.id: silverMockFinallyReturn001Explanation,
        silverMockSwitchFallthrough001Explanation.id: silverMockSwitchFallthrough001Explanation,
        silverMockStringBuilder001Explanation.id: silverMockStringBuilder001Explanation,
        silverMockPrimitiveCast001Explanation.id: silverMockPrimitiveCast001Explanation,
        silverMockStaticNull001Explanation.id: silverMockStaticNull001Explanation,
        silverMockOverloadVarargs001Explanation.id: silverMockOverloadVarargs001Explanation,
        silverMockDoWhile001Explanation.id: silverMockDoWhile001Explanation,
        goldMockCollectorsToMap001Explanation.id: goldMockCollectorsToMap001Explanation,
        goldMockOptionalOr001Explanation.id: goldMockOptionalOr001Explanation,
        goldMockInvokeAny001Explanation.id: goldMockInvokeAny001Explanation,
        goldMockSuppressedOrder001Explanation.id: goldMockSuppressedOrder001Explanation,
        goldMockRecordArray001Explanation.id: goldMockRecordArray001Explanation,
        goldMockSealedPermits001Explanation.id: goldMockSealedPermits001Explanation,
        goldMockRawHeapPollution001Explanation.id: goldMockRawHeapPollution001Explanation,
        goldMockDateTimePeriodDuration001Explanation.id: goldMockDateTimePeriodDuration001Explanation,
        goldMockPathNormalize001Explanation.id: goldMockPathNormalize001Explanation,
        goldMockAnnotationRetention001Explanation.id: goldMockAnnotationRetention001Explanation,
    ]

    private static func mockExamStep(
        _ index: Int,
        _ narration: String,
        _ highlightLines: [Int],
        variables: [Variable] = [],
        predict: PredictPrompt? = nil
    ) -> Step {
        Step(
            index: index,
            narration: narration,
            highlightLines: highlightLines,
            variables: variables,
            callStack: [],
            heap: [],
            predict: predict
        )
    }

    private static func mockExamPrompt(
        _ question: String,
        _ choices: [String],
        _ answerIndex: Int,
        _ hint: String,
        _ afterExplanation: String
    ) -> PredictPrompt {
        PredictPrompt(
            question: question,
            choices: choices,
            answerIndex: answerIndex,
            hint: hint,
            afterExplanation: afterExplanation
        )
    }

    static let silverMockOverloadNull001Explanation = Explanation(
        id: "explain-silver-mock-overload-null-001",
        initialCode: """
public class Test {
    static void print(String s) {
        System.out.println("String");
    }
    static void print(StringBuilder s) {
        System.out.println("StringBuilder");
    }
    public static void main(String[] args) {
        print(null);
    }
}
""",
        steps: [
            mockExamStep(0, "`print(null)` の実引数 `null` は、参照型である `String` にも `StringBuilder` にも代入可能です。ここまではどちらのオーバーロードも候補に残ります。", [2, 5, 9], variables: [Variable(name: "argument", type: "null literal", value: "String / StringBuilder both applicable", scope: "overload")]),
            mockExamStep(1, "次に、コンパイラは候補のうち『より具体的』なメソッドを選ぼうとします。しかし `String` と `StringBuilder` は互いに継承関係がありません。", [2, 5], predict: mockExamPrompt("StringとStringBuilderのどちらがより具体的？", ["String", "StringBuilder", "決められない"], 2, "どちらもfinalな別クラスです。", "正解です。上下関係がないため優先順位を決められません。")),
            mockExamStep(2, "より具体的な候補を1つに絞れないため、この呼び出しは曖昧です。実行時例外ではなく、コンパイル時点でエラーになります。", [9], variables: [Variable(name: "result", type: "compile-time decision", value: "ambiguous method call", scope: "compiler")]),
        ]
    )

    static let silverMockInitOrder001Explanation = Explanation(
        id: "explain-silver-mock-init-order-001",
        initialCode: """
class Parent {
    static { System.out.print("A"); }
    { System.out.print("B"); }
    Parent() { System.out.print("C"); }
}

class Child extends Parent {
    static { System.out.print("D"); }
    { System.out.print("E"); }
    Child() { System.out.print("F"); }
}

public class Test {
    public static void main(String[] args) {
        new Child();
        new Child();
    }
}
""",
        steps: [
            mockExamStep(0, "最初に `new Child()` を実行する直前、クラス初期化が必要です。親クラス `Parent` のstatic初期化 `A` が先、次に `Child` のstatic初期化 `D` が一度だけ実行されます。", [2, 8, 15], variables: [Variable(name: "class init", type: "order", value: "A -> D", scope: "first new")]),
            mockExamStep(1, "1回目のインスタンス生成では、親側のインスタンス初期化 `B`、親コンストラクタ `C`、子側のインスタンス初期化 `E`、子コンストラクタ `F` の順に進みます。", [3, 4, 9, 10, 15], variables: [Variable(name: "first object", type: "constructor chain", value: "B -> C -> E -> F", scope: "first new")], predict: mockExamPrompt("子コンストラクタFより前に実行されるものは？", ["Parent側の初期化とコンストラクタ", "Childのstaticだけ"], 0, "super()が暗黙に先頭で呼ばれます。", "正解です。親側を完了してから子側へ戻ります。")),
            mockExamStep(2, "2回目の `new Child()` ではstatic初期化は再実行されません。インスタンス生成部分の `BCEF` だけがもう一度続くため、全体は `ADBCEFBCEF` です。", [16], variables: [Variable(name: "output", type: "String", value: "ADBCEFBCEF", scope: "main")]),
        ]
    )

    static let silverMockArrayStore001Explanation = Explanation(
        id: "explain-silver-mock-array-store-001",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        Object[] values = new String[1];
        try {
            values[0] = 10;
            System.out.println("OK");
        } catch (ArrayStoreException e) {
            System.out.println("ASE");
        }
    }
}
""",
        steps: [
            mockExamStep(0, "`String[]` は配列の共変性により `Object[]` 参照へ代入できます。ただし、参照型が `Object[]` でも、実体の配列型は `String[]` のままです。", [3], variables: [Variable(name: "values", type: "Object[] reference", value: "runtime type = String[]", scope: "main")]),
            mockExamStep(1, "`values[0] = 10` では `10` が `Integer` にボクシングされ、実体が `String[]` の配列へ格納されようとします。配列は格納時に実行時型を検査します。", [5], predict: mockExamPrompt("String[]の実体へIntegerを格納できる？", ["できる", "できない"], 1, "配列は実行時にも要素型を知っています。", "正解です。格納時にArrayStoreExceptionになります。")),
            mockExamStep(2, "型検査に失敗して `ArrayStoreException` が発生し、catchブロックで `ASE` が出力されます。`OK` には到達しません。", [6, 7, 8], variables: [Variable(name: "output", type: "String", value: "ASE", scope: "catch")]),
        ]
    )

    static let silverMockFinallyReturn001Explanation = Explanation(
        id: "explain-silver-mock-finally-return-001",
        initialCode: """
public class Test {
    static int value() {
        try {
            return 1;
        } finally {
            return 3;
        }
    }
    public static void main(String[] args) {
        System.out.println(value());
    }
}
""",
        steps: [
            mockExamStep(0, "`value()` が呼ばれると、まずtryブロックで `return 1` を実行しようとします。ただし、returnでメソッドを抜ける直前にもfinallyは必ず実行されます。", [3, 4, 10], variables: [Variable(name: "pending return", type: "int", value: "1", scope: "value")]),
            mockExamStep(1, "finallyブロックにも `return 3` があります。finally側のreturnは、try側で準備されていた戻り値を上書きします。", [5, 6], predict: mockExamPrompt("最終的に返る値は？", ["1", "3"], 1, "finally内にもreturnがあります。", "正解です。finallyのreturnが最終結果になります。")),
            mockExamStep(2, "そのため `value()` の戻り値は3です。`System.out.println(value())` は `3` を出力します。実務ではfinallyのreturnは例外も握りつぶすため避けるべき書き方です。", [10], variables: [Variable(name: "output", type: "int", value: "3", scope: "main")]),
        ]
    )

    static let silverMockSwitchFallthrough001Explanation = Explanation(
        id: "explain-silver-mock-switch-fallthrough-001",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        int n = 2;
        switch (n) {
            case 1: System.out.print("A");
            case 2: System.out.print("B");
            default: System.out.print("D");
            case 3: System.out.print("C");
        }
    }
}
""",
        steps: [
            mockExamStep(0, "`n` は2なので、switchの実行開始位置は `case 2` のラベルです。`case 1` の文は実行されません。", [3, 4, 5, 6], variables: [Variable(name: "n", type: "int", value: "2", scope: "main")]),
            mockExamStep(1, "`case 2` で `B` を出力しますが、`break` がありません。Javaのswitch文はbreakがなければ次のラベルへそのまま進みます。", [6, 7], predict: mockExamPrompt("case 2の後、defaultへ進む？", ["進む", "止まる"], 0, "breakがあるかを見ます。", "正解です。defaultもラベルなので通過します。")),
            mockExamStep(2, "続いて `default` で `D`、さらに `case 3` で `C` を出力します。したがって出力は `BDC` です。", [7, 8], variables: [Variable(name: "output", type: "String", value: "BDC", scope: "main")]),
        ]
    )

    static let silverMockStringBuilder001Explanation = Explanation(
        id: "explain-silver-mock-string-builder-001",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("abcdef");
        sb.delete(1, 4).insert(1, "XY").reverse();
        System.out.println(sb);
    }
}
""",
        steps: [
            mockExamStep(0, "初期値は `abcdef` です。`delete(1, 4)` は開始index 1を含み、終了index 4を含まないため、`bcd` を削除して `aef` になります。", [3, 4], variables: [Variable(name: "sb", type: "StringBuilder", value: "aef", scope: "after delete")]),
            mockExamStep(1, "同じStringBuilderに対して `insert(1, \"XY\")` を続けます。index 1、つまり `a` の直後に挿入され、`aXYef` になります。", [4], variables: [Variable(name: "sb", type: "StringBuilder", value: "aXYef", scope: "after insert")]),
            mockExamStep(2, "最後の `reverse()` は全体を反転します。`aXYef` を反転すると `feYXa` です。StringBuilderの操作は破壊的に同じオブジェクトを更新します。", [4, 5], variables: [Variable(name: "output", type: "String", value: "feYXa", scope: "main")], predict: mockExamPrompt("XYは反転後もXYのまま？", ["そのまま", "YXになる"], 1, "全体をreverseします。", "正解です。文字列全体が反転するのでYXになります。")),
        ]
    )

    static let silverMockPrimitiveCast001Explanation = Explanation(
        id: "explain-silver-mock-primitive-cast-001",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        byte b = (byte) 130;
        System.out.println(b);
    }
}
""",
        steps: [
            mockExamStep(0, "`byte` の範囲は -128 から 127 です。リテラル130は範囲外ですが、明示キャスト `(byte)` があるためコンパイルは可能です。", [3], variables: [Variable(name: "literal", type: "int", value: "130", scope: "main")]),
            mockExamStep(1, "intからbyteへの縮小変換では下位8ビットだけが残ります。130は8ビットでは `10000010` で、byteとして解釈すると -126 です。", [3], predict: mockExamPrompt("範囲外の明示キャストは例外になる？", ["なる", "ならない"], 1, "整数のキャストはビットを切り詰めます。", "正解です。ArithmeticExceptionではありません。")),
            mockExamStep(2, "`b` の値は -126 になり、そのまま `System.out.println(b)` で `-126` が出力されます。", [4], variables: [Variable(name: "b", type: "byte", value: "-126", scope: "main")]),
        ]
    )

    static let silverMockStaticNull001Explanation = Explanation(
        id: "explain-silver-mock-static-null-001",
        initialCode: """
public class Test {
    static void print() {
        System.out.println("OK");
    }
    public static void main(String[] args) {
        Test t = null;
        t.print();
    }
}
""",
        steps: [
            mockExamStep(0, "`print` は `static` メソッドです。推奨される書き方は `Test.print()` ですが、Javaでは参照変数 `t` 経由でもstaticメソッド呼び出しを書けます。", [2, 6, 7], variables: [Variable(name: "t", type: "Test", value: "null", scope: "main")]),
            mockExamStep(1, "staticメソッド呼び出しはコンパイル時にクラスへ束縛されます。`t.print()` は実質的に `Test.print()` として解決され、`t` が指すオブジェクトの実体を取りに行きません。", [7], predict: mockExamPrompt("null参照式なのでNPEになる？", ["なる", "ならない"], 1, "呼んでいるメンバがstaticです。", "正解です。インスタンスメソッド呼び出しとは扱いが違います。")),
            mockExamStep(2, "したがって `NullPointerException` は発生せず、`print()` の本体が実行されて `OK` が出力されます。", [3], variables: [Variable(name: "output", type: "String", value: "OK", scope: "print")]),
        ]
    )

    static let silverMockOverloadVarargs001Explanation = Explanation(
        id: "explain-silver-mock-overload-varargs-001",
        initialCode: """
public class Test {
    static void call(int... values) {
        System.out.println("varargs");
    }
    static void call(Integer value) {
        System.out.println("boxing");
    }
    public static void main(String[] args) {
        call(1);
    }
}
""",
        steps: [
            mockExamStep(0, "`call(1)` の実引数はintです。候補には `int...` と `Integer` の2つがあります。`int...` は可変長引数、`Integer` はボクシングで適用可能な固定引数です。", [2, 5, 9], variables: [Variable(name: "argument", type: "int", value: "1", scope: "overload")]),
            mockExamStep(1, "オーバーロード解決は、厳密な一致、ボクシング、可変長引数の順に広げて候補を探します。固定引数の `call(Integer)` がボクシングで見つかるため、varargsの段階へ行く必要がありません。", [2, 5], predict: mockExamPrompt("boxingとvarargsではどちらが優先？", ["boxing", "varargs"], 0, "varargsは最後の手段です。", "正解です。固定引数で適用できるメソッドが優先されます。")),
            mockExamStep(2, "選ばれるのは `call(Integer value)` なので、出力は `boxing` です。曖昧でも実行時選択でもありません。", [6, 9], variables: [Variable(name: "selected method", type: "overload", value: "call(Integer)", scope: "compiler")]),
        ]
    )

    static let silverMockDoWhile001Explanation = Explanation(
        id: "explain-silver-mock-do-while-001",
        initialCode: """
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
        steps: [
            mockExamStep(0, "`do-while` は条件判定より前に本体を必ず1回実行します。開始時の `i` は0です。", [3, 4], variables: [Variable(name: "i", type: "int", value: "0", scope: "main")]),
            mockExamStep(1, "`System.out.print(i++)` は後置インクリメントなので、まず現在値0を出力し、その後 `i` を1にします。", [5], variables: [Variable(name: "i", type: "int", value: "1", scope: "after print")], predict: mockExamPrompt("i++で出力される値は？", ["0", "1"], 0, "後置インクリメントです。", "正解です。使ってから増やします。")),
            mockExamStep(2, "条件 `i < 0` は `1 < 0` なのでfalseです。ループを抜けて `\":\" + i` を出力するため、全体は `0:1` になります。", [6, 7], variables: [Variable(name: "output", type: "String", value: "0:1", scope: "main")]),
        ]
    )

    static let goldMockCollectorsToMap001Explanation = Explanation(
        id: "explain-gold-mock-collectors-to-map-001",
        initialCode: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        Map<Integer, String> map = Stream.of("aa", "b", "cc")
            .collect(Collectors.toMap(
                String::length,
                s -> s,
                (left, right) -> left + right,
                TreeMap::new
            ));
        System.out.println(map);
    }
}
""",
        steps: [
            mockExamStep(0, "`toMap` のキーは `String::length` です。`aa` は2、`b` は1、`cc` は2になり、キー2が重複します。", [6, 7, 8], variables: [Variable(name: "keys", type: "Map key", value: "aa->2, b->1, cc->2", scope: "collector")]),
            mockExamStep(1, "重複キーが出たときは、3番目の引数 `(left, right) -> left + right` が使われます。キー2の値は遭遇順に `aa` と `cc` が結合され、`aacc` になります。", [9, 10], predict: mockExamPrompt("重複キー2は例外になる？", ["なる", "ならない"], 1, "マージ関数が指定されています。", "正解です。指定した関数で値をまとめます。")),
            mockExamStep(2, "4番目の引数が `TreeMap::new` なので、結果Mapはキーの自然順序で表示されます。キー1の `b`、キー2の `aacc` の順で `{1=b, 2=aacc}` です。", [11, 13], variables: [Variable(name: "map", type: "TreeMap<Integer,String>", value: "{1=b, 2=aacc}", scope: "main")]),
        ]
    )

    static let goldMockOptionalOr001Explanation = Explanation(
        id: "explain-gold-mock-optional-or-001",
        initialCode: """
import java.util.*;

public class Test {
    static Optional<String> fallback() {
        System.out.print("F");
        return Optional.of("java");
    }
    public static void main(String[] args) {
        String result = Optional.<String>empty()
            .or(() -> fallback())
            .map(String::toUpperCase)
            .orElseGet(() -> "NONE");
        System.out.println(result);
    }
}
""",
        steps: [
            mockExamStep(0, "開始時のOptionalは空です。`or(() -> fallback())` は、元のOptionalが空のときだけSupplierを実行して代替Optionalを返します。", [9, 10], variables: [Variable(name: "source", type: "Optional<String>", value: "empty", scope: "main")]),
            mockExamStep(1, "`fallback()` が実行されるため、まず `F` が `print` されます。そして `Optional.of(\"java\")` が返ります。", [4, 5, 6, 10], variables: [Variable(name: "after or", type: "Optional<String>", value: "Optional[java]", scope: "pipeline")], predict: mockExamPrompt("orのSupplierは実行される？", ["実行される", "実行されない"], 0, "元のOptionalはemptyです。", "正解です。空なので代替Optionalを作ります。")),
            mockExamStep(2, "`map(String::toUpperCase)` により値は `JAVA` になります。値があるので `orElseGet` の `NONE` は使われず、既に出ている `F` に続いて `JAVA` が出力されます。", [11, 12, 13], variables: [Variable(name: "output", type: "String", value: "FJAVA", scope: "main")]),
        ]
    )

    static let goldMockInvokeAny001Explanation = Explanation(
        id: "explain-gold-mock-invoke-any-001",
        initialCode: """
import java.util.*;
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) throws Exception {
        ExecutorService service = Executors.newFixedThreadPool(2);
        try {
            String result = service.invokeAny(List.of(
                () -> { Thread.sleep(200); return "A"; },
                () -> "B"
            ));
            System.out.println(result);
        } finally {
            service.shutdown();
        }
    }
}
""",
        steps: [
            mockExamStep(0, "`invokeAny` には2つのCallableが渡されています。1つ目は200ms待って `A`、2つ目は待たずに `B` を返します。", [8, 9, 10], variables: [Variable(name: "tasks", type: "Callable<String>", value: "slow A / fast B", scope: "executor")]),
            mockExamStep(1, "`invokeAny` は全結果を集めるAPIではなく、正常完了したいずれか1つの結果を返します。入力順の先頭を必ず返すわけでもありません。", [8], predict: mockExamPrompt("invokeAnyの戻り値は全タスク分？", ["1つ", "List全部"], 0, "名前のAnyに注目します。", "正解です。成功した1件の結果です。")),
            mockExamStep(2, "このコードでは通常、待機のない2番目のCallableが先に成功するため `B` が返ります。finallyでExecutorServiceをshutdownしてから終了します。", [10, 12, 14], variables: [Variable(name: "result", type: "String", value: "B", scope: "main")]),
        ]
    )

    static let goldMockSuppressedOrder001Explanation = Explanation(
        id: "explain-gold-mock-suppressed-order-001",
        initialCode: """
class R implements AutoCloseable {
    private final String name;
    R(String name) { this.name = name; }
    public void close() throws Exception {
        throw new Exception(name);
    }
}

public class Test {
    public static void main(String[] args) {
        try (R a = new R("A"); R b = new R("B")) {
            throw new Exception("body");
        } catch (Exception e) {
            System.out.println(e.getMessage()
                + ":" + e.getSuppressed()[0].getMessage()
                + e.getSuppressed()[1].getMessage());
        }
    }
}
""",
        steps: [
            mockExamStep(0, "tryブロック本体で `new Exception(\"body\")` が投げられます。この時点の主例外は `body` です。", [11, 12], variables: [Variable(name: "primary", type: "Exception", value: "body", scope: "try")]),
            mockExamStep(1, "try-with-resourcesのリソースは宣言と逆順にcloseされます。先に `b` が閉じられて `B`、次に `a` が閉じられて `A` の例外が発生します。", [4, 5, 11], variables: [Variable(name: "close order", type: "AutoCloseable", value: "b -> a", scope: "finally-equivalent")], predict: mockExamPrompt("close順は？", ["A then B", "B then A"], 1, "スタックのように後から宣言したものが先です。", "正解です。逆順に閉じます。")),
            mockExamStep(2, "本体で既に主例外があるため、close時の例外はsuppressedとして追加されます。順序は `B`、`A` なので、出力は `body:BA` です。", [13, 14, 15, 16], variables: [Variable(name: "suppressed", type: "[Throwable]", value: "[B, A]", scope: "catch")]),
        ]
    )

    static let goldMockRecordArray001Explanation = Explanation(
        id: "explain-gold-mock-record-array-001",
        initialCode: """
import java.util.*;

record Box(int[] values) {}

public class Test {
    public static void main(String[] args) {
        Box a = new Box(new int[] {1});
        Box b = new Box(new int[] {1});
        System.out.println(a.equals(b) + ":" + Arrays.equals(a.values(), b.values()));
    }
}
""",
        steps: [
            mockExamStep(0, "`a` と `b` はどちらも中身が `{1}` の配列を持っています。ただし `new int[] {1}` を2回実行しているので、配列オブジェクトは別々です。", [7, 8], variables: [Variable(name: "a.values", type: "int[]", value: "array object #1", scope: "main"), Variable(name: "b.values", type: "int[]", value: "array object #2", scope: "main")]),
            mockExamStep(1, "recordの自動 `equals` はコンポーネントを比較しますが、配列コンポーネントを特別に内容比較へ変えるわけではありません。配列の `equals` は参照比較なので `a.equals(b)` はfalseです。", [3, 9], predict: mockExamPrompt("recordのequalsは配列内容を深く比較する？", ["する", "しない"], 1, "配列型のequalsの挙動がそのまま効きます。", "正解です。recordでも配列は落とし穴になります。")),
            mockExamStep(2, "一方 `Arrays.equals(a.values(), b.values())` はint配列の要素内容を比較するためtrueです。連結した出力は `false:true` になります。", [9], variables: [Variable(name: "output", type: "String", value: "false:true", scope: "main")]),
        ]
    )

    static let goldMockSealedPermits001Explanation = Explanation(
        id: "explain-gold-mock-sealed-permits-001",
        initialCode: """
sealed interface Shape permits Circle {}

final class Circle implements Shape {}

final class Square implements Shape {}
""",
        steps: [
            mockExamStep(0, "`Shape` はsealed interfaceで、直接の実装クラスを `permits Circle` に制限しています。つまり、直接 `Shape` を実装できるのはここでは `Circle` だけです。", [1], variables: [Variable(name: "permitted subtype", type: "sealed", value: "Circle", scope: "Shape")]),
            mockExamStep(1, "`Circle` はpermitsに含まれており、さらに `final` を付けています。sealed型の直接サブタイプは `final`、`sealed`、`non-sealed` のいずれかを明示する必要があるので、Circle側は正しいです。", [3], predict: mockExamPrompt("Circleのfinalはエラー？", ["エラー", "正しい"], 1, "sealedの直接サブタイプに必要な修飾子です。", "正解です。finalは許可されます。")),
            mockExamStep(2, "`Square` は `Shape` を直接実装していますが、permitsリストに含まれていません。そのため `final class Square implements Shape` の行でコンパイルエラーになります。", [5], variables: [Variable(name: "compile error", type: "sealed restriction", value: "Square is not permitted", scope: "compiler")]),
        ]
    )

    static let goldMockRawHeapPollution001Explanation = Explanation(
        id: "explain-gold-mock-raw-heap-pollution-001",
        initialCode: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<Integer> nums = new ArrayList<>();
        List raw = nums;
        raw.add("x");
        try {
            Integer n = nums.get(0);
            System.out.println(n);
        } catch (ClassCastException e) {
            System.out.println("CCE");
        }
    }
}
""",
        steps: [
            mockExamStep(0, "`nums` は `List<Integer>` として宣言されていますが、同じ実体をraw型の `List raw` に代入しています。raw型ではジェネリクスの型検査が弱まり、警告は出ますが通常コンパイルは通ります。", [5, 6], variables: [Variable(name: "raw", type: "List", value: "same object as nums", scope: "main")]),
            mockExamStep(1, "`raw.add(\"x\")` により、`List<Integer>` として扱っている実体にStringが入り、ヒープ汚染が起きます。この時点では配列のような実行時要素型検査はありません。", [7], variables: [Variable(name: "list content", type: "ArrayList", value: "[\"x\"]", scope: "heap")]),
            mockExamStep(2, "`Integer n = nums.get(0)` では、コンパイラがIntegerとして取り出すためのキャストを挿入します。実体はStringなので `ClassCastException` が発生し、`CCE` が出力されます。", [8, 9, 11, 12], variables: [Variable(name: "output", type: "String", value: "CCE", scope: "catch")], predict: mockExamPrompt("例外が起きる場所は？", ["add時", "getしてIntegerへ代入する時"], 1, "ジェネリクスは実行時に消去されます。", "正解です。取得時のキャストで失敗します。")),
        ]
    )

    static let goldMockDateTimePeriodDuration001Explanation = Explanation(
        id: "explain-gold-mock-date-time-period-duration-001",
        initialCode: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        LocalDateTime t = LocalDateTime.of(2024, 2, 28, 23, 0);
        t = t.plus(Period.ofDays(1));
        t = t.plus(Duration.ofHours(2));
        System.out.println(t);
    }
}
""",
        steps: [
            mockExamStep(0, "開始値は `2024-02-28T23:00` です。2024年はうるう年なので、2月28日の翌日は2月29日です。", [5], variables: [Variable(name: "t", type: "LocalDateTime", value: "2024-02-28T23:00", scope: "main")]),
            mockExamStep(1, "`Period.ofDays(1)` は日付ベースの1日加算です。`t` に戻り値を再代入しているため、値は `2024-02-29T23:00` になります。", [6], variables: [Variable(name: "t", type: "LocalDateTime", value: "2024-02-29T23:00", scope: "after Period")], predict: mockExamPrompt("2024-02-28に1日足すと？", ["2024-02-29", "2024-03-01"], 0, "2024年はうるう年です。", "正解です。2月29日が存在します。")),
            mockExamStep(2, "次に `Duration.ofHours(2)` を足すと、23:00から2時間進んで翌日の01:00です。最終出力は `2024-03-01T01:00` です。", [7, 8], variables: [Variable(name: "output", type: "LocalDateTime", value: "2024-03-01T01:00", scope: "main")]),
        ]
    )

    static let goldMockPathNormalize001Explanation = Explanation(
        id: "explain-gold-mock-path-normalize-001",
        initialCode: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path base = Path.of("/a/b");
        Path target = Path.of("/a/b/c/../d");
        Path relative = base.relativize(target).normalize();
        System.out.println(relative);
    }
}
""",
        steps: [
            mockExamStep(0, "`base` は `/a/b`、`target` は `/a/b/c/../d` です。`relativize` は、baseからtargetへ向かう相対パスを作ります。", [5, 6, 7], variables: [Variable(name: "base", type: "Path", value: "/a/b", scope: "main"), Variable(name: "target", type: "Path", value: "/a/b/c/../d", scope: "main")]),
            mockExamStep(1, "baseから見ると、いったん `c` に入り、`..` で戻ってから `d` に行く形なので、relativize直後は概念的に `c/../d` です。", [7], predict: mockExamPrompt("relativizeの戻り値は絶対パス？", ["絶対パス", "相対パス"], 1, "baseからtargetまでの道筋です。", "正解です。相対パスになります。")),
            mockExamStep(2, "その後 `normalize()` が `c/..` を整理します。残るのは `d` だけなので、出力は `d` です。", [7, 8], variables: [Variable(name: "relative", type: "Path", value: "d", scope: "main")]),
        ]
    )

    static let goldMockAnnotationRetention001Explanation = Explanation(
        id: "explain-gold-mock-annotation-retention-001",
        initialCode: """
import java.lang.annotation.*;

@Retention(RetentionPolicy.CLASS)
@interface Mark {}

@Mark
public class Test {
    public static void main(String[] args) {
        System.out.println(Test.class.isAnnotationPresent(Mark.class));
    }
}
""",
        steps: [
            mockExamStep(0, "`Mark` には `@Retention(RetentionPolicy.CLASS)` が付いています。これはclassファイルには情報を残しますが、実行時リフレクションで読めることを意味しません。", [3, 4], variables: [Variable(name: "retention", type: "RetentionPolicy", value: "CLASS", scope: "Mark")]),
            mockExamStep(1, "`Test` には `@Mark` が付いています。ただし `isAnnotationPresent` は実行時にリフレクションでアノテーションを確認するAPIです。", [6, 7, 9], predict: mockExamPrompt("CLASS保持はリフレクションで見える？", ["見える", "見えない"], 1, "実行時に見せるにはRUNTIMEが必要です。", "正解です。CLASSは実行時可視ではありません。")),
            mockExamStep(2, "実行時に取得できないため、`Test.class.isAnnotationPresent(Mark.class)` はfalseです。出力は `false` になります。", [9], variables: [Variable(name: "output", type: "boolean", value: "false", scope: "main")]),
        ]
    )
}
