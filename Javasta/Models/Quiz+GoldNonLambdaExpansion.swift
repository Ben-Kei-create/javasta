import Foundation

enum GoldNonLambdaQuestionData {
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
        let codeTabs: [Quiz.CodeFile]?
        let question: String
        let choices: [ChoiceSpec]
        let explanationRef: String
        let designIntent: String
        let steps: [StepSpec]
    }

    static let specs: [Spec] = [
        // MARK: - Module System

        q(
            "gold-nonlambda-module-transitive-access-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "module-system",
            tags: ["requires transitive", "exports", "readability"],
            code: """
package client;

import alpha.Name;
import beta.Bridge;

public class Main {
    public static void main(String[] args) {
        System.out.println(Name.value() + ":" + Bridge.value());
    }
}
""",
            codeTabs: [
                file("alpha.core/module-info.java", "module alpha.core { exports alpha; }"),
                file("alpha.core/alpha/Name.java", """
package alpha;
public class Name {
    public static String value() { return "alpha"; }
}
"""),
                file("beta.core/module-info.java", "module beta.core { requires transitive alpha.core; exports beta; }"),
                file("beta.core/beta/Bridge.java", """
package beta;
public class Bridge {
    public static String value() { return alpha.Name.value(); }
}
"""),
                file("client.app/module-info.java", "module client.app { requires beta.core; }"),
                file("client.app/client/Main.java", """
package client;
import alpha.Name;
import beta.Bridge;
public class Main {
    public static void main(String[] args) {
        System.out.println(Name.value() + ":" + Bridge.value());
    }
}
""")
            ],
            question: "`client.app` が `alpha.Name` を直接importできる理由として正しいものはどれか？",
            choices: [
                choice("a", "`beta.core` が `requires transitive alpha.core` を宣言しているため", correct: true, explanation: "`client.app` は `beta.core` を読むだけで、推移的に `alpha.core` も読むことができます。"),
                choice("b", "`alpha.Name` がpublicならモジュール宣言に関係なく常に見える", misconception: "publicだけでモジュール境界を越えられると誤解", explanation: "public型でも、パッケージがexportされ、かつモジュールを読める必要があります。"),
                choice("c", "`Bridge` が `alpha.Name` を使っているため自動的に再exportされる", misconception: "利用しているだけで公開されると誤解", explanation: "再exportされるのは `requires transitive` の効果です。単に使うだけでは公開されません。"),
                choice("d", "`client.app` で `requires alpha.core` を書いていないためコンパイルエラーになる", misconception: "推移的依存を見落としている", explanation: "この例では `requires transitive` により `alpha.core` も読めます。"),
            ],
            intent: "requires transitiveが依存先モジュールの読み取りを利用側へ推移させることを確認する。",
            steps: [
                step("`client.app` は `module-info.java` で `beta.core` だけをrequiresしています。", [1, 3, 4], [variable("client reads", "module", "beta.core", "module graph")]),
                step("`beta.core` は `requires transitive alpha.core` を宣言しています。これにより `beta.core` を読むモジュールは `alpha.core` も読めます。", [3], [variable("transitive edge", "module", "beta.core -> alpha.core", "module graph")]),
                step("`alpha.core` は `alpha` パッケージをexportsしているため、`client.app` は `alpha.Name` を直接参照できます。", [3, 8], [variable("result", "String", "alpha:alpha", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-module-nontransitive-access-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "module-system",
            tags: ["requires", "exports", "readability"],
            code: """
package client;

import alpha.Name;

public class Main {
    public static void main(String[] args) {
        System.out.println(Name.value());
    }
}
""",
            codeTabs: [
                file("alpha.core/module-info.java", "module alpha.core { exports alpha; }"),
                file("alpha.core/alpha/Name.java", """
package alpha;
public class Name {
    public static String value() { return "alpha"; }
}
"""),
                file("beta.core/module-info.java", "module beta.core { requires alpha.core; exports beta; }"),
                file("beta.core/beta/Bridge.java", """
package beta;
public class Bridge {
    public static String value() { return alpha.Name.value(); }
}
"""),
                file("client.app/module-info.java", "module client.app { requires beta.core; }"),
                file("client.app/client/Main.java", """
package client;
import alpha.Name;
public class Main {
    public static void main(String[] args) {
        System.out.println(Name.value());
    }
}
""")
            ],
            question: "このモジュール構成で `client.Main` をコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "`alpha` パッケージがexportされているため正常にコンパイルできる", misconception: "exportsだけで十分と誤解", explanation: "exportされていても、参照元モジュールがそのモジュールを読めなければアクセスできません。"),
                choice("b", "`client.app` が `alpha.core` を読んでいないためコンパイルエラーになる", correct: true, explanation: "`beta.core` のrequiresはtransitiveではないので、`client.app` へ `alpha.core` の読み取りは伝わりません。"),
                choice("c", "実行時だけ `NoClassDefFoundError` になる", misconception: "モジュールの読み取り不足を実行時問題と誤解", explanation: "名前解決の段階でコンパイルエラーになります。"),
                choice("d", "`beta.Bridge` をimportしていないことだけが原因でコンパイルエラーになる", misconception: "直接使う型のモジュール境界を見ていない", explanation: "問題は `alpha.Name` を含む `alpha.core` を `client.app` が読めないことです。"),
            ],
            intent: "通常のrequiresは推移せず、利用側が直接読めないモジュールのexport型にはアクセスできないことを確認する。",
            steps: [
                step("`beta.core` は `alpha.core` をrequiresしていますが、transitiveではありません。", [1], [variable("requires kind", "String", "non-transitive", "beta.core")]),
                step("`client.app` は `beta.core` だけをrequiresしているため、`alpha.core` を読む関係がありません。", [1, 3], [variable("client reads alpha.core", "boolean", "false", "module graph")]),
                step("その状態で `import alpha.Name;` を書くと、`alpha` パッケージは見えずコンパイルエラーです。", [3], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "gold-nonlambda-module-qualified-export-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "module-system",
            tags: ["qualified exports", "exports to"],
            code: """
package other;

import api.Ping;

public class Main {
    public static void main(String[] args) {
        System.out.println(Ping.message());
    }
}
""",
            codeTabs: [
                file("lib.core/module-info.java", "module lib.core { exports api to client.app; }"),
                file("lib.core/api/Ping.java", """
package api;
public class Ping {
    public static String message() { return "pong"; }
}
"""),
                file("other.app/module-info.java", "module other.app { requires lib.core; }"),
                file("other.app/other/Main.java", """
package other;
import api.Ping;
public class Main {
    public static void main(String[] args) {
        System.out.println(Ping.message());
    }
}
""")
            ],
            question: "`other.app` から `api.Ping` を参照した場合の結果として正しいものはどれか？",
            choices: [
                choice("a", "`lib.core` をrequiresしているので正常に参照できる", misconception: "qualified exportの相手を見落としている", explanation: "`api` は `client.app` にだけexportされています。"),
                choice("b", "`api` は `other.app` にexportされていないためコンパイルエラーになる", correct: true, explanation: "`exports api to client.app;` は限定exportなので、`other.app` からはpublic型でも参照できません。"),
                choice("c", "コンパイルはできるが実行時に `IllegalAccessError` になる", misconception: "コンパイル時アクセス検査を実行時だけの問題と誤解", explanation: "モジュールのexport可視性はコンパイル時に検査されます。"),
                choice("d", "`Ping.message()` がstaticなので限定exportの影響を受けない", misconception: "staticメンバーはモジュール境界を無視すると誤解", explanation: "staticかどうかではなく、型を含むパッケージが参照元へexportされているかが重要です。"),
            ],
            intent: "qualified exportsが指定したモジュールにだけパッケージを公開することを確認する。",
            steps: [
                step("`lib.core` は `api` パッケージを `client.app` にだけ限定exportしています。", [1], [variable("export target", "module", "client.app only", "lib.core")]),
                step("`other.app` は `lib.core` を読んでいますが、`api` のexport先には含まれていません。", [1], [variable("api visible to other.app", "boolean", "false", "module graph")]),
                step("そのため `import api.Ping;` の時点で、`api` パッケージへアクセスできずコンパイルエラーです。", [3], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "gold-nonlambda-module-opens-not-export-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "module-system",
            tags: ["opens", "exports", "reflection"],
            code: """
package client;

import model.User;

public class Main {
    public static void main(String[] args) {
        System.out.println(new User().name());
    }
}
""",
            codeTabs: [
                file("model.core/module-info.java", "module model.core { opens model; }"),
                file("model.core/model/User.java", """
package model;
public class User {
    public String name() { return "Ada"; }
}
"""),
                file("client.app/module-info.java", "module client.app { requires model.core; }"),
                file("client.app/client/Main.java", """
package client;
import model.User;
public class Main {
    public static void main(String[] args) {
        System.out.println(new User().name());
    }
}
""")
            ],
            question: "`opens model;` だけが宣言されているとき、`client.app` から `model.User` を通常参照するとどうなるか？",
            choices: [
                choice("a", "正常にコンパイルでき、`Ada` を出力する", misconception: "opensを通常アクセス公開と混同", explanation: "`opens` は主にリフレクション向けで、通常のコンパイル時アクセスには `exports` が必要です。"),
                choice("b", "`model` がexportされていないためコンパイルエラーになる", correct: true, explanation: "`opens model;` だけでは `import model.User;` に必要な通常アクセスは公開されません。"),
                choice("c", "コンパイルはできるが、`new User()` で実行時例外になる", misconception: "コンパイル時の型アクセス検査を見落としている", explanation: "型が見えないため、実行前にコンパイルできません。"),
                choice("d", "`opens` は無名モジュール専用なのでモジュール宣言自体が無効", misconception: "opensの用途を狭く捉えている", explanation: "`opens` は名前付きモジュールでも有効ですが、通常アクセス公開とは別です。"),
            ],
            intent: "opensとexportsの役割の違いを、通常参照とリフレクションの観点で確認する。",
            steps: [
                step("`model.core` は `opens model;` を宣言していますが、`exports model;` はありません。", [1], [variable("exports model", "boolean", "false", "model.core")]),
                step("`opens` は深いリフレクションを許すための宣言であり、通常の `import` による型参照を公開しません。", [3], [variable("normal access", "String", "not exported", "compiler")]),
                step("したがって `client.app` の `import model.User;` はコンパイルエラーになります。", [3], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "gold-nonlambda-module-hidden-package-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "module-system",
            tags: ["exports", "encapsulation"],
            code: """
package client;

import internal.Secret;

public class Main {
    public static void main(String[] args) {
        System.out.println(Secret.value());
    }
}
""",
            codeTabs: [
                file("lib.core/module-info.java", "module lib.core { exports api; }"),
                file("lib.core/api/PublicApi.java", """
package api;
public class PublicApi {
    public static String value() { return internal.Secret.value(); }
}
"""),
                file("lib.core/internal/Secret.java", """
package internal;
public class Secret {
    public static String value() { return "hidden"; }
}
"""),
                file("client.app/module-info.java", "module client.app { requires lib.core; }"),
                file("client.app/client/Main.java", """
package client;
import internal.Secret;
public class Main {
    public static void main(String[] args) {
        System.out.println(Secret.value());
    }
}
""")
            ],
            question: "`client.app` が `internal.Secret` を直接importした場合の説明として正しいものはどれか？",
            choices: [
                choice("a", "`Secret` がpublicなので正常にimportできる", misconception: "publicとexportsの両方が必要な点を見落としている", explanation: "public型でも、所属パッケージがexportされていなければ外部モジュールから通常参照できません。"),
                choice("b", "`internal` パッケージがexportされていないためコンパイルエラーになる", correct: true, explanation: "`lib.core` は `api` だけをexportしています。`internal` はモジュール内に隠蔽されます。"),
                choice("c", "`api.PublicApi` から使われているので `internal` も外部公開される", misconception: "内部利用と外部公開を混同", explanation: "あるexportパッケージのpublic型が内部パッケージを使っていても、その内部パッケージは自動公開されません。"),
                choice("d", "`requires lib.core` を書いた時点で全パッケージが読める", misconception: "readabilityとexportsを混同", explanation: "requiresはモジュールを読む関係を作りますが、参照できるのはexportされたパッケージのpublic型です。"),
            ],
            intent: "モジュール内の非exportパッケージがpublic型を含んでいても外部から隠蔽されることを確認する。",
            steps: [
                step("`lib.core` は `exports api;` だけを宣言し、`internal` はexportしていません。", [1], [variable("exported packages", "Set", "api", "lib.core")]),
                step("`Secret` 自体はpublicですが、所属する `internal` パッケージはモジュール外へ公開されていません。", [3], [variable("internal visible", "boolean", "false", "module graph")]),
                step("そのため `client.app` が `internal.Secret` を直接importするとコンパイルエラーです。", [3], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),

        // MARK: - JDBC

        q(
            "gold-nonlambda-jdbc-parameter-index-001",
            difficulty: .standard,
            estimatedSeconds: 75,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["PreparedStatement", "parameter index", "SQLException"],
            code: """
PreparedStatement ps =
    conn.prepareStatement("select * from users where name = ?");
ps.setString(0, "Ada");
ResultSet rs = ps.executeQuery();
""",
            question: "`ps.setString(0, \"Ada\")` を実行したときの結果として正しいものはどれか？",
            choices: [
                choice("a", "最初の `?` に `Ada` が設定される", misconception: "JDBCのパラメータ番号を0始まりと誤解", explanation: "JDBCのパラメータ番号は1始まりです。"),
                choice("b", "`SQLException` が発生する", correct: true, explanation: "PreparedStatementのパラメータインデックスは1から始まるため、0は無効です。"),
                choice("c", "`executeQuery()` まで例外は発生しない", misconception: "設定時のインデックス検査を見落としている", explanation: "多くの場合、不正なパラメータ番号はsetter呼び出し時に検出されます。"),
                choice("d", "`ResultSet` が空になるだけで例外は発生しない", misconception: "検索条件の不一致とAPI誤用を混同", explanation: "これは条件に合わない検索ではなく、JDBC APIのパラメータ番号誤りです。"),
            ],
            intent: "PreparedStatementで0番パラメータを指定したときに、最初のプレースホルダではなく無効な番号として扱われることを確認する。",
            steps: [
                step("SQLには `?` が1つあります。JDBCではこの最初のプレースホルダの番号は1です。", [1, 2], [variable("first parameter", "int", "1", "PreparedStatement")]),
                step("`setString(0, \"Ada\")` は存在しない0番パラメータを指定しているため無効です。", [3], [variable("requested index", "int", "0", "setter")]),
                step("したがって正しい結果は `SQLException` です。", [3], [variable("result", "Exception", "SQLException", "JDBC")]),
            ]
        ),
        q(
            "gold-nonlambda-jdbc-resultset-cursor-before-first-001",
            difficulty: .standard,
            estimatedSeconds: 90,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["ResultSet", "cursor", "next"],
            code: """
ResultSet rs = stmt.executeQuery("select name from users");
String name = rs.getString(1);
System.out.println(name);
""",
            question: "`ResultSet` 取得直後に `getString(1)` を呼んだ場合の説明として正しいものはどれか？",
            choices: [
                choice("a", "最初の行の1列目が取得される", misconception: "カーソルの初期位置を最初の行と誤解", explanation: "ResultSet取得直後のカーソルは最初の行の前にあります。"),
                choice("b", "`rs.next()` で行へ移動していないため `SQLException` になる", correct: true, explanation: "列値を読む前に、通常は `next()` を呼んで有効な行へカーソルを進めます。"),
                choice("c", "行が存在しない場合だけnullが返る", misconception: "カーソル位置エラーをnull扱いと誤解", explanation: "カーソルが有効な行を指していない状態で列値を読むのは誤りです。"),
                choice("d", "自動的に `next()` が呼ばれる", misconception: "JDBCが自動移動すると誤解", explanation: "ResultSetは明示的にカーソルを進める必要があります。"),
            ],
            intent: "ResultSetのカーソル初期位置が最初の行の前であり、読み取り前にnextが必要なことを確認する。",
            steps: [
                step("`executeQuery` でResultSetを得た直後、カーソルは最初の行そのものではなく「最初の行の前」にあります。", [1], [variable("cursor", "position", "before first", "ResultSet")]),
                step("`rs.getString(1)` は現在行の1列目を読む操作ですが、まだ現在行がありません。", [2], [variable("current row", "boolean", "false", "ResultSet")]),
                step("そのため、まず `rs.next()` を呼ばなければならず、このコードでは `SQLException` になります。", [2], [variable("result", "Exception", "SQLException", "JDBC")]),
            ]
        ),
        q(
            "gold-nonlambda-jdbc-executequery-update-001",
            difficulty: .tricky,
            estimatedSeconds: 90,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["Statement", "executeQuery", "executeUpdate"],
            code: """
Statement stmt = conn.createStatement();
ResultSet rs = stmt.executeQuery("update users set active = true");
System.out.println(rs.next());
""",
            question: "更新SQLに対して `executeQuery` を使った場合の結果として正しいものはどれか？",
            choices: [
                choice("a", "更新件数を1列だけ持つResultSetが返る", misconception: "executeQueryとexecuteUpdateを混同", explanation: "更新件数を扱うには通常 `executeUpdate` を使います。"),
                choice("b", "`SQLException` が発生する", correct: true, explanation: "`executeQuery` はResultSetを返すSQL向けです。更新SQLに使うとSQLExceptionになります。"),
                choice("c", "更新は実行され、`rs.next()` はfalseになる", misconception: "空ResultSetが返ると誤解", explanation: "更新SQLはResultSetを生成しないため、`executeQuery` の用途と合いません。"),
                choice("d", "コンパイルエラーになる", misconception: "SQL文字列の内容をコンパイラが検査すると誤解", explanation: "メソッド呼び出し自体は型としては成立し、実行時にJDBCが検査します。"),
            ],
            intent: "JDBCのexecuteQueryとexecuteUpdateの使い分けを確認する。",
            steps: [
                step("SQL文字列は `update users set active = true` で、行を更新する文です。", [2], [variable("sql kind", "String", "UPDATE", "JDBC")]),
                step("`executeQuery` はSELECTなどResultSetを返すSQLのためのメソッドです。", [2], [variable("method expects", "String", "query producing ResultSet", "Statement")]),
                step("更新SQLには `executeUpdate` を使うべきで、この呼び出しは `SQLException` になります。", [2], [variable("result", "Exception", "SQLException", "JDBC")]),
            ]
        ),
        q(
            "gold-nonlambda-jdbc-rollback-001",
            difficulty: .standard,
            estimatedSeconds: 100,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["transaction", "rollback", "autoCommit"],
            code: """
conn.setAutoCommit(false);
try (PreparedStatement ps =
        conn.prepareStatement("update accounts set balance = 0 where id = 1")) {
    ps.executeUpdate();
    conn.rollback();
}
""",
            question: "このトランザクション処理について正しい説明はどれか？",
            choices: [
                choice("a", "`executeUpdate()` した時点で必ず確定する", misconception: "autoCommit=falseを見落としている", explanation: "autoCommitをfalseにしているため、明示的なcommitまで確定しません。"),
                choice("b", "`rollback()` により、このトランザクション内の更新は取り消される", correct: true, explanation: "autoCommit=falseの状態で実行した更新は、commit前ならrollbackで取り消せます。"),
                choice("c", "try-with-resourcesを抜けると自動的にcommitされる", misconception: "リソースクローズとトランザクション確定を混同", explanation: "PreparedStatementのcloseはトランザクションのcommitとは別です。"),
                choice("d", "`setAutoCommit(false)` の直後にrollbackするとコンパイルエラーになる", misconception: "トランザクション制御を構文規則と混同", explanation: "rollbackは通常のメソッド呼び出しであり、コンパイルエラーではありません。"),
            ],
            intent: "autoCommitをfalseにしたJDBCトランザクションではcommit前の更新をrollbackできることを確認する。",
            steps: [
                step("`conn.setAutoCommit(false)` により、各SQLが自動確定されない状態になります。", [1], [variable("autoCommit", "boolean", "false", "Connection")]),
                step("`executeUpdate()` で更新は行われますが、まだcommitされていません。", [4], [variable("update state", "String", "pending", "transaction")]),
                step("続く `conn.rollback()` により、このトランザクション内の未確定更新は取り消されます。", [5], [variable("result", "String", "rolled back", "transaction")]),
            ]
        ),
        q(
            "gold-nonlambda-jdbc-wasnull-001",
            difficulty: .tricky,
            estimatedSeconds: 100,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["ResultSet", "wasNull", "NULL"],
            code: """
// 現在行: id = 10, nickname = SQL NULL
int id = rs.getInt("id");
String nickname = rs.getString("nickname");
boolean missing = rs.wasNull();
System.out.println(id + ":" + missing);
""",
            question: "`rs.wasNull()` が判定している対象として正しいものはどれか？",
            choices: [
                choice("a", "`getInt(\"id\")` で読んだid列", misconception: "wasNullが任意の過去列を覚えると誤解", explanation: "`wasNull()` は直前に読んだ列の値がSQL NULLだったかを返します。"),
                choice("b", "直前の `getString(\"nickname\")` で読んだnickname列", correct: true, explanation: "`wasNull()` は最後に呼んだgetterの結果に対応します。この例ではnicknameです。"),
                choice("c", "現在行にNULL列が1つでもあるか", misconception: "行全体のNULL検査だと誤解", explanation: "行全体ではなく、直前の列読み取りに対する判定です。"),
                choice("d", "ResultSetに次の行があるか", misconception: "nextの結果と混同", explanation: "次行の有無は `next()` の戻り値で確認します。"),
            ],
            intent: "ResultSet.wasNullが直前のgetter呼び出しに対するNULL判定であることを確認する。",
            steps: [
                step("まず `getInt(\"id\")` でid列を読みます。この列は10です。", [2], [variable("last read", "column", "id = 10", "ResultSet")]),
                step("次に `getString(\"nickname\")` でnickname列を読みます。この列はSQL NULLです。", [3], [variable("last read", "column", "nickname = NULL", "ResultSet")]),
                step("`wasNull()` は直前に読んだnickname列に対応するため、`missing` はtrueです。出力は `10:true` です。", [4, 5], [variable("missing", "boolean", "true", "main")]),
            ]
        ),

        // MARK: - Date Time

        q(
            "gold-nonlambda-datetime-plusmonths-leap-001",
            category: "date-time",
            tags: ["LocalDate", "plusMonths", "leap year"],
            code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        LocalDate date = LocalDate.of(2024, 1, 31);
        System.out.println(date.plusMonths(1));
    }
}
""",
            question: "この日付APIコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2024-02-31", misconception: "存在しない日付がそのまま保持されると誤解", explanation: "2月31日は存在しないため、月末に調整されます。"),
                choice("b", "2024-02-29", correct: true, explanation: "2024年はうるう年で、1月31日に1か月足すと2月末の29日に調整されます。"),
                choice("c", "2024-03-02", misconception: "あふれた日数を翌月へ繰り越すと誤解", explanation: "`plusMonths` は月末調整を行い、3月へ繰り越しません。"),
                choice("d", "DateTimeException", misconception: "結果日が存在しないと例外になると誤解", explanation: "`plusMonths` は有効な日付へ調整します。"),
            ],
            intent: "LocalDate.plusMonthsが月末を有効な最終日に調整することを確認する。",
            steps: [
                step("基準日はうるう年2024年の1月31日です。", [5], [variable("date", "LocalDate", "2024-01-31", "main")]),
                step("1か月後の2024年2月には31日が存在しません。`plusMonths` は月末へ調整します。", [6], [variable("adjusted day", "int", "29", "date-time")]),
                step("2024年2月の最終日は29日なので、出力は `2024-02-29` です。", [6], [variable("output", "LocalDate", "2024-02-29", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-datetime-period-between-leap-001",
            category: "date-time",
            tags: ["Period", "between", "leap year"],
            code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        LocalDate start = LocalDate.of(2024, 2, 28);
        LocalDate end = LocalDate.of(2024, 3, 1);
        Period p = Period.between(start, end);
        System.out.println(p.getDays());
    }
}
""",
            question: "この `Period` の日数部分として出力される値はどれか？",
            choices: [
                choice("a", "1", misconception: "2月29日を見落としている", explanation: "2024年はうるう年なので、2月28日から3月1日までは2日差です。"),
                choice("b", "2", correct: true, explanation: "2月28日から2月29日、さらに3月1日で2日分の差です。"),
                choice("c", "3", misconception: "開始日と終了日を両方含めて数えている", explanation: "`Period.between` は日付間の差であり、単純な包含カウントではありません。"),
                choice("d", "0", misconception: "月をまたぐとdaysが0になると誤解", explanation: "この範囲では月部分ではなく日部分として2日が表現されます。"),
            ],
            intent: "うるう年をまたぐPeriod.betweenの日数部分を確認する。",
            steps: [
                step("開始日は2024年2月28日、終了日は2024年3月1日です。", [5, 6], [variable("start", "LocalDate", "2024-02-28", "main"), variable("end", "LocalDate", "2024-03-01", "main")]),
                step("2024年はうるう年なので、2月29日が存在します。開始日から終了日までの差は2日です。", [7], [variable("period", "Period", "P2D", "date-time")]),
                step("`p.getDays()` は2を返すため、出力は `2` です。", [8], [variable("output", "int", "2", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-datetime-pattern-month-minute-001",
            difficulty: .standard,
            category: "date-time",
            tags: ["DateTimeFormatter", "pattern", "MM", "mm"],
            code: """
import java.time.*;
import java.time.format.*;

public class Test {
    public static void main(String[] args) {
        LocalDateTime dt = LocalDateTime.of(2024, 5, 6, 7, 8);
        DateTimeFormatter f = DateTimeFormatter.ofPattern("MM:mm");
        System.out.println(dt.format(f));
    }
}
""",
            question: "`MM:mm` というパターンでフォーマットした結果はどれか？",
            choices: [
                choice("a", "05:08", correct: true, explanation: "`MM` は月、`mm` は分です。5月8分なので `05:08` になります。"),
                choice("b", "08:05", misconception: "MMとmmの意味を逆にしている", explanation: "大文字Mはmonth、小文字mはminuteです。"),
                choice("c", "07:08", misconception: "MMを時として読んでいる", explanation: "時は `HH` などで表します。"),
                choice("d", "2024:05", misconception: "MMが年を含むと誤解", explanation: "年は `yyyy` などのパターン文字を使います。"),
            ],
            intent: "DateTimeFormatterの大文字Mと小文字mの違いを確認する。",
            steps: [
                step("`LocalDateTime` は2024年5月6日7時8分です。", [6], [variable("dt", "LocalDateTime", "2024-05-06T07:08", "main")]),
                step("パターン `MM:mm` の `MM` は月、`mm` は分を表します。", [7], [variable("pattern", "String", "month:minute", "formatter")]),
                step("月は05、分は08なので、出力は `05:08` です。", [8], [variable("output", "String", "05:08", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-datetime-duration-minutes-001",
            category: "date-time",
            tags: ["Duration", "LocalDateTime", "toMinutes"],
            code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        LocalDateTime start = LocalDateTime.of(2024, 1, 1, 10, 0);
        LocalDateTime end = start.plusMinutes(90);
        Duration d = Duration.between(start, end);
        System.out.println(d.toHours() + ":" + d.toMinutes());
    }
}
""",
            question: "この `Duration` の出力として正しいものはどれか？",
            choices: [
                choice("a", "1:30", misconception: "toMinutesが時間を除いた分部分だけを返すと誤解", explanation: "`toMinutes()` は合計分数を返します。"),
                choice("b", "1:90", correct: true, explanation: "90分は1時間30分ですが、`toMinutes()` は合計90分を返します。"),
                choice("c", "2:90", misconception: "toHoursが切り上げだと誤解", explanation: "`toHours()` は完全な時間数として1を返します。"),
                choice("d", "0:90", misconception: "90分未満だけが時間換算されると誤解", explanation: "90分には完全な1時間が含まれます。"),
            ],
            intent: "DurationのtoHoursとtoMinutesが合計単位への変換であることを確認する。",
            steps: [
                step("開始時刻は10:00で、終了時刻は90分後の11:30です。", [5, 6], [variable("start", "LocalDateTime", "2024-01-01T10:00", "main"), variable("end", "LocalDateTime", "2024-01-01T11:30", "main")]),
                step("`Duration.between` は90分の時間量を表します。", [7], [variable("duration", "Duration", "PT1H30M", "date-time")]),
                step("`toHours()` は1、`toMinutes()` は合計分の90なので、出力は `1:90` です。", [8], [variable("output", "String", "1:90", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-datetime-offset-same-instant-001",
            difficulty: .tricky,
            category: "date-time",
            tags: ["OffsetDateTime", "withOffsetSameInstant", "UTC"],
            code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        OffsetDateTime tokyo =
            OffsetDateTime.parse("2024-01-01T00:00:00+09:00");
        System.out.println(tokyo.withOffsetSameInstant(ZoneOffset.UTC));
    }
}
""",
            question: "`withOffsetSameInstant(ZoneOffset.UTC)` の出力として正しいものはどれか？",
            choices: [
                choice("a", "2024-01-01T00:00Z", misconception: "ローカル時刻を固定したままオフセットだけ変えると誤解", explanation: "同じ瞬間を保つため、UTCでは9時間前の時刻になります。"),
                choice("b", "2023-12-31T15:00Z", correct: true, explanation: "+09:00の2024-01-01 00:00はUTCでは2023-12-31 15:00です。"),
                choice("c", "2024-01-01T09:00Z", misconception: "UTCへ9時間足している", explanation: "+09:00からUTCへ変換する場合は9時間戻します。"),
                choice("d", "DateTimeException", misconception: "日付が前年に戻る変換が無効だと誤解", explanation: "同じ瞬間を別オフセットで表すため、日付が変わることは有効です。"),
            ],
            intent: "withOffsetSameInstantが同じ瞬間を保ったままオフセット表現を変えることを確認する。",
            steps: [
                step("`tokyo` は+09:00の2024年1月1日0時を表します。", [5, 6], [variable("tokyo", "OffsetDateTime", "2024-01-01T00:00+09:00", "main")]),
                step("UTCは+09:00より9時間前なので、同じ瞬間をUTCで表すと前日の15時です。", [7], [variable("utc instant", "OffsetDateTime", "2023-12-31T15:00Z", "date-time")]),
                step("したがって出力は `2023-12-31T15:00Z` です。", [7], [variable("output", "String", "2023-12-31T15:00Z", "stdout")]),
            ]
        ),

        // MARK: - I/O

        q(
            "gold-nonlambda-io-path-normalize-001",
            category: "io",
            tags: ["Path", "normalize", "NIO.2"],
            code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path p = Path.of("a/./b/../c");
        System.out.println(p.normalize());
    }
}
""",
            question: "Unix系の区切り文字で考えた場合、このPathの正規化結果はどれか？",
            choices: [
                choice("a", "a/./b/../c", misconception: "normalizeが何もしないと誤解", explanation: "`.` と `..` は可能な範囲で取り除かれます。"),
                choice("b", "a/c", correct: true, explanation: "`./` は現在ディレクトリ、`b/..` は打ち消されるため `a/c` になります。"),
                choice("c", "c", misconception: "先頭のaまで消えると誤解", explanation: "`b/..` が消えるだけで、`a` は残ります。"),
                choice("d", "../c", misconception: "相対パス全体が親方向に進むと誤解", explanation: "この例では `..` は直前の `b` と打ち消し合います。"),
            ],
            intent: "Path.normalizeが冗長な名前要素を取り除く挙動を確認する。",
            steps: [
                step("元のPathは `a/./b/../c` です。", [5], [variable("p", "Path", "a/./b/../c", "main")]),
                step("`.` は現在ディレクトリなので消え、`b/..` は直前要素bを打ち消します。", [6], [variable("normalized elements", "List", "a, c", "Path")]),
                step("残る要素は `a` と `c` なので、出力は `a/c` です。", [6], [variable("output", "Path", "a/c", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-io-path-resolve-sibling-001",
            category: "io",
            tags: ["Path", "resolveSibling", "NIO.2"],
            code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path p = Path.of("logs/app.txt");
        System.out.println(p.resolveSibling("error.txt"));
    }
}
""",
            question: "`resolveSibling(\"error.txt\")` の結果として正しいものはどれか？",
            choices: [
                choice("a", "logs/app.txt/error.txt", misconception: "resolveと同じく子要素を足すと誤解", explanation: "`resolveSibling` は同じ親の別名を解決します。"),
                choice("b", "logs/error.txt", correct: true, explanation: "`app.txt` の親 `logs` の下で `error.txt` を解決します。"),
                choice("c", "error.txt/app.txt", misconception: "引数側を親として扱うと誤解", explanation: "元Pathの親を使い、引数を兄弟名として解決します。"),
                choice("d", "app.txt/error.txt", misconception: "親ディレクトリlogsが消えると誤解", explanation: "元Pathの親 `logs` は残ります。"),
            ],
            intent: "Path.resolveSiblingが同じ親ディレクトリ上の別パスを作ることを確認する。",
            steps: [
                step("元Path `logs/app.txt` の親は `logs`、ファイル名は `app.txt` です。", [5], [variable("parent", "Path", "logs", "Path")]),
                step("`resolveSibling(\"error.txt\")` は親 `logs` の下に `error.txt` を置いたPathを作ります。", [6], [variable("sibling", "Path", "logs/error.txt", "Path")]),
                step("したがって出力は `logs/error.txt` です。", [6], [variable("output", "Path", "logs/error.txt", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-io-path-relativize-001",
            difficulty: .standard,
            category: "io",
            tags: ["Path", "relativize", "NIO.2"],
            code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path base = Path.of("project/src");
        Path target = Path.of("project/src/main/App.java");
        System.out.println(base.relativize(target));
    }
}
""",
            question: "`base.relativize(target)` の結果として正しいものはどれか？",
            choices: [
                choice("a", "main/App.java", correct: true, explanation: "`target` は `base` の下にあるため、baseからの相対パスは `main/App.java` です。"),
                choice("b", "project/src/main/App.java", misconception: "target全体が返ると誤解", explanation: "`relativize` は元Pathから見た相対Pathを返します。"),
                choice("c", "../main/App.java", misconception: "一度親へ戻る必要があると誤解", explanation: "targetはbase配下なので親へ戻る必要はありません。"),
                choice("d", "src/main/App.java", misconception: "共通部分projectだけが消えると誤解", explanation: "`base` 全体 `project/src` が基準です。"),
            ],
            intent: "Path.relativizeが基準Pathから対象Pathへの相対パスを返すことを確認する。",
            steps: [
                step("基準Pathは `project/src`、対象Pathは `project/src/main/App.java` です。", [5, 6], [variable("base", "Path", "project/src", "main"), variable("target", "Path", "project/src/main/App.java", "main")]),
                step("対象Pathは基準Pathの配下にあるため、共通部分 `project/src` が取り除かれます。", [7], [variable("relative part", "Path", "main/App.java", "Path")]),
                step("出力は `main/App.java` です。", [7], [variable("output", "Path", "main/App.java", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-io-bytearray-close-001",
            difficulty: .tricky,
            category: "io",
            tags: ["ByteArrayOutputStream", "close", "I/O"],
            code: """
import java.io.*;

public class Test {
    public static void main(String[] args) throws Exception {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        out.write('A');
        out.close();
        out.write('B');
        System.out.println(out.toString());
    }
}
""",
            question: "`ByteArrayOutputStream` をcloseした後にwriteした場合の出力はどれか？",
            choices: [
                choice("a", "A", misconception: "close後のwriteが無視されると誤解", explanation: "ByteArrayOutputStreamのcloseは効果を持たず、以後のメソッドも呼べます。"),
                choice("b", "AB", correct: true, explanation: "`ByteArrayOutputStream.close()` は何もしないため、close後のwriteもバッファに追加されます。"),
                choice("c", "IOException", misconception: "すべてのOutputStreamがclose後に例外を投げると誤解", explanation: "一般化はできません。ByteArrayOutputStreamではclose後も使用できます。"),
                choice("d", "B", misconception: "closeでバッファがリセットされると誤解", explanation: "closeしてもバッファ内容は消えません。"),
            ],
            intent: "ByteArrayOutputStream.closeの特殊な挙動を確認する。",
            steps: [
                step("まず `out.write('A')` により、内部バッファにAが入ります。", [5, 6], [variable("buffer", "byte[]", "A", "ByteArrayOutputStream")]),
                step("`ByteArrayOutputStream.close()` は効果を持たないため、以後のwriteも可能です。", [7], [variable("closed effect", "String", "no effect", "ByteArrayOutputStream")]),
                step("`out.write('B')` でBが追加され、`toString()` の出力は `AB` です。", [8, 9], [variable("output", "String", "AB", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-io-dataoutputstream-endian-001",
            difficulty: .tricky,
            category: "io",
            tags: ["DataOutputStream", "byte order", "writeInt"],
            code: """
import java.io.*;
import java.util.*;

public class Test {
    public static void main(String[] args) throws Exception {
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        DataOutputStream out = new DataOutputStream(bytes);
        out.writeInt(0x01020304);
        System.out.println(Arrays.toString(bytes.toByteArray()));
    }
}
""",
            question: "`writeInt(0x01020304)` で書き込まれるバイト列として正しいものはどれか？",
            choices: [
                choice("a", "[1, 2, 3, 4]", correct: true, explanation: "DataOutputStreamは上位バイトから順に、ビッグエンディアンで書き込みます。"),
                choice("b", "[4, 3, 2, 1]", misconception: "リトルエンディアンで書かれると誤解", explanation: "DataOutputStreamの多バイト値は高位バイトから書かれます。"),
                choice("c", "[16909060]", misconception: "intが1要素として配列に入ると誤解", explanation: "ByteArrayOutputStreamにはバイト単位で4要素が書き込まれます。"),
                choice("d", "[0, 1, 2, 3, 4]", misconception: "符号や長さ用の先頭バイトが付くと誤解", explanation: "`writeInt` はintの4バイトを書きます。長さ情報は付けません。"),
            ],
            intent: "DataOutputStream.writeIntがビッグエンディアン順に4バイトを書き込むことを確認する。",
            steps: [
                step("`0x01020304` は上位から `01 02 03 04` の4バイトで構成されます。", [8], [variable("value", "int", "0x01020304", "main")]),
                step("`DataOutputStream.writeInt` は高位バイトから順に書き込みます。", [8], [variable("byte order", "String", "big-endian", "DataOutputStream")]),
                step("配列にすると `[1, 2, 3, 4]` が出力されます。", [9], [variable("output", "byte[]", "[1, 2, 3, 4]", "stdout")]),
            ]
        ),

        // MARK: - Inheritance

        q(
            "gold-nonlambda-inheritance-interface-private-001",
            category: "inheritance",
            tags: ["interface", "private method", "default method"],
            code: """
interface Printable {
    private String prefix() { return "Java"; }
    default String text() { return prefix() + " Gold"; }
}

class Report implements Printable { }

public class Test {
    public static void main(String[] args) {
        System.out.println(new Report().text());
    }
}
""",
            question: "このインタフェースのprivateメソッドを使うコードの出力はどれか？",
            choices: [
                choice("a", "Java Gold", correct: true, explanation: "インタフェースのprivateメソッドは同じインタフェース内のdefaultメソッドから呼び出せます。"),
                choice("b", "Gold", misconception: "privateメソッドが呼ばれないと誤解", explanation: "`text()` は `prefix()` の戻り値を連結しています。"),
                choice("c", "コンパイルエラー", misconception: "インタフェースにprivateメソッドを書けないと誤解", explanation: "Java 9以降、インタフェースにはprivateメソッドを定義できます。"),
                choice("d", "実行時にIllegalAccessError", misconception: "同一インタフェース内からのprivate呼び出しも禁止と誤解", explanation: "privateメソッドは外部から呼べませんが、同じインタフェース内からは呼べます。"),
            ],
            intent: "インタフェースprivateメソッドがdefaultメソッドの共通処理として使えることを確認する。",
            steps: [
                step("`Printable` にはprivateメソッド `prefix()` とdefaultメソッド `text()` があります。", [1, 2, 3], [variable("prefix()", "String", "Java", "Printable")]),
                step("`Report` は `text()` をオーバーライドしていないため、インタフェースのdefault実装を使います。", [6, 10], [variable("method", "String", "Printable.text", "dispatch")]),
                step("`text()` 内で `prefix()` が呼ばれ、`Java Gold` が出力されます。", [3, 10], [variable("output", "String", "Java Gold", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-inheritance-sealed-modifier-001",
            difficulty: .standard,
            category: "inheritance",
            tags: ["sealed", "permits", "final"],
            code: """
sealed class Animal permits Dog { }

class Dog extends Animal { }

public class Test {
    public static void main(String[] args) {
        System.out.println(new Dog().getClass().getSimpleName());
    }
}
""",
            question: "このsealed classのサブクラス宣言について正しい説明はどれか？",
            choices: [
                choice("a", "`Dog` はpermitsに含まれるため、このままで正常にコンパイルできる", misconception: "permitsだけで十分と誤解", explanation: "sealed classの直接サブクラスは `final`、`sealed`、`non-sealed` のいずれかを宣言する必要があります。"),
                choice("b", "`Dog` に `final`、`sealed`、`non-sealed` のいずれもないためコンパイルエラーになる", correct: true, explanation: "許可された直接サブクラスでも、継承方針を明示する修飾子が必要です。"),
                choice("c", "`Dog` はpublicでないため実行時にエラーになる", misconception: "アクセス修飾子の問題と混同", explanation: "この問題の原因はsealed階層のサブクラス修飾子です。"),
                choice("d", "`permits Dog` は同じファイル内では書けない", misconception: "permitsの場所を誤解", explanation: "同じモジュールまたはパッケージなどの条件を満たせばpermits宣言は可能です。"),
            ],
            intent: "sealed classの直接サブクラスには継承方針を示す修飾子が必要なことを確認する。",
            steps: [
                step("`Animal` はsealed classで、直接サブクラスとして `Dog` を許可しています。", [1], [variable("permitted subclass", "Class", "Dog", "Animal")]),
                step("許可されたサブクラスでも、`final`、`sealed`、`non-sealed` のいずれかで次の継承方針を示す必要があります。", [3], [variable("Dog modifier", "String", "missing", "compiler")]),
                step("`class Dog extends Animal` にはその修飾子がないため、コンパイルエラーです。", [3], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "gold-nonlambda-inheritance-static-hiding-001",
            difficulty: .tricky,
            category: "inheritance",
            tags: ["static method", "hiding", "polymorphism"],
            code: """
class Parent {
    static String name() { return "Parent"; }
}

class Child extends Parent {
    static String name() { return "Child"; }
}

public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        System.out.println(p.name());
    }
}
""",
            question: "`p.name()` の出力として正しいものはどれか？",
            choices: [
                choice("a", "Parent", correct: true, explanation: "staticメソッドはオーバーライドではなく隠蔽です。参照型Parentに基づき `Parent.name()` が選ばれます。"),
                choice("b", "Child", misconception: "staticメソッドにも動的ディスパッチが働くと誤解", explanation: "インスタンスメソッドと異なり、staticメソッドは実行時型では選ばれません。"),
                choice("c", "コンパイルエラー", misconception: "staticメソッドを参照変数経由で呼べないと誤解", explanation: "推奨されませんが、参照変数経由の呼び出しはコンパイルできます。"),
                choice("d", "ClassCastException", misconception: "参照型と実体型の違いを実行時例外と誤解", explanation: "代入は有効で、staticメソッド選択はコンパイル時の参照型で決まります。"),
            ],
            intent: "staticメソッドの隠蔽はインスタンスメソッドのオーバーライドと異なり参照型で解決されることを確認する。",
            steps: [
                step("`Parent p = new Child();` により、参照型はParent、実体はChildです。", [11], [variable("reference type", "Class", "Parent", "main"), variable("object type", "Class", "Child", "heap")]),
                step("`name()` はstaticメソッドなので、実体型Childではなく参照型Parentに基づいて解決されます。", [12], [variable("selected method", "String", "Parent.name", "compiler")]),
                step("したがって出力は `Parent` です。", [12], [variable("output", "String", "Parent", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-inheritance-covariant-return-001",
            category: "inheritance",
            tags: ["covariant return", "override"],
            code: """
class Base {
    Base copy() { return new Base(); }
}

class Sub extends Base {
    @Override
    Sub copy() { return new Sub(); }
}

public class Test {
    public static void main(String[] args) {
        Base b = new Sub();
        System.out.println(b.copy().getClass().getSimpleName());
    }
}
""",
            question: "この戻り値型を変えたオーバーライドの出力はどれか？",
            choices: [
                choice("a", "Base", misconception: "参照型Baseの戻り値型だけで生成型もBaseになると誤解", explanation: "実行されるメソッド本体はSub側で、`new Sub()` を返します。"),
                choice("b", "Sub", correct: true, explanation: "戻り値型は共変戻り値としてBaseのサブタイプSubにできます。動的ディスパッチでSub.copyが実行されます。"),
                choice("c", "コンパイルエラー", misconception: "戻り値型を変えるオーバーライドは常に禁止と誤解", explanation: "戻り値型が元の戻り値型のサブタイプなら共変戻り値として許可されます。"),
                choice("d", "ClassCastException", misconception: "Base型で受けるとSubを返せないと誤解", explanation: "SubはBaseのサブタイプなのでBaseとして扱えます。"),
            ],
            intent: "共変戻り値でSubを返すオーバーライドが、Base参照から呼ばれても実行時にはSubインスタンスを返すことを確認する。",
            steps: [
                step("`Sub.copy()` は `Base.copy()` をオーバーライドし、戻り値型をサブタイプのSubにしています。", [5, 6, 7], [variable("return type", "Class", "Sub extends Base", "Sub.copy")]),
                step("`Base b = new Sub();` なので、`b.copy()` は動的ディスパッチによりSub側の実装を呼びます。", [12, 13], [variable("dispatched method", "String", "Sub.copy", "runtime")]),
                step("Sub側は `new Sub()` を返すため、実体クラス名は `Sub` です。", [7, 13], [variable("output", "String", "Sub", "stdout")]),
            ]
        ),

        // MARK: - Generics

        q(
            "gold-nonlambda-generics-super-get-001",
            category: "generics",
            tags: ["wildcard", "super", "PECS"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<? super Integer> nums = new ArrayList<Number>();
        nums.add(10);
        Object value = nums.get(0);
        System.out.println(value.getClass().getSimpleName());
    }
}
""",
            question: "`List<? super Integer>` の読み書きについて正しい出力はどれか？",
            choices: [
                choice("a", "Integer", correct: true, explanation: "`Integer` は追加できます。取得時の静的型はObjectですが、実体は追加したIntegerです。"),
                choice("b", "Number", misconception: "ArrayList<Number>に入るとIntegerがNumberオブジェクトへ変わると誤解", explanation: "IntegerインスタンスはNumberとして扱えますが、実体クラスはIntegerのままです。"),
                choice("c", "コンパイルエラー", misconception: "superワイルドカードには追加できないと誤解", explanation: "`? super Integer` にはIntegerやそのサブタイプを追加できます。"),
                choice("d", "Object", misconception: "静的型Objectと実体クラスを混同", explanation: "`value` 変数の静的型はObjectですが、`getClass()` は実体クラスを返します。"),
            ],
            intent: "superワイルドカードではIntegerを書き込めるが読み取りの静的型はObjectになることを確認する。",
            steps: [
                step("`List<? super Integer>` はIntegerのスーパータイプを要素型に持つリストを参照できます。ここでは `ArrayList<Number>` です。", [5], [variable("nums", "List<? super Integer>", "ArrayList<Number>", "main")]),
                step("Integer値10は安全に追加できます。取得時の静的型はObjectです。", [6, 7], [variable("value static type", "Class", "Object", "compiler")]),
                step("実体は追加したIntegerなので、`getClass().getSimpleName()` は `Integer` です。", [8], [variable("output", "String", "Integer", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-generics-extends-add-001",
            difficulty: .standard,
            category: "generics",
            tags: ["wildcard", "extends", "PECS"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<? extends Number> nums = new ArrayList<Integer>();
        nums.add(10);
        System.out.println(nums.size());
    }
}
""",
            question: "`List<? extends Number>` に `nums.add(10)` した場合の結果はどれか？",
            choices: [
                choice("a", "1が出力される", misconception: "extendsならNumberのサブタイプを追加できると誤解", explanation: "実際のリストが `ArrayList<Double>` かもしれないため、Integer追加は安全ではありません。"),
                choice("b", "0が出力される", misconception: "addが無視されると誤解", explanation: "無視されるのではなく、コンパイル時に禁止されます。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "`? extends Number` からNumberとして読み取ることはできますが、具体的な要素型が不明なためIntegerを追加できません。"),
                choice("d", "実行時にClassCastExceptionになる", misconception: "ジェネリクスの安全性検査を実行時だけの問題と誤解", explanation: "このaddはコンパイル時に拒否されます。"),
            ],
            intent: "extendsワイルドカードは主に読み取り向けで、具体値の追加ができないことを確認する。",
            steps: [
                step("`List<? extends Number>` はNumberの何らかのサブタイプのリストを表します。", [5], [variable("element type", "String", "unknown subtype of Number", "compiler")]),
                step("参照先が `ArrayList<Integer>` で初期化されていても、変数型からは具体的な要素型を安全に決められません。", [5, 6], [variable("can add Integer", "boolean", "false", "compiler")]),
                step("そのため `nums.add(10)` はコンパイルエラーです。", [6], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "gold-nonlambda-generics-erasure-overload-001",
            difficulty: .tricky,
            category: "generics",
            tags: ["erasure", "overload", "List"],
            code: """
import java.util.*;

public class Test {
    void print(List<String> values) {
        System.out.println("String");
    }
    void print(List<Integer> values) {
        System.out.println("Integer");
    }
}
""",
            question: "この2つの `print` メソッド宣言について正しい説明はどれか？",
            choices: [
                choice("a", "引数の型引数が異なるため正常にオーバーロードできる", misconception: "型消去後のシグネチャを見落としている", explanation: "型引数は消去されるため、どちらも `print(List)` 相当になります。"),
                choice("b", "型消去後のシグネチャが同じになるためコンパイルエラーになる", correct: true, explanation: "`List<String>` と `List<Integer>` はどちらも実行時にはListとして扱われ、同じ消去形になります。"),
                choice("c", "実行時に引数の要素型を見て自動選択される", misconception: "ジェネリクスの型引数が実行時に残ると誤解", explanation: "通常のジェネリクス型引数は実行時のメソッド選択には使われません。"),
                choice("d", "戻り値型がvoidなので型消去の影響を受けない", misconception: "戻り値だけを見ている", explanation: "問題はメソッド引数の消去後シグネチャが衝突することです。"),
            ],
            intent: "ジェネリクスの型消去により型引数だけが異なるList引数ではオーバーロードできないことを確認する。",
            steps: [
                step("1つ目のメソッドは `List<String>`、2つ目は `List<Integer>` を受け取ります。", [4, 7], [variable("declared signatures", "String", "print(List<String>), print(List<Integer>)", "source")]),
                step("コンパイル時の型消去により、どちらの引数型も実行時シグネチャでは `List` になります。", [4, 7], [variable("erased signature", "String", "print(List)", "compiler")]),
                step("同じ消去後シグネチャのメソッドを同じクラスに宣言できないため、コンパイルエラーです。", [7], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "gold-nonlambda-generics-generic-array-001",
            difficulty: .standard,
            category: "generics",
            tags: ["generic array", "type erasure"],
            code: """
public class Box<T> {
    private T[] values = new T[3];

    public T get(int index) {
        return values[index];
    }
}
""",
            question: "`new T[3]` を含むこのクラスについて正しい説明はどれか？",
            choices: [
                choice("a", "正常にコンパイルでき、T型配列が作られる", misconception: "型パラメータ配列を直接作れると誤解", explanation: "型消去により、実行時にTの具体型を配列生成へ使えません。"),
                choice("b", "`new T[3]` の箇所でコンパイルエラーになる", correct: true, explanation: "型パラメータTの配列を直接生成することはできません。"),
                choice("c", "コンパイルはできるが、get時に必ずClassCastExceptionになる", misconception: "配列生成禁止を実行時問題と誤解", explanation: "このコードはそもそもコンパイルできません。"),
                choice("d", "`values` をprivateにすれば型安全なのでコンパイルできる", misconception: "アクセス修飾子で配列生成制約が変わると誤解", explanation: "privateかどうかに関係なく、型パラメータ配列の直接生成は禁止です。"),
            ],
            intent: "型消去により型パラメータTの配列を直接生成できないことを確認する。",
            steps: [
                step("`Box<T>` のTは型パラメータであり、実行時には具体的なT型情報が消去されます。", [1], [variable("T", "type parameter", "erased", "compiler")]),
                step("配列生成 `new T[3]` には実行時の要素型情報が必要ですが、Tの具体型は利用できません。", [2], [variable("array creation", "String", "new T[3]", "compiler")]),
                step("そのため `new T[3]` の行でコンパイルエラーになります。", [2], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),

        // MARK: - Module System: Second Batch

        q(
            "gold-nonlambda-module-cyclic-requires-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "module-system",
            tags: ["requires", "cyclic dependence", "module graph"],
            code: """
// a.core/module-info.java
module a.core {
    requires b.core;
}

// b.core/module-info.java
module b.core {
    requires a.core;
}
""",
            question: "この2つのモジュール宣言を同じモジュールグラフに入れた場合の説明として正しいものはどれか？",
            choices: [
                choice("a", "相互にrequiresしているため、両方のpublic型を自由に参照できる", misconception: "循環依存が許されると誤解", explanation: "モジュールの依存グラフでは循環依存は許可されません。"),
                choice("b", "循環依存としてコンパイルエラーになる", correct: true, explanation: "`a.core` が `b.core` を読み、`b.core` が `a.core` を読むため、依存関係が循環します。"),
                choice("c", "実行時だけ `LayerInstantiationException` になる", misconception: "コンパイル時に検出される関係を実行時だけの問題と誤解", explanation: "通常はモジュール宣言の解決時点で循環依存として検出されます。"),
                choice("d", "`requires transitive` に変えれば循環依存は解消される", misconception: "transitiveが循環を許可すると誤解", explanation: "推移的かどうかに関係なく、循環した読み取り関係は問題です。"),
            ],
            intent: "Javaモジュールのrequires関係では循環依存を作れないことを確認する。",
            steps: [
                step("`a.core` は `requires b.core;` を宣言しています。", [2, 3, 4], [variable("a.core reads", "module", "b.core", "module graph")]),
                step("一方で `b.core` も `requires a.core;` を宣言しており、読み取り関係が元に戻ります。", [6, 7, 8], [variable("b.core reads", "module", "a.core", "module graph")]),
                step("この依存関係は循環しているため、モジュールグラフとして解決できずコンパイルエラーです。", [3, 8], [variable("result", "String", "cyclic dependence error", "compiler")]),
            ]
        ),
        q(
            "gold-nonlambda-module-service-provider-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "module-system",
            tags: ["ServiceLoader", "uses", "provides"],
            code: """
// api/module-info.java
module api {
    exports service;
}

// provider/module-info.java
module provider {
    requires api;
    provides service.Tool with impl.FastTool;
}

// client/module-info.java
module client {
    requires api;
    uses service.Tool;
}
""",
            question: "ServiceLoaderで `service.Tool` の実装を見つけるために必要な宣言として正しいものはどれか？",
            choices: [
                choice("a", "利用側モジュールは `uses service.Tool;` を宣言する", correct: true, explanation: "サービス利用側は `uses`、提供側は `provides ... with ...` を宣言します。"),
                choice("b", "利用側モジュールは必ず `requires provider;` を宣言する", misconception: "サービス実装モジュールへの直接依存が必須と誤解", explanation: "ServiceLoaderではAPIへの依存とuses宣言で、実装モジュールを直接参照しない設計にできます。"),
                choice("c", "提供側モジュールは実装パッケージ `impl` をexportsする必要がある", misconception: "サービス提供と通常公開を混同", explanation: "プロバイダクラスは `provides ... with ...` で指定され、利用側へ通常APIとしてexportする必要はありません。"),
                choice("d", "`provides` はapiモジュール側に書く", misconception: "サービス型の宣言元と提供元を混同", explanation: "実装を提供するモジュール側が `provides` を宣言します。"),
            ],
            intent: "ServiceLoader連携では利用側のusesと提供側のprovidesを分けて宣言することを確認する。",
            steps: [
                step("`api` モジュールはサービスインタフェースを含む `service` パッケージをexportsします。", [1, 2, 3], [variable("service API", "package", "service", "api")]),
                step("`provider` モジュールはAPIをrequiresし、`provides service.Tool with impl.FastTool;` で実装を登録します。", [6, 7, 8, 9], [variable("provider declaration", "String", "Tool -> FastTool", "provider")]),
                step("`client` モジュールはAPIをrequiresし、`uses service.Tool;` でServiceLoader利用を宣言します。", [12, 13, 14, 15], [variable("client declaration", "String", "uses service.Tool", "client")]),
            ]
        ),
        q(
            "gold-nonlambda-module-moduleinfo-package-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "module-system",
            tags: ["module-info.java", "package declaration"],
            code: """
package app;

module app.core {
    exports app;
}
""",
            question: "`module-info.java` の先頭に `package app;` を書いた場合の結果として正しいものはどれか？",
            choices: [
                choice("a", "module-info.javaも通常クラスと同じくpackage宣言が必要", misconception: "通常のJavaソースと同じ扱いだと誤解", explanation: "module-info.javaにはpackage宣言を書きません。"),
                choice("b", "module宣言の前にpackage宣言があるためコンパイルエラーになる", correct: true, explanation: "`module-info.java` はモジュール宣言を記述する特別なファイルで、package宣言を持ちません。"),
                choice("c", "`exports app;` があるため正常にコンパイルできる", misconception: "exportsの有無でpackage宣言が許可されると誤解", explanation: "exportsとは別に、module-info.javaの構文としてpackage宣言は不正です。"),
                choice("d", "実行時にだけモジュール名が `app.app.core` になる", misconception: "package宣言がモジュール名に付くと誤解", explanation: "モジュール名は `module app.core` で指定し、package宣言は使いません。"),
            ],
            intent: "module-info.javaは通常のpackage宣言を持たず、module宣言をトップレベルに書くことを確認する。",
            steps: [
                step("コードは `package app;` から始まっています。", [1], [variable("first declaration", "String", "package app", "module-info.java")]),
                step("`module-info.java` はモジュール宣言用の特別なソースで、通常クラスのようなpackage宣言を置きません。", [3], [variable("expected first declaration", "String", "module app.core", "compiler")]),
                step("そのため、このmodule-info.javaはコンパイルエラーです。", [1, 3], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "gold-nonlambda-module-open-module-exports-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "module-system",
            tags: ["open module", "opens", "exports"],
            code: """
open module model.core {
    opens model;
}
""",
            question: "`open module` の中で個別に `opens model;` を書いた場合の説明として正しいものはどれか？",
            choices: [
                choice("a", "`open module` では全パッケージが開かれるため、個別のopens宣言は不要でコンパイルエラーになる", correct: true, explanation: "open module内ではすべてのパッケージがリフレクション向けに開かれるため、個別のopens宣言は書けません。"),
                choice("b", "`opens model;` により通常のコンパイル時アクセスも公開される", misconception: "opensとexportsを混同", explanation: "opensはリフレクション向けで、通常アクセスにはexportsが必要です。"),
                choice("c", "`open module` なら `exports` 宣言もすべて不要になる", misconception: "深いリフレクションと通常API公開を混同", explanation: "open moduleでも、通常のコンパイル時アクセス公開にはexportsが関係します。"),
                choice("d", "`open module` はJava 17では廃止されている", misconception: "open moduleが使えないと誤解", explanation: "open moduleはJava 9以降のモジュール機能です。"),
            ],
            intent: "open moduleでは個別のopens宣言を書けず、exportsとは役割が違うことを確認する。",
            steps: [
                step("`open module model.core` は、モジュール内パッケージをリフレクション向けに開く宣言です。", [1], [variable("module kind", "String", "open", "module descriptor")]),
                step("open moduleの中では、個別に `opens model;` を書く必要がなく、構文上も許可されません。", [2], [variable("individual opens", "String", "not allowed", "compiler")]),
                step("したがって、このmodule-info.javaはコンパイルエラーです。", [1, 2], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),

        // MARK: - JDBC: Second Batch

        q(
            "gold-nonlambda-jdbc-execute-select-boolean-001",
            difficulty: .standard,
            estimatedSeconds: 90,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["Statement", "execute", "ResultSet"],
            code: """
Statement stmt = conn.createStatement();
boolean result = stmt.execute("select id from users");
System.out.println(result);
""",
            question: "SELECT文に対して `Statement.execute` を呼んだ場合、戻り値の意味として正しいものはどれか？",
            choices: [
                choice("a", "更新件数が1以上ならtrue", misconception: "executeUpdateの戻り値と混同", explanation: "`execute` のbooleanは更新件数ではなく、最初の結果がResultSetかどうかを示します。"),
                choice("b", "最初の結果がResultSetならtrue", correct: true, explanation: "SELECT文はResultSetを生成するため、`execute` の戻り値はtrueになります。"),
                choice("c", "SQLが成功すれば常にtrue", misconception: "成功フラグだと誤解", explanation: "UPDATE文など、成功しても最初の結果がResultSetでなければfalseです。"),
                choice("d", "結果行が1件以上ならtrue、0件ならfalse", misconception: "行数有無と混同", explanation: "ResultSetが空かどうかではなく、最初の結果の種類を示します。"),
            ],
            intent: "Statement.executeのboolean戻り値が成功可否や件数ではなく、最初の結果がResultSetかどうかを表すことを確認する。",
            steps: [
                step("SQLは `select id from users` で、問い合わせ結果としてResultSetを生成します。", [2], [variable("sql kind", "String", "SELECT", "JDBC")]),
                step("`Statement.execute` の戻り値は、最初の結果がResultSetならtrue、更新件数などならfalseです。", [2], [variable("first result", "String", "ResultSet", "Statement")]),
                step("したがって、この呼び出しの戻り値はtrueです。", [3], [variable("output", "boolean", "true", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-jdbc-getint-null-001",
            difficulty: .tricky,
            estimatedSeconds: 100,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["ResultSet", "getInt", "wasNull", "SQL NULL"],
            code: """
// 現在行: score = SQL NULL
int score = rs.getInt("score");
boolean missing = rs.wasNull();
System.out.println(score + ":" + missing);
""",
            question: "SQL NULLの数値列を `getInt` で読んだ直後の出力として正しいものはどれか？",
            choices: [
                choice("a", "0:true", correct: true, explanation: "`getInt` はSQL NULLに対して0を返し、直後の `wasNull()` がtrueになります。"),
                choice("b", "null:true", misconception: "プリミティブintにnullが入ると誤解", explanation: "戻り値型はintなのでnullにはなりません。"),
                choice("c", "0:false", misconception: "NULLと実際の0を区別できないと誤解", explanation: "直後に `wasNull()` を呼ぶことでSQL NULLだったかを確認できます。"),
                choice("d", "SQLException", misconception: "NULL数値を読むと例外になると誤解", explanation: "NULL自体では通常例外にならず、0とwasNullで判定します。"),
            ],
            intent: "ResultSet.getIntでSQL NULLを読むと0が返り、直後のwasNullでNULL判定することを確認する。",
            steps: [
                step("現在行の `score` 列はSQL NULLです。", [1], [variable("score column", "SQL value", "NULL", "ResultSet")]),
                step("`getInt(\"score\")` の戻り値型はプリミティブintなので、NULLは0として返ります。", [2], [variable("score", "int", "0", "main")]),
                step("直後の `wasNull()` はtrueを返すため、出力は `0:true` です。", [3, 4], [variable("missing", "boolean", "true", "main")]),
            ]
        ),
        q(
            "gold-nonlambda-jdbc-autocommit-default-001",
            difficulty: .standard,
            estimatedSeconds: 80,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["Connection", "autoCommit", "transaction"],
            code: """
Connection conn = dataSource.getConnection();
System.out.println(conn.getAutoCommit());
""",
            question: "JDBCのConnectionを取得した直後のauto-commitについて、一般的な既定値として正しいものはどれか？",
            choices: [
                choice("a", "true", correct: true, explanation: "JDBC Connectionは通常、作成直後はauto-commitが有効です。"),
                choice("b", "false", misconception: "明示commitが常に必要だと誤解", explanation: "明示的に `setAutoCommit(false)` しない限り、通常は各SQLが自動commitされます。"),
                choice("c", "データベース製品に関係なく必ずSQLException", misconception: "getAutoCommitを呼べないと誤解", explanation: "有効なConnectionであればauto-commit状態を取得できます。"),
                choice("d", "直前に実行したSQLの種類で変わる", misconception: "状態取得とSQL実行結果を混同", explanation: "auto-commitはConnectionの設定であり、SQLの種類で自動的に切り替わるものではありません。"),
            ],
            intent: "JDBC Connectionのauto-commitは通常デフォルトで有効であることを確認する。",
            steps: [
                step("`dataSource.getConnection()` でConnectionを取得しています。", [1], [variable("conn", "Connection", "new connection", "main")]),
                step("JDBCでは、Connection作成直後のauto-commitは通常trueです。", [2], [variable("autoCommit", "boolean", "true", "Connection")]),
                step("したがって `getAutoCommit()` の出力はtrueです。明示トランザクションにしたい場合はfalseへ変更します。", [2], [variable("output", "boolean", "true", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-jdbc-close-resultset-001",
            difficulty: .standard,
            estimatedSeconds: 95,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["Statement", "ResultSet", "close"],
            code: """
Statement stmt = conn.createStatement();
ResultSet rs = stmt.executeQuery("select id from users");
stmt.close();
rs.next();
""",
            question: "`Statement` をcloseした後、そのStatementから作られた `ResultSet` を使う場合の説明として正しいものはどれか？",
            choices: [
                choice("a", "`ResultSet` はStatementとは独立しているため必ず使い続けられる", misconception: "ResultSetの所有関係を見落としている", explanation: "Statementを閉じると、それにより生成されたResultSetも閉じられます。"),
                choice("b", "`Statement.close()` により関連する `ResultSet` も閉じられる", correct: true, explanation: "Statementを閉じると、そのStatementの現在のResultSetも閉じられるため、以後の利用はできません。"),
                choice("c", "`rs.next()` はfalseを返すだけで例外にはならない", misconception: "閉じたResultSetを空のResultSetと混同", explanation: "閉じられたResultSetへの操作は通常SQLExceptionになります。"),
                choice("d", "`ResultSet` を閉じるとStatementも必ず閉じる", misconception: "逆方向のclose関係と混同", explanation: "この問題で重要なのはStatementを閉じると生成元のResultSetも閉じられる点です。"),
            ],
            intent: "Statementを閉じると、そのStatementから生成されたResultSetも閉じられることを確認する。",
            steps: [
                step("`stmt.executeQuery` により、Statementに紐づいたResultSetが作られます。", [1, 2], [variable("rs owner", "Statement", "stmt", "JDBC")]),
                step("`stmt.close()` を呼ぶと、そのStatementが管理するResultSetも閉じられます。", [3], [variable("rs state", "String", "closed", "JDBC")]),
                step("閉じたResultSetに対して `rs.next()` を呼ぶと、通常は `SQLException` になります。", [4], [variable("result", "Exception", "SQLException", "JDBC")]),
            ]
        ),

        // MARK: - Date Time: Second Batch

        q(
            "gold-nonlambda-datetime-localtime-wrap-001",
            category: "date-time",
            tags: ["LocalTime", "plusHours", "wrap around"],
            code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        LocalTime time = LocalTime.of(23, 30);
        System.out.println(time.plusHours(2));
    }
}
""",
            question: "`LocalTime.of(23, 30).plusHours(2)` の出力として正しいものはどれか？",
            choices: [
                choice("a", "25:30", misconception: "24時を超える時刻がそのまま表現されると誤解", explanation: "LocalTimeは1日の時刻なので、24時間単位で循環します。"),
                choice("b", "01:30", correct: true, explanation: "23:30に2時間足すと翌日の01:30ですが、LocalTimeは日付を持たないため `01:30` だけが残ります。"),
                choice("c", "23:32", misconception: "plusHoursを分加算と誤解", explanation: "`plusHours(2)` は2時間を加算します。"),
                choice("d", "DateTimeException", misconception: "日をまたぐ加算が無効だと誤解", explanation: "LocalTimeの加算は24時間で循環するため例外にはなりません。"),
            ],
            intent: "LocalTimeは日付を持たず、24時間を超える加算では時刻が循環することを確認する。",
            steps: [
                step("基準時刻は23時30分です。", [5], [variable("time", "LocalTime", "23:30", "main")]),
                step("2時間足すと暦上は翌日の1時30分ですが、LocalTimeは日付を保持しません。", [6], [variable("after plusHours", "LocalTime", "01:30", "date-time")]),
                step("そのため出力は `01:30` です。", [6], [variable("output", "String", "01:30", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-datetime-period-normalized-001",
            difficulty: .tricky,
            category: "date-time",
            tags: ["Period", "normalized", "months"],
            code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        Period p = Period.ofMonths(15);
        Period n = p.normalized();
        System.out.println(p.getYears() + ":" + p.getMonths()
            + "/" + n.getYears() + ":" + n.getMonths());
    }
}
""",
            question: "`Period.ofMonths(15).normalized()` を使った出力として正しいものはどれか？",
            choices: [
                choice("a", "1:3/1:3", misconception: "Period作成時に自動正規化されると誤解", explanation: "`Period.ofMonths(15)` 自体は年0、月15を保持します。"),
                choice("b", "0:15/1:3", correct: true, explanation: "元のPeriodは15か月のままです。`normalized()` により1年3か月へ正規化されます。"),
                choice("c", "0:15/0:15", misconception: "normalizedが何もしないと誤解", explanation: "月が12以上の場合は年と月へ正規化されます。"),
                choice("d", "1:15/1:3", misconception: "getYearsが月数から自動計算されると誤解", explanation: "元Periodのyears要素は0です。"),
            ],
            intent: "Periodは作成時には15か月を自動で1年3か月にせず、normalizedで年/月へ変換できることを確認する。",
            steps: [
                step("`Period.ofMonths(15)` は年0、月15のPeriodを作ります。", [5], [variable("p", "Period", "P15M", "main")]),
                step("`normalized()` により、15か月は1年3か月に変換されます。", [6], [variable("n", "Period", "P1Y3M", "main")]),
                step("元は `0:15`、正規化後は `1:3` なので、出力は `0:15/1:3` です。", [7, 8], [variable("output", "String", "0:15/1:3", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-datetime-yearmonth-length-001",
            category: "date-time",
            tags: ["YearMonth", "lengthOfMonth", "leap year"],
            code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        YearMonth ym = YearMonth.of(2024, 2);
        System.out.println(ym.lengthOfMonth());
    }
}
""",
            question: "この `YearMonth` コードを実行したときの出力はどれか？",
            choices: [
                choice("a", "28", misconception: "うるう年を考慮していない", explanation: "2024年はうるう年なので2月は29日あります。"),
                choice("b", "29", correct: true, explanation: "`YearMonth.of(2024, 2).lengthOfMonth()` は2024年2月の日数29を返します。"),
                choice("c", "30", misconception: "月の日数を固定パターンで誤っている", explanation: "2月の日数は年によって28または29です。"),
                choice("d", "DateTimeException", misconception: "YearMonthでは2月を扱えないと誤解", explanation: "YearMonthは年と月だけを表すため、日付の存在確認なしに2月を表せます。"),
            ],
            intent: "YearMonth.lengthOfMonthがうるう年を考慮した月の日数を返すことを確認する。",
            steps: [
                step("`YearMonth` は2024年2月を表しています。", [5], [variable("ym", "YearMonth", "2024-02", "main")]),
                step("2024年はうるう年なので、2月は29日あります。", [6], [variable("length", "int", "29", "date-time")]),
                step("したがって出力は `29` です。", [6], [variable("output", "int", "29", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-datetime-month-plus-wrap-001",
            difficulty: .standard,
            category: "date-time",
            tags: ["Month", "plus", "enum"],
            code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        Month m = Month.APRIL;
        System.out.println(m.plus(10));
    }
}
""",
            question: "`Month.APRIL.plus(10)` の出力として正しいものはどれか？",
            choices: [
                choice("a", "FEBRUARY", correct: true, explanation: "APRILから10か月進むと、12か月で循環してFEBRUARYになります。"),
                choice("b", "JANUARY", misconception: "4月を0始まりで数えている", explanation: "APRILを起点として10か月分進めます。"),
                choice("c", "DECEMBER", misconception: "年末で止まると誤解", explanation: "Monthのplusは12か月で循環します。"),
                choice("d", "DateTimeException", misconception: "12を超える月加算が無効だと誤解", explanation: "Month enumのplusは循環するため例外になりません。"),
            ],
            intent: "Month.plusは12か月で循環するenum操作であることを確認する。",
            steps: [
                step("開始月はAPRILです。", [5], [variable("m", "Month", "APRIL", "main")]),
                step("10か月進めると、MAYを1として数え、12か月周期でFEBRUARYに到達します。", [6], [variable("m.plus(10)", "Month", "FEBRUARY", "date-time")]),
                step("したがって出力は `FEBRUARY` です。", [6], [variable("output", "String", "FEBRUARY", "stdout")]),
            ]
        ),

        // MARK: - I/O: Second Batch

        q(
            "gold-nonlambda-io-bufferedreader-readline-001",
            category: "io",
            tags: ["BufferedReader", "readLine", "StringReader"],
            code: """
import java.io.*;

public class Test {
    public static void main(String[] args) throws Exception {
        BufferedReader br = new BufferedReader(new StringReader("A\\nB"));
        System.out.println(br.readLine() + ":" + br.readLine());
    }
}
""",
            question: "`BufferedReader.readLine()` の出力として正しいものはどれか？",
            choices: [
                choice("a", "A:B", correct: true, explanation: "`readLine()` は行末記号を含めずに1行ずつ返します。"),
                choice("b", "A\\n:B", misconception: "改行文字が戻り値に含まれると誤解", explanation: "`readLine()` の戻り値には行末記号は含まれません。"),
                choice("c", "A\\nB:null", misconception: "1回ですべて読むと誤解", explanation: "`readLine()` は1行ずつ読みます。"),
                choice("d", "AB:null", misconception: "改行で分割されないと誤解", explanation: "改行は行区切りとして扱われます。"),
            ],
            intent: "BufferedReader.readLineが行末文字を含めずに1行ずつ読み取ることを確認する。",
            steps: [
                step("入力文字列は `A\\nB` で、A行とB行の2行です。", [5], [variable("input", "String", "A\\nB", "StringReader")]),
                step("1回目の `readLine()` は行末文字を除いた `A`、2回目は `B` を返します。", [6], [variable("first", "String", "A", "BufferedReader"), variable("second", "String", "B", "BufferedReader")]),
                step("連結して出力するため、結果は `A:B` です。", [6], [variable("output", "String", "A:B", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-io-bytearrayinputstream-read-001",
            difficulty: .standard,
            category: "io",
            tags: ["ByteArrayInputStream", "read", "byte array"],
            code: """
import java.io.*;
import java.util.*;

public class Test {
    public static void main(String[] args) throws Exception {
        byte[] buffer = new byte[4];
        InputStream in = new ByteArrayInputStream(new byte[] {1, 2});
        int count = in.read(buffer);
        System.out.println(count + ":" + Arrays.toString(buffer));
    }
}
""",
            question: "`ByteArrayInputStream` から4バイト配列へreadした結果はどれか？",
            choices: [
                choice("a", "4:[1, 2, 0, 0]", misconception: "バッファ長が戻り値になると誤解", explanation: "戻り値は実際に読み込んだバイト数です。"),
                choice("b", "2:[1, 2, 0, 0]", correct: true, explanation: "入力は2バイトだけなので、readは2を返し、残りのバッファ要素は初期値0のままです。"),
                choice("c", "-1:[0, 0, 0, 0]", misconception: "最初からEOFだと誤解", explanation: "2バイト読み込めるため、最初のreadは-1ではありません。"),
                choice("d", "2:[0, 0, 1, 2]", misconception: "末尾に詰めると誤解", explanation: "readは配列の先頭から読み込んだバイトを書きます。"),
            ],
            intent: "InputStream.read(byte[])の戻り値は実際に読み込んだバイト数で、未使用部分はそのまま残ることを確認する。",
            steps: [
                step("バッファは4要素で、初期値はすべて0です。入力側には1, 2の2バイトがあります。", [6, 7], [variable("buffer", "byte[]", "[0, 0, 0, 0]", "main"), variable("input", "byte[]", "[1, 2]", "stream")]),
                step("`read(buffer)` は読み込める2バイトを配列先頭へ格納し、戻り値として2を返します。", [8], [variable("count", "int", "2", "main")]),
                step("残り2要素は0のままなので、出力は `2:[1, 2, 0, 0]` です。", [9], [variable("output", "String", "2:[1, 2, 0, 0]", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-io-serialization-notserializable-001",
            difficulty: .tricky,
            category: "io",
            tags: ["serialization", "Serializable", "NotSerializableException"],
            code: """
import java.io.*;

class User {
    String name = "Ada";
}

public class Test {
    public static void main(String[] args) throws Exception {
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        ObjectOutputStream out = new ObjectOutputStream(bytes);
        out.writeObject(new User());
    }
}
""",
            question: "このシリアライズコードを実行したときの結果として正しいものはどれか？",
            choices: [
                choice("a", "正常にシリアライズされる", misconception: "すべてのオブジェクトがObjectOutputStreamで保存できると誤解", explanation: "シリアライズ対象のクラスはSerializableを実装する必要があります。"),
                choice("b", "`NotSerializableException` が発生する", correct: true, explanation: "`User` は `Serializable` を実装していないため、`writeObject` で `NotSerializableException` が発生します。"),
                choice("c", "コンパイルエラーになる", misconception: "Serializable未実装をコンパイル時に検出すると誤解", explanation: "`writeObject` の引数型はObjectなのでコンパイルはできます。"),
                choice("d", "`name` フィールドだけが無視される", misconception: "非Serializableをtransientと混同", explanation: "クラス自体がSerializableでないため、フィールド無視ではなく例外になります。"),
            ],
            intent: "ObjectOutputStreamでオブジェクトを書き出すには対象クラスがSerializableを実装している必要があることを確認する。",
            steps: [
                step("`User` クラスは `Serializable` を実装していません。", [3, 4, 5], [variable("User implements Serializable", "boolean", "false", "class")]),
                step("`ObjectOutputStream.writeObject` はObject型を受け取るため、呼び出し自体はコンパイルできます。", [10, 11], [variable("argument static type", "Class", "Object", "writeObject")]),
                step("実行時にUserがシリアライズ不可と判定され、`NotSerializableException` が発生します。", [11], [variable("result", "Exception", "NotSerializableException", "serialization")]),
            ]
        ),
        q(
            "gold-nonlambda-io-printwriter-exception-001",
            difficulty: .tricky,
            category: "io",
            tags: ["PrintWriter", "IOException", "checkError"],
            code: """
import java.io.*;

public class Test {
    public static void main(String[] args) {
        PrintWriter writer = new PrintWriter(System.out);
        writer.println("ok");
    }
}
""",
            question: "`PrintWriter.println` の例外処理について正しい説明はどれか？",
            choices: [
                choice("a", "`println` はチェック例外IOExceptionを必ずthrowsする", misconception: "Writer系全般と混同", explanation: "PrintWriterのprint/println系メソッドはIOExceptionをチェック例外として投げません。"),
                choice("b", "I/Oエラーは内部で記録され、必要なら `checkError()` で確認する", correct: true, explanation: "PrintWriterはI/Oエラーをチェック例外として直接投げず、エラー状態を保持します。"),
                choice("c", "`main` にthrows IOExceptionがないためコンパイルエラー", misconception: "PrintWriter.printlnがチェック例外を投げると誤解", explanation: "このコードにIOExceptionのcatchやthrowsは不要です。"),
                choice("d", "PrintWriterは文字列を出力できない", misconception: "PrintStreamと混同", explanation: "PrintWriterは文字出力用のクラスで、文字列を出力できます。"),
            ],
            intent: "PrintWriterはprint/println時のI/Oエラーをチェック例外として投げず、checkErrorで確認する設計であることを確認する。",
            steps: [
                step("`PrintWriter` を作成し、`println(\"ok\")` を呼び出しています。", [5, 6], [variable("writer", "PrintWriter", "System.out", "main")]),
                step("PrintWriterのprint/println系メソッドは、IOExceptionをチェック例外として呼び出し元へ投げません。", [6], [variable("throws IOException", "boolean", "false", "println")]),
                step("I/Oエラーを確認したい場合は、内部のエラー状態を `checkError()` で見る設計です。", [6], [variable("error check", "String", "checkError()", "PrintWriter")]),
            ]
        ),

        // MARK: - Inheritance: Second Batch

        q(
            "gold-nonlambda-inheritance-default-conflict-001",
            difficulty: .tricky,
            category: "inheritance",
            tags: ["interface", "default method", "conflict"],
            code: """
interface A {
    default String name() { return "A"; }
}

interface B {
    default String name() { return "B"; }
}

class C implements A, B { }

public class Test {
    public static void main(String[] args) {
        System.out.println(new C().name());
    }
}
""",
            question: "2つのインタフェースが同じdefaultメソッドを持つ場合、このコードはどうなるか？",
            choices: [
                choice("a", "Aが出力される", misconception: "先に書いたimplementsが優先されると誤解", explanation: "同じシグネチャのdefaultメソッドが競合するため、自動では選ばれません。"),
                choice("b", "Bが出力される", misconception: "後に書いたimplementsが優先されると誤解", explanation: "実装クラスで競合を解決する必要があります。"),
                choice("c", "コンパイルエラーになる", correct: true, explanation: "`C` は `name()` をオーバーライドして、どちらを使うか、または独自実装するかを明示する必要があります。"),
                choice("d", "実行時にAbstractMethodErrorになる", misconception: "default競合を実行時問題と誤解", explanation: "競合はコンパイル時に検出されます。"),
            ],
            intent: "複数インタフェース由来の同じdefaultメソッド競合は実装クラスで明示解決が必要なことを確認する。",
            steps: [
                step("インタフェースAとBは、どちらも `default String name()` を持っています。", [1, 2, 5, 6], [variable("A.name", "default method", "A", "interface"), variable("B.name", "default method", "B", "interface")]),
                step("`class C implements A, B` は `name()` をオーバーライドしていないため、どちらのdefaultを使うか決まりません。", [9], [variable("conflict resolved", "boolean", "false", "C")]),
                step("そのため、Cの宣言はコンパイルエラーになります。", [9], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "gold-nonlambda-inheritance-class-wins-default-001",
            category: "inheritance",
            tags: ["interface", "default method", "class wins"],
            code: """
interface Named {
    default String name() { return "interface"; }
}

class Base {
    public String name() { return "class"; }
}

class Child extends Base implements Named { }

public class Test {
    public static void main(String[] args) {
        System.out.println(new Child().name());
    }
}
""",
            question: "クラス継承のメソッドとインタフェースdefaultメソッドが同じ場合の出力はどれか？",
            choices: [
                choice("a", "class", correct: true, explanation: "クラス階層の具象メソッドがインタフェースdefaultメソッドより優先されます。"),
                choice("b", "interface", misconception: "defaultメソッドがクラスメソッドを上書きすると誤解", explanation: "クラスの具象メソッドが勝ちます。"),
                choice("c", "コンパイルエラー", misconception: "クラスとdefaultの同名メソッドが常に競合すると誤解", explanation: "クラス側の具象メソッドがあるため、競合は解決されます。"),
                choice("d", "実行時にIncompatibleClassChangeError", misconception: "defaultメソッド解決を実行時エラーと誤解", explanation: "この解決規則により正常に実行できます。"),
            ],
            intent: "インタフェースdefaultメソッドよりクラス階層の具象メソッドが優先されることを確認する。",
            steps: [
                step("`Named` はdefaultメソッド `name()` を提供しています。", [1, 2], [variable("Named.name", "default method", "interface", "Named")]),
                step("一方、`Base` には具象メソッド `name()` があり、`Child` はBaseを継承しています。", [5, 6, 9], [variable("Base.name", "instance method", "class", "Base")]),
                step("クラス階層の具象メソッドが優先されるため、出力は `class` です。", [13], [variable("output", "String", "class", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-inheritance-override-throws-001",
            difficulty: .standard,
            category: "inheritance",
            tags: ["override", "checked exception", "throws"],
            code: """
import java.io.*;

class Parent {
    void read() throws IOException { }
}

class Child extends Parent {
    @Override
    void read() throws Exception { }
}
""",
            question: "このオーバーライド宣言について正しい説明はどれか？",
            choices: [
                choice("a", "`Exception` は `IOException` のスーパータイプなのでコンパイルエラーになる", correct: true, explanation: "オーバーライドメソッドは、より広いチェック例外を新たにthrowsできません。"),
                choice("b", "例外型は自由に広げられるため正常にコンパイルできる", misconception: "throws句のオーバーライド制約を見落としている", explanation: "チェック例外は元メソッドのthrows範囲内に収める必要があります。"),
                choice("c", "`@Override` を消せば正常にコンパイルできる", misconception: "アノテーションだけが原因と誤解", explanation: "シグネチャ上はオーバーライドであり、throws制約違反は残ります。"),
                choice("d", "実行時にIOExceptionだけcatchすれば問題ない", misconception: "コンパイル時のthrows制約を実行時処理で解決できると誤解", explanation: "この宣言自体がコンパイルできません。"),
            ],
            intent: "オーバーライド時にチェック例外のthrows範囲を広げることはできないことを確認する。",
            steps: [
                step("親クラスの `read()` は `IOException` をthrowsします。", [3, 4], [variable("parent throws", "Exception type", "IOException", "Parent.read")]),
                step("子クラスの `read()` はより広い `Exception` をthrowsしようとしています。", [7, 8, 9], [variable("child throws", "Exception type", "Exception", "Child.read")]),
                step("オーバーライドではチェック例外を広げられないため、コンパイルエラーです。", [9], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "gold-nonlambda-inheritance-private-not-override-001",
            difficulty: .tricky,
            category: "inheritance",
            tags: ["private method", "override", "dispatch"],
            code: """
class Parent {
    private String value() { return "parent"; }
    String call() { return value(); }
}

class Child extends Parent {
    String value() { return "child"; }
}

public class Test {
    public static void main(String[] args) {
        System.out.println(new Child().call());
    }
}
""",
            question: "このprivateメソッドと同名メソッドを持つコードの出力はどれか？",
            choices: [
                choice("a", "parent", correct: true, explanation: "privateメソッドは継承されずオーバーライドされません。`Parent.call()` 内の `value()` はParentのprivateメソッドです。"),
                choice("b", "child", misconception: "privateメソッドも動的ディスパッチで上書きされると誤解", explanation: "Childの `value()` はParentのprivate `value()` をオーバーライドしていません。"),
                choice("c", "コンパイルエラー", misconception: "Childで同名メソッドを宣言できないと誤解", explanation: "親のprivateメソッドは子から見えないため、同名メソッドを宣言できます。"),
                choice("d", "IllegalAccessError", misconception: "Parent.callからParent privateを呼べないと誤解", explanation: "同じParentクラス内からprivateメソッドを呼ぶのは有効です。"),
            ],
            intent: "privateメソッドは継承・オーバーライドされず、親クラス内の呼び出しは親のprivate実装に束縛されることを確認する。",
            steps: [
                step("`Parent.value()` はprivateなので、Childへ継承されず、オーバーライド対象にもなりません。", [1, 2, 6, 7], [variable("Parent.value visibility", "String", "private", "Parent")]),
                step("`new Child().call()` では、継承した `Parent.call()` が実行されます。", [3, 12], [variable("called method", "String", "Parent.call", "runtime")]),
                step("`Parent.call()` 内の `value()` はParentのprivateメソッドに束縛されているため、出力は `parent` です。", [2, 3, 12], [variable("output", "String", "parent", "stdout")]),
            ]
        ),

        // MARK: - Annotations: Second Batch

        q(
            "gold-nonlambda-annotations-retention-default-001",
            difficulty: .standard,
            category: "annotations",
            tags: ["Retention", "reflection", "CLASS"],
            code: """
import java.lang.annotation.*;

@interface Marker { }

@Marker
class Sample { }

public class Test {
    public static void main(String[] args) {
        System.out.println(Sample.class.isAnnotationPresent(Marker.class));
    }
}
""",
            question: "`@Retention` を指定していないアノテーションを実行時リフレクションで調べた結果はどれか？",
            choices: [
                choice("a", "true（実行時にもMarkerが保持される）", misconception: "すべてのアノテーションが実行時に残ると誤解", explanation: "Retentionを指定しない場合の既定はCLASSで、実行時リフレクションでは見えません。"),
                choice("b", "false（RUNTIME保持ではないため検出されない）", correct: true, explanation: "`@Retention(RetentionPolicy.RUNTIME)` がないため、`isAnnotationPresent` では検出されません。"),
                choice("c", "Retention指定がないためコンパイルエラー", misconception: "Retention指定が必須と誤解", explanation: "Retentionを省略することは可能です。既定がCLASSになります。"),
                choice("d", "isAnnotationPresentがNullPointerExceptionを投げる", misconception: "存在しないアノテーション検査がnull例外になると誤解", explanation: "存在しない場合はfalseが返ります。"),
            ],
            intent: "アノテーションのRetention既定値はCLASSであり、RUNTIME指定なしでは実行時リフレクションで見えないことを確認する。",
            steps: [
                step("`Marker` には `@Retention` が指定されていません。", [3], [variable("retention", "RetentionPolicy", "CLASS default", "Marker")]),
                step("`Sample` には `@Marker` が付いていますが、RUNTIME保持ではありません。", [5, 6], [variable("runtime visible", "boolean", "false", "Marker")]),
                step("そのため `isAnnotationPresent(Marker.class)` はfalseを返します。", [10], [variable("output", "boolean", "false", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-annotations-inherited-interface-001",
            difficulty: .tricky,
            category: "annotations",
            tags: ["@Inherited", "interface", "reflection"],
            code: """
import java.lang.annotation.*;

@Inherited
@Retention(RetentionPolicy.RUNTIME)
@interface Role { }

@Role
interface Service { }

class Impl implements Service { }

public class Test {
    public static void main(String[] args) {
        System.out.println(Impl.class.isAnnotationPresent(Role.class));
    }
}
""",
            question: "`@Inherited` を付けたアノテーションがインタフェースに付いている場合、実装クラスで検出されるか？",
            choices: [
                choice("a", "true", misconception: "@Inheritedがインタフェースにも効くと誤解", explanation: "@Inheritedはクラスの継承に対して働き、インタフェース実装には適用されません。"),
                choice("b", "false", correct: true, explanation: "`Impl` は `Service` を実装していますが、@Inheritedはインタフェースから実装クラスへは継承されません。"),
                choice("c", "コンパイルエラー", misconception: "@Inheritedをインタフェース用アノテーションに付けられないと誤解", explanation: "宣言自体は可能ですが、効果はクラス継承に限られます。"),
                choice("d", "Role.classが取得できずClassNotFoundException", misconception: "リフレクションAPIの動作を誤解", explanation: "Role型自体は存在しており、検査結果がfalseになるだけです。"),
            ],
            intent: "@Inheritedはクラス継承に対して働き、インタフェース実装からはアノテーションを継承しないことを確認する。",
            steps: [
                step("`Role` は `@Inherited` かつRUNTIME保持のアノテーションです。", [3, 4, 5], [variable("Role inherited", "boolean", "true", "annotation")]),
                step("ただし `@Role` が付いているのはクラスではなくインタフェース `Service` です。", [7, 8], [variable("annotated element", "String", "interface Service", "source")]),
                step("`Impl` はServiceを実装しているだけなので、@Inheritedの効果は及ばず、出力はfalseです。", [10, 14], [variable("output", "boolean", "false", "stdout")]),
            ]
        ),
        q(
            "gold-nonlambda-annotations-invalid-element-type-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "annotations",
            tags: ["annotation element", "List", "allowed types"],
            code: """
import java.util.*;

@interface Config {
    List<String> names();
}
""",
            question: "このアノテーション型の要素宣言について正しい説明はどれか？",
            choices: [
                choice("a", "`List<String>` はアノテーション要素型として使える", misconception: "任意の戻り値型を使えると誤解", explanation: "アノテーション要素に使える型は限定されています。Listは使えません。"),
                choice("b", "`names()` の戻り値型が不正なためコンパイルエラーになる", correct: true, explanation: "アノテーション要素型はプリミティブ、String、Class、enum、アノテーション、それらの配列などに限られます。"),
                choice("c", "`List<String>` は空リストをdefaultにすれば使える", misconception: "default値で型制約を回避できると誤解", explanation: "要素型自体が許可されていないため、default値の有無では解決しません。"),
                choice("d", "`String[]` より `List<String>` が推奨される", misconception: "通常API設計とアノテーション制約を混同", explanation: "アノテーションでは配列は使えますが、Listは使えません。"),
            ],
            intent: "アノテーション要素として使える型は限定され、Listなど任意の型は使えないことを確認する。",
            steps: [
                step("`Config` はアノテーション型として宣言されています。", [3], [variable("annotation", "String", "Config", "source")]),
                step("要素 `names()` の戻り値型は `List<String>` です。これはアノテーション要素に許可された型ではありません。", [4], [variable("element type", "String", "List<String>", "compiler")]),
                step("そのため、このアノテーション型宣言はコンパイルエラーです。", [4], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "gold-nonlambda-annotations-repeatable-container-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "annotations",
            tags: ["@Repeatable", "container annotation"],
            code: """
import java.lang.annotation.*;

@Repeatable(Tags.class)
@interface Tag {
    String value();
}

@interface Tags {
    Tag value();
}
""",
            question: "`@Repeatable(Tags.class)` のコンテナアノテーション宣言として正しい説明はどれか？",
            choices: [
                choice("a", "`Tags.value()` は `Tag` 1個を返せばよい", misconception: "コンテナのvalue型を単数と誤解", explanation: "繰り返しアノテーションのコンテナは、対象アノテーション型の配列をvalue要素として持つ必要があります。"),
                choice("b", "`Tags.value()` が `Tag[]` ではないためコンパイルエラーになる", correct: true, explanation: "コンテナアノテーションの `value` 要素は `Tag[]` 型でなければなりません。"),
                choice("c", "`@Repeatable` はRetentionPolicy.RUNTIMEがないと常にコンパイルエラー", misconception: "RetentionとRepeatableの必須条件を混同", explanation: "Retentionの整合性は重要ですが、このコードの直接の問題はコンテナvalue型です。"),
                choice("d", "コンテナ名は必ず `TagContainer` でなければならない", misconception: "コンテナ型名に固定ルールがあると誤解", explanation: "コンテナ型名は任意ですが、構造要件を満たす必要があります。"),
            ],
            intent: "Repeatableアノテーションのコンテナは対象アノテーション型の配列を返すvalue要素を持つ必要があることを確認する。",
            steps: [
                step("`Tag` は `@Repeatable(Tags.class)` として、コンテナ型に `Tags` を指定しています。", [3, 4, 5, 6], [variable("repeatable annotation", "String", "Tag", "source")]),
                step("コンテナ `Tags` の `value()` は `Tag` 単体を返しています。", [8, 9, 10], [variable("container value type", "String", "Tag", "Tags")]),
                step("Repeatableのコンテナには `Tag[] value()` が必要なため、この宣言はコンパイルエラーです。", [9], [variable("expected value type", "String", "Tag[]", "compiler")]),
            ]
        ),
    ]

    static func q(
        _ id: String,
        difficulty: QuizDifficulty = .standard,
        estimatedSeconds: Int = 90,
        validatedByJavac: Bool = true,
        category: String,
        tags: [String],
        code: String,
        codeTabs: [Quiz.CodeFile]? = nil,
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
            codeTabs: codeTabs,
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

    static func file(_ filename: String, _ code: String) -> Quiz.CodeFile {
        Quiz.CodeFile(filename: filename, code: code)
    }
}

extension GoldNonLambdaQuestionData.Spec {
    var quiz: Quiz {
        Quiz(
            id: id,
            level: .gold,
            difficulty: difficulty,
            estimatedSeconds: estimatedSeconds,
            validatedByJavac: validatedByJavac,
            category: category,
            tags: tags,
            code: code,
            codeTabs: codeTabs,
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
    static let goldNonLambdaExpansion: [Quiz] = GoldNonLambdaQuestionData.specs.map(\.quiz)
}
