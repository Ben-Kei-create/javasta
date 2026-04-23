import Foundation

extension GlossaryTerm {
    static let examVocabularyExpansion: [GlossaryTerm] = [
        definiteAssignmentTerm,
        defaultValueTerm,
        arrayCovarianceTerm,
        multidimensionalArrayTerm,
        shortCircuitTerm,
        ternaryOperatorTerm,
        operatorPrecedenceTerm,
        labelBreakContinueTerm,
        initializationOrderTerm,
        staticInitializerTerm,
        instanceInitializerTerm,
        thisSuperTerm,
        methodHidingTerm,
        covariantReturnTerm,
        exceptionHierarchyTerm,
        runtimeExceptionTerm,
        errorTerm,
        tryCatchOrderTerm,
        typeErasureTerm,
        boundedTypeParameterTerm,
        wildcardTerm,
        diamondOperatorTerm,
        comparableComparatorContractTerm,
        listSetQueueMapTerm,
        hashSetTerm,
        treeSetTerm,
        dequeTerm,
        targetTypingTerm,
        effectivelyFinalTerm,
        predicateFunctionConsumerSupplierTerm,
        unaryBinaryOperatorTerm,
        primitiveStreamTerm,
        flatMapTerm,
        groupingPartitioningTerm,
        toMapMergeTerm,
        optionalEagerLazyTerm,
        dateTimeFormatterTerm,
        messageFormatTerm,
        moduleDescriptorTerm,
        requiresTransitiveTerm,
        exportsOpensTerm,
        serviceLoaderTerm,
        executorServiceTerm,
        callableFutureTerm,
        completableFutureTerm,
        parallelStreamTerm,
        volatileTerm,
        concurrentHashMapTerm,
        synchronizedTerm,
        raceConditionTerm,
        filesLinesTerm,
        pathResolveRelativizeTerm,
        transientTerm,
        serialVersionUIDTerm,
        retentionPolicyTerm,
        annotationTargetTerm,
    ]

    private static func examVocabulary(
        id: String,
        term: String,
        aliases: [String] = [],
        summary: String,
        body: String,
        relatedTermIds: [String] = [],
        relatedLessonIds: [String] = [],
        relatedQuizIds: [String] = []
    ) -> GlossaryTerm {
        GlossaryTerm(
            id: id,
            term: term,
            aliases: aliases,
            summary: summary,
            body: body,
            relatedTermIds: relatedTermIds,
            relatedLessonIds: relatedLessonIds,
            relatedQuizIds: relatedQuizIds
        )
    }

    static let definiteAssignmentTerm = examVocabulary(
        id: "definite-assignment",
        term: "definite assignment",
        aliases: ["確実な代入", "初期化チェック"],
        summary: "ローカル変数が使用前に必ず代入済みであることをコンパイラが確認する規則。",
        body: """
**definite assignment** は、ローカル変数を読む前に必ず値が入っているかをコンパイラが検査する規則です。

```java
int x;
if (flag) {
    x = 10;
}
System.out.println(x); // flagがfalseなら未代入なのでコンパイルエラー
```

フィールドにはデフォルト値がありますが、ローカル変数には自動初期化がありません。試験では `if`、`switch`、`try` の全経路で代入されるかを追わせる問題がよく出ます。
""",
        relatedTermIds: ["default-value", "compile", "control-flow"]
    )

    static let defaultValueTerm = examVocabulary(
        id: "default-value",
        term: "デフォルト値",
        aliases: ["default value", "フィールド初期値", "配列初期値"],
        summary: "フィールドや配列要素に自動で入る初期値。ローカル変数には適用されない。",
        body: """
フィールドと配列要素には型ごとのデフォルト値が入ります。

- 数値型: `0` / `0.0`
- `char`: `\\u0000`
- `boolean`: `false`
- 参照型: `null`

一方、メソッド内のローカル変数は使用前に明示的な代入が必要です。ここを混同すると、コンパイルエラー問題を実行時出力問題として読んでしまいます。
""",
        relatedTermIds: ["definite-assignment", "null", "data-types"]
    )

    static let arrayCovarianceTerm = examVocabulary(
        id: "array-covariance",
        term: "配列の共変性",
        aliases: ["array covariance", "ArrayStoreException"],
        summary: "`String[]` を `Object[]` として扱えるが、格納時に実行時型検査が入る性質。",
        body: """
配列は共変です。つまり `String[]` は `Object[]` に代入できます。

```java
Object[] a = new String[1];
a[0] = 100; // ArrayStoreException
```

参照型は `Object[]` でも、実体は `String[]` です。配列は実行時にも要素型を知っているため、違う型を格納しようとすると `ArrayStoreException` が発生します。
""",
        relatedTermIds: ["casting", "runtime-exception", "generics-invariance"]
    )

    static let multidimensionalArrayTerm = examVocabulary(
        id: "multidimensional-array",
        term: "多次元配列",
        aliases: ["2次元配列", "jagged array", "配列の配列"],
        summary: "Javaの多次元配列は配列の配列。行ごとに長さが違ってもよい。",
        body: """
Javaの多次元配列は、厳密には「配列の配列」です。

```java
int[][] a = new int[2][];
a[0] = new int[3];
a[1] = new int[1];
```

`a.length` は外側の長さ、`a[0].length` は内側配列の長さです。内側配列を作っていない状態で `a[0][0]` にアクセスすると `NullPointerException` になります。
""",
        relatedTermIds: ["array-covariance", "null", "runtime-exception"]
    )

