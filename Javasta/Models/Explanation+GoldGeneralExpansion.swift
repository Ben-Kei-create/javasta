import Foundation

extension Explanation {
    static let goldGeneralAuthoredSamples: [String: Explanation] = [
        goldModule004Explanation.id: goldModule004Explanation,
        goldModule005Explanation.id: goldModule005Explanation,
        goldConcurrency010Explanation.id: goldConcurrency010Explanation,
        goldConcurrency011Explanation.id: goldConcurrency011Explanation,
        goldIo007Explanation.id: goldIo007Explanation,
        goldIo008Explanation.id: goldIo008Explanation,
        goldJdbc004Explanation.id: goldJdbc004Explanation,
        goldJdbc005Explanation.id: goldJdbc005Explanation,
        goldDateTime006Explanation.id: goldDateTime006Explanation,
        goldDateTime007Explanation.id: goldDateTime007Explanation,
        goldException021Explanation.id: goldException021Explanation,
        goldException022Explanation.id: goldException022Explanation,
        goldCollections026Explanation.id: goldCollections026Explanation,
        goldCollections027Explanation.id: goldCollections027Explanation,
        goldGenerics009Explanation.id: goldGenerics009Explanation,
        goldGenerics010Explanation.id: goldGenerics010Explanation,
        goldAnnotations013Explanation.id: goldAnnotations013Explanation,
        goldAnnotations014Explanation.id: goldAnnotations014Explanation,
        goldClasses008Explanation.id: goldClasses008Explanation,
    ]

