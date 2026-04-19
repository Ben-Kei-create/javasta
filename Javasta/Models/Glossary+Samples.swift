import Foundation

extension GlossaryTerm {
    static let samples: [GlossaryTerm] = [
        compile,
        overload,
        staticBinding,
        dynamicBinding,
        typePromotion,
        boxing,
        varargs,
        genericsInvariance,
        bytecode,
    ]

    static func lookup(_ id: String) -> GlossaryTerm? {
        samples.first { $0.id == id }
    }

    // MARK: - 用語

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

この制約を緩めるためにワイルドカード（`<? extends T>` `<? super T>`）を使います。詳しくは関連レッスン「上限境界ワイルドカード」を参照。
""",
        relatedTermIds: [],
        relatedLessonIds: ["lesson-bounded-wildcards"],
        relatedQuizIds: ["gold-generics-001"]
    )
}
