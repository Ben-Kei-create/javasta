import Foundation

extension QuizExpansion {
    static let goldAdvancedExpansion: [Quiz] = [
        goldAdvancedStreamTakeWhile001,
        goldAdvancedStreamDropWhile001,
        goldAdvancedStreamOfNullable001,
        goldAdvancedStreamPeekFindFirst001,
        goldAdvancedCollectorsJoining001,
        goldAdvancedCollectorsPartitioning001,
        goldAdvancedMapMerge001,
        goldAdvancedMapComputeIfAbsent001,
        goldAdvancedListCopyOfNull001,
        goldAdvancedUnmodifiableView001,
        goldAdvancedTreeSetComparator001,
        goldAdvancedGenericsSuperRead001,
        goldAdvancedGenericsExtendsNull001,
        goldAdvancedGenericsErasureOverload001,
        goldAdvancedLambdaReferenceMutation001,
        goldAdvancedFunctionCompose001,
        goldAdvancedMethodReferenceBound001,
        goldAdvancedOptionalOrElseThrow001,
        goldAdvancedOptionalFilter001,
        goldAdvancedDateTimeMonthEnd001,
        goldAdvancedDateTimePeriodBetween001,
        goldAdvancedMessageFormatQuotes001,
        goldAdvancedAnnotationDefaultRetention001,
        goldAdvancedAnnotationRepeatable001,
        goldAdvancedExceptionMultiCatchAssign001,
        goldAdvancedExceptionCatchOrder001,
        goldAdvancedTryResourcesClose001,
        goldAdvancedSerializationStaticTransient001,
        goldAdvancedPathResolveSibling001,
        goldAdvancedPathSubpath001,
    ]

    static let goldAdvancedStreamTakeWhile001 = Quiz(
        id: "gold-advanced-stream-takewhile-001",
        level: .gold,
        difficulty: .tricky,
        category: "lambda-streams",
        tags: ["Stream", "takeWhile", "short-circuit"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2", correct: true, misconception: nil, explanation: "takeWhileは条件が初めてfalseになる直前までを通します。1,2だけが対象です。"),
            Choice(id: "b", text: "4", correct: false, misconception: "filterと同じく全要素から条件一致を数えると誤解", explanation: "後半の2,1は条件を満たしますが、3で処理が止まった後なので流れません。"),
            Choice(id: "c", text: "5", correct: false, misconception: "takeWhileを制限なしの通過操作と誤解", explanation: "3で条件がfalseになった時点で以降は打ち切られます。"),
            Choice(id: "d", text: "0", correct: false, misconception: "終端操作がないと誤解", explanation: "count() が終端操作なのでパイプラインは実行されます。"),
        ],
        explanationRef: "explain-gold-advanced-stream-takewhile-001",
        designIntent: "takeWhileはfilterではなく、先頭から条件が続く間だけ通す短絡的な中間操作であることを確認する。"
    )

