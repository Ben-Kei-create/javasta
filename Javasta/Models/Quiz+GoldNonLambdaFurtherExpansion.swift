import Foundation

enum GoldNonLambdaFurtherQuestionData {
    static let specs: [GoldNonLambdaQuestionData.Spec] = [
        // MARK: - Module System

        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-module-automatic-name-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "module-system",
            tags: ["automatic module", "requires", "module path"],
            code: """
// module pathに legacy-utils-1.2.jar がある
module app.core {
    requires legacy.utils;
}
""",
            question: "自動モジュール名の基本的な扱いとして、この `requires legacy.utils;` の読み方で正しいものはどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "JAR名からバージョンなどを除いて推定された自動モジュール名をrequiresしている", correct: true, explanation: "Automatic-Module-NameがないJARは、ファイル名から自動モジュール名が推定されます。例では `legacy.utils` として読ませる想定です。"),
                GoldNonLambdaQuestionData.choice("b", "自動モジュールは名前を持たないためrequiresできない", misconception: "自動モジュールが無名モジュールと同じだと誤解", explanation: "自動モジュールは名前付きモジュールとして扱われます。"),
                GoldNonLambdaQuestionData.choice("c", "requiresにはJARファイル名を拡張子付きで書く", misconception: "モジュール名とファイル名を混同", explanation: "requiresにはモジュール名を書きます。`.jar` は書きません。"),
                GoldNonLambdaQuestionData.choice("d", "自動モジュールは常に `java.base` という名前になる", misconception: "全モジュールがjava.baseになると誤解", explanation: "`java.base` は基底モジュールであり、自動モジュール名とは別です。"),
            ],
            intent: "モジュールパス上の通常JARは自動モジュールとして名前を持ち、requires対象にできることを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("モジュールパスに `legacy-utils-1.2.jar` が置かれている前提です。", [1], [GoldNonLambdaQuestionData.variable("jar", "String", "legacy-utils-1.2.jar", "module path")]),
                GoldNonLambdaQuestionData.step("通常JARは自動モジュールとして扱われ、JAR名からモジュール名が推定されます。", [2, 3], [GoldNonLambdaQuestionData.variable("module name", "String", "legacy.utils", "module system")]),
                GoldNonLambdaQuestionData.step("そのため `requires legacy.utils;` は推定された自動モジュール名を読む宣言です。", [3], [GoldNonLambdaQuestionData.variable("requires target", "module", "legacy.utils", "app.core")]),
            ]
        ),
        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-module-java-base-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "module-system",
            tags: ["java.base", "implicit requires"],
            code: """
module app.core {
    exports app;
}
""",
            question: "`module-info.java` に `requires java.base;` がない場合の説明として正しいものはどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "`java.base` は暗黙的にrequiresされる", correct: true, explanation: "すべてのモジュールは暗黙的に `java.base` を読みます。"),
                GoldNonLambdaQuestionData.choice("b", "Stringなどの基本クラスが使えないためコンパイルエラー", misconception: "java.baseを明示しないと読めないと誤解", explanation: "`java.base` は明示しなくても読めます。"),
                GoldNonLambdaQuestionData.choice("c", "`java.base` は通常JARなのでclasspathに置く必要がある", misconception: "標準モジュールと通常JARを混同", explanation: "`java.base` は標準の基底モジュールです。"),
                GoldNonLambdaQuestionData.choice("d", "exportsを書いた場合だけjava.baseが不要になる", misconception: "exportsと基底モジュールの関係を誤解", explanation: "exportsの有無に関係なく、java.baseは暗黙的に読まれます。"),
            ],
            intent: "すべての名前付きモジュールはjava.baseを暗黙的に読み、明示requiresが不要なことを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("module宣言には `requires java.base;` が書かれていません。", [1, 2, 3], [GoldNonLambdaQuestionData.variable("explicit requires java.base", "boolean", "false", "module-info")]),
                GoldNonLambdaQuestionData.step("しかしJavaの全モジュールは `java.base` を暗黙的に読みます。", [1], [GoldNonLambdaQuestionData.variable("implicit read", "module", "java.base", "module graph")]),
                GoldNonLambdaQuestionData.step("そのため、基本APIを使うために `requires java.base;` を明示する必要はありません。", [1], [GoldNonLambdaQuestionData.variable("result", "String", "valid descriptor", "compiler")]),
            ]
        ),
        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-module-split-package-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "module-system",
            tags: ["split package", "module path"],
            code: """
// module a.core exports com.example.util
// module b.core exports com.example.util
module app.core {
    requires a.core;
    requires b.core;
}
""",
            question: "同じパッケージ `com.example.util` を複数の読み取り対象モジュールが持つ場合の説明として正しいものはどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "同じパッケージ名でもクラス名が違えば常に問題ない", misconception: "モジュール単位のパッケージ一意性を見落としている", explanation: "名前付きモジュールでは、同じパッケージが複数の読み取り対象から見える状態は問題になります。"),
                GoldNonLambdaQuestionData.choice("b", "split packageとして解決エラーまたはコンパイルエラーになる", correct: true, explanation: "同じパッケージを複数モジュールから読む構成は、モジュールシステムで避けるべきsplit packageです。"),
                GoldNonLambdaQuestionData.choice("c", "先にrequiresした `a.core` のパッケージだけが優先される", misconception: "classpath的な先勝ちを想定", explanation: "モジュールパスでは曖昧な先勝ちではなく、構成自体が問題になります。"),
                GoldNonLambdaQuestionData.choice("d", "実行時にランダムでどちらかのクラスが選ばれる", misconception: "モジュール解決の決定性を誤解", explanation: "ランダム選択ではなく、解決段階で問題になります。"),
            ],
            intent: "名前付きモジュールでは同じパッケージを複数モジュールから読ませるsplit packageが問題になることを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("`a.core` と `b.core` の両方が `com.example.util` パッケージを持つ前提です。", [1, 2], [GoldNonLambdaQuestionData.variable("package", "String", "com.example.util", "a.core/b.core")]),
                GoldNonLambdaQuestionData.step("`app.core` は両方のモジュールをrequiresしているため、同じパッケージが2つの読み取り対象から見えます。", [3, 4, 5, 6], [GoldNonLambdaQuestionData.variable("reads", "Set", "a.core, b.core", "app.core")]),
                GoldNonLambdaQuestionData.step("これはsplit packageとして問題になり、モジュール解決またはコンパイルで失敗します。", [4, 5], [GoldNonLambdaQuestionData.variable("result", "String", "split package error", "module system")]),
            ]
        ),

        // MARK: - JDBC

        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-jdbc-preparestatement-execute-boolean-001",
            difficulty: .standard,
            estimatedSeconds: 90,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["PreparedStatement", "execute", "executeUpdate"],
            code: """
PreparedStatement ps =
    conn.prepareStatement("delete from users where inactive = true");
boolean result = ps.execute();
System.out.println(result);
""",
            question: "DELETE文に対して `PreparedStatement.execute()` を呼んだ場合の戻り値として正しい説明はどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "更新件数が1以上ならtrue", misconception: "executeのbooleanを更新件数判定と誤解", explanation: "`execute()` のbooleanは最初の結果がResultSetかどうかです。"),
                GoldNonLambdaQuestionData.choice("b", "最初の結果がResultSetではないためfalse", correct: true, explanation: "DELETEは更新件数を生成する文であり、ResultSetを返す問い合わせではないためfalseです。"),
                GoldNonLambdaQuestionData.choice("c", "SQLが成功したら常にtrue", misconception: "成功フラグだと誤解", explanation: "成功しても、最初の結果が更新件数ならfalseです。"),
                GoldNonLambdaQuestionData.choice("d", "DELETE文ではexecuteを呼べないためコンパイルエラー", misconception: "SQL内容をコンパイラが検査すると誤解", explanation: "SQL内容は実行時にJDBCドライバが扱います。"),
            ],
            intent: "PreparedStatement.executeのboolean戻り値は成功可否ではなく、最初の結果がResultSetかどうかを表すことを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("SQLはDELETE文で、問い合わせ結果のResultSetではなく更新件数を生みます。", [1, 2], [GoldNonLambdaQuestionData.variable("sql kind", "String", "DELETE", "JDBC")]),
                GoldNonLambdaQuestionData.step("`execute()` の戻り値は、最初の結果がResultSetならtrue、更新件数ならfalseです。", [3], [GoldNonLambdaQuestionData.variable("first result", "String", "update count", "PreparedStatement")]),
                GoldNonLambdaQuestionData.step("したがって出力はfalseです。", [4], [GoldNonLambdaQuestionData.variable("output", "boolean", "false", "stdout")]),
            ]
        ),
        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-jdbc-generated-keys-001",
            difficulty: .tricky,
            estimatedSeconds: 100,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["generated keys", "RETURN_GENERATED_KEYS"],
            code: """
PreparedStatement ps = conn.prepareStatement(
    "insert into users(name) values (?)");
ps.setString(1, "Ada");
ps.executeUpdate();
ResultSet keys = ps.getGeneratedKeys();
""",
            question: "自動生成キーを取得したい場合、このコードの問題として最も適切なものはどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "prepareStatement時に生成キー返却を要求していない", correct: true, explanation: "生成キーを取得したい場合は、通常 `Statement.RETURN_GENERATED_KEYS` などを指定してPreparedStatementを作成します。"),
                GoldNonLambdaQuestionData.choice("b", "`setString` は生成キー取得と同時に使えない", misconception: "パラメータ設定と生成キー取得を混同", explanation: "パラメータ設定自体は問題ではありません。"),
                GoldNonLambdaQuestionData.choice("c", "`executeUpdate()` ではなく必ず `executeQuery()` を使う", misconception: "INSERTとqueryを混同", explanation: "INSERTには通常 `executeUpdate()` を使います。"),
                GoldNonLambdaQuestionData.choice("d", "`getGeneratedKeys()` はStatementではなくResultSetに対して呼ぶ", misconception: "APIの呼び出し先を誤解", explanation: "`getGeneratedKeys()` はStatement/PreparedStatementから呼びます。"),
            ],
            intent: "生成キー取得にはPreparedStatement作成時にRETURN_GENERATED_KEYS等で要求する必要があることを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("PreparedStatementはSQL文字列だけで作られており、生成キー返却の指定がありません。", [1, 2], [GoldNonLambdaQuestionData.variable("generated keys requested", "boolean", "false", "PreparedStatement")]),
                GoldNonLambdaQuestionData.step("INSERT実行自体は `executeUpdate()` で行えます。問題は生成キーを返すように要求していない点です。", [3, 4], [GoldNonLambdaQuestionData.variable("insert executed", "boolean", "true", "JDBC")]),
                GoldNonLambdaQuestionData.step("生成キーが必要なら、作成時に `Statement.RETURN_GENERATED_KEYS` などを指定します。", [5], [GoldNonLambdaQuestionData.variable("fix", "String", "prepareStatement(sql, RETURN_GENERATED_KEYS)", "JDBC")]),
            ]
        ),
        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-jdbc-savepoint-rollback-001",
            difficulty: .standard,
            estimatedSeconds: 100,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["Savepoint", "rollback", "transaction"],
            code: """
conn.setAutoCommit(false);
updateA(conn);
Savepoint sp = conn.setSavepoint();
updateB(conn);
conn.rollback(sp);
conn.commit();
""",
            question: "このトランザクションで `rollback(sp)` により取り消される処理として正しいものはどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "`updateA` と `updateB` の両方", misconception: "セーブポイント以前も戻ると誤解", explanation: "指定したセーブポイント以降の変更が取り消し対象です。"),
                GoldNonLambdaQuestionData.choice("b", "`updateB` のみ", correct: true, explanation: "セーブポイントは `updateA` の後に作成されているため、`rollback(sp)` はその後の `updateB` を取り消します。"),
                GoldNonLambdaQuestionData.choice("c", "何も取り消されず、commitですべて確定する", misconception: "rollback(sp)の効果を見落としている", explanation: "セーブポイントへのロールバックは、その時点以降の変更を戻します。"),
                GoldNonLambdaQuestionData.choice("d", "`rollback(sp)` 後は必ずcommitできない", misconception: "部分ロールバック後のcommitを誤解", explanation: "残った変更をcommitすることは可能です。"),
            ],
            intent: "JDBCのSavepointへrollbackすると、そのセーブポイント以降の変更だけを戻せることを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("autoCommitをfalseにし、まず `updateA` を実行します。", [1, 2], [GoldNonLambdaQuestionData.variable("updateA", "String", "pending", "transaction")]),
                GoldNonLambdaQuestionData.step("その後にSavepointを作り、さらに `updateB` を実行しています。", [3, 4], [GoldNonLambdaQuestionData.variable("savepoint", "String", "after updateA", "transaction")]),
                GoldNonLambdaQuestionData.step("`rollback(sp)` はセーブポイント以降の `updateB` を取り消し、`updateA` はcommit対象として残ります。", [5, 6], [GoldNonLambdaQuestionData.variable("rolled back", "String", "updateB", "transaction")]),
            ]
        ),

        // MARK: - Date Time

        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-datetime-zoneddatetime-dst-gap-001",
            difficulty: .tricky,
            category: "date-time",
            tags: ["ZonedDateTime", "DST", "gap"],
            code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        ZoneId zone = ZoneId.of("America/New_York");
        LocalDateTime local = LocalDateTime.of(2024, 3, 10, 2, 30);
        System.out.println(ZonedDateTime.of(local, zone).toLocalTime());
    }
}
""",
            question: "夏時間開始で存在しないローカル時刻 `2024-03-10T02:30` をNew YorkでZonedDateTime化した結果として正しいものはどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "02:30", misconception: "存在しないローカル時刻がそのまま採用されると誤解", explanation: "DSTのgapに入る時刻は有効な時刻へ調整されます。"),
                GoldNonLambdaQuestionData.choice("b", "03:30", correct: true, explanation: "New Yorkの2024年3月10日02:30は夏時間開始のgapに入るため、通常03:30へ進められます。"),
                GoldNonLambdaQuestionData.choice("c", "01:30", misconception: "gapを前に戻すと誤解", explanation: "存在しない時刻はgapの後ろ側へ調整されます。"),
                GoldNonLambdaQuestionData.choice("d", "DateTimeException", misconception: "ZonedDateTime.ofが必ず例外にすると誤解", explanation: "`of` はgapを調整して有効なZonedDateTimeを作ります。"),
            ],
            intent: "ZonedDateTime.ofはDSTのgapに入るローカル時刻を有効な時刻へ調整することを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("対象ゾーンは `America/New_York` で、2024年3月10日は夏時間開始日です。", [5], [GoldNonLambdaQuestionData.variable("zone", "ZoneId", "America/New_York", "main")]),
                GoldNonLambdaQuestionData.step("`02:30` はDST開始のgapに入り、このローカル時刻は存在しません。", [6], [GoldNonLambdaQuestionData.variable("local", "LocalDateTime", "2024-03-10T02:30", "main")]),
                GoldNonLambdaQuestionData.step("`ZonedDateTime.of` は有効な時刻へ進めるため、ローカル時刻部分は `03:30` になります。", [7], [GoldNonLambdaQuestionData.variable("output", "LocalTime", "03:30", "stdout")]),
            ]
        ),
        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-datetime-instant-plus-period-001",
            difficulty: .standard,
            category: "date-time",
            tags: ["Instant", "Period", "UnsupportedTemporalTypeException"],
            code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        Instant now = Instant.parse("2024-01-01T00:00:00Z");
        System.out.println(now.plus(Period.ofDays(1)));
    }
}
""",
            question: "`Instant` に `Period.ofDays(1)` を足した場合の結果として正しいものはどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "2024-01-02T00:00:00Z", misconception: "PeriodをInstantへ直接足せると誤解", explanation: "Instantは日付ベースのPeriod加算を直接サポートしません。"),
                GoldNonLambdaQuestionData.choice("b", "UnsupportedTemporalTypeException", correct: true, explanation: "`Period` は日付ベースの量で、Instantへの加算ではサポートされない単位を含むため例外になります。"),
                GoldNonLambdaQuestionData.choice("c", "コンパイルエラー", misconception: "plusにTemporalAmountを渡せないと誤解", explanation: "呼び出しはコンパイルできますが、実行時にサポート単位の問題になります。"),
                GoldNonLambdaQuestionData.choice("d", "1970-01-02T00:00:00Z", misconception: "Instantの基準日へ加算すると誤解", explanation: "対象はparseした2024年のInstantです。"),
            ],
            intent: "InstantにはDurationのような時刻ベース量が適し、Periodの直接加算はサポートされないことを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("`now` はUTCのInstantを表しています。", [5], [GoldNonLambdaQuestionData.variable("now", "Instant", "2024-01-01T00:00:00Z", "main")]),
                GoldNonLambdaQuestionData.step("`Period.ofDays(1)` は日付ベースのTemporalAmountです。", [6], [GoldNonLambdaQuestionData.variable("amount", "Period", "P1D", "date-time")]),
                GoldNonLambdaQuestionData.step("InstantへのPeriod加算はサポートされない単位を使うため、`UnsupportedTemporalTypeException` が発生します。", [6], [GoldNonLambdaQuestionData.variable("result", "Exception", "UnsupportedTemporalTypeException", "runtime")]),
            ]
        ),
        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-datetime-format-parse-strict-001",
            difficulty: .standard,
            category: "date-time",
            tags: ["DateTimeFormatter", "parse", "DateTimeParseException"],
            code: """
import java.time.*;
import java.time.format.*;

public class Test {
    public static void main(String[] args) {
        DateTimeFormatter f = DateTimeFormatter.ISO_LOCAL_DATE;
        System.out.println(LocalDate.parse("2024/01/02", f));
    }
}
""",
            question: "`ISO_LOCAL_DATE` で `2024/01/02` をparseした場合の結果として正しいものはどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "2024-01-02", misconception: "スラッシュ区切りもISO_LOCAL_DATEで読めると誤解", explanation: "ISO_LOCAL_DATEはハイフン区切りの形式を期待します。"),
                GoldNonLambdaQuestionData.choice("b", "2024/01/02", misconception: "LocalDateが入力文字列形式を保持すると誤解", explanation: "LocalDateは日付値であり、形式はFormatterが扱います。"),
                GoldNonLambdaQuestionData.choice("c", "DateTimeParseException", correct: true, explanation: "`2024/01/02` はISO_LOCAL_DATEの期待する `yyyy-MM-dd` 形式ではないためparseに失敗します。"),
                GoldNonLambdaQuestionData.choice("d", "null", misconception: "parse失敗がnullになると誤解", explanation: "parse失敗時は例外が発生します。"),
            ],
            intent: "DateTimeFormatter.ISO_LOCAL_DATEはスラッシュ区切りを受け付けず、形式不一致でDateTimeParseExceptionになることを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("`ISO_LOCAL_DATE` は `yyyy-MM-dd` のようなハイフン区切り形式を扱います。", [6], [GoldNonLambdaQuestionData.variable("formatter", "DateTimeFormatter", "ISO_LOCAL_DATE", "main")]),
                GoldNonLambdaQuestionData.step("入力文字列は `2024/01/02` で、区切り文字がスラッシュです。", [7], [GoldNonLambdaQuestionData.variable("input", "String", "2024/01/02", "main")]),
                GoldNonLambdaQuestionData.step("形式が一致しないため、`LocalDate.parse` は `DateTimeParseException` を投げます。", [7], [GoldNonLambdaQuestionData.variable("result", "Exception", "DateTimeParseException", "runtime")]),
            ]
        ),

        // MARK: - Classes

        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-classes-record-canonical-001",
            difficulty: .standard,
            category: "classes",
            tags: ["record", "canonical constructor"],
            code: """
record User(String name, int age) {
    public User {
        if (age < 0) age = 0;
    }
}

public class Test {
    public static void main(String[] args) {
        System.out.println(new User("Ada", -1).age());
    }
}
""",
            question: "このrecordのコンパクトコンストラクタを実行したとき、出力される値はどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "-1", misconception: "コンパクトコンストラクタ内の代入が反映されないと誤解", explanation: "コンパクトコンストラクタでは、パラメータを調整してからフィールドへ代入できます。"),
                GoldNonLambdaQuestionData.choice("b", "0", correct: true, explanation: "`age` パラメータが負数なら0に変更され、その値がrecordコンポーネントへ格納されます。"),
                GoldNonLambdaQuestionData.choice("c", "コンパイルエラー", misconception: "recordのコンパクトコンストラクタでパラメータを書き換えられないと誤解", explanation: "コンパクトコンストラクタ内でパラメータ変数を代入し直すことはできます。"),
                GoldNonLambdaQuestionData.choice("d", "IllegalArgumentException", misconception: "負数なら自動で例外になると誤解", explanation: "このコードは例外を投げず、0へ補正しています。"),
            ],
            intent: "recordのコンパクトコンストラクタではパラメータ検証や補正を行った後にコンポーネントへ代入されることを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("`new User(\"Ada\", -1)` により、コンパクトコンストラクタへ `age = -1` が渡ります。", [8], [GoldNonLambdaQuestionData.variable("age parameter", "int", "-1", "User constructor")]),
                GoldNonLambdaQuestionData.step("`age < 0` がtrueなので、コンストラクタ内で `age = 0` に補正されます。", [2, 3], [GoldNonLambdaQuestionData.variable("age parameter", "int", "0", "User constructor")]),
                GoldNonLambdaQuestionData.step("補正後の値がrecordコンポーネントへ格納されるため、`age()` は0を返します。", [8], [GoldNonLambdaQuestionData.variable("output", "int", "0", "stdout")]),
            ]
        ),
        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-classes-record-field-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "classes",
            tags: ["record", "instance field"],
            code: """
public record Point(int x, int y) {
    private int cached;
}
""",
            question: "このrecord宣言について正しい説明はどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "recordにも通常の変更可能なインスタンスフィールドを自由に追加できる", misconception: "recordのフィールド制約を見落としている", explanation: "recordではコンポーネント由来以外のインスタンスフィールドは宣言できません。"),
                GoldNonLambdaQuestionData.choice("b", "`cached` がstaticではないためコンパイルエラーになる", correct: true, explanation: "record本体に追加できるフィールドはstaticフィールドなどで、通常のインスタンスフィールドは不可です。"),
                GoldNonLambdaQuestionData.choice("c", "`cached` は自動的にfinalになるので正常にコンパイルできる", misconception: "自動final化されると誤解", explanation: "recordのコンポーネントはprivate finalフィールドになりますが、任意の追加インスタンスフィールドは許可されません。"),
                GoldNonLambdaQuestionData.choice("d", "`private` を `public` に変えれば有効になる", misconception: "アクセス修飾子だけの問題と誤解", explanation: "問題はアクセス修飾子ではなく、追加インスタンスフィールド自体が許可されない点です。"),
            ],
            intent: "recordではコンポーネント以外の通常インスタンスフィールドを追加できないことを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("`Point` はrecordで、コンポーネント `x` と `y` を持ちます。", [1], [GoldNonLambdaQuestionData.variable("components", "String", "x, y", "Point")]),
                GoldNonLambdaQuestionData.step("record本体に `private int cached;` という通常インスタンスフィールドを追加しています。", [2], [GoldNonLambdaQuestionData.variable("extra field", "String", "cached", "Point")]),
                GoldNonLambdaQuestionData.step("recordではこのような追加インスタンスフィールドは許可されないため、コンパイルエラーです。", [2], [GoldNonLambdaQuestionData.variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-classes-static-nested-001",
            category: "classes",
            tags: ["static nested class", "outer instance"],
            code: """
class Outer {
    static class Nested {
        String name() { return "nested"; }
    }
}

public class Test {
    public static void main(String[] args) {
        Outer.Nested n = new Outer.Nested();
        System.out.println(n.name());
    }
}
""",
            question: "このstatic nested classの生成と出力について正しいものはどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "nested", correct: true, explanation: "static nested classは外側インスタンスなしで `new Outer.Nested()` と生成できます。"),
                GoldNonLambdaQuestionData.choice("b", "コンパイルエラー。必ず `new Outer().new Nested()` が必要", misconception: "static nested classとinner classを混同", explanation: "`new Outer().new Nested()` が必要なのは非static inner classです。"),
                GoldNonLambdaQuestionData.choice("c", "Outer", misconception: "外側クラス名が出力されると誤解", explanation: "出力しているのは `Nested.name()` の戻り値です。"),
                GoldNonLambdaQuestionData.choice("d", "NullPointerException", misconception: "外側インスタンスがnullだと誤解", explanation: "static nested classには外側インスタンスが不要です。"),
            ],
            intent: "static nested classは外側クラスのインスタンスなしで生成できることを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("`Nested` は `static class` としてOuter内に宣言されています。", [1, 2, 3, 4], [GoldNonLambdaQuestionData.variable("nested kind", "String", "static nested", "Outer")]),
                GoldNonLambdaQuestionData.step("static nested classなので、`new Outer.Nested()` で直接生成できます。", [9], [GoldNonLambdaQuestionData.variable("n", "Outer.Nested", "created", "main")]),
                GoldNonLambdaQuestionData.step("`name()` は `nested` を返すため、出力は `nested` です。", [10], [GoldNonLambdaQuestionData.variable("output", "String", "nested", "stdout")]),
            ]
        ),

        // MARK: - Exceptions

        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-exception-try-resource-init-001",
            difficulty: .tricky,
            category: "exception-handling",
            tags: ["try-with-resources", "resource init", "close"],
            code: """
class R implements AutoCloseable {
    private final String name;
    R(String name) {
        this.name = name;
        System.out.print("open" + name);
    }
    public void close() {
        System.out.print("close" + name);
    }
}

public class Test {
    public static void main(String[] args) {
        try (R a = new R("A"); R b = new R("B")) {
            System.out.print("body");
        }
    }
}
""",
            question: "このtry-with-resourcesコードの出力はどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "openAopenBbodycloseBcloseA", correct: true, explanation: "リソースは左から初期化され、終了時は逆順にcloseされます。"),
                GoldNonLambdaQuestionData.choice("b", "openAopenBbodycloseAcloseB", misconception: "close順を初期化順と誤解", explanation: "try-with-resourcesのcloseは逆順です。"),
                GoldNonLambdaQuestionData.choice("c", "bodyopenAopenBcloseBcloseA", misconception: "リソース初期化がbody後だと誤解", explanation: "リソースはtry本体の前に初期化されます。"),
                GoldNonLambdaQuestionData.choice("d", "openAbodycloseAopenBcloseB", misconception: "リソースごとにbodyが実行されると誤解", explanation: "リソース宣言をすべて初期化してからtry本体を一度実行します。"),
            ],
            intent: "try-with-resourcesのリソース初期化は左から、closeは逆順で行われることを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("リソース `a`、`b` は宣言順に初期化されるため、まず `openAopenB` が出力されます。", [14], [GoldNonLambdaQuestionData.variable("open order", "String", "A then B", "try resources")]),
                GoldNonLambdaQuestionData.step("try本体で `body` が出力されます。", [15], [GoldNonLambdaQuestionData.variable("body output", "String", "body", "try block")]),
                GoldNonLambdaQuestionData.step("終了時は逆順にcloseされるため、`closeBcloseA` が続きます。", [7, 14], [GoldNonLambdaQuestionData.variable("close order", "String", "B then A", "try resources")]),
            ]
        ),
        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-exception-precise-rethrow-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "exception-handling",
            tags: ["precise rethrow", "multi-catch", "checked exception"],
            code: """
import java.io.*;
import java.sql.*;

class Test {
    static void run(boolean io) throws IOException, SQLException {
        try {
            if (io) throw new IOException();
            throw new SQLException();
        } catch (Exception e) {
            throw e;
        }
    }
}
""",
            question: "このprecise rethrowに関する説明として正しいものはどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "`catch (Exception e)` なので `run` は必ず `throws Exception` にしないといけない", misconception: "precise rethrowを見落としている", explanation: "再代入されていないcatchパラメータでは、実際に投げられ得る例外型へ精密に解析されます。"),
                GoldNonLambdaQuestionData.choice("b", "`throws IOException, SQLException` でコンパイルできる", correct: true, explanation: "try内から投げられるチェック例外はIOExceptionとSQLExceptionなので、precise rethrowによりその2つで宣言できます。"),
                GoldNonLambdaQuestionData.choice("c", "`throw e;` は常にコンパイルエラー", misconception: "catchパラメータを再throwできないと誤解", explanation: "catchした例外を再throwすること自体は有効です。"),
                GoldNonLambdaQuestionData.choice("d", "`SQLException` はjava.ioに含まれる", misconception: "SQLExceptionのパッケージを誤解", explanation: "実際には `java.sql.SQLException` です。このスニペットではimport不足なら別途必要ですが、狙いはprecise rethrowです。"),
            ],
            intent: "catchしたExceptionを再代入せず再throwする場合、実際に投げられ得るチェック例外へ精密に解析されることを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("try内で投げられ得るチェック例外は `IOException` と `SQLException` です。", [5, 6, 7], [GoldNonLambdaQuestionData.variable("possible exceptions", "Set", "IOException, SQLException", "try")]),
                GoldNonLambdaQuestionData.step("catchパラメータ `e` は再代入されず、そのまま `throw e;` されています。", [8, 9], [GoldNonLambdaQuestionData.variable("e reassigned", "boolean", "false", "catch")]),
                GoldNonLambdaQuestionData.step("precise rethrowにより、メソッドのthrowsは `IOException, SQLException` で足ります。", [4, 9], [GoldNonLambdaQuestionData.variable("declared throws", "Set", "IOException, SQLException", "run")]),
            ]
        ),
        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-exception-multicatch-final-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "exception-handling",
            tags: ["multi-catch", "effectively final"],
            code: """
try {
    risky();
} catch (IOException | SQLException e) {
    e = new IOException();
    throw e;
}
""",
            question: "このmulti-catchのcatchパラメータ `e` への代入について正しい説明はどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "multi-catchのパラメータは暗黙的にfinal扱いなので代入できない", correct: true, explanation: "multi-catchパラメータには再代入できないため、`e = ...` はコンパイルエラーです。"),
                GoldNonLambdaQuestionData.choice("b", "IOException側でcatchされた場合だけ代入できる", misconception: "実行時の例外型で代入可否が変わると誤解", explanation: "代入可否はコンパイル時に決まります。"),
                GoldNonLambdaQuestionData.choice("c", "代入はできるが `throw e` だけがエラーになる", misconception: "代入行の制約を見落としている", explanation: "multi-catchパラメータへの代入自体が禁止されています。"),
                GoldNonLambdaQuestionData.choice("d", "単一catchと同じく常に再代入できる", misconception: "multi-catch固有の制約を見落としている", explanation: "単一catchとは異なり、multi-catchパラメータは暗黙的にfinalです。"),
            ],
            intent: "multi-catchパラメータは暗黙的にfinal扱いで再代入できないことを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("catch句は `IOException | SQLException` のmulti-catchです。", [3], [GoldNonLambdaQuestionData.variable("catch kind", "String", "multi-catch", "compiler")]),
                GoldNonLambdaQuestionData.step("multi-catchのパラメータ `e` は暗黙的にfinal扱いになります。", [3, 4], [GoldNonLambdaQuestionData.variable("e assignable", "boolean", "false", "catch")]),
                GoldNonLambdaQuestionData.step("そのため `e = new IOException();` の行でコンパイルエラーです。", [4], [GoldNonLambdaQuestionData.variable("result", "String", "compile error", "compiler")]),
            ]
        ),

        // MARK: - Concurrency

        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-concurrency-scheduled-delay-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "concurrency",
            tags: ["ScheduledExecutorService", "schedule", "TimeUnit"],
            code: """
ScheduledExecutorService service =
    Executors.newSingleThreadScheduledExecutor();
ScheduledFuture<?> f = service.schedule(
    () -> System.out.print("run"), 1, TimeUnit.SECONDS);
System.out.print(f.isDone());
service.shutdown();
""",
            question: "タスクをscheduleした直後の `f.isDone()` について正しい説明はどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "通常false。指定した遅延後に実行されるまで完了していない", correct: true, explanation: "scheduleは指定遅延後にタスクを実行します。直後はまだ完了していないのが通常です。"),
                GoldNonLambdaQuestionData.choice("b", "常にtrue。scheduleした時点でタスクは完了扱い", misconception: "登録完了とタスク完了を混同", explanation: "Futureの完了はタスク本体の完了を意味します。"),
                GoldNonLambdaQuestionData.choice("c", "shutdownすると予約済みタスクは必ず即キャンセルされる", misconception: "shutdownとshutdownNowを混同", explanation: "通常のshutdownは新規受付を止めますが、予約済みタスクを直ちにすべてキャンセルするとは限りません。"),
                GoldNonLambdaQuestionData.choice("d", "scheduleはRunnableを受け取れない", misconception: "ScheduledExecutorServiceのAPIを誤解", explanation: "Runnableを遅延実行するscheduleメソッドがあります。"),
            ],
            intent: "ScheduledExecutorService.scheduleは遅延実行を登録し、Future完了は登録時点ではなくタスク完了後になることを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("タスクは1秒後に実行されるようscheduleされています。", [3, 4], [GoldNonLambdaQuestionData.variable("delay", "long", "1 second", "scheduler")]),
                GoldNonLambdaQuestionData.step("schedule直後は、タスク本体がまだ実行・完了していないのが通常です。", [5], [GoldNonLambdaQuestionData.variable("f.isDone()", "boolean", "false", "main")]),
                GoldNonLambdaQuestionData.step("したがって直後に出力されるbooleanは通常falseです。", [5], [GoldNonLambdaQuestionData.variable("output", "String", "false", "stdout")]),
            ]
        ),
        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-concurrency-future-cancel-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "concurrency",
            tags: ["Future", "cancel", "CancellationException"],
            code: """
Future<String> f = executor.submit(() -> "done");
boolean cancelled = f.cancel(true);
String value = f.get();
""",
            question: "`Future.cancel(true)` が成功した後に `get()` した場合の説明として正しいものはどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "`get()` はnullを返す", misconception: "キャンセル結果をnullと誤解", explanation: "キャンセルされたFutureのgetは正常値を返しません。"),
                GoldNonLambdaQuestionData.choice("b", "`get()` は `CancellationException` を投げる", correct: true, explanation: "キャンセル済みFutureに対してgetすると、通常 `CancellationException` が発生します。"),
                GoldNonLambdaQuestionData.choice("c", "`cancel(true)` はFutureを完了済みにできない", misconception: "cancelの効果を見落としている", explanation: "タスク状態によって成功可否はありますが、成功すればキャンセル状態になります。"),
                GoldNonLambdaQuestionData.choice("d", "`get()` は必ず `done` を返す", misconception: "キャンセルが成功した前提を無視", explanation: "キャンセル成功後は通常の結果取得はできません。"),
            ],
            intent: "キャンセルに成功したFutureからgetするとCancellationExceptionになることを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("Futureに対して `cancel(true)` を呼び、ここでは成功した前提です。", [1, 2], [GoldNonLambdaQuestionData.variable("cancelled", "boolean", "true", "Future")]),
                GoldNonLambdaQuestionData.step("キャンセル済みFutureは正常な計算結果を持つ完了状態ではありません。", [3], [GoldNonLambdaQuestionData.variable("future state", "String", "cancelled", "Future")]),
                GoldNonLambdaQuestionData.step("そのため `f.get()` は `CancellationException` を投げます。", [3], [GoldNonLambdaQuestionData.variable("result", "Exception", "CancellationException", "main")]),
            ]
        ),
        GoldNonLambdaQuestionData.q(
            "gold-nonlambda-further-concurrency-cyclicbarrier-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "concurrency",
            tags: ["CyclicBarrier", "await", "parties"],
            code: """
CyclicBarrier barrier = new CyclicBarrier(2);
barrier.await();
System.out.println("after");
""",
            question: "このコードをmainスレッドだけで実行した場合の説明として正しいものはどれか？",
            choices: [
                GoldNonLambdaQuestionData.choice("a", "2つの参加者がそろうまで `await()` で待つ", correct: true, explanation: "CyclicBarrier(2) は2つの参加者がawaitするまで先へ進みません。mainだけでは待機します。"),
                GoldNonLambdaQuestionData.choice("b", "mainスレッド1つで十分なので `after` が出力される", misconception: "parties数を見落としている", explanation: "partiesは2なので、1スレッドだけではバリアが解除されません。"),
                GoldNonLambdaQuestionData.choice("c", "`await()` は参加者数を増やすだけで待たない", misconception: "awaitの待機動作を誤解", explanation: "awaitは必要数に達するまで待機します。"),
                GoldNonLambdaQuestionData.choice("d", "CyclicBarrierは一度も再利用できない", misconception: "Cyclicの意味を誤解", explanation: "CyclicBarrierはバリア解除後に再利用可能です。"),
            ],
            intent: "CyclicBarrierは指定したparties数のawaitがそろうまで各スレッドを待機させることを確認する。",
            steps: [
                GoldNonLambdaQuestionData.step("`CyclicBarrier(2)` は2つの参加者を必要とします。", [1], [GoldNonLambdaQuestionData.variable("parties", "int", "2", "barrier")]),
                GoldNonLambdaQuestionData.step("mainスレッドだけが `await()` を呼ぶと、参加者はまだ1つだけです。", [2], [GoldNonLambdaQuestionData.variable("arrived", "int", "1", "barrier")]),
                GoldNonLambdaQuestionData.step("2つ目の参加者が来るまで待機するため、このままでは `after` へ進みません。", [2, 3], [GoldNonLambdaQuestionData.variable("state", "String", "waiting", "main")]),
            ]
        ),
    ]
}

extension QuizExpansion {
    static let goldNonLambdaFurtherExpansion: [Quiz] = GoldNonLambdaFurtherQuestionData.specs.map(\.quiz)
}
