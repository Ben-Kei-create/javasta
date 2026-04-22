import Foundation

extension Lesson {
    static let goldLearningExpansion: [Lesson] = [
        goldStreamPipelineExpansion,
        goldCollectorsExpansion,
        goldOptionalDecisionExpansion,
        goldFunctionalTargetTypingExpansion,
        goldPrimitiveFunctionalExpansion,
        goldGenericsErasureExpansion,
        goldCollectionsOrderingExpansion,
        goldTryWithResourcesExpansion,
        goldDateTimeLocalizationExpansion,
        goldModuleSystemExpansion,
        goldConcurrencyExpansion,
        goldNioFilesExpansion,
        goldAnnotationsExpansion,
        goldSecureCodingExpansion,
        goldModernClassFeaturesExpansion,
    ]

    private static func goldLesson(
        id: String,
        category: QuizCategory,
        title: String,
        summary: String,
        estimatedMinutes: Int,
        sections: [Section],
        keyPoints: [String],
        relatedQuizIds: [String]
    ) -> Lesson {
        Lesson(
            id: id,
            level: .gold,
            category: category.rawValue,
            title: title,
            summary: summary,
            estimatedMinutes: estimatedMinutes,
            sections: sections,
            keyPoints: keyPoints,
            relatedQuizIds: relatedQuizIds
        )
    }

    static let goldStreamPipelineExpansion = goldLesson(
        id: "lesson-gold-stream-pipeline-deep",
        category: .lambdaStreams,
        title: "Streamパイプラインを読む",
        summary: "生成、中間操作、終端操作を分け、遅延評価で実行順を追う",
        estimatedMinutes: 10,
        sections: [
            Section(
                id: "model",
                heading: "3つに分けて読む",
                body: "Stream APIは、1) Stream生成、2) [中間操作](javasta://term/intermediate-operation)、3) [終端操作](javasta://term/terminal-operation) に分けて読むと安定します。中間操作はその場では動かず、終端操作が呼ばれたときに必要な分だけ流れます。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .exam, text: "filterやmapのラムダがいつ実行されるかを問う問題では、終端操作の有無を最初に確認します。")
            ),
            Section(
                id: "code",
                heading: "filter・map・limitの順序",
                body: "`filter`、`map`、`limit` の順序で、何件の要素が後段へ進むかが変わります。`limit` は通過件数を制限するため、無限Streamでも終端できることがあります。",
                code: """
Stream.iterate(1, n -> n + 1)
    .filter(n -> n % 2 == 0)
    .map(n -> n * 10)
    .limit(3)
    .forEach(System.out::print); // 204060
""",
                highlightLines: [2, 3, 4, 5],
                callout: nil
            ),
            Section(
                id: "pitfall",
                heading: "再利用できない",
                body: "Streamは終端操作を一度実行すると消費済みです。同じStream変数に対して `count()` の後に `forEach()` すると `IllegalStateException` になります。再度処理したい場合は、新しいStreamを生成します。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .warning, text: "Streamはデータそのものではなく、1回限りの処理パイプラインです。")
            ),
        ],
        keyPoints: [
            "中間操作は遅延評価され、終端操作で初めて実行される",
            "limit、skip、findFirstなどの短絡操作は処理件数に影響する",
            "Streamは終端操作後に再利用できない",
        ],
        relatedQuizIds: ["gold-stream-014", "gold-stream-015", "gold-stream-016", "gold-stream-020", "gold-stream-021", "gold-stream-024", "gold-stream-025"]
    )