    static let shortCircuitTerm = examVocabulary(
        id: "short-circuit",
        term: "短絡評価",
        aliases: ["short-circuit", "&&", "||"],
        summary: "`&&` と `||` で、結果が確定した時点で右辺評価を省略する仕組み。",
        body: """
`&&` と `||` は短絡評価します。

```java
if (obj != null && obj.isValid()) { ... }
```

`&&` は左辺がfalseなら右辺を評価しません。`||` は左辺がtrueなら右辺を評価しません。試験では `i++` などの副作用が右辺に置かれ、値の変化を追わせることがあります。
""",
        relatedTermIds: ["operator-precedence", "ternary-operator", "null"]
    )

    static let ternaryOperatorTerm = examVocabulary(
        id: "ternary-operator",
        term: "三項演算子",
        aliases: ["?:", "conditional operator", "条件演算子"],
        summary: "`条件 ? 値1 : 値2` の形で、条件に応じて式の値を切り替える演算子。",
        body: """
三項演算子は文ではなく式です。

```java
int n = flag ? 10 : 20;
```

第2・第3オペランドの型が異なる場合、数値昇格やボクシングが絡みます。`if` と同じ感覚で読むだけでなく、最終的な式の型が何になるかを見るのが重要です。
""",
        relatedTermIds: ["type-promotion", "boxing", "operator-precedence"]
    )

    static let operatorPrecedenceTerm = examVocabulary(
        id: "operator-precedence",
        term: "演算子の優先順位",
        aliases: ["precedence", "結合規則"],
        summary: "式のどの部分が先に評価されるかを決める規則。迷ったら括弧で読む。",
        body: """
演算子には優先順位があります。たとえば `*` は `+` より先に評価されます。

```java
int x = 1 + 2 * 3; // 7
```

試験では `++`、キャスト、文字列連結、三項演算子が混ざることがあります。暗記だけに頼らず、コードを括弧で補って読む癖を付けると安定します。
""",
        relatedTermIds: ["ternary-operator", "type-promotion", "casting"]
    )

    static let labelBreakContinueTerm = examVocabulary(
        id: "labeled-break-continue",
        term: "ラベル付き break / continue",
        aliases: ["labeled break", "labeled continue", "ラベル"],
        summary: "ネストしたループで、どのループを抜けるか・続けるかを明示する構文。",
        body: """
ラベルを付けると、ネストしたループの外側を対象に `break` や `continue` できます。

```java
outer:
for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
        if (j == 1) continue outer;
    }
}
```

`break outer` は外側ループを抜けます。`continue outer` は外側ループの次の反復へ進みます。出力順を追う問題でよく効きます。
""",
        relatedTermIds: ["fallthrough", "control-flow"]
    )

    static let initializationOrderTerm = examVocabulary(
        id: "initialization-order",
        term: "初期化順",
        aliases: ["initialization order", "クラス初期化", "インスタンス初期化"],
        summary: "static初期化、インスタンス初期化、コンストラクタが実行される順序。",
        body: """
初期化順は本番で強いひっかけになります。

基本順序:
1. 親クラスのstatic初期化
2. 子クラスのstatic初期化
3. 親のインスタンス初期化
4. 親コンストラクタ
5. 子のインスタンス初期化
6. 子コンストラクタ

static初期化はクラスごとに一度だけ、インスタンス初期化とコンストラクタは `new` のたびに実行されます。
""",
        relatedTermIds: ["static-initializer", "instance-initializer", "constructor", "inheritance"]
    )

    static let staticInitializerTerm = examVocabulary(
        id: "static-initializer",
        term: "static初期化ブロック",
        aliases: ["static initializer", "static block"],
        summary: "クラス初期化時に一度だけ実行される `static { ... }` ブロック。",
        body: """
`static { ... }` はクラスが初期化されるときに一度だけ実行されます。

```java
class A {
    static { System.out.print("S"); }
}
```

インスタンスを何個作っても毎回は実行されません。継承が絡む場合、親クラスのstatic初期化が子クラスより先です。
""",
        relatedTermIds: ["initialization-order", "static-keyword"]
    )

    static let instanceInitializerTerm = examVocabulary(
        id: "instance-initializer",
        term: "インスタンス初期化ブロック",
        aliases: ["instance initializer", "初期化ブロック"],
        summary: "コンストラクタ本体の前に、インスタンス生成ごとに実行される `{ ... }` ブロック。",
        body: """
インスタンス初期化ブロックは、オブジェクト生成のたびにコンストラクタ本体より前に実行されます。

```java
class A {
    { System.out.print("I"); }
    A() { System.out.print("C"); }
}
```

`new A()` の出力は `IC` です。複数の初期化ブロックやフィールド初期化がある場合、ソースに書かれた順に実行されます。
""",
        relatedTermIds: ["initialization-order", "constructor"]
    )

    static let thisSuperTerm = examVocabulary(
        id: "this-super",
        term: "this / super",
        aliases: ["this()", "super()", "this参照", "super参照"],
        summary: "`this` は現在のオブジェクト、`super` は親クラス側のメンバやコンストラクタを指す。",
        body: """
`this` は現在のオブジェクト、`super` は親クラス側を参照します。

```java
class B extends A {
    B() {
        super(); // コンストラクタの先頭で呼ぶ必要がある
    }
}
```

`this()` と `super()` は同じコンストラクタ内で同時に書けません。どちらも書くならコンストラクタの最初の文でなければならないためです。
""",
        relatedTermIds: ["constructor", "inheritance", "override"]
    )

