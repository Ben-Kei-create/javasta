import Foundation

extension QuizExpansion {
    static let streamApiExpansion: [Quiz] = [
        goldStream014,
        goldStream015,
        goldStream016,
        goldStream017,
        goldStream018,
        goldStream019,
        goldOptional009,
        goldOptional010,
        goldStream020,
        goldStream021,
        goldStream022,
        goldOptional011,
        goldOptional012,
        goldOptional013,
        goldStream023,
        goldStream024,
        goldStream025,
        goldStream026,
        goldStream027,
        goldStream028,
        goldStream029,
        goldStream030,
        goldStream031,
    ]

    static let goldStream014 = Quiz(
        id: "gold-stream-014",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "IntStream", "生成", "count"],
        code: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        long a = Stream.of(1, 2, 3).count();
        int b = IntStream.rangeClosed(1, 3).sum();
        System.out.println(a + ":" + b);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "3:6", correct: true, misconception: nil, explanation: "Stream.ofは3要素なのでcountは3です。rangeClosed(1, 3)は1,2,3を含むためsumは6です。"),
            Choice(id: "b", text: "3:3", correct: false, misconception: "rangeClosedの終端値を含まないと誤解", explanation: "rangeClosedは終端値を含むため1+2+3です。"),
            Choice(id: "c", text: "2:6", correct: false, misconception: "countが0始まりになると誤解", explanation: "countは要素数を返すため3です。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "Stream<Integer>とIntStreamを同じ型として扱えないと誤解", explanation: "別々の変数に受けているため問題ありません。"),
        ],
        explanationRef: "explain-gold-stream-014",
        designIntent: "参照型StreamとプリミティブStreamの生成、countとsumの違いを確認する。"
    )

    static let goldStream015 = Quiz(
        id: "gold-stream-015",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "Arrays.stream", "generate", "limit"],
        code: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        String[] data = {"A", "B", "C", "D"};
        long a = Arrays.stream(data, 1, 3).count();
        long b = Stream.generate(() -> "x").limit(3).count();
        System.out.println(a + ":" + b);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2:3", correct: true, misconception: nil, explanation: "Arrays.stream(data, 1, 3)はインデックス1以上3未満なのでB,Cの2件です。generateは無限Streamですがlimit(3)で3件に制限されます。"),
            Choice(id: "b", text: "3:3", correct: false, misconception: "toIndexも含まれると誤解", explanation: "第3引数のtoIndexは排他的です。Dは含まれません。"),
            Choice(id: "c", text: "2:無限ループ", correct: false, misconception: "limit前でもgenerateが無限に評価されると誤解", explanation: "Streamは遅延評価され、countの要求分だけlimitで3件に制限されます。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "Stream.generateにラムダを渡せないと誤解", explanation: "generateはSupplierを受け取るため`() -> \"x\"`を渡せます。"),
        ],
        explanationRef: "explain-gold-stream-015",
        designIntent: "配列範囲Streamと無限Stream生成、limitによる短絡的な制限を追わせる。"
    )

    static let goldStream016 = Quiz(
        id: "gold-stream-016",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "forEach", "skip", "limit"],
        code: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        Stream.of("A", "B", "C", "D")
            .skip(1)
            .limit(2)
            .forEach(System.out::print);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "BC", correct: true, misconception: nil, explanation: "skip(1)でAを飛ばし、limit(2)でB,Cの2件だけをforEachで出力します。"),
            Choice(id: "b", text: "AB", correct: false, misconception: "skipを見落とし", explanation: "Aはskip(1)で除外されます。"),
            Choice(id: "c", text: "BCD", correct: false, misconception: "limitが残り全件を許可すると誤解", explanation: "limit(2)なのでB,Cの2件までです。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "forEachにメソッド参照を渡せないと誤解", explanation: "System.out::printはConsumerとして利用できます。"),
        ],
        explanationRef: "explain-gold-stream-016",
        designIntent: "skip、limit、forEachの終端処理までの要素の流れを確認する。"
    )

    static let goldStream017 = Quiz(
        id: "gold-stream-017",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "reduce", "identity", "終端操作"],
        code: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        int result = Stream.of(2, 3, 4)
            .reduce(1, (a, b) -> a * b);
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "24", correct: true, misconception: nil, explanation: "identityの1から始めて、1*2*3*4を計算するため24です。"),
            Choice(id: "b", text: "9", correct: false, misconception: "reduceが加算になると誤解", explanation: "ラムダは掛け算です。"),
            Choice(id: "c", text: "10", correct: false, misconception: "identityが最後に加算されると誤解", explanation: "identityは初期値であり、今回は掛け算の初期値1です。"),
            Choice(id: "d", text: "Optional[24]", correct: false, misconception: "identityありreduceもOptionalを返すと誤解", explanation: "identityありのreduceはTを返します。Optionalではありません。"),
        ],
        explanationRef: "explain-gold-stream-017",
        designIntent: "identityありreduceの戻り値型と累積順を確認する。"
    )

    static let goldStream018 = Quiz(
        id: "gold-stream-018",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "reduce", "Optional", "isPresent"],
        code: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        Optional<Integer> result = Stream.<Integer>empty()
            .reduce(Integer::sum);
        System.out.println(result.isPresent());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "false", correct: true, misconception: nil, explanation: "identityなしreduceはOptionalを返します。空StreamなのでOptional.emptyとなりisPresentはfalseです。"),
            Choice(id: "b", text: "true", correct: false, misconception: "空でも0が入ると誤解", explanation: "identityを指定していないため、空の場合は値を作れません。"),
            Choice(id: "c", text: "0", correct: false, misconception: "sumの初期値0が返ると誤解", explanation: "reduce(Integer::sum)はOptional<Integer>を返すため、出力しているのはisPresentのbooleanです。"),
            Choice(id: "d", text: "NoSuchElementException", correct: false, misconception: "空Optionalをgetしていると誤解", explanation: "get()は呼んでいません。isPresent()だけなので例外は出ません。"),
        ],
        explanationRef: "explain-gold-stream-018",
        designIntent: "identityなしreduceがOptionalを返し、空Streamでは空になることを確認する。"
    )

    static let goldStream019 = Quiz(
        id: "gold-stream-019",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "toArray", "配列生成"],
        code: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        Object[] a = Stream.of("x", "y").toArray();
        String[] b = Stream.of("x", "y").toArray(String[]::new);
        System.out.println(a.length + ":" + b[1] + ":" + (a instanceof String[]));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2:y:false", correct: true, misconception: nil, explanation: "引数なしtoArrayはObject[]を返します。String[]::newを渡した方はString[]です。"),
            Choice(id: "b", text: "2:y:true", correct: false, misconception: "要素がStringなら引数なしtoArrayもString[]になると誤解", explanation: "引数なしtoArrayの戻り値はObject[]です。"),
            Choice(id: "c", text: "2:x:false", correct: false, misconception: "配列の添字を1始まりと誤解", explanation: "b[1]は2番目の要素yです。"),
            Choice(id: "d", text: "ClassCastException", correct: false, misconception: "Object[]作成時にString[]へキャストされると誤解", explanation: "aはObject[]として受け取っており、キャストしていません。"),
        ],
        explanationRef: "explain-gold-stream-019",
        designIntent: "toArray()とtoArray(IntFunction)の配列型の違いを確認する。"
    )

    static let goldOptional009 = Quiz(
        id: "gold-optional-009",
        level: .gold,
        category: "optional-api",
        tags: ["Optional", "get", "NoSuchElementException"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Optional<String> opt = Optional.empty();
        try {
            System.out.println(opt.get());
        } catch (NoSuchElementException e) {
            System.out.println("empty");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "empty", correct: true, misconception: nil, explanation: "空Optionalにget()を呼ぶとNoSuchElementExceptionが発生し、catchでemptyが出力されます。"),
            Choice(id: "b", text: "null", correct: false, misconception: "Optional.emptyがnullを返すと誤解", explanation: "get()はnullではなく例外を投げます。"),
            Choice(id: "c", text: "Optional.empty", correct: false, misconception: "get()がOptional自身を返すと誤解", explanation: "get()は中身の値を返すメソッドです。空なら例外です。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "NoSuchElementExceptionのcatchが不要/不可と誤解", explanation: "NoSuchElementExceptionはRuntimeExceptionなのでcatchできます。"),
        ],
        explanationRef: "explain-gold-optional-009",
        designIntent: "Optional.get()は空の場合にNoSuchElementExceptionを投げることを確認する。"
    )

    static let goldOptional010 = Quiz(
        id: "gold-optional-010",
        level: .gold,
        category: "optional-api",
        tags: ["Optional", "isPresent", "get"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Optional<String> opt = Optional.of("java");
        if (opt.isPresent()) {
            System.out.println(opt.get().toUpperCase());
        } else {
            System.out.println("empty");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "JAVA", correct: true, misconception: nil, explanation: "optにはjavaが入っているためisPresentはtrueです。get()した値にtoUpperCase()を適用します。"),
            Choice(id: "b", text: "java", correct: false, misconception: "toUpperCaseの結果を見落とし", explanation: "get()後にtoUpperCase()を呼んでいます。"),
            Choice(id: "c", text: "empty", correct: false, misconception: "Optional.ofが空になると誤解", explanation: "Optional.of(\"java\")は値ありOptionalです。"),
            Choice(id: "d", text: "NoSuchElementException", correct: false, misconception: "get()は常に危険だとだけ覚えている", explanation: "値がある状態でget()しているため例外は出ません。"),
        ],
        explanationRef: "explain-gold-optional-010",
        designIntent: "isPresentで値の有無を確認してからgetする基本動作を確認する。"
    )

    static let goldStream020 = Quiz(
        id: "gold-stream-020",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "max", "Comparator", "Optional"],
        code: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        String result = Stream.of("aa", "b", "cccc")
            .max(Comparator.comparingInt(String::length))
            .get();
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "cccc", correct: true, misconception: nil, explanation: "maxはComparatorで最大となる要素をOptionalで返します。長さ最大はccccです。"),
            Choice(id: "b", text: "aa", correct: false, misconception: "最初の要素が返ると誤解", explanation: "maxは全要素を比較します。"),
            Choice(id: "c", text: "b", correct: false, misconception: "lengthが最小のものを返すと誤解", explanation: "maxなので長さ最大の要素です。"),
            Choice(id: "d", text: "Optional[cccc]", correct: false, misconception: "get後もOptionalの表示になると誤解", explanation: "get()で中身のStringを取り出しています。"),
        ],
        explanationRef: "explain-gold-stream-020",
        designIntent: "maxの戻り値がOptionalであり、Comparatorによって最大要素が決まることを確認する。"
    )

    static let goldStream021 = Quiz(
        id: "gold-stream-021",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "findFirst", "filter", "orElse"],
        code: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        String result = Stream.of("bb", "a", "ccc")
            .filter(s -> s.length() <= 2)
            .findFirst()
            .orElse("none");
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "bb", correct: true, misconception: nil, explanation: "条件に合う要素はbbとaですが、順序付きStreamのfindFirstは最初のbbを返します。"),
            Choice(id: "b", text: "a", correct: false, misconception: "最短の要素を探す処理だと誤解", explanation: "filterは長さ2以下を残すだけで、最小値を探していません。"),
            Choice(id: "c", text: "none", correct: false, misconception: "条件一致がないと誤解", explanation: "bbとaが条件に一致します。"),
            Choice(id: "d", text: "ccc", correct: false, misconception: "filter条件を逆に読んでいる", explanation: "cccの長さは3なので除外されます。"),
        ],
        explanationRef: "explain-gold-stream-021",
        designIntent: "順序付きStreamでfindFirstが最初に条件を満たした要素を返すことを確認する。"
    )

    static let goldStream022 = Quiz(
        id: "gold-stream-022",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "findAny", "parallel", "Optional"],
        code: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        String result = Stream.of("A", "B", "C")
            .parallel()
            .findAny()
            .orElse("none");
        System.out.println(result);
    }
}
""",
        question: "このコードの仕様上の読み方として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "A, B, C のいずれかが出力され得る", correct: true, misconception: nil, explanation: "findAnyは任意の要素を返せます。parallelでは特に先頭要素とは限りません。"),
            Choice(id: "b", text: "必ずAが出力される", correct: false, misconception: "findFirstとfindAnyを混同", explanation: "順序を保証したい場合はfindFirstを使います。"),
            Choice(id: "c", text: "必ずnoneが出力される", correct: false, misconception: "parallelにするとOptionalが空になると誤解", explanation: "StreamにはA,B,Cの要素があります。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "parallel後にfindAnyを呼べないと誤解", explanation: "parallel()はStreamを返すためfindAnyを呼べます。"),
        ],
        explanationRef: "explain-gold-stream-022",
        designIntent: "findAnyは任意要素であり、findFirstの順序保証とは違うことを確認する。"
    )

    static let goldOptional011 = Quiz(
        id: "gold-optional-011",
        level: .gold,
        category: "optional-api",
        tags: ["Optional", "orElse", "評価タイミング"],
        code: """
