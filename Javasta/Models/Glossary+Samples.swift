import Foundation

extension GlossaryTerm {
    static let samples: [GlossaryTerm] = [
        jdk,
        jvm,
        sourceFile,
        entryPoint,
        compile,
        overload,
        staticBinding,
        dynamicBinding,
        typePromotion,
        boxing,
        varargs,
        genericsInvariance,
        bytecode,
        stringPool,
        integerCache,
        fallthrough,
        finallyBlock,
        referenceEquals,
        streamApi,
        lazyEvaluation,
        intermediateOp,
        terminalOp,
        optionalType,
        pecs,
        wrapperClass,
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
        relatedQuizIds: ["gold-generics-001"]
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

    static let fallthrough = GlossaryTerm(
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
        relatedQuizIds: ["gold-generics-001"]
    )
}