    static let methodHidingTerm = examVocabulary(
        id: "method-hiding",
        term: "メソッドの隠蔽",
        aliases: ["method hiding", "static method hiding"],
        summary: "staticメソッドはオーバーライドではなく隠蔽され、参照型で呼び出し先が決まる。",
        body: """
staticメソッドはインスタンスメソッドのようにはオーバーライドされません。

```java
class A { static void m() { System.out.print("A"); } }
class B extends A { static void m() { System.out.print("B"); } }
A x = new B();
x.m(); // A
```

呼び出し先は実体型 `B` ではなく、参照型 `A` で決まります。動的バインディングと混同しやすい重要ポイントです。
""",
        relatedTermIds: ["static-binding", "dynamic-binding", "static-keyword", "override"]
    )

    static let covariantReturnTerm = examVocabulary(
        id: "covariant-return",
        term: "共変戻り値",
        aliases: ["covariant return type"],
        summary: "オーバーライド時、戻り値型を親メソッドの戻り値型のサブタイプへ狭められる規則。",
        body: """
オーバーライドでは、戻り値型をより具体的な型へ変更できます。

```java
class A {
    Number value() { return 1; }
}
class B extends A {
    Integer value() { return 1; }
}
```

戻り値型だけを無関係な型に変えることはできません。アクセス修飾子や例外宣言の制約とセットで問われます。
""",
        relatedTermIds: ["override", "inheritance", "polymorphism"]
    )

    static let exceptionHierarchyTerm = examVocabulary(
        id: "exception-hierarchy",
        term: "例外階層",
        aliases: ["Throwable", "Exception", "RuntimeException", "Error"],
        summary: "`Throwable` の下に `Exception` と `Error` があり、検査例外と非検査例外の区別がある。",
        body: """
Javaの例外は `Throwable` を頂点にします。

- `Exception`: 通常の例外
- `RuntimeException`: 非検査例外
- `Error`: アプリ側で通常捕捉しない深刻なエラー

`RuntimeException` 以外の `Exception` は検査例外で、捕捉または `throws` が必要です。
""",
        relatedTermIds: ["checked-unchecked", "runtime-exception", "error", "try-catch-order"]
    )

    static let runtimeExceptionTerm = examVocabulary(
        id: "runtime-exception",
        term: "RuntimeException",
        aliases: ["非検査例外", "unchecked exception"],
        summary: "コンパイル時にcatch/throwsを強制されない例外。",
        body: """
`RuntimeException` とそのサブクラスは非検査例外です。

代表例:
- `NullPointerException`
- `ClassCastException`
- `ArrayIndexOutOfBoundsException`
- `IllegalArgumentException`

非検査例外は `throws` を書かなくてもコンパイルできます。ただし実行時に発生すれば通常通り処理は中断します。
""",
        relatedTermIds: ["exception-hierarchy", "checked-unchecked", "null", "casting"]
    )

    static let errorTerm = examVocabulary(
        id: "error",
        term: "Error",
        aliases: ["AssertionError", "StackOverflowError", "OutOfMemoryError"],
        summary: "通常のアプリケーションで回復を想定しない深刻な問題を表す `Throwable`。",
        body: """
`Error` は `Throwable` のサブクラスですが、通常のアプリケーションコードで捕捉して回復する対象ではありません。

試験で重要な例:
- `AssertionError`: assert失敗時
- `StackOverflowError`: 再帰が深すぎる場合
- `OutOfMemoryError`: メモリ不足

`Exception` ではないので、`catch (Exception e)` では捕まりません。
""",
        relatedTermIds: ["assertion", "exception-hierarchy", "checked-unchecked"]
    )

    static let tryCatchOrderTerm = examVocabulary(
        id: "try-catch-order",
        term: "catchブロックの順序",
        aliases: ["catch order", "unreachable catch"],
        summary: "複数catchでは、サブクラス例外を先に、スーパークラス例外を後に書く必要がある。",
        body: """
複数catchでは、狭い型から広い型へ並べます。

```java
try {
    ...
} catch (IOException e) {
} catch (Exception e) {
}
```

先に `catch (Exception e)` を書くと、その後の `catch (IOException e)` は到達不能になりコンパイルエラーです。マルチキャッチでは継承関係にある例外型を同時に並べることもできません。
""",
        relatedTermIds: ["exception-hierarchy", "checked-unchecked", "finally"]
    )

    static let typeErasureTerm = examVocabulary(
        id: "type-erasure",
        term: "型消去",
        aliases: ["type erasure", "ジェネリクス消去"],
        summary: "Javaジェネリクスの型引数情報が、主にコンパイル時検査に使われ、実行時には消去される仕組み。",
        body: """
Javaのジェネリクスは型消去されます。

```java
List<String> a = new ArrayList<>();
List<Integer> b = new ArrayList<>();
```

実行時にはどちらも主に `ArrayList` として扱われ、`String` や `Integer` の型引数は通常残りません。このため `new T()` や `new T[]` はできません。
""",
        relatedTermIds: ["generics-invariance", "raw-type", "bounded-type-parameter"]
    )

