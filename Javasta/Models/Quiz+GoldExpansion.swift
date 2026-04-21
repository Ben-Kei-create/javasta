import Foundation

enum QuizExpansion {
    typealias Choice = Quiz.Choice

    static let goldExpansion: [Quiz] = [
        goldCollections002,
        goldGenerics004,
        goldStream006,
        goldStream007,
        goldOptional004,
        goldConcurrency005,
        goldConcurrency006,
        goldIo003,
        goldModule003,
        goldLocalization003,
        goldJdbc003,
        goldClasses003,
    ]

    // MARK: - Gold: Collections (List.copyOf)

    static let goldCollections002 = Quiz(
        id: "gold-collections-002",
        level: .gold,
        category: "collections",
        tags: ["List.copyOf", "不変コレクション", "null"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> source = new ArrayList<>();
        source.add("A");
        source.add(null);
        try {
            List<String> copy = List.copyOf(source);
            System.out.println(copy.size());
        } catch (NullPointerException e) {
            System.out.println("NPE");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2",
                   correct: false, misconception: "copyOfがnull要素をそのままコピーすると誤解",
                   explanation: "List.copyOfはnull要素を許容しません。コピー作成時にNullPointerExceptionが発生します。"),
            Choice(id: "b", text: "1",
                   correct: false, misconception: "null要素が自動的に除外されると誤解",
                   explanation: "nullを除外する仕様はありません。null要素を含むコレクションからcopyOfすると例外です。"),
            Choice(id: "c", text: "NPE",
                   correct: true, misconception: nil,
                   explanation: "List.copyOfは不変リストを作るファクトリで、入力コレクションにnull要素があるとNullPointerExceptionをスローします。"),
            Choice(id: "d", text: "UnsupportedOperationException",
                   correct: false, misconception: "不変リストの変更時例外と混同",
                   explanation: "UnsupportedOperationExceptionは作成後の変更操作で起こる例外です。このコードでは作成時にNPEが発生します。"),
        ],
        explanationRef: "explain-gold-collections-002",
        designIntent: "copyOf系ファクトリがnullを許容せず、作成後だけでなく作成時にも例外が起こる点を確認する。"
    )

    // MARK: - Gold: Generics (Generic Method Inference)

    static let goldGenerics004 = Quiz(
        id: "gold-generics-004",
        level: .gold,
        category: "generics",
        tags: ["ジェネリックメソッド", "型推論", "var"],
        code: """
public class Test {
    static <T> T pick(T a, T b) {
        return a;
    }

    public static void main(String[] args) {
        var value = pick(10, 20.0);
        System.out.println(value.getClass().getSimpleName());
    }
}
""",
        question: "このコードを実行したとき、出力される可能性が最も高いものはどれか？",
        choices: [
            Choice(id: "a", text: "Integer",
                   correct: true, misconception: nil,
                   explanation: "TはIntegerとDoubleの共通上位型として推論されますが、戻り値として返される実体は第1引数のIntegerです。varの静的型と実体の型を分けて考えます。"),
            Choice(id: "b", text: "Double",
                   correct: false, misconception: "数値型がdoubleへ統一されると誤解",
                   explanation: "ジェネリックメソッドのTはプリミティブの数値昇格ではなく、ボクシング後の参照型の共通上位型として扱われます。"),
            Choice(id: "c", text: "Number",
                   correct: false, misconception: "静的型がそのままgetClassに出ると誤解",
                   explanation: "getClass()は実行時の実体クラスを返します。変数の静的型がNumber相当でも、実体はIntegerです。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "異なる型の引数を同じTに渡せないと誤解",
                   explanation: "コンパイラは両者の共通上位型を使ってTを推論できます。"),
        ],
        explanationRef: "explain-gold-generics-004",
        designIntent: "ジェネリックメソッドの型推論と、静的型・実行時型の違いを同時に見抜かせる。"
    )

    // MARK: - Gold: Stream API (toMap Duplicate Key)

