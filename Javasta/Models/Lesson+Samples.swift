import Foundation

extension Lesson {
    static let samples: [Lesson] = [
        overloadResolution,
        finallyAndReturn,
        boundedWildcards,
    ]

    static func sample(for id: String) -> Lesson? {
        samples.first(where: { $0.id == id })
    }

    // MARK: - オーバーロード解決

    static let overloadResolution = Lesson(
        id: "lesson-overload-resolution",
        level: .silver,
        category: QuizCategory.overloadResolution.rawValue,
        title: "オーバーロード解決",
        summary: "同名メソッドが複数あるとき、Javaがどれを呼ぶか決定するルール",
        estimatedMinutes: 6,
        sections: [
            Section(
                id: "s1",
                heading: "オーバーロードとは",
                body: "同じクラス内で、名前は同じだが引数の型や数が違うメソッドを定義することをオーバーロードと呼びます。コンパイラはコンパイル時に静的に呼び先を決定します（静的束縛）。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "解決ルールの優先順位",
                body: "Javaは次の順番でオーバーロードを試します。1) 完全一致、2) 型昇格（int→long→float→double）、3) ボクシング（int→Integer）、4) 可変長引数。上位で見つかった時点で確定し、下位は試しません。",
                code: nil,
                highlightLines: [],
                callout: Callout(
                    kind: .exam,
                    text: "試験頻出: 完全一致がある場合、型昇格やボクシングは無視されます。"
                )
            ),
            Section(
                id: "s3",
                heading: "コードで確認",
                body: "次のコードでは print(int) と print(long) の両方が定義されています。print(5) を呼ぶと、5 は int リテラルなので完全一致の print(int) が選ばれます。",
                code: """
public class Test {
    static void print(int x) {
        System.out.println("int: " + x);
    }
    static void print(long x) {
        System.out.println("long: " + x);
    }
    public static void main(String[] args) {
        print(5);   // → "int: 5"
        print(5L);  // → "long: 5"
    }
}
""",
                highlightLines: [9, 10],
                callout: nil
            ),
            Section(
                id: "s4",
                heading: "型昇格 vs ボクシング",
                body: "print(int) を消して print(long) と print(Integer) だけ残すと、5 はまず型昇格で long に揃えられて print(long) が呼ばれます。ボクシングは型昇格より優先度が低い点に注意。",
                code: nil,
                highlightLines: [],
                callout: Callout(
                    kind: .warning,
                    text: "可変長引数は最後の手段。他のすべてが該当しない場合のみ選ばれます。"
                )
            ),
        ],
        keyPoints: [
            "オーバーロードはコンパイル時に静的に解決される",
            "完全一致 > 型昇格 > ボクシング > 可変長引数 の優先順位",
            "完全一致があれば、型昇格は試みられない",
        ],
        relatedQuizIds: ["silver-overload-001"]
    )

    // MARK: - finallyとreturn

    static let finallyAndReturn = Lesson(
        id: "lesson-finally-and-return",
        level: .silver,
        category: QuizCategory.exceptionHandling.rawValue,
        title: "finallyとreturnの落とし穴",
        summary: "tryのreturnはfinallyに上書きされる。例外も握りつぶされる",
        estimatedMinutes: 5,
        sections: [
            Section(
                id: "s1",
                heading: "finallyは必ず実行される",
                body: "try / catch ブロックを抜ける前に、finally ブロックは必ず実行されます。return / break / continue / throw のいずれで抜けても同じです。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "tryのreturnは保留される",
                body: "tryブロック内で return X を実行した瞬間、戻り値Xは一時退避されます。その後 finally が実行され、finally が終わってから初めて呼び出し元に戻ります。",
                code: """
static int calc() {
    try {
        return 1;       // ← 1 を保留して finally へ
    } finally {
        return 2;       // ← 保留中の 1 を上書き！
    }
}
// calc() の戻り値は 2
""",
                highlightLines: [3, 5],
                callout: Callout(
                    kind: .warning,
                    text: "finallyにreturnを書くと、tryのreturn・throwを完全に上書きします。例外すら握りつぶされる。"
                )
            ),
            Section(
                id: "s3",
                heading: "推奨: finallyにはreturn/throwを書かない",
                body: "finallyは「リソース解放」「ログ出力」など副作用専用に使い、戻り値や例外を変更してはいけません。可読性のためにも、tryのreturnを尊重するのがベストプラクティスです。",
                code: nil,
                highlightLines: [],
                callout: Callout(
                    kind: .tip,
                    text: "リソース解放にはfinallyの代わりに try-with-resources を使うとさらに安全。"
                )
            ),
        ],
        keyPoints: [
            "finallyは return/break/throw を貫いて必ず実行される",
            "finallyの return は try の return を上書きする",
            "finallyに return / throw を書くのは原則アンチパターン",
        ],
        relatedQuizIds: ["silver-exception-001"]
    )

    // MARK: - 上限境界ワイルドカード

    static let boundedWildcards = Lesson(
        id: "lesson-bounded-wildcards",
        level: .gold,
        category: QuizCategory.generics.rawValue,
        title: "上限境界ワイルドカード",
        summary: "<? extends T> で「Tまたはそのサブタイプ」を受け取る",
        estimatedMinutes: 8,
        sections: [
            Section(
                id: "s1",
                heading: "ジェネリクスは不変",
                body: "List<Integer> は List<Number> のサブタイプ ではありません。Integer が Number のサブタイプでも、ジェネリクス型自体は不変（invariant）だからです。これが Java ジェネリクスの最大の落とし穴。",
                code: """
List<Integer> ints = ...;
List<Number> nums = ints;  // ❌ コンパイルエラー
""",
                highlightLines: [2],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "<? extends T> で共変にする",
                body: "<? extends Number> と書くと、Number またはそのサブタイプ（Integer, Long, Double等）のリストを受け取れるようになります。これを上限境界ワイルドカード（upper bounded wildcard）と呼びます。",
                code: """
static double sum(List<? extends Number> list) {
    double total = 0;
    for (Number n : list) {
        total += n.doubleValue();
    }
    return total;
}

sum(List.of(1, 2, 3));        // OK: List<Integer>
sum(List.of(1.5, 2.5));       // OK: List<Double>
""",
                highlightLines: [1],
                callout: Callout(
                    kind: .exam,
                    text: "<? extends T> のリストには 読み取り はできるが、null以外の 書き込み はできません（PECSの法則）。"
                )
            ),
            Section(
                id: "s3",
                heading: "PECS: Producer Extends, Consumer Super",
                body: "「データを取り出す（Producer）なら extends、データを入れる（Consumer）なら super」と覚えます。値を読みたい時は <? extends T>、値を入れたい時は <? super T>。",
                code: nil,
                highlightLines: [],
                callout: Callout(
                    kind: .tip,
                    text: "Effective Java の有名な指針。試験でも実務でも頻出。"
                )
            ),
            Section(
                id: "s4",
                heading: "なぜ書き込めない？",
                body: "List<? extends Number> は「Numberのサブタイプ何かのリスト」を意味します。実体が List<Integer> かもしれないし List<Double> かもしれない。安全に追加できる型が決められないため、コンパイラは書き込みを禁止します。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
        ],
        keyPoints: [
            "ジェネリクスは不変。List<Integer> ≠ List<Number>",
            "<? extends T> は T のサブタイプのリストを受け取れる（共変）",
            "<? extends T> からは読み取りのみ可能（書き込み不可）",
            "PECS: Producer Extends, Consumer Super",
        ],
        relatedQuizIds: ["gold-generics-001"]
    )
}