    static let boundedTypeParameterTerm = examVocabulary(
        id: "bounded-type-parameter",
        term: "境界付き型パラメータ",
        aliases: ["bounded type parameter", "<T extends X>"],
        summary: "`<T extends Number>` のように、型パラメータに上限を付けるジェネリクス構文。",
        body: """
型パラメータには上限を付けられます。

```java
class Box<T extends Number> {
    T value;
}
```

複数境界ではクラスを先に、インターフェースを後に書きます。

```java
<T extends Number & Comparable<T>>
```

`extends` はクラス継承だけでなく、インターフェース境界にも使う点が試験で狙われます。
""",
        relatedTermIds: ["type-erasure", "generics-invariance", "pecs"]
    )

    static let wildcardTerm = examVocabulary(
        id: "wildcard",
        term: "ワイルドカード",
        aliases: ["?", "? extends", "? super"],
        summary: "ジェネリクスで未知の型を表す `?`。読み取り中心ならextends、書き込み中心ならsuperが基本。",
        body: """
ワイルドカード `?` は未知の型を表します。

```java
List<? extends Number> in;
List<? super Integer> out;
```

`? extends Number` はNumberとして読めますが、具体的な要素追加はほぼできません。`? super Integer` はIntegerを書き込めますが、読むときは基本的にObjectです。PECSとセットで覚えます。
""",
        relatedTermIds: ["pecs", "generics-invariance", "bounded-type-parameter"]
    )

    static let diamondOperatorTerm = examVocabulary(
        id: "diamond-operator",
        term: "ダイヤモンド演算子",
        aliases: ["diamond", "<>"],
        summary: "右辺のジェネリクス型引数をコンパイラに推論させる `<>`。",
        body: """
ダイヤモンド演算子 `<>` は、右辺の型引数を省略する構文です。

```java
List<String> names = new ArrayList<>();
```

左辺や文脈から `String` が推論されます。raw型の `new ArrayList()` とは違い、型安全性を保てます。
""",
        relatedTermIds: ["type-erasure", "raw-type", "var-local-type"]
    )

    static let comparableComparatorContractTerm = examVocabulary(
        id: "comparison-contract",
        term: "比較の契約",
        aliases: ["compareTo", "compare", "Comparator contract"],
        summary: "`Comparable` / `Comparator` では、負・0・正の戻り値と一貫した順序が重要。",
        body: """
`compareTo` や `Comparator.compare` は、大小関係を負・0・正で返します。

```java
Comparator<String> byLength = (a, b) -> a.length() - b.length();
```

0は「順序上同じ」を意味します。`TreeSet` や `TreeMap` では比較結果が0だと重複扱いになり、`equals` と違う判断になることがあります。
""",
        relatedTermIds: ["comparable", "comparator", "tree-set"]
    )

    static let listSetQueueMapTerm = examVocabulary(
        id: "list-set-queue-map",
        term: "List / Set / Queue / Map",
        aliases: ["Collection主要インターフェース"],
        summary: "Java Collections Frameworkの主要インターフェース。順序・重複・キー値対応で使い分ける。",
        body: """
コレクションの主要インターフェースは性質で整理します。

- `List`: 順序あり、重複あり
- `Set`: 重複なし
- `Queue`: 取り出し順を意識する
- `Map`: キーと値の対応。`Collection` のサブインターフェースではない

本番では「どの実装が順序を保証するか」「重複時にどうなるか」が問われやすいです。
""",
        relatedTermIds: ["collections", "arraylist", "hashmap", "hash-set", "deque"]
    )

    static let hashSetTerm = examVocabulary(
        id: "hash-set",
        term: "HashSet",
        aliases: ["Set", "重複排除"],
        summary: "ハッシュ値で要素を管理するSet実装。重複判定には `equals` と `hashCode` が関係する。",
        body: """
`HashSet` は重複を許さないSet実装です。

重複判定では `hashCode` と `equals` が重要です。独自クラスを要素にする場合、この2つの契約が崩れると、同じつもりの要素が重複したり、検索できなかったりします。

出力順は基本的に挿入順ではありません。順序を期待する問題では `LinkedHashSet` や `TreeSet` と区別します。
""",
        relatedTermIds: ["list-set-queue-map", "reference-equals", "object-class"]
    )

    static let treeSetTerm = examVocabulary(
        id: "tree-set",
        term: "TreeSet",
        aliases: ["SortedSet", "NavigableSet"],
        summary: "要素をソート順で保持するSet実装。比較結果0の要素は重複扱いになる。",
        body: """
`TreeSet` は要素をソート順で管理します。

要素は `Comparable` を実装するか、`Comparator` を渡す必要があります。比較結果が0なら同じ要素とみなされるため、`equals` がfalseでも追加されないことがあります。

`HashSet` との大きな違いは、順序が比較規則で決まることです。
""",
        relatedTermIds: ["comparable", "comparator", "comparison-contract", "hash-set"]
    )

    static let dequeTerm = examVocabulary(
        id: "deque",
        term: "Deque",
        aliases: ["ArrayDeque", "両端キュー", "stack"],
        summary: "先頭・末尾の両方から追加/削除できるキュー。スタック用途にも使える。",
        body: """
`Deque` は double-ended queue の略で、両端から操作できます。

```java
Deque<String> d = new ArrayDeque<>();
d.push("A");
d.push("B");
System.out.println(d.pop()); // B
```

`ArrayDeque` はスタック用途でもよく使われます。`Queue` の `offer` / `poll` / `peek` と、`Deque` の `push` / `pop` を区別しましょう。
""",
        relatedTermIds: ["list-set-queue-map", "collections", "iterator"]
    )