    static let goldStream006 = Quiz(
        id: "gold-stream-006",
        level: .gold,
        category: "lambda-streams",
        tags: ["Collectors.toMap", "重複キー", "IllegalStateException"],
        code: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        try {
            Map<Integer, String> map = Stream.of("A", "B")
                .collect(Collectors.toMap(String::length, s -> s));
            System.out.println(map);
        } catch (IllegalStateException e) {
            System.out.println("ISE");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "{1=A, 1=B}",
                   correct: false, misconception: "Mapが同じキーを複数保持できると誤解",
                   explanation: "Mapは同じキーを複数保持できません。toMapでは重複キーの扱いを指定しないと例外です。"),
            Choice(id: "b", text: "{1=B}",
                   correct: false, misconception: "後勝ちで上書きされると誤解",
                   explanation: "Collectors.toMapの2引数版は重複キーを自動上書きしません。マージ関数を明示する必要があります。"),
            Choice(id: "c", text: "ISE",
                   correct: true, misconception: nil,
                   explanation: "\"A\"と\"B\"はどちらも長さ1なのでキーが重複します。2引数版toMapではIllegalStateExceptionが発生します。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "toMapの型推論が失敗すると誤解",
                   explanation: "型推論は成立します。問題は実行時の重複キーです。"),
        ],
        explanationRef: "explain-gold-stream-006",
        designIntent: "Collectors.toMapで重複キーが発生した場合、マージ関数なしではIllegalStateExceptionになる点を確認する。"
    )

    // MARK: - Gold: Stream API (Parallel forEachOrdered)

    static let goldStream007 = Quiz(
        id: "gold-stream-007",
        level: .gold,
        category: "lambda-streams",
        tags: ["parallelStream", "forEachOrdered", "順序"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List.of(1, 2, 3).parallelStream()
            .forEachOrdered(System.out::print);
    }
}
""",
        question: "このコードの出力として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "123",
                   correct: true, misconception: nil,
                   explanation: "parallelStreamでも、順序付きストリームに対してforEachOrderedを使うと遭遇順序が維持されます。"),
            Choice(id: "b", text: "321",
                   correct: false, misconception: "parallelなら必ず逆順になると誤解",
                   explanation: "並列処理は逆順を意味しません。forEachOrderedは元の順序を尊重します。"),
            Choice(id: "c", text: "出力順は毎回不定",
                   correct: false, misconception: "forEachとforEachOrderedを混同",
                   explanation: "順序が不定になり得るのはforEachです。forEachOrderedは順序付きストリームの遭遇順序を守ります。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "parallelStreamではforEachOrderedが使えないと誤解",
                   explanation: "forEachOrderedはStreamの終端操作として有効です。"),
        ],
        explanationRef: "explain-gold-stream-007",
        designIntent: "並列ストリームでもforEachOrderedなら順序が維持されることを、forEachとの対比で確認する。"
    )

    // MARK: - Gold: Optional (or)

    static let goldOptional004 = Quiz(
        id: "gold-optional-004",
        level: .gold,
        category: "optional-api",
        tags: ["Optional", "or", "Supplier"],
        code: """
import java.util.*;

public class Test {
    static Optional<String> fallback() {
        System.out.print("F");
        return Optional.of("fallback");
    }

