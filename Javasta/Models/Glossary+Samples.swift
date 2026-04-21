import Foundation

extension GlossaryTerm {
    static let samples: [GlossaryTerm] = [
        // プラットフォーム
        jdk, jvm, sourceFile, entryPoint, compile, bytecode, secureCodingTerm,
        // OOP基礎
        classAndObject, objectClassTerm, constructor, inheritance, override, overload,
        polymorphism, encapsulation, abstractClass, interfaceTerm,
        staticKeyword, finalKeyword, instanceofTerm,
        // 型・変換
        typePromotion, boxing, wrapperClass, castingTerm, nullTerm,
        varArgs2, varLocalType,
        // 束縛・ディスパッチ
        staticBinding, dynamicBinding,
        // アクセス制御・構造
        accessModifier, packageTerm, importTerm,
        // 例外
        finallyBlock, tryWithResources, suppressedExceptionTerm, serializationTerm, assertionTerm, checkedUnchecked,
        // コレクション
        collectionsFramework, arrayListTerm, hashMapTerm,
        mapComputeIfAbsentTerm, iteratorTerm, comparableTerm, comparatorTerm,
        // 文字列
        stringPool, referenceEquals, integerCache, stringBuilderTerm,
        // ジェネリクス
        genericsInvariance, pecs,
        // 関数型・Stream
        lambdaTerm, functionalInterface, methodReference,
        streamApi, intermediateOp, terminalOp, lazyEvaluation, optionalType,
        // ローカライズ・フォーマット
        localeTerm, resourceBundleTerm, formattingTerm,
        // 制御フロー
        `fallthrough`, switchExpression,
        // モダンJava
        enumTerm, annotationTerm, metaAnnotationTerm, pathNioTerm, recordTerm, sealedTerm,
    ]

    static func lookup(_ id: String) -> GlossaryTerm? {
        samples.first { $0.id == id }
    }

    // MARK: - 用語

    static let jdk = GlossaryTerm(
        id: "jdk",
        term: "JDK",
        aliases: ["Java Development Kit", "開発キット"],
        summary: "Javaアプリを作るための開発キット。javacやjavaコマンドを含む。",
        body: """
**JDK** は Java Development Kit の略で、Javaプログラムを開発するための道具一式です。

主な中身:

- `javac`: [ソースファイル](javasta://term/source-file)を[バイトコード](javasta://term/bytecode)へ変換するコンパイラ
- `java`: [JVM](javasta://term/jvm)上でクラスを実行するコマンド
- 標準ライブラリと開発ツール

Bronze相当の前提として、JDKでコンパイルし、JVMで実行する流れを押さえておくとSilver/Goldの理解がかなり楽になります。
""",
        relatedTermIds: ["jvm", "compile", "bytecode", "source-file"],
        relatedLessonIds: ["lesson-bronze-java-platform"],
        relatedQuizIds: []
    )

    static let jvm = GlossaryTerm(
        id: "jvm",
        term: "JVM",
        aliases: ["Java Virtual Machine", "Java仮想マシン"],
        summary: "Javaのバイトコードを実行する仮想マシン。",
        body: """
**JVM** は Java Virtual Machine の略で、[バイトコード](javasta://term/bytecode)を読み込んで実行する仮想マシンです。

Javaはソースコードを直接実行するのではなく、まず `.class` ファイルに[コンパイル](javasta://term/compile)し、それをJVMが実行します。

この仕組みにより、同じJavaプログラムをさまざまなOS上で動かしやすくしています。
""",
        relatedTermIds: ["jdk", "bytecode", "compile"],
        relatedLessonIds: ["lesson-bronze-java-platform"],
        relatedQuizIds: []
    )

    static let sourceFile = GlossaryTerm(
        id: "source-file",
        term: "ソースファイル",
        aliases: [".java", "Javaファイル", "source file"],
        summary: "開発者が書く `.java` ファイル。コンパイルされて `.class` になる。",
        body: """
**ソースファイル** は、開発者が書く `.java` ファイルです。

`public class Test` を含むソースファイルは、原則として `Test.java` というファイル名にします。publicなトップレベルクラスは1ファイルに1つだけ、というルールも重要です。

一方、publicでないトップレベルクラスは同じファイルに複数書くことも、別ファイルに分けることもできます。
""",
        relatedTermIds: ["compile", "bytecode", "entry-point"],
        relatedLessonIds: ["lesson-bronze-java-platform"],
        relatedQuizIds: ["silver-multifile-override-001"]
    )

    static let entryPoint = GlossaryTerm(
        id: "entry-point",
        term: "エントリポイント",
        aliases: ["mainメソッド", "entry point"],
        summary: "プログラム実行時に最初に呼ばれる入口。Javaではmainメソッド。",
        body: """
**エントリポイント** は、プログラムが実行を開始する入口です。

Javaアプリケーションでは通常、次の形のmainメソッドが入口になります。

```java
public static void main(String[] args) {
    // ここから実行開始
}
```

`String[] args` は `String... args` と書くこともできます。
""",
        relatedTermIds: ["source-file", "static-binding"],
        relatedLessonIds: ["lesson-silver-main-method"],
        relatedQuizIds: []
    )