    private static func goldGeneralStep(
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

    private static func goldGeneralPrompt(
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

    static let goldModule004Explanation = Explanation(
        id: "explain-gold-module-004",
        initialCode: """
module com.app {
    requires transitive com.lib;
    exports com.app.api;
}

module com.client {
    requires com.app;
}
""",
        steps: [
            goldGeneralStep(0, "`com.app` は `com.lib` を `requires transitive` しています。通常の `requires` と違い、この依存は利用側へ読み取り関係が伝播します。", [1, 2], variables: [Variable(name: "com.app reads", type: "module", value: "com.lib", scope: "module graph")]),
            goldGeneralStep(1, "`com.client` は直接には `com.app` だけを `requires` しています。しかし `com.app` の transitive 依存により、`com.client` からも `com.lib` を読めます。", [6, 7], variables: [Variable(name: "com.client reads", type: "module", value: "com.app + com.lib", scope: "module graph")], predict: goldGeneralPrompt("com.clientからcom.libは読める？", ["読める", "読めない"], 0, "transitiveが付いた依存です。", "正解です。読み取り関係が伝播します。")),
            goldGeneralStep(2, "ただし、読めることとパッケージが公開されることは別です。`com.lib` の型へ通常アクセスできるかは、`com.lib` 側の `exports` に依存します。", [2, 3], variables: [Variable(name: "important distinction", type: "rule", value: "readability != exports", scope: "module system")]),
        ]
    )

    static let goldModule005Explanation = Explanation(
        id: "explain-gold-module-005",
        initialCode: """
module com.app {
    exports com.app.api;
    opens com.app.internal;
}
""",
        steps: [
            goldGeneralStep(0, "`exports com.app.api` は、他モジュールから `com.app.api` パッケージ内のpublic型へ通常アクセスできるようにします。コンパイル時のimportや型参照に関係します。", [2], variables: [Variable(name: "com.app.api", type: "package", value: "exported", scope: "module")]),
            goldGeneralStep(1, "`opens com.app.internal` は、通常アクセスではなく深いリフレクション向けです。フレームワークがprivateメンバへ反射的にアクセスするような場面で効きます。", [3], variables: [Variable(name: "com.app.internal", type: "package", value: "opened for reflection", scope: "module")], predict: goldGeneralPrompt("opensだけで通常のimport対象になる？", ["なる", "ならない"], 1, "通常アクセスはexportsです。", "正解です。opensは通常アクセスの公開ではありません。")),
            goldGeneralStep(2, "したがって、`api` は通常公開、`internal` はリフレクション用に開いている、という読み方になります。exportsとopensを同じ『公開』として扱わないのが大切です。", [2, 3]),
        ]
    )

    static let goldConcurrency010Explanation = Explanation(
        id: "explain-gold-concurrency-010",
        initialCode: """
Future<Integer> future = service.submit(() -> {
    throw new IllegalStateException("boom");
});
try {
    System.out.println(future.get());
} catch (ExecutionException e) {
    System.out.println(e.getCause().getClass().getSimpleName());
}
""",
        steps: [
            goldGeneralStep(0, "`submit` で渡したCallableは別スレッドで実行されます。Callable内では `IllegalStateException(\"boom\")` が投げられ、タスクは例外完了します。", [1, 2], variables: [Variable(name: "task state", type: "Future<Integer>", value: "failed with IllegalStateException", scope: "executor")]),
            goldGeneralStep(1, "タスク内の例外はその場でmainへ直接投げられるのではなく、Futureに保持されます。`future.get()` を呼んだ時点で `ExecutionException` に包まれて観測されます。", [4, 5, 6], variables: [Variable(name: "e", type: "ExecutionException", value: "cause = IllegalStateException", scope: "catch")], predict: goldGeneralPrompt("get()でcatchされる型は？", ["IllegalStateException", "ExecutionException"], 1, "Future.getの契約です。", "正解です。原因例外はExecutionExceptionに包まれます。")),
            goldGeneralStep(2, "出力しているのは `e.getCause().getClass().getSimpleName()` です。原因例外の実体クラス名なので `IllegalStateException` が表示されます。", [7], variables: [Variable(name: "output", type: "String", value: "IllegalStateException", scope: "main")]),
        ]
    )

    static let goldConcurrency011Explanation = Explanation(
        id: "explain-gold-concurrency-011",
        initialCode: """
List<Callable<String>> tasks = List.of(
    () -> { Thread.sleep(100); return "A"; },
    () -> "B"
);
List<Future<String>> futures = service.invokeAll(tasks);
System.out.println(futures.get(0).get() + futures.get(1).get());
""",
        steps: [
            goldGeneralStep(0, "2つのCallableを入力Listに並べています。1つ目は少し待ってAを返し、2つ目はすぐBを返します。完了順だけ見ればBの方が早い可能性が高いです。", [1, 2, 3], variables: [Variable(name: "tasks", type: "List<Callable<String>>", value: "[A task, B task]", scope: "main")]),
            goldGeneralStep(1, "`invokeAll(tasks)` は全タスクの完了を待ち、FutureのListを返します。このListの順序は完了順ではなく、入力したtasksの順序に対応します。", [5], variables: [Variable(name: "futures[0]", type: "Future<String>", value: "A task", scope: "main"), Variable(name: "futures[1]", type: "Future<String>", value: "B task", scope: "main")], predict: goldGeneralPrompt("futuresの並びは何順？", ["入力順", "完了順"], 0, "invokeAllの戻り値の契約です。", "正解です。入力Collectionの順序です。")),
            goldGeneralStep(2, "`futures.get(0).get()` はA、`futures.get(1).get()` はBを返すため、出力は `AB` です。", [6], variables: [Variable(name: "output", type: "String", value: "AB", scope: "main")]),
        ]
    )

    static let goldIo007Explanation = Explanation(
        id: "explain-gold-io-007",
        initialCode: """
Path base = Path.of("/app/data");
Path result = base.resolve("/tmp/file.txt").normalize();
System.out.println(result);
""",
        steps: [
            goldGeneralStep(0, "`base` は `/app/data` です。`resolve` は右辺が相対パスならbase配下へ結合します。", [1], variables: [Variable(name: "base", type: "Path", value: "/app/data", scope: "main")]),
            goldGeneralStep(1, "今回の右辺 `\"/tmp/file.txt\"` は絶対パスです。この場合、`base.resolve(...)` の結果はbaseを無視して右辺の絶対パスになります。", [2], variables: [Variable(name: "result before normalize", type: "Path", value: "/tmp/file.txt", scope: "main")], predict: goldGeneralPrompt("絶対パスをresolveした結果は？", ["base配下", "右辺が優先"], 1, "右辺が/で始まります。", "正解です。右辺の絶対パスが結果になります。")),
            goldGeneralStep(2, "`normalize()` は `.` や `..` を整理しますが、今回のパスにはそれらがないため変化しません。出力は `/tmp/file.txt` です。", [2, 3], variables: [Variable(name: "output", type: "String", value: "/tmp/file.txt", scope: "main")]),
        ]
    )

    static let goldIo008Explanation = Explanation(
        id: "explain-gold-io-008",
        initialCode: """
Path path = Files.createTempFile("jvs", ".txt");
Files.writeString(path, "a\\nbb\\n");
try (Stream<String> lines = Files.lines(path)) {
    long count = lines.filter(s -> s.length() == 2).count();
    System.out.println(count);
}
Files.deleteIfExists(path);
""",
        steps: [
            goldGeneralStep(0, "一時ファイルに2行を書き込みます。内容は1行目が `a`、2行目が `bb` です。", [1, 2], variables: [Variable(name: "file lines", type: "String", value: "a / bb", scope: "temp file")]),
            goldGeneralStep(1, "`Files.lines(path)` は行ごとの `Stream<String>` を返します。行末の改行文字は各Stringには含まれません。try-with-resourcesにより、処理後にStreamも閉じられます。", [3], variables: [Variable(name: "lines", type: "Stream<String>", value: "a, bb", scope: "try")]),
            goldGeneralStep(2, "`filter(s -> s.length() == 2)` で長さ2の行だけを残します。`a` は長さ1、`bb` は長さ2なので、countは1です。", [4, 5], variables: [Variable(name: "count", type: "long", value: "1", scope: "try")], predict: goldGeneralPrompt("改行はlengthに含まれる？", ["含まれる", "含まれない"], 1, "Files.linesは行文字列を返します。", "正解です。行末の改行は含まれません。")),
        ]
    )

    static let goldJdbc004Explanation = Explanation(
        id: "explain-gold-jdbc-004",
        initialCode: """
ResultSet rs = stmt.executeQuery("select id from users");
int id = rs.getInt(1);
System.out.println(id);
""",
        steps: [
            goldGeneralStep(0, "`executeQuery` はSELECT結果を表す `ResultSet` を返します。ただし、作成直後のカーソルは先頭行そのものではなく『先頭行の前』にあります。", [1], variables: [Variable(name: "cursor", type: "ResultSet", value: "before first row", scope: "JDBC")]),
            goldGeneralStep(1, "値を読むには、まず `rs.next()` で次の行へ移動します。`next()` がtrueなら、その行の列値を `getInt(1)` などで読めます。", [1, 2], predict: goldGeneralPrompt("getInt前に必要なのは？", ["next()", "close()"], 0, "カーソルを行へ進めます。", "正解です。まずnext()で行へ移動します。")),
            goldGeneralStep(2, "このコードは `next()` を呼ばずに `getInt(1)` しているため、カーソル位置が不正です。列番号1自体は正しいですが、読むタイミングが誤りです。", [2], variables: [Variable(name: "problem", type: "JDBC cursor", value: "read before next()", scope: "ResultSet")]),
        ]
    )

    static let goldJdbc005Explanation = Explanation(
        id: "explain-gold-jdbc-005",
        initialCode: """
PreparedStatement ps = con.prepareStatement(
    "select * from users where id = ? and name = ?"
);
ps.setInt(0, 10);
ps.setString(1, "Alice");
ResultSet rs = ps.executeQuery();
""",
        steps: [
            goldGeneralStep(0, "SQLには `?` が2つあります。標準JDBCのPreparedStatementでは、プレースホルダ番号は配列のような0始まりではなく1始まりです。", [1, 2, 3], variables: [Variable(name: "first ?", type: "parameter", value: "index 1", scope: "PreparedStatement"), Variable(name: "second ?", type: "parameter", value: "index 2", scope: "PreparedStatement")]),
            goldGeneralStep(1, "`ps.setInt(0, 10)` は0番目を指定しているため誤りです。最初の `id = ?` へ10を入れるなら `ps.setInt(1, 10)` です。", [4], predict: goldGeneralPrompt("JDBCパラメータ番号の開始は？", ["0", "1"], 1, "ResultSet列番号と同じく1始まりです。", "正解です。PreparedStatementも1始まりです。")),
            goldGeneralStep(2, "`ps.setString(1, \"Alice\")` も、このままだと1番目の `?` へAliceを設定しようとします。name側へ入れるには2番を指定します。", [5], variables: [Variable(name: "correct binding", type: "parameter mapping", value: "1 -> id, 2 -> name", scope: "PreparedStatement")]),
        ]
    )

    static let goldDateTime006Explanation = Explanation(
        id: "explain-gold-date-time-006",
        initialCode: """
LocalDate date = LocalDate.of(2024, 2, 29).plusYears(1);
System.out.println(date);
""",
        steps: [
            goldGeneralStep(0, "`LocalDate.of(2024, 2, 29)` はうるう年の2月29日なので有効な日付です。", [1], variables: [Variable(name: "start", type: "LocalDate", value: "2024-02-29", scope: "main")]),
            goldGeneralStep(1, "`plusYears(1)` で年を2025へ進めます。しかし2025年には2月29日が存在しません。LocalDateはこのケースで月末の有効日、つまり2月28日へ調整します。", [1], variables: [Variable(name: "date", type: "LocalDate", value: "2025-02-28", scope: "main")], predict: goldGeneralPrompt("2025年2月29日は存在する？", ["存在する", "存在しない"], 1, "2025年はうるう年ではありません。", "正解です。そのため2月28日へ調整されます。")),
            goldGeneralStep(2, "LocalDateは不変ですが、`plusYears` の戻り値を `date` に代入しています。出力は `2025-02-28` です。", [1, 2], variables: [Variable(name: "output", type: "String", value: "2025-02-28", scope: "main")]),
        ]
    )

    static let goldDateTime007Explanation = Explanation(
        id: "explain-gold-date-time-007",
        initialCode: """
LocalTime time = LocalTime.of(23, 30).plus(Duration.ofMinutes(90));
LocalDate date = LocalDate.of(2024, 1, 1).plus(Period.ofDays(1));
System.out.println(date + " " + time);
""",
        steps: [
            goldGeneralStep(0, "`LocalTime.of(23, 30)` に90分のDurationを足します。23:30 + 90分は翌日の01:00相当ですが、LocalTimeは日付を持たないため時刻だけが01:00へ循環します。", [1], variables: [Variable(name: "time", type: "LocalTime", value: "01:00", scope: "main")]),
            goldGeneralStep(1, "`LocalDate.of(2024, 1, 1).plus(Period.ofDays(1))` は日付ベースの1日加算です。戻り値は2024-01-02です。", [2], variables: [Variable(name: "date", type: "LocalDate", value: "2024-01-02", scope: "main")], predict: goldGeneralPrompt("LocalTimeは日付繰り上がりを保持する？", ["保持する", "保持しない"], 1, "LocalTimeは時刻だけです。", "正解です。日付情報はありません。")),
            goldGeneralStep(2, "dateとtimeを文字列連結するため、出力は `2024-01-02 01:00` です。", [3], variables: [Variable(name: "output", type: "String", value: "2024-01-02 01:00", scope: "main")]),
        ]
    )

    static let goldException021Explanation = Explanation(
        id: "explain-gold-exception-021",
        initialCode: """
try (R a = new R("A"); R b = new R("B")) {
    System.out.print("T");
}
// close order: b then a
""",
        steps: [
            goldGeneralStep(0, "try-with-resourcesに `a`、`b` の順で2つのリソースを宣言しています。まずtryブロック本体が実行され、`T` が出力されます。", [1, 2], variables: [Variable(name: "printed", type: "String", value: "T", scope: "try")]),
            goldGeneralStep(1, "tryブロックを抜けるとリソースが自動的にcloseされます。複数リソースのclose順は宣言順ではなく逆順なので、先にbが閉じられます。", [1, 4], variables: [Variable(name: "first close", type: "R", value: "b -> B", scope: "resources")], predict: goldGeneralPrompt("最初にcloseされるのは？", ["a", "b"], 1, "逆順に閉じます。", "正解です。後に宣言したbが先です。")),
            goldGeneralStep(2, "b.close()でB、a.close()でAが出力されます。try本体のTと合わせて `TBA` です。", [4], variables: [Variable(name: "output", type: "String", value: "TBA", scope: "main")]),
        ]
    )

    static let goldException022Explanation = Explanation(
        id: "explain-gold-exception-022",
        initialCode: """
try (R r = new R()) {
    throw new Exception("body");
} catch (Exception e) {
    System.out.println(e.getMessage() + ":" + e.getSuppressed()[0].getMessage());
}
""",
        steps: [
            goldGeneralStep(0, "tryブロック本体で `Exception(\"body\")` が投げられます。この時点の主例外候補はbodyです。", [1, 2], variables: [Variable(name: "primary", type: "Exception", value: "body", scope: "try")]),
            goldGeneralStep(1, "try-with-resourcesは例外が発生していてもリソースを閉じます。`close()` も `Exception(\"close\")` を投げますが、すでに主例外bodyがあるため、closeはsuppressed例外として追加されます。", [1, 2, 3], variables: [Variable(name: "suppressed[0]", type: "Exception", value: "close", scope: "catch")], predict: goldGeneralPrompt("catchされる主例外のメッセージは？", ["body", "close"], 0, "try本体の例外が先です。", "正解です。closeの例外はsuppressedになります。")),
            goldGeneralStep(2, "`e.getMessage()` はbody、`e.getSuppressed()[0].getMessage()` はcloseです。出力は `body:close` です。", [4], variables: [Variable(name: "output", type: "String", value: "body:close", scope: "main")]),
        ]
    )

    static let goldCollections026Explanation = Explanation(
        id: "explain-gold-collections-026",
        initialCode: """
Map<String, Integer> map = new LinkedHashMap<>();
map.put("A", 1);
map.merge("A", 2, Integer::sum);
map.merge("B", 3, Integer::sum);
System.out.println(map);
""",
        steps: [
            goldGeneralStep(0, "`LinkedHashMap` にA=1を入れます。LinkedHashMapは挿入順を保持するため、表示順も基本的に挿入順です。", [1, 2], variables: [Variable(name: "map", type: "LinkedHashMap<String,Integer>", value: "{A=1}", scope: "main")]),
            goldGeneralStep(1, "`merge(\"A\", 2, Integer::sum)` はAが既に存在するため、現在値1と新しい値2を `Integer::sum` へ渡します。結果3でAが更新されます。", [3], variables: [Variable(name: "map[A]", type: "Integer", value: "3", scope: "main")], predict: goldGeneralPrompt("既存キーAの値は？", ["2で上書き", "1+2で3"], 1, "mergeの第3引数を使います。", "正解です。既存値と新値を結合します。")),
            goldGeneralStep(2, "`merge(\"B\", 3, ...)` はBが未存在なので、関数を使わず3をそのまま入れます。出力は `{A=3, B=3}` です。", [4, 5], variables: [Variable(name: "map", type: "LinkedHashMap<String,Integer>", value: "{A=3, B=3}", scope: "main")]),
        ]
    )

    static let goldCollections027Explanation = Explanation(
        id: "explain-gold-collections-027",
        initialCode: """
List<Integer> list = new ArrayList<>(List.of(1, 2, 3, 4));
boolean changed = list.removeIf(n -> n % 2 == 0);
System.out.println(changed + ":" + list);
""",
        steps: [
            goldGeneralStep(0, "`new ArrayList<>(List.of(...))` により、変更可能なArrayListを作っています。List.ofの変更不可リストを直接変更しているわけではありません。", [1], variables: [Variable(name: "list", type: "ArrayList<Integer>", value: "[1, 2, 3, 4]", scope: "main")]),
            goldGeneralStep(1, "`removeIf` はPredicateがtrueを返す要素を削除します。`n % 2 == 0` がtrueの2と4が削除対象です。", [2], variables: [Variable(name: "removed", type: "List<Integer>", value: "[2, 4]", scope: "removeIf")], predict: goldGeneralPrompt("removeIf後に残るのは？", ["[1, 3]", "[2, 4]"], 0, "条件に合う方を削除します。", "正解です。奇数が残ります。")),
            goldGeneralStep(2, "実際に削除が発生したため戻り値 `changed` はtrueです。最終出力は `true:[1, 3]` です。", [2, 3], variables: [Variable(name: "changed", type: "boolean", value: "true", scope: "main"), Variable(name: "list", type: "ArrayList<Integer>", value: "[1, 3]", scope: "main")]),
        ]
    )

    static let goldGenerics009Explanation = Explanation(
        id: "explain-gold-generics-009",
        initialCode: """
static <T> void copy(List<? super T> dst, List<? extends T> src) {
    for (T value : src) {
        dst.add(value);
    }
}
List<Number> numbers = new ArrayList<>();
List<Integer> integers = List.of(1, 2);
copy(numbers, integers);
System.out.println(numbers);
""",
        steps: [
            goldGeneralStep(0, "`src` は `List<? extends T>` なので、Tとして安全に読み出せます。ここでは `integers` から1,2を読み出します。", [1, 2, 7], variables: [Variable(name: "src", type: "List<? extends T>", value: "List<Integer>", scope: "copy")]),
            goldGeneralStep(1, "`dst` は `List<? super T>` なので、T型の値を安全に追加できます。`numbers` はList<Number>で、Integer値を受け取れます。", [1, 3, 6], variables: [Variable(name: "dst", type: "List<? super T>", value: "List<Number>", scope: "copy")], predict: goldGeneralPrompt("PECSで書き込み側は？", ["extends", "super"], 1, "Consumer superです。", "正解です。追加先はsuperです。")),
            goldGeneralStep(2, "copy後のnumbersには1と2が追加されています。ArrayListの表示は `[1, 2]` です。", [8, 9], variables: [Variable(name: "numbers", type: "List<Number>", value: "[1, 2]", scope: "main")]),
        ]
    )

    static let goldGenerics010Explanation = Explanation(
        id: "explain-gold-generics-010",
        initialCode: """
List<? extends Number> values = new ArrayList<Integer>(List.of(1, 2));
Number first = values.get(0);
values.add(null);
System.out.println(values.size() + ":" + first.intValue());
""",
        steps: [
            goldGeneralStep(0, "`List<? extends Number>` は具体的な要素型がIntegerかDoubleかなど不明です。そのため、非nullのNumber値を追加することはできません。", [1], variables: [Variable(name: "values", type: "List<? extends Number>", value: "[1, 2]", scope: "main")]),
            goldGeneralStep(1, "読み出しは可能です。要素型は少なくともNumberのサブタイプなので、`values.get(0)` はNumberとして受け取れます。firstは1です。", [2], variables: [Variable(name: "first", type: "Number", value: "1", scope: "main")]),
            goldGeneralStep(2, "例外的に `null` はどの参照型にも代入可能なので、`values.add(null)` はコンパイルできます。実体はArrayListなので追加され、サイズは3です。", [3, 4], variables: [Variable(name: "values.size()", type: "int", value: "3", scope: "main")], predict: goldGeneralPrompt("? extends に追加できる値は？", ["nullだけ", "任意のNumber"], 0, "具体的な要素型は不明です。", "正解です。nullだけは追加できます。")),
        ]
    )

    static let goldAnnotations013Explanation = Explanation(
        id: "explain-gold-annotations-013",
        initialCode: """
@Inherited
@Retention(RetentionPolicy.RUNTIME)
@interface Mark {}

@Mark
class Base {}

public class Test extends Base {
    System.out.println(Test.class.isAnnotationPresent(Mark.class));
}
""",
        steps: [
            goldGeneralStep(0, "`@Retention(RetentionPolicy.RUNTIME)` により、Markは実行時リフレクションで参照できます。CLASSやSOURCEではこの判定に使えません。", [1, 2, 3], variables: [Variable(name: "retention", type: "RetentionPolicy", value: "RUNTIME", scope: "Mark")]),
            goldGeneralStep(1, "`@Inherited` が付いたクラスアノテーションは、サブクラスのClassオブジェクトから検索したときに継承されたものとして扱われます。Baseに@Markが付いています。", [1, 5, 6, 8], variables: [Variable(name: "Base annotation", type: "Mark", value: "present", scope: "class hierarchy")], predict: goldGeneralPrompt("Test.classでMarkは見える？", ["見える", "見えない"], 0, "@Inheritedがあります。", "正解です。クラス継承で見えます。")),
            goldGeneralStep(2, "`Test.class.isAnnotationPresent(Mark.class)` はtrueを返します。なお @Inherited はクラス継承向けで、メソッドのオーバーライドには同じようには効きません。", [8, 9], variables: [Variable(name: "output", type: "boolean", value: "true", scope: "main")]),
        ]
    )

    static let goldAnnotations014Explanation = Explanation(
        id: "explain-gold-annotations-014",
        initialCode: """
@Retention(RetentionPolicy.RUNTIME)
@Repeatable(Tags.class)
@interface Tag { String value(); }

@Retention(RetentionPolicy.RUNTIME)
@interface Tags { Tag[] value(); }

@Tag("a")
@Tag("b")
public class Test {
    Tag[] tags = Test.class.getAnnotationsByType(Tag.class);
}
""",
        steps: [
            goldGeneralStep(0, "`@Repeatable(Tags.class)` により、Tagを同じ対象へ複数付けられます。コンテナ側のTagsは `Tag[] value()` を持つ必要があります。", [1, 2, 3, 5, 6], variables: [Variable(name: "container", type: "Annotation", value: "Tags", scope: "Tag")]),
            goldGeneralStep(1, "Testクラスには `@Tag(\"a\")` と `@Tag(\"b\")` が付いています。実行時に読むため、TagとTagsのどちらにもRUNTIME保持が指定されています。", [8, 9, 10], variables: [Variable(name: "declared tags", type: "[Tag]", value: "a,b", scope: "Test")]),
            goldGeneralStep(2, "`getAnnotationsByType(Tag.class)` は繰り返しアノテーションを展開してTag配列を返します。長さは2、値はa,bなので出力は `2:ab` です。", [11], variables: [Variable(name: "tags", type: "Tag[]", value: "[a, b]", scope: "main")], predict: goldGeneralPrompt("getAnnotationsByTypeの件数は？", ["1", "2"], 1, "コンテナを展開します。", "正解です。Tagが2件です。")),
        ]
    )

    static let goldClasses008Explanation = Explanation(
        id: "explain-gold-classes-008",
        initialCode: """
record Point(int x, int y) {
    Point {
        if (x < 0) {
            x = 0;
        }
    }
}
Point p = new Point(-1, 2);
System.out.println(p.x() + ":" + p.y());
""",
        steps: [
            goldGeneralStep(0, "recordのコンパクトコンストラクタ `Point { ... }` では、引数リストを書かずに正規コンストラクタの本文だけを定義します。xとyはコンストラクタパラメータとして使えます。", [1, 2], variables: [Variable(name: "x", type: "int parameter", value: "-1", scope: "Point constructor"), Variable(name: "y", type: "int parameter", value: "2", scope: "Point constructor")]),
            goldGeneralStep(1, "`x < 0` がtrueなので、コンストラクタ本文内でパラメータxに0を代入します。ここで変更しているのはフィールドではなく、暗黙代入前のパラメータです。", [3, 4], variables: [Variable(name: "x", type: "int parameter", value: "0", scope: "Point constructor")], predict: goldGeneralPrompt("この後フィールドxに入る値は？", ["-1", "0"], 1, "暗黙代入は本文の後です。", "正解です。補正後のパラメータ0が使われます。")),
            goldGeneralStep(2, "コンパクトコンストラクタ本文の後、recordコンポーネントへの代入が暗黙に行われます。xは0、yは2となり、出力は `0:2` です。", [7, 8, 9], variables: [Variable(name: "p", type: "Point", value: "Point[x=0, y=2]", scope: "main")]),
        ]
    )
}