    public static void main(String[] args) {
        String result = Optional.of("java")
            .or(Test::fallback)
            .get();
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "java",
                   correct: true, misconception: nil,
                   explanation: "Optionalに値があるため、orに渡したSupplierは実行されません。fallback()のFも出力されず、javaだけが出ます。"),
            Choice(id: "b", text: "Fjava",
                   correct: false, misconception: "orのSupplierが常に実行されると誤解",
                   explanation: "orは値が空の場合だけ代替Optionalを取得します。値がある場合はSupplierを呼びません。"),
            Choice(id: "c", text: "fallback",
                   correct: false, misconception: "orが常に代替Optionalを優先すると誤解",
                   explanation: "元のOptionalに値がある場合、その値が優先されます。"),
            Choice(id: "d", text: "NoSuchElementException",
                   correct: false, misconception: "or後も空のままだと誤解",
                   explanation: "元のOptionalにjavaが入っているため、get()は値を返します。"),
        ],
        explanationRef: "explain-gold-optional-004",
        designIntent: "Optional.orは空の場合だけSupplierを遅延実行し、Optionalを返すAPIであることを確認する。"
    )

    // MARK: - Gold: Concurrency (ScheduledExecutorService)

    static let goldConcurrency005 = Quiz(
        id: "gold-concurrency-005",
        level: .gold,
        category: "concurrency",
        tags: ["ScheduledExecutorService", "schedule", "shutdown"],
        code: """
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) throws Exception {
        ScheduledExecutorService es = Executors.newSingleThreadScheduledExecutor();
        es.schedule(() -> System.out.print("A"), 100, TimeUnit.MILLISECONDS);
        System.out.print("B");
        Thread.sleep(200);
        es.shutdown();
    }
}
""",
        question: "このコードを実行したとき、出力として最も適切なのはどれか？",
        choices: [
            Choice(id: "a", text: "AB",
                   correct: false, misconception: "スケジュールした処理が即時実行されると誤解",
                   explanation: "Aは100ミリ秒後に実行されます。先にBが出力されます。"),
            Choice(id: "b", text: "BA",
                   correct: true, misconception: nil,
                   explanation: "scheduleでAは遅延実行されます。mainはすぐにBを出力し、sleep中にAが実行されます。"),
            Choice(id: "c", text: "B",
                   correct: false, misconception: "mainスレッドが終わるとスケジュールタスクが必ず破棄されると誤解",
                   explanation: "ここではsleepで十分待機し、shutdownもタスク実行後です。Aは実行されます。"),
            Choice(id: "d", text: "RejectedExecutionException",
                   correct: false, misconception: "schedule直後に拒否されると誤解",
                   explanation: "shutdown前にタスクを登録しているため拒否されません。"),
        ],
        explanationRef: "explain-gold-concurrency-005",
        designIntent: "ScheduledExecutorService.scheduleが指定遅延後に実行されることと、mainスレッドの流れを確認する。"
    )

    // MARK: - Gold: Concurrency (CopyOnWriteArrayList)

    static let goldConcurrency006 = Quiz(
        id: "gold-concurrency-006",
        level: .gold,
        category: "concurrency",
        tags: ["CopyOnWriteArrayList", "Iterator", "スナップショット"],
        code: """
import java.util.concurrent.CopyOnWriteArrayList;

public class Test {
    public static void main(String[] args) {
        var list = new CopyOnWriteArrayList<String>();
        list.add("A");
        list.add("B");

        for (String s : list) {
            System.out.print(s);
            list.add("C");
        }
        System.out.println(list.size());
    }
}
""",
        question: "このコードを実行したとき、出力として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "AB4",
                   correct: true, misconception: nil,
                   explanation: "CopyOnWriteArrayListのイテレータは作成時点のスナップショットを走査します。ループ対象はAとBだけで、Cが2回追加され最終サイズは4です。"),
            Choice(id: "b", text: "ABC5",
                   correct: false, misconception: "追加されたCも同じループで走査されると誤解",
                   explanation: "スナップショットイテレータなので、走査中に追加された要素はそのループには現れません。"),
            Choice(id: "c", text: "ConcurrentModificationException",
                   correct: false, misconception: "ArrayListのfail-fastと混同",
                   explanation: "CopyOnWriteArrayListは走査中の構造変更でConcurrentModificationExceptionを投げません。"),
            Choice(id: "d", text: "AB2",
                   correct: false, misconception: "addが無視されると誤解",
                   explanation: "addは有効です。ループには反映されませんが、リスト自体にはCが追加されます。"),
        ],
        explanationRef: "explain-gold-concurrency-006",
        designIntent: "CopyOnWriteArrayListのイテレータがスナップショットを走査するため、走査中の追加が現在のループに現れない点を確認する。"
    )

    // MARK: - Gold: I/O (Files.mismatch)

    static let goldIo003 = Quiz(
        id: "gold-io-003",
        level: .gold,
        category: "io",
        tags: ["Files.mismatch", "Path", "NIO.2"],
        code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) throws Exception {
        Path a = Files.writeString(Files.createTempFile("a", ".txt"), "Java");
        Path b = Files.writeString(Files.createTempFile("b", ".txt"), "Jara");
        System.out.println(Files.mismatch(a, b));
    }
}
""",
        question: "このコードを実行したとき、出力される値として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "-1",
                   correct: false, misconception: "異なるファイルでも同じ長さなら-1になると誤解",
                   explanation: "Files.mismatchは内容が完全一致した場合だけ-1を返します。"),
            Choice(id: "b", text: "0",
                   correct: false, misconception: "最初の文字だけ比較すると誤解",
                   explanation: "先頭のJと2文字目のaは一致しています。最初に違うのは3文字目です。"),
            Choice(id: "c", text: "2",
                   correct: true, misconception: nil,
                   explanation: "\"Java\"と\"Jara\"は0始まりで位置2、つまりvとrのところで最初に異なります。Files.mismatchはその位置を返します。"),
            Choice(id: "d", text: "4",
                   correct: false, misconception: "ファイル長を返すと誤解",
                   explanation: "Files.mismatchは長さではなく、最初に異なるバイト位置を返します。"),
        ],
        explanationRef: "explain-gold-io-003",
        designIntent: "Files.mismatchが一致なら-1、差分があれば最初に異なるバイト位置を返すことを確認する。"
    )

    // MARK: - Gold: Module System (open module)

    static let goldModule003 = Quiz(
        id: "gold-module-003",
        level: .gold,
        category: "module-system",
        tags: ["open module", "opens", "exports"],
        code: """
