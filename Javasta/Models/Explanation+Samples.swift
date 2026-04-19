import Foundation

extension Explanation {
    static func sample(for ref: String) -> Explanation? {
        switch ref {
        case "explain-silver-overload-001":   return silverOverload001
        case "explain-silver-exception-001":  return silverException001
        case "explain-silver-string-001":     return silverString001
        case "explain-silver-autoboxing-001": return silverAutoboxing001
        case "explain-silver-switch-001":     return silverSwitch001
        case "explain-gold-generics-001":     return goldGenerics001
        case "explain-gold-stream-001":       return goldStream001
        case "explain-gold-optional-001":     return goldOptional001
        default:
            if let quiz = Quiz.samples.first(where: { $0.explanationRef == ref }) {
                return quickTrace(for: quiz, ref: ref)
            }
            return nil
        }
    }

    private static func quickTrace(for quiz: Quiz, ref: String) -> Explanation {
        let lines = quiz.code.components(separatedBy: .newlines)
        let mainLine = lines.firstIndex { $0.contains("main(") }.map { $0 + 1 } ?? 1
        let outputLine = lines.lastIndex { $0.contains("System.out") }.map { $0 + 1 } ?? max(lines.count, 1)
        let correctChoice = quiz.choices.first { $0.correct }

        return Explanation(
            id: ref,
            initialCode: quiz.code,
            codeTabs: quiz.codeTabs,
            steps: [
                Step(
                    index: 0,
                    narration: "mainメソッドから実行開始。この問題では、コードを上から順に追い、出力またはコンパイル結果を判断します。",
                    highlightLines: [mainLine],
                    variables: [],
                    callStack: [CallStackFrame(method: "main", line: mainLine)],
                    heap: [],
                    predict: nil
                ),
                Step(
                    index: 1,
                    narration: "選択肢を判断する前に、型・参照・APIの評価順序を確認します。特にこの問題の狙いは「\(quiz.designIntent)」です。",
                    highlightLines: [outputLine],
                    variables: [],
                    callStack: [CallStackFrame(method: "main", line: outputLine)],
                    heap: [],
                    predict: PredictPrompt(
                        question: quiz.question,
                        choices: quiz.choices.map(\.text),
                        answerIndex: max(quiz.choices.firstIndex(where: { $0.correct }) ?? 0, 0),
                        hint: quiz.tags.joined(separator: " / "),
                        afterExplanation: correctChoice?.explanation ?? quiz.designIntent
                    )
                ),
                Step(
                    index: 2,
                    narration: "正解は「\(correctChoice?.text ?? "該当なし")」。\(correctChoice?.explanation ?? quiz.designIntent)",
                    highlightLines: [outputLine],
                    variables: [],
                    callStack: [CallStackFrame(method: "main", line: outputLine)],
                    heap: [],
                    predict: nil
                ),
            ]
        )
    }

    // MARK: - Silver: オーバーロード解決

