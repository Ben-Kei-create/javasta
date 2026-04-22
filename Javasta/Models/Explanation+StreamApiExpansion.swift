import Foundation

extension Explanation {
    static let streamApiAuthoredSamples: [String: Explanation] = [
        goldStream014Explanation.id: goldStream014Explanation,
        goldStream015Explanation.id: goldStream015Explanation,
        goldStream016Explanation.id: goldStream016Explanation,
        goldStream017Explanation.id: goldStream017Explanation,
        goldStream018Explanation.id: goldStream018Explanation,
        goldStream019Explanation.id: goldStream019Explanation,
        goldOptional009Explanation.id: goldOptional009Explanation,
        goldOptional010Explanation.id: goldOptional010Explanation,
        goldStream020Explanation.id: goldStream020Explanation,
        goldStream021Explanation.id: goldStream021Explanation,
        goldStream022Explanation.id: goldStream022Explanation,
        goldOptional011Explanation.id: goldOptional011Explanation,
        goldOptional012Explanation.id: goldOptional012Explanation,
        goldOptional013Explanation.id: goldOptional013Explanation,
        goldStream023Explanation.id: goldStream023Explanation,
        goldStream024Explanation.id: goldStream024Explanation,
        goldStream025Explanation.id: goldStream025Explanation,
        goldStream026Explanation.id: goldStream026Explanation,
        goldStream027Explanation.id: goldStream027Explanation,
        goldStream028Explanation.id: goldStream028Explanation,
        goldStream029Explanation.id: goldStream029Explanation,
        goldStream030Explanation.id: goldStream030Explanation,
        goldStream031Explanation.id: goldStream031Explanation,
    ]