    static let targetTypingTerm = examVocabulary(
        id: "target-typing",
        term: "ターゲット型",
        aliases: ["target typing", "ラムダの型推論"],
        summary: "ラムダ式やメソッド参照の型が、代入先や引数位置から決まる仕組み。",
        body: """
ラムダ式そのものには単独の型がありません。代入先やメソッド引数の型、つまりターゲット型によって型が決まります。

```java
Predicate<String> p = s -> s.isEmpty();
Function<String, Integer> f = s -> s.length();
```

同じ `s -> ...` でも、ターゲット型が違えば意味が変わります。オーバーロードとラムダが絡む問題で重要です。
""",
        relatedTermIds: ["lambda", "functional-interface", "method-reference"]
    )

    static let effectivelyFinalTerm = examVocabulary(
        id: "effectively-final",
        term: "実質的final",
        aliases: ["effectively final", "ラムダキャプチャ"],
        summary: "finalと明示していなくても、初期化後に再代入されないローカル変数のこと。",
        body: """
ラムダ式や匿名クラスから参照するローカル変数は、`final` または実質的finalである必要があります。

```java
int n = 10;
Runnable r = () -> System.out.println(n);
// n++; // これを書くと実質的finalではなくなる
```

値が変わるかどうかではなく、再代入があるかを見ます。参照先オブジェクトの中身を変更することとは区別します。
""",
        relatedTermIds: ["lambda", "functional-interface", "var-local-type"]
    )

    static let predicateFunctionConsumerSupplierTerm = examVocabulary(
        id: "main-functional-interfaces",
        term: "Predicate / Function / Consumer / Supplier",
        aliases: ["主要関数型インターフェース"],
        summary: "ラムダ式で頻出する4つの基本関数型インターフェース。",
        body: """
主要な関数型インターフェースは入出力で覚えると整理できます。

- `Predicate<T>`: Tを受け取りbooleanを返す
- `Function<T,R>`: Tを受け取りRを返す
- `Consumer<T>`: Tを受け取り戻り値なし
- `Supplier<T>`: 引数なしでTを返す

メソッド名はそれぞれ `test`、`apply`、`accept`、`get` です。
""",
        relatedTermIds: ["functional-interface", "lambda", "primitive-functional-interface"]
    )

    static let unaryBinaryOperatorTerm = examVocabulary(
        id: "unary-binary-operator",
        term: "UnaryOperator / BinaryOperator",
        aliases: ["Operator系関数型インターフェース"],
        summary: "入力型と戻り値型が同じFunction系の関数型インターフェース。",
        body: """
`UnaryOperator<T>` は `Function<T, T>` の特殊形です。1つ受け取り同じ型を返します。

`BinaryOperator<T>` は `BiFunction<T, T, T>` の特殊形です。2つ受け取り同じ型を返します。

```java
UnaryOperator<String> trim = String::trim;
BinaryOperator<Integer> add = Integer::sum;
```

Streamの `reduce` でもよく登場します。
""",
        relatedTermIds: ["main-functional-interfaces", "method-reference", "stream"]
    )

    static let primitiveStreamTerm = examVocabulary(
        id: "primitive-stream",
        term: "IntStream / LongStream / DoubleStream",
        aliases: ["プリミティブStream", "mapToInt", "boxed"],
        summary: "int/long/doubleを直接扱い、ボクシングを避けられるStream。",
        body: """
プリミティブStreamは `int`、`long`、`double` を直接扱います。

```java
int sum = IntStream.rangeClosed(1, 3).sum();
Stream<Integer> boxed = IntStream.of(1, 2).boxed();
```

`sum`、`average`、`summaryStatistics` など、参照型Streamにはない便利な終端操作があります。型変換には `mapToInt`、`boxed` などを使います。
""",
        relatedTermIds: ["stream", "boxing", "terminal-operation"]
    )

    static let flatMapTerm = examVocabulary(
        id: "flat-map",
        term: "flatMap",
        aliases: ["map vs flatMap", "平坦化"],
        summary: "各要素からStreamを作り、それらを1本のStreamへ平坦化する中間操作。",
        body: """
`map` は1要素を1値へ変換します。`flatMap` は1要素からStreamを作り、結果を平坦化します。

```java
Stream.of(List.of("A", "B"), List.of("C"))
    .flatMap(List::stream)
    .forEach(System.out::print); // ABC
```

戻り値が `Stream<Stream<T>>` になりそうな場面では `flatMap` を疑います。
""",
        relatedTermIds: ["stream", "intermediate-operation", "lazy-evaluation"]
    )

    static let groupingPartitioningTerm = examVocabulary(
        id: "grouping-partitioning",
        term: "groupingBy / partitioningBy",
        aliases: ["Collectors.groupingBy", "Collectors.partitioningBy"],
        summary: "Stream要素をキーごと、またはboolean条件ごとに分類してMapへ集めるCollector。",
        body: """
`groupingBy` は分類キーごとに要素をまとめます。

```java
Map<Integer, List<String>> m =
    Stream.of("a", "bb").collect(Collectors.groupingBy(String::length));
```

`partitioningBy` は `Predicate` により `true` と `false` の2グループへ分けます。戻り値のMapキーはBooleanです。
""",
        relatedTermIds: ["collectors", "stream", "main-functional-interfaces"]
    )