    static let silverOverload001 = Explanation(
        id: "explain-silver-overload-001",
        relatedLessonId: "lesson-overload-resolution",
        initialCode: """
public class Test {
    static void print(int x) {
        System.out.println("int: " + x);
    }
    static void print(long x) {
        System.out.println("long: " + x);
    }
    public static void main(String[] args) {
        print(5);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "mainメソッドから実行開始。JVMはmainをコールスタックに積みます。",
                 highlightLines: [8],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 8)],
                 heap: [], predict: nil),

            Step(index: 1,
                 narration: "print(5) を呼び出します。引数 5 はint型のリテラルです。Javaはここでオーバーロード解決を行い、どちらのprint()を呼ぶか決定します。",
                 highlightLines: [9],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 9)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "呼び出されるのはどちら？",
                    choices: ["print(int x)", "print(long x)"],
                    answerIndex: 0,
                    hint: "5はint型リテラル。完全一致 > 型昇格の優先順位",
                    afterExplanation: "print(int)と完全一致。型昇格は完全一致がない場合のみ試みられます。"
                 )),

            Step(index: 2,
                 narration: "print(int x) に入ります。引数 x に int 型の値 5 が渡されます。コールスタックにprint(int)が積まれます。",
                 highlightLines: [2],
                 variables: [Variable(name: "x", type: "int", value: "5", scope: "print(int)")],
                 callStack: [
                    CallStackFrame(method: "main", line: 9),
                    CallStackFrame(method: "print(int)", line: 2),
                 ],
                 heap: [], predict: nil),

            Step(index: 3,
                 narration: "System.out.println(\"int: \" + x) を実行。\"int: \" と x(=5) を連結して \"int: 5\" を出力します。",
                 highlightLines: [3],
                 variables: [Variable(name: "x", type: "int", value: "5", scope: "print(int)")],
                 callStack: [
                    CallStackFrame(method: "main", line: 9),
                    CallStackFrame(method: "print(int)", line: 3),
                 ],
                 heap: [], predict: nil),

            Step(index: 4,
                 narration: "print(int)が終了してコールスタックから取り除かれます。mainに戻り、プログラムが終了します。\n\n出力結果: \"int: 5\"",
                 highlightLines: [9],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 9)],
                 heap: [], predict: nil),
        ]
    )

    // MARK: - Silver: finallyのreturn

    static let silverException001 = Explanation(
        id: "explain-silver-exception-001",
        relatedLessonId: "lesson-finally-and-return",
        initialCode: """
public class Test {
    static int calc() {
        try {
            return 1;
        } finally {
            return 2;
        }
    }
    public static void main(String[] args) {
        System.out.println(calc());
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "mainからcalc()を呼び出します。",
                 highlightLines: [10],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 10)],
                 heap: [], predict: nil),

            Step(index: 1,
                 narration: "tryブロックに入ります。return 1 が実行されますが、Javaはすぐにメソッドを返しません。戻り値 1 を一時的に保留し、finallyブロックを必ず実行します。",
                 highlightLines: [4],
                 variables: [Variable(name: "保留中の戻り値", type: "int", value: "1", scope: "calc")],
                 callStack: [
                    CallStackFrame(method: "main", line: 10),
                    CallStackFrame(method: "calc", line: 4),
                 ],
                 heap: [],
                 predict: PredictPrompt(
                    question: "finallyのreturn 2が実行されると、最終的な戻り値は？",
                    choices: ["1（tryのreturnが優先）", "2（finallyのreturnが優先）", "例外が発生する"],
                    answerIndex: 1,
                    hint: "finallyはtryのreturnを上書きする",
                    afterExplanation: "finallyのreturnは保留中の戻り値1を完全に上書きします。最終的に2が返されます。"
                 )),

            Step(index: 2,
                 narration: "finallyブロックが実行されます。return 2 によって、保留中だった戻り値1が上書きされ、2がcalcの最終的な戻り値になります。",
                 highlightLines: [6],
                 variables: [Variable(name: "最終戻り値", type: "int", value: "2", scope: "calc")],
                 callStack: [
                    CallStackFrame(method: "main", line: 10),
                    CallStackFrame(method: "calc", line: 6),
                 ],
                 heap: [], predict: nil),