open module com.example.app {
    exports com.example.api;
    opens com.example.model;
}
""",
        question: "このmodule-info.javaについて正しい説明はどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる",
                   correct: false, misconception: "open module内でも個別opensを書けると誤解",
                   explanation: "open moduleは全パッケージをリフレクションに開くため、個別のopens句は書けません。"),
            Choice(id: "b", text: "opens com.example.model の行がコンパイルエラーになる",
                   correct: true, misconception: nil,
                   explanation: "open module宣言では、モジュール全体がopenになります。その中で個別のopensディレクティブを使うことはできません。"),
            Choice(id: "c", text: "exports com.example.api の行がコンパイルエラーになる",
                   correct: false, misconception: "open moduleではexportsも禁止と誤解",
                   explanation: "open moduleでもexportsは使用できます。通常アクセスの公開範囲はexportsで制御します。"),
            Choice(id: "d", text: "実行時にIllegalAccessExceptionが発生する",
                   correct: false, misconception: "module-infoの誤りが実行時まで遅れると誤解",
                   explanation: "module-info.javaの構文・ディレクティブ制約はコンパイル時に検出されます。"),
        ],
        explanationRef: "explain-gold-module-003",
        designIntent: "open moduleとopensディレクティブの関係を整理し、モジュール全体をopenにした場合の制約を確認する。"
    )

    // MARK: - Gold: Localization (DateTimeFormatter Locale)

    static let goldLocalization003 = Quiz(
        id: "gold-localization-003",
        level: .gold,
        category: "localization",
        tags: ["Locale", "DateTimeFormatter", "ofPattern"],
        code: """