    static let toMapMergeTerm = examVocabulary(
        id: "to-map-merge",
        term: "Collectors.toMap のマージ関数",
        aliases: ["toMap", "merge function", "重複キー"],
        summary: "`toMap` で重複キーが出る場合、マージ関数を指定しないと例外になる。",
        body: """
`Collectors.toMap` ではキーが重複すると注意が必要です。

```java
Collectors.toMap(
    String::length,
    s -> s,
    (a, b) -> a + b
)
```

3番目の引数がマージ関数です。指定しない形で重複キーが出ると `IllegalStateException` になります。
""",
        relatedTermIds: ["collectors", "hashmap", "runtime-exception"]
    )

    static let optionalEagerLazyTerm = examVocabulary(
        id: "optional-eager-lazy",
        term: "orElse と orElseGet",
        aliases: ["Optional.orElse", "Optional.orElseGet", "遅延評価"],
        summary: "`orElse` は代替値を先に評価し、`orElseGet` は必要なときだけSupplierを実行する。",
        body: """
`Optional` の代替値指定は評価タイミングが違います。

```java
opt.orElse(create());      // 値があってもcreate()は評価される
opt.orElseGet(() -> create()); // 空のときだけ実行
```

副作用のあるメソッドや重い処理が代替値に置かれると、出力や実行回数が変わります。本番でかなり狙われます。
""",
        relatedTermIds: ["optional", "lazy-evaluation", "main-functional-interfaces"]
    )

    static let dateTimeFormatterTerm = examVocabulary(
        id: "date-time-formatter",
        term: "DateTimeFormatter",
        aliases: ["ofPattern", "parse", "format"],
        summary: "日付時刻を文字列へ整形したり、文字列から解析したりするクラス。",
        body: """
`DateTimeFormatter` は日付時刻のフォーマットとパースに使います。

```java
DateTimeFormatter f = DateTimeFormatter.ofPattern("yyyy/MM/dd");
LocalDate d = LocalDate.parse("2024/02/29", f);
System.out.println(d.format(f));
```

`M` は月、`m` は分です。大文字小文字の違いがひっかけになります。
""",
        relatedTermIds: ["formatting", "locale"]
    )

    static let messageFormatTerm = examVocabulary(
        id: "message-format",
        term: "MessageFormat",
        aliases: ["java.text.MessageFormat", "メッセージフォーマット"],
        summary: "`{0}` などのプレースホルダに値を差し込んで、ローカライズされた文を作るクラス。",
        body: """
`MessageFormat` はメッセージ内の `{0}`、`{1}` などへ値を差し込みます。

```java
String s = MessageFormat.format("Hello, {0}", "Java");
```

リソースバンドルから文面を取り出し、そこへ値を入れる流れがGoldで重要です。単純な文字列連結ではなく、ロケールに応じた表示を意識します。
""",
        relatedTermIds: ["resource-bundle", "locale", "formatting"]
    )

    static let moduleDescriptorTerm = examVocabulary(
        id: "module-descriptor",
        term: "module-info.java",
        aliases: ["モジュール宣言", "module descriptor"],
        summary: "Javaモジュールの依存、公開パッケージ、サービス利用などを宣言するファイル。",
        body: """
`module-info.java` はモジュールの設定ファイルです。

```java
module com.example.app {
    requires com.example.lib;
    exports com.example.api;
}
```

`requires`、`exports`、`opens`、`uses`、`provides` などのディレクティブを理解すると、モジュール問題を読みやすくなります。
""",
        relatedTermIds: ["requires-transitive", "exports-opens", "service-loader"]
    )

    static let requiresTransitiveTerm = examVocabulary(
        id: "requires-transitive",
        term: "requires transitive",
        aliases: ["推移的依存", "transitive requires"],
        summary: "あるモジュールが必要とする依存を、そのモジュールの利用側にも読ませる指定。",
        body: """
`requires transitive` は依存の読み取り関係を利用側へ伝播します。

```java
module app {
    requires transitive lib;
}
module client {
    requires app;
}
```

この場合、`client` は `app` をrequiresするだけで `lib` も読めます。ただし、読めることとパッケージがexportsされていることは別です。
""",
        relatedTermIds: ["module-descriptor", "exports-opens"]
    )

    static let exportsOpensTerm = examVocabulary(
        id: "exports-opens",
        term: "exports と opens",
        aliases: ["module exports", "module opens", "リフレクション"],
        summary: "`exports` は通常アクセス用、`opens` はリフレクション用にパッケージを開く。",
        body: """
`exports` と `opens` はどちらもパッケージ公開に見えますが、目的が違います。

- `exports`: 他モジュールからpublic型を通常参照できる
- `opens`: リフレクションによる深いアクセスを許可する

フレームワークがprivateメンバへ反射的にアクセスする場合は `opens` が関係します。通常のimport可否は `exports` を見ます。
""",
        relatedTermIds: ["module-descriptor", "requires-transitive"]
    )

    static let serviceLoaderTerm = examVocabulary(
        id: "service-loader",
        term: "uses / provides",
        aliases: ["ServiceLoader", "サービスプロバイダ"],
        summary: "モジュールシステムでサービス利用側と提供側を宣言する仕組み。",
        body: """
モジュールではサービスの利用と提供を宣言できます。

```java
module client {
    uses com.example.Service;
}
module provider {
    provides com.example.Service with com.example.ServiceImpl;
}
```

利用側は `ServiceLoader` で実装を探せます。`requires` や `exports` とは役割が違う点を整理しましょう。
""",
        relatedTermIds: ["module-descriptor", "interface"]
    )

