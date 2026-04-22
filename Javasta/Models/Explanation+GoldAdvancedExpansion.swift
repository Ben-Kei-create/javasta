import Foundation

extension Explanation {
    static let goldAdvancedAuthoredSamples: [String: Explanation] = [
        goldAdvancedStreamTakeWhile001Explanation.id: goldAdvancedStreamTakeWhile001Explanation,
        goldAdvancedStreamDropWhile001Explanation.id: goldAdvancedStreamDropWhile001Explanation,
        goldAdvancedStreamOfNullable001Explanation.id: goldAdvancedStreamOfNullable001Explanation,
        goldAdvancedStreamPeekFindFirst001Explanation.id: goldAdvancedStreamPeekFindFirst001Explanation,
        goldAdvancedCollectorsJoining001Explanation.id: goldAdvancedCollectorsJoining001Explanation,
        goldAdvancedCollectorsPartitioning001Explanation.id: goldAdvancedCollectorsPartitioning001Explanation,
        goldAdvancedMapMerge001Explanation.id: goldAdvancedMapMerge001Explanation,
        goldAdvancedMapComputeIfAbsent001Explanation.id: goldAdvancedMapComputeIfAbsent001Explanation,
        goldAdvancedListCopyOfNull001Explanation.id: goldAdvancedListCopyOfNull001Explanation,
        goldAdvancedUnmodifiableView001Explanation.id: goldAdvancedUnmodifiableView001Explanation,
        goldAdvancedTreeSetComparator001Explanation.id: goldAdvancedTreeSetComparator001Explanation,
        goldAdvancedGenericsSuperRead001Explanation.id: goldAdvancedGenericsSuperRead001Explanation,
        goldAdvancedGenericsExtendsNull001Explanation.id: goldAdvancedGenericsExtendsNull001Explanation,
        goldAdvancedGenericsErasureOverload001Explanation.id: goldAdvancedGenericsErasureOverload001Explanation,
        goldAdvancedLambdaReferenceMutation001Explanation.id: goldAdvancedLambdaReferenceMutation001Explanation,
        goldAdvancedFunctionCompose001Explanation.id: goldAdvancedFunctionCompose001Explanation,
        goldAdvancedMethodReferenceBound001Explanation.id: goldAdvancedMethodReferenceBound001Explanation,
        goldAdvancedOptionalOrElseThrow001Explanation.id: goldAdvancedOptionalOrElseThrow001Explanation,
        goldAdvancedOptionalFilter001Explanation.id: goldAdvancedOptionalFilter001Explanation,
        goldAdvancedDateTimeMonthEnd001Explanation.id: goldAdvancedDateTimeMonthEnd001Explanation,
        goldAdvancedDateTimePeriodBetween001Explanation.id: goldAdvancedDateTimePeriodBetween001Explanation,
        goldAdvancedMessageFormatQuotes001Explanation.id: goldAdvancedMessageFormatQuotes001Explanation,
        goldAdvancedAnnotationDefaultRetention001Explanation.id: goldAdvancedAnnotationDefaultRetention001Explanation,
        goldAdvancedAnnotationRepeatable001Explanation.id: goldAdvancedAnnotationRepeatable001Explanation,
        goldAdvancedExceptionMultiCatchAssign001Explanation.id: goldAdvancedExceptionMultiCatchAssign001Explanation,
        goldAdvancedExceptionCatchOrder001Explanation.id: goldAdvancedExceptionCatchOrder001Explanation,
        goldAdvancedTryResourcesClose001Explanation.id: goldAdvancedTryResourcesClose001Explanation,
        goldAdvancedSerializationStaticTransient001Explanation.id: goldAdvancedSerializationStaticTransient001Explanation,
        goldAdvancedPathResolveSibling001Explanation.id: goldAdvancedPathResolveSibling001Explanation,
        goldAdvancedPathSubpath001Explanation.id: goldAdvancedPathSubpath001Explanation,
    ]