    static let compile = GlossaryTerm(
        id: "compile",
        term: "コンパイル",
        aliases: ["compile", "コンパイラ"],
        summary: "ソースコードをJVMが実行できる[バイトコード](javasta://term/bytecode)に変換する処理。",
        body: """
Javaの **コンパイル** は、人が書いた `.java` ファイルを `javac` コマンドで `.class` ファイル（[バイトコード](javasta://term/bytecode)）に変換する処理です。

コンパイル時には次のことが行われます。

- 文法チェック（型の整合性、未定義シンボル等）
- [オーバーロード](javasta://term/overload)の解決（[静的束縛](javasta://term/static-binding)）
- ジェネリクスの型消去
- 定数畳み込み等の最適化

実行時に動的に決まる挙動（ポリモーフィズム、リフレクション）と区別して理解するのが重要です。
""",
        relatedTermIds: ["bytecode", "static-binding"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let bytecode = GlossaryTerm(
        id: "bytecode",
        term: "バイトコード",
        aliases: ["bytecode", "クラスファイル"],
        summary: "JVMが直接実行できる中間表現。`.class` ファイルの中身。",
        body: """
**バイトコード** は、Javaソースコードを[コンパイル](javasta://term/compile)した結果生成される中間表現です。

特定のCPUに依存せず、どのプラットフォームでもJVMさえあれば同じバイトコードが動作します。これがJavaの「Write Once, Run Anywhere」を支える仕組みです。

`javap -c Test.class` で人間が読める形に逆アセンブルできます。
""",
        relatedTermIds: ["compile"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let secureCodingTerm = GlossaryTerm(
        id: "secure-coding",
        term: "セキュアコーディング",
        aliases: ["FIO", "MSC", "プラットフォームセキュリティ", "CERT"],
        summary: "外部入力・権限・シリアライズ・コレクション公開などを安全に扱うための実装上の考え方。",
        body: """
**セキュアコーディング** は、コードが想定外の入力や実行環境でも安全に動くようにする実装上の考え方です。

Goldで狙われやすい観点:

- FIO: パス文字列をそのまま信じず、[Path](javasta://term/path-nio)で組み立て、正規化後に許可ディレクトリ配下か確認する
- シリアライズ: [transientやreadObject](javasta://term/serialization)で機密値・不変条件を守る
- プラットフォームセキュリティ: 特権ブロックは必要最小限にする
- MSC: [assert](javasta://term/assertion)を公開引数の検証に使わない、変更可能コレクションを不用意に公開しない

「APIが便利に処理してくれるはず」と思い込まず、境界で検証するのが基本です。
""",
        relatedTermIds: ["path-nio", "serialization", "assertion", "collections", "checked-unchecked"],
        relatedLessonIds: [],
        relatedQuizIds: ["gold-secure-coding-001", "gold-secure-coding-002", "gold-secure-coding-003", "gold-secure-coding-004", "gold-secure-coding-005", "gold-secure-coding-006", "gold-secure-coding-007", "gold-secure-coding-008", "gold-secure-coding-009", "gold-secure-coding-010", "gold-secure-coding-011", "gold-secure-coding-012", "gold-secure-coding-013", "gold-secure-coding-014", "gold-secure-coding-015", "gold-secure-coding-016", "gold-secure-coding-017", "gold-secure-coding-018", "gold-secure-coding-019", "gold-secure-coding-020"]
    )

    static let overload = GlossaryTerm(
        id: "overload",
        term: "オーバーロード",
        aliases: ["overload", "メソッドオーバーロード"],
        summary: "同じクラス内で同名のメソッドを引数の型・数を変えて複数定義すること。",
        body: """
**オーバーロード** とは、同じクラス内で名前が同じだが引数の型や数が異なるメソッドを複数定義することです。

[コンパイル](javasta://term/compile)時に [静的束縛](javasta://term/static-binding) で呼び先が決まるため、実行時のオーバーヘッドはありません。

解決の優先順位は次の通り。

1. 完全一致
2. [型昇格](javasta://term/type-promotion)
3. [ボクシング](javasta://term/boxing)
4. [可変長引数](javasta://term/varargs)

上位で見つかった時点で確定し、下位は試されません。
""",
        relatedTermIds: ["static-binding", "type-promotion", "boxing", "varargs"],
        relatedLessonIds: ["lesson-overload-resolution"],
        relatedQuizIds: ["silver-overload-001"]
    )

    static let staticBinding = GlossaryTerm(
        id: "static-binding",
        term: "静的束縛",
        aliases: ["static binding", "early binding"],
        summary: "コンパイル時にメソッドの呼び出し先が決まる仕組み。",
        body: """
**静的束縛** （early binding）は、[コンパイル](javasta://term/compile)時に呼び出すメソッドが確定する仕組みです。

[オーバーロード](javasta://term/overload)、`static` メソッド、`private` メソッド、`final` メソッドはすべて静的束縛されます。

対義語は [動的束縛](javasta://term/dynamic-binding) で、こちらはインスタンスメソッド（オーバーライド）で使われます。
""",
        relatedTermIds: ["compile", "overload", "dynamic-binding"],
        relatedLessonIds: ["lesson-overload-resolution"],
        relatedQuizIds: []
    )

    static let dynamicBinding = GlossaryTerm(
        id: "dynamic-binding",
        term: "動的束縛",
        aliases: ["dynamic binding", "late binding"],
        summary: "実行時にオブジェクトの実際の型を見てメソッドを呼ぶ仕組み。ポリモーフィズムの土台。",
        body: """
**動的束縛** （late binding）は、実行時にオブジェクトの実際の型に応じて呼ぶメソッドが決まる仕組みです。

```java
Animal a = new Dog();
a.bark();   // → Dog#bark が呼ばれる
```

`a` の宣言型は `Animal` ですが、実体は `Dog`。インスタンスメソッドのオーバーライドはすべて動的束縛されます。

対義語は [静的束縛](javasta://term/static-binding) です。
""",
        relatedTermIds: ["static-binding"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let typePromotion = GlossaryTerm(
        id: "type-promotion",
        term: "型昇格",
        aliases: ["type promotion", "暗黙の型変換"],
        summary: "小さい数値型を大きい数値型に自動変換すること（int→long→float→double）。",
        body: """
**型昇格** は、より精度の低い数値型がより精度の高い数値型に自動的に変換されることです。

順序: `byte` → `short` → `int` → `long` → `float` → `double`

[オーバーロード](javasta://term/overload)解決では、完全一致がない場合に型昇格が試みられます。[ボクシング](javasta://term/boxing)よりも優先されるので注意。
""",
        relatedTermIds: ["overload", "boxing"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let boxing = GlossaryTerm(
        id: "boxing",
        term: "ボクシング",
        aliases: ["boxing", "オートボクシング", "autoboxing"],
        summary: "プリミティブ型を対応するラッパークラスに自動変換すること（int → Integer）。",
        body: """
**ボクシング** とは、`int` などのプリミティブ型を `Integer` などのラッパークラスに変換することです。Java 5以降は自動で行われ、これを **オートボクシング** と呼びます。

逆方向（Integer → int）は **アンボクシング** です。

注意点:

- `Integer` には -128〜127 のキャッシュがあり、`==` 比較で予期せぬ挙動になる
- [オーバーロード](javasta://term/overload)解決では[型昇格](javasta://term/type-promotion)より優先度が低い
""",
        relatedTermIds: ["overload", "type-promotion"],
        relatedLessonIds: [],
        relatedQuizIds: ["silver-autoboxing-001"]
    )

    static let varargs = GlossaryTerm(
        id: "varargs",
        term: "可変長引数",
        aliases: ["varargs", "variable arguments"],
        summary: "`型... 名` の構文で任意個の引数を配列として受け取れる機能。",
        body: """
**可変長引数** は、メソッド宣言で `String...` のように書くことで、任意個の引数を受け取れる機能です。受け取り側では配列として扱われます。

```java
static void log(String... messages) {
    for (String m : messages) System.out.println(m);
}
log("a", "b", "c");
```

[オーバーロード](javasta://term/overload)解決では最後の手段として扱われ、他のすべてが該当しない場合のみ選ばれます。
""",
        relatedTermIds: ["overload"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let genericsInvariance = GlossaryTerm(
        id: "generics-invariance",
        term: "ジェネリクスの不変性",
        aliases: ["invariance", "不変"],
        summary: "`List<Integer>` は `List<Number>` のサブタイプではない、というJavaジェネリクスの基本性質。",
        body: """
Javaのジェネリクス型は **不変** （invariant）です。`Integer` が `Number` のサブタイプであっても、`List<Integer>` は `List<Number>` のサブタイプではありません。

この制約を緩めるためにワイルドカード（`<? extends T>` `<? super T>`）を使います。覚え方は [PECS](javasta://term/pecs)。
""",
        relatedTermIds: ["pecs"],
        relatedLessonIds: ["lesson-bounded-wildcards"],
        relatedQuizIds: ["gold-generics-001", "gold-secure-coding-018", "gold-secure-coding-019"]
    )

    // MARK: - 文字列 / 参照

    static let stringPool = GlossaryTerm(
        id: "string-pool",
        term: "文字列定数プール",
        aliases: ["string pool", "intern pool", "リテラルプール"],
        summary: "同じ内容のStringリテラルを1つの参照に集約するJVM内部のキャッシュ領域。",
        body: """
**文字列定数プール** は、JVMが `"hello"` などの文字列リテラルをユニーク化して保持する領域です。

```java
String a = "hello";
String b = "hello";
a == b;   // true （プール内で同じ参照）
```

一方、`new String("hello")` は明示的にヒープへ新しいオブジェクトを作るのでプール外になります。

```java
String c = new String("hello");
a == c;         // false
a.equals(c);    // true
```

[== と equals の違い](javasta://term/reference-equals) と合わせて理解しておくと落とし穴を避けられます。
""",
        relatedTermIds: ["reference-equals"],
        relatedLessonIds: [],
        relatedQuizIds: ["silver-string-001"]
    )

    static let referenceEquals = GlossaryTerm(
        id: "reference-equals",
        term: "== と equals",
        aliases: ["参照比較", "内容比較"],
        summary: "`==` は参照の同一性、`equals()` は中身の等価性を比較する。",
        body: """
- `==` は **参照の同一性** （同じオブジェクトか）を比較
- `equals()` は **内容の等価性** （中身が等しいか）を比較

プリミティブ同士の `==` は値比較で問題ありません。参照型（String, Integer等）で中身の等しさを調べたいときは必ず `equals()` を使います。

```java
String a = "hello";
String b = new String("hello");
a == b;        // false（別オブジェクト）
a.equals(b);   // true
```

関連: [文字列定数プール](javasta://term/string-pool)、[Integerキャッシュ](javasta://term/integer-cache)
""",
        relatedTermIds: ["string-pool", "integer-cache"],
        relatedLessonIds: [],
        relatedQuizIds: ["silver-string-001", "silver-autoboxing-001"]
    )

    static let integerCache = GlossaryTerm(
        id: "integer-cache",
        term: "Integerキャッシュ",
        aliases: ["Integer cache", "valueOfキャッシュ"],
        summary: "`Integer.valueOf` が `-128〜127` の範囲で同じインスタンスを再利用する仕組み。",
        body: """
`Integer.valueOf(n)` は `-128 ≤ n ≤ 127` の範囲の値に対して、事前に用意した単一のインスタンスを返します。[オートボクシング](javasta://term/boxing) で `Integer i = 100` と書いたときに内部で呼ばれるのがこれです。

```java
Integer a = 100;   // キャッシュから返る
Integer b = 100;   // 同じインスタンス → a == b は true
Integer c = 200;   // 範囲外 → 新しいインスタンス
Integer d = 200;   // 別インスタンス → c == d は false
```

実務では Wrapper 同士の比較は必ず [equals](javasta://term/reference-equals) を使うのが鉄則。
""",
        relatedTermIds: ["boxing", "reference-equals", "wrapper-class"],
        relatedLessonIds: [],
        relatedQuizIds: ["silver-autoboxing-001"]
    )

    static let wrapperClass = GlossaryTerm(
        id: "wrapper-class",
        term: "ラッパークラス",
        aliases: ["wrapper class", "Integer", "Long", "Double"],
        summary: "プリミティブ型に対応する参照型（Integer, Long, Double, Boolean等）。",
        body: """
**ラッパークラス** は、プリミティブ型をオブジェクトとして扱うためのクラスです。

| プリミティブ | ラッパー |
|-----|-----|
| `int` | `Integer` |
| `long` | `Long` |
| `double` | `Double` |
| `boolean` | `Boolean` |
| `char` | `Character` |

コレクション (`List<Integer>`) やジェネリクス経由で使うときに必要になります。[オートボクシング](javasta://term/boxing) で自動変換されますが、`==` 比較や [Integerキャッシュ](javasta://term/integer-cache) の落とし穴に注意。
""",
        relatedTermIds: ["boxing", "integer-cache"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    // MARK: - 制御フロー

    static let `fallthrough` = GlossaryTerm(
        id: "fallthrough",
        term: "フォールスルー",
        aliases: ["fall-through", "switch break忘れ"],
        summary: "`switch` 文でマッチした case から `break` なく次の case に流れ込む挙動。",
        body: """
従来型の `switch` 文は、case にマッチすると **そのまま次の case の処理へ流れ落ちます**。`break` で明示的に抜けない限り続くのが特徴。

```java
switch (x) {
    case 1: System.out.print("A");
    case 2: System.out.print("B");   // ← break なし
    case 3: System.out.print("C");
        break;
    case 4: System.out.print("D");
}
// x = 2 のとき → "BC"
```

Java 14 以降の新しい **switch式** (`case 2 -> ...`) ではフォールスルーは起きません。新規コードはなるべく switch式で書くのが安全。
""",
        relatedTermIds: [],
        relatedLessonIds: [],
        relatedQuizIds: ["silver-switch-001"]
    )

    // MARK: - 例外

    static let finallyBlock = GlossaryTerm(
        id: "finally",
        term: "finally",
        aliases: ["finallyブロック"],
        summary: "try/catch を抜けるときに必ず実行されるブロック。リソース解放専用。",
        body: """
**finally** ブロックは `try` の後ろに置き、tryやcatchから **どう抜けても必ず実行** されます（return/throw/break/continueを貫通）。

```java
try {
    return 1;
} finally {
    // ここが必ず動く
}
```

落とし穴: finally 内に `return` や `throw` を書くと、tryのreturn値や例外が **上書き** されます。finallyはあくまで **リソース解放** や **ログ出力** に留めるのが原則。

リソース解放は try-with-resources で書けるならそちらが安全。
""",
        relatedTermIds: [],
        relatedLessonIds: ["lesson-finally-and-return"],
        relatedQuizIds: ["silver-exception-001"]
    )

    // MARK: - Stream / ラムダ

    static let streamApi = GlossaryTerm(
        id: "stream",
        term: "Stream API",
        aliases: ["stream", "ストリーム"],
        summary: "コレクションを宣言的に変換・集約するためのAPI。中間操作と終端操作で構成される。",
        body: """
**Stream API** は Java 8 で導入された、コレクションを宣言的に処理するためのAPIです。

一つのストリームは「source → [中間操作](javasta://term/intermediate-operation) ×N → [終端操作](javasta://term/terminal-operation)」というパイプラインで構成されます。

```java
int sum = List.of(1, 2, 3, 4, 5).stream()
    .filter(n -> n % 2 == 0)     // 中間操作
    .mapToInt(Integer::intValue) // 中間操作
    .sum();                      // 終端操作
```

中間操作は [遅延評価](javasta://term/lazy-evaluation) されるため、終端操作が呼ばれるまで実際には動きません。
""",
        relatedTermIds: ["intermediate-operation", "terminal-operation", "lazy-evaluation"],
        relatedLessonIds: [],
        relatedQuizIds: ["gold-stream-001"]
    )

    static let intermediateOp = GlossaryTerm(
        id: "intermediate-operation",
        term: "中間操作",
        aliases: ["intermediate operation"],
        summary: "Streamを変換して別のStreamを返す操作（filter, map, sorted 等）。",
        body: """
**中間操作** は [Stream](javasta://term/stream) に対するパイプラインのビルディングブロックで、新たな Stream を返します。代表例:

- `filter(Predicate)` — 条件を満たす要素のみ通す
- `map(Function)` — 各要素を変換
- `sorted()` — 並べ替え
- `distinct()` — 重複除去

ここで重要なのが [遅延評価](javasta://term/lazy-evaluation)。中間操作は「何をするか」をパイプラインに記録するだけで、終端操作が呼ばれるまで実行されません。
""",
        relatedTermIds: ["stream", "terminal-operation", "lazy-evaluation"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let terminalOp = GlossaryTerm(
        id: "terminal-operation",
        term: "終端操作",
        aliases: ["terminal operation"],
        summary: "Streamを消費して結果を生む操作（sum, collect, forEach 等）。呼ばれて初めてパイプラインが動く。",
        body: """
**終端操作** は [Stream](javasta://term/stream) を消費し、Stream 以外の結果を返します。代表例:

- `sum()` / `count()` / `average()` — 集約
- `collect(Collectors.toList())` — コレクションへ変換
- `forEach(...)` — 副作用的に処理
- `findFirst()` / `anyMatch(...)` — 検索

終端操作が呼ばれた瞬間、積み上げていた [中間操作](javasta://term/intermediate-operation) 群が順に実行されます。ストリームは使い捨てなので、同じ Stream に対して複数回終端操作を呼ぶことはできません。
""",
        relatedTermIds: ["stream", "intermediate-operation", "lazy-evaluation"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let lazyEvaluation = GlossaryTerm(
        id: "lazy-evaluation",
        term: "遅延評価",
        aliases: ["lazy evaluation", "遅延"],
        summary: "値や処理を「必要になるまで走らせない」評価戦略。Streamの中間操作もこれ。",
        body: """
**遅延評価** とは、評価のトリガーが引かれるまで実際の計算を走らせない戦略です。

[Stream](javasta://term/stream) の [中間操作](javasta://term/intermediate-operation) は典型例で、`filter` や `map` を繋げてもその場では何も起きず、[終端操作](javasta://term/terminal-operation) が呼ばれて初めて要素ごとにパイプラインが流れます。

メリット:

- 無駄な計算を省ける（`findFirst` で途中で打ち切れる）
- 無限ストリームも扱える
""",
        relatedTermIds: ["stream", "intermediate-operation", "terminal-operation"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    // MARK: - Optional

    static let optionalType = GlossaryTerm(
        id: "optional",
        term: "Optional",
        aliases: ["java.util.Optional"],
        summary: "「値があるかもしれないし、無いかもしれない」を型で表すコンテナ。nullの安全な代替。",
        body: """
**Optional** は値の有無を型で表現するラッパーで、`null` を撒き散らすコードを安全に書き換えるために Java 8 で導入されました。

生成方法:

- `Optional.of(v)` — `v` が `null` なら即 `NullPointerException`
- `Optional.ofNullable(v)` — `v` が `null` なら空Optionalを返す

操作:

- `map(Function)` — 値があれば変換、なければ何もしない
- `orElse(default)` — 値があればそれ、無ければ `default`
- `orElseThrow()` — 無ければ例外

```java
String r = Optional.ofNullable(s)
    .map(String::toUpperCase)
    .orElse("DEFAULT");
```

フィールド型として Optional を使うのは推奨されません（戻り値型として使うのが本来の用途）。
""",
        relatedTermIds: [],
        relatedLessonIds: [],
        relatedQuizIds: ["gold-optional-001"]
    )

    // MARK: - ジェネリクス

    static let pecs = GlossaryTerm(
        id: "pecs",
        term: "PECS",
        aliases: ["Producer Extends Consumer Super"],
        summary: "Producer Extends, Consumer Super ― ジェネリクスのワイルドカードを選ぶ覚え方。",
        body: """
**PECS** は Effective Java で紹介された有名な指針です。

- **Producer Extends** — 値を **取り出す** 側なら `<? extends T>`
- **Consumer Super** — 値を **入れる** 側なら `<? super T>`

```java
// Producer: 読み取り専用
void sum(List<? extends Number> src)  { for (Number n : src) { ... } }

// Consumer: 書き込み専用
void fill(List<? super Integer> dst)  { dst.add(42); }
```

Javaジェネリクスが [不変](javasta://term/generics-invariance) であるために必要になるテクニック。
""",
        relatedTermIds: ["generics-invariance"],
        relatedLessonIds: ["lesson-bounded-wildcards"],
        relatedQuizIds: ["gold-generics-001", "gold-secure-coding-019"]
    )

    // MARK: - OOP基礎

    static let classAndObject = GlossaryTerm(
        id: "class-object",
        term: "クラスとオブジェクト",
        aliases: ["class", "object", "インスタンス"],
        summary: "クラスはオブジェクトの設計図。`new` でインスタンス（オブジェクト）を生成する。",
        body: """
**クラス** はフィールド（状態）とメソッド（振る舞い）をまとめた設計図です。`new` キーワードでヒープ上にインスタンスを生成します。

```java
class Dog {
    String name;
    void bark() { System.out.println("Woof!"); }
}
Dog d = new Dog();
d.name = "Pochi";
d.bark();
```

変数 `d` は実体ではなく **参照**（アドレス）を保持します。これが [== と equals](javasta://term/reference-equals) の挙動に直結します。
""",
        relatedTermIds: ["object-class", "constructor", "reference-equals", "null"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let objectClassTerm = GlossaryTerm(
        id: "object-class",
        term: "Objectクラス",
        aliases: ["java.lang.Object", "Object", "equals", "hashCode", "toString", "getClass"],
        summary: "Javaの全クラスの共通の親。`equals`、`hashCode`、`toString`、`getClass` などの基本メソッドを持つ。",
        body: """
`Object` はJavaの全クラスのルートにあるクラスです。明示的に `extends` を書かないクラスも、最終的には `Object` を継承しています。

よく問われるメソッド:

- `equals(Object obj)`: デフォルトでは参照同一性を比較する。値比較にしたい場合はオーバーライドする
- `hashCode()`: ハッシュ系コレクションで使われる。`equals` をオーバーライドするなら通常こちらも合わせる
- `toString()`: オブジェクトの文字列表現。`String` など多くのクラスがオーバーライドしている
- `getClass()`: 実行時クラスを返すfinalメソッド

```java
Object value = "Java";
System.out.println(value.getClass().getSimpleName()); // String
System.out.println(value.toString());                 // Java
```

`equals(Key other)` のように引数型を変えると、`equals(Object)` のオーバーライドではなくオーバーロードになります。試験ではここがかなり狙われます。
""",
        relatedTermIds: ["class-object", "inheritance", "override", "reference-equals", "collections"],
        relatedLessonIds: [],
        relatedQuizIds: ["silver-object-001", "silver-object-002", "gold-object-003", "gold-object-004"]
    )

    static let constructor = GlossaryTerm(
        id: "constructor",
        term: "コンストラクタ",
        aliases: ["constructor", "コンストラクター"],
        summary: "オブジェクト生成時に呼ばれる初期化専用のメソッド。クラス名と同じ名前で戻り値なし。",
        body: """
**コンストラクタ** はクラスと同名で戻り値のない特殊なメソッドで、`new` 時に自動で呼ばれます。

```java
class Point {
    int x, y;
    Point(int x, int y) {
        this.x = x;
        this.y = y;
    }
}
```

**デフォルトコンストラクタ**: 何も書かなければ引数なしが自動生成されます。ただし独自コンストラクタを1つでも書くとデフォルトは生成されません。

**コンストラクタチェーン**: `this(...)` で同クラスの別コンストラクタ、`super(...)` で親コンストラクタを呼べます。
""",
        relatedTermIds: ["class-object", "inheritance", "static-keyword"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let inheritance = GlossaryTerm(
        id: "inheritance",
        term: "継承",
        aliases: ["extends", "サブクラス", "スーパークラス"],
        summary: "既存クラスの機能を引き継いで新しいクラスを作る仕組み。`extends` で宣言。",
        body: """
**継承** は `extends` キーワードで既存クラス（スーパークラス）の機能をそのまま引き継いだ新クラス（サブクラス）を作る仕組みです。

```java
class Animal { void eat() { ... } }
class Dog extends Animal {
    void bark() { ... }  // 追加
}
```

Javaのクラス継承は **単一継承**（親は1つ）。複数の型を実装したい場合は [インターフェース](javasta://term/interface) を使います。

サブクラスのコンストラクタは `super()` で親コンストラクタを呼ぶ必要があります（明示しなければ暗黙で呼ばれます）。

[オーバーライド](javasta://term/override)と合わせて、[ポリモーフィズム](javasta://term/polymorphism)の基盤になります。
""",
        relatedTermIds: ["override", "polymorphism", "interface", "abstract-class"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let override = GlossaryTerm(
        id: "override",
        term: "オーバーライド",
        aliases: ["@Override", "メソッドオーバーライド"],
        summary: "親クラスのメソッドをサブクラスで再定義すること。動的束縛の対象になる。",
        body: """
**オーバーライド** とは、スーパークラスで定義されたインスタンスメソッドをサブクラスで再定義することです。`@Override` アノテーションを付けるとコンパイラがチェックします（推奨）。

```java
class Animal { String sound() { return "..."; } }
class Cat extends Animal {
    @Override
    String sound() { return "Meow"; }
}
```

オーバーライドは [動的束縛](javasta://term/dynamic-binding) の対象で、参照型ではなく実際のオブジェクトの型で決まります。

[オーバーロード](javasta://term/overload)（同名別シグネチャ）と混同しないよう注意。
""",
        relatedTermIds: ["dynamic-binding", "inheritance", "overload", "annotation"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let polymorphism = GlossaryTerm(
        id: "polymorphism",
        term: "ポリモーフィズム",
        aliases: ["多態性", "多相性", "polymorphism"],
        summary: "同じ型の変数で異なるクラスのオブジェクトを扱い、実際の型に応じた動作をさせる仕組み。",
        body: """
**ポリモーフィズム**（多態性）は、スーパークラスや[インターフェース](javasta://term/interface)の参照変数で、異なるサブクラスのインスタンスを扱える仕組みです。

```java
Animal a = new Dog();
Animal b = new Cat();
a.sound();  // → Dogの実装
b.sound();  // → Catの実装
```

これが機能するのは [動的束縛](javasta://term/dynamic-binding) のおかげ。[継承](javasta://term/inheritance)と[オーバーライド](javasta://term/override)によって成立します。

ポリモーフィズムを使うとコードの切り替え（switch/if分岐）を減らし、拡張性の高い設計ができます。
""",
        relatedTermIds: ["dynamic-binding", "inheritance", "override", "interface"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let encapsulation = GlossaryTerm(
        id: "encapsulation",
        term: "カプセル化",
        aliases: ["encapsulation", "情報隠蔽"],
        summary: "フィールドを `private` にして外部から直接アクセスさせず、メソッド経由で操作させる設計原則。",
        body: """
**カプセル化** は、クラス内部のフィールドを `private` で隠蔽し、`getter`/`setter` などのメソッド経由でのみアクセスを許す設計原則です。

```java
class BankAccount {
    private int balance;              // 直接触れない
    void deposit(int amount) {
        if (amount > 0) balance += amount;  // バリデーション込み
    }
    int getBalance() { return balance; }
}
```

外部から直接 `balance` を書き換えられないので、不正な状態を防げます。[アクセス修飾子](javasta://term/access-modifier)と密接に関係します。
""",
        relatedTermIds: ["access-modifier", "class-object"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let abstractClass = GlossaryTerm(
        id: "abstract-class",
        term: "抽象クラス",
        aliases: ["abstract class", "abstract"],
        summary: "`abstract` 修飾子を持ち、直接インスタンス化できないクラス。未実装のメソッドを持てる。",
        body: """
**抽象クラス** は `abstract` キーワードで宣言され、インスタンスを直接生成できません。抽象メソッド（本体なし）を持てるのが特徴。

```java
abstract class Shape {
    abstract double area();       // サブクラスが実装する
    void print() {                // 実装済みメソッドも持てる
        System.out.println(area());
    }
}
class Circle extends Shape {
    double r;
    @Override double area() { return Math.PI * r * r; }
}
```

[インターフェース](javasta://term/interface)との違い:

| | 抽象クラス | インターフェース |
|---|---|---|
| 継承 | 単一 | 複数実装可 |
| フィールド | 任意 | `public static final` のみ |
| コンストラクタ | 持てる | 持てない |
""",
        relatedTermIds: ["interface", "inheritance", "override"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let interfaceTerm = GlossaryTerm(
        id: "interface",
        term: "インターフェース",
        aliases: ["interface", "implements"],
        summary: "実装の約束ごとを定義する型。クラスは複数のインターフェースを実装できる。",
        body: """
**インターフェース** は、クラスが実装すべきメソッドのシグネチャを定義する型です。Java 8以降は `default` メソッド（実装あり）や `static` メソッドも持てます。

```java
interface Flyable {
    void fly();
    default void land() { System.out.println("Landing"); }
}
class Bird implements Flyable {
    @Override public void fly() { ... }
}
```

クラスは `implements` で複数のインターフェースを実装できます（多重継承の代替）。

[関数型インターフェース](javasta://term/functional-interface)（`@FunctionalInterface`）は[ラムダ式](javasta://term/lambda)で使われます。
""",
        relatedTermIds: ["abstract-class", "functional-interface", "lambda", "polymorphism"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let staticKeyword = GlossaryTerm(
        id: "static-keyword",
        term: "static",
        aliases: ["static修飾子", "クラスメソッド", "クラス変数"],
        summary: "インスタンスではなくクラスに属するフィールド・メソッドを宣言するキーワード。",
        body: """
`static` を付けたフィールド・メソッドは、インスタンスではなく **クラス** に属します。

```java
class Counter {
    static int count = 0;      // 全インスタンス共有
    Counter() { count++; }
    static int getCount() { return count; }
}
Counter.getCount();  // インスタンスなしで呼べる
```

staticメソッドからは `this` や非staticメンバーにアクセスできません。[静的束縛](javasta://term/static-binding)の対象なのでオーバーライドも不可（隠蔽は可能）。

`static` 初期化ブロックはクラスロード時に一度だけ実行されます。
""",
        relatedTermIds: ["static-binding", "entry-point", "object-class"],
        relatedLessonIds: [],
        relatedQuizIds: ["silver-static-001", "silver-static-002", "silver-static-003", "silver-static-004", "gold-static-005", "gold-static-006"]
    )

    static let finalKeyword = GlossaryTerm(
        id: "final-keyword",
        term: "final",
        aliases: ["final修飾子"],
        summary: "変数なら再代入不可、メソッドならオーバーライド不可、クラスなら継承不可を意味するキーワード。",
        body: """
`final` はコンテキストによって意味が変わります。

| 対象 | 意味 |
|---|---|
| ローカル変数 / フィールド | 一度代入したら変更不可 |
| メソッド | サブクラスでオーバーライドできない |
| クラス | 継承できない（`String` など）|

```java
final int MAX = 100;
MAX = 200;  // コンパイルエラー
```

`final` フィールドはコンストラクタ内で初期化できます。`static final` は定数として使われることが多い（`PI` など）。
""",
        relatedTermIds: ["inheritance", "override", "static-keyword"],
        relatedLessonIds: [],
        relatedQuizIds: ["silver-final-001", "silver-final-002", "silver-final-003"]
    )

    static let instanceofTerm = GlossaryTerm(
        id: "instanceof",
        term: "instanceof",
        aliases: ["型チェック", "パターンマッチ"],
        summary: "オブジェクトが特定の型のインスタンスかを判定する演算子。Java 16以降はパターンマッチングに対応。",
        body: """
`instanceof` は実行時に型チェックを行う演算子です。

```java
Object obj = "hello";
if (obj instanceof String) {
    System.out.println("文字列です");
}
```

**Java 16以降のパターンマッチング**:

```java
if (obj instanceof String s) {
    System.out.println(s.length());  // sを直接使える
}
```

`null` に対しては常に `false` を返します。[キャスト](javasta://term/casting)と組み合わせて使われることが多いが、パターンマッチングでキャストが不要になりました。
""",
        relatedTermIds: ["casting", "polymorphism"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let castingTerm = GlossaryTerm(
        id: "casting",
        term: "キャスト",
        aliases: ["型変換", "ダウンキャスト", "アップキャスト"],
        summary: "参照型や数値型を別の型に変換すること。アップキャストは安全、ダウンキャストは実行時に失敗しうる。",
        body: """
**キャスト** は型変換です。大きく2種類あります。

**アップキャスト**（自動）: サブクラス → スーパークラス。安全なので自動で行われます。

```java
Dog d = new Dog();
Animal a = d;   // アップキャスト（自動）
```

**ダウンキャスト**（明示）: スーパークラス → サブクラス。実際の型が合わない場合 `ClassCastException` が発生します。

```java
Animal a = new Cat();
Dog d = (Dog) a;  // ClassCastException！実体はCat
```

事前に [instanceof](javasta://term/instanceof) で型を確認するのが安全です。
""",
        relatedTermIds: ["instanceof", "polymorphism", "dynamic-binding"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let nullTerm = GlossaryTerm(
        id: "null",
        term: "null",
        aliases: ["NullPointerException", "NPE"],
        summary: "参照型変数が「何も指していない」ことを表す特殊な値。アクセスすると NullPointerException になる。",
        body: """
`null` は参照型変数が何のオブジェクトも指していないことを示す特殊な値です。

```java
String s = null;
s.length();  // NullPointerException!
```

`null` に対して `==` 比較は有効ですが、メソッド呼び出しは全て NPE になります。

**対策**:

- [Optional](javasta://term/optional) で null を型として表現する
- `Objects.requireNonNull()` で早期に検出する
- 入力値のバリデーションで null を弾く

Java 14以降では NPE のメッセージが詳細になり、どの変数が null だったかを示します。
""",
        relatedTermIds: ["optional", "reference-equals"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let varArgs2 = GlossaryTerm(
        id: "varargs",
        term: "可変長引数",
        aliases: ["varargs", "variable arguments"],
        summary: "`型... 名` の構文で任意個の引数を配列として受け取れる機能。",
        body: """
**可変長引数** は、メソッド宣言で `String...` のように書くことで、任意個の引数を受け取れる機能です。受け取り側では配列として扱われます。

```java
static void log(String... messages) {
    for (String m : messages) System.out.println(m);
}
log("a", "b", "c");
```

[オーバーロード](javasta://term/overload)解決では最後の手段として扱われ、他のすべてが該当しない場合のみ選ばれます。
""",
        relatedTermIds: ["overload"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let varLocalType = GlossaryTerm(
        id: "var",
        term: "var（ローカル型推論）",
        aliases: ["local variable type inference", "var"],
        summary: "Java 10以降。ローカル変数の型をコンパイラが推論してくれるキーワード。",
        body: """
`var` はローカル変数宣言時の型をコンパイラが右辺から推論するキーワードです（Java 10〜）。

```java
var list = new ArrayList<String>();  // ArrayList<String> と推論
var i = 42;                          // int と推論
```

**使える場所**: ローカル変数のみ。フィールド、パラメータ、戻り値型には使えません。

**注意**: `null` で初期化すると型が確定しないのでコンパイルエラー。

型を明示したほうが読みやすい場面では使わないのが良い習慣です。
""",
        relatedTermIds: ["compile"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    // MARK: - アクセス制御・構造

    static let accessModifier = GlossaryTerm(
        id: "access-modifier",
        term: "アクセス修飾子",
        aliases: ["public", "protected", "private", "package-private"],
        summary: "クラス・フィールド・メソッドの可視範囲を制御するキーワード。",
        body: """
Javaのアクセス修飾子は4種類あり、スコープが広い順に並べます。

| 修飾子 | 同クラス | 同パッケージ | サブクラス | 他 |
|---|---|---|---|---|
| `public` | ✓ | ✓ | ✓ | ✓ |
| `protected` | ✓ | ✓ | ✓ | — |
| （なし）| ✓ | ✓ | — | — |
| `private` | ✓ | — | — | — |

（なし）は **パッケージプライベート** と呼ばれます。

[カプセル化](javasta://term/encapsulation)の観点から、フィールドは原則 `private`、必要なものだけ公開するのが基本です。
""",
        relatedTermIds: ["encapsulation", "package"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let packageTerm = GlossaryTerm(
        id: "package",
        term: "パッケージ",
        aliases: ["package", "パッケージ宣言"],
        summary: "クラスを名前空間でグループ化する仕組み。ディレクトリ構造と対応する。",
        body: """
**パッケージ** は複数のクラスを名前空間でまとめる仕組みで、クラスの識別と[アクセス制御](javasta://term/access-modifier)に使われます。

```java
package com.example.app;   // ファイル先頭に宣言
```

ディレクトリ構造と一致させる必要があります（`com/example/app/MyClass.java`）。

**デフォルトパッケージ**: `package` 宣言がないクラスはデフォルトパッケージに属しますが、本番コードでは使用を避けます。

`java.lang` パッケージ（String, System 等）は自動でインポートされます。
""",
        relatedTermIds: ["access-modifier", "import"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let importTerm = GlossaryTerm(
        id: "import",
        term: "import",
        aliases: ["import文", "static import"],
        summary: "他パッケージのクラスを短い名前で使えるようにする宣言。",
        body: """
`import` 文を使うと、別パッケージのクラスをフルパスなしで参照できます。

```java
import java.util.ArrayList;
import java.util.*;   // パッケージ全体（非推奨）
```

**static import**: クラス名なしで静的メンバーを参照できます。

```java
import static java.lang.Math.PI;
import static java.lang.Math.*;
double area = PI * r * r;
```

`import` はコンパイル時の糖衣構文にすぎず、実行時には影響しません。
""",
        relatedTermIds: ["package"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    // MARK: - 例外

    static let tryWithResources = GlossaryTerm(
        id: "try-with-resources",
        term: "try-with-resources",
        aliases: ["AutoCloseable", "リソース解放"],
        summary: "try文でリソースを宣言すると、ブロック終了時に自動的に `close()` が呼ばれる構文（Java 7〜）。",
        body: """
`try-with-resources` は `AutoCloseable` を実装したリソースを自動クローズする構文です。

```java
try (BufferedReader br = new BufferedReader(new FileReader("file.txt"))) {
    return br.readLine();
} // br.close() が自動で呼ばれる
```

`finally` で手動クローズする古いコードより安全で簡潔。例外が発生してもリソースを確実に解放します。

複数のリソースはセミコロンで区切れます。宣言と逆順に `close()` されます。
""",
        relatedTermIds: ["finally", "suppressed-exception", "secure-coding"],
        relatedLessonIds: [],
        relatedQuizIds: ["gold-exception-008", "gold-exception-009", "gold-exception-013", "gold-secure-coding-001", "gold-secure-coding-002", "gold-secure-coding-003"]
    )

    static let suppressedExceptionTerm = GlossaryTerm(
        id: "suppressed-exception",
        term: "抑制例外",
        aliases: ["suppressed exception", "getSuppressed", "try-with-resources"],
        summary: "try-with-resourcesで主例外がある状態でclose例外も起きたとき、close側が主例外に添付される仕組み。",
        body: """
**抑制例外** は、主例外がすでに発生している状態で、リソース解放中にも別の例外が発生したときに使われます。

```java
try (R r = new R()) {
    throw new RuntimeException("body");
} // close() でも RuntimeException("close")
```

この場合、呼び出し元へ届く主例外は `body` です。`close` 例外は消えるのではなく、主例外の `getSuppressed()` から取り出せます。

複数リソースは宣言と逆順にcloseされるため、抑制例外の並びもclose順を追う必要があります。
""",
        relatedTermIds: ["try-with-resources", "finally", "checked-unchecked"],
        relatedLessonIds: [],
        relatedQuizIds: ["gold-exception-008", "gold-exception-009"]
    )

    static let serializationTerm = GlossaryTerm(
        id: "serialization",
        term: "シリアライズ",
        aliases: ["Serializable", "transient", "readObject", "ObjectInputFilter"],
        summary: "オブジェクトをバイト列に変換・復元する仕組み。外部入力として扱い、復元時の検証が重要。",
        body: """
**シリアライズ** は、オブジェクトをバイト列として保存・送受信し、あとで復元する仕組みです。

基本:

- `Serializable` を実装したクラスが対象
- `transient` フィールドは保存されず、復元後はデフォルト値になる
- `readObject` で `defaultReadObject()` 後に不変条件を検証できる
- `ObjectInputFilter` で想定外の型や大きすぎる入力を拒否できる

デシリアライズは外部入力をオブジェクトとして復元する処理なので、ただ読み込むだけではなく「復元後に安全な状態か」を確認するのが重要です。
""",
        relatedTermIds: ["secure-coding", "checked-unchecked"],
        relatedLessonIds: [],
        relatedQuizIds: ["gold-secure-coding-011", "gold-secure-coding-012", "gold-secure-coding-013"]
    )

    static let assertionTerm = GlossaryTerm(
        id: "assertion",
        term: "アサーション",
        aliases: ["assert", "AssertionError", "-ea", "-da"],
        summary: "`assert 条件;` で内部前提を検査する仕組み。通常起動では無効で、公開入力検証には使わない。",
        body: """
**アサーション** は、開発中に「ここでは必ず成り立つはず」という内部前提を検査するための仕組みです。

```java
assert count >= 0 : "count must not be negative";
```

起動オプション:

- `-ea`: assertionを有効化
- `-da`: assertionを無効化

assertが無効な場合、条件式も詳細式も評価されません。副作用を持つ式を書いたり、公開メソッドの引数検証をassertだけで済ませたりすると危険です。外部入力の検証には通常の `if` と適切な例外を使います。
""",
        relatedTermIds: ["secure-coding", "checked-unchecked"],
        relatedLessonIds: [],
        relatedQuizIds: ["gold-secure-coding-004", "gold-secure-coding-005", "gold-secure-coding-006", "gold-secure-coding-007", "gold-secure-coding-008"]
    )

    static let checkedUnchecked = GlossaryTerm(
        id: "checked-unchecked",
        term: "検査例外 / 非検査例外",
        aliases: ["checked exception", "unchecked exception", "RuntimeException"],
        summary: "検査例外はコンパイル時に処理が義務付けられる。非検査例外（RuntimeException系）はその義務がない。",
        body: """
Javaの例外は大きく2種類あります。

**検査例外（Checked Exception）**: `Exception` の直接サブクラス。メソッド呼び出し側が `try-catch` か `throws` 宣言を強制されます。

```java
void readFile() throws IOException { ... }
```

**非検査例外（Unchecked Exception）**: `RuntimeException` のサブクラス。コンパイラの強制なし。`NullPointerException`、`ArrayIndexOutOfBoundsException`、`ClassCastException` など。

```java
int[] arr = new int[3];
arr[5] = 1;  // ArrayIndexOutOfBoundsException（実行時）
```

業務ロジックのエラーには検査例外、プログラムのバグには非検査例外、が基本的な使い分けです。
""",
        relatedTermIds: ["finally", "try-with-resources", "suppressed-exception", "assertion", "serialization"],
        relatedLessonIds: [],
        relatedQuizIds: ["silver-exception-006", "silver-exception-007", "gold-exception-007", "gold-exception-011", "gold-exception-012", "gold-exception-014", "gold-exception-015", "gold-exception-016", "gold-exception-017", "gold-exception-018", "gold-exception-019", "gold-exception-020", "gold-secure-coding-005", "gold-secure-coding-012", "gold-secure-coding-013", "gold-secure-coding-015", "gold-secure-coding-017", "gold-secure-coding-018", "gold-secure-coding-020"]
    )

    // MARK: - コレクション

    static let collectionsFramework = GlossaryTerm(
        id: "collections",
        term: "コレクションフレームワーク",
        aliases: ["Collection", "List", "Set", "Map"],
        summary: "データ構造（リスト・セット・マップ等）を統一的に扱うAPIセット。`java.util` パッケージ。",
        body: """
Javaの **コレクションフレームワーク** は `java.util` パッケージにあり、主なインターフェースは以下の通りです。

- `List` — 順序あり・重複OK（[ArrayList](javasta://term/arraylist)、LinkedList）
- `Set` — 順序なし（実装依存）・重複NG（HashSet、LinkedHashSet、TreeSet）
- `Map` — キーと値のペア（[HashMap](javasta://term/hashmap)、TreeMap、LinkedHashMap）
- `Queue` / `Deque` — キュー・両端キュー

共通のユーティリティは `Collections` クラスに静的メソッドとして提供されます（`sort`, `shuffle`, `unmodifiableList` 等）。
""",
        relatedTermIds: ["arraylist", "hashmap", "iterator", "generics-invariance", "secure-coding"],
        relatedLessonIds: [],
        relatedQuizIds: ["gold-secure-coding-016", "gold-secure-coding-017", "gold-secure-coding-020"]
    )

    static let arrayListTerm = GlossaryTerm(
        id: "arraylist",
        term: "ArrayList",
        aliases: ["動的配列", "List実装"],
        summary: "動的にサイズが変わる配列ベースの `List` 実装。ランダムアクセスが高速。",
        body: """
`ArrayList` は内部で配列を使う `List` 実装です。

```java
List<String> list = new ArrayList<>();
list.add("Java");
list.add("Silver");
list.get(0);    // "Java"（O(1)）
list.remove(0); // 後続要素がシフト（O(n)）
```

**特徴**:
- ランダムアクセス `get(i)` が O(1)
- 末尾への追加は均し O(1)（容量超過時に再確保）
- 途中への挿入・削除は O(n)

`LinkedList` との使い分け: 読み取り中心なら `ArrayList`、先頭・中間の挿入削除が多いなら `LinkedList`。

ただし `LinkedList` は参照ポインタのオーバーヘッドがあるため、現代では `ArrayList` のほうが一般的に高速です。
""",
        relatedTermIds: ["collections", "iterator"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let hashMapTerm = GlossaryTerm(
        id: "hashmap",
        term: "HashMap",
        aliases: ["Map", "ハッシュマップ", "キーと値"],
        summary: "キーと値のペアを管理する `Map` 実装。検索・追加・削除が平均 O(1)。順序は保証しない。",
        body: """
`HashMap` はハッシュテーブルを使った `Map` 実装です。

```java
Map<String, Integer> map = new HashMap<>();
map.put("apple", 1);
map.put("banana", 2);
map.get("apple");           // 1
map.getOrDefault("grape", 0); // 0（未登録のデフォルト値）
```

**特徴**:
- `put` / `get` / `containsKey` が平均 O(1)
- 挿入順を保持しない（順序が必要なら `LinkedHashMap`）
- キーの重複は上書き、値の重複は許容

**null の扱い**: キーに `null` を1つ、値は複数 `null` を持てます。

スレッドセーフが必要なら `ConcurrentHashMap` を使います。
""",
        relatedTermIds: ["collections", "reference-equals"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let mapComputeIfAbsentTerm = GlossaryTerm(
        id: "map-compute-if-absent",
        term: "Map.computeIfAbsent",
        aliases: ["computeIfAbsent", "Map初期化", "遅延作成"],
        summary: "キーが未登録のときだけ値を作り、既存値があればそれを返すMapの便利メソッド。",
        body: """
`computeIfAbsent` は、Mapにキーがないときだけ関数を実行して値を作ります。既にキーがある場合は、既存値をそのまま返します。

```java
Map<String, List<Integer>> map = new HashMap<>();
map.computeIfAbsent("A", k -> new ArrayList<>()).add(1);
map.computeIfAbsent("A", k -> new ArrayList<>()).add(2);

map.get("A"); // [1, 2]
```

試験では「2回目にも新しいListが作られる」と誤解しやすい点が狙われます。キーが存在する限り、ラムダは実行されません。
""",
        relatedTermIds: ["hashmap", "collections", "lambda"],
        relatedLessonIds: [],
        relatedQuizIds: ["gold-collections-005"]
    )

    static let iteratorTerm = GlossaryTerm(
        id: "iterator",
        term: "Iterator",
        aliases: ["反復子", "hasNext", "next"],
        summary: "コレクションの要素を順に取り出すインターフェース。拡張for文の内部でも使われる。",
        body: """
`Iterator` はコレクションを走査するインターフェースです。`hasNext()` と `next()` の2メソッドが中心。

```java
List<String> list = List.of("a", "b", "c");
Iterator<String> it = list.iterator();
while (it.hasNext()) {
    System.out.println(it.next());
}
```

実際には **拡張 for 文**（for-each）が `Iterator` を内部で使っています。

```java
for (String s : list) { ... }
```

`Iterator.remove()` を使うと走査中に安全に要素を削除できます（直接 `list.remove()` を呼ぶと `ConcurrentModificationException` になる）。
""",
        relatedTermIds: ["collections", "arraylist"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let comparableTerm = GlossaryTerm(
        id: "comparable",
        term: "Comparable",
        aliases: ["compareTo", "自然順序", "Comparable<T>"],
        summary: "クラス自身が「自然な順序」を定義するインターフェース。`compareTo` を実装する。",
        body: """
`Comparable<T>` は「自然な順序」をクラス自身が定義するインターフェースで、`compareTo` を実装します。

```java
class Student implements Comparable<Student> {
    int score;
    @Override public int compareTo(Student other) {
        return this.score - other.score;  // 昇順
    }
}
```

`Collections.sort()` や `TreeSet` は `Comparable` を使って並べます。

`compareTo` の戻り値の約束:
- 負: `this < other`
- 0: `this == other`
- 正: `this > other`

複数の基準で並べたい場合は [Comparator](javasta://term/comparator) を使います。
""",
        relatedTermIds: ["comparator", "collections"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let comparatorTerm = GlossaryTerm(
        id: "comparator",
        term: "Comparator",
        aliases: ["compare", "外部比較器", "Comparator<T>"],
        summary: "クラスの外部から比較ロジックを定義する関数型インターフェース。ラムダ式と相性がよい。",
        body: """
`Comparator<T>` はクラスの外から比較ロジックを定義する[関数型インターフェース](javasta://term/functional-interface)です。

```java
// ラムダ式で定義
Comparator<Student> byScore = (a, b) -> a.score - b.score;

// メソッド参照 + チェーン
List<Student> sorted = students.stream()
    .sorted(Comparator.comparing(Student::getName)
                      .thenComparingInt(Student::getScore))
    .toList();
```

[Comparable](javasta://term/comparable)が「自然な順序1つ」なのに対し、`Comparator` は「複数の並び方を外部で定義」できる柔軟性があります。
""",
        relatedTermIds: ["comparable", "functional-interface", "lambda", "stream"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    // MARK: - 文字列

    static let stringBuilderTerm = GlossaryTerm(
        id: "string-builder",
        term: "StringBuilder",
        aliases: ["StringBuffer", "文字列結合", "append"],
        summary: "可変の文字列バッファ。ループ内での文字列結合は `String +` より大幅に高速。",
        body: """
`String` は不変（immutable）なので `+` で結合するたびに新しいオブジェクトが生成されます。ループ内での結合は `StringBuilder` を使うべきです。

```java
// 非推奨（毎回新しいStringオブジェクト）
String result = "";
for (int i = 0; i < 100; i++) result += i;

// 推奨
StringBuilder sb = new StringBuilder();
for (int i = 0; i < 100; i++) sb.append(i);
String result = sb.toString();
```

主なメソッド: `append()`, `insert()`, `delete()`, `reverse()`, `toString()`

スレッドセーフが必要なら `StringBuffer`（ただし低速）を使います。単一スレッドでは `StringBuilder` 一択。
""",
        relatedTermIds: ["string-pool"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    // MARK: - 関数型

    static let lambdaTerm = GlossaryTerm(
        id: "lambda",
        term: "ラムダ式",
        aliases: ["lambda expression", "アロー演算子", "->"],
        summary: "匿名関数を簡潔に書くための構文（Java 8〜）。関数型インターフェースの実装に使う。",
        body: """
**ラムダ式** は [関数型インターフェース](javasta://term/functional-interface) の無名実装を簡潔に書く構文です。

```java
// 従来の匿名クラス
Runnable r = new Runnable() {
    @Override public void run() { System.out.println("Hello"); }
};

// ラムダ式
Runnable r = () -> System.out.println("Hello");
```

**書き方のバリエーション**:

```java
(x) -> x * 2           // 引数1つ、式1つ
x -> x * 2             // 括弧省略可
(a, b) -> a + b        // 引数2つ
(x) -> { return x; }  // 複数文はブロック必須
```

[メソッド参照](javasta://term/method-reference)でさらに短く書ける場合があります。
""",
        relatedTermIds: ["functional-interface", "method-reference", "stream"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let functionalInterface = GlossaryTerm(
        id: "functional-interface",
        term: "関数型インターフェース",
        aliases: ["@FunctionalInterface", "SAM", "Runnable", "Predicate", "Function", "Consumer", "Supplier"],
        summary: "抽象メソッドが1つだけのインターフェース。ラムダ式やメソッド参照で実装できる。",
        body: """
**関数型インターフェース** は抽象メソッドが1つだけのインターフェースです。`@FunctionalInterface` を付けると複数の抽象メソッドがあればコンパイルエラーになります。

`java.util.function` パッケージの代表的なもの:

| インターフェース | シグネチャ | 用途 |
|---|---|---|
| `Predicate<T>` | `T → boolean` | 条件判定 |
| `Function<T,R>` | `T → R` | 変換 |
| `Consumer<T>` | `T → void` | 副作用 |
| `Supplier<T>` | `() → T` | 生成 |
| `BiFunction<T,U,R>` | `(T,U) → R` | 2引数変換 |

```java
Predicate<String> isLong = s -> s.length() > 5;
isLong.test("hello");   // false
```
""",
        relatedTermIds: ["lambda", "method-reference", "interface"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let methodReference = GlossaryTerm(
        id: "method-reference",
        term: "メソッド参照",
        aliases: ["method reference", "::", "コロンコロン"],
        summary: "既存のメソッドをラムダ式の代わりに `クラス::メソッド名` 形式で渡す構文。",
        body: """
**メソッド参照** は [ラムダ式](javasta://term/lambda) をさらに短く書ける構文で、`::` を使います。

4種類あります。

| 種類 | 書き方 | 等価なラムダ |
|---|---|---|
| 静的メソッド | `Integer::parseInt` | `s -> Integer.parseInt(s)` |
| インスタンス（任意） | `String::toUpperCase` | `s -> s.toUpperCase()` |
| インスタンス（特定） | `obj::method` | `x -> obj.method(x)` |
| コンストラクタ | `ArrayList::new` | `() -> new ArrayList<>()` |

```java
List<String> words = List.of("b", "a", "c");
words.stream().sorted(String::compareTo).toList();
```
""",
        relatedTermIds: ["lambda", "functional-interface", "stream"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    // MARK: - 制御フロー追加

    static let switchExpression = GlossaryTerm(
        id: "switch-expression",
        term: "switch式",
        aliases: ["switch expression", "->", "yield"],
        summary: "Java 14で正式化。`case ->` 構文でフォールスルーなし・値を返せる式としてのswitch。",
        body: """
Java 14以降の **switch式** は、従来の `switch文` の問題（[フォールスルー](javasta://term/fallthrough)、値を返せない）を解決します。

```java
String result = switch (day) {
    case MONDAY, FRIDAY -> "平日";
    case SATURDAY, SUNDAY -> "週末";
    default -> "その他";
};
```

複数文が必要な場合は `yield` で値を返します。

```java
int val = switch (x) {
    case 1 -> 10;
    case 2 -> {
        int r = compute(x);
        yield r * 2;
    }
    default -> 0;
};
```

`->` 構文ではフォールスルーは発生しません。
""",
        relatedTermIds: ["fallthrough"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    // MARK: - ローカライズ・フォーマット

    static let localeTerm = GlossaryTerm(
        id: "locale",
        term: "Locale",
        aliases: ["ロケール", "language tag", "BCP 47", "Locale.US", "Locale.JAPAN"],
        summary: "言語・地域・文化圏を表す設定。数値、通貨、日付、メッセージ選択に影響する。",
        body: """
`Locale` は、言語や地域を表すオブジェクトです。

```java
Locale us = Locale.US;                 // en_US
Locale br = Locale.forLanguageTag("pt-BR");
Locale tag = new Locale.Builder()
    .setLanguage("en")
    .setRegion("US")
    .build();
```

ポイント:

- `getLanguage()` は言語コード、`getCountry()` は国/地域コードを返す
- `toString()` は `en_US` のようなアンダースコア形式
- `toLanguageTag()` は `en-US` のようなハイフン形式
- [フォーマット](javasta://term/formatting)や[ResourceBundle](javasta://term/resource-bundle)の選択に使われる

デフォルトLocaleに頼ると実行環境で結果が変わるため、試験問題では明示されたLocaleを優先して読むのが大事です。
""",
        relatedTermIds: ["formatting", "resource-bundle"],
        relatedLessonIds: [],
        relatedQuizIds: ["gold-localization-001", "gold-localization-002", "gold-localization-003", "gold-localization-004", "gold-localization-005", "gold-localization-006", "gold-localization-010", "gold-localization-015", "gold-localization-022", "gold-localization-023", "gold-localization-024"]
    )

    static let resourceBundleTerm = GlossaryTerm(
        id: "resource-bundle",
        term: "ResourceBundle",
        aliases: ["リソースバンドル", "ListResourceBundle", "MissingResourceException"],
        summary: "Localeに応じてメッセージや設定値を切り替える仕組み。候補Localeと親バンドルを順に探す。",
        body: """
`ResourceBundle` は、Localeごとにメッセージや設定値を切り替える仕組みです。

```java
ResourceBundle rb = ResourceBundle.getBundle("Messages", Locale.JAPAN);
String title = rb.getString("title");
```

探索の考え方:

- `ja_JP` なら `Messages_ja_JP`、`Messages_ja`、`Messages` のように候補を探す
- 子バンドルにキーがなければ親バンドルを探す
- キーがどこにもなければ `MissingResourceException`
- `ListResourceBundle` ではString以外のObject値も扱える

メッセージ内に `{0}` のような差し込みがある場合、ResourceBundleはパターンを返すだけです。実際の置換は[MessageFormat](javasta://term/formatting)で行います。
""",
        relatedTermIds: ["locale", "formatting"],
        relatedLessonIds: [],
        relatedQuizIds: ["gold-localization-001", "gold-localization-002", "gold-localization-007", "gold-localization-008", "gold-localization-009", "gold-localization-023"]
    )

    static let formattingTerm = GlossaryTerm(
        id: "formatting",
        term: "フォーマット",
        aliases: ["NumberFormat", "DecimalFormat", "DateTimeFormatter", "MessageFormat", "parse", "ofPattern"],
        summary: "数値・通貨・日付・メッセージをLocaleやパターンに従って文字列化、または文字列から解析する処理。",
        body: """
JavaのフォーマットAPIは、値を人間向けの文字列に変換したり、文字列から値を解析したりします。

代表例:

- `NumberFormat`: 数値、通貨、パーセントを[Locale](javasta://term/locale)に従って整形
- `DecimalFormat`: `0000.00` や `#,##0` などのパターンで数値を整形
- `DateTimeFormatter`: `ofPattern("uuuu/MM/dd")` などで日付時刻を整形・解析
- `MessageFormat`: `Hello {0}` のようなメッセージパターンに値を差し込む

注意点:

- `NumberFormat.parse(String)` は、先頭から読める部分だけでNumberを返すことがある
- `DateTimeFormatter` の `MM` は月、`mm` は分。大文字小文字を区別する
- `MessageFormat` の単一引用符はエスケープに使われる
""",
        relatedTermIds: ["locale", "resource-bundle"],
        relatedLessonIds: [],
        relatedQuizIds: ["gold-localization-003", "gold-localization-004", "gold-localization-006", "gold-localization-010", "gold-localization-011", "gold-localization-012", "gold-localization-013", "gold-localization-014", "gold-localization-015", "gold-localization-016", "gold-localization-017", "gold-localization-018", "gold-localization-019", "gold-localization-020", "gold-localization-021", "gold-localization-022", "gold-localization-023"]
    )

    // MARK: - モダンJava

    static let enumTerm = GlossaryTerm(
        id: "enum",
        term: "enum（列挙型）",
        aliases: ["Enum", "列挙型", "定数"],
        summary: "決まった値の集合を型安全に表すクラス。メソッドやフィールドも持てる。",
        body: """
`enum` は決まった定数セットを型安全に表す特殊なクラスです。

```java
enum Season { SPRING, SUMMER, FALL, WINTER }
Season s = Season.SUMMER;
```

**フィールド・メソッドを持てる**:

```java
enum Planet {
    EARTH(5.97e24, 6.37e6),
    MARS(6.42e23, 3.39e6);

    final double mass, radius;
    Planet(double mass, double radius) {
        this.mass = mass; this.radius = radius;
    }
    double gravity() { return 6.67e-11 * mass / (radius * radius); }
}
```

switch文で全ケースを網羅しているかコンパイラが確認でき、バグを防げます。`ordinal()`（0始まりの番号）や `name()` も組み込まれています。
""",
        relatedTermIds: ["switch-expression", "static-keyword"],
        relatedLessonIds: [],
        relatedQuizIds: ["silver-enum-001", "silver-enum-002", "silver-enum-003", "gold-enum-004", "gold-enum-005"]
    )

    static let annotationTerm = GlossaryTerm(
        id: "annotation",
        term: "アノテーション",
        aliases: ["@annotation", "メタデータ"],
        summary: "コード要素にメタデータを付与する `@` 構文。コンパイラやフレームワークが読み取る。",
        body: """
**アノテーション** は `@` で始まり、クラス・メソッド・フィールドなどにメタデータを付与します。

代表的な組み込みアノテーション:

| アノテーション | 用途 |
|---|---|
| `@Override` | オーバーライドを明示、コンパイルチェック |
| `@Deprecated` | 非推奨API、警告を出す |
| `@SuppressWarnings` | 特定の警告を抑制 |
| `@FunctionalInterface` | 関数型インターフェースを明示 |

フレームワーク（Spring、JUnit等）は独自アノテーション（`@Test`, `@Autowired` 等）を多用します。アノテーション自体はコードの動作を変えず、ツールやランタイムが読み取って動作します。
""",
        relatedTermIds: ["override", "functional-interface", "meta-annotation"],
        relatedLessonIds: [],
        relatedQuizIds: ["gold-annotations-001", "gold-annotations-002", "gold-annotations-003", "gold-annotations-004", "gold-annotations-005", "gold-annotations-006", "gold-annotations-007", "gold-annotations-008", "gold-annotations-009", "gold-annotations-010", "gold-annotations-011", "gold-annotations-012"]
    )

    static let metaAnnotationTerm = GlossaryTerm(
        id: "meta-annotation",
        term: "メタアノテーション",
        aliases: ["@Retention", "@Target", "@Inherited", "@Repeatable", "ANNOTATION_TYPE"],
        summary: "アノテーション型そのものに付けて、保持期間・使用可能位置・継承・繰り返し可否を指定するアノテーション。",
        body: """
**メタアノテーション** は、アノテーション型を定義するときに、そのアノテーションの性質を指定するためのアノテーションです。

代表例:

- `@Retention`: ソースだけ、classファイルまで、実行時まで、の保持期間を指定
- `@Target`: クラス、メソッド、フィールド、アノテーション型など、付与できる場所を制限
- `@Inherited`: クラスアノテーションをサブクラスからも反射で見えるようにする
- `@Repeatable`: 同じアノテーションを同じ場所に複数回付けられるようにする

```java
@Target(ElementType.ANNOTATION_TYPE)
@interface Role {}

@Role
@interface Secured {}
```

`ElementType.ANNOTATION_TYPE` は「アノテーション型宣言にだけ付けられる」という意味です。通常クラスに付けるとコンパイルエラーになります。
""",
        relatedTermIds: ["annotation"],
        relatedLessonIds: [],
        relatedQuizIds: ["gold-annotations-006", "gold-annotations-007", "gold-annotations-008", "gold-annotations-009", "gold-annotations-010", "gold-annotations-011"]
    )

    static let pathNioTerm = GlossaryTerm(
        id: "path-nio",
        term: "Path（NIO.2）",
        aliases: ["java.nio.file.Path", "resolve", "relativize", "resolveSibling"],
        summary: "ファイルやディレクトリのパスを表すNIO.2 API。文字列連結ではなくメソッドでパスを組み立てる。",
        body: """
`Path` は `java.nio.file` パッケージのパス表現です。ファイルの存在確認ではなく、パスそのものの操作を行います。

```java
Path path = Path.of("/app/logs/app.log");
path.getParent();                 // /app/logs
path.resolveSibling("old.log");   // /app/logs/old.log
```

よく出る操作:

- `resolve(other)`: 子パスとして解決。`other` が絶対パスなら `other` が優先される
- `relativize(other)`: 基準パスから見た相対パスを作る
- `normalize()`: `.` や `..` などの冗長な名前要素を整理する
- `resolveSibling(other)`: 同じ親を持つ兄弟パスとして解決する

`Files.readString` や `Files.copy` など、実際にファイルへアクセスするAPIとは役割を分けて考えます。
""",
        relatedTermIds: ["collections", "secure-coding"],
        relatedLessonIds: ["lesson-gold-path-resolve", "lesson-gold-path-normalize"],
        relatedQuizIds: ["gold-io-005", "gold-io-006", "gold-secure-coding-009", "gold-secure-coding-010"]
    )

    static let recordTerm = GlossaryTerm(
        id: "record",
        term: "record（レコード）",
        aliases: ["Java 16", "不変データクラス"],
        summary: "Java 16で正式化。フィールドの宣言だけでコンストラクタ・getter・equals・hashCode・toStringを自動生成。",
        body: """
`record` は不変データクラスを簡潔に書くための構文（Java 16〜）。

```java
record Point(int x, int y) {}

Point p = new Point(3, 4);
p.x();        // getter（フィールド名と同名）
p.toString(); // "Point[x=3, y=4]"
p.equals(new Point(3, 4));  // true
```

自動生成されるもの:
- コンストラクタ（全フィールド）
- フィールドに対応する getter
- `equals`, `hashCode`, `toString`

フィールドは暗黙的に `private final`。カスタム検証はコンパクトコンストラクタで行えます。

```java
record Range(int min, int max) {
    Range {
        if (min > max) throw new IllegalArgumentException();
    }
}
```
""",
        relatedTermIds: ["encapsulation", "final-keyword"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )

    static let sealedTerm = GlossaryTerm(
        id: "sealed",
        term: "sealed クラス/インターフェース",
        aliases: ["sealed", "permits", "Java 17"],
        summary: "Java 17で正式化。継承できるサブクラスを `permits` で明示的に制限する。",
        body: """
`sealed` は継承を許可するクラスを明示的に制限する機能です（Java 17〜）。

```java
sealed interface Shape permits Circle, Rectangle, Triangle {}
record Circle(double radius) implements Shape {}
record Rectangle(double w, double h) implements Shape {}
final class Triangle implements Shape { ... }
```

`permits` に列挙したクラスしか実装・継承できません。サブクラスは `final`・`sealed`・`non-sealed` のいずれかを宣言します。

switch式でパターンマッチングと組み合わせると、全ケースの網羅チェックができます。

```java
double area = switch (shape) {
    case Circle c    -> Math.PI * c.radius() * c.radius();
    case Rectangle r -> r.w() * r.h();
    case Triangle t  -> ...;
};
```
""",
        relatedTermIds: ["inheritance", "interface", "switch-expression", "record"],
        relatedLessonIds: [],
        relatedQuizIds: []
    )
}