import java.util.*;

public class Test {
    static String fallback() {
        System.out.print("F");
        return "fallback";
    }

    public static void main(String[] args) {
        String result = Optional.of("value").orElse(fallback());
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "Fvalue", correct: true, misconception: nil, explanation: "orElseの引数fallback()はOptionalに値があっても先に評価され、その後valueが返ります。"),
            Choice(id: "b", text: "value", correct: false, misconception: "orElseが遅延評価されると誤解", explanation: "orElseの引数は通常のメソッド引数なので先に評価されます。"),
            Choice(id: "c", text: "Ffallback", correct: false, misconception: "値ありでも代替値が採用されると誤解", explanation: "fallback()は実行されますが、採用される戻り値はOptional内のvalueです。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "orElseにメソッド呼び出しを書けないと誤解", explanation: "orElseにはStringを渡せばよく、fallback()の戻り値はStringです。"),
        ],
        explanationRef: "explain-gold-optional-011",
        designIntent: "orElseの引数が即時評価されることを副作用の出力で確認する。"
    )

    static let goldOptional012 = Quiz(
        id: "gold-optional-012",
        level: .gold,
        category: "optional-api",
        tags: ["Optional", "orElseGet", "Supplier", "遅延評価"],
        code: """
import java.util.*;

public class Test {
    static String fallback() {
        System.out.print("F");
        return "fallback";
    }

    public static void main(String[] args) {
        String result = Optional.of("value").orElseGet(() -> fallback());
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "value", correct: true, misconception: nil, explanation: "Optionalに値があるためorElseGetのSupplierは実行されず、valueだけが出力されます。"),
            Choice(id: "b", text: "Fvalue", correct: false, misconception: "orElseGetも即時評価されると誤解", explanation: "orElseGetは必要なときだけSupplierを実行します。"),
            Choice(id: "c", text: "fallback", correct: false, misconception: "値ありでも代替値が返ると誤解", explanation: "Optional内にvalueがあるため代替値は使われません。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "orElseGetにラムダを渡せないと誤解", explanation: "orElseGetはSupplierを受け取るためラムダを渡せます。"),
        ],
        explanationRef: "explain-gold-optional-012",
        designIntent: "orElseGetのSupplierが遅延評価されることを確認する。"
    )

    static let goldOptional013 = Quiz(
        id: "gold-optional-013",
        level: .gold,
        category: "optional-api",
        tags: ["Optional", "orElseThrow", "例外"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        try {
            Optional.<String>empty()
                .orElseThrow(() -> new IllegalStateException("none"));
        } catch (IllegalStateException e) {
            System.out.println(e.getMessage());
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "none", correct: true, misconception: nil, explanation: "空OptionalなのでSupplierが実行され、IllegalStateException(\"none\")が投げられてcatchされます。"),
            Choice(id: "b", text: "null", correct: false, misconception: "空Optionalがnullを返すと誤解", explanation: "orElseThrowは空の場合に例外を投げます。"),
            Choice(id: "c", text: "Optional.empty", correct: false, misconception: "Optional自身が出力されると誤解", explanation: "Optionalを出力しているコードではありません。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "orElseThrowに例外生成ラムダを渡せないと誤解", explanation: "Supplier<? extends Throwable>として例外生成ラムダを渡せます。"),
        ],
        explanationRef: "explain-gold-optional-013",
        designIntent: "orElseThrowで空Optionalを例外へ変換する流れを確認する。"
    )

    static let goldStream023 = Quiz(
        id: "gold-stream-023",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "filter", "distinct", "skip", "limit"],
        code: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        Stream.of(1, 2, 2, 3, 4)
            .filter(n -> n % 2 == 0)
            .distinct()
            .skip(1)
            .limit(1)
            .forEach(System.out::print);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "4", correct: true, misconception: nil, explanation: "偶数だけで2,2,4になり、distinctで2,4、skip(1)で4、limit(1)で4だけ出力します。"),
            Choice(id: "b", text: "2", correct: false, misconception: "skipを見落とし", explanation: "distinct後の先頭2はskip(1)で飛ばされます。"),
            Choice(id: "c", text: "24", correct: false, misconception: "limitを見落とし", explanation: "limit(1)により4だけです。"),
            Choice(id: "d", text: "224", correct: false, misconception: "distinctを見落とし", explanation: "distinctで重複した2は1つになります。"),
        ],
        explanationRef: "explain-gold-stream-023",
        designIntent: "複数の中間操作で要素列がどう変化するかを追わせる。"
    )

    static let goldStream024 = Quiz(
        id: "gold-stream-024",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "map", "flatMap", "count"],
        code: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        long a = Stream.of("ab", "cd")
            .map(s -> s.split(""))
            .count();
        long b = Stream.of("ab", "cd")
            .flatMap(s -> Arrays.stream(s.split("")))
            .count();
        System.out.println(a + ":" + b);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2:4", correct: true, misconception: nil, explanation: "mapは各文字列を配列1個に変換するため2件です。flatMapは配列内要素を平坦化するためa,b,c,dの4件です。"),
            Choice(id: "b", text: "4:4", correct: false, misconception: "mapも平坦化すると誤解", explanation: "mapはStream<String[]>を作るだけで、配列内の要素数までは数えません。"),
            Choice(id: "c", text: "2:2", correct: false, misconception: "flatMapをmapと同じだと誤解", explanation: "flatMapは内側のStreamを1本に平坦化します。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "Arrays.streamをflatMapに渡せないと誤解", explanation: "ラムダがStream<String>を返すためflatMapに適合します。"),
        ],
        explanationRef: "explain-gold-stream-024",
        designIntent: "mapとflatMapの戻り値の形の違いをcountで確認する。"
    )

    static let goldStream025 = Quiz(
        id: "gold-stream-025",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "sorted", "Comparator"],
        code: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        Stream.of("bb", "a", "ccc")
            .sorted(Comparator.comparingInt(String::length).reversed())
            .forEach(s -> System.out.print(s.length()));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "321", correct: true, misconception: nil, explanation: "長さ順のComparatorをreversedしているため、ccc(3), bb(2), a(1)の順です。"),
            Choice(id: "b", text: "123", correct: false, misconception: "reversedを見落とし", explanation: "reversedにより降順です。"),
            Choice(id: "c", text: "213", correct: false, misconception: "元の順序の長さを出力すると誤解", explanation: "sortedにより並び替えられます。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "Comparator.comparingIntにメソッド参照を渡せないと誤解", explanation: "String::lengthはToIntFunctionとして使えます。"),
        ],
        explanationRef: "explain-gold-stream-025",
        designIntent: "sortedとComparatorのreversedによる順序付けを確認する。"
    )

    static let goldStream026 = Quiz(
        id: "gold-stream-026",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "peek", "forEach", "終端操作"],
        code: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        Stream.of("A", "B")
            .peek(System.out::print)
            .forEach(s -> System.out.print(s.toLowerCase()));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "AaBb", correct: true, misconception: nil, explanation: "終端操作forEachがあるためpeekも実行されます。各要素ごとにpeekの大文字、forEachの小文字が出力されます。"),
            Choice(id: "b", text: "ABab", correct: false, misconception: "peekが全要素先に実行されると誤解", explanation: "Streamは要素ごとにパイプラインを流れるためA,a,B,bの順になります。"),
            Choice(id: "c", text: "ab", correct: false, misconception: "peekは常に無視されると誤解", explanation: "終端操作があるためpeekも実行されます。"),
            Choice(id: "d", text: "何も出力されない", correct: false, misconception: "peekだけでなくforEachも中間操作と誤解", explanation: "forEachは終端操作なのでパイプラインが実行されます。"),
        ],
        explanationRef: "explain-gold-stream-026",
        designIntent: "peekは中間操作だが、終端操作があるとパイプライン内で実行されることを確認する。"
    )

    static let goldStream027 = Quiz(
        id: "gold-stream-027",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "mapToInt", "boxed", "Collectors"],
        code: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        List<Integer> list = Stream.of("a", "bb", "ccc")
            .mapToInt(String::length)
            .boxed()
            .collect(Collectors.toList());
        System.out.println(list);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "[1, 2, 3]", correct: true, misconception: nil, explanation: "mapToIntでIntStreamになり、boxedでStream<Integer>へ戻してListにcollectします。"),
            Choice(id: "b", text: "[a, bb, ccc]", correct: false, misconception: "mapToIntの変換を見落とし", explanation: "文字列そのものではなく長さに変換しています。"),
            Choice(id: "c", text: "6", correct: false, misconception: "sumしていると誤解", explanation: "sumではなくcollect(Collectors.toList())です。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "IntStreamをList<Integer>にcollectできないと誤解", explanation: "boxed()でStream<Integer>に変換してからcollectしています。"),
        ],
        explanationRef: "explain-gold-stream-027",
        designIntent: "StreamからIntStream、さらにboxedで参照型Streamへ戻す型変換を確認する。"
    )

    static let goldStream028 = Quiz(
        id: "gold-stream-028",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "flatMapToInt", "IntStream", "sum"],
        code: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        int result = Stream.of("A", "B")
            .flatMapToInt(String::chars)
            .sum();
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "131", correct: true, misconception: nil, explanation: "String::charsは文字コードのIntStreamを返します。'A'は65、'B'は66なので合計は131です。"),
            Choice(id: "b", text: "2", correct: false, misconception: "文字数を数える処理と誤解", explanation: "countではなくsumです。"),
            Choice(id: "c", text: "AB", correct: false, misconception: "IntStreamではなく文字列が結合されると誤解", explanation: "flatMapToInt後はIntStreamです。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "String::charsをflatMapToIntに渡せないと誤解", explanation: "String::charsはIntStreamを返すためflatMapToIntに適合します。"),
        ],
        explanationRef: "explain-gold-stream-028",
        designIntent: "flatMapToIntで参照型StreamからIntStreamへ平坦化する動きを確認する。"
    )

    static let goldStream029 = Quiz(
        id: "gold-stream-029",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "Collectors", "joining", "map"],
        code: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        String result = Stream.of("a", "bb", "c")
            .map(String::toUpperCase)
            .collect(Collectors.joining("-"));
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "A-BB-C", correct: true, misconception: nil, explanation: "mapで大文字へ変換し、Collectors.joining(\"-\")でハイフン区切りに連結します。"),
            Choice(id: "b", text: "a-bb-c", correct: false, misconception: "mapの大文字変換を見落とし", explanation: "String::toUpperCaseが適用されます。"),
            Choice(id: "c", text: "[A, BB, C]", correct: false, misconception: "toListで収集すると誤解", explanation: "joiningはStringを返します。"),
            Choice(id: "d", text: "ABB C", correct: false, misconception: "区切り文字の扱いを誤解", explanation: "区切り文字は要素の間にだけ入ります。"),
        ],
        explanationRef: "explain-gold-stream-029",
        designIntent: "Collectors.joiningでStream<String>を1つの文字列へ終端処理する流れを確認する。"
    )

    static let goldStream030 = Quiz(
        id: "gold-stream-030",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "Collectors", "groupingBy", "counting"],
        code: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        Map<Integer, Long> map = Stream.of("a", "bb", "c")
            .collect(Collectors.groupingBy(
                String::length,
                Collectors.counting()
            ));
        System.out.println(map.get(1) + ":" + map.get(2));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2:1", correct: true, misconception: nil, explanation: "長さ1はaとcで2件、長さ2はbbで1件です。countingの値型はLongです。"),
            Choice(id: "b", text: "1:2", correct: false, misconception: "キー1と2の件数を逆に読んでいる", explanation: "map.get(1)が長さ1の件数です。"),
            Choice(id: "c", text: "2:null", correct: false, misconception: "長さ2のキーが作られないと誤解", explanation: "bbが長さ2なのでキー2が作られます。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "groupingByに下流Collectorを渡せないと誤解", explanation: "groupingBy(classifier, downstream)の形は有効です。"),
        ],
        explanationRef: "explain-gold-stream-030",
        designIntent: "Collectors.groupingByと下流countingの戻り値を確認する。"
    )

    static let goldStream031 = Quiz(
        id: "gold-stream-031",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "Collectors", "toMap", "重複キー"],
        code: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        try {
            Map<Integer, String> map = Stream.of("a", "b")
                .collect(Collectors.toMap(String::length, s -> s));
            System.out.println(map);
        } catch (IllegalStateException e) {
            System.out.println("duplicate");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "duplicate", correct: true, misconception: nil, explanation: "aとbはどちらも長さ1なのでtoMapのキーが重複します。マージ関数なしではIllegalStateExceptionです。"),
            Choice(id: "b", text: "{1=a}", correct: false, misconception: "後続要素が無視されると誤解", explanation: "重複キーは自動で無視されず、例外になります。"),
            Choice(id: "c", text: "{1=b}", correct: false, misconception: "後続値で自動上書きされると誤解", explanation: "上書きしたい場合はマージ関数を指定します。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "toMapでメソッド参照とラムダを混在できないと誤解", explanation: "型は合っています。実行時に重複キーで例外になります。"),
        ],
        explanationRef: "explain-gold-stream-031",
        designIntent: "Collectors.toMapの重複キー処理とマージ関数の必要性を確認する。"
    )
}