    static let goldCollectorsExpansion = goldLesson(
        id: "lesson-gold-collectors-deep",
        category: .lambdaStreams,
        title: "Collectorsの集約パターン",
        summary: "toMap、groupingBy、partitioningBy、joiningの戻り値を読む",
        estimatedMinutes: 11,
        sections: [
            Section(
                id: "tomap",
                heading: "toMapは重複キーを見る",
                body: "`Collectors.toMap` はキー生成関数と値生成関数でMapを作ります。キーが重複する可能性があるなら、マージ関数を指定しないと `IllegalStateException` になります。",
                code: """
Map<Integer, String> map = Stream.of("aa", "b", "cc")
    .collect(Collectors.toMap(
        String::length,
        s -> s,
        (left, right) -> left + right
    ));
""",
                highlightLines: [2, 3, 4, 5],
                callout: Callout(kind: .exam, text: "重複キー、Map実装、表示順の3点を同時に見ます。TreeMap指定ならキー順です。")
            ),
            Section(
                id: "grouping",
                heading: "groupingByとpartitioningBy",
                body: "`groupingBy` は任意の分類キーで `Map<K, List<T>>` を作ります。`partitioningBy` はboolean条件で `Map<Boolean, List<T>>` を作ります。true/falseの2分割ならpartitioningByが自然です。",
                code: """
Map<Integer, List<String>> byLength =
    words.stream().collect(Collectors.groupingBy(String::length));

Map<Boolean, List<String>> longWords =
    words.stream().collect(Collectors.partitioningBy(s -> s.length() >= 3));
""",
                highlightLines: [1, 2, 4, 5],
                callout: nil
            ),
            Section(
                id: "downstream",
                heading: "下流Collector",
                body: "`groupingBy(key, downstream)` の形では、分類後の各グループにさらに集約をかけます。`counting()`、`mapping()`、`joining()` などを組み合わせると戻り値型が変わるため、選択肢の型を先に見ると解きやすくなります。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .tip, text: "Collector問題は、出力値だけでなくMapの型まで追うとミスが減ります。")
            ),
        ],
        keyPoints: [
            "toMapは重複キー時のマージ関数有無を確認する",
            "groupingByは分類キーごとのMap、partitioningByはBooleanキーのMap",
            "下流CollectorによりMapの値型がList以外へ変わる",
        ],
        relatedQuizIds: ["gold-stream-027", "gold-stream-028", "gold-stream-029", "gold-stream-030", "gold-stream-031"]
    )