    static let goldAdvancedStreamDropWhile001 = Quiz(
        id: "gold-advanced-stream-dropwhile-001",
        level: .gold,
        difficulty: .tricky,
        category: "lambda-streams",
        tags: ["IntStream", "dropWhile", "limit"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "3", correct: false, misconception: "dropWhile後に3だけが残ると誤解", explanation: "dropWhileは3以降の要素を残すため、3,2,1が残ります。"),
            Choice(id: "b", text: "5", correct: true, misconception: nil, explanation: "1,2が捨てられ、3,2,1が残ります。limit(2)で3と2になり、合計は5です。"),
            Choice(id: "c", text: "6", correct: false, misconception: "limit(2)を見落とし", explanation: "dropWhile後の3,2,1すべてを合計するのではなく、先頭2件だけです。"),
            Choice(id: "d", text: "9", correct: false, misconception: "dropWhileをfilterの逆と誤解", explanation: "条件を満たす全要素を削除するのではなく、先頭から条件が続く間だけ削除します。"),
        ],
        explanationRef: "explain-gold-advanced-stream-dropwhile-001",
        designIntent: "dropWhileとfilterの違い、およびlimitとの組み合わせを確認する。"
    )

    static let goldAdvancedStreamOfNullable001 = Quiz(
        id: "gold-advanced-stream-ofnullable-001",
        level: .gold,
        difficulty: .standard,
        category: "lambda-streams",
        tags: ["Stream", "ofNullable", "null"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "0:1", correct: true, misconception: nil, explanation: "ofNullable(null)は空Stream、ofNullable(\"x\")は1要素のStreamを返します。"),
            Choice(id: "b", text: "1:1", correct: false, misconception: "nullを要素として含むStreamになると誤解", explanation: "ofNullableはnullなら空Streamにします。"),
            Choice(id: "c", text: "NullPointerException", correct: false, misconception: "Stream生成時にnullを拒否すると誤解", explanation: "ofNullableはnullを安全に空Streamへ変換するAPIです。"),
            Choice(id: "d", text: "0:0", correct: false, misconception: "ofNullableが常に空Streamを返すと誤解", explanation: "非null値は1要素として流れます。"),
        ],
        explanationRef: "explain-gold-advanced-stream-ofnullable-001",
        designIntent: "Stream.ofNullableのnull/非nullでの要素数を確認する。"
    )

    static let goldAdvancedStreamPeekFindFirst001 = Quiz(
        id: "gold-advanced-stream-peek-findfirst-001",
        level: .gold,
        difficulty: .tricky,
        category: "lambda-streams",
        tags: ["Stream", "peek", "findFirst", "short-circuit"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "123:bb", correct: false, misconception: "findFirstでも全要素がpeekされると誤解", explanation: "bbが条件を満たした時点でfindFirstは結果を得るため、cccまでは処理されません。"),
            Choice(id: "b", text: "12:bb", correct: true, misconception: nil, explanation: "aで1を出力してfilter失敗、bbで2を出力してfilter成功し、findFirstで停止します。"),
            Choice(id: "c", text: ":bb", correct: false, misconception: "peekが実行されないと誤解", explanation: "終端操作findFirstがあるため、必要な要素にはpeekが実行されます。"),
            Choice(id: "d", text: "12:ccc", correct: false, misconception: "最後に条件を満たす要素を返すと誤解", explanation: "findFirstは最初に条件を満たすbbを返します。"),
        ],
        explanationRef: "explain-gold-advanced-stream-peek-findfirst-001",
        designIntent: "peekの実行タイミングとfindFirstの短絡評価を確認する。"
    )

    static let goldAdvancedCollectorsJoining001 = Quiz(
        id: "gold-advanced-collectors-joining-001",
        level: .gold,
        difficulty: .standard,
        category: "lambda-streams",
        tags: ["Collectors", "joining", "sorted"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "[a,b]", correct: true, misconception: nil, explanation: "sortedでa,bになり、joiningのdelimiterがカンマ、prefixが[、suffixが]です。"),
            Choice(id: "b", text: "[b,a]", correct: false, misconception: "sortedを見落とし", explanation: "Stream.ofの遭遇順はb,aですが、sortedで自然順に変わります。"),
            Choice(id: "c", text: "a,b", correct: false, misconception: "prefix/suffixを見落とし", explanation: "joining(\",\", \"[\", \"]\") は前後に角括弧を付けます。"),
            Choice(id: "d", text: "[ab]", correct: false, misconception: "delimiterを見落とし", explanation: "区切り文字としてカンマが挿入されます。"),
        ],
        explanationRef: "explain-gold-advanced-collectors-joining-001",
        designIntent: "Collectors.joiningの3引数とsortedの順序を確認する。"
    )

    static let goldAdvancedCollectorsPartitioning001 = Quiz(
        id: "gold-advanced-collectors-partitioning-001",
        level: .gold,
        difficulty: .standard,
        category: "lambda-streams",
        tags: ["Collectors", "partitioningBy", "counting"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1:2", correct: true, misconception: nil, explanation: "長さが2より大きいではなく1より大きい条件です。bbだけがtrue、aとcがfalseです。"),
            Choice(id: "b", text: "2:1", correct: false, misconception: "true/falseのグループを逆に読んでいる", explanation: "true側は長さが1より大きい要素、つまりbbだけです。"),
            Choice(id: "c", text: "1:1", correct: false, misconception: "false側の要素数を1つ落としている", explanation: "aとcの2つがfalse側です。"),
            Choice(id: "d", text: "3:0", correct: false, misconception: "partitioningByを全件trueと誤解", explanation: "Predicateの結果でtrue/falseに分かれます。"),
        ],
        explanationRef: "explain-gold-advanced-collectors-partitioning-001",
        designIntent: "partitioningByのBooleanキーと下流countingの戻り値を確認する。"
    )

    static let goldAdvancedMapMerge001 = Quiz(
        id: "gold-advanced-map-merge-001",
        level: .gold,
        difficulty: .standard,
        category: "collections",
        tags: ["Map", "merge", "BiFunction"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1:3", correct: false, misconception: "既存キーではmergeが何もしないと誤解", explanation: "既存値がある場合は、既存値と新しい値をremapping関数へ渡します。"),
            Choice(id: "b", text: "2:3", correct: false, misconception: "既存キーが常に上書きされると誤解", explanation: "mergeは上書きではなく、指定した関数で1と2を合成します。"),
            Choice(id: "c", text: "3:3", correct: true, misconception: nil, explanation: "aは1+2で3、bは既存値がないため3がそのまま入ります。"),
            Choice(id: "d", text: "NullPointerException", correct: false, misconception: "未存在キーのmergeで例外になると誤解", explanation: "キーbには値3が新規登録されます。"),
        ],
        explanationRef: "explain-gold-advanced-map-merge-001",
        designIntent: "Map.mergeの既存キーと未存在キーでの動作を確認する。"
    )

    static let goldAdvancedMapComputeIfAbsent001 = Quiz(
        id: "gold-advanced-map-computeifabsent-001",
        level: .gold,
        difficulty: .tricky,
        category: "collections",
        tags: ["Map", "computeIfAbsent", "null"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "null:null", correct: false, misconception: "キーが存在すれば計算されないと誤解", explanation: "computeIfAbsentはキーがない場合だけでなく、値がnullの場合にも関数を実行します。"),
            Choice(id: "b", text: "x:x", correct: true, misconception: nil, explanation: "aは存在しますが値がnullなので、マッピング関数が実行されxが格納されます。"),
            Choice(id: "c", text: "x:null", correct: false, misconception: "戻り値だけがxでMapは更新されないと誤解", explanation: "関数の戻り値がnullでなければMapに関連付けられます。"),
            Choice(id: "d", text: "NullPointerException", correct: false, misconception: "HashMapがnull値を許容しないと誤解", explanation: "HashMapはnull値を許容します。"),
        ],
        explanationRef: "explain-gold-advanced-map-computeifabsent-001",
        designIntent: "computeIfAbsentは値がnullの既存キーでも計算することを確認する。"
    )

    static let goldAdvancedListCopyOfNull001 = Quiz(
        id: "gold-advanced-list-copyof-null-001",
        level: .gold,
        difficulty: .standard,
        category: "collections",
        tags: ["List.copyOf", "null", "immutable"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2", correct: false, misconception: "Arrays.asListと同じくnullを許容すると誤解", explanation: "List.copyOfで作る変更不可リストはnull要素を拒否します。"),
            Choice(id: "b", text: "1", correct: false, misconception: "nullだけが除外されると誤解", explanation: "nullは無視されず、例外になります。"),
            Choice(id: "c", text: "NPE", correct: true, misconception: nil, explanation: "コピー作成時にnull要素が検出され、NullPointerExceptionが発生します。"),
            Choice(id: "d", text: "UnsupportedOperationException", correct: false, misconception: "変更不可リストへの変更と混同", explanation: "今回は変更操作ではなく、生成時のnull拒否です。"),
        ],
        explanationRef: "explain-gold-advanced-list-copyof-null-001",
        designIntent: "List.copyOfがnull要素を許容しないことを確認する。"
    )

    static let goldAdvancedUnmodifiableView001 = Quiz(
        id: "gold-advanced-unmodifiable-view-001",
        level: .gold,
        difficulty: .tricky,
        category: "collections",
        tags: ["Collections", "unmodifiableList", "view"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1", correct: false, misconception: "unmodifiableListが防御的コピーを作ると誤解", explanation: "unmodifiableListは元リストを包むビューです。元リストの変更は見えます。"),
            Choice(id: "b", text: "2", correct: true, misconception: nil, explanation: "viewはbaseの変更不可ビューなので、baseへ追加したbもviewから見えます。"),
            Choice(id: "c", text: "UnsupportedOperationException", correct: false, misconception: "baseへの追加も禁止されると誤解", explanation: "禁止されるのはview経由の変更です。base自体はArrayListです。"),
            Choice(id: "d", text: "ConcurrentModificationException", correct: false, misconception: "変更を検出して例外になると誤解", explanation: "イテレータ走査中の構造変更ではありません。"),
        ],
        explanationRef: "explain-gold-advanced-unmodifiable-view-001",
        designIntent: "Collections.unmodifiableListはコピーではなくビューであることを確認する。"
    )

    static let goldAdvancedTreeSetComparator001 = Quiz(
        id: "gold-advanced-treeset-comparator-001",
        level: .gold,
        difficulty: .exam,
        category: "collections",
        tags: ["TreeSet", "Comparator", "equals"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "3:true", correct: false, misconception: "TreeSetもequalsで重複判定すると誤解", explanation: "TreeSetはComparatorの比較結果0を同じ要素として扱います。"),
            Choice(id: "b", text: "2:true", correct: true, misconception: nil, explanation: "aaとbbは長さが同じで比較結果0のため重複扱いです。containsもComparator基準なのでbbは含まれると判定されます。"),
            Choice(id: "c", text: "2:false", correct: false, misconception: "bbが格納されないならcontainsもfalseと誤解", explanation: "containsも比較規則で判定するため、同じ長さのaaがあればbbも含む扱いです。"),
            Choice(id: "d", text: "ClassCastException", correct: false, misconception: "StringがComparableでないと誤解", explanation: "Comparatorを明示しているため比較可能です。"),
        ],
        explanationRef: "explain-gold-advanced-treeset-comparator-001",
        designIntent: "TreeSetの重複判定とcontainsがComparator基準であることを確認する。"
    )

    static let goldAdvancedGenericsSuperRead001 = Quiz(
        id: "gold-advanced-generics-super-read-001",
        level: .gold,
        difficulty: .standard,
        category: "generics",
        tags: ["generics", "wildcard", "super"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "Integer", correct: true, misconception: nil, explanation: "Integerを追加し、Objectとして取り出した実体のクラス名を表示しています。"),
            Choice(id: "b", text: "Number", correct: false, misconception: "ArrayList<Number>に入れるとNumberへ変換されると誤解", explanation: "格納されたオブジェクトの実体はIntegerのままです。"),
            Choice(id: "c", text: "Object", correct: false, misconception: "変数型Objectが実体クラスになると誤解", explanation: "getClass()は実体オブジェクトのクラスを返します。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "? super Integerからは何も読めないと誤解", explanation: "読むことはできます。ただし安全な型はObjectです。"),
        ],
        explanationRef: "explain-gold-advanced-generics-super-read-001",
        designIntent: "? super IntegerにはIntegerを書き込めるが、読み取り型はObjectになることを確認する。"
    )

    static let goldAdvancedGenericsExtendsNull001 = Quiz(
        id: "gold-advanced-generics-extends-null-001",
        level: .gold,
        difficulty: .tricky,
        category: "generics",
        tags: ["generics", "wildcard", "extends", "null"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1", correct: true, misconception: nil, explanation: "? extends Numberには具体的な非null値は追加できませんが、nullだけは追加できます。"),
            Choice(id: "b", text: "0", correct: false, misconception: "add(null)が無視されると誤解", explanation: "ArrayListへのadd(null)は実行され、サイズが増えます。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "? extendsにはnullも追加できないと誤解", explanation: "nullはどの参照型にも代入可能なので例外的に追加できます。"),
            Choice(id: "d", text: "NullPointerException", correct: false, misconception: "null追加が常に例外になると誤解", explanation: "ArrayListはnull要素を許容します。"),
        ],
        explanationRef: "explain-gold-advanced-generics-extends-null-001",
        designIntent: "? extends Tでもnullだけは追加できるという例外を確認する。"
    )

    static let goldAdvancedGenericsErasureOverload001 = Quiz(
        id: "gold-advanced-generics-erasure-overload-001",
        level: .gold,
        difficulty: .exam,
        validatedByJavac: false,
        category: "generics",
        tags: ["generics", "type erasure", "overload", "compile error"],
        code: """
import java.util.*;

public class Test {
    static void print(List<String> values) {}
    static void print(List<Integer> values) {}
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる", correct: false, misconception: "型引数が違えば別シグネチャになると誤解", explanation: "型消去後はどちらもprint(List)相当になり衝突します。"),
            Choice(id: "b", text: "2つのprintメソッドが名前衝突してコンパイルエラー", correct: true, misconception: nil, explanation: "Javaジェネリクスは型消去されるため、List<String>とList<Integer>だけではオーバーロードを区別できません。"),
            Choice(id: "c", text: "実行時にClassCastException", correct: false, misconception: "コンパイルは通ると誤解", explanation: "実行前にメソッド宣言の衝突でコンパイルエラーです。"),
            Choice(id: "d", text: "片方だけが自動的に選ばれる", correct: false, misconception: "後に定義したメソッドで上書きされると誤解", explanation: "Javaでは同じ消去後シグネチャのメソッドを同一クラスに宣言できません。"),
        ],
        explanationRef: "explain-gold-advanced-generics-erasure-overload-001",
        designIntent: "型消去により型引数だけが異なるオーバーロードは成立しないことを確認する。"
    )

    static let goldAdvancedLambdaReferenceMutation001 = Quiz(
        id: "gold-advanced-lambda-reference-mutation-001",
        level: .gold,
        difficulty: .tricky,
        category: "lambda-streams",
        tags: ["lambda", "effectively final", "mutation"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "[y, x]", correct: true, misconception: nil, explanation: "list変数は再代入されていないため実質的finalです。中身の変更は可能で、y追加後にr.runでxが追加されます。"),
            Choice(id: "b", text: "[x, y]", correct: false, misconception: "ラムダ定義時に実行されると誤解", explanation: "ラムダ本体はr.run()まで実行されません。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "参照先オブジェクトの変更も実質的final違反と誤解", explanation: "禁止されるのはローカル変数listへの再代入です。list.addは可能です。"),
            Choice(id: "d", text: "[]", correct: false, misconception: "変更が別コピーに対して行われると誤解", explanation: "ラムダは同じArrayListオブジェクトを参照しています。"),
        ],
        explanationRef: "explain-gold-advanced-lambda-reference-mutation-001",
        designIntent: "実質的finalの制約は変数の再代入であり、参照先オブジェクトの変更ではないことを確認する。"
    )

    static let goldAdvancedFunctionCompose001 = Quiz(
        id: "gold-advanced-function-compose-001",
        level: .gold,
        difficulty: .tricky,
        category: "lambda-streams",
        tags: ["Function", "compose", "andThen"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "7:8", correct: true, misconception: nil, explanation: "composeは先にdblしてからaddなので7、andThenはaddしてからdblなので8です。"),
            Choice(id: "b", text: "8:7", correct: false, misconception: "composeとandThenの順序を逆に理解", explanation: "composeは引数側の関数を先に実行します。"),
            Choice(id: "c", text: "6:4", correct: false, misconception: "どちらか一方の関数だけ実行すると誤解", explanation: "compose/andThenは2つの関数を合成します。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "Functionの合成メソッドを使えないと誤解", explanation: "FunctionにはcomposeとandThenが定義されています。"),
        ],
        explanationRef: "explain-gold-advanced-function-compose-001",
        designIntent: "Function.composeとandThenの評価順の違いを確認する。"
    )

    static let goldAdvancedMethodReferenceBound001 = Quiz(
        id: "gold-advanced-method-reference-bound-001",
        level: .gold,
        difficulty: .standard,
        category: "lambda-streams",
        tags: ["method reference", "bound", "unbound"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "y:x", correct: true, misconception: nil, explanation: "String::trimは引数のStringをtrimし、\" x \"::trimは固定されたレシーバをtrimします。"),
            Choice(id: "b", text: " y : x ", correct: false, misconception: "trimが空白を削除しないと誤解", explanation: "trimは前後の空白を取り除きます。"),
            Choice(id: "c", text: "x:y", correct: false, misconception: "FunctionとSupplierの結果を逆に読んでいる", explanation: "左側がtrim.apply(\" y \")、右側がfixed.get()です。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "束縛済みメソッド参照をSupplierへ代入できないと誤解", explanation: "レシーバが固定されているため、引数なしでStringを返すSupplierに適合します。"),
        ],
        explanationRef: "explain-gold-advanced-method-reference-bound-001",
        designIntent: "非束縛メソッド参照と束縛済みメソッド参照のターゲット型の違いを確認する。"
    )

    static let goldAdvancedOptionalOrElseThrow001 = Quiz(
        id: "gold-advanced-optional-orelsethrow-001",
        level: .gold,
        difficulty: .standard,
        category: "optional-api",
        tags: ["Optional", "orElseThrow", "Supplier", "lazy"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "Xok", correct: false, misconception: "orElseThrowのSupplierが常に実行されると誤解", explanation: "Optionalに値があるためSupplierは実行されません。"),
            Choice(id: "b", text: "ok", correct: true, misconception: nil, explanation: "Optional.of(\"ok\")は値を持つため、orElseThrowはその値を返します。Xは出力されません。"),
            Choice(id: "c", text: "RuntimeException", correct: false, misconception: "orElseThrowが常に例外を投げると誤解", explanation: "値がある場合は例外は生成されません。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "ラムダで例外Supplierを書けないと誤解", explanation: "orElseThrowはSupplier<? extends Throwable>を受け取ります。"),
        ],
        explanationRef: "explain-gold-advanced-optional-orelsethrow-001",
        designIntent: "orElseThrowのSupplierが空Optionalのときだけ実行されることを確認する。"
    )

    static let goldAdvancedOptionalFilter001 = Quiz(
        id: "gold-advanced-optional-filter-001",
        level: .gold,
        difficulty: .standard,
        category: "optional-api",
        tags: ["Optional", "filter", "orElse"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "java", correct: false, misconception: "filter条件を満たすと誤解", explanation: "\"java\"の長さは4なので、length() > 4 はfalseです。"),
            Choice(id: "b", text: "none", correct: true, misconception: nil, explanation: "filterで空Optionalになり、orElseの値noneが使われます。"),
            Choice(id: "c", text: "false", correct: false, misconception: "filterがbooleanを返すと誤解", explanation: "Optional.filterは条件に応じてOptionalを返します。"),
            Choice(id: "d", text: "NoSuchElementException", correct: false, misconception: "空Optionalをgetしていると誤解", explanation: "getではなくorElseで代替値を指定しています。"),
        ],
        explanationRef: "explain-gold-advanced-optional-filter-001",
        designIntent: "Optional.filterで条件不一致時に空になり、orElseへ進むことを確認する。"
    )

    static let goldAdvancedDateTimeMonthEnd001 = Quiz(
        id: "gold-advanced-datetime-month-end-001",
        level: .gold,
        difficulty: .tricky,
        category: "date-time",
        tags: ["LocalDate", "plusMonths", "leap year"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2024-02-29", correct: false, misconception: "plusDays(1)を見落とし", explanation: "2024-01-31に1か月足すと2024-02-29ですが、さらに1日足します。"),
            Choice(id: "b", text: "2024-03-01", correct: true, misconception: nil, explanation: "2024年はうるう年なのでplusMonths(1)で2月29日、plusDays(1)で3月1日です。"),
            Choice(id: "c", text: "2024-03-02", correct: false, misconception: "2月を28日として処理している", explanation: "2024年2月は29日まであります。"),
            Choice(id: "d", text: "DateTimeException", correct: false, misconception: "存在しない日付で例外になると誤解", explanation: "plusMonthsは月末の有効日に調整します。"),
        ],
        explanationRef: "explain-gold-advanced-datetime-month-end-001",
        designIntent: "LocalDate.plusMonthsの月末調整とうるう年を確認する。"
    )

    static let goldAdvancedDateTimePeriodBetween001 = Quiz(
        id: "gold-advanced-datetime-period-between-001",
        level: .gold,
        difficulty: .standard,
        category: "date-time",
        tags: ["LocalDate", "Period", "between"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "P1D:1", correct: false, misconception: "2024年の2月29日を見落とし", explanation: "2024年はうるう年で、2月28日から3月1日までは2日あります。"),
            Choice(id: "b", text: "P2D:2", correct: true, misconception: nil, explanation: "2024-02-28から2024-03-01までは2日差なのでPeriodはP2Dです。"),
            Choice(id: "c", text: "P1M1D:1", correct: false, misconception: "月をまたぐと月成分になると誤解", explanation: "この期間は月単位ではなく日数2として表現されます。"),
            Choice(id: "d", text: "PT48H:0", correct: false, misconception: "PeriodとDurationを混同", explanation: "Periodは日付ベースで、PT48HはDurationの表現です。"),
        ],
        explanationRef: "explain-gold-advanced-datetime-period-between-001",
        designIntent: "Period.betweenの日付差とうるう年を確認する。"
    )

    static let goldAdvancedMessageFormatQuotes001 = Quiz(
        id: "gold-advanced-messageformat-quotes-001",
        level: .gold,
        difficulty: .tricky,
        category: "localization",
        tags: ["MessageFormat", "format", "quotes"],
        code: """
import java.text.*;

public class Test {
    public static void main(String[] args) {
        String text = MessageFormat.format("'{0}' {0}", "A");
        System.out.println(text);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "A A", correct: false, misconception: "単一引用符内の{0}も置換されると誤解", explanation: "MessageFormatでは単一引用符がクォートに使われ、引用内の{0}はリテラルになります。"),
            Choice(id: "b", text: "{0} A", correct: true, misconception: nil, explanation: "最初の'{0}'はリテラルの{0}、後半の{0}だけがAに置換されます。"),
            Choice(id: "c", text: "'A' A", correct: false, misconception: "引用符が出力されると誤解", explanation: "単一引用符はMessageFormatのエスケープ構文として使われ、通常は出力されません。"),
            Choice(id: "d", text: "IllegalArgumentException", correct: false, misconception: "引用符付きパターンが不正と誤解", explanation: "このパターンは有効です。"),
        ],
        explanationRef: "explain-gold-advanced-messageformat-quotes-001",
        designIntent: "MessageFormatにおける単一引用符の扱いとプレースホルダ置換を確認する。"
    )

    static let goldAdvancedAnnotationDefaultRetention001 = Quiz(
        id: "gold-advanced-annotation-default-retention-001",
        level: .gold,
        difficulty: .standard,
        category: "annotations",
        tags: ["Annotation", "Retention", "reflection"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "true", correct: true, misconception: nil, explanation: "@Retentionを指定しない場合、実行時リフレクションでは取得できません。getAnnotationはnullを返します。"),
            Choice(id: "b", text: "false", correct: false, misconception: "デフォルトでRUNTIME保持だと誤解", explanation: "実行時に取得したい場合は@Retention(RetentionPolicy.RUNTIME)が必要です。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "配列要素のアノテーション値を書けないと誤解", explanation: "value要素が配列の場合、@Tags({\"a\", \"b\"})は有効です。"),
            Choice(id: "d", text: "NullPointerException", correct: false, misconception: "null比較で例外になると誤解", explanation: "== null の比較では例外は発生しません。"),
        ],
        explanationRef: "explain-gold-advanced-annotation-default-retention-001",
        designIntent: "アノテーションのデフォルト保持期間とリフレクション可視性を確認する。"
    )

    static let goldAdvancedAnnotationRepeatable001 = Quiz(
        id: "gold-advanced-annotation-repeatable-001",
        level: .gold,
        difficulty: .exam,
        category: "annotations",
        tags: ["Annotation", "Repeatable", "reflection"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "0", correct: false, misconception: "繰り返しアノテーションがリフレクションで読めないと誤解", explanation: "RetentionPolicy.RUNTIMEなので実行時に読めます。"),
            Choice(id: "b", text: "1", correct: false, misconception: "コンテナアノテーションだけが1つ見えると誤解", explanation: "getAnnotationsByType(Role.class)は繰り返されたRoleを展開して返します。"),
            Choice(id: "c", text: "2", correct: true, misconception: nil, explanation: "@Roleが2回付いているため、Role.classで取得すると2件です。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "@Repeatableのコンテナを正しく定義できていないと誤解", explanation: "RolesはRole[] value()を持つため、コンテナとして有効です。"),
        ],
        explanationRef: "explain-gold-advanced-annotation-repeatable-001",
        designIntent: "繰り返し可能アノテーションのコンテナとgetAnnotationsByTypeの動作を確認する。"
    )

    static let goldAdvancedExceptionMultiCatchAssign001 = Quiz(
        id: "gold-advanced-exception-multicatch-assign-001",
        level: .gold,
        difficulty: .exam,
        validatedByJavac: false,
        category: "exception-handling",
        tags: ["multi-catch", "effectively final", "compile error"],
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
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる", correct: false, misconception: "catchパラメータは常に再代入できると誤解", explanation: "マルチキャッチのパラメータは暗黙的にfinalです。"),
            Choice(id: "b", text: "eへの再代入がコンパイルエラー", correct: true, misconception: nil, explanation: "IOException | SQLException のcatchパラメータeには再代入できません。"),
            Choice(id: "c", text: "run()の呼び出しが未処理例外でコンパイルエラー", correct: false, misconception: "catchで処理されていないと誤解", explanation: "runが投げる2種類の例外はcatchの候補に含まれています。"),
            Choice(id: "d", text: "実行時にIOExceptionが出力される", correct: false, misconception: "コンパイルが通ると誤解", explanation: "コンパイルエラーなので実行されません。"),
        ],
        explanationRef: "explain-gold-advanced-exception-multicatch-assign-001",
        designIntent: "マルチキャッチのcatchパラメータが再代入不可であることを確認する。"
    )

    static let goldAdvancedExceptionCatchOrder001 = Quiz(
        id: "gold-advanced-exception-catch-order-001",
        level: .gold,
        difficulty: .standard,
        validatedByJavac: false,
        category: "exception-handling",
        tags: ["catch", "exception hierarchy", "compile error"],
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
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "E と出力される", correct: false, misconception: "先に広いcatchで捕まるため問題ないと誤解", explanation: "広いcatchを先に書くと、後続の狭いcatchが到達不能になります。"),
            Choice(id: "b", text: "IO と出力される", correct: false, misconception: "実体型に最も近いcatchが実行時に選ばれると誤解", explanation: "catchブロックは上から検査されますが、このコードは到達不能catchでコンパイルエラーです。"),
            Choice(id: "c", text: "IOExceptionのcatchが到達不能でコンパイルエラー", correct: true, misconception: nil, explanation: "IOExceptionはExceptionのサブクラスなので、先のcatch(Exception)で必ず捕捉されます。"),
            Choice(id: "d", text: "実行時に未処理例外", correct: false, misconception: "catchが機能しないと誤解", explanation: "実行前にコンパイルエラーです。"),
        ],
        explanationRef: "explain-gold-advanced-exception-catch-order-001",
        designIntent: "複数catchではサブクラス例外を先に書く必要があることを確認する。"
    )

    static let goldAdvancedTryResourcesClose001 = Quiz(
        id: "gold-advanced-try-resources-close-001",
        level: .gold,
        difficulty: .standard,
        category: "exception-handling",
        tags: ["try-with-resources", "AutoCloseable", "close"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "BCA", correct: true, misconception: nil, explanation: "try本体でB、tryを抜けるときにcloseでC、その後Aが出力されます。"),
            Choice(id: "b", text: "BAC", correct: false, misconception: "closeがtry文全体の後に実行されると誤解", explanation: "closeはtry-with-resourcesを抜ける時点、後続文Aより前に実行されます。"),
            Choice(id: "c", text: "CBA", correct: false, misconception: "closeが本体前に実行されると誤解", explanation: "closeは本体実行後です。"),
            Choice(id: "d", text: "BA", correct: false, misconception: "例外がなければcloseされないと誤解", explanation: "例外の有無にかかわらずリソースは閉じられます。"),
        ],
        explanationRef: "explain-gold-advanced-try-resources-close-001",
        designIntent: "try-with-resourcesで本体後・後続文前にcloseされる順序を確認する。"
    )

    static let goldAdvancedSerializationStaticTransient001 = Quiz(
        id: "gold-advanced-serialization-static-transient-001",
        level: .gold,
        difficulty: .exam,
        category: "secure-coding",
        tags: ["serialization", "static", "transient"],
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
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "V:T:S", correct: false, misconception: "static/transientも通常フィールドと同じく保存されると誤解", explanation: "staticはインスタンス状態ではなく、transientは保存対象外です。"),
            Choice(id: "b", text: "V:null:X", correct: true, misconception: nil, explanation: "valueは復元され、transientのtempはnull、staticのsharedは現在のクラス変数Xです。"),
            Choice(id: "c", text: "null:null:X", correct: false, misconception: "通常フィールドも初期化し直されると誤解", explanation: "非transientのvalueはシリアライズされたVとして復元されます。"),
            Choice(id: "d", text: "NotSerializableException", correct: false, misconception: "transientフィールドがあるとシリアライズできないと誤解", explanation: "BoxはSerializableを実装しており、tempは保存対象外になるだけです。"),
        ],
        explanationRef: "explain-gold-advanced-serialization-static-transient-001",
        designIntent: "staticフィールドとtransientフィールドがシリアライズ対象にならないことを確認する。"
    )

    static let goldAdvancedPathResolveSibling001 = Quiz(
        id: "gold-advanced-path-resolve-sibling-001",
        level: .gold,
        difficulty: .standard,
        category: "io",
        tags: ["Path", "resolveSibling", "NIO"],
        code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path path = Path.of("/a/b/c.txt");
        System.out.println(path.resolveSibling("d.txt"));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "/a/b/d.txt", correct: true, misconception: nil, explanation: "resolveSiblingは同じ親ディレクトリ配下の兄弟パスとしてd.txtを解決します。"),
            Choice(id: "b", text: "/a/b/c.txt/d.txt", correct: false, misconception: "resolveと同じく子パスとして結合すると誤解", explanation: "resolveSiblingはファイル名部分を兄弟に置き換えます。"),
            Choice(id: "c", text: "d.txt", correct: false, misconception: "相対パスだけが返ると誤解", explanation: "元のpathが絶対パスなので、親/a/bを含む絶対パスになります。"),
            Choice(id: "d", text: "/a/d.txt", correct: false, misconception: "親を一段上げると誤解", explanation: "兄弟はc.txtと同じ親/a/b配下です。"),
        ],
        explanationRef: "explain-gold-advanced-path-resolve-sibling-001",
        designIntent: "Path.resolveSiblingが親ディレクトリを保って兄弟パスを作ることを確認する。"
    )

    static let goldAdvancedPathSubpath001 = Quiz(
        id: "gold-advanced-path-subpath-001",
        level: .gold,
        difficulty: .tricky,
        category: "io",
        tags: ["Path", "subpath", "root"],
        code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path path = Path.of("/a/b/c");
        System.out.println(path.subpath(0, 2));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "/a/b", correct: false, misconception: "subpathにrootが含まれると誤解", explanation: "subpathは名前要素だけを対象にし、rootの/は含みません。"),
            Choice(id: "b", text: "a/b", correct: true, misconception: nil, explanation: "名前要素はa,b,cで、subpath(0,2)は開始0を含み終了2を含まないためa/bです。"),
            Choice(id: "c", text: "a/b/c", correct: false, misconception: "終了インデックスを含むと誤解", explanation: "終了インデックス2は含まれません。"),
            Choice(id: "d", text: "b/c", correct: false, misconception: "rootを0番目の名前要素として数えると誤解", explanation: "rootは名前要素ではありません。0番目はaです。"),
        ],
        explanationRef: "explain-gold-advanced-path-subpath-001",
        designIntent: "Path.subpathの開始/終了インデックスとrootを含まない性質を確認する。"
    )
}