import java.time.*;
import java.time.format.*;
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Locale.setDefault(Locale.US);
        LocalDate date = LocalDate.of(2026, Month.APRIL, 20);
        DateTimeFormatter f = DateTimeFormatter.ofPattern("MMM", Locale.JAPAN);
        System.out.println(date.format(f));
    }
}
""",
        question: "このコードを実行したとき、出力として最も適切なのはどれか？",
        choices: [
            Choice(id: "a", text: "Apr",
                   correct: false, misconception: "デフォルトLocale.USが常に使われると誤解",
                   explanation: "Formatter作成時にLocale.JAPANを明示しているため、デフォルトLocale.USではなく日本ロケールが使われます。"),
            Choice(id: "b", text: "4月",
                   correct: true, misconception: nil,
                   explanation: "DateTimeFormatter.ofPatternにLocale.JAPANを渡しているため、月の短縮表記は日本語ロケールに従います。"),
            Choice(id: "c", text: "APRIL",
                   correct: false, misconception: "Month enum名がそのまま出ると誤解",
                   explanation: "formatはDateTimeFormatterのパターンとLocaleに従って文字列化します。enum名を出すわけではありません。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "Month.APRILやLocale.JAPANが使えないと誤解",
                   explanation: "どちらも有効なAPIです。"),
        ],
        explanationRef: "explain-gold-localization-003",
        designIntent: "DateTimeFormatterに明示したLocaleが、デフォルトLocaleより優先されることを確認する。"
    )

    // MARK: - Gold: JDBC (executeUpdate)

    static let goldJdbc003 = Quiz(
        id: "gold-jdbc-003",
        level: .gold,
        category: "jdbc",
        tags: ["JDBC", "executeUpdate", "戻り値"],
        code: """
import java.sql.*;

public class Test {
    static void update(Statement stmt) throws SQLException {
        int count = stmt.executeUpdate("UPDATE users SET active = true");
        System.out.println(count);
    }
}
""",
        question: "executeUpdateの戻り値として正しい説明はどれか？",
        choices: [
            Choice(id: "a", text: "更新された行数",
                   correct: true, misconception: nil,
                   explanation: "executeUpdateはINSERT、UPDATE、DELETEなどで影響を受けた行数をintで返します。"),
            Choice(id: "b", text: "ResultSet",
                   correct: false, misconception: "executeQueryと混同",
                   explanation: "ResultSetを返すのは主にSELECTで使うexecuteQueryです。executeUpdateの戻り値はintです。"),
            Choice(id: "c", text: "SQL文が成功したかどうかのboolean",
                   correct: false, misconception: "executeメソッドと混同",
                   explanation: "booleanを返すのはexecuteです。executeUpdateは更新件数を返します。"),
            Choice(id: "d", text: "常に0",
                   correct: false, misconception: "UPDATEでは行数が返らないと誤解",
                   explanation: "実際に影響を受けた行数が返ります。0は対象行がなかった場合などです。"),
        ],
        explanationRef: "explain-gold-jdbc-003",
        designIntent: "JDBCのexecuteQuery、executeUpdate、executeの戻り値の違いを整理させる。"
    )

    // MARK: - Gold: Classes (Nested static class)

    static let goldClasses003 = Quiz(
        id: "gold-classes-003",
        level: .gold,
        category: "classes",
        tags: ["ネストクラス", "static", "インスタンス"],
        code: """
public class Outer {
    private int value = 10;

    static class Nested {
        void print() {
            System.out.println(value);
        }
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる",
                   correct: false, misconception: "ネストクラスなら外側のインスタンス変数へ直接アクセスできると誤解",
                   explanation: "staticネストクラスは外側クラスのインスタンスに暗黙には結びつきません。インスタンス変数valueへ直接アクセスできません。"),
            Choice(id: "b", text: "valueの参照でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "Nestedはstaticネストクラスです。Outerのインスタンスなしに存在できるため、非staticフィールドvalueを直接参照できません。"),
            Choice(id: "c", text: "実行時にNullPointerException",
                   correct: false, misconception: "外側インスタンスがnullとして扱われると誤解",
                   explanation: "この問題は実行時ではなく、非staticフィールドへの不正アクセスとしてコンパイル時に検出されます。"),
            Choice(id: "d", text: "10と出力される",
                   correct: false, misconception: "Outerインスタンスが自動生成されると誤解",
                   explanation: "staticネストクラスのため、Outerインスタンスは自動生成されません。"),
        ],
        explanationRef: "explain-gold-classes-003",
        designIntent: "staticネストクラスと内部クラスの違い、外側インスタンスへの暗黙参照の有無を確認する。"
    )
}