    static let goldOptionalDecisionExpansion = goldLesson(
        id: "lesson-gold-optional-decision-points",
        category: .optionalApi,
        title: "Optionalの分岐点",
        summary: "get、orElse、orElseGet、orElseThrow、orの評価タイミング",
        estimatedMinutes: 9,
        sections: [
            Section(
                id: "presence",
                heading: "値があるかを先に見る",
                body: "`Optional` は値がある場合と空の場合で分岐します。`get()` は値がある前提の操作なので、空Optionalに対して呼ぶと `NoSuchElementException` です。試験では `isPresent()` だけでなく、`orElseThrow()` の挙動も問われます。",
                code: """
Optional<String> empty = Optional.empty();
empty.get(); // NoSuchElementException
""",
                highlightLines: [2],
                callout: Callout(kind: .warning, text: "get()を安全な取り出しAPIとして扱う選択肢は疑います。")
            ),
            Section(
                id: "eager",
                heading: "orElseは先に評価される",
                body: "`orElse(value)` の `value` はOptionalに値があっても評価されます。一方 `orElseGet(Supplier)` は空のときだけSupplierを実行します。副作用のあるメソッドが置かれたら出力順を追います。",
                code: """
String a = Optional.of("A").orElse(create());      // create()は実行される
String b = Optional.of("B").orElseGet(() -> create()); // create()は実行されない
""",
                highlightLines: [1, 2],
                callout: Callout(kind: .exam, text: "orElseとorElseGetの違いは、値そのものかSupplierかです。")
            ),
            Section(
                id: "or",
                heading: "orはOptionalを返す",
                body: "`or(Supplier<Optional<T>>)` は、空のときに代替Optionalを作ります。`map` は値を変換し、`flatMap` はOptionalを返す変換を1段に平坦化します。戻り値が `Optional<Optional<T>>` になっていないかを確認します。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
        ],
        keyPoints: [
            "空OptionalのgetはNoSuchElementException",
            "orElseは代替値を先に評価し、orElseGetは空のときだけ実行する",
            "orは代替Optionalを返すため、mapやflatMapとの型を追う",
        ],
        relatedQuizIds: ["gold-optional-009", "gold-optional-010", "gold-optional-011", "gold-optional-012", "gold-optional-013"]
    )

    static let goldFunctionalTargetTypingExpansion = goldLesson(
        id: "lesson-gold-functional-target-typing",
        category: .lambdaStreams,
        title: "ラムダ式とターゲット型",
        summary: "ラムダ式は代入先の関数型インターフェースで型が決まる",
        estimatedMinutes: 10,
        sections: [
            Section(
                id: "target",
                heading: "ラムダ単体には型がない",
                body: "ラムダ式は、代入先やメソッド引数の[ターゲット型](javasta://term/target-typing)によって型が決まります。抽象メソッドが1つだけの[関数型インターフェース](javasta://term/functional-interface)へ代入できます。",
                code: """
Predicate<String> p = s -> s.isEmpty();
Function<String, Integer> f = s -> s.length();
""",
                highlightLines: [1, 2],
                callout: nil
            ),
            Section(
                id: "omission",
                heading: "省略記法の条件",
                body: "引数型はターゲット型から推論できます。引数が1つなら丸括弧を省略できます。処理が式1つなら波括弧とreturnも省略できます。ただし、波括弧を使うなら戻り値が必要なSAMでは明示的に `return` が必要です。",
                code: """
Function<String, Integer> a = (String s) -> { return s.length(); };
Function<String, Integer> b = s -> s.length();
""",
                highlightLines: [1, 2],
                callout: Callout(kind: .exam, text: "波括弧ありのラムダでreturn漏れ、returnありでセミコロン漏れ、が定番です。")
            ),
            Section(
                id: "methodref",
                heading: "メソッド参照もターゲット型で読む",
                body: "`String::length`、`System.out::println`、`ArrayList::new` などのメソッド参照も、ターゲット型の抽象メソッドに合うかで判定します。見た目だけでなく、引数と戻り値が一致するかを確認します。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .tip, text: "メソッド参照は省略されたラムダとして展開して考えると読みやすくなります。")
            ),
        ],
        keyPoints: [
            "ラムダ式とメソッド参照はターゲット型で型が決まる",
            "省略記法は、引数数、波括弧、returnの有無をセットで見る",
            "オーバーロードとラムダが絡むと、候補メソッドの関数型インターフェースを確認する",
        ],
        relatedQuizIds: ["gold-functional-lambda-001", "gold-functional-lambda-002", "gold-functional-lambda-003", "gold-functional-lambda-004", "gold-functional-lambda-005", "gold-functional-lambda-006"]
    )

    static let goldPrimitiveFunctionalExpansion = goldLesson(
        id: "lesson-gold-primitive-functional-interfaces",
        category: .lambdaStreams,
        title: "プリミティブ特化の関数型IF",
        summary: "IntPredicate、ToIntFunction、IntUnaryOperatorなどでBoxingを避ける",
        estimatedMinutes: 9,
        sections: [
            Section(
                id: "why",
                heading: "Boxingを避けるための型",
                body: "`Predicate<Integer>` や `Function<Integer, Integer>` はラッパークラスを使うため、オートボクシングが絡みます。`IntPredicate`、`IntFunction`、`ToIntFunction`、`IntUnaryOperator` などはintを直接扱います。",
                code: """
IntPredicate even = n -> n % 2 == 0;
IntUnaryOperator twice = n -> n * 2;
ToIntFunction<String> len = String::length;
""",
                highlightLines: [1, 2, 3],
                callout: nil
            ),
            Section(
                id: "naming",
                heading: "名前で入出力を読む",
                body: "`ToIntFunction<T>` はTを受け取ってintを返します。`IntFunction<R>` はintを受け取ってRを返します。`IntSupplier` は引数なしでintを返し、`IntConsumer` はintを受け取って戻り値なしです。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .exam, text: "ToIntとIntToの向きを逆に読む選択肢に注意します。")
            ),
            Section(
                id: "composition",
                heading: "合成メソッド",
                body: "`Predicate` の `and`、`or`、`negate`、`Function` の `compose`、`andThen` は評価順に注意します。`compose` は先に引数側、`andThen` は後続側を実行します。",
                code: """
Function<Integer, Integer> add = n -> n + 1;
Function<Integer, Integer> dbl = n -> n * 2;
System.out.println(add.andThen(dbl).apply(3)); // 8
""",
                highlightLines: [3],
                callout: nil
            ),
        ],
        keyPoints: [
            "Int/Long/Double特化型はBoxingを避ける",
            "ToIntFunctionとIntFunctionは入力と出力の向きが違う",
            "composeとandThenは実行順を追う",
        ],
        relatedQuizIds: ["gold-functional-lambda-021", "gold-functional-lambda-022", "gold-functional-lambda-023", "gold-functional-lambda-024", "gold-functional-lambda-039", "gold-functional-lambda-040"]
    )

    static let goldGenericsErasureExpansion = goldLesson(
        id: "lesson-gold-generics-erasure-wildcards",
        category: .generics,
        title: "型消去とワイルドカード",
        summary: "実行時に残らない型引数と、extends/superの読み方",
        estimatedMinutes: 11,
        sections: [
            Section(
                id: "erasure",
                heading: "型引数は主にコンパイル時のもの",
                body: "Javaジェネリクスは[型消去](javasta://term/type-erasure)されます。`List<String>` と `List<Integer>` はコンパイル時には区別されますが、実行時の型情報として型引数は通常残りません。",
                code: """
List<String> names = new ArrayList<>();
List<Integer> nums = new ArrayList<>();
System.out.println(names.getClass() == nums.getClass()); // true
""",
                highlightLines: [1, 2, 3],
                callout: Callout(kind: .exam, text: "型消去により、型引数だけが違うオーバーロードは同じシグネチャ扱いになります。")
            ),
            Section(
                id: "wildcards",
                heading: "extendsは読む、superは入れる",
                body: "`List<? extends Number>` はNumberとして読めますが、具体的な非null値を安全に追加できません。`List<? super Integer>` はIntegerを追加できますが、読むときは基本的にObjectです。",
                code: """
List<? extends Number> src = List.of(1, 2, 3);
Number n = src.get(0);

List<? super Integer> dst = new ArrayList<Number>();
dst.add(10);
""",
                highlightLines: [1, 2, 4, 5],
                callout: nil
            ),
            Section(
                id: "raw",
                heading: "raw型は警告、失敗は後で出る",
                body: "raw型を使うとコンパイル時の型安全性が弱まり、ヒープ汚染が起きます。追加時ではなく、取り出して具体型へ代入する地点で `ClassCastException` になることがあります。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .warning, text: "raw型の警告を、コンパイルエラーと読み違えないようにします。")
            ),
        ],
        keyPoints: [
            "ジェネリクスの型引数は実行時には通常消去される",
            "? extends Tは読み取り中心、? super Tは書き込み中心",
            "raw型は警告で通り、取得時にClassCastExceptionへつながることがある",
        ],
        relatedQuizIds: ["gold-generics-001", "gold-generics-002", "gold-generics-003", "gold-generics-004", "gold-generics-009", "gold-generics-010"]
    )

    static let goldCollectionsOrderingExpansion = goldLesson(
        id: "lesson-gold-collections-ordering-mutability",
        category: .collections,
        title: "コレクションの順序と変更可否",
        summary: "List、Set、Mapの順序、重複、変更不可ビューを整理する",
        estimatedMinutes: 10,
        sections: [
            Section(
                id: "types",
                heading: "主要インターフェースの違い",
                body: "`List` は順序と重複あり、`Set` は重複なし、`Queue` は取り出し順、`Map` はキーと値の対応です。MapはCollectionのサブインターフェースではありません。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
            Section(
                id: "ordering",
                heading: "順序は実装で決まる",
                body: "`ArrayList` はインデックス順、`HashSet` は基本的に順序保証なし、`TreeSet` は比較順です。`TreeSet` は比較結果が0なら同じ要素とみなすため、`equals` がfalseでも追加されない場合があります。",
                code: """
Set<String> set = new TreeSet<>(Comparator.comparingInt(String::length));
set.add("aa");
set.add("bb"); // 長さが同じなので比較上は重複
System.out.println(set.size()); // 1
""",
                highlightLines: [1, 2, 3, 4],
                callout: Callout(kind: .exam, text: "Set問題では、equalsではなくComparatorの結果で重複扱いになるケースを確認します。")
            ),
            Section(
                id: "immutability",
                heading: "変更不可ビューとコピー",
                body: "`Collections.unmodifiableList(list)` は元リストを包むビューです。元リストを変更するとビューにも見えます。`List.copyOf(list)` はその時点の変更不可コピーを作ります。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .warning, text: "List.ofは変更不可で、null要素も許容しません。")
            ),
        ],
        keyPoints: [
            "List、Set、Queue、Mapは性質で使い分ける",
            "HashSet、TreeSet、LinkedHashSetでは順序保証が違う",
            "unmodifiableListはビュー、List.copyOfはコピー",
        ],
        relatedQuizIds: ["gold-collections-020", "gold-collections-021", "gold-collections-022", "gold-collections-023", "gold-collections-026", "gold-collections-027"]
    )

    static let goldTryWithResourcesExpansion = goldLesson(
        id: "lesson-gold-try-with-resources-suppressed",
        category: .exceptionHandling,
        title: "try-with-resourcesとsuppressed",
        summary: "close順、主例外、抑制例外の関係を追う",
        estimatedMinutes: 9,
        sections: [
            Section(
                id: "close",
                heading: "リソースは逆順に閉じる",
                body: "`try (A a = ...; B b = ...)` のように複数リソースを宣言すると、閉じる順序は逆順です。つまり `b.close()` の後に `a.close()` が呼ばれます。",
                code: """
try (R a = new R("A"); R b = new R("B")) {
    System.out.print("body");
}
// close順は B -> A
""",
                highlightLines: [1],
                callout: nil
            ),
            Section(
                id: "suppressed",
                heading: "主例外とsuppressed",
                body: "try本体で例外が発生し、さらにcloseでも例外が発生した場合、本体の例外が主例外です。close側の例外は `getSuppressed()` で取得できます。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .exam, text: "本体例外がない場合は、closeで最初に投げられた例外が主例外になります。")
            ),
            Section(
                id: "effectively-final",
                heading: "try()内の変数",
                body: "Java 9以降は、tryの外で宣言した実質的finalなリソース変数を `try (r)` のように指定できます。再代入される変数は使えません。",
                code: """
BufferedReader r = Files.newBufferedReader(path);
try (r) {
    System.out.println(r.readLine());
}
""",
                highlightLines: [1, 2],
                callout: nil
            ),
        ],
        keyPoints: [
            "複数リソースは宣言と逆順にcloseされる",
            "try本体の例外が主例外、close例外はsuppressedになる",
            "try()にはfinalまたは実質的finalなリソースを指定できる",
        ],
        relatedQuizIds: ["gold-exception-006", "gold-exception-007", "gold-exception-008", "gold-exception-021", "gold-exception-022"]
    )

    static let goldDateTimeLocalizationExpansion = goldLesson(
        id: "lesson-gold-datetime-localization-format",
        category: .localization,
        title: "日時・数値フォーマット",
        summary: "Locale、DateTimeFormatter、NumberFormat、MessageFormatをつなげて読む",
        estimatedMinutes: 10,
        sections: [
            Section(
                id: "locale",
                heading: "Localeは表示ルールを選ぶ",
                body: "[Locale](javasta://term/locale) は言語や国/地域の情報です。`NumberFormat.getCurrencyInstance(Locale.US)` のように指定すると、通貨記号や桁区切りの見え方が変わります。",
                code: """
NumberFormat f = NumberFormat.getCurrencyInstance(Locale.US);
System.out.println(f.format(1234.5));
""",
                highlightLines: [1, 2],
                callout: nil
            ),
            Section(
                id: "datetime",
                heading: "ofPatternの大文字小文字",
                body: "`DateTimeFormatter.ofPattern` では、`M` は月、`m` は分です。`y`、`M`、`d`、`H`、`m` の違いを見落とすと、出力選択肢で崩れます。",
                code: """
DateTimeFormatter f = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm");
LocalDateTime t = LocalDateTime.parse("2026/04/23 09:30", f);
""",
                highlightLines: [1, 2],
                callout: Callout(kind: .warning, text: "MMとmmの取り違えは、日時フォーマット問題の定番です。")
            ),
            Section(
                id: "bundle",
                heading: "ResourceBundleとMessageFormat",
                body: "[ResourceBundle](javasta://term/resource-bundle) からテンプレート文字列を取り出し、`MessageFormat` で `{0}` などへ値を差し込む流れがよく出ます。存在しないキーは `MissingResourceException` です。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .exam, text: "ファイル探索順、キー存在、フォーマット適用の順に確認します。")
            ),
        ],
        keyPoints: [
            "Localeは数値、通貨、日付の表示ルールに影響する",
            "DateTimeFormatterのパターン文字は大文字小文字を区別する",
            "ResourceBundleの文字列はMessageFormatと組み合わせて使える",
        ],
        relatedQuizIds: ["gold-date-time-002", "gold-date-time-003", "gold-date-time-006", "gold-date-time-007", "gold-localization-004", "gold-localization-005", "gold-localization-024"]
    )

    static let goldModuleSystemExpansion = goldLesson(
        id: "lesson-gold-module-system-deep",
        category: .moduleSystem,
        title: "モジュール宣言を読む",
        summary: "requires、requires transitive、exports、opens、uses/providesの役割",
        estimatedMinutes: 11,
        sections: [
            Section(
                id: "readability",
                heading: "requiresは可読性",
                body: "`requires` は他モジュールを読むための宣言です。`requires transitive` は、その依存を利用側にも伝播します。ただし、モジュールを読めることと、パッケージが公開されていることは別です。",
                code: """
module app {
    requires transitive lib;
}
""",
                highlightLines: [2],
                callout: nil
            ),
            Section(
                id: "exports",
                heading: "exportsとopens",
                body: "`exports` は通常のコンパイル時アクセス用にpublic型を公開します。`opens` はリフレクション用にパッケージを開きます。フレームワークの反射アクセスならopens、通常importならexportsを見ます。",
                code: """
module app {
    exports app.api;
    opens app.internal;
}
""",
                highlightLines: [2, 3],
                callout: Callout(kind: .exam, text: "exportsとopensを同じ公開として扱う選択肢は危険です。")
            ),
            Section(
                id: "services",
                heading: "uses/provides",
                body: "`uses` はサービス利用側、`provides ... with ...` は実装提供側の宣言です。`ServiceLoader` と組み合わせて実装を発見します。依存宣言やパッケージ公開とは別の役割です。",
                code: """
module client {
    uses com.example.Plugin;
}

module provider {
    provides com.example.Plugin with com.example.PluginImpl;
}
""",
                highlightLines: [2, 6],
                callout: nil
            ),
        ],
        keyPoints: [
            "requiresはモジュール可読性、exportsは通常アクセスの公開",
            "opensはリフレクション用の公開",
            "uses/providesはServiceLoader向けのサービス宣言",
        ],
        relatedQuizIds: ["gold-module-003", "gold-module-004", "gold-module-005"]
    )

    static let goldConcurrencyExpansion = goldLesson(
        id: "lesson-gold-concurrency-future-invoke",
        category: .concurrency,
        title: "ExecutorServiceとFuture",
        summary: "submit、get、invokeAll、invokeAnyの戻り方と例外を整理する",
        estimatedMinutes: 10,
        sections: [
            Section(
                id: "submit",
                heading: "submitはFutureを返す",
                body: "`submit(Callable)` は `Future` を返します。タスク内で例外が起きた場合、その例外は `Future.get()` の時点で `ExecutionException` に包まれて観測されます。",
                code: """
Future<Integer> f = service.submit(() -> {
    throw new IllegalStateException("boom");
});
f.get(); // ExecutionException
""",
                highlightLines: [1, 2, 4],
                callout: nil
            ),
            Section(
                id: "invoke-all",
                heading: "invokeAllは入力順",
                body: "`invokeAll` はすべてのタスク完了を待ち、FutureのListを返します。このListの順序は完了順ではなく、渡したタスクの順序に対応します。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .exam, text: "sleepでBが先に終わっても、FutureリストがBから始まるとは限りません。")
            ),
            Section(
                id: "invoke-any",
                heading: "invokeAnyは1つだけ",
                body: "`invokeAny` は正常完了したいずれか1つの結果を返します。全タスクの結果を集めるAPIではありません。早く成功したタスクの値を返すことが多いですが、並行処理なので問題文の条件をよく読みます。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
        ],
        keyPoints: [
            "Future.getはタスク内例外をExecutionExceptionで包む",
            "invokeAllの戻りListは入力順",
            "invokeAnyは成功した1件の結果を返す",
        ],
        relatedQuizIds: ["gold-concurrency-007", "gold-concurrency-008", "gold-concurrency-009", "gold-concurrency-010", "gold-concurrency-011"]
    )

    static let goldNioFilesExpansion = goldLesson(
        id: "lesson-gold-nio-files-paths",
        category: .io,
        title: "NIO.2のPathとFiles",
        summary: "resolve、relativize、normalize、Files.linesを試験目線で読む",
        estimatedMinutes: 10,
        sections: [
            Section(
                id: "path",
                heading: "Path操作は文字列的に読む",
                body: "`resolve` は結合、`relativize` は基準から対象への相対パス、`normalize` は `.` や `..` の整理です。ファイルが存在するかどうかを確認する操作ではありません。",
                code: """
Path base = Path.of("/a/b");
Path target = Path.of("/a/b/c/../d");
System.out.println(base.relativize(target).normalize()); // d
""",
                highlightLines: [1, 2, 3],
                callout: nil
            ),
            Section(
                id: "absolute",
                heading: "絶対パスをresolveすると右辺優先",
                body: "`base.resolve(other)` で `other` が絶対パスなら、baseは無視されてotherが結果になります。セキュアコーディング問題では、ユーザー入力が絶対パスや `..` を含む場合の検証が重要です。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .warning, text: "resolveだけでは安全なディレクトリ配下に閉じ込められません。normalize後にstartsWithなどで確認します。")
            ),
            Section(
                id: "files",
                heading: "Files.linesは閉じる",
                body: "`Files.lines(path)` は行単位のStreamを返します。I/Oリソースを持つためtry-with-resourcesで閉じます。行末の改行は各Stringには含まれません。",
                code: """
try (Stream<String> lines = Files.lines(path)) {
    long count = lines.filter(s -> s.length() > 0).count();
}
""",
                highlightLines: [1, 2],
                callout: nil
            ),
        ],
        keyPoints: [
            "resolve、relativize、normalizeの役割を分ける",
            "絶対パスresolveと..のnormalizeはセキュリティ問題につながる",
            "Files.linesはStreamなので閉じる必要がある",
        ],
        relatedQuizIds: ["gold-io-003", "gold-io-004", "gold-io-005", "gold-io-007", "gold-io-008", "gold-secure-coding-009", "gold-secure-coding-010"]
    )

    static let goldAnnotationsExpansion = goldLesson(
        id: "lesson-gold-annotations-custom-retention",
        category: .annotations,
        title: "カスタムアノテーション",
        summary: "Retention、Target、メタアノテーション、リフレクション可視性",
        estimatedMinutes: 9,
        sections: [
            Section(
                id: "define",
                heading: "@interfaceで定義する",
                body: "カスタムアノテーションは `@interface` で定義します。要素はメソッドのように書き、デフォルト値を指定できます。要素型に使える型は制限されています。",
                code: """
@interface Role {
    String value();
    int level() default 1;
}
""",
                highlightLines: [1, 2, 3],
                callout: nil
            ),
            Section(
                id: "meta",
                heading: "RetentionとTarget",
                body: "`@Retention` は保持期間、`@Target` は付けられる場所を決めるメタアノテーションです。実行時に `isAnnotationPresent` で読むには `RetentionPolicy.RUNTIME` が必要です。",
                code: """
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
@interface TestCase {}
""",
                highlightLines: [1, 2],
                callout: Callout(kind: .exam, text: "CLASS保持はclassファイルには残りますが、通常リフレクションでは見えません。")
            ),
            Section(
                id: "repeat",
                heading: "アノテーションのアノテート",
                body: "アノテーションにアノテーションを付けることをメタアノテーションと呼びます。独自アノテーションを別の独自アノテーションに付けたい場合は、対象に `ElementType.ANNOTATION_TYPE` を含めます。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
        ],
        keyPoints: [
            "カスタムアノテーションは@interfaceで定義する",
            "実行時リフレクションで読むにはRetentionPolicy.RUNTIMEが必要",
            "Targetで付与先を制限し、ANNOTATION_TYPEでアノテーションへ付けられる",
        ],
        relatedQuizIds: ["gold-annotations-003", "gold-annotations-004", "gold-annotations-005", "gold-annotations-010", "gold-annotations-013", "gold-annotations-014"]
    )

    static let goldSecureCodingExpansion = goldLesson(
        id: "lesson-gold-secure-coding-serialization",
        category: .secureCoding,
        title: "セキュアコーディングとシリアライズ",
        summary: "assert、パス検証、transient、readObject、入力フィルタをまとめる",
        estimatedMinutes: 12,
        sections: [
            Section(
                id: "assert",
                heading: "assertは入力検証ではない",
                body: "`assert` は `-ea` で有効、`-da` で無効にできます。無効化され得るため、公開メソッドの引数検証やセキュリティ境界に使うべきではありません。",
                code: """
static int divide(int x) {
    assert x > 0;
    return 100 / x;
}
""",
                highlightLines: [2, 3],
                callout: Callout(kind: .warning, text: "assert無効時にも守るべき条件は、ifで検証して例外を投げます。")
            ),
            Section(
                id: "serialization",
                heading: "transientとreadObject",
                body: "`transient` フィールドはデフォルトシリアライズ対象外です。デシリアライズ時に不変条件を検証したい場合、privateな `readObject` で `defaultReadObject()` 後に値を確認します。",
                code: """
private void readObject(ObjectInputStream in)
    throws IOException, ClassNotFoundException {
    in.defaultReadObject();
    if (age < 0) throw new InvalidObjectException("age");
}
""",
                highlightLines: [1, 3, 4],
                callout: nil
            ),
            Section(
                id: "filter",
                heading: "入力を信頼しない",
                body: "ファイルパスでは `normalize()` 後に許可ディレクトリ配下かを確認します。シリアライズ入力では `ObjectInputFilter` で受け入れる型やサイズを制限できます。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .exam, text: "安全なAPI名が出ていても、検証の順序と範囲が正しいかを読みます。")
            ),
        ],
        keyPoints: [
            "assertは無効化できるため必須検証に使わない",
            "transientはシリアライズ対象外で、復元時はデフォルト値になる",
            "readObjectやObjectInputFilterでデシリアライズ入力を検証する",
        ],
        relatedQuizIds: ["gold-secure-coding-004", "gold-secure-coding-005", "gold-secure-coding-008", "gold-secure-coding-011", "gold-secure-coding-012", "gold-secure-coding-013", "gold-secure-coding-016", "gold-secure-coding-017"]
    )

    static let goldModernClassFeaturesExpansion = goldLesson(
        id: "lesson-gold-record-sealed-object",
        category: .classes,
        title: "record・sealed・Object",
        summary: "Java 17のクラス機能とObject由来メソッドの落とし穴",
        estimatedMinutes: 10,
        sections: [
            Section(
                id: "record",
                heading: "recordは値の入れ物を簡潔に書く",
                body: "`record` はコンポーネントに対応するアクセサ、コンストラクタ、`equals`、`hashCode`、`toString` を自動生成します。ただし配列コンポーネントのequalsは内容比較ではなく、配列オブジェクトのequalsになる点に注意します。",
                code: """
record Box(int[] values) {}
Box a = new Box(new int[] {1});
Box b = new Box(new int[] {1});
System.out.println(a.equals(b)); // false
""",
                highlightLines: [1, 2, 3, 4],
                callout: nil
            ),
            Section(
                id: "sealed",
                heading: "sealedは継承先を制限する",
                body: "`sealed` 型は `permits` で直接サブタイプを制限します。直接サブタイプは `final`、`sealed`、`non-sealed` のいずれかを宣言します。",
                code: """
sealed interface Shape permits Circle {}
final class Circle implements Shape {}
""",
                highlightLines: [1, 2],
                callout: Callout(kind: .exam, text: "permitsにないクラスが直接実装するとコンパイルエラーです。")
            ),
            Section(
                id: "object",
                heading: "Objectメソッドを読む",
                body: "すべての参照型は `Object` 由来の `equals`、`hashCode`、`toString` を持ちます。コレクションやrecordの問題では、どのequalsが呼ばれているかが結果に直結します。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
        ],
        keyPoints: [
            "recordは主要メソッドを自動生成するが、配列内容比較はしない",
            "sealed型の直接サブタイプはpermitsに含まれる必要がある",
            "equals/hashCode/toStringはコレクション動作にも影響する",
        ],
        relatedQuizIds: ["gold-classes-003", "gold-classes-004", "gold-classes-005", "gold-classes-006", "gold-classes-007", "gold-classes-008"]
    )
}