            Step(index: 3,
                 narration: "calc()が2を返してmainに戻ります。System.out.println(2)が実行され、\"2\" が出力されます。",
                 highlightLines: [10],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 10)],
                 heap: [], predict: nil),
        ]
    )

    // MARK: - Gold: ジェネリクス（上限境界ワイルドカード）

    static let goldGenerics001 = Explanation(
        id: "explain-gold-generics-001",
        relatedLessonId: "lesson-bounded-wildcards",
        initialCode: """
import java.util.*;

public class Test {
    static double sum(List<? extends Number> list) {
        double total = 0;
        for (Number n : list) {
            total += n.doubleValue();
        }
        return total;
    }
    public static void main(String[] args) {
        List<Integer> ints = Arrays.asList(1, 2, 3);
        System.out.println(sum(ints));
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "mainメソッドから実行開始。Arrays.asList(1, 2, 3) で List<Integer> を作成します。",
                 highlightLines: [12],
                 variables: [Variable(name: "ints", type: "List<Integer>", value: "[1, 2, 3]", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 12)],
                 heap: [], predict: nil),

            Step(index: 1,
                 narration: "sum(ints) を呼び出します。引数は List<Integer> ですが、メソッドは List<? extends Number> を受け取ります。型システムはこれを許可するでしょうか？",
                 highlightLines: [13],
                 variables: [Variable(name: "ints", type: "List<Integer>", value: "[1, 2, 3]", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 13)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "List<Integer> を List<? extends Number> として渡せる？",
                    choices: ["渡せる（IntegerはNumberのサブタイプ）", "渡せない（型不一致）"],
                    answerIndex: 0,
                    hint: "<? extends Number> は Number のサブタイプを受け入れる",
                    afterExplanation: "上限境界ワイルドカード <? extends Number> は、Number またはそのサブタイプ（Integer, Long, Double等）のリストを受け取れます。"
                 )),

            Step(index: 2,
                 narration: "sum メソッド内に入ります。total が 0.0 で初期化されます。",
                 highlightLines: [5],
                 variables: [
                    Variable(name: "list", type: "List<? ext Number>", value: "[1, 2, 3]", scope: "sum"),
                    Variable(name: "total", type: "double", value: "0.0", scope: "sum"),
                 ],
                 callStack: [
                    CallStackFrame(method: "main", line: 13),
                    CallStackFrame(method: "sum", line: 5),
                 ],
                 heap: [], predict: nil),

            Step(index: 3,
                 narration: "for-eachループ1回目。n = 1（Integer→Numberとして扱う）。doubleValue() で 1.0 に変換して total に加算します。",
                 highlightLines: [7],
                 variables: [
                    Variable(name: "list", type: "List<? ext Number>", value: "[1, 2, 3]", scope: "sum"),
                    Variable(name: "n", type: "Number", value: "1", scope: "sum"),
                    Variable(name: "total", type: "double", value: "1.0", scope: "sum"),
                 ],
                 callStack: [
                    CallStackFrame(method: "main", line: 13),
                    CallStackFrame(method: "sum", line: 7),
                 ],
                 heap: [], predict: nil),

            Step(index: 4,
                 narration: "ループ2回目。n = 2、total = 1.0 + 2.0 = 3.0",
                 highlightLines: [7],
                 variables: [
                    Variable(name: "list", type: "List<? ext Number>", value: "[1, 2, 3]", scope: "sum"),
                    Variable(name: "n", type: "Number", value: "2", scope: "sum"),
                    Variable(name: "total", type: "double", value: "3.0", scope: "sum"),
                 ],
                 callStack: [
                    CallStackFrame(method: "main", line: 13),
                    CallStackFrame(method: "sum", line: 7),
                 ],
                 heap: [], predict: nil),

            Step(index: 5,
                 narration: "ループ3回目。n = 3、total = 3.0 + 3.0 = 6.0",
                 highlightLines: [7],
                 variables: [
                    Variable(name: "list", type: "List<? ext Number>", value: "[1, 2, 3]", scope: "sum"),
                    Variable(name: "n", type: "Number", value: "3", scope: "sum"),
                    Variable(name: "total", type: "double", value: "6.0", scope: "sum"),
                 ],
                 callStack: [
                    CallStackFrame(method: "main", line: 13),
                    CallStackFrame(method: "sum", line: 7),
                 ],
                 heap: [], predict: nil),

            Step(index: 6,
                 narration: "sumが 6.0 を返してmainに戻ります。System.out.println(6.0) が実行され、\"6.0\" が出力されます。\n\n出力結果: \"6.0\"",
                 highlightLines: [13],
                 variables: [Variable(name: "ints", type: "List<Integer>", value: "[1, 2, 3]", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 13)],
                 heap: [], predict: nil),
        ]
    )

    // MARK: - Silver: 文字列比較

    static let silverString001 = Explanation(
        id: "explain-silver-string-001",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        String a = "hello";
        String b = "hello";
        String c = new String("hello");
        System.out.println((a == b) + " " + (a == c));
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "main開始。String a = \"hello\" でリテラル \"hello\" が文字列定数プールに格納され、aはその参照を保持します。",
                 highlightLines: [3],
                 variables: [Variable(name: "a", type: "String", value: "\"hello\" (pool@1)", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 3)],
                 heap: [Explanation.HeapObject(id: "pool@1", type: "String", fields: ["value": "\"hello\""])],
                 predict: nil),

            Step(index: 1,
                 narration: "String b = \"hello\" を実行。同じリテラルなので、新しいオブジェクトは作られず、bはプール内の同じ参照を共有します。",
                 highlightLines: [4],
                 variables: [
                    Variable(name: "a", type: "String", value: "\"hello\" (pool@1)", scope: "main"),
                    Variable(name: "b", type: "String", value: "\"hello\" (pool@1)", scope: "main"),
                 ],
                 callStack: [CallStackFrame(method: "main", line: 4)],
                 heap: [Explanation.HeapObject(id: "pool@1", type: "String", fields: ["value": "\"hello\""])],
                 predict: PredictPrompt(
                    question: "a == b の結果は？",
                    choices: ["true（同じ参照）", "false（別オブジェクト）"],
                    answerIndex: 0,
                    hint: "リテラルはプールで共有される",
                    afterExplanation: "同じリテラルはプール内で共有されるため、a と b は同じ参照を持ちます。a == b は true。"
                 )),

            Step(index: 2,
                 narration: "String c = new String(\"hello\") を実行。new はヒープ上に新しい String オブジェクトを生成します。プール内の \"hello\" とは別の参照です。",
                 highlightLines: [5],
                 variables: [
                    Variable(name: "a", type: "String", value: "\"hello\" (pool@1)", scope: "main"),
                    Variable(name: "b", type: "String", value: "\"hello\" (pool@1)", scope: "main"),
                    Variable(name: "c", type: "String", value: "\"hello\" (heap@2)", scope: "main"),
                 ],
                 callStack: [CallStackFrame(method: "main", line: 5)],
                 heap: [
                    Explanation.HeapObject(id: "pool@1", type: "String", fields: ["value": "\"hello\""]),
                    Explanation.HeapObject(id: "heap@2", type: "String", fields: ["value": "\"hello\""]),
                 ],
                 predict: PredictPrompt(
                    question: "a == c の結果は？",
                    choices: ["true（中身が同じ）", "false（別オブジェクト）"],
                    answerIndex: 1,
                    hint: "== は参照比較。new で別オブジェクト",
                    afterExplanation: "== は参照比較なので、別オブジェクトの a と c は false。中身を比較するなら equals() を使う。"
                 )),

            Step(index: 3,
                 narration: "println で結果を出力。a==b は true、a==c は false、これらが連結されて \"true false\" が出力されます。",
                 highlightLines: [6],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [], predict: nil),
        ]
    )

    // MARK: - Silver: オートボクシングとIntegerキャッシュ

    static let silverAutoboxing001 = Explanation(
        id: "explain-silver-autoboxing-001",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        Integer a = 100;
        Integer b = 100;
        Integer c = 200;
        Integer d = 200;
        System.out.println((a == b) + " " + (c == d));
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "Integer a = 100 で int リテラルが Integer.valueOf(100) によりオートボクシングされます。100 は -128〜127 のキャッシュ範囲内のため、JVM 内部のキャッシュから既存のオブジェクトが返されます。",
                 highlightLines: [3],
                 variables: [Variable(name: "a", type: "Integer", value: "100 (cache@100)", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 3)],
                 heap: [], predict: nil),

            Step(index: 1,
                 narration: "Integer b = 100 も同じ valueOf(100) を呼び出し、同じキャッシュオブジェクトを返します。a と b は同じ参照。",
                 highlightLines: [4],
                 variables: [
                    Variable(name: "a", type: "Integer", value: "100 (cache@100)", scope: "main"),
                    Variable(name: "b", type: "Integer", value: "100 (cache@100)", scope: "main"),
                 ],
                 callStack: [CallStackFrame(method: "main", line: 4)],
                 heap: [], predict: nil),

            Step(index: 2,
                 narration: "Integer c = 200 を実行。200 はキャッシュ範囲外のため、毎回 new Integer(200) 相当の新しいオブジェクトが作られます。",
                 highlightLines: [5],
                 variables: [
                    Variable(name: "a", type: "Integer", value: "100 (cache@100)", scope: "main"),
                    Variable(name: "b", type: "Integer", value: "100 (cache@100)", scope: "main"),
                    Variable(name: "c", type: "Integer", value: "200 (heap@x)", scope: "main"),
                 ],
                 callStack: [CallStackFrame(method: "main", line: 5)],
                 heap: [], predict: nil),

            Step(index: 3,
                 narration: "Integer d = 200 も同様に、別の新しい Integer オブジェクトを作成します。",
                 highlightLines: [6],
                 variables: [
                    Variable(name: "c", type: "Integer", value: "200 (heap@x)", scope: "main"),
                    Variable(name: "d", type: "Integer", value: "200 (heap@y)", scope: "main"),
                 ],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "(a == b) と (c == d) はそれぞれ何になる？",
                    choices: ["true / true", "true / false", "false / true", "false / false"],
                    answerIndex: 1,
                    hint: "Integerキャッシュの範囲は -128〜127",
                    afterExplanation: "100 はキャッシュ共有で同じ参照（true）、200 はキャッシュ範囲外で別オブジェクト（false）。出力は \"true false\"。"
                 )),

            Step(index: 4,
                 narration: "println で \"true false\" が出力されます。Wrapper同士の == は危険。値比較は必ず equals() を使う。",
                 highlightLines: [7],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 7)],
                 heap: [], predict: nil),
        ]
    )

    // MARK: - Silver: switchフォールスルー

    static let silverSwitch001 = Explanation(
        id: "explain-silver-switch-001",
        initialCode: """
public class Test {
    public static void main(String[] args) {
        int x = 2;
        switch (x) {
            case 1: System.out.print("A");
            case 2: System.out.print("B");
            case 3: System.out.print("C");
                break;
            case 4: System.out.print("D");
        }
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "x = 2 で switch (x) を評価します。x の値 2 にマッチする case 2: から実行を開始します。",
                 highlightLines: [3, 4],
                 variables: [Variable(name: "x", type: "int", value: "2", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 4)],
                 heap: [], predict: nil),

            Step(index: 1,
                 narration: "case 2: にジャンプ。System.out.print(\"B\") で \"B\" を出力します。",
                 highlightLines: [6],
                 variables: [Variable(name: "x", type: "int", value: "2", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "case 2: の末尾には break がない。次に何が起こる？",
                    choices: ["switch を抜けて終了", "case 3: に流れ落ちる（フォールスルー）", "コンパイルエラー"],
                    answerIndex: 1,
                    hint: "switch文は break で明示的に抜けない限り続く",
                    afterExplanation: "break がない case はそのまま次の case の処理に流れ込みます。これを「フォールスルー」と呼びます。"
                 )),

            Step(index: 2,
                 narration: "break がないため case 3: に流れ落ちます。System.out.print(\"C\") で \"C\" を出力します。",
                 highlightLines: [7],
                 variables: [Variable(name: "x", type: "int", value: "2", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 7)],
                 heap: [], predict: nil),

            Step(index: 3,
                 narration: "case 3: の break; に到達。switch ブロックを抜けます。case 4: には到達しません。\n\n出力結果: \"BC\"",
                 highlightLines: [8],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 8)],
                 heap: [], predict: nil),
        ]
    )

    // MARK: - Gold: Stream API

    static let goldStream001 = Explanation(
        id: "explain-gold-stream-001",
        initialCode: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        List<Integer> nums = List.of(1, 2, 3, 4, 5);
        int result = nums.stream()
            .filter(n -> n % 2 == 0)
            .mapToInt(Integer::intValue)
            .sum();
        System.out.println(result);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "List.of(1, 2, 3, 4, 5) で不変リストを生成。nums がその参照を保持します。",
                 highlightLines: [6],
                 variables: [Variable(name: "nums", type: "List<Integer>", value: "[1, 2, 3, 4, 5]", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [], predict: nil),

            Step(index: 1,
                 narration: "nums.stream() で Stream<Integer> を作成。この時点では何も計算されません（中間操作は遅延評価）。",
                 highlightLines: [7],
                 variables: [Variable(name: "nums", type: "List<Integer>", value: "[1, 2, 3, 4, 5]", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 7)],
                 heap: [], predict: nil),

            Step(index: 2,
                 narration: ".filter(n -> n % 2 == 0) は中間操作。条件「nが偶数」を満たす要素だけ通すパイプラインを構築しますが、まだ実行されません。",
                 highlightLines: [8],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 8)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "filter はこの時点で実行される？",
                    choices: ["される（即評価）", "されない（遅延評価）"],
                    answerIndex: 1,
                    hint: "Streamは終端操作が呼ばれるまで動かない",
                    afterExplanation: "中間操作（filter, map等）はパイプラインを組み立てるだけ。終端操作（sum, collect等）が呼ばれて初めて実行されます。"
                 )),

            Step(index: 3,
                 narration: ".mapToInt(Integer::intValue) で Stream<Integer> を IntStream に変換するパイプラインを追加。これも中間操作で遅延評価。",
                 highlightLines: [9],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 9)],
                 heap: [], predict: nil),

            Step(index: 4,
                 narration: ".sum() は終端操作。ここで初めてパイプライン全体が実行されます。各要素について filter→mapToInt→加算が順に行われます。",
                 highlightLines: [10],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 10)],
                 heap: [], predict: nil),

            Step(index: 5,
                 narration: "実行: 1（奇数→除外）、2（偶数→2）、3（除外）、4（4）、5（除外）。残った [2, 4] を sum して 6 になります。",
                 highlightLines: [10],
                 variables: [Variable(name: "result", type: "int", value: "6", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 10)],
                 heap: [], predict: nil),

            Step(index: 6,
                 narration: "println(6) で \"6\" が出力されます。\n\n出力結果: \"6\"",
                 highlightLines: [11],
                 variables: [Variable(name: "result", type: "int", value: "6", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 11)],
                 heap: [], predict: nil),
        ]
    )

    // MARK: - Gold: Optional

    static let goldOptional001 = Explanation(
        id: "explain-gold-optional-001",
        initialCode: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        String s = null;
        String result = Optional.ofNullable(s)
            .map(String::toUpperCase)
            .orElse("DEFAULT");
        System.out.println(result);
    }
}
""",
        steps: [
            Step(index: 0,
                 narration: "String s = null で s に null を代入します。",
                 highlightLines: [5],
                 variables: [Variable(name: "s", type: "String", value: "null", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 5)],
                 heap: [], predict: nil),

            Step(index: 1,
                 narration: "Optional.ofNullable(s) を呼び出します。s は null ですが、ofNullable は例外を投げず、空の Optional を返します（of(null) なら NPE）。",
                 highlightLines: [6],
                 variables: [Variable(name: "s", type: "String", value: "null", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 6)],
                 heap: [],
                 predict: PredictPrompt(
                    question: "Optional.of(null) と Optional.ofNullable(null) の違いは？",
                    choices: ["どちらも空Optionalを返す", "of(null)はNPE、ofNullable(null)は空Optional", "どちらもNPE"],
                    answerIndex: 1,
                    hint: "of は null を許容しない",
                    afterExplanation: "Optional.of(null) は NullPointerException を投げます。null の可能性がある値には ofNullable() を使う。"
                 )),

            Step(index: 2,
                 narration: ".map(String::toUpperCase) を呼び出し。Optional が空の場合、map は何もせず空の Optional を返します（関数は呼ばれない）。",
                 highlightLines: [7],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 7)],
                 heap: [], predict: nil),

            Step(index: 3,
                 narration: ".orElse(\"DEFAULT\") を呼び出し。Optional が空なので、引数の \"DEFAULT\" がそのまま返されます。result に \"DEFAULT\" が代入されます。",
                 highlightLines: [8],
                 variables: [Variable(name: "result", type: "String", value: "\"DEFAULT\"", scope: "main")],
                 callStack: [CallStackFrame(method: "main", line: 8)],
                 heap: [], predict: nil),

            Step(index: 4,
                 narration: "println で \"DEFAULT\" が出力されます。Optional + map + orElse の組み合わせで、null チェックなしに安全にデフォルト値を返せます。\n\n出力結果: \"DEFAULT\"",
                 highlightLines: [9],
                 variables: [],
                 callStack: [CallStackFrame(method: "main", line: 9)],
                 heap: [], predict: nil),
        ]
    )
}