    static let executorServiceTerm = examVocabulary(
        id: "executor-service",
        term: "ExecutorService",
        aliases: ["スレッドプール", "submit", "invokeAll", "invokeAny"],
        summary: "タスクをスレッドプールに投入して実行するためのインターフェース。",
        body: """
`ExecutorService` はタスク実行を管理します。

```java
ExecutorService es = Executors.newFixedThreadPool(2);
Future<Integer> f = es.submit(() -> 10);
es.shutdown();
```

`submit` は `Future` を返します。`invokeAll` は全タスク完了を待ち、入力順のFuture一覧を返します。`invokeAny` は成功したいずれか1つの結果を返します。
""",
        relatedTermIds: ["callable-future", "synchronized", "race-condition"]
    )

    static let callableFutureTerm = examVocabulary(
        id: "callable-future",
        term: "Callable / Future",
        aliases: ["Callable", "Future", "ExecutionException"],
        summary: "`Callable` は値や例外を返せるタスク、`Future` は非同期結果を表す。",
        body: """
`Callable<V>` は `V call()` を持ち、戻り値と検査例外を扱えます。

`Future<V>` の `get()` は結果が出るまで待ちます。タスク内で例外が発生した場合、`get()` は原因例外を `ExecutionException` に包んで投げます。

`Runnable` との違い、`submit` と `execute` の違いもよく問われます。
""",
        relatedTermIds: ["executor-service", "exception-hierarchy"]
    )

    static let completableFutureTerm = examVocabulary(
        id: "completable-future",
        term: "CompletableFuture",
        aliases: ["thenApply", "thenCompose", "allOf", "handle"],
        summary: "非同期処理の結果を表し、完了後の処理をチェーンできるFuture。",
        body: """
`CompletableFuture` は非同期計算の結果を表し、完了後の処理をメソッドチェーンでつなげられます。

```java
CompletableFuture<Integer> f = CompletableFuture
    .completedFuture(2)
    .thenApply(n -> n + 3);
```

`thenApply` は値の変換、`thenCompose` はFutureを返す処理の平坦化、`allOf` は複数Futureの完了待ち、`handle` は正常時・例外時の両方を扱う処理です。
""",
        relatedTermIds: ["callable-future", "executor-service", "exception-hierarchy"],
        relatedQuizIds: ["gold-balanced-concurrency-thenapplyasync-001", "gold-balanced-concurrency-allof-001", "gold-balanced-concurrency-handle-001"]
    )

    static let parallelStreamTerm = examVocabulary(
        id: "parallel-stream",
        term: "parallelStream",
        aliases: ["並列ストリーム", "Stream.parallel", "forEachOrdered"],
        summary: "Stream処理を複数スレッドで実行し得るAPI。順序と副作用に注意する。",
        body: """
`parallelStream()` は、Streamパイプラインを複数スレッドで処理し得る形にします。

```java
list.parallelStream()
    .filter(n -> n > 0)
    .findAny();
```

`findAny` や `forEach` は順序を強く保証しないため、順序が必要なら `findFirst` や `forEachOrdered` を検討します。並列 `reduce` ではidentityが単位元になっているかも重要です。
""",
        relatedTermIds: ["stream", "race-condition", "completable-future"],
        relatedQuizIds: ["gold-balanced-concurrency-parallel-findany-001", "gold-balanced-concurrency-foreachordered-001", "gold-balanced-concurrency-parallel-reduce-001"]
    )

    static let volatileTerm = examVocabulary(
        id: "volatile",
        term: "volatile",
        aliases: ["可視性", "visibility"],
        summary: "フィールド値の可視性に関わる修飾子。複合操作の原子性は保証しない。",
        body: """
`volatile` は、あるスレッドの書き込みが他スレッドから見えることに関係する修飾子です。

```java
private volatile boolean running = true;
```

ただし `count++` のような「読む、計算する、書く」の複合操作は原子的になりません。原子的な更新には `AtomicInteger` や `synchronized` などを使います。
""",
        relatedTermIds: ["race-condition", "synchronized", "executor-service"],
        relatedQuizIds: ["gold-balanced-concurrency-volatile-atomicity-001"]
    )

    static let concurrentHashMapTerm = examVocabulary(
        id: "concurrent-hash-map",
        term: "ConcurrentHashMap",
        aliases: ["並行Map", "compute", "computeIfAbsent"],
        summary: "並行アクセスを想定したMap実装。更新系メソッドのラムダ実行に注意する。",
        body: """
`ConcurrentHashMap` は、複数スレッドからのアクセスを想定したMap実装です。

```java
ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();
map.compute("a", (k, v) -> v == null ? 1 : v + 1);
```

`compute` では既存値があればその値、未存在なら `null` がラムダへ渡ります。通常の `HashMap` を外部同期なしに共有するより安全ですが、ラムダ内の副作用や重い処理には注意します。
""",
        relatedTermIds: ["race-condition", "executor-service", "collections"],
        relatedQuizIds: ["gold-balanced-collections-concurrenthashmap-compute-001"]
    )