    private static func streamStep(
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

    private static func streamPrompt(
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

    static let goldStream014Explanation = Explanation(
        id: "explain-gold-stream-014",
        initialCode: """
long a = Stream.of(1, 2, 3).count();
int b = IntStream.rangeClosed(1, 3).sum();
System.out.println(a + ":" + b);
""",
        steps: [
            streamStep(0, "`Stream.of(1, 2, 3)` は参照型Streamを3要素で生成します。終端操作 `count()` は要素数のlong値を返します。", [1], variables: [Variable(name: "a", type: "long", value: "3", scope: "main")]),
            streamStep(1, "`IntStream.rangeClosed(1, 3)` は1,2,3を含むプリミティブStreamです。`sum()` の結果は6です。", [2], variables: [Variable(name: "b", type: "int", value: "6", scope: "main")], predict: streamPrompt("rangeClosedは3を含む？", ["含む", "含まない"], 0, "closedは閉区間です。", "正解です。1,2,3を流します。")),
            streamStep(2, "`a + \":\" + b` を評価して `3:6` が出力されます。", [3], variables: [Variable(name: "output", type: "String", value: "3:6", scope: "main")]),
        ]
    )

    static let goldStream015Explanation = Explanation(
        id: "explain-gold-stream-015",
        initialCode: """
String[] data = {"A", "B", "C", "D"};
long a = Arrays.stream(data, 1, 3).count();
long b = Stream.generate(() -> "x").limit(3).count();
System.out.println(a + ":" + b);
""",
        steps: [
            streamStep(0, "`Arrays.stream(data, 1, 3)` は開始インデックス1を含み、終了インデックス3を含みません。対象はB,Cの2要素です。", [1, 2], variables: [Variable(name: "a", type: "long", value: "2", scope: "main")]),
            streamStep(1, "`Stream.generate` は無限Streamを作れますが、`limit(3)` が先に3要素へ制限します。`count()` は3です。", [3], variables: [Variable(name: "b", type: "long", value: "3", scope: "main")], predict: streamPrompt("generateはここで無限ループになる？", ["なる", "ならない"], 1, "limitと遅延評価を見ます。", "正解です。終端操作が必要とする3件だけ生成されます。")),
            streamStep(2, "2件と3件を連結表示するため、出力は `2:3` です。", [4], variables: [Variable(name: "output", type: "String", value: "2:3", scope: "main")]),
        ]
    )

    static let goldStream016Explanation = Explanation(
        id: "explain-gold-stream-016",
        initialCode: """
Stream.of("A", "B", "C", "D")
    .skip(1)
    .limit(2)
    .forEach(System.out::print);
""",
        steps: [
            streamStep(0, "元の要素列はA,B,C,Dです。`skip(1)` により先頭Aが除外され、残りはB,C,Dです。", [1, 2], variables: [Variable(name: "after skip", type: "Stream<String>", value: "B,C,D", scope: "pipeline")]),
            streamStep(1, "`limit(2)` は残った要素の先頭2件だけを通します。ここではB,Cです。", [3], variables: [Variable(name: "after limit", type: "Stream<String>", value: "B,C", scope: "pipeline")], predict: streamPrompt("forEachに渡る要素は？", ["B,C", "B,C,D"], 0, "limit(2)です。", "正解です。2件だけです。")),
            streamStep(2, "`forEach(System.out::print)` が終端操作としてB,Cを順に出力します。", [4], variables: [Variable(name: "output", type: "String", value: "BC", scope: "main")]),
        ]
    )

    static let goldStream017Explanation = Explanation(
        id: "explain-gold-stream-017",
        initialCode: """
int result = Stream.of(2, 3, 4)
    .reduce(1, (a, b) -> a * b);
System.out.println(result);
""",
        steps: [
            streamStep(0, "identityありの `reduce` はOptionalではなく値そのものを返します。初期値は1です。", [1, 2], variables: [Variable(name: "accumulator", type: "int", value: "1", scope: "reduce")]),
            streamStep(1, "要素2,3,4を順に掛けます。1*2=2、2*3=6、6*4=24です。", [2], variables: [Variable(name: "result", type: "int", value: "24", scope: "main")], predict: streamPrompt("identityありreduceの戻り値型は？", ["int", "Optional<Integer>"], 0, "初期値がある形です。", "正解です。空Streamでもidentityを返せるためOptionalではありません。")),
            streamStep(2, "最終的に `24` が出力されます。", [3], variables: [Variable(name: "output", type: "int", value: "24", scope: "main")]),
        ]
    )

    static let goldStream018Explanation = Explanation(
        id: "explain-gold-stream-018",
        initialCode: """
Optional<Integer> result = Stream.<Integer>empty()
    .reduce(Integer::sum);
System.out.println(result.isPresent());
""",
        steps: [
            streamStep(0, "identityなしの `reduce(BinaryOperator)` は `Optional<T>` を返します。空Streamでは累積の元になる要素がありません。", [1, 2], variables: [Variable(name: "result", type: "Optional<Integer>", value: "Optional.empty", scope: "main")]),
            streamStep(1, "`isPresent()` は値が入っているかをbooleanで返します。空Optionalなのでfalseです。", [3], variables: [Variable(name: "result.isPresent()", type: "boolean", value: "false", scope: "main")], predict: streamPrompt("空Streamのidentityなしreduceは？", ["Optional.empty", "Optional.of(0)"], 0, "初期値0は指定していません。", "正解です。値を作れないので空Optionalです。")),
        ]
    )

    static let goldStream019Explanation = Explanation(
        id: "explain-gold-stream-019",
        initialCode: """
Object[] a = Stream.of("x", "y").toArray();
String[] b = Stream.of("x", "y").toArray(String[]::new);
System.out.println(a.length + ":" + b[1] + ":" + (a instanceof String[]));
""",
        steps: [
            streamStep(0, "引数なし `toArray()` の戻り値型は `Object[]` です。要素がStringでも配列の実行時型はString[]にはなりません。", [1], variables: [Variable(name: "a", type: "Object[]", value: "[x, y]", scope: "main")]),
            streamStep(1, "`toArray(String[]::new)` は生成関数により `String[]` を作ります。`b[1]` はyです。", [2], variables: [Variable(name: "b", type: "String[]", value: "[x, y]", scope: "main")], predict: streamPrompt("a instanceof String[] は？", ["true", "false"], 1, "aは引数なしtoArrayです。", "正解です。aの実行時型はObject[]です。")),
            streamStep(2, "長さ2、b[1]のy、`a instanceof String[]` のfalseを連結し、`2:y:false` です。", [3], variables: [Variable(name: "output", type: "String", value: "2:y:false", scope: "main")]),
        ]
    )

    static let goldOptional009Explanation = Explanation(
        id: "explain-gold-optional-009",
        initialCode: """
Optional<String> opt = Optional.empty();
try {
    System.out.println(opt.get());
} catch (NoSuchElementException e) {
    System.out.println("empty");
}
""",
        steps: [
            streamStep(0, "`Optional.empty()` は値を持たないOptionalです。変数optの中身は空です。", [1], variables: [Variable(name: "opt", type: "Optional<String>", value: "empty", scope: "main")]),
            streamStep(1, "空Optionalに `get()` を呼ぶと、nullではなく `NoSuchElementException` が投げられます。", [3, 4], predict: streamPrompt("空Optional.get()の結果は？", ["null", "NoSuchElementException"], 1, "Optionalはnullを返してごまかしません。", "正解です。getは空なら例外です。")),
            streamStep(2, "catch節に入り、`empty` が出力されます。", [4, 5], variables: [Variable(name: "output", type: "String", value: "empty", scope: "main")]),
        ]
    )

    static let goldOptional010Explanation = Explanation(
        id: "explain-gold-optional-010",
        initialCode: """
Optional<String> opt = Optional.of("java");
if (opt.isPresent()) {
    System.out.println(opt.get().toUpperCase());
} else {
    System.out.println("empty");
}
""",
        steps: [
            streamStep(0, "`Optional.of(\"java\")` で値ありOptionalを作ります。`isPresent()` はtrueです。", [1, 2], variables: [Variable(name: "opt.isPresent()", type: "boolean", value: "true", scope: "main")]),
            streamStep(1, "true側に入り、`get()` でjavaを取り出して `toUpperCase()` を呼びます。", [3], variables: [Variable(name: "opt.get()", type: "String", value: "java", scope: "main")], predict: streamPrompt("出力直前の文字列は？", ["JAVA", "empty"], 0, "ifのtrue側を通ります。", "正解です。javaを大文字化します。")),
            streamStep(2, "出力は `JAVA` です。", [3], variables: [Variable(name: "output", type: "String", value: "JAVA", scope: "main")]),
        ]
    )

    static let goldStream020Explanation = Explanation(
        id: "explain-gold-stream-020",
        initialCode: """
String result = Stream.of("aa", "b", "cccc")
    .max(Comparator.comparingInt(String::length))
    .get();
System.out.println(result);
""",
        steps: [
            streamStep(0, "`Comparator.comparingInt(String::length)` は文字列の長さを比較キーにします。長さはaa=2、b=1、cccc=4です。", [1, 2], variables: [Variable(name: "lengths", type: "comparison key", value: "2,1,4", scope: "max")]),
            streamStep(1, "`max` は最大要素を `Optional<String>` として返します。最大はccccです。", [2, 3], variables: [Variable(name: "max", type: "Optional<String>", value: "Optional[cccc]", scope: "pipeline")], predict: streamPrompt("get()後の値は？", ["cccc", "Optional[cccc]"], 0, "getは中身を取り出します。", "正解です。Stringのccccです。")),
            streamStep(2, "取り出したStringを出力するため、`cccc` が表示されます。", [4], variables: [Variable(name: "result", type: "String", value: "cccc", scope: "main")]),
        ]
    )

    static let goldStream021Explanation = Explanation(
        id: "explain-gold-stream-021",
        initialCode: """
String result = Stream.of("bb", "a", "ccc")
    .filter(s -> s.length() <= 2)
    .findFirst()
    .orElse("none");
System.out.println(result);
""",
        steps: [
            streamStep(0, "filter条件 `length() <= 2` により、bbとaが残り、cccは除外されます。", [1, 2], variables: [Variable(name: "after filter", type: "Stream<String>", value: "bb,a", scope: "pipeline")]),
            streamStep(1, "順序付きStreamなので `findFirst()` は残った要素の先頭bbをOptionalで返します。", [3], variables: [Variable(name: "findFirst", type: "Optional<String>", value: "Optional[bb]", scope: "pipeline")], predict: streamPrompt("findFirstが見る順序は？", ["元の遭遇順", "文字列の短い順"], 0, "sortedはありません。", "正解です。元のStreamの順序です。")),
            streamStep(2, "Optionalに値があるため `orElse(\"none\")` は使われず、出力は `bb` です。", [4, 5], variables: [Variable(name: "result", type: "String", value: "bb", scope: "main")]),
        ]
    )

    static let goldStream022Explanation = Explanation(
        id: "explain-gold-stream-022",
        initialCode: """
String result = Stream.of("A", "B", "C")
    .parallel()
    .findAny()
    .orElse("none");
System.out.println(result);
""",
        steps: [
            streamStep(0, "`parallel()` により並列実行可能なStreamになります。要素自体はA,B,Cの3つです。", [1, 2], variables: [Variable(name: "source", type: "Stream<String>", value: "A,B,C", scope: "pipeline")]),
            streamStep(1, "`findAny()` は名前の通り任意の要素を返せます。特にparallelでは先頭Aとは限りません。", [3], variables: [Variable(name: "findAny", type: "Optional<String>", value: "A/B/Cのいずれか", scope: "pipeline")], predict: streamPrompt("順序保証が必要なら？", ["findFirst", "findAny"], 0, "Firstが順序を示します。", "正解です。順序付きの先頭が欲しいならfindFirstです。")),
            streamStep(2, "Optionalに値があるためnoneにはならず、A/B/Cのいずれかが出力され得ます。", [4, 5], variables: [Variable(name: "result", type: "String", value: "A or B or C", scope: "main")]),
        ]
    )

    static let goldOptional011Explanation = Explanation(
        id: "explain-gold-optional-011",
        initialCode: """
static String fallback() {
    System.out.print("F");
    return "fallback";
}
String result = Optional.of("value").orElse(fallback());
System.out.println(result);
""",
        steps: [
            streamStep(0, "`orElse(fallback())` の引数は通常のメソッド引数なので、Optionalの中身を見る前に `fallback()` が評価されます。", [5], predict: streamPrompt("値ありOptionalでもfallbackは呼ばれる？", ["呼ばれる", "呼ばれない"], 0, "orElseの引数は値そのものです。", "正解です。先に評価されます。")),
            streamStep(1, "`fallback()` が実行されてFを出力します。ただしOptionalにはvalueがあるため、戻り値fallbackは採用されません。", [1, 2, 3, 5], variables: [Variable(name: "result", type: "String", value: "value", scope: "main")]),
            streamStep(2, "その後 `println(result)` がvalueを出力します。全体の出力は `Fvalue` です。", [6], variables: [Variable(name: "output", type: "String", value: "Fvalue", scope: "main")]),
        ]
    )

    static let goldOptional012Explanation = Explanation(
        id: "explain-gold-optional-012",
        initialCode: """
static String fallback() {
    System.out.print("F");
    return "fallback";
}
String result = Optional.of("value").orElseGet(() -> fallback());
System.out.println(result);
""",
        steps: [
            streamStep(0, "`orElseGet` はSupplierを受け取ります。Supplierは必要になった時だけ実行されます。", [5], predict: streamPrompt("値ありOptionalでSupplierは実行される？", ["実行される", "実行されない"], 1, "Optionalにはvalueがあります。", "正解です。代替値は不要なので実行されません。")),
            streamStep(1, "Optionalにvalueが入っているため `fallback()` は呼ばれません。Fは出力されず、resultはvalueです。", [5], variables: [Variable(name: "result", type: "String", value: "value", scope: "main")]),
            streamStep(2, "`println(result)` により `value` だけが出力されます。", [6], variables: [Variable(name: "output", type: "String", value: "value", scope: "main")]),
        ]
    )

    static let goldOptional013Explanation = Explanation(
        id: "explain-gold-optional-013",
        initialCode: """
try {
    Optional.<String>empty()
        .orElseThrow(() -> new IllegalStateException("none"));
} catch (IllegalStateException e) {
    System.out.println(e.getMessage());
}
""",
        steps: [
            streamStep(0, "`Optional.<String>empty()` は空Optionalです。`orElseThrow` は空の場合、渡されたSupplierで例外を作ります。", [1, 2, 3], predict: streamPrompt("Supplierは実行される？", ["実行される", "実行されない"], 0, "Optionalは空です。", "正解です。例外が必要なので実行されます。")),
            streamStep(1, "`new IllegalStateException(\"none\")` が生成されて投げられ、catch節へ移動します。", [3, 4], variables: [Variable(name: "e.message", type: "String", value: "none", scope: "catch")]),
            streamStep(2, "`e.getMessage()` はnoneなので、出力は `none` です。", [5], variables: [Variable(name: "output", type: "String", value: "none", scope: "main")]),
        ]
    )

    static let goldStream023Explanation = Explanation(
        id: "explain-gold-stream-023",
        initialCode: """
Stream.of(1, 2, 2, 3, 4)
    .filter(n -> n % 2 == 0)
    .distinct()
    .skip(1)
    .limit(1)
    .forEach(System.out::print);
""",
        steps: [
            streamStep(0, "元の要素列1,2,2,3,4から、filterで偶数だけを残すと2,2,4です。", [1, 2], variables: [Variable(name: "after filter", type: "Stream<Integer>", value: "2,2,4", scope: "pipeline")]),
            streamStep(1, "`distinct()` で重複した2が1つになり、2,4になります。さらに `skip(1)` で先頭2を飛ばして4だけが残ります。", [3, 4], variables: [Variable(name: "after skip", type: "Stream<Integer>", value: "4", scope: "pipeline")], predict: streamPrompt("limit(1)後に出る値は？", ["2", "4"], 1, "skip後の残りを見ます。", "正解です。残っている4です。")),
            streamStep(2, "`limit(1)` は4をそのまま通し、forEachが `4` を出力します。", [5, 6], variables: [Variable(name: "output", type: "int", value: "4", scope: "main")]),
        ]
    )

    static let goldStream024Explanation = Explanation(
        id: "explain-gold-stream-024",
        initialCode: """
long a = Stream.of("ab", "cd")
    .map(s -> s.split(""))
    .count();
long b = Stream.of("ab", "cd")
    .flatMap(s -> Arrays.stream(s.split("")))
    .count();
System.out.println(a + ":" + b);
""",
        steps: [
            streamStep(0, "`map(s -> s.split(\"\"))` は各StringをString配列へ変換します。Streamの要素数は配列2個なのでcountは2です。", [1, 2, 3], variables: [Variable(name: "a", type: "long", value: "2", scope: "main")]),
            streamStep(1, "`flatMap` は各配列から作ったStreamを1本に平坦化します。a,b,c,dの4要素になるためcountは4です。", [4, 5, 6], variables: [Variable(name: "b", type: "long", value: "4", scope: "main")], predict: streamPrompt("map側の要素型は？", ["String[]", "String"], 0, "splitの戻り値です。", "正解です。mapだけでは配列の中身を平坦化しません。")),
            streamStep(2, "2と4を連結し、出力は `2:4` です。", [7], variables: [Variable(name: "output", type: "String", value: "2:4", scope: "main")]),
        ]
    )

    static let goldStream025Explanation = Explanation(
        id: "explain-gold-stream-025",
        initialCode: """
Stream.of("bb", "a", "ccc")
    .sorted(Comparator.comparingInt(String::length).reversed())
    .forEach(s -> System.out.print(s.length()));
""",
        steps: [
            streamStep(0, "`comparingInt(String::length)` は長さで比較します。`reversed()` が付いているので長い順です。", [1, 2], variables: [Variable(name: "sort key", type: "int", value: "length descending", scope: "pipeline")]),
            streamStep(1, "並び順はccc、bb、aです。forEachでは各文字列の長さ3,2,1を出力します。", [2, 3], variables: [Variable(name: "after sorted", type: "Stream<String>", value: "ccc,bb,a", scope: "pipeline")], predict: streamPrompt("reversed後の先頭は？", ["a", "ccc"], 1, "長さの降順です。", "正解です。最長のcccです。")),
            streamStep(2, "最終出力は `321` です。", [3], variables: [Variable(name: "output", type: "String", value: "321", scope: "main")]),
        ]
    )

    static let goldStream026Explanation = Explanation(
        id: "explain-gold-stream-026",
        initialCode: """
Stream.of("A", "B")
    .peek(System.out::print)
    .forEach(s -> System.out.print(s.toLowerCase()));
""",
        steps: [
            streamStep(0, "`peek` は中間操作なので、単独では実行されません。ただし今回は終端操作 `forEach` があります。", [1, 2, 3], predict: streamPrompt("このpeekは実行される？", ["実行される", "実行されない"], 0, "forEachが終端操作です。", "正解です。終端操作があるので実行されます。")),
            streamStep(1, "Streamは要素ごとに処理が流れます。AではpeekがAを出し、forEachがaを出します。Bでも同様にB,bです。", [2, 3], variables: [Variable(name: "element order", type: "String", value: "A,a,B,b", scope: "pipeline")]),
            streamStep(2, "連続した出力は `AaBb` です。", [3], variables: [Variable(name: "output", type: "String", value: "AaBb", scope: "main")]),
        ]
    )

    static let goldStream027Explanation = Explanation(
        id: "explain-gold-stream-027",
        initialCode: """
List<Integer> list = Stream.of("a", "bb", "ccc")
    .mapToInt(String::length)
    .boxed()
    .collect(Collectors.toList());
System.out.println(list);
""",
        steps: [
            streamStep(0, "`mapToInt(String::length)` により `Stream<String>` から `IntStream` へ変換され、値は1,2,3です。", [1, 2], variables: [Variable(name: "int values", type: "IntStream", value: "1,2,3", scope: "pipeline")]),
            streamStep(1, "`boxed()` はIntStreamのintをIntegerへ箱詰めし、`Stream<Integer>` に戻します。これでCollectors.toListを使えます。", [3, 4], variables: [Variable(name: "list", type: "List<Integer>", value: "[1, 2, 3]", scope: "main")], predict: streamPrompt("boxed後の型は？", ["IntStream", "Stream<Integer>"], 1, "boxedは参照型へ戻します。", "正解です。IntegerのStreamです。")),
            streamStep(2, "ListのtoStringにより `[1, 2, 3]` が出力されます。", [5], variables: [Variable(name: "output", type: "String", value: "[1, 2, 3]", scope: "main")]),
        ]
    )

    static let goldStream028Explanation = Explanation(
        id: "explain-gold-stream-028",
        initialCode: """
int result = Stream.of("A", "B")
    .flatMapToInt(String::chars)
    .sum();
System.out.println(result);
""",
        steps: [
            streamStep(0, "`String::chars` は各文字列から文字コードのIntStreamを返します。Aは65、Bは66です。", [1, 2], variables: [Variable(name: "chars", type: "IntStream", value: "65,66", scope: "pipeline")]),
            streamStep(1, "`flatMapToInt` は複数のIntStreamを1本のIntStreamに平坦化します。その後 `sum()` で65+66を計算します。", [2, 3], variables: [Variable(name: "result", type: "int", value: "131", scope: "main")], predict: streamPrompt("sumの対象は文字数？", ["文字数", "文字コード"], 1, "String::charsです。", "正解です。char値のintを流します。")),
            streamStep(2, "出力は `131` です。", [4], variables: [Variable(name: "output", type: "int", value: "131", scope: "main")]),
        ]
    )

    static let goldStream029Explanation = Explanation(
        id: "explain-gold-stream-029",
        initialCode: """
String result = Stream.of("a", "bb", "c")
    .map(String::toUpperCase)
    .collect(Collectors.joining("-"));
System.out.println(result);
""",
        steps: [
            streamStep(0, "`map(String::toUpperCase)` で各要素はA、BB、Cに変換されます。", [1, 2], variables: [Variable(name: "after map", type: "Stream<String>", value: "A,BB,C", scope: "pipeline")]),
            streamStep(1, "`Collectors.joining(\"-\")` は要素の間にハイフンを入れて1つのStringへ収集します。", [3], variables: [Variable(name: "result", type: "String", value: "A-BB-C", scope: "main")], predict: streamPrompt("joiningの戻り値は？", ["String", "List<String>"], 0, "joinは連結です。", "正解です。1つのStringになります。")),
            streamStep(2, "出力は `A-BB-C` です。", [4], variables: [Variable(name: "output", type: "String", value: "A-BB-C", scope: "main")]),
        ]
    )

    static let goldStream030Explanation = Explanation(
        id: "explain-gold-stream-030",
        initialCode: """
Map<Integer, Long> map = Stream.of("a", "bb", "c")
    .collect(Collectors.groupingBy(
        String::length,
        Collectors.counting()
    ));
System.out.println(map.get(1) + ":" + map.get(2));
""",
        steps: [
            streamStep(0, "`groupingBy(String::length, counting())` は長さをキーにして件数を数えます。aとcは長さ1、bbは長さ2です。", [1, 2, 3, 4, 5], variables: [Variable(name: "groups", type: "Map<Integer, Long>", value: "{1=2, 2=1}", scope: "main")]),
            streamStep(1, "`Collectors.counting()` の値型はLongです。`map.get(1)` は2、`map.get(2)` は1です。", [6], variables: [Variable(name: "map.get(1)", type: "Long", value: "2", scope: "main"), Variable(name: "map.get(2)", type: "Long", value: "1", scope: "main")], predict: streamPrompt("長さ1の要素数は？", ["1", "2"], 1, "aとcです。", "正解です。2件です。")),
            streamStep(2, "出力は `2:1` です。", [6], variables: [Variable(name: "output", type: "String", value: "2:1", scope: "main")]),
        ]
    )

    static let goldStream031Explanation = Explanation(
        id: "explain-gold-stream-031",
        initialCode: """
try {
    Map<Integer, String> map = Stream.of("a", "b")
        .collect(Collectors.toMap(String::length, s -> s));
    System.out.println(map);
} catch (IllegalStateException e) {
    System.out.println("duplicate");
}
""",
        steps: [
            streamStep(0, "`Collectors.toMap(String::length, s -> s)` は文字列の長さをキーにします。aもbも長さ1なのでキーが重複します。", [2, 3], variables: [Variable(name: "keys", type: "Integer", value: "1,1", scope: "collector")]),
            streamStep(1, "マージ関数を指定していない `toMap` は重複キーを自動上書きしません。`IllegalStateException` が発生します。", [3, 5], predict: streamPrompt("重複キーは自動で後勝ちになる？", ["なる", "ならない"], 1, "マージ関数がありません。", "正解です。例外になります。")),
            streamStep(2, "catch節で `duplicate` が出力されます。", [5, 6], variables: [Variable(name: "output", type: "String", value: "duplicate", scope: "main")]),
        ]
    )
}