    private static func goldAdvancedStep(
        _ index: Int,
        _ narration: String,
        _ highlightLines: [Int],
        variables: [Variable] = []
    ) -> Step {
        Step(
            index: index,
            narration: narration,
            highlightLines: highlightLines,
            variables: variables,
            callStack: [],
            heap: [],
            predict: nil
        )
    }

    private static func goldAdvancedTrace(
        id: String,
        code: String,
        steps: [(String, [Int], [Variable])]
    ) -> Explanation {
        Explanation(
            id: id,
            initialCode: code,
            steps: steps.enumerated().map { offset, item in
                goldAdvancedStep(offset, item.0, item.1, variables: item.2)
            }
        )
    }

    static let goldAdvancedStreamTakeWhile001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-stream-takewhile-001",
        code: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        long count = Stream.of(1, 2, 3, 2, 1)
            .takeWhile(n -> n < 3)
            .count();
        System.out.println(count);
    }
}
""",
        steps: [
            ("`takeWhile` は `filter` と違い、先頭から条件がtrueで続く間だけ要素を通します。1と2は `n < 3` を満たしますが、3で初めてfalseになります。", [5, 6], [Variable(name: "passed", type: "Stream<Integer>", value: "1, 2", scope: "pipeline")]),
            ("3で条件がfalseになった時点で、後ろの2と1は条件を満たしていても評価対象になりません。`count()` は通過した2要素を数えるため、出力は `2` です。", [6, 7, 8], [Variable(name: "count", type: "long", value: "2", scope: "main")]),
        ]
    )

    static let goldAdvancedStreamDropWhile001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-stream-dropwhile-001",
        code: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        int sum = IntStream.of(1, 2, 3, 2, 1)
            .dropWhile(n -> n < 3)
            .limit(2)
            .sum();
        System.out.println(sum);
    }
}
""",
        steps: [
            ("`dropWhile` は先頭から条件がtrueの間だけ捨てます。1と2は捨てられますが、3で条件がfalseになった後は、後続の2や1も残ります。", [5, 6], [Variable(name: "after dropWhile", type: "IntStream", value: "3, 2, 1", scope: "pipeline")]),
            ("`limit(2)` により残った要素の先頭2件、つまり3と2だけが `sum()` に渡ります。合計は `5` です。", [7, 8, 9], [Variable(name: "sum", type: "int", value: "5", scope: "main")]),
        ]
    )

    static let goldAdvancedStreamOfNullable001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-stream-ofnullable-001",
        code: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        long a = Stream.ofNullable(null).count();
        long b = Stream.ofNullable("x").count();
        System.out.println(a + ":" + b);
    }
}
""",
        steps: [
            ("`Stream.ofNullable(null)` はnull要素を1つ持つStreamではなく、空Streamを返します。したがって `a` は0です。", [5], [Variable(name: "a", type: "long", value: "0", scope: "main")]),
            ("非nullの `\"x\"` は1要素のStreamになります。`b` は1なので、連結表示は `0:1` です。", [6, 7], [Variable(name: "b", type: "long", value: "1", scope: "main"), Variable(name: "output", type: "String", value: "0:1", scope: "main")]),
        ]
    )

    static let goldAdvancedStreamPeekFindFirst001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-stream-peek-findfirst-001",
        code: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        Optional<String> result = Stream.of("a", "bb", "ccc")
            .peek(s -> System.out.print(s.length()))
            .filter(s -> s.length() > 1)
            .findFirst();
        System.out.println(":" + result.get());
    }
}
""",
        steps: [
            ("終端操作は `findFirst()` です。最初の要素 `a` は `peek` で長さ1を出力したあと、`filter` でfalseになります。", [6, 7, 8], [Variable(name: "printed so far", type: "String", value: "1", scope: "pipeline")]),
            ("次の `bb` は `peek` で2を出力し、filterを通過します。`findFirst` はここで結果を得るため `ccc` までは進みません。最後に `:bb` が出力され、全体は `12:bb` です。", [7, 8, 9, 10], [Variable(name: "result", type: "Optional<String>", value: "Optional[bb]", scope: "main")]),
        ]
    )

    static let goldAdvancedCollectorsJoining001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-collectors-joining-001",
        code: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        String text = Stream.of("b", "a")
            .sorted()
            .collect(Collectors.joining(",", "[", "]"));
        System.out.println(text);
    }
}
""",
        steps: [
            ("元の遭遇順はb,aですが、`sorted()` により自然順のa,bへ並び替えられます。", [5, 6], [Variable(name: "after sorted", type: "Stream<String>", value: "a, b", scope: "pipeline")]),
            ("`Collectors.joining(\",\", \"[\", \"]\")` は、区切り文字`,`、prefix`[`、suffix`]`で文字列化します。結果は `[a,b]` です。", [7, 8], [Variable(name: "text", type: "String", value: "[a,b]", scope: "main")]),
        ]
    )

    static let goldAdvancedCollectorsPartitioning001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-collectors-partitioning-001",
        code: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        Map<Boolean, Long> map = Stream.of("a", "bb", "c")
            .collect(Collectors.partitioningBy(
                s -> s.length() > 1,
                Collectors.counting()
            ));
        System.out.println(map.get(true) + ":" + map.get(false));
    }
}
""",
        steps: [
            ("`partitioningBy` はPredicateの結果でtrue側とfalse側へ分けます。長さが1より大きいのは `bb` だけなのでtrue側は1件です。", [6, 7, 8], [Variable(name: "true group", type: "long", value: "1", scope: "collector")]),
            ("`a` と `c` はfalse側です。下流Collectorが `counting()` なので値はListではなく件数のLongです。出力は `1:2` です。", [9, 11], [Variable(name: "false group", type: "long", value: "2", scope: "collector")]),
        ]
    )

    static let goldAdvancedMapMerge001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-map-merge-001",
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Map<String, Integer> map = new HashMap<>();
        map.put("a", 1);
        map.merge("a", 2, Integer::sum);
        map.merge("b", 3, Integer::sum);
        System.out.println(map.get("a") + ":" + map.get("b"));
    }
}
""",
        steps: [
            ("`a` には既に1が入っています。`merge(\"a\", 2, Integer::sum)` は既存値1と新しい値2を合成し、3を保存します。", [6, 7], [Variable(name: "map[a]", type: "Integer", value: "3", scope: "main")]),
            ("`b` は未存在キーなので、remapping関数は使わず3がそのまま登録されます。したがって出力は `3:3` です。", [8, 9], [Variable(name: "map[b]", type: "Integer", value: "3", scope: "main")]),
        ]
    )

    static let goldAdvancedMapComputeIfAbsent001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-map-computeifabsent-001",
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Map<String, String> map = new HashMap<>();
        map.put("a", null);
        String value = map.computeIfAbsent("a", k -> "x");
        System.out.println(value + ":" + map.get("a"));
    }
}
""",
        steps: [
            ("`computeIfAbsent` は、キーが存在しない場合だけでなく、キーが存在しても対応する値がnullの場合にマッピング関数を実行します。", [6, 7], [Variable(name: "map[a] before", type: "String", value: "null", scope: "main")]),
            ("ラムダ `k -> \"x\"` の戻り値はnullではないため、`a` に `x` が関連付けられます。戻り値もMap内の値もxなので `x:x` です。", [7, 8], [Variable(name: "value", type: "String", value: "x", scope: "main"), Variable(name: "map[a] after", type: "String", value: "x", scope: "main")]),
        ]
    )

    static let goldAdvancedListCopyOfNull001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-list-copyof-null-001",
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        try {
            List<String> list = List.copyOf(Arrays.asList("a", null));
            System.out.println(list.size());
        } catch (NullPointerException e) {
            System.out.println("NPE");
        }
    }
}
""",
        steps: [
            ("`Arrays.asList(\"a\", null)` 自体はnull要素を含むリストを作れます。しかし `List.copyOf` は変更不可リストを作る際にnull要素を拒否します。", [5, 6], [Variable(name: "source", type: "List<String>", value: "[a, null]", scope: "try")]),
            ("コピー作成時に `NullPointerException` が発生するため、`list.size()` には到達しません。catch側で `NPE` が出力されます。", [6, 7, 8, 9], [Variable(name: "output", type: "String", value: "NPE", scope: "catch")]),
        ]
    )

    static let goldAdvancedUnmodifiableView001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-unmodifiable-view-001",
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> base = new ArrayList<>();
        base.add("a");
        List<String> view = Collections.unmodifiableList(base);
        base.add("b");
        System.out.println(view.size());
    }
}
""",
        steps: [
            ("`Collections.unmodifiableList(base)` は防御的コピーではなく、`base` を包む変更不可ビューを返します。`view` 経由の変更はできませんが、元の `base` は同じオブジェクトです。", [5, 6, 7], [Variable(name: "base", type: "ArrayList<String>", value: "[a]", scope: "main")]),
            ("その後 `base.add(\"b\")` で元リストが変更されます。ビューは元リストを見ているためサイズは2になり、出力は `2` です。", [8, 9], [Variable(name: "view.size()", type: "int", value: "2", scope: "main")]),
        ]
    )

    static let goldAdvancedTreeSetComparator001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-treeset-comparator-001",
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Set<String> set = new TreeSet<>(Comparator.comparingInt(String::length));
        set.add("aa");
        set.add("bb");
        set.add("c");
        System.out.println(set.size() + ":" + set.contains("bb"));
    }
}
""",
        steps: [
            ("このTreeSetの比較規則は文字列の長さです。`aa` と `bb` はどちらも長さ2なので、Comparatorの比較結果は0になり、重複扱いです。", [5, 6, 7], [Variable(name: "set", type: "TreeSet<String>", value: "aa, c", scope: "main")]),
            ("`contains(\"bb\")` も同じComparatorで探索します。実際に格納された文字列がaaでも、長さ2の要素があるためtrueと判定されます。出力は `2:true` です。", [8, 9], [Variable(name: "contains bb", type: "boolean", value: "true", scope: "main")]),
        ]
    )

    static let goldAdvancedGenericsSuperRead001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-generics-super-read-001",
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<? super Integer> list = new ArrayList<Number>();
        list.add(10);
        Object value = list.get(0);
        System.out.println(value.getClass().getSimpleName());
    }
}
""",
        steps: [
            ("`? super Integer` はIntegerまたはそのスーパータイプのリストを表すため、`Integer` 値の追加は安全です。`10` はIntegerとして格納されます。", [5, 6], [Variable(name: "list content", type: "ArrayList<Number>", value: "[Integer(10)]", scope: "main")]),
            ("読み出し時に安全に言える型はObjectです。`value` の静的型はObjectですが、実体はIntegerなので `getClass().getSimpleName()` は `Integer` です。", [7, 8], [Variable(name: "value runtime type", type: "Class", value: "Integer", scope: "main")]),
        ]
    )

    static let goldAdvancedGenericsExtendsNull001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-generics-extends-null-001",
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<? extends Number> list = new ArrayList<Integer>();
        list.add(null);
        System.out.println(list.size());
    }
}
""",
        steps: [
            ("`List<? extends Number>` には `Integer` や `Double` など具体的な非null値を安全に追加できません。実体がどのサブタイプのリストか分からないためです。", [5], [Variable(name: "list type", type: "List<? extends Number>", value: "unknown subtype", scope: "main")]),
            ("ただし `null` はどの参照型にも代入可能なので例外的に追加できます。ArrayListはnullを許容するため、サイズは1になります。", [6, 7], [Variable(name: "list.size()", type: "int", value: "1", scope: "main")]),
        ]
    )

    static let goldAdvancedGenericsErasureOverload001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-generics-erasure-overload-001",
        code: """