    static let synchronizedTerm = examVocabulary(
        id: "synchronized",
        term: "synchronized",
        aliases: ["モニタロック", "排他制御"],
        summary: "同じロックを使うコードを同時に1スレッドだけ実行させるキーワード。",
        body: """
`synchronized` はモニタロックによる排他制御を行います。

```java
synchronized (lock) {
    count++;
}
```

インスタンスメソッドに付けると `this`、staticメソッドに付けると `Class` オブジェクトがロックになります。どのロックを共有しているかを読むのが重要です。
""",
        relatedTermIds: ["executor-service", "race-condition", "static-keyword"]
    )

    static let raceConditionTerm = examVocabulary(
        id: "race-condition",
        term: "競合状態",
        aliases: ["race condition", "data race", "スレッド安全性"],
        summary: "複数スレッドの実行順により結果が変わってしまう状態。",
        body: """
競合状態は、複数スレッドが共有データを同時に読み書きし、実行順によって結果が変わる状態です。

```java
count++; // 読む、足す、書く の複合操作
```

`count++` は一見1操作に見えますが、分解されます。`synchronized`、並行コレクション、atomicクラスなどで制御します。
""",
        relatedTermIds: ["synchronized", "executor-service"]
    )

    static let filesLinesTerm = examVocabulary(
        id: "files-lines",
        term: "Files.lines",
        aliases: ["java.nio.file.Files.lines", "Stream<String>"],
        summary: "ファイルを行単位のStreamとして読むAPI。Streamは閉じる必要がある。",
        body: """
`Files.lines(path)` はファイルを行単位で読む `Stream<String>` を返します。

```java
try (Stream<String> lines = Files.lines(path)) {
    long count = lines.count();
}
```

行末の改行文字は各Stringには含まれません。StreamはI/Oリソースを持つため、try-with-resourcesで閉じるのが基本です。
""",
        relatedTermIds: ["path-nio", "try-with-resources", "stream"]
    )

    static let pathResolveRelativizeTerm = examVocabulary(
        id: "path-resolve-relativize",
        term: "resolve / relativize / normalize",
        aliases: ["Path操作", "normalize", "relativize"],
        summary: "Pathを結合・相対化・正規化するNIO.2の基本操作。",
        body: """
`Path` 操作は名前が似ているので整理します。

- `resolve`: パスを結合する。右辺が絶対パスなら右辺が優先される
- `relativize`: あるパスから別パスへの相対パスを作る
- `normalize`: `.` や `..` を構文的に整理する

実ファイルの存在確認ではなく、文字列的なパス操作として問われることが多いです。
""",
        relatedTermIds: ["path-nio", "files-lines"]
    )

    static let transientTerm = examVocabulary(
        id: "transient",
        term: "transient",
        aliases: ["シリアライズ対象外"],
        summary: "シリアライズ時にフィールドを保存対象から外す修飾子。",
        body: """
`transient` を付けたフィールドは、デフォルトシリアライズで保存されません。

```java
class User implements Serializable {
    String name;
    transient String password;
}
```

復元時、transientフィールドは型のデフォルト値になります。セキュアコーディングでは、秘密情報を不用意に保存しないためにも重要です。
""",
        relatedTermIds: ["serialization", "default-value", "secure-coding"]
    )

    static let serialVersionUIDTerm = examVocabulary(
        id: "serial-version-uid",
        term: "serialVersionUID",
        aliases: ["シリアルバージョンUID"],
        summary: "シリアライズされたクラスの互換性確認に使われる識別子。",
        body: """
`serialVersionUID` は、シリアライズされたデータとクラス定義の互換性確認に使われます。

```java
private static final long serialVersionUID = 1L;
```

明示しない場合はコンパイラがクラス構造から計算しますが、クラス変更で変わる可能性があります。試験では `static final long` として宣言する形を押さえます。
""",
        relatedTermIds: ["serialization", "static-keyword", "final-keyword"]
    )

    static let retentionPolicyTerm = examVocabulary(
        id: "retention-policy",
        term: "RetentionPolicy",
        aliases: ["SOURCE", "CLASS", "RUNTIME", "@Retention"],
        summary: "アノテーション情報をソース、classファイル、実行時のどこまで残すかを決める。",
        body: """
`@Retention` はアノテーションの保持期間を決めます。

- `SOURCE`: コンパイル時に破棄
- `CLASS`: classファイルには残るが、通常リフレクションでは見えない
- `RUNTIME`: 実行時リフレクションで取得できる

`isAnnotationPresent` で見えるかを問う問題では、`RUNTIME` かどうかを確認します。
""",
        relatedTermIds: ["annotation", "meta-annotation"]
    )

    static let annotationTargetTerm = examVocabulary(
        id: "annotation-target",
        term: "ElementType",
        aliases: ["@Target", "ANNOTATION_TYPE", "METHOD", "TYPE"],
        summary: "アノテーションを付けられる対象を制限する列挙型。",
        body: """
`@Target` はアノテーションを付けられる場所を制限します。

```java
@Target(ElementType.METHOD)
@interface TestOnly {}
```

代表的な `ElementType` には `TYPE`、`METHOD`、`FIELD`、`PARAMETER`、`CONSTRUCTOR`、`ANNOTATION_TYPE` があります。メタアノテーションを作る問題では `ANNOTATION_TYPE` が狙われます。
""",
        relatedTermIds: ["annotation", "meta-annotation", "retention-policy"]
    )
}
