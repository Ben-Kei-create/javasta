import Foundation

extension Lesson {
    static let samples: [Lesson] = [
        overloadResolution,
        finallyAndReturn,
        boundedWildcards,
    ] + goldLearningExpansion + quickLessons
    
    static func sample(for id: String) -> Lesson? {
        samples.first(where: { $0.id == id })
    }
    
    // MARK: - 深掘り教材 (Deep Dive)
    
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
                body: "同じクラス内で、名前は同じだが引数の型や数が違うメソッドを定義することを[オーバーロード](javasta://term/overload)と呼びます。[コンパイラ](javasta://term/compile)はコンパイル時に静的に呼び先を決定します（[静的束縛](javasta://term/static-binding)）。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "解決ルールの優先順位",
                body: "Javaは次の順番で[オーバーロード](javasta://term/overload)を試します。1) 完全一致、2) [型昇格](javasta://term/type-promotion)（int→long→float→double）、3) [ボクシング](javasta://term/boxing)（int→Integer）、4) [可変長引数](javasta://term/varargs)。上位で見つかった時点で確定し、下位は試しません。",
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
                body: "print(int) を消して print(long) と print(Integer) だけ残すと、5 はまず[型昇格](javasta://term/type-promotion)で long に揃えられて print(long) が呼ばれます。[ボクシング](javasta://term/boxing)は型昇格より優先度が低い点に注意。",
                code: nil,
                highlightLines: [],
                callout: Callout(
                    kind: .warning,
                    text: "可変長引数は最後の手段。他のすべてが該当しない場合のみ選ばれます。"
                )
            ),
        ],
        keyPoints: [
            "呼び先はコンパイル時に決まる（静的束縛）",
            "優先度: 完全一致 ≻ 型昇格 ≻ ボクシング ≻ 可変長引数",
            "print(5) と print(5L) は別メソッドに解決される（リテラルの型が効く）",
            "int と Integer の両方があると、int リテラルは必ず int 側へ",
        ],
        relatedQuizIds: ["silver-overload-001"]
    )
    
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
                body: "`try` / `catch` ブロックを抜ける前に、[finally](javasta://term/finally) ブロックは必ず実行されます。`return` / `break` / `continue` / `throw` のいずれで抜けても同じ。通常は **リソース解放** 専用に使います。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "tryのreturnは保留される",
                body: "tryブロック内で `return X` を実行した瞬間、戻り値 X は一時退避されます。その後 [finally](javasta://term/finally) が実行され、finally が終わってから初めて呼び出し元に戻ります。",
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
                body: "[finally](javasta://term/finally) は「リソース解放」「ログ出力」など副作用専用に使い、戻り値や例外を変更してはいけません。可読性のためにも、tryのreturnを尊重するのがベストプラクティスです。",
                code: nil,
                highlightLines: [],
                callout: Callout(
                    kind: .tip,
                    text: "リソース解放にはfinallyの代わりに try-with-resources を使うとさらに安全。"
                )
            ),
        ],
        keyPoints: [
            "finally は return/break/throw を貫いて必ず実行される",
            "tryのreturn値は一時退避 → finally終了後に返される",
            "finally 内で return/throw を書くと、tryの結果も例外も握りつぶす",
            "リソース解放は try-with-resources で書けるならそちらへ",
        ],
        relatedQuizIds: ["silver-exception-001"]
    )
    
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
                body: "List<Integer> は List<Number> のサブタイプ ではありません。Integer が Number のサブタイプでも、ジェネリクス型自体は[不変（invariant）](javasta://term/generics-invariance)だからです。これが Java ジェネリクスの最大の落とし穴。",
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
                body: "`<? extends Number>` と書くと、Number またはそのサブタイプ（[Integer](javasta://term/wrapper-class), Long, Double等）のリストを受け取れるようになります。これを **上限境界ワイルドカード** （upper bounded wildcard）と呼びます。",
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
                body: "「データを取り出す（Producer）なら `extends`、データを入れる（Consumer）なら `super`」と覚えます。値を読みたい時は `<? extends T>`、値を入れたい時は `<? super T>`。詳細は [PECS](javasta://term/pecs) を参照。",
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
            "<? super T> は T のスーパータイプのリストを受け取れる（反変）",
            "PECS の覚え方: 取り出す = Extends / 入れる = Super",
        ],
        relatedQuizIds: ["gold-generics-001"]
    )
    
    // MARK: - 短編教材 (Quick Lessons)
    
    private static let quickLessons: [Lesson] = [
        
        // ===== 今回追加した5つの新レッスン =====
        
        // MARK: - Silver: GC
        quickLesson(
            id: "lesson-silver-gc-eligibility",
            level: .silver,
            category: .javaBasics,
            title: "GCの対象になるタイミング",
            summary: "到達不能（Unreachable）になったオブジェクトを判定する",
            estimatedMinutes: 5,
            focus: "ガベージコレクション(GC)の対象となるのは、「どの有効なスレッドからも参照されなくなったオブジェクト」です。変数に null を代入したり、別の参照を上書き代入することで、元のオブジェクトは孤立します。",
            examTip: "試験では複数の変数同士で参照を代入し合うコードが出ます。「図を描いて矢印がどこを向いているか」を追うのが確実に解くコツです。",
            code: """
        Object a = new Object(); // 参照A
        Object b = new Object(); // 参照B
        a = b; 
        // 参照Aだったオブジェクトはどこからも辿れなくなり、ここでGC対象になる
        """,
            relatedQuizIds: ["silver-java-basics-002"]
        ),

        // MARK: - Silver: 配列
        quickLesson(
            id: "lesson-silver-multidimensional-arrays",
            level: .silver,
            category: .dataTypes,
            title: "多次元配列と非対称配列",
            summary: "Javaの多次元配列は「配列の配列」である",
            estimatedMinutes: 5,
            focus: "Javaには真の多次元配列はなく、「配列を要素として持つ配列」です。そのため、new int[3][] のように1次元目のサイズだけを指定し、2次元目はバラバラのサイズの配列を後から代入する（非対称配列）ことが可能です。",
            examTip: "1次元目だけ生成した時点では、各要素（2次元目を指す部分）は null です。そのままアクセスすると NullPointerException が発生します。",
            code: """
        int[][] arr = new int[2][]; // OK
        arr[0] = new int[3];        // 1行目は3列
        arr[1] = new int[5];        // 2行目は5列 (非対称)
        """,
            relatedQuizIds: ["silver-array-002"]
        ),

        // MARK: - Gold: JDBC
        quickLesson(
            id: "lesson-gold-jdbc-resultset",
            level: .gold,
            category: .jdbc,
            title: "ResultSetのカーソル操作",
            summary: "データ取得前に必ず rs.next() を呼ぶ",
            estimatedMinutes: 5,
            focus: "executeQuery() で取得した ResultSet は、内部に「カーソル」を持っています。初期状態のカーソルは「1行目の直前」を指しているため、データを読むには必ず最初に next() を呼び出してカーソルを1行目に進める必要があります。",
            examTip: "rs.next() は次の行が存在すれば true を返します。 while(rs.next()) { ... } が定番のイディオムです。next()を忘れて getString() すると SQLException になります。",
            code: """
        ResultSet rs = stmt.executeQuery("SELECT name FROM users");
        // System.out.println(rs.getString("name")); // ❌ 例外発生
        if (rs.next()) {
            System.out.println(rs.getString("name")); // ⭕ OK
        }
        """,
            relatedQuizIds: ["gold-jdbc-001"]
        ),

        // MARK: - Gold: ローカライゼーション
        quickLesson(
            id: "lesson-gold-resourcebundle-fallback",
            level: .gold,
            category: .localization,
            title: "ResourceBundleの検索順序",
            summary: "見つからないプロパティファイルのフォールバック",
            estimatedMinutes: 7,
            focus: "Localeを指定してBundleを取得する際、完全一致するファイルがない場合は以下の順序で探します。\n1. 要求された「言語+地域」\n2. 要求された「言語のみ」\n3. デフォルトの「言語+地域」\n4. デフォルトの「言語のみ」\n5. ベースファイル（言語指定なし）",
            examTip: "fr_CA (フランス語・カナダ) が要求されてファイルがない場合、まずは fr (フランス語) を探します。いきなり en_US (デフォルト) やベースファイルには飛びません。",
            code: nil,
            relatedQuizIds: ["gold-localization-001"]
        ),

        // MARK: - Gold: Stream API
        quickLesson(
            id: "lesson-gold-stream-collectors",
            level: .gold,
            category: .lambdaStreams,
            title: "Collectors.groupingBy",
            summary: "Streamの要素を条件でグループ分けしてMapにする",
            estimatedMinutes: 6,
            focus: "collect(Collectors.groupingBy(分類関数)) を使うと、関数の戻り値をキーとし、そのキーに該当する要素のリストを値とする Map を生成できます。",
            examTip: "戻り値の型は Map<キーの型, List<元の要素の型>> になります。true/false の2つにだけ分けたい場合は Collectors.partitioningBy() の方が適しています。",
            code: """
        List<String> names = List.of("Ali", "Bob", "Charlie");
        // 名前の文字数をキーにしてグループ化
        Map<Integer, List<String>> map = names.stream()
            .collect(Collectors.groupingBy(String::length));
        // 結果: {3=[Ali, Bob], 7=[Charlie]}
        """,
            relatedQuizIds: ["gold-stream-003", "gold-stream-029", "gold-stream-030", "gold-stream-031"]
        ),

        // ===== 以下、既存の全レッスン =====
        
        quickLesson(
            id: "lesson-silver-try-with-resources",
            level: .silver,
            category: .exceptionHandling,
            title: "try-with-resourcesのクローズ順序",
            summary: "複数リソースの自動解放における優先順序",
            estimatedMinutes: 5,
            focus: "try-with-resources文で複数のリソースを宣言した場合、クローズ(closeメソッドの呼び出し)は「宣言した順序の逆（下から上）」に行われます。",
            examTip: "AとBの順番で宣言した場合、B -> A の順でcloseされます。実行結果を問う問題の定番トラップです。",
            code: """
        try (Reader r1 = new FileReader("file1.txt");
             Reader r2 = new FileReader("file2.txt")) {
            // 処理終了時、r2.close() が先によばれ、次に r1.close() が呼ばれる
        }
        """,
            relatedQuizIds: ["silver-exception-002"]
        ),
        quickLesson(
            id: "lesson-silver-list-factory",
            level: .silver,
            category: .collections,
            title: "List.of()とArrays.asList()の違い",
            summary: "コレクションのファクトリメソッドの挙動",
            estimatedMinutes: 6,
            focus: "Java 9の List.of() は「完全な不変(Immutable)リスト」を作り、nullを要素に含めることができず、実行時にNPEになります。一方、Arrays.asList() は「要素の変更(set)のみ可能」でnullも許容します。",
            examTip: "List.of() に null を渡すコードを見たら、コンパイルエラーではなく実行時エラー(NPE)になることを疑ってください。",
            code: """
        List<String> list1 = Arrays.asList("A", null); // OK
        list1.set(0, "B"); // OK

        List<String> list2 = List.of("A", null); // ここでNullPointerException
        // list2.set(0, "B"); // (もし生成できたとしても) UnsupportedOperationException
        """,
            relatedQuizIds: ["silver-collections-001"]
        ),
        quickLesson(
            id: "lesson-gold-executor-submit",
            level: .gold,
            category: .concurrency,
            title: "submit()とexecute()の例外ハンドリング",
            summary: "ExecutorServiceによる非同期タスクの例外",
            estimatedMinutes: 7,
            focus: "execute() は例外が発生するとスレッドが終了しコンソールにエラーが出力されますが、submit() は例外をキャッチして戻り値の Future に閉じ込めます。",
            examTip: "submit() を使った問題で「例外が発生してプログラムが異常終了する」という選択肢はほぼ引っかけです。Future.get() を呼ばない限りエラーは隠蔽されます。",
            code: """
        ExecutorService es = Executors.newSingleThreadExecutor();

        // 例外はコンソールに出力される
        es.execute(() -> { throw new RuntimeException(); });

        // 例外は隠蔽され、f.get() を呼んだ時に ExecutionException としてスローされる
        Future<?> f = es.submit(() -> { throw new RuntimeException(); });
        """,
            relatedQuizIds: ["gold-concurrency-001"]
        ),
        quickLesson(
            id: "lesson-gold-path-resolve",
            level: .gold,
            category: .io,
            title: "Path.resolve()の絶対パス結合",
            summary: "NIO.2 におけるパスの結合ルール",
            estimatedMinutes: 5,
            focus: "Path.resolve(Path other) メソッドは、引数(other)が「相対パス」の場合は結合したパスを返しますが、引数が「絶対パス」の場合は引数(other)そのものを返します。",
            examTip: "Windows環境を想定した C:\\dir などの絶対パスか、/dir などのUNIX系絶対パスが引数に来た場合の挙動を見落とさないように注意してください。",
            code: """
        Path base = Path.of("/app");
        Path relative = Path.of("logs");
        Path absolute = Path.of("/backup");

        System.out.println(base.resolve(relative)); // /app/logs
        System.out.println(base.resolve(absolute)); // /backup (上書きされる)
        """,
            relatedQuizIds: ["gold-io-001"]
        ),
        quickLesson(
            id: "lesson-silver-string-pool",
            level: .silver,
            category: .string,
            title: "Stringの不変性とString Pool",
            summary: "文字列リテラルと new String() の挙動の違い",
            estimatedMinutes: 5,
            focus: "リテラルで生成した文字列は「String Pool」で共有されますが、new演算子を使うとヒープ上に全く新しいインスタンスが生成されます。",
            examTip: "文字列の同値性判定で == を使う引っかけ問題が頻出です。値の比較には必ず equals() を使用してください。",
            code: """
        String s1 = "Java";
        String s2 = "Java";
        String s3 = new String("Java");

        System.out.println(s1 == s2); // true (同じ参照)
        System.out.println(s1 == s3); // false (違う参照)
        """,
            relatedQuizIds: ["silver-string-001"]
        ),
        quickLesson(
            id: "lesson-silver-local-var",
            level: .silver,
            category: .dataTypes,
            title: "ローカル変数型推論 (var)",
            summary: "Java 10から導入された var の正しい使い方",
            estimatedMinutes: 5,
            focus: "var は「ローカル変数」かつ「初期化を伴う宣言」でのみ使用可能です。フィールド変数やメソッドの引数、初期化なしの宣言には使えません。",
            examTip: "var x = null; や var[] arr = new int[3]; のような記述はコンパイルエラーになるため、試験でよく狙われます。",
            code: """
        public void sample() {
            var list = new ArrayList<String>(); // OK
            // var name; // コンパイルエラー (初期化なし)
            // var obj = null; // コンパイルエラー (型が特定できない)
        }
        """,
            relatedQuizIds: ["gold-lambda-effectively-final-001"]
        ),
        quickLesson(
            id: "lesson-silver-exception-types",
            level: .silver,
            category: .exceptionHandling,
            title: "チェック例外と非チェック例外",
            summary: "RuntimeException と Exception の違いを理解する",
            estimatedMinutes: 6,
            focus: "RuntimeExceptionとそのサブクラスは「非チェック例外」であり、try-catchやthrowsの記述が任意です。それ以外のExceptionは「チェック例外」と呼ばれ、ハンドリングが必須です。",
            examTip: "NullPointerException や IllegalArgumentException は非チェック例外です。試験では、例外の種類によってコンパイルエラーになるかどうかの判別が求められます。",
            code: """
        // チェック例外 (IOExceptionなど) はハンドリング必須
        try {
            throw new java.io.IOException();
        } catch (java.io.IOException e) {
            e.printStackTrace();
        }
        """,
            relatedQuizIds: []
        ),
        quickLesson(
            id: "lesson-silver-interface-methods",
            level: .silver,
            category: .inheritance,
            title: "インターフェースのdefault/staticメソッド",
            summary: "Java 8以降のインターフェースの拡張機能",
            estimatedMinutes: 6,
            focus: "インターフェースには、実装を持てる default メソッドと static メソッドを定義できます。これにより、既存の実装クラスを壊さずにメソッドを追加できます。",
            examTip: "インターフェースの static メソッドは、実装クラスのインスタンスからは呼び出せません (InterfaceName.method() のように呼び出す必要があります)。",
            code: """
        interface Greeter {
            default void greet() {
                System.out.println("Hello");
            }
            static void log() {
                System.out.println("Log");
            }
        }
        """,
            relatedQuizIds: []
        ),
        quickLesson(
            id: "lesson-gold-sealed-classes",
            level: .gold,
            category: .classes,
            title: "シールドクラス (Sealed Classes)",
            summary: "Java 17で正式導入された、継承を制限する仕組み",
            estimatedMinutes: 5,
            focus: "sealed 修飾子を使うと、どのクラスがこのクラスを継承できるかを permits で明示的に制限できます。想定外のサブクラスが作られるのを防ぎます。",
            examTip: "シールドクラスを継承するサブクラスは、必ず final, sealed, non-sealed のいずれかの修飾子をつける必要があります。",
            code: """
        public sealed class Shape permits Circle, Square {}

        final class Circle extends Shape {}
        non-sealed class Square extends Shape {}
        """,
            relatedQuizIds: ["gold-classes-002"]
        ),
                quickLesson(
                    id: "lesson-gold-stream-terminal",
            level: .gold,
            category: .lambdaStreams,
            title: "Streamの中間操作と終端操作",
            summary: "遅延評価とストリームの消費",
            estimatedMinutes: 7,
            focus: "filterやmapなどの「中間操作」はストリームを返し、メソッドチェーンを作ります。「終端操作」(forEachやcollect)が呼ばれるまで、実際の処理は実行されません（遅延評価）。",
            examTip: "1つのストリームに対して終端操作を2回呼び出すと、実行時例外 (IllegalStateException) が発生します。",
            code: """
        Stream<String> stream = Stream.of("A", "B", "C");
        stream.filter(s -> s.equals("A")); // 何も出力・実行されない
        long count = stream.count(); // ここで初めて処理される(終端操作)
        // stream.forEach(System.out::println); // 例外発生(再利用不可)
        """,
                    relatedQuizIds: ["gold-stream-003", "gold-stream-004"]
                ),
        quickLesson(
            id: "lesson-gold-optional-flatmap",
            level: .gold,
            category: .optionalApi,
            title: "OptionalのmapとflatMap",
            summary: "ネストしたOptionalを平坦化する方法",
            estimatedMinutes: 6,
            focus: "Optionalの中身を変換する際、変換後の値がさらにOptionalである場合、map() を使うと Optional<Optional<T>> のようにネストしてしまいます。flatMap() を使うと1層に平坦化されます。",
            examTip: "メソッドの戻り値が Optional 型である場合、flatMap を使うのが定石です。",
            code: """
        Optional<String> opt = Optional.of("Java");
        // mapの場合
        Optional<Optional<Integer>> nested = opt.map(s -> Optional.of(s.length()));
        // flatMapの場合
        Optional<Integer> flat = opt.flatMap(s -> Optional.of(s.length()));
        """,
            relatedQuizIds: []
        ),
        quickLesson(
            id: "lesson-gold-module-exports",
            level: .gold,
            category: .moduleSystem,
            title: "モジュールシステムの基本 (exports / requires)",
            summary: "Java 9で導入されたアクセス制御と依存関係の管理",
            estimatedMinutes: 5,
            focus: "module-info.java にて、他モジュールに公開するパッケージを exports で指定し、自分が利用するモジュールを requires で宣言します。",
            examTip: "exports は「パッケージ名」を指定し、requires は「モジュール名」を指定します。この違いが非常によく出題されます。",
            code: """
        module com.myapp.core {
            // パッケージを公開
            exports com.myapp.core.util;
            
            // 他のモジュールに依存
            requires java.logging;
        }
        """,
            relatedQuizIds: ["gold-module-001"]
        ),
        quickLesson(
            id: "lesson-bronze-java-platform",
            level: .silver,
            category: .javaBasics,
            title: "Bronze前提: JDK/JVM/JRE",
            summary: "Javaを動かす道具と実行の流れを押さえる",
            estimatedMinutes: 4,
            focus: "Bronze相当の土台として、[JDK](javasta://term/jdk)・[JVM](javasta://term/jvm)・[ソースファイル](javasta://term/source-file)・[バイトコード](javasta://term/bytecode)の関係を理解します。開発者は `.java` を書き、javacで `.class` にコンパイルし、JVMがそれを実行します。",
            examTip: "Silver以降の問題でも、コンパイル時に決まることと実行時に決まることを分ける力はずっと使います。",
            code: """
// Test.java
public class Test {
    public static void main(String[] args) {
        System.out.println("Hello");
    }
}
""",
            relatedQuizIds: []
        ),
        quickLesson(
            id: "lesson-bronze-variables-expression",
            level: .silver,
            category: .dataTypes,
            title: "Bronze前提: 変数と式",
            summary: "変数宣言、代入、式評価の読み方",
            estimatedMinutes: 4,
            focus: "変数は型・名前・値の組み合わせです。`int x = 3;` はint型の変数xに3を入れます。式は左から順に読むだけでなく、演算子の優先順位と型変換を意識します。",
            examTip: "Silverのひっかけは、Bronzeレベルの代入・演算・比較を正確に追えるかに乗っています。",
            code: """
int x = 3;
int y = x + 2;
System.out.println(y);
""",
            relatedQuizIds: ["silver-array-defaults-001"]
        ),
        quickLesson(
            id: "lesson-silver-main-method",
            level: .silver,
            category: .javaBasics,
            title: "mainメソッドの形",
            summary: "public static void main(String[] args) の各キーワードを整理する",
            estimatedMinutes: 4,
            focus: "Javaアプリケーションの入口は main メソッドです。試験では `public static void main(String[] args)` の並びや、`String... args` でもよい点が問われます。",
            examTip: "`static` がないmainは通常のインスタンスメソッドであり、起動エントリポイントにはなりません。",
            code: """
public class Test {
    public static void main(String... args) {
        System.out.println(args.length);
    }
}
""",
            relatedQuizIds: []
        ),
        quickLesson(
            id: "lesson-silver-primitive-widening",
            level: .silver,
            category: .dataTypes,
            title: "プリミティブの型昇格",
            summary: "byte/short/char/int/long/float/double の昇格ルール",
            estimatedMinutes: 5,
            focus: "小さい整数型は演算時にintへ昇格します。代入やメソッド呼び出しでは、狭い型から広い型への変換は自動で行われます。",
            examTip: "longからintのような縮小変換は明示キャストが必要です。",
            code: """
byte b = 1;
int x = b + 2;      // b は int に昇格
long y = x;         // int から long はOK
""",
            relatedQuizIds: ["silver-overload-002"]
        ),
        quickLesson(
            id: "lesson-silver-wrapper-cache",
            level: .silver,
            category: .dataTypes,
            title: "Wrapperとキャッシュ",
            summary: "Integerの==比較で起こる-128から127の罠",
            estimatedMinutes: 5,
            focus: "IntegerなどのWrapperは参照型です。`==` は値ではなく参照を比較します。Integerは通常 -128 から 127 をキャッシュします。",
            examTip: "Wrapper同士の値比較は `equals()` を使うのが安全です。",
            code: """
Integer a = 100;
Integer b = 100;
System.out.println(a == b); // trueになり得る
""",
            relatedQuizIds: ["silver-autoboxing-001"]
        ),
        quickLesson(
            id: "lesson-silver-string-equals",
            level: .silver,
            category: .string,
            title: "String比較",
            summary: "== と equals の違い、文字列プールの挙動",
            estimatedMinutes: 5,
            focus: "`==` は参照比較、`equals()` は内容比較です。文字列リテラルはプールで共有されるため、同じリテラル同士の `==` はtrueになることがあります。",
            examTip: "`new String(\"x\")` は新しいオブジェクトを作るため、リテラルと `==` では一致しません。",
            code: """
String a = "java";
String b = new String("java");
System.out.println(a == b);      // false
System.out.println(a.equals(b)); // true
""",
            relatedQuizIds: ["silver-string-001"]
        ),
        quickLesson(
            id: "lesson-silver-stringbuilder-mutability",
            level: .silver,
            category: .string,
            title: "StringBuilderの可変性",
            summary: "appendは同じオブジェクトを書き換える",
            estimatedMinutes: 4,
            focus: "Stringは不変ですが、StringBuilderは可変です。`append()` は新しいStringBuilderを作るのではなく、同じインスタンスを更新します。",
            examTip: "`toString()` で作られたStringは、その後StringBuilderを変更しても変わりません。",
            code: """
StringBuilder sb = new StringBuilder("A");
String s = sb.append("B").toString();
sb.append("C");
""",
            relatedQuizIds: ["silver-stringbuilder-001"]
        ),
        quickLesson(
            id: "lesson-silver-array-defaults",
            level: .silver,
            category: .dataTypes,
            title: "配列の初期値",
            summary: "newした配列要素は型ごとのデフォルト値で初期化される",
            estimatedMinutes: 4,
            focus: "配列を `new` すると、各要素はデフォルト値で初期化されます。intは0、booleanはfalse、参照型はnullです。",
            examTip: "ローカル変数そのものは自動初期化されませんが、配列の要素は自動初期化されます。",
            code: """
int[] nums = new int[3];
String[] names = new String[3];
""",
            relatedQuizIds: ["silver-array-defaults-001"]
        ),
        quickLesson(
            id: "lesson-silver-loop-control",
            level: .silver,
            category: .controlFlow,
            title: "breakとcontinue",
            summary: "ループ制御の流れを正確に追う",
            estimatedMinutes: 5,
            focus: "`break` はループを抜け、`continue` は次の繰り返しへ進みます。for文ではcontinue後に更新式が実行されます。",
            examTip: "ネストしたループでは、ラベル付きbreak/continueの対象を見誤りやすいです。",
            code: """
for (int i = 0; i < 3; i++) {
    if (i == 1) continue;
    System.out.print(i);
}
""",
            relatedQuizIds: []
        ),
        quickLesson(
            id: "lesson-silver-switch-fallthrough",
            level: .silver,
            category: .controlFlow,
            title: "switchのフォールスルー",
            summary: "breakがないcaseは次へ流れる",
            estimatedMinutes: 4,
            focus: "従来のswitch文では、`break` がないと次のcaseへ処理が流れます。マッチしたcaseから実行が始まる点も重要です。",
            examTip: "defaultの位置は最後でなくてもよく、そこからもbreakがなければ流れます。",
            code: nil,
            relatedQuizIds: ["silver-switch-001"]
        ),
        quickLesson(
            id: "lesson-silver-constructor-chain",
            level: .silver,
            category: .classes,
            title: "コンストラクタチェーン",
            summary: "this(...) と super(...) は先頭文にしか書けない",
            estimatedMinutes: 5,
            focus: "`this(...)` は同じクラスの別コンストラクタ、`super(...)` は親クラスのコンストラクタを呼びます。どちらもコンストラクタの先頭文でなければなりません。",
            examTip: "明示的に書かない場合、コンパイラは `super()` を補います。",
            code: """
Box() {
    this(10);  // 先頭文なのでOK
}
""",
            relatedQuizIds: ["silver-constructor-001"]
        ),
        quickLesson(
            id: "lesson-silver-access-modifiers",
            level: .silver,
            category: .classes,
            title: "アクセス修飾子",
            summary: "public/protected/デフォルト/private の範囲",
            estimatedMinutes: 5,
            focus: "アクセス範囲は `public > protected > package-private > private` の順に広くなります。デフォルトは同一パッケージ内のみアクセス可能です。",
            examTip: "protectedは同一パッケージまたはサブクラスからアクセスできますが、別パッケージの扱いに注意が必要です。",
            code: nil,
            relatedQuizIds: []
        ),
        quickLesson(
            id: "lesson-silver-static-instance",
            level: .silver,
            category: .classes,
            title: "staticとインスタンス",
            summary: "クラスに属するものとオブジェクトに属するものを分ける",
            estimatedMinutes: 5,
            focus: "`static` メンバーはクラスに属し、インスタンスメンバーは各オブジェクトに属します。staticメソッドから直接インスタンス変数へはアクセスできません。",
            examTip: "参照変数経由でstaticメンバーを呼べても、解決先は参照先オブジェクトではなくクラスです。",
            code: nil,
            relatedQuizIds: ["silver-classes-002"]
        ),
        quickLesson(
            id: "lesson-silver-dynamic-dispatch",
            level: .silver,
            category: .inheritance,
            title: "動的ディスパッチ",
            summary: "オーバーライドメソッドは実体の型で決まる",
            estimatedMinutes: 5,
            focus: "親型の変数に子クラスのインスタンスを入れても、オーバーライドされたメソッドは実体である子クラス側が呼ばれます。",
            examTip: "フィールドはオーバーライドされず、参照型で解決されます。",
            code: nil,
            relatedQuizIds: ["silver-inheritance-001"]
        ),
        quickLesson(
            id: "lesson-silver-interface-default",
            level: .silver,
            category: .inheritance,
            title: "interfaceのdefaultメソッド",
            summary: "実装を持つインタフェースメソッドの扱い",
            estimatedMinutes: 5,
            focus: "Java 8以降、interfaceはdefaultメソッドを持てます。実装クラスは必要に応じてオーバーライドできます。",
            examTip: "複数interfaceから同じdefaultメソッドを継承すると、実装クラス側で明示的な解決が必要です。",
            code: nil,
            relatedQuizIds: []
        ),
        quickLesson(
            id: "lesson-silver-checked-exception",
            level: .silver,
            category: .exceptionHandling,
            title: "チェック例外と非チェック例外",
            summary: "throwsやcatchが必要な例外を見分ける",
            estimatedMinutes: 5,
            focus: "Exception直下の多くはチェック例外で、コンパイル時に処理が強制されます。RuntimeExceptionとそのサブクラスは非チェック例外です。",
            examTip: "catchの順序はサブクラスから先。親クラスを先にcatchすると後続が到達不能になります。",
            code: nil,
            relatedQuizIds: ["silver-exception-001"]
        ),
        quickLesson(
            id: "lesson-silver-try-with-resources-basic",
            level: .silver,
            category: .exceptionHandling,
            title: "try-with-resources",
            summary: "AutoCloseableを自動でcloseする構文",
            estimatedMinutes: 5,
            focus: "try-with-resourcesでは、tryの括弧内で宣言したリソースがブロック終了時に自動でcloseされます。",
            examTip: "複数リソースは宣言の逆順でcloseされます。",
            code: nil,
            relatedQuizIds: ["silver-exception-002"]
        ),
        quickLesson(
            id: "lesson-gold-generics-invariance",
            level: .gold,
            category: .generics,
            title: "ジェネリクスの不変性",
            summary: "List<Integer> は List<Number> ではない",
            estimatedMinutes: 6,
            focus: "IntegerはNumberのサブタイプですが、List<Integer>はList<Number>のサブタイプではありません。これを不変性と呼びます。",
            examTip: "読み取り中心なら `? extends`、書き込み中心なら `? super` を検討します。",
            code: """
List<Integer> ints = List.of(1);
// List<Number> nums = ints; // コンパイルエラー
""",
            relatedQuizIds: ["gold-generics-001"]
        ),
        quickLesson(
            id: "lesson-gold-lower-bounded-wildcard",
            level: .gold,
            category: .generics,
            title: "下限境界ワイルドカード",
            summary: "<? super T> はTを入れる側で使う",
            estimatedMinutes: 6,
            focus: "`List<? super Integer>` にはIntegerを追加できます。ただし取り出すときは具体型が保証できないためObjectになります。",
            examTip: "PECS: Producer Extends, Consumer Super。",
            code: nil,
            relatedQuizIds: ["gold-generics-002"]
        ),
        quickLesson(
            id: "lesson-gold-functional-interface",
            level: .gold,
            category: .lambdaStreams,
            title: "関数型インタフェース",
            summary: "抽象メソッドが1つだけのinterface",
            estimatedMinutes: 5,
            focus: "ラムダ式の代入先は関数型インタフェースです。Predicate、Function、Consumer、Supplierなどの標準APIを覚えます。",
            examTip: "@FunctionalInterfaceは必須ではありませんが、条件を満たさない時にコンパイルエラーで検出できます。",
            code: nil,
            relatedQuizIds: []
        ),
        quickLesson(
            id: "lesson-gold-effectively-final",
            level: .gold,
            category: .lambdaStreams,
            title: "effectively final",
            summary: "ラムダから参照するローカル変数の制約",
            estimatedMinutes: 5,
            focus: "ラムダ式内から参照するローカル変数はfinalまたは実質的finalである必要があります。後から再代入するとコンパイルエラーになります。",
            examTip: "参照先オブジェクトの状態変更と、変数そのものの再代入は別物です。",
            code: nil,
            relatedQuizIds: []
        ),
        quickLesson(
            id: "lesson-gold-stream-lazy",
            level: .gold,
            category: .lambdaStreams,
            title: "Streamの遅延評価",
            summary: "中間操作は終端操作まで動かない",
            estimatedMinutes: 6,
            focus: "filterやmapなどの中間操作はパイプラインを組み立てるだけです。sum、collect、forEachなどの終端操作で初めて実行されます。",
            examTip: "peekを使った出力順問題は、終端操作の有無を必ず確認します。",
            code: nil,
            relatedQuizIds: ["gold-stream-001", "gold-stream-002", "gold-stream-lazy-001", "gold-stream-004"]
        ),
        quickLesson(
            id: "lesson-gold-stream-findfirst",
            level: .gold,
            category: .lambdaStreams,
            title: "findFirstとOptional",
            summary: "条件に合う最初の要素をOptionalで受け取る",
            estimatedMinutes: 5,
            focus: "`findFirst()` はOptionalを返します。順序付きストリームでは、条件に合う最初の要素を安全に扱えます。",
            examTip: "値がない可能性があるため、orElseやorElseGetで後続処理を設計します。",
            code: nil,
            relatedQuizIds: ["gold-stream-002"]
        ),
        quickLesson(
            id: "lesson-gold-optional-orelseget",
            level: .gold,
            category: .optionalApi,
            title: "orElseとorElseGet",
            summary: "デフォルト値の評価タイミングが違う",
            estimatedMinutes: 5,
            focus: "`orElse(value)` のvalueは即時評価されます。`orElseGet(supplier)` は値がない場合だけSupplierが実行されます。",
            examTip: "副作用のあるメソッドをorElseに渡すと、Optionalに値があっても実行されます。",
            code: nil,
            relatedQuizIds: ["gold-optional-001", "gold-optional-002", "gold-optional-003"]
        ),
        quickLesson(
            id: "lesson-gold-datetime-immutable",
            level: .gold,
            category: .classes,
            title: "Date-Time APIの不変性",
            summary: "LocalDateなどは変更ではなく新しい値を返す",
            estimatedMinutes: 5,
            focus: "LocalDate、LocalTime、LocalDateTimeは不変です。plusDaysなどのメソッドは元のインスタンスを変えず、新しいインスタンスを返します。",
            examTip: "戻り値を受け取らないと、変更したつもりでも元の値のままです。",
            code: """
LocalDate d = LocalDate.of(2026, 4, 19);
d.plusDays(1); // d 自体は変わらない
""",
            relatedQuizIds: ["gold-date-time-001"]
        ),
        quickLesson(
            id: "lesson-gold-module-basics",
            level: .gold,
            category: .moduleSystem,
            title: "module-info.javaの基本",
            summary: "requiresとexportsで依存と公開を宣言する",
            estimatedMinutes: 6,
            focus: "モジュールは `module-info.java` で定義します。`requires` で依存モジュール、`exports` で外部公開するパッケージを宣言します。",
            examTip: "exportsしないパッケージは、publicクラスであっても他モジュールから直接利用できません。",
            code: """
module app.main {
    requires java.sql;
    exports com.example.api;
}
""",
            relatedQuizIds: ["gold-module-001", "gold-module-002"]
        ),
        quickLesson(
            id: "lesson-gold-service-loader",
            level: .gold,
            category: .moduleSystem,
            title: "ServiceLoader",
            summary: "uses/providesでサービス実装を疎結合にする",
            estimatedMinutes: 6,
            focus: "モジュールシステムでは、サービス利用側が `uses`、提供側が `provides ... with ...` を宣言します。",
            examTip: "実装クラスをexportsしなくても、providesでサービス提供できます。",
            code: nil,
            relatedQuizIds: []
        ),
        quickLesson(
            id: "lesson-gold-executor-future",
            level: .gold,
            category: .concurrency,
            title: "ExecutorServiceとFuture",
            summary: "非同期タスクの投入と結果取得",
            estimatedMinutes: 6,
            focus: "ExecutorServiceにCallableをsubmitするとFutureが返ります。`get()` は結果が出るまで待機し、例外はExecutionExceptionに包まれます。",
            examTip: "shutdownしないExecutorServiceはアプリケーション終了を妨げることがあります。",
            code: nil,
            relatedQuizIds: ["gold-concurrency-001", "gold-concurrency-004"]
        ),
        quickLesson(
            id: "lesson-gold-atomic-integer",
            level: .gold,
            category: .concurrency,
            title: "AtomicInteger",
            summary: "ロックなしで安全に数値を更新する",
            estimatedMinutes: 5,
            focus: "AtomicIntegerはCASを使ってスレッドセーフな更新を提供します。`getAndIncrement()` は更新前の値、`incrementAndGet()` は更新後の値を返します。",
            examTip: "名前にAndがあるメソッドは戻り値のタイミングを問われやすいです。",
            code: nil,
            relatedQuizIds: ["gold-concurrency-002"]
        ),
        quickLesson(
            id: "lesson-gold-path-normalize",
            level: .gold,
            category: .io,
            title: "Path.normalize",
            summary: ". と .. を整理したパスを作る",
            estimatedMinutes: 5,
            focus: "`Path.normalize()` は冗長な名前要素を取り除きます。ファイルシステムへアクセスして存在確認をするわけではありません。",
            examTip: "`normalize` と `toRealPath` は別物です。toRealPathは実ファイル解決を伴います。",
            code: nil,
            relatedQuizIds: ["gold-path-normalize-001"]
        ),
        quickLesson(
            id: "lesson-gold-files-api",
            level: .gold,
            category: .io,
            title: "Files API",
            summary: "readString/writeString/copy/moveなどのNIO.2操作",
            estimatedMinutes: 6,
            focus: "FilesクラスはPathを使ってファイル操作を行うユーティリティです。小さなテキストならreadString/writeString、コピーや移動にはcopy/moveを使います。",
            examTip: "copyやmoveはオプション指定なしだと既存ファイルで例外になる点に注意します。",
            code: nil,
            relatedQuizIds: ["gold-io-001", "gold-io-002"]
        ),
        quickLesson(
            id: "lesson-gold-tree-set-comparator",
            level: .gold,
            category: .collections,
            title: "TreeSetとComparatorの重複判定",
            summary: "Setの重複はequalsだけで決まるとは限らない",
            estimatedMinutes: 6,
            focus: "TreeSetは要素の並び順だけでなく、同一要素かどうかもComparatorまたはcompareToの結果で判断します。比較結果が0なら、equalsがfalseでも同じ要素として扱われます。",
            examTip: "Comparator.comparingInt(String::length) のような比較では、同じ長さの別文字列が重複扱いになります。",
            code: """
Set<String> set = new TreeSet<>(Comparator.comparingInt(String::length));
set.add("aa");
set.add("bb"); // 長さが同じなので追加されない
""",
            relatedQuizIds: ["gold-collections-001"]
        ),
        quickLesson(
            id: "lesson-gold-type-erasure-overload",
            level: .gold,
            category: .generics,
            title: "型消去とメソッド衝突",
            summary: "List<String>とList<Integer>だけではオーバーロードできない",
            estimatedMinutes: 6,
            focus: "Javaのジェネリクスはコンパイル後に型引数が消去されます。List<String>もList<Integer>も実行時にはListとして扱われるため、型引数だけが異なるメソッドは同じシグネチャとして衝突します。",
            examTip: "ジェネリクス絡みのコンパイルエラーでは、型消去後の形を頭の中で作ると判断しやすくなります。",
            code: """
void print(List<String> values) {}
void print(List<Integer> values) {} // 型消去後に衝突
""",
            relatedQuizIds: ["gold-generics-003", "gold-generics-erasure-001"]
        ),
        quickLesson(
            id: "lesson-gold-stream-reduce-identity",
            level: .gold,
            category: .lambdaStreams,
            title: "reduceのidentity",
            summary: "畳み込みの初期値は結果に含まれる",
            estimatedMinutes: 5,
            focus: "Streamのreduce(identity, accumulator)では、identityが累積処理の初期値として使われます。空ストリームならidentityそのものが返り、要素がある場合もidentityから計算が始まります。",
            examTip: "合計問題でidentityが0以外のときは、その値を足し忘れないようにします。",
            code: """
int result = Stream.of(1, 2, 3).reduce(10, Integer::sum); // 16
""",
            relatedQuizIds: ["gold-stream-005"]
        ),
        quickLesson(
            id: "lesson-gold-optional-of-null",
            level: .gold,
            category: .optionalApi,
            title: "Optional.of(null)の扱い",
            summary: "ofは非null専用、ofNullableはnull許容",
            estimatedMinutes: 5,
            focus: "Optional.of(value) はvalueがnullでないことを前提にします。nullの可能性がある値をOptional化するときは Optional.ofNullable(value) を使います。",
            examTip: "Optional.of(null) はコンパイルエラーではなく、実行時にNullPointerExceptionです。",
            code: """
Optional.of("x");       // OK
Optional.ofNullable(null); // OK: Optional.empty()
Optional.of(null);      // NullPointerException
""",
            relatedQuizIds: ["gold-optional-003"]
        ),
        quickLesson(
            id: "lesson-gold-records",
            level: .gold,
            category: .classes,
            title: "Recordクラスの特性",
            summary: "データキャリアを短く書く構文と不変性",
            estimatedMinutes: 6,
            focus: "recordのコンポーネントからはprivate finalフィールド、同名アクセサ、equals、hashCode、toStringが自動生成されます。コンポーネントの値は再代入できません。",
            examTip: "recordに通常のインスタンスフィールドを追加することはできません。staticフィールドや独自メソッドは定義できます。",
            code: """
record Point(int x, int y) {
    int sum() { return x + y; }
}
""",
            relatedQuizIds: ["gold-classes-001"]
        ),
        quickLesson(
            id: "lesson-gold-requires-transitive",
            level: .gold,
            category: .moduleSystem,
            title: "requires transitive",
            summary: "依存モジュールの可読性を利用側へ伝播させる",
            estimatedMinutes: 6,
            focus: "requires transitive A と宣言したモジュールを別モジュールがrequiresすると、その別モジュールもAを読めるようになります。APIの型として依存先モジュールの型を公開する場合に重要です。",
            examTip: "exportsはパッケージ公開、requires transitiveはモジュール可読性の伝播です。役割を混同しないようにします。",
            code: """
module lib.core {
    requires transitive java.sql;
    exports lib.api;
}
""",
            relatedQuizIds: ["gold-module-002"]
        ),
        quickLesson(
            id: "lesson-gold-completable-future",
            level: .gold,
            category: .concurrency,
            title: "CompletableFutureのthenApply",
            summary: "非同期処理の結果を次の処理へ渡す",
            estimatedMinutes: 6,
            focus: "CompletableFutureのthenApplyは、前段の結果を受け取って変換し、新しいCompletableFutureを返します。joinは完了を待って値を取り出します。",
            examTip: "joinはチェック例外を要求しませんが、例外発生時はCompletionExceptionで包まれる点も押さえます。",
            code: """
CompletableFuture<Integer> f = CompletableFuture
    .supplyAsync(() -> 10)
    .thenApply(n -> n + 5);
""",
            relatedQuizIds: ["gold-concurrency-003"]
        ),
        quickLesson(
            id: "lesson-gold-invoke-all-order",
            level: .gold,
            category: .concurrency,
            title: "invokeAllの戻り順",
            summary: "Futureのリストは完了順ではなく投入順",
            estimatedMinutes: 6,
            focus: "ExecutorService.invokeAllはすべてのタスクが完了するまで待機し、渡したタスクの順序と同じ順序でFutureを返します。先に終わったタスクが先頭に並ぶわけではありません。",
            examTip: "sleepで完了順をずらす問題でも、取得順が入力リスト順か完了順かを切り分けます。",
            code: """
List<Future<String>> futures = es.invokeAll(tasks);
// futuresの順序はtasksの順序と同じ
""",
            relatedQuizIds: ["gold-concurrency-004"]
        ),
        quickLesson(
            id: "lesson-gold-path-relativize",
            level: .gold,
            category: .io,
            title: "Path.relativize",
            summary: "基準パスから対象パスまでの相対パスを作る",
            estimatedMinutes: 5,
            focus: "base.relativize(target) は、baseからtargetへ到達するための相対パスを返します。絶対パス同士、相対パス同士のように、比較できる種類を揃える必要があります。",
            examTip: "normalize、resolve、relativizeは名前が似ていますが、用途がまったく違います。",
            code: """
Path base = Path.of("/app/logs");
Path file = Path.of("/app/logs/2026/app.log");
Path relative = base.relativize(file); // 2026/app.log
""",
            relatedQuizIds: ["gold-io-002"]
        ),
        quickLesson(
            id: "lesson-gold-override-annotation",
            level: .gold,
            category: .annotations,
            title: "@Overrideで検出できるミス",
            summary: "オーバーライドとオーバーロードの取り違えを防ぐ",
            estimatedMinutes: 5,
            focus: "@Overrideを付けたメソッドは、親クラスまたはインターフェースのメソッドを実際にオーバーライドしている必要があります。引数が違うだけの同名メソッドはオーバーロードです。",
            examTip: "名前が同じでも、引数リストが違えば別シグネチャです。@Overrideがあるとコンパイルエラーで気づけます。",
            code: """
class Parent { void run() {} }
class Child extends Parent {
    @Override void run(String name) {} // エラー
}
""",
            relatedQuizIds: ["gold-annotations-001"]
        ),
        quickLesson(
            id: "lesson-gold-preparedstatement-index",
            level: .gold,
            category: .jdbc,
            title: "PreparedStatementの番号",
            summary: "プレースホルダは1始まり",
            estimatedMinutes: 5,
            focus: "JDBCのPreparedStatementで?に値をバインドするとき、parameterIndexは1から始まります。最初の?はsetString(1, value)です。",
            examTip: "配列やListの感覚で0を指定する選択肢は、JDBCではひっかけです。",
            code: """
PreparedStatement ps = con.prepareStatement(
    "select * from users where name = ?"
);
ps.setString(1, "Alice");
""",
            relatedQuizIds: ["gold-jdbc-002"]
        ),
        quickLesson(
            id: "lesson-gold-resource-bundle",
            level: .gold,
            category: .localization,
            title: "ResourceBundle",
            summary: "Localeに応じたプロパティファイルを読み込む",
            estimatedMinutes: 6,
            focus: "ResourceBundleはベース名とLocaleから最適なリソースを探索します。地域、言語、デフォルトの順でフォールバックを理解します。",
            examTip: "ファイル名の候補順と、存在しないキーを取得した時のMissingResourceExceptionが頻出です。",
            code: nil,
            relatedQuizIds: ["gold-localization-001", "gold-localization-002"]
        ),
    ]

    private static func quickLesson(
        id: String,
        level: JavaLevel,
        category: QuizCategory,
        title: String,
        summary: String,
        estimatedMinutes: Int,
        focus: String,
        examTip: String,
        code: String?,
        relatedQuizIds: [String]
    ) -> Lesson {
        Lesson(
            id: id,
            level: level,
            category: category.rawValue,
            title: title,
            summary: summary,
            estimatedMinutes: estimatedMinutes,
            sections: [
                Section(
                    id: "focus",
                    heading: "要点",
                    body: focus,
                    code: code,
                    highlightLines: code == nil ? [] : [1],
                    callout: nil
                ),
                Section(
                    id: "exam",
                    heading: "試験での見え方",
                    body: examTip,
                    code: nil,
                    highlightLines: [],
                    callout: Callout(kind: .exam, text: examTip)
                ),
            ],
            keyPoints: [
                focus,
                examTip,
            ],
            relatedQuizIds: relatedQuizIds
        )
    }
}
