import Foundation

extension QuizExpansion {
    static let goldGeneralExpansion: [Quiz] = [
        goldModule004,
        goldModule005,
        goldConcurrency010,
        goldConcurrency011,
        goldIo007,
        goldIo008,
        goldJdbc004,
        goldJdbc005,
        goldDateTime006,
        goldDateTime007,
        goldException021,
        goldException022,
        goldCollections026,
        goldCollections027,
        goldGenerics009,
        goldGenerics010,
        goldAnnotations013,
        goldAnnotations014,
        goldClasses008,
    ]

    static let goldModule004 = Quiz(
        id: "gold-module-004",
        level: .gold,
        validatedByJavac: false,
        category: "module-system",
        tags: ["module", "requires transitive", "readability"],
        code: """
// com.app/module-info.java
module com.app {
    requires transitive com.lib;
    exports com.app.api;
}

// com.client/module-info.java
module com.client {
    requires com.app;
}
""",
        question: "このモジュール定義の読み方として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "com.client は com.lib も読み込める", correct: true, misconception: nil, explanation: "com.app が com.lib を requires transitive しているため、com.app を requires する com.client からも com.lib が読み取り可能になります。"),
            Choice(id: "b", text: "com.client は com.app しか読み込めず com.lib は読めない", correct: false, misconception: "requires transitive を通常の requires と同じだと誤解", explanation: "transitive が付いている依存は、利用側へ読み取り関係が伝播します。"),
            Choice(id: "c", text: "com.lib の全パッケージが自動的に公開される", correct: false, misconception: "readability と exports を混同", explanation: "読み取り可能になることと、パッケージが公開されることは別です。com.lib 側が exports したパッケージだけ通常アクセスできます。"),
            Choice(id: "d", text: "requires transitive は実行時だけ有効でコンパイル時には無関係", correct: false, misconception: "モジュール読み取りを実行時専用と誤解", explanation: "requires transitive はコンパイル時のモジュール解決にも影響します。"),
        ],
        explanationRef: "explain-gold-module-004",
        designIntent: "requires transitive による読み取り関係の伝播と、exportsとの違いを確認する。"
    )

    static let goldModule005 = Quiz(
        id: "gold-module-005",
        level: .gold,
        validatedByJavac: false,
        category: "module-system",
        tags: ["module", "exports", "opens", "reflection"],
        code: """
module com.app {
    exports com.app.api;
    opens com.app.internal;
}
""",
        question: "この module-info.java の説明として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "com.app.api は通常アクセス用に公開され、com.app.internal は深いリフレクション用に開かれる", correct: true, misconception: nil, explanation: "exports は他モジュールからの通常のコンパイル時アクセスを許可し、opens は主に実行時の深いリフレクションを許可します。"),
            Choice(id: "b", text: "opens した com.app.internal は通常のimport対象としても公開される", correct: false, misconception: "opens と exports を同じ公開指定だと誤解", explanation: "opens は通常アクセスを公開しません。通常アクセスを許可するには exports が必要です。"),
            Choice(id: "c", text: "exports した com.app.api はリフレクションでprivateメンバまで常にアクセスできる", correct: false, misconception: "exports が deep reflection も許可すると誤解", explanation: "exports はpublic型などの通常アクセス向けです。privateメンバへの深いリフレクションはopensの役割です。"),
            Choice(id: "d", text: "exports と opens はどちらも実行時には無視される", correct: false, misconception: "モジュール記述子が実行時に影響しないと誤解", explanation: "モジュールシステムは実行時にも読み取りやリフレクションアクセスの制御に関わります。"),
        ],
        explanationRef: "explain-gold-module-005",
        designIntent: "exports と opens の用途差を、通常アクセスとリフレクションで整理する。"
    )

    static let goldConcurrency010 = Quiz(
        id: "gold-concurrency-010",
        level: .gold,
        category: "concurrency",
        tags: ["ExecutorService", "submit", "Future", "ExecutionException"],
        code: """
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) throws Exception {
        ExecutorService service = Executors.newSingleThreadExecutor();
        Future<Integer> future = service.submit(() -> {
            throw new IllegalStateException("boom");
        });
        try {
            System.out.println(future.get());
        } catch (ExecutionException e) {
            System.out.println(e.getCause().getClass().getSimpleName());
        } finally {
            service.shutdown();
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "IllegalStateException", correct: true, misconception: nil, explanation: "submitしたタスク内の例外はFutureに保持され、get()時にExecutionExceptionで包まれます。getCause()の実体はIllegalStateExceptionです。"),
            Choice(id: "b", text: "ExecutionException", correct: false, misconception: "catchした型がそのまま出力されると誤解", explanation: "出力しているのはeではなくe.getCause().getClass().getSimpleName()です。"),
            Choice(id: "c", text: "boom", correct: false, misconception: "例外メッセージが出力されると誤解", explanation: "メッセージではなく、原因例外のクラス名を出力しています。"),
            Choice(id: "d", text: "何も出力されずスレッドだけ終了する", correct: false, misconception: "submitした例外が捨てられると誤解", explanation: "例外はFutureに保持され、get()で観測できます。"),
        ],
        explanationRef: "explain-gold-concurrency-010",
        designIntent: "ExecutorService.submitで発生した例外がFuture.getでExecutionExceptionとして取り出されることを確認する。"
    )

    static let goldConcurrency011 = Quiz(
        id: "gold-concurrency-011",
        level: .gold,
        category: "concurrency",
        tags: ["ExecutorService", "invokeAll", "Future", "順序"],
        code: """
import java.util.*;
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) throws Exception {
        ExecutorService service = Executors.newFixedThreadPool(2);
        List<Callable<String>> tasks = List.of(
            () -> { Thread.sleep(100); return "A"; },
            () -> "B"
        );
        List<Future<String>> futures = service.invokeAll(tasks);
        System.out.println(futures.get(0).get() + futures.get(1).get());
        service.shutdown();
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "AB", correct: true, misconception: nil, explanation: "invokeAllの戻り値のListは、完了順ではなく渡したtasksの順序に対応します。Aのタスクが遅くてもfutures.get(0)はAです。"),
            Choice(id: "b", text: "BA", correct: false, misconception: "Futureの並びが完了順になると誤解", explanation: "Bの方が早く完了しても、戻りListの順序は入力タスクの順序です。"),
            Choice(id: "c", text: "Aだけ", correct: false, misconception: "2つ目のFutureを取り出していないと誤解", explanation: "futures.get(0)とfutures.get(1)の両方をgetしています。"),
            Choice(id: "d", text: "TimeoutException", correct: false, misconception: "sleepがあるとタイムアウトすると誤解", explanation: "タイムアウト付きgetは使っていません。invokeAllは全タスク完了を待ちます。"),
        ],
        explanationRef: "explain-gold-concurrency-011",
        designIntent: "invokeAllの戻り値順序が入力タスク順であることを確認する。"
    )

    static let goldIo007 = Quiz(
        id: "gold-io-007",
        level: .gold,
        category: "io",
        tags: ["Path", "resolve", "absolute path", "normalize"],
        code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path base = Path.of("/app/data");
        Path result = base.resolve("/tmp/file.txt").normalize();
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "/tmp/file.txt", correct: true, misconception: nil, explanation: "resolveの右辺が絶対パスの場合、base配下に結合されず右辺が結果になります。normalizeしてもこのパスは変わりません。"),
            Choice(id: "b", text: "/app/data/tmp/file.txt", correct: false, misconception: "絶対パスもbaseへ結合されると誤解", explanation: "右辺が絶対パスなら右辺が優先されます。"),
            Choice(id: "c", text: "/app/tmp/file.txt", correct: false, misconception: "normalizeがbaseを一段戻すと誤解", explanation: "今回のパスには..がないためnormalizeで階層は変わりません。"),
            Choice(id: "d", text: "InvalidPathException", correct: false, misconception: "絶対パスをresolveできないと誤解", explanation: "絶対パスをresolveすること自体は可能です。結果が右辺になるだけです。"),
        ],
        explanationRef: "explain-gold-io-007",
        designIntent: "Path.resolveで右辺が絶対パスの場合の挙動を確認する。"
    )

    static let goldIo008 = Quiz(
        id: "gold-io-008",
        level: .gold,
        category: "io",
        tags: ["Files.lines", "try-with-resources", "Stream", "NIO.2"],
        code: """
import java.nio.file.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) throws Exception {
        Path path = Files.createTempFile("jvs", ".txt");
        Files.writeString(path, "a\\nbb\\n");
        try (Stream<String> lines = Files.lines(path)) {
            long count = lines.filter(s -> s.length() == 2).count();
            System.out.println(count);
        }
        Files.deleteIfExists(path);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1", correct: true, misconception: nil, explanation: "Files.linesは行のStreamを返します。行はaとbbで、長さ2の行はbbだけなのでcountは1です。try-with-resourcesでStreamも閉じられます。"),
            Choice(id: "b", text: "2", correct: false, misconception: "全行数をそのまま数えると誤解", explanation: "filterで長さ2の行だけに絞っています。"),
            Choice(id: "c", text: "0", correct: false, misconception: "改行文字もlengthに含まれると誤解", explanation: "Files.linesで得られる各行文字列には行末の改行は含まれません。bbのlengthは2です。"),
            Choice(id: "d", text: "IllegalStateException", correct: false, misconception: "try内のStream操作が閉じた後に行われると誤解", explanation: "countはtryブロック内で実行されます。閉じるのはブロックを抜ける時です。"),
        ],
        explanationRef: "explain-gold-io-008",
        designIntent: "Files.linesがStreamを返し、try-with-resourcesで閉じる必要があることを確認する。"
    )

    static let goldJdbc004 = Quiz(
        id: "gold-jdbc-004",
        level: .gold,
        validatedByJavac: false,
        category: "jdbc",
        tags: ["JDBC", "ResultSet", "cursor", "next"],
        code: """
ResultSet rs = stmt.executeQuery("select id from users");
int id = rs.getInt(1);
System.out.println(id);
""",
        question: "このJDBCコードの問題点として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "ResultSet.next() を呼ぶ前に値を取得している", correct: true, misconception: nil, explanation: "ResultSetのカーソルは最初、先頭行の前にあります。値を読む前にnext()で行へ移動する必要があります。"),
            Choice(id: "b", text: "getInt(1) は必ずコンパイルエラーになる", correct: false, misconception: "JDBC列番号が0始まりだと誤解", explanation: "列番号は1始まりです。getInt(1)自体は正しい呼び出しです。"),
            Choice(id: "c", text: "executeQuery() はResultSetを返せない", correct: false, misconception: "executeUpdateと混同", explanation: "SELECT文にはexecuteQueryを使い、ResultSetを受け取ります。"),
            Choice(id: "d", text: "ResultSetはtry-with-resourcesでは閉じられない", correct: false, misconception: "ResultSetがAutoCloseableでないと誤解", explanation: "ResultSetはAutoCloseableなので、通常はtry-with-resourcesで閉じられます。"),
        ],
        explanationRef: "explain-gold-jdbc-004",
        designIntent: "ResultSetのカーソル初期位置とnext()の必要性を確認する。"
    )

    static let goldJdbc005 = Quiz(
        id: "gold-jdbc-005",
        level: .gold,
        validatedByJavac: false,
        category: "jdbc",
        tags: ["JDBC", "PreparedStatement", "parameter index"],
        code: """
PreparedStatement ps = con.prepareStatement(
    "select * from users where id = ? and name = ?"
);
ps.setInt(0, 10);
ps.setString(1, "Alice");
ResultSet rs = ps.executeQuery();
""",
        question: "このPreparedStatementの扱いとして正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "ps.setInt(0, 10) が誤り。パラメータ番号は1始まり", correct: true, misconception: nil, explanation: "PreparedStatementのプレースホルダ番号は1から始まります。最初の?は1、次の?は2です。"),
            Choice(id: "b", text: "ps.setString(1, \"Alice\") が2番目の?に対応する", correct: false, misconception: "0始まりの添字と混同", explanation: "setString(1, ...)は1番目の?に対応します。2番目はsetString(2, ...)です。"),
            Choice(id: "c", text: "executeQuery()ではなくexecuteUpdate()を使うべき", correct: false, misconception: "SELECTと更新系SQLを混同", explanation: "SELECT文なのでexecuteQuery()でResultSetを受け取ります。"),
            Choice(id: "d", text: "プレースホルダは名前で指定するため番号は使えない", correct: false, misconception: "標準JDBCに名前付きパラメータがあると誤解", explanation: "標準のPreparedStatementは番号でパラメータを指定します。"),
        ],
        explanationRef: "explain-gold-jdbc-005",
        designIntent: "PreparedStatementのパラメータ番号が1始まりであることを確認する。"
    )

    static let goldDateTime006 = Quiz(
        id: "gold-date-time-006",
        level: .gold,
        category: "date-time",
        tags: ["LocalDate", "leap year", "plusYears"],
        code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        LocalDate date = LocalDate.of(2024, 2, 29).plusYears(1);
        System.out.println(date);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2025-02-28", correct: true, misconception: nil, explanation: "2025年には2月29日が存在しないため、LocalDate.plusYears(1)は有効な日付である2025-02-28へ調整します。"),
            Choice(id: "b", text: "2025-03-01", correct: false, misconception: "存在しない日付が翌月へ繰り越されると誤解", explanation: "plusYearsはこのケースで2月の最終日へ調整します。"),
            Choice(id: "c", text: "2024-02-29", correct: false, misconception: "LocalDateが不変なので変化しないと誤解", explanation: "LocalDateは不変ですが、plusYearsは新しいLocalDateを返し、それをdateに代入しています。"),
            Choice(id: "d", text: "DateTimeException", correct: false, misconception: "存在しない日付になる操作は常に例外と誤解", explanation: "このplusYearsの結果は有効な日付へ調整されます。"),
        ],
        explanationRef: "explain-gold-date-time-006",
        designIntent: "うるう日のLocalDateに対するplusYearsの調整挙動を確認する。"
    )

    static let goldDateTime007 = Quiz(
        id: "gold-date-time-007",
        level: .gold,
        category: "date-time",
        tags: ["LocalTime", "Duration", "Period", "immutability"],
        code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        LocalTime time = LocalTime.of(23, 30).plus(Duration.ofMinutes(90));
        LocalDate date = LocalDate.of(2024, 1, 1).plus(Period.ofDays(1));
        System.out.println(date + " " + time);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2024-01-02 01:00", correct: true, misconception: nil, explanation: "LocalTimeは24時を超えると日付情報を持たず時刻だけが01:00へ回ります。LocalDate側はPeriod.ofDays(1)で2024-01-02です。"),
            Choice(id: "b", text: "2024-01-02 25:00", correct: false, misconception: "LocalTimeが24時以上を保持すると誤解", explanation: "LocalTimeは00:00から23:59:59.999...の範囲で表現されます。"),
            Choice(id: "c", text: "2024-01-01 01:00", correct: false, misconception: "Period.ofDays(1)を見落とし", explanation: "dateにはplusの戻り値を代入しているため1日進みます。"),
            Choice(id: "d", text: "DateTimeException", correct: false, misconception: "23:30に90分足すと例外になると誤解", explanation: "LocalTimeの加算は24時間で循環します。"),
        ],
        explanationRef: "explain-gold-date-time-007",
        designIntent: "DurationとPeriodの対象、LocalTimeの循環、日時APIの不変性を確認する。"
    )

    static let goldException021 = Quiz(
        id: "gold-exception-021",
        level: .gold,
        category: "exception-handling",
        tags: ["try-with-resources", "AutoCloseable", "close order"],
        code: """
class R implements AutoCloseable {
    private final String name;
    R(String name) { this.name = name; }
    public void close() {
        System.out.print(name);
    }
}

public class Test {
    public static void main(String[] args) {
        try (R a = new R("A"); R b = new R("B")) { // close order is reverse of declaration
            System.out.print("T");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "TBA", correct: true, misconception: nil, explanation: "tryブロックでTを出力した後、リソースは宣言と逆順に閉じられます。bが先にB、aが後にAを出力します。"),
            Choice(id: "b", text: "TAB", correct: false, misconception: "リソースが宣言順に閉じられると誤解", explanation: "try-with-resourcesのcloseは逆順です。"),
            Choice(id: "c", text: "ABT", correct: false, misconception: "tryブロック前にcloseされると誤解", explanation: "closeはtryブロックを抜ける時に呼ばれます。"),
            Choice(id: "d", text: "T", correct: false, misconception: "closeが自動実行されないと誤解", explanation: "AutoCloseableリソースは自動的にcloseされます。"),
        ],
        explanationRef: "explain-gold-exception-021",
        designIntent: "try-with-resourcesで複数リソースが逆順にcloseされることを確認する。"
    )

    static let goldException022 = Quiz(
        id: "gold-exception-022",
        level: .gold,
        category: "exception-handling",
        tags: ["try-with-resources", "suppressed exception", "AutoCloseable"],
        code: """
class R implements AutoCloseable {
    public void close() throws Exception {
        throw new Exception("close");
    }
}

public class Test {
    public static void main(String[] args) {
        try (R r = new R()) {
            throw new Exception("body");
        } catch (Exception e) {
            System.out.println(e.getMessage() + ":" + e.getSuppressed()[0].getMessage());
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "body:close", correct: true, misconception: nil, explanation: "tryブロックの例外bodyが主例外です。close時の例外closeは握りつぶされず、suppressed例外として主例外に追加されます。"),
            Choice(id: "b", text: "close:body", correct: false, misconception: "closeの例外が主例外を上書きすると誤解", explanation: "tryブロックで先に発生した例外が主例外で、closeの例外はsuppressedになります。"),
            Choice(id: "c", text: "body", correct: false, misconception: "suppressed例外が消えると誤解", explanation: "suppressed例外はgetSuppressed()で取得できます。"),
            Choice(id: "d", text: "ArrayIndexOutOfBoundsException", correct: false, misconception: "suppressedが空だと誤解", explanation: "closeも例外を投げているためsuppressed[0]が存在します。"),
        ],
        explanationRef: "explain-gold-exception-022",
        designIntent: "try-with-resourcesでtry本体とcloseの両方が例外を投げた時のsuppressed例外を確認する。"
    )

    static let goldCollections026 = Quiz(
        id: "gold-collections-026",
        level: .gold,
        category: "collections",
        tags: ["Map", "merge", "LinkedHashMap"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Map<String, Integer> map = new LinkedHashMap<>();
        map.put("A", 1);
        map.merge("A", 2, Integer::sum);
        map.merge("B", 3, Integer::sum);
        System.out.println(map);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "{A=3, B=3}", correct: true, misconception: nil, explanation: "既存キーAには現在値1と新しい値2をInteger::sumで結合して3を格納します。存在しないBには値3がそのまま格納されます。"),
            Choice(id: "b", text: "{A=2, B=3}", correct: false, misconception: "mergeが常に上書きすると誤解", explanation: "既存キーでは第3引数の関数で現在値と新値を結合します。"),
            Choice(id: "c", text: "{A=1, B=3}", correct: false, misconception: "既存キーではmergeが何もしないと誤解", explanation: "既存キーAの値は1から3に更新されます。"),
            Choice(id: "d", text: "{B=3, A=3}", correct: false, misconception: "LinkedHashMapの挿入順を見落とし", explanation: "LinkedHashMapは挿入順を保持します。Aが先、Bが後です。"),
        ],
        explanationRef: "explain-gold-collections-026",
        designIntent: "Map.mergeの既存キーと新規キーでの動作差を確認する。"
    )

    static let goldCollections027 = Quiz(
        id: "gold-collections-027",
        level: .gold,
        category: "collections",
        tags: ["Collection", "removeIf", "Predicate"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<Integer> list = new ArrayList<>(List.of(1, 2, 3, 4));
        boolean changed = list.removeIf(n -> n % 2 == 0);
        System.out.println(changed + ":" + list);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "true:[1, 3]", correct: true, misconception: nil, explanation: "removeIfは条件がtrueの要素を削除します。偶数2と4が削除され、変更があったため戻り値はtrueです。"),
            Choice(id: "b", text: "false:[1, 3]", correct: false, misconception: "removeIfの戻り値を削除後の空判定と誤解", explanation: "戻り値はコレクションが変更されたかどうかです。"),
            Choice(id: "c", text: "true:[2, 4]", correct: false, misconception: "条件に合う要素を残すと誤解", explanation: "removeIfは条件に合う要素を取り除きます。"),
            Choice(id: "d", text: "UnsupportedOperationException", correct: false, misconception: "List.ofで作ったリスト自体を変更していると誤解", explanation: "new ArrayList<>(List.of(...))で変更可能なArrayListを作っています。"),
        ],
        explanationRef: "explain-gold-collections-027",
        designIntent: "removeIfがPredicateに一致した要素を削除し、変更有無を返すことを確認する。"
    )

    static let goldGenerics009 = Quiz(
        id: "gold-generics-009",
        level: .gold,
        category: "generics",
        tags: ["Generics", "PECS", "extends", "super"],
        code: """
import java.util.*;

public class Test {
    static <T> void copy(List<? super T> dst, List<? extends T> src) {
        for (T value : src) {
            dst.add(value);
        }
    }

    public static void main(String[] args) {
        List<Number> numbers = new ArrayList<>();
        List<Integer> integers = List.of(1, 2);
        copy(numbers, integers);
        System.out.println(numbers);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "[1, 2]", correct: true, misconception: nil, explanation: "srcは? extends TなのでTとして読み出せます。dstは? super TなのでTを追加できます。IntegerからTを推論し、List<Number>へ追加できます。"),
            Choice(id: "b", text: "[]", correct: false, misconception: "copy内の追加が呼び出し元へ反映されないと誤解", explanation: "numbersとdstは同じArrayListインスタンスを参照しています。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "List<Integer>をList<Number>へ渡せない不変性だけで判断", explanation: "直接List<Number>に代入しているのではなく、extends/superワイルドカードを使ったメソッドです。"),
            Choice(id: "d", text: "ClassCastException", correct: false, misconception: "NumberリストにIntegerを入れると実行時エラーと誤解", explanation: "IntegerはNumberのサブクラスなのでList<Number>へ格納できます。"),
        ],
        explanationRef: "explain-gold-generics-009",
        designIntent: "PECSを使ったcopyメソッドで、読み出し側extendsと書き込み側superを確認する。"
    )

    static let goldGenerics010 = Quiz(
        id: "gold-generics-010",
        level: .gold,
        category: "generics",
        tags: ["Generics", "wildcard", "extends", "null"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<? extends Number> values = new ArrayList<Integer>(List.of(1, 2));
        Number first = values.get(0);
        values.add(null);
        System.out.println(values.size() + ":" + first.intValue());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "3:1", correct: true, misconception: nil, explanation: "? extends NumberからはNumberとして読み出せます。非null値は追加できませんが、nullだけは追加できるためサイズは3になります。"),
            Choice(id: "b", text: "2:1", correct: false, misconception: "values.add(null)が無視されると誤解", explanation: "ArrayListはnullを許容し、add(null)は実際に要素を追加します。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "? extends Numberにはnullも追加できないと誤解", explanation: "具体的なNumber値は追加できませんが、nullはすべての参照型に代入可能なので追加できます。"),
            Choice(id: "d", text: "UnsupportedOperationException", correct: false, misconception: "List.ofの変更不可リストを直接変更していると誤解", explanation: "new ArrayList<Integer>(List.of(...))で変更可能なArrayListを作っています。"),
        ],
        explanationRef: "explain-gold-generics-010",
        designIntent: "? extends の読み出しと、nullだけ追加可能という例外的なルールを確認する。"
    )

    static let goldAnnotations013 = Quiz(
        id: "gold-annotations-013",
        level: .gold,
        category: "annotations",
        tags: ["Annotation", "@Inherited", "Retention", "reflection"],
        code: """
import java.lang.annotation.*;

@Inherited
@Retention(RetentionPolicy.RUNTIME)
@interface Mark {}

@Mark
class Base {}

public class Test extends Base {
    public static void main(String[] args) {
        System.out.println(Test.class.isAnnotationPresent(Mark.class));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "true", correct: true, misconception: nil, explanation: "@Inheritedが付いたクラスアノテーションは、サブクラスのClassオブジェクトで検索したときに継承されたものとして扱われます。RetentionPolicy.RUNTIMEなので実行時に取得できます。"),
            Choice(id: "b", text: "false", correct: false, misconception: "@Inheritedを見落とし", explanation: "@Inheritedがあり、Baseに@Markが付いているためTestでもisAnnotationPresentがtrueになります。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "@Inheritedは自作アノテーションに使えないと誤解", explanation: "@Inheritedはアノテーション型に付けるメタアノテーションです。"),
            Choice(id: "d", text: "RetentionPolicy.CLASS", correct: false, misconception: "出力対象をRetention値と混同", explanation: "出力しているのはisAnnotationPresentのbooleanです。"),
        ],
        explanationRef: "explain-gold-annotations-013",
        designIntent: "@InheritedとRUNTIME保持による実行時アノテーション検索を確認する。"
    )

    static let goldAnnotations014 = Quiz(
        id: "gold-annotations-014",
        level: .gold,
        category: "annotations",
        tags: ["Annotation", "@Repeatable", "container", "reflection"],
        code: """
import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)
@Repeatable(Tags.class)
@interface Tag {
    String value();
}

@Retention(RetentionPolicy.RUNTIME)
@interface Tags {
    Tag[] value();
}

@Tag("a")
@Tag("b")
public class Test {
    public static void main(String[] args) {
        Tag[] tags = Test.class.getAnnotationsByType(Tag.class);
        System.out.println(tags.length + ":" + tags[0].value() + tags[1].value());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2:ab", correct: true, misconception: nil, explanation: "@RepeatableによりTagを同じ対象へ複数付けられます。getAnnotationsByType(Tag.class)はコンテナを展開して2つのTagを返します。"),
            Choice(id: "b", text: "1:a", correct: false, misconception: "繰り返しアノテーションが1つにまとめられて見えると誤解", explanation: "getAnnotationsByTypeは繰り返しアノテーションを展開します。"),
            Choice(id: "c", text: "2:ba", correct: false, misconception: "取得順が逆になると誤解", explanation: "この宣言ではa、bの順に取得されます。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "@Repeatableにコンテナを指定しても複数付けられないと誤解", explanation: "コンテナアノテーションTagsがTag[] value()を持っているため正しい定義です。"),
        ],
        explanationRef: "explain-gold-annotations-014",
        designIntent: "@RepeatableのコンテナアノテーションとgetAnnotationsByTypeの展開を確認する。"
    )

    static let goldClasses008 = Quiz(
        id: "gold-classes-008",
        level: .gold,
        category: "classes",
        tags: ["record", "compact constructor", "immutable"],
        code: """
record Point(int x, int y) {
    Point {
        if (x < 0) {
            x = 0;
        }
    }
}

public class Test {
    public static void main(String[] args) {
        Point p = new Point(-1, 2);
        System.out.println(p.x() + ":" + p.y());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "0:2", correct: true, misconception: nil, explanation: "recordのコンパクトコンストラクタでは、本文の後に正規コンストラクタのフィールド代入が暗黙に行われます。パラメータxを0に変更したため、xコンポーネントは0になります。"),
            Choice(id: "b", text: "-1:2", correct: false, misconception: "コンパクトコンストラクタ内のパラメータ変更が反映されないと誤解", explanation: "暗黙のフィールド代入はコンストラクタ本文の後に、現在のパラメータ値を使って行われます。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "recordのコンパクトコンストラクタでパラメータを変更できないと誤解", explanation: "コンパクトコンストラクタ内でパラメータ変数へ再代入することは可能です。"),
            Choice(id: "d", text: "IllegalArgumentException", correct: false, misconception: "負数チェックは例外を投げるはずと推測", explanation: "このコードは例外を投げず、xを0に補正しています。"),
        ],
        explanationRef: "explain-gold-classes-008",
        designIntent: "recordのコンパクトコンストラクタで、パラメータ補正後に暗黙代入される流れを確認する。"
    )
}