import java.util.*;

public class Test {
    static void print(List<String> values) {}
    static void print(List<Integer> values) {}
}
""",
        steps: [
            ("Javaジェネリクスは型消去されます。`List<String>` と `List<Integer>` の型引数部分は、メソッドシグネチャの実行時表現としては区別されません。", [4, 5], [Variable(name: "erased signature", type: "method", value: "print(List)", scope: "compiler")]),
            ("そのため2つの `print` は消去後に同じ `print(List)` となり、同一クラス内で名前衝突します。コンパイルエラーです。", [4, 5], [Variable(name: "result", type: "compile-time", value: "name clash", scope: "compiler")]),
        ]
    )

    static let goldAdvancedLambdaReferenceMutation001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-lambda-reference-mutation-001",
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>();
        Runnable r = () -> list.add("x");
        list.add("y");
        r.run();
        System.out.println(list);
    }
}
""",
        steps: [
            ("ラムダから参照されるローカル変数 `list` は、再代入されていないため実質的finalです。参照先のArrayListの中身を変更することは、実質的final違反ではありません。", [5, 6], [Variable(name: "list variable", type: "local", value: "effectively final", scope: "main")]),
            ("ラムダは定義時には実行されません。先に `list.add(\"y\")` が実行され、`r.run()` で `x` が追加されるため、出力は `[y, x]` です。", [7, 8, 9], [Variable(name: "list", type: "ArrayList<String>", value: "[y, x]", scope: "main")]),
        ]
    )

    static let goldAdvancedFunctionCompose001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-function-compose-001",
        code: """
import java.util.function.*;

public class Test {
    public static void main(String[] args) {
        Function<Integer, Integer> add = n -> n + 1;
        Function<Integer, Integer> dbl = n -> n * 2;
        System.out.println(
            add.compose(dbl).apply(3) + ":" + add.andThen(dbl).apply(3)
        );
    }
}
""",
        steps: [
            ("`add.compose(dbl)` は、まず `dbl` を実行し、その結果へ `add` を実行します。3を2倍して6、そこへ1を足して7です。", [5, 6, 8], [Variable(name: "compose result", type: "Integer", value: "7", scope: "main")]),
            ("`add.andThen(dbl)` は、まず `add`、次に `dbl` です。3に1を足して4、それを2倍して8です。出力は `7:8` です。", [8], [Variable(name: "andThen result", type: "Integer", value: "8", scope: "main")]),
        ]
    )

    static let goldAdvancedMethodReferenceBound001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-method-reference-bound-001",
        code: """
import java.util.function.*;

public class Test {
    public static void main(String[] args) {
        Function<String, String> trim = String::trim;
        Supplier<String> fixed = " x "::trim;
        System.out.println(trim.apply(" y ") + ":" + fixed.get());
    }
}
""",
        steps: [
            ("`String::trim` はレシーバを引数として受け取る非束縛メソッド参照なので、`Function<String, String>` に適合します。`trim.apply(\" y \")` は `y` です。", [5, 7], [Variable(name: "left", type: "String", value: "y", scope: "main")]),
            ("`\" x \"::trim` はレシーバが固定された束縛済みメソッド参照です。引数なしでStringを返すため `Supplier<String>` に適合し、結果は `x` です。出力は `y:x` です。", [6, 7], [Variable(name: "right", type: "String", value: "x", scope: "main")]),
        ]
    )

    static let goldAdvancedOptionalOrElseThrow001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-optional-orelsethrow-001",
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        String value = Optional.of("ok")
            .orElseThrow(() -> {
                System.out.print("X");
                return new RuntimeException();
            });
        System.out.println(value);
    }
}
""",
        steps: [
            ("`Optional.of(\"ok\")` は値を持っています。`orElseThrow` のSupplierは、Optionalが空の場合だけ例外を生成するために実行されます。", [5, 6], [Variable(name: "optional", type: "Optional<String>", value: "Optional[ok]", scope: "main")]),
            ("今回は値があるため、ラムダ内の `System.out.print(\"X\")` は実行されません。`value` は `ok` になり、出力は `ok` だけです。", [7, 10], [Variable(name: "value", type: "String", value: "ok", scope: "main")]),
        ]
    )

    static let goldAdvancedOptionalFilter001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-optional-filter-001",
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        String value = Optional.of("java")
            .filter(s -> s.length() > 4)
            .orElse("none");
        System.out.println(value);
    }
}
""",
        steps: [
            ("`Optional.of(\"java\")` の値は存在しますが、`filter` の条件 `s.length() > 4` を満たす必要があります。`java` の長さは4なので条件はfalseです。", [5, 6], [Variable(name: "filter result", type: "Optional<String>", value: "Optional.empty", scope: "pipeline")]),
            ("filterで空Optionalになったため、`orElse(\"none\")` の代替値が使われます。出力は `none` です。", [7, 8], [Variable(name: "value", type: "String", value: "none", scope: "main")]),
        ]
    )

    static let goldAdvancedDateTimeMonthEnd001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-datetime-month-end-001",
        code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        LocalDate date = LocalDate.of(2024, 1, 31)
            .plusMonths(1)
            .plusDays(1);
        System.out.println(date);
    }
}
""",
        steps: [
            ("`2024-01-31.plusMonths(1)` では、2024年2月31日は存在しないため月末の有効日へ調整されます。2024年はうるう年なので `2024-02-29` です。", [5, 6], [Variable(name: "after plusMonths", type: "LocalDate", value: "2024-02-29", scope: "main")]),
            ("そこへ `plusDays(1)` を適用すると翌日の `2024-03-01` になります。LocalDateは不変ですが、メソッドチェーンの戻り値がdateへ代入されています。", [7, 8], [Variable(name: "date", type: "LocalDate", value: "2024-03-01", scope: "main")]),
        ]
    )

    static let goldAdvancedDateTimePeriodBetween001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-datetime-period-between-001",
        code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        Period p = Period.between(
            LocalDate.of(2024, 2, 28),
            LocalDate.of(2024, 3, 1)
        );
        System.out.println(p + ":" + p.getDays());
    }
}
""",
        steps: [
            ("`Period.between` は開始日を含まず終了日へ到達するまでの日付ベースの差を表します。2024年はうるう年なので、2月28日から3月1日までは2日です。", [5, 6, 7], [Variable(name: "p", type: "Period", value: "P2D", scope: "main")]),
            ("Periodの文字列表現は `P2D` で、日成分 `getDays()` は2です。出力は `P2D:2` です。", [9], [Variable(name: "output", type: "String", value: "P2D:2", scope: "main")]),
        ]
    )

    static let goldAdvancedMessageFormatQuotes001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-messageformat-quotes-001",
        code: """
import java.text.*;

public class Test {
    public static void main(String[] args) {
        String text = MessageFormat.format("'{0}' {0}", "A");
        System.out.println(text);
    }
}
""",
        steps: [
            ("MessageFormatでは単一引用符がパターン内のクォートに使われます。`'{0}'` の中の `{0}` はプレースホルダではなく、リテラル文字列として扱われます。", [5], [Variable(name: "quoted part", type: "String", value: "{0}", scope: "format")]),
            ("後半の `{0}` は通常のプレースホルダなので `A` に置換されます。単一引用符自体は出力されず、結果は `{0} A` です。", [5, 6], [Variable(name: "text", type: "String", value: "{0} A", scope: "main")]),
        ]
    )

    static let goldAdvancedAnnotationDefaultRetention001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-annotation-default-retention-001",
        code: """
@interface Tags {
    String[] value() default {};
}

@Tags({"a", "b"})
class Service {}

public class Test {
    public static void main(String[] args) {
        System.out.println(Service.class.getAnnotation(Tags.class) == null);
    }
}
""",
        steps: [
            ("`Tags` には `@Retention` が付いていません。アノテーションの保持はデフォルトでCLASS相当であり、通常の実行時リフレクションでは取得できません。", [1, 5], [Variable(name: "retention", type: "RetentionPolicy", value: "CLASS(default)", scope: "Tags")]),
            ("`Service.class.getAnnotation(Tags.class)` は実行時に見えるアノテーションを探すため、結果はnullです。`== null` はtrueなので `true` が出力されます。", [10], [Variable(name: "annotation", type: "Tags", value: "null", scope: "main")]),
        ]
    )

    static let goldAdvancedAnnotationRepeatable001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-annotation-repeatable-001",
        code: """
import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)
@Repeatable(Roles.class)
@interface Role {
    String value();
}

@Retention(RetentionPolicy.RUNTIME)
@interface Roles {
    Role[] value();
}

@Role("A")
@Role("B")
class Service {}

public class Test {
    public static void main(String[] args) {
        System.out.println(Service.class.getAnnotationsByType(Role.class).length);
    }
}
""",
        steps: [
            ("`Role` は `@Repeatable(Roles.class)` を持ち、コンテナ `Roles` は `Role[] value()` を定義しています。どちらもRUNTIME保持なので実行時に読めます。", [3, 4, 9, 10, 11], [Variable(name: "container", type: "Annotation", value: "Roles", scope: "Role")]),
            ("`Service` には `@Role` が2回付いています。`getAnnotationsByType(Role.class)` は繰り返しアノテーションを展開して返すため、配列長は2です。", [14, 15, 20], [Variable(name: "length", type: "int", value: "2", scope: "main")]),
        ]
    )

    static let goldAdvancedExceptionMultiCatchAssign001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-exception-multicatch-assign-001",
        code: """
import java.io.*;
import java.sql.*;

public class Test {
    static void run() throws IOException, SQLException {}
    public static void main(String[] args) {
        try {
            run();
        } catch (IOException | SQLException e) {
            e = new IOException();
        }
    }
}
""",
        steps: [
            ("`run()` はIOExceptionとSQLExceptionを投げ得るため、`catch (IOException | SQLException e)` で捕捉する形自体は有効です。", [5, 7, 8, 9], [Variable(name: "catch alternatives", type: "multi-catch", value: "IOException | SQLException", scope: "compiler")]),
            ("しかしマルチキャッチのcatchパラメータは暗黙的にfinalです。`e = new IOException();` の再代入は許されず、コンパイルエラーになります。", [9, 10], [Variable(name: "result", type: "compile-time", value: "cannot assign to e", scope: "compiler")]),
        ]
    )

    static let goldAdvancedExceptionCatchOrder001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-exception-catch-order-001",
        code: """
import java.io.*;

public class Test {
    public static void main(String[] args) {
        try {
            throw new IOException();
        } catch (Exception e) {
            System.out.println("E");
        } catch (IOException e) {
            System.out.println("IO");
        }
    }
}
""",
        steps: [
            ("`IOException` は `Exception` のサブクラスです。先に `catch (Exception e)` があると、IOExceptionも必ずそこで捕捉されます。", [6, 7], [Variable(name: "hierarchy", type: "class", value: "IOException extends Exception", scope: "compiler")]),
            ("そのため後続の `catch (IOException e)` は到達不能です。Javaでは到達不能なcatchブロックはコンパイルエラーになります。", [7, 9], [Variable(name: "result", type: "compile-time", value: "unreachable catch", scope: "compiler")]),
        ]
    )

    static let goldAdvancedTryResourcesClose001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-try-resources-close-001",
        code: """
class R implements AutoCloseable {
    public void close() {
        System.out.print("C");
    }
}

public class Test {
    public static void main(String[] args) {
        try (R r = new R()) {
            System.out.print("B");
        }
        System.out.print("A");
    }
}
""",
        steps: [
            ("try-with-resourcesでは、まずtry本体が実行されます。ここで `B` が出力されます。", [9, 10], [Variable(name: "output so far", type: "String", value: "B", scope: "main")]),
            ("tryブロックを抜けるときにリソース `r` の `close()` が呼ばれて `C` が出ます。その後、後続文で `A` が出るため、全体は `BCA` です。", [2, 3, 11, 12], [Variable(name: "output", type: "String", value: "BCA", scope: "main")]),
        ]
    )

    static let goldAdvancedSerializationStaticTransient001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-serialization-static-transient-001",
        code: """
import java.io.*;

class Box implements Serializable {
    private static final long serialVersionUID = 1L;
    static String shared = "S";
    transient String temp = "T";
    String value = "V";
}

public class Test {
    public static void main(String[] args) throws Exception {
        Box box = new Box();
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        try (ObjectOutputStream out = new ObjectOutputStream(bout)) {
            out.writeObject(box);
        }
        Box.shared = "X";
        try (ObjectInputStream in = new ObjectInputStream(
                new ByteArrayInputStream(bout.toByteArray()))) {
            Box copy = (Box) in.readObject();
            System.out.println(copy.value + ":" + copy.temp + ":" + Box.shared);
        }
    }
}
""",
        steps: [
            ("シリアライズされるのはインスタンス状態です。`value` は通常フィールドなので `V` が保存されます。一方、`transient temp` は保存対象外です。", [5, 6, 7, 14, 15], [Variable(name: "serialized value", type: "String", value: "value=V, temp excluded", scope: "stream")]),
            ("`shared` はstaticフィールドなのでシリアライズ対象ではなく、現在のクラス変数の値を見ます。復元前に `Box.shared = \"X\"` としているため、出力は `V:null:X` です。", [17, 20, 21], [Variable(name: "output", type: "String", value: "V:null:X", scope: "main")]),
        ]
    )

    static let goldAdvancedPathResolveSibling001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-path-resolve-sibling-001",
        code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path path = Path.of("/a/b/c.txt");
        System.out.println(path.resolveSibling("d.txt"));
    }
}
""",
        steps: [
            ("`path` は `/a/b/c.txt` です。親は `/a/b`、ファイル名部分は `c.txt` です。", [5], [Variable(name: "parent", type: "Path", value: "/a/b", scope: "main")]),
            ("`resolveSibling(\"d.txt\")` は同じ親ディレクトリの兄弟パスとして解決します。`c.txt/d.txt` ではなく、`/a/b/d.txt` です。", [6], [Variable(name: "result", type: "Path", value: "/a/b/d.txt", scope: "main")]),
        ]
    )

    static let goldAdvancedPathSubpath001Explanation = goldAdvancedTrace(
        id: "explain-gold-advanced-path-subpath-001",
        code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path path = Path.of("/a/b/c");
        System.out.println(path.subpath(0, 2));
    }
}
""",
        steps: [
            ("絶対パス `/a/b/c` のrootは `/` ですが、`subpath` が扱うのは名前要素です。名前要素は `a`, `b`, `c` の3つです。", [5], [Variable(name: "name elements", type: "Path", value: "a, b, c", scope: "main")]),
            ("`subpath(0, 2)` は開始0を含み、終了2を含みません。したがって名前要素0と1、つまり `a/b` が出力されます。rootの `/` は含まれません。", [6], [Variable(name: "result", type: "Path", value: "a/b", scope: "main")]),
        ]
    )
}
