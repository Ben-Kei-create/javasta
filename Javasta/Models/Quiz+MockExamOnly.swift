import Foundation

extension QuizExpansion {
    static let mockExamOnlyExpansion: [Quiz] = [
        silverMockOverloadNull001,
        silverMockInitOrder001,
        silverMockArrayStore001,
        silverMockFinallyReturn001,
        silverMockSwitchFallthrough001,
        silverMockStringBuilder001,
        silverMockPrimitiveCast001,
        silverMockStaticNull001,
        silverMockOverloadVarargs001,
        silverMockDoWhile001,
        goldMockCollectorsToMap001,
        goldMockOptionalOr001,
        goldMockInvokeAny001,
        goldMockSuppressedOrder001,
        goldMockRecordArray001,
        goldMockSealedPermits001,
        goldMockRawHeapPollution001,
        goldMockDateTimePeriodDuration001,
        goldMockPathNormalize001,
        goldMockAnnotationRetention001,
    ] + silverMockFurtherExpansion
        + silverCapstoneMockExpansion
        + silverSprintMockExpansion
        + silverFinalPushMockExpansion
        + goldMockAdditionalExpansion

    static let silverMockOverloadNull001 = Quiz(
        id: "silver-mock-overload-null-001",
        level: .silver,
        difficulty: .tricky,
        validatedByJavac: false,
        isMockExamOnly: true,
        category: "overload-resolution",
        tags: ["模試専用", "overload", "null", "ambiguous"],
        code: """
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
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "String と出力される", correct: false, misconception: "StringがStringBuilderより優先されると誤解", explanation: "StringとStringBuilderは継承関係にないため、どちらがより具体的か決められません。"),
            Choice(id: "b", text: "StringBuilder と出力される", correct: false, misconception: "後に定義されたオーバーロードが選ばれると誤解", explanation: "宣言順でオーバーロード解決は決まりません。"),
            Choice(id: "c", text: "コンパイルエラー", correct: true, misconception: nil, explanation: "nullはどちらの参照型にも適合しますが、StringとStringBuilderの間に上下関係がないため呼び出しが曖昧です。"),
            Choice(id: "d", text: "NullPointerException", correct: false, misconception: "実行時まで進むと誤解", explanation: "オーバーロード解決に失敗するため、実行前にコンパイルエラーです。"),
        ],
        explanationRef: "explain-silver-mock-overload-null-001",
        designIntent: "null実引数で参照型オーバーロードが曖昧になるケースを確認する。"
    )

    static let silverMockInitOrder001 = Quiz(
        id: "silver-mock-init-order-001",
        level: .silver,
        difficulty: .tricky,
        isMockExamOnly: true,
        category: "classes",
        tags: ["模試専用", "初期化順", "継承", "static"],
        code: """
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "ADBCEFBCEF", correct: true, misconception: nil, explanation: "static初期化はParent, Childの順に一度だけ。各newではParentのインスタンス初期化B、ParentコンストラクタC、Child初期化E、ChildコンストラクタFの順です。"),
            Choice(id: "b", text: "ABCDEFBCF", correct: false, misconception: "Childのstatic初期化位置を誤解", explanation: "Childのstatic初期化Dは、最初のChild生成前にParentのstatic初期化Aの後で実行されます。"),
            Choice(id: "c", text: "ADBCEFADBCEF", correct: false, misconception: "static初期化がnewごとに実行されると誤解", explanation: "static初期化ブロックはクラス初期化時に一度だけ実行されます。"),
            Choice(id: "d", text: "DBEFACDBEFAC", correct: false, misconception: "サブクラス側から初期化されると誤解", explanation: "クラス初期化もコンストラクタ連鎖も、親クラス側が先です。"),
        ],
        explanationRef: "explain-silver-mock-init-order-001",
        designIntent: "継承時のstatic初期化、インスタンス初期化、コンストラクタ実行順を確認する。"
    )

    static let silverMockArrayStore001 = Quiz(
        id: "silver-mock-array-store-001",
        level: .silver,
        difficulty: .tricky,
        isMockExamOnly: true,
        category: "data-types",
        tags: ["模試専用", "array", "covariance", "ArrayStoreException"],
        code: """
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "ASE", correct: true, misconception: nil, explanation: "配列は共変なのでObject[]参照へ代入できますが、実体はString[]です。Integerを格納しようとしてArrayStoreExceptionになります。"),
            Choice(id: "b", text: "OK", correct: false, misconception: "参照型Object[]なら任意のObjectを格納できると誤解", explanation: "実行時の配列型はString[]なので、格納時に型検査されます。"),
            Choice(id: "c", text: "ClassCastException", correct: false, misconception: "キャスト失敗と混同", explanation: "配列への格納時に発生するのはArrayStoreExceptionです。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "配列共変性を認めないと誤解", explanation: "String[]はObject[]へ代入できます。問題は実行時の格納です。"),
        ],
        explanationRef: "explain-silver-mock-array-store-001",
        designIntent: "配列共変性と実行時の要素型検査を確認する。"
    )

    static let silverMockFinallyReturn001 = Quiz(
        id: "silver-mock-finally-return-001",
        level: .silver,
        difficulty: .tricky,
        isMockExamOnly: true,
        category: "exception-handling",
        tags: ["模試専用", "finally", "return"],
        code: """
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1", correct: false, misconception: "tryのreturnがそのまま確定すると誤解", explanation: "return直前にもfinallyは必ず実行されます。finally側のreturnが最終結果を上書きします。"),
            Choice(id: "b", text: "3", correct: true, misconception: nil, explanation: "tryで1を返そうとしますが、finallyでreturn 3が実行されるため、最終的な戻り値は3です。"),
            Choice(id: "c", text: "4", correct: false, misconception: "戻り値が加算されると誤解", explanation: "finallyのreturnはtryのreturn値を加算するのではなく上書きします。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "finallyでreturnできないと誤解", explanation: "finally内のreturnはコンパイル可能です。ただし可読性と保守性の観点で避けるべきです。"),
        ],
        explanationRef: "explain-silver-mock-finally-return-001",
        designIntent: "finally内returnがtryのreturnを上書きする挙動を確認する。"
    )

    static let silverMockSwitchFallthrough001 = Quiz(
        id: "silver-mock-switch-fallthrough-001",
        level: .silver,
        difficulty: .tricky,
        isMockExamOnly: true,
        category: "control-flow",
        tags: ["模試専用", "switch", "fall-through", "default"],
        code: """
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "B", correct: false, misconception: "case一致後に自動で抜けると誤解", explanation: "breakがないため後続ラベルへフォールスルーします。"),
            Choice(id: "b", text: "BDC", correct: true, misconception: nil, explanation: "case 2から開始し、breakがないためdefault、case 3へ順に落ちます。defaultの位置は途中でも有効です。"),
            Choice(id: "c", text: "BD", correct: false, misconception: "defaultでswitchが終了すると誤解", explanation: "defaultもラベルの一種です。breakがないためcase 3へ続きます。"),
            Choice(id: "d", text: "ABDC", correct: false, misconception: "case 1から常に評価されると誤解", explanation: "実行開始位置は一致したcase 2です。case 1の文は実行されません。"),
        ],
        explanationRef: "explain-silver-mock-switch-fallthrough-001",
        designIntent: "switch文の開始位置、defaultの位置、breakなしフォールスルーを確認する。"
    )

    static let silverMockStringBuilder001 = Quiz(
        id: "silver-mock-string-builder-001",
        level: .silver,
        difficulty: .tricky,
        isMockExamOnly: true,
        category: "string",
        tags: ["模試専用", "StringBuilder", "delete", "insert", "reverse"],
        code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("abcdef");
        sb.delete(1, 4).insert(1, "XY").reverse();
        System.out.println(sb);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "feYXa", correct: true, misconception: nil, explanation: "delete(1,4)でbcdを削除してaef。insert(1,\"XY\")でaXYef。reverseでfeYXaです。"),
            Choice(id: "b", text: "fedcba", correct: false, misconception: "deleteとinsertの変更を見落とし", explanation: "reverse前の文字列はabcdefではなくaXYefです。"),
            Choice(id: "c", text: "feXYa", correct: false, misconception: "reverse時にXYの順序が変わらないと誤解", explanation: "reverseは全体を反転するためXYもYXになります。"),
            Choice(id: "d", text: "aXYef", correct: false, misconception: "reverseを見落とし", explanation: "最後にreverse()を呼んでいます。"),
        ],
        explanationRef: "explain-silver-mock-string-builder-001",
        designIntent: "StringBuilderの破壊的変更とメソッドチェーンの順序を確認する。"
    )

    static let silverMockPrimitiveCast001 = Quiz(
        id: "silver-mock-primitive-cast-001",
        level: .silver,
        difficulty: .tricky,
        isMockExamOnly: true,
        category: "data-types",
        tags: ["模試専用", "byte", "cast", "overflow"],
        code: """
public class Test {
    public static void main(String[] args) {
        byte b = (byte) 130;
        System.out.println(b);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "130", correct: false, misconception: "byteが130を保持できると誤解", explanation: "byteの範囲は-128から127です。130は範囲外です。"),
            Choice(id: "b", text: "-126", correct: true, misconception: nil, explanation: "intの130をbyteへ明示キャストすると下位8ビットだけが残ります。130はbyte表現では-126になります。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "明示キャストしても範囲外リテラルを代入できないと誤解", explanation: "明示キャストがあるためコンパイルできます。"),
            Choice(id: "d", text: "ArithmeticException", correct: false, misconception: "整数オーバーフローが例外になると誤解", explanation: "このキャストでは例外は発生せず、ビットが切り詰められます。"),
        ],
        explanationRef: "explain-silver-mock-primitive-cast-001",
        designIntent: "整数の明示キャストとbyte範囲外値の回り込みを確認する。"
    )

    static let silverMockStaticNull001 = Quiz(
        id: "silver-mock-static-null-001",
        level: .silver,
        difficulty: .tricky,
        isMockExamOnly: true,
        category: "classes",
        tags: ["模試専用", "static", "null reference"],
        code: """
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "OK", correct: true, misconception: nil, explanation: "staticメソッド呼び出しはコンパイル時にクラスへ束縛されます。null参照式を通して書いても、実体参照の dereference は起きません。"),
            Choice(id: "b", text: "NullPointerException", correct: false, misconception: "static呼び出しでも参照先オブジェクトが必要と誤解", explanation: "インスタンスメソッドならNPEですが、printはstaticです。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "staticメソッドを参照変数経由で呼べないと誤解", explanation: "推奨はされませんが、参照変数経由のstatic呼び出しはコンパイル可能です。"),
            Choice(id: "d", text: "何も出力されない", correct: false, misconception: "nullなら呼び出しが無視されると誤解", explanation: "呼び出しはTest.print()として解決され、OKが出力されます。"),
        ],
        explanationRef: "explain-silver-mock-static-null-001",
        designIntent: "null参照式を通したstaticメンバ呼び出しの扱いを確認する。"
    )

    static let silverMockOverloadVarargs001 = Quiz(
        id: "silver-mock-overload-varargs-001",
        level: .silver,
        difficulty: .tricky,
        isMockExamOnly: true,
        category: "overload-resolution",
        tags: ["模試専用", "overload", "boxing", "varargs"],
        code: """
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "boxing", correct: true, misconception: nil, explanation: "オーバーロード解決では、可変長引数よりもボクシングで適用できるメソッドが先に検討されます。int 1はIntegerへボクシングされます。"),
            Choice(id: "b", text: "varargs", correct: false, misconception: "int...がint実引数に最優先で一致すると誤解", explanation: "varargsは最後の段階です。Integerの固定引数メソッドが選ばれます。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "boxingとvarargsで曖昧になると誤解", explanation: "解決段階に優先順位があるため曖昧ではありません。"),
            Choice(id: "d", text: "実行時例外", correct: false, misconception: "オーバーロード解決が実行時に行われると誤解", explanation: "オーバーロードはコンパイル時に選択されます。"),
        ],
        explanationRef: "explain-silver-mock-overload-varargs-001",
        designIntent: "オーバーロード解決でboxingがvarargsより優先されることを確認する。"
    )

    static let silverMockDoWhile001 = Quiz(
        id: "silver-mock-do-while-001",
        level: .silver,
        difficulty: .tricky,
        isMockExamOnly: true,
        category: "control-flow",
        tags: ["模試専用", "do-while", "post-increment"],
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
            Choice(id: "a", text: "0:1", correct: true, misconception: nil, explanation: "do-whileは条件判定前に本体を必ず1回実行します。i++は0を出力してからiを1にします。その後条件i<0はfalseです。"),
            Choice(id: "b", text: ":0", correct: false, misconception: "whileと同じく条件を先に判定すると誤解", explanation: "do-whileは少なくとも1回本体を実行します。"),
            Choice(id: "c", text: "1:1", correct: false, misconception: "後置インクリメントが増加後の値を返すと誤解", explanation: "i++は現在値0を使ってから1へ増やします。"),
            Choice(id: "d", text: "無限ループ", correct: false, misconception: "i<0がtrueになると誤解", explanation: "本体後のiは1なので条件はfalseです。"),
        ],
        explanationRef: "explain-silver-mock-do-while-001",
        designIntent: "do-whileの最低1回実行と後置インクリメントを確認する。"
    )

    static let goldMockCollectorsToMap001 = Quiz(
        id: "gold-mock-collectors-to-map-001",
        level: .gold,
        difficulty: .exam,
        isMockExamOnly: true,
        category: "lambda-streams",
        tags: ["模試専用", "Collectors", "toMap", "merge", "TreeMap"],
        code: """
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "{1=b, 2=aacc}", correct: true, misconception: nil, explanation: "キーは文字列長です。aaとccはキー2で衝突し、マージ関数でaa+ccとなります。TreeMapなのでキー順に1,2で表示されます。"),
            Choice(id: "b", text: "{2=aacc, 1=b}", correct: false, misconception: "TreeMapではなく遭遇順で表示されると誤解", explanation: "Map実装にTreeMapを指定しているためキーの自然順序で表示されます。"),
            Choice(id: "c", text: "IllegalStateException", correct: false, misconception: "重複キーが常に例外になると誤解", explanation: "今回はマージ関数を指定しているため、重複キーを結合できます。"),
            Choice(id: "d", text: "{1=b, 2=cc}", correct: false, misconception: "重複キーで後勝ちになると誤解", explanation: "後勝ちではなく、指定したマージ関数left + rightで結合します。"),
        ],
        explanationRef: "explain-gold-mock-collectors-to-map-001",
        designIntent: "Collectors.toMapのマージ関数とMap実装指定を同時に確認する。"
    )

    static let goldMockOptionalOr001 = Quiz(
        id: "gold-mock-optional-or-001",
        level: .gold,
        difficulty: .exam,
        isMockExamOnly: true,
        category: "optional-api",
        tags: ["模試専用", "Optional", "or", "map", "orElseGet"],
        code: """
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "FJAVA", correct: true, misconception: nil, explanation: "最初のOptionalが空なのでorのSupplierが実行されFが出力されます。その後javaを大文字化してJAVAをprintlnします。"),
            Choice(id: "b", text: "JAVA", correct: false, misconception: "fallbackの副作用出力を見落とし", explanation: "orのSupplier内でSystem.out.print(\"F\")が実行されます。"),
            Choice(id: "c", text: "FNONE", correct: false, misconception: "orが値ありOptionalを返すことを見落とし", explanation: "fallbackはOptional.of(\"java\")を返すため、orElseGetのNONEは使われません。"),
            Choice(id: "d", text: "NONE", correct: false, misconception: "orのSupplierが実行されないと誤解", explanation: "元のOptionalが空なのでSupplierは実行されます。"),
        ],
        explanationRef: "explain-gold-mock-optional-or-001",
        designIntent: "Optional.orの遅延代替Optional生成と、その後のmap/orElseGetの流れを確認する。"
    )

    static let goldMockInvokeAny001 = Quiz(
        id: "gold-mock-invoke-any-001",
        level: .gold,
        difficulty: .exam,
        isMockExamOnly: true,
        category: "concurrency",
        tags: ["模試専用", "ExecutorService", "invokeAny", "Callable"],
        code: """
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
        question: "このコードを実行したとき、通常出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "B", correct: true, misconception: nil, explanation: "invokeAnyは正常完了したいずれか1つの結果を返します。ここではBのタスクが待機なしで完了するため、通常Bが返ります。"),
            Choice(id: "b", text: "A", correct: false, misconception: "入力順の最初の結果を返すと誤解", explanation: "invokeAnyは入力順ではなく、成功したタスクのいずれかの結果を返します。"),
            Choice(id: "c", text: "AB", correct: false, misconception: "全タスクの結果を結合すると誤解", explanation: "全結果が欲しい場合はinvokeAllです。invokeAnyは1つの結果です。"),
            Choice(id: "d", text: "ExecutionException", correct: false, misconception: "戻り値を得るにはFuture.getが必要と誤解", explanation: "invokeAnyは成功したCallableの戻り値を直接返します。"),
        ],
        explanationRef: "explain-gold-mock-invoke-any-001",
        designIntent: "invokeAnyが入力順ではなく、成功したいずれか1つの結果を返すことを確認する。"
    )

    static let goldMockSuppressedOrder001 = Quiz(
        id: "gold-mock-suppressed-order-001",
        level: .gold,
        difficulty: .exam,
        isMockExamOnly: true,
        category: "exception-handling",
        tags: ["模試専用", "try-with-resources", "suppressed", "close order"],
        code: """
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "body:BA", correct: true, misconception: nil, explanation: "本体のbodyが主例外です。リソースは逆順に閉じるため、bのB、aのAがsuppressedに順に追加されます。"),
            Choice(id: "b", text: "body:AB", correct: false, misconception: "closeが宣言順に行われると誤解", explanation: "try-with-resourcesでは後に宣言したリソースから先に閉じます。"),
            Choice(id: "c", text: "B:A", correct: false, misconception: "close例外が主例外になると誤解", explanation: "try本体で既にbodyが投げられているため、close例外はsuppressedです。"),
            Choice(id: "d", text: "body", correct: false, misconception: "suppressed例外が消えると誤解", explanation: "suppressed例外はgetSuppressed()で取得できます。"),
        ],
        explanationRef: "explain-gold-mock-suppressed-order-001",
        designIntent: "複数リソースのclose順とsuppressed例外の順序を確認する。"
    )

    static let goldMockRecordArray001 = Quiz(
        id: "gold-mock-record-array-001",
        level: .gold,
        difficulty: .exam,
        isMockExamOnly: true,
        category: "classes",
        tags: ["模試専用", "record", "equals", "array"],
        code: """
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "false:true", correct: true, misconception: nil, explanation: "recordの自動equalsは配列コンポーネントに対して配列内容比較ではなく配列オブジェクトのequalsを使います。別配列なのでfalse、Arrays.equalsは内容比較なのでtrueです。"),
            Choice(id: "b", text: "true:true", correct: false, misconception: "recordのequalsが配列内容まで比較すると誤解", explanation: "recordが特別に配列内容比較へ変換するわけではありません。"),
            Choice(id: "c", text: "false:false", correct: false, misconception: "Arrays.equalsも参照比較と誤解", explanation: "Arrays.equals(int[], int[])は要素内容を比較します。"),
            Choice(id: "d", text: "true:false", correct: false, misconception: "recordとArrays.equalsの比較方法を逆に理解", explanation: "recordのequalsは配列参照比較相当、Arrays.equalsは内容比較です。"),
        ],
        explanationRef: "explain-gold-mock-record-array-001",
        designIntent: "recordの自動equalsと配列コンポーネントの落とし穴を確認する。"
    )

    static let goldMockSealedPermits001 = Quiz(
        id: "gold-mock-sealed-permits-001",
        level: .gold,
        difficulty: .exam,
        validatedByJavac: false,
        isMockExamOnly: true,
        category: "classes",
        tags: ["模試専用", "sealed", "permits", "compile error"],
        code: """
sealed interface Shape permits Circle {}

final class Circle implements Shape {}

final class Square implements Shape {}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる", correct: false, misconception: "finalならsealed型を自由に実装できると誤解", explanation: "sealed型を直接実装・継承できるのはpermitsに列挙された型だけです。"),
            Choice(id: "b", text: "Square implements Shape がコンパイルエラー", correct: true, misconception: nil, explanation: "ShapeのpermitsにSquareが含まれていないため、SquareはShapeを直接実装できません。"),
            Choice(id: "c", text: "Circleがfinalなのでコンパイルエラー", correct: false, misconception: "sealedの直接サブタイプにfinalを使えないと誤解", explanation: "sealed型の直接サブタイプはfinal、sealed、non-sealedのいずれかを明示する必要があります。Circleのfinalは正しいです。"),
            Choice(id: "d", text: "sealed interface には permits を書けない", correct: false, misconception: "sealed class と sealed interface を混同", explanation: "sealed interfaceにもpermitsを書けます。"),
        ],
        explanationRef: "explain-gold-mock-sealed-permits-001",
        designIntent: "sealed型のpermitsリストと直接サブタイプ制限を確認する。"
    )

    static let goldMockRawHeapPollution001 = Quiz(
        id: "gold-mock-raw-heap-pollution-001",
        level: .gold,
        difficulty: .exam,
        isMockExamOnly: true,
        category: "generics",
        tags: ["模試専用", "raw type", "heap pollution", "ClassCastException"],
        code: """
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "CCE", correct: true, misconception: nil, explanation: "raw型経由でStringをList<Integer>の実体へ追加できますが、nums.get(0)をIntegerへ代入する地点でキャストが入りClassCastExceptionになります。"),
            Choice(id: "b", text: "x", correct: false, misconception: "Integer変数へStringがそのまま入ると誤解", explanation: "Integerへの暗黙キャストが発生し、StringはIntegerに変換できません。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "raw型使用が必ずコンパイルエラーと誤解", explanation: "raw型使用は警告になりますが、通常はコンパイルできます。"),
            Choice(id: "d", text: "ArrayStoreException", correct: false, misconception: "配列の実行時型検査と混同", explanation: "これは配列ではなくジェネリクスのヒープ汚染なので、取得時にClassCastExceptionです。"),
        ],
        explanationRef: "explain-gold-mock-raw-heap-pollution-001",
        designIntent: "raw型によるヒープ汚染と取得時のClassCastExceptionを確認する。"
    )

    static let goldMockDateTimePeriodDuration001 = Quiz(
        id: "gold-mock-date-time-period-duration-001",
        level: .gold,
        difficulty: .exam,
        isMockExamOnly: true,
        category: "date-time",
        tags: ["模試専用", "LocalDateTime", "Period", "Duration"],
        code: """
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2024-03-01T01:00", correct: true, misconception: nil, explanation: "2024年はうるう年なので2月28日にPeriod.ofDays(1)を足すと2月29日23:00。さらに2時間足して3月1日01:00です。"),
            Choice(id: "b", text: "2024-02-29T01:00", correct: false, misconception: "日付加算と時刻加算の順序を誤解", explanation: "先に1日足して2月29日23:00になり、その後2時間で3月1日へ進みます。"),
            Choice(id: "c", text: "2024-03-02T01:00", correct: false, misconception: "うるう年を見落とし", explanation: "2024年には2月29日が存在するため、2月28日の翌日は2月29日です。"),
            Choice(id: "d", text: "2024-02-28T23:00", correct: false, misconception: "日時APIが不変なので戻り値代入も無視されると誤解", explanation: "LocalDateTimeは不変ですが、戻り値をtへ再代入しています。"),
        ],
        explanationRef: "explain-gold-mock-date-time-period-duration-001",
        designIntent: "PeriodとDurationを順番に適用したときの日時変化とうるう年を確認する。"
    )

    static let goldMockPathNormalize001 = Quiz(
        id: "gold-mock-path-normalize-001",
        level: .gold,
        difficulty: .exam,
        isMockExamOnly: true,
        category: "io",
        tags: ["模試専用", "Path", "relativize", "normalize"],
        code: """
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "d", correct: true, misconception: nil, explanation: "baseからtargetへの相対パスはc/../dです。normalizeでc/..が整理され、dになります。"),
            Choice(id: "b", text: "c/../d", correct: false, misconception: "normalizeの効果を見落とし", explanation: "relativize後にnormalizeを呼んでいるため、..が整理されます。"),
            Choice(id: "c", text: "/a/b/d", correct: false, misconception: "relativize後も絶対パスだと誤解", explanation: "relativizeはbaseからtargetへの相対パスを返します。"),
            Choice(id: "d", text: "../d", correct: false, misconception: "baseから一段上がると誤解", explanation: "targetは正規化すると/a/b/dであり、base配下です。"),
        ],
        explanationRef: "explain-gold-mock-path-normalize-001",
        designIntent: "relativize後の相対パスとnormalizeの順序を確認する。"
    )

    static let goldMockAnnotationRetention001 = Quiz(
        id: "gold-mock-annotation-retention-001",
        level: .gold,
        difficulty: .exam,
        isMockExamOnly: true,
        category: "annotations",
        tags: ["模試専用", "Annotation", "Retention", "reflection"],
        code: """
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "false", correct: true, misconception: nil, explanation: "RetentionPolicy.CLASSはclassファイルには残りますが、実行時リフレクションでは取得できません。isAnnotationPresentはfalseです。"),
            Choice(id: "b", text: "true", correct: false, misconception: "CLASS保持でも実行時に見えると誤解", explanation: "実行時にリフレクションで読むにはRetentionPolicy.RUNTIMEが必要です。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "RetentionPolicy.CLASSを自作アノテーションに使えないと誤解", explanation: "CLASSは有効なRetentionPolicyです。"),
            Choice(id: "d", text: "Mark", correct: false, misconception: "booleanではなくアノテーション名が出ると誤解", explanation: "出力しているのはisAnnotationPresentのbooleanです。"),
        ],
        explanationRef: "explain-gold-mock-annotation-retention-001",
        designIntent: "RetentionPolicy.CLASSとRUNTIMEのリフレクション可視性の違いを確認する。"
    )
}
