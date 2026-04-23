import Foundation

enum GoldMockTopupQuestionData {
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
            "gold-mock-topup-integer-cache-001",
            category: "data-types",
            tags: ["模試専用", "Integer", "キャッシュ", "=="],
            code: """
public class Test {
    public static void main(String[] args) {
        Integer a = 127;
        Integer b = 127;
        Integer c = 128;
        Integer d = 128;
        System.out.println((a == b) + ":" + (c == d));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true:true", misconception: "Integerの==が常に値比較になると誤解", explanation: "==は参照比較です。キャッシュ範囲外の128は通常別オブジェクトです。"),
                choice("b", "true:false", correct: true, explanation: "127はIntegerキャッシュにより同じ参照、128は通常別参照になるため `true:false` です。"),
                choice("c", "false:true", misconception: "キャッシュ範囲を逆に理解", explanation: "代表的なキャッシュ範囲は-128から127です。128は範囲外です。"),
                choice("d", "false:false", misconception: "autoboxingでは常に新規オブジェクトが作られると誤解", explanation: "キャッシュ範囲内のIntegerは再利用されます。"),
            ],
            intent: "Integerキャッシュと、ラッパー型の==が値比較ではなく参照比較であることを確認する。",
            steps: [
                step("`Integer a = 127;` と `b = 127;` はautoboxingされます。127はIntegerキャッシュ範囲内です。", [3, 4], [variable("a,b", "Integer", "same cached object", "main")]),
                step("`Integer c = 128;` と `d = 128;` は代表的なキャッシュ範囲外のため、通常は別オブジェクトになります。", [5, 6], [variable("c,d", "Integer", "different objects", "main")]),
                step("`==` は参照比較です。a==bはtrue、c==dはfalseとなり、出力は `true:false` です。", [7], [variable("output", "String", "true:false", "stdout")]),
            ]
        ),
        q(
            "gold-mock-topup-compound-overflow-001",
            category: "data-types",
            tags: ["模試専用", "byte", "複合代入", "オーバーフロー"],
            code: """
public class Test {
    public static void main(String[] args) {
        byte b = 127;
        b += 1;
        System.out.println(b);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "128", misconception: "byteが128を保持できると誤解", explanation: "byteの範囲は-128から127です。128は保持できません。"),
                choice("b", "-128", correct: true, explanation: "`b += 1` は暗黙のキャストを含む複合代入です。127に1を足した結果がbyteへ戻され、-128になります。"),
                choice("c", "コンパイルエラー", misconception: "`b = b + 1` と同じ扱いだと誤解", explanation: "`b = b + 1` はコンパイルエラーですが、`b += 1` は暗黙のキャストが入るためコンパイルできます。"),
                choice("d", "ArithmeticException", misconception: "整数オーバーフローで例外が出ると誤解", explanation: "Javaの整数オーバーフローは通常例外を投げません。"),
            ],
            intent: "複合代入の暗黙キャストとbyte範囲のオーバーフローを確認する。",
            steps: [
                step("`byte b = 127;` でbはbyteの最大値です。", [3], [variable("b", "byte", "127", "main")]),
                step("`b += 1` は `b = (byte)(b + 1)` 相当です。int計算後にbyteへ戻されます。", [4], [variable("b + 1", "int", "128", "main")]),
                step("128をbyteに戻すと範囲を回り込み、bは-128になります。出力は `-128` です。", [5], [variable("b", "byte", "-128", "main"), variable("output", "String", "-128", "stdout")]),
            ]
        ),
        q(
            "gold-mock-topup-switch-null-001",
            category: "control-flow",
            tags: ["模試専用", "switch", "null", "NullPointerException"],
            code: """
public class Test {
    public static void main(String[] args) {
        try {
            String s = null;
            switch (s) {
                case "A" -> System.out.println("A");
                default -> System.out.println("D");
            }
        } catch (NullPointerException e) {
            System.out.println("NPE");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", misconception: "nullが文字列Aとして扱われると誤解", explanation: "nullはどのcaseラベルにも一致しません。"),
                choice("b", "D", misconception: "nullはdefaultに流れると誤解", explanation: "String switchでnullを評価すると、defaultへ進む前にNullPointerExceptionが発生します。"),
                choice("c", "NPE", correct: true, explanation: "`switch (s)` の評価時にsがnullのためNullPointerExceptionが発生し、catchでNPEが出力されます。"),
                choice("d", "コンパイルエラー", misconception: "String switchにnullの可能性があるとコンパイルできないと誤解", explanation: "コンパイルはできます。nullは実行時例外になります。"),
            ],
            intent: "String switchにnullを渡したときdefaultではなくNullPointerExceptionになることを確認する。",
            steps: [
                step("tryブロック内で `String s = null;` として、sはnullです。", [3, 4], [variable("s", "String", "null", "main")]),
                step("`switch (s)` はcase判定の前にswitch対象を評価します。対象がnullなのでNullPointerExceptionが発生します。", [5], [variable("switch target", "String", "null", "main")]),
                step("例外はcatchで捕捉され、`NPE` が出力されます。default節は実行されません。", [9, 10], [variable("output", "String", "NPE", "stdout")]),
            ]
        ),
        q(
            "gold-mock-topup-pattern-scope-001",
            validatedByJavac: false,
            category: "control-flow",
            tags: ["模試専用", "instanceof", "パターン変数", "スコープ"],
            code: """
public class Test {
    public static void main(String[] args) {
        Object obj = "gold";
        if (obj instanceof String s && s.length() > 3) {
            System.out.println(s.toUpperCase());
        }
        System.out.println(s);
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "GOLDとgoldが出力される", misconception: "パターン変数sがif文の後も使えると誤解", explanation: "sのスコープは条件が成り立つ領域とifブロック内に限られます。"),
                choice("b", "GOLDだけが出力される", misconception: "if後のs参照が無視されると誤解", explanation: "if後の `System.out.println(s)` はコンパイル時に検出されます。"),
                choice("c", "7行目のs参照でコンパイルエラー", correct: true, explanation: "パターン変数sはifブロックの外ではスコープ外です。7行目ではsを参照できません。"),
                choice("d", "実行時にNullPointerException", misconception: "スコープエラーが実行時まで遅れると誤解", explanation: "変数sがスコープ外であることはコンパイル時に判定されます。"),
            ],
            intent: "instanceofパターン変数のスコープがifブロック外へ漏れないことを確認する。",
            steps: [
                step("`obj instanceof String s && ...` により、条件式の右側とifブロック内ではsを使えます。", [4, 5], [variable("s", "String", "gold", "if")]),
                step("ifブロックが終わると、パターン変数sのスコープも終わります。", [6], [variable("s scope", "String", "ended", "compiler")]),
                step("7行目の `System.out.println(s);` はスコープ外の変数参照なのでコンパイルエラーです。", [7], [variable("compile result", "String", "error", "javac")]),
            ]
        ),
        q(
            "gold-mock-topup-optional-eager-orElse-001",
            category: "optional-api",
            tags: ["模試専用", "Optional", "orElse", "orElseGet", "副作用"],
            code: """
import java.util.*;

public class Test {
    static String fallback() {
        System.out.print("B");
        return "C";
    }
    public static void main(String[] args) {
        Optional<String> opt = Optional.of("A");
        String value = opt.orElse(fallback());
        System.out.print(value);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A", misconception: "orElseの引数が必要なときだけ評価されると誤解", explanation: "orElseの引数式はメソッド呼び出し前に評価されます。"),
                choice("b", "BA", correct: true, explanation: "optは値Aを持ちますが、orElseの引数fallback()は先に評価されBを出力します。その後Aが出力されます。"),
                choice("c", "BC", misconception: "orElseがfallbackの戻り値を採用すると誤解", explanation: "Optionalに値があるため、orElseの戻り値としてはAが採用されます。"),
                choice("d", "C", misconception: "fallbackの戻り値だけが出力されると誤解", explanation: "fallbackはBを出力してCを返しますが、最終的なvalueはAです。"),
            ],
            intent: "orElseは引数を eager に評価し、orElseGetは必要時にSupplierを評価するという違いを確認する。",
            steps: [
                step("`Optional.of(\"A\")` によりoptは値Aを保持しています。", [9], [variable("opt", "Optional<String>", "Optional[A]", "main")]),
                step("`opt.orElse(fallback())` では、orElse呼び出し前に引数式fallback()が評価されます。fallbackはBを出力しCを返します。", [10, 4, 5, 6], [variable("fallback()", "String", "C", "main"), variable("output so far", "String", "B", "stdout")]),
                step("optは空ではないためorElseの結果はAです。最後にAを出力し、全体の出力は `BA` です。", [10, 11], [variable("value", "String", "A", "main"), variable("output", "String", "BA", "stdout")]),
            ]
        ),
        q(
            "gold-mock-topup-stream-reduce-order-001",
            category: "lambda-streams",
            tags: ["模試専用", "Stream", "reduce", "終端操作"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        int result = List.of(1, 2, 3)
            .stream()
            .reduce(0, (a, b) -> a - b);
        System.out.println(result);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "6", misconception: "reduceが常に合計になると誤解", explanation: "ラムダは加算ではなく減算です。"),
                choice("b", "-6", correct: true, explanation: "初期値0から順に `0 - 1 = -1`、`-1 - 2 = -3`、`-3 - 3 = -6` となります。"),
                choice("c", "0", misconception: "初期値が最終結果として残ると誤解", explanation: "初期値は最初の累積値として使われ、その後各要素が処理されます。"),
                choice("d", "2", misconception: "最後の `3 - 1` のように処理すると誤解", explanation: "逐次streamのreduceは遭遇順に累積します。"),
            ],
            intent: "reduceのidentityとaccumulatorをコード順に追わせる。",
            steps: [
                step("reduceのidentityは0です。最初の要素1で `0 - 1` が計算されます。", [5, 6, 7], [variable("a", "int", "0", "reduce"), variable("b", "int", "1", "reduce"), variable("result", "int", "-1", "reduce")]),
                step("次に要素2で `-1 - 2 = -3`、要素3で `-3 - 3 = -6` と累積されます。", [7], [variable("result", "int", "-6", "reduce")]),
                step("最終結果resultは-6で、`System.out.println(result)` により `-6` が出力されます。", [8], [variable("output", "String", "-6", "stdout")]),
            ]
        ),
        q(
            "gold-mock-topup-try-resource-suppressed-001",
            category: "exception-handling",
            tags: ["模試専用", "try-with-resources", "suppressed", "close順序"],
            code: """
class R implements AutoCloseable {
    private final String name;
    R(String name) { this.name = name; }
    public void close() throws Exception {
        throw new Exception("close" + name);
    }
}

public class Test {
    public static void main(String[] args) {
        try (R a = new R("A"); R b = new R("B")) {
            throw new Exception("body");
        } catch (Exception e) {
            System.out.println(
                e.getMessage() + ":" +
                e.getSuppressed()[0].getMessage() + ":" +
                e.getSuppressed()[1].getMessage()
            );
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "body:closeA:closeB", misconception: "リソースが宣言順にcloseされると誤解", explanation: "try-with-resourcesのcloseは宣言と逆順です。"),
                choice("b", "body:closeB:closeA", correct: true, explanation: "本体例外bodyが主例外になり、closeはB、Aの逆順に実行され、それぞれsuppressedに追加されます。"),
                choice("c", "closeB:closeA:body", misconception: "close例外が主例外になると誤解", explanation: "try本体で例外が発生しているため、それが主例外です。close例外は抑制例外です。"),
                choice("d", "コンパイルエラー", misconception: "closeが例外を投げるAutoCloseableを使えないと誤解", explanation: "catchでExceptionを捕捉しているためコンパイルできます。"),
            ],
            intent: "try-with-resourcesのclose順序とsuppressed例外の並びを確認する。",
            steps: [
                step("tryブロック内でa、bの順にリソースが作成され、その後本体で `body` 例外が発生します。", [11, 12], [variable("primary exception", "Exception", "body", "try")]),
                step("リソースは宣言と逆順にcloseされます。まずb.close()が `closeB` を投げ、次にa.close()が `closeA` を投げます。", [4, 5, 11], [variable("suppressed[0]", "Exception", "closeB", "catch"), variable("suppressed[1]", "Exception", "closeA", "catch")]),
                step("catchでは主例外のmessageとsuppressedのmessageを順に連結し、`body:closeB:closeA` を出力します。", [14, 15, 16, 17], [variable("output", "String", "body:closeB:closeA", "stdout")]),
            ]
        ),
        q(
            "gold-mock-topup-list-of-null-001",
            category: "collections",
            tags: ["模試専用", "List.of", "null", "コレクション"],
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
                choice("a", "2", misconception: "List.ofがnull要素を許容すると誤解", explanation: "List.ofで作る不変リストはnull要素を許容しません。"),
                choice("b", "1", misconception: "null要素が自動的に除外されると誤解", explanation: "nullが除外されるのではなく、生成時に例外が発生します。"),
                choice("c", "NPE", correct: true, explanation: "`List.of(\"A\", null)` の評価時にNullPointerExceptionが発生し、catchでNPEが出力されます。"),
                choice("d", "コンパイルエラー", misconception: "List.ofにnullリテラルを渡せない文法だと誤解", explanation: "呼び出し自体はコンパイルできます。null拒否は実行時の挙動です。"),
            ],
            intent: "List.ofなどの不変コレクションファクトリがnull要素を許容しないことを確認する。",
            steps: [
                step("tryブロックで `List.of(\"A\", null)` を評価します。呼び出しはコンパイル可能です。", [5, 6], [variable("argument[1]", "String", "null", "main")]),
                step("List.ofはnull要素を許容しないため、リスト生成時にNullPointerExceptionが発生します。", [6], [variable("list", "List<String>", "not created", "main")]),
                step("catch節で例外を捕捉し、`NPE` を出力します。`list.size()` は実行されません。", [7, 8, 9], [variable("output", "String", "NPE", "stdout")]),
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
        ChoiceSpec(
            id: id,
            text: text,
            correct: correct,
            misconception: misconception,
            explanation: explanation
        )
    }

    static func step(
        _ narration: String,
        _ highlightLines: [Int],
        _ variables: [VariableSpec] = []
    ) -> StepSpec {
        StepSpec(
            narration: narration,
            highlightLines: highlightLines,
            variables: variables
        )
    }

    static func variable(
        _ name: String,
        _ type: String,
        _ value: String,
        _ scope: String
    ) -> VariableSpec {
        VariableSpec(name: name, type: type, value: value, scope: scope)
    }
}

extension GoldMockTopupQuestionData.Spec {
    var quiz: Quiz {
        Quiz(
            id: id,
            level: .gold,
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
    static let goldMockTopupExpansion: [Quiz] = GoldMockTopupQuestionData.specs.map(\.quiz)
}
