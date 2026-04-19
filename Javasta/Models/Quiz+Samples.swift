import Foundation

extension Quiz {
    static let samples: [Quiz] = [
        silverOverload001,
        silverException001,
        silverString001,
        silverAutoboxing001,
        silverSwitch001,
        silverOverload002,
        silverArrayDefaults001,
        silverInheritance001,
        silverMultiFileOverride001,
        silverControlFlow001,
        silverConstructor001,
        silverStringBuilder001,
        goldGenerics001,
        goldStream001,
        goldOptional001,
        goldOptional002,
        goldStream002,
        goldGenerics002,
        goldClasses001,
        goldConcurrency001,
        goldPathNormalize001,
        silverException002,
    ]

    // MARK: - Silver: 例外処理 (try-with-resources)
        static let silverException002 = Quiz(
            id: "silver-exception-002",
            level: .silver,
            category: "exception-handling",
            tags: ["try-with-resources", "AutoCloseable", "リソース解放"],
            code: """
    public class Test {
        static class Resource implements AutoCloseable {
            String name;
            Resource(String name) { this.name = name; }
            public void close() { System.out.print(name + " "); }
        }

        public static void main(String[] args) {
            try (Resource r1 = new Resource("A");
                 Resource r2 = new Resource("B")) {
                System.out.print("Run ");
            }
        }
    }
    """,
            question: "このコードを実行したとき、出力される結果はどれか？",
            choices: [
                Choice(id: "a", text: "Run A B",
                       correct: false, misconception: "宣言した順にクローズされると誤解",
                       explanation: "try-with-resources文では、リソースは宣言された順序とは逆（LIFO: 後入れ先出し）の順にクローズされます。"),
                Choice(id: "b", text: "Run B A",
                       correct: true, misconception: nil,
                       explanation: "tryブロック内の処理が実行された後、r2、r1の順（宣言の逆順）で自動的にclose()メソッドが呼び出されます。"),
                Choice(id: "c", text: "A B Run",
                       correct: false, misconception: "tryブロックの前にクローズされると誤解",
                       explanation: "リソースのクローズは、tryブロックの処理（または例外発生時）の後に行われます。"),
                Choice(id: "d", text: "コンパイルエラー",
                       correct: false, misconception: "catchやfinallyブロックが必須であると誤解",
                       explanation: "try-with-resources文では、catchブロックやfinallyブロックは省略可能です。"),
            ],
            explanationRef: "explain-silver-exception-002",
            designIntent: "try-with-resources文における、複数リソースの自動クローズの実行順序（逆順）を見抜かせる。"
        )

        // MARK: - Silver: コレクション (List.of)
        static let silverCollections001 = Quiz(
            id: "silver-collections-001",
            level: .silver,
            category: "collections",
            tags: ["List.of", "NullPointerException", "不変コレクション"],
            code: """
    import java.util.List;

    public class Test {
        public static void main(String[] args) {
            try {
                var list = List.of("Apple", null, "Banana");
                System.out.println(list.size());
            } catch (NullPointerException e) {
                System.out.println("NPE");
            } catch (UnsupportedOperationException e) {
                System.out.println("UOE");
            }
        }
    }
    """,
            question: "このコードを実行したとき、出力される結果はどれか？",
            choices: [
                Choice(id: "a", text: "3",
                       correct: false, misconception: "nullを要素として許容すると誤解",
                       explanation: "List.of() はnullを要素として追加することを許可していません。"),
                Choice(id: "b", text: "2",
                       correct: false, misconception: "nullが無視されてリストが生成されると誤解",
                       explanation: "nullを無視する仕様はなく、実行時に例外がスローされます。"),
                Choice(id: "c", text: "NPE",
                       correct: true, misconception: nil,
                       explanation: "List.of() の引数にnullを渡すと、オブジェクト生成の時点で NullPointerException がスローされます。"),
                Choice(id: "d", text: "UOE",
                       correct: false, misconception: "不変コレクション関連の例外と混同",
                       explanation: "UnsupportedOperationException は生成後のリストに add() や set() を行った場合に発生します。生成時のnullチェックはNPEです。"),
            ],
            explanationRef: "explain-silver-collections-001",
            designIntent: "Java 9で導入された不変コレクションファクトリ(List.of等)がnullを許容しない仕様を確認する。"
        )

        // MARK: - Gold: 並行処理 (ExecutorService)
        static let goldConcurrency001 = Quiz(
            id: "gold-concurrency-001",
            level: .gold,
            category: "concurrency",
            tags: ["ExecutorService", "submit", "Future"],
            code: """
    import java.util.concurrent.*;

    public class Test {
        public static void main(String[] args) throws InterruptedException {
            ExecutorService es = Executors.newSingleThreadExecutor();
            Future<?> future = es.submit(() -> {
                throw new RuntimeException("Error!");
            });
            
            Thread.sleep(100); // 確実な実行待ち
            System.out.println("Done");
            es.shutdown();
        }
    }
    """,
            question: "このコードを実行したときの挙動として正しいものはどれか？",
            choices: [
                Choice(id: "a", text: "スタックトレースが出力され、Done が表示されずにプログラムが異常終了する",
                       correct: false, misconception: "別スレッドの例外がメインスレッドを停止させると誤解",
                       explanation: "submit()内で発生した例外はFutureオブジェクトにキャッチされ、メインスレッドには影響しません。"),
                Choice(id: "b", text: "スタックトレースが出力された後、Done が表示される",
                       correct: false, misconception: "例外がコンソールに自動出力されると誤解",
                       explanation: "submit()では例外は自動で標準エラー出力には出ません。execute()メソッドの場合は出力されます。"),
                Choice(id: "c", text: "コンパイルエラー",
                       correct: false, misconception: "Runnableが例外をスローできないと誤解",
                       explanation: "非チェック例外(RuntimeException)はスロー可能です。Callableとしても解釈可能です。"),
                Choice(id: "d", text: "例外はコンソールに出力されず、Done が表示される",
                       correct: true, misconception: nil,
                       explanation: "submit()でタスクを投げた場合、発生した例外はFuture内に保持されます。future.get()を呼び出さない限り、例外は表に出ません。"),
            ],
            explanationRef: "explain-gold-concurrency-001",
            designIntent: "ExecutorServiceのsubmit()メソッドにおける例外のハンドリング仕様（Futureの挙動）を見抜かせる。"
        )

        // MARK: - Gold: 入出力 (NIO.2 Path)
        static let goldIo001 = Quiz(
            id: "gold-io-001",
            level: .gold,
            category: "io",
            tags: ["NIO.2", "Path", "resolve"],
            code: """
    import java.nio.file.Path;

    public class Test {
        public static void main(String[] args) {
            Path p1 = Path.of("/app/logs");
            Path p2 = Path.of("/backup/data");
            Path result = p1.resolve(p2);
            
            System.out.println(result.getNameCount());
        }
    }
    """,
            question: "このコードを実行したとき、出力される結果はどれか？",
            choices: [
                Choice(id: "a", text: "2",
                       correct: true, misconception: nil,
                       explanation: "resolve()の引数に「絶対パス」を渡した場合、引数の絶対パスがそのまま返されます。/backup/data のルートを除く要素数は backup と data の「2」です。"),
                Choice(id: "b", text: "4",
                       correct: false, misconception: "パスが単純に連結されると誤解",
                       explanation: "/app/logs/backup/data と連結されるのは、引数が相対パス（例: backup/data）の場合です。"),
                Choice(id: "c", text: "実行時エラー",
                       correct: false, misconception: "異なるルートディレクトリの解決は例外になると誤解",
                       explanation: "引数が絶対パスの場合は、例外は出ずに引数のパスに置き換わります。"),
                Choice(id: "d", text: "コンパイルエラー",
                       correct: false, misconception: "Pathインターフェースの使い方の誤解",
                       explanation: "Path.of() や resolve() の使用方法は構文的に正しいです。"),
            ],
            explanationRef: "explain-gold-io-001",
            designIntent: "NIO.2 の Path.resolve() において、引数が絶対パスの場合の特殊な挙動と、getNameCount()の数え方を同時に確認する。"
        )
    
    static let silverOverload001 = Quiz(
        id: "silver-overload-001",
        level: .silver,
        category: "overload-resolution",
        tags: ["オーバーロード", "型解決"],
        code: """
public class Test {
    static void print(int x) {
        System.out.println("int: " + x);
    }
    static void print(long x) {
        System.out.println("long: " + x);
    }
    public static void main(String[] args) {
        print(5);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "int: 5",
                   correct: true, misconception: nil,
                   explanation: "5はintリテラル。Javaのオーバーロード解決は完全一致を最優先するため、print(int)が選ばれます。"),
            Choice(id: "b", text: "long: 5",
                   correct: false, misconception: "型の自動昇格が常に起こると誤解",
                   explanation: "int→longへの昇格は完全一致するメソッドがない場合のみ。ここではprint(int)と完全一致するため昇格しません。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "オーバーロードが曖昧と誤解",
                   explanation: "5はintリテラルなのでprint(int)と完全一致します。曖昧さはなく、コンパイルエラーにはなりません。"),
            Choice(id: "d", text: "実行時エラー",
                   correct: false, misconception: nil,
                   explanation: "このコードに実行時エラーの要因はありません。正常にコンパイル・実行されます。"),
        ],
        explanationRef: "explain-silver-overload-001",
        designIntent: "Javaのオーバーロード解決は「完全一致 → 型昇格 → オートボクシング → 可変長引数」の順で試みられます。"
    )

    static let silverException001 = Quiz(
        id: "silver-exception-001",
        level: .silver,
        category: "exception-handling",
        tags: ["finally", "return"],
        code: """
public class Test {
    static int calc() {
        try {
            return 1;
        } finally {
            return 2;
        }
    }
    public static void main(String[] args) {
        System.out.println(calc());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1",
                   correct: false, misconception: "tryのreturnが優先されると誤解",
                   explanation: "tryのreturnは一時保留され、finallyが必ず実行されます。finallyにreturnがある場合、それが最終的な戻り値になります。"),
            Choice(id: "b", text: "2",
                   correct: true, misconception: nil,
                   explanation: "finallyブロックのreturnはtryブロックのreturnを上書きします。このためcalc()は2を返し、2が出力されます。"),
            Choice(id: "c", text: "1と2",
                   correct: false, misconception: nil,
                   explanation: "メソッドは必ず1つのreturnだけが実行されます。finallyのreturnが勝ちます。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: nil,
                   explanation: "このコードは文法的に正しく、コンパイルエラーにはなりません。"),
        ],
        explanationRef: "explain-silver-exception-001",
        designIntent: "finallyブロック内でreturnを書くと、tryやcatchのreturnを無条件に上書きします。実務では意図せず書かないよう注意が必要です。"
    )

    static let goldGenerics001 = Quiz(
        id: "gold-generics-001",
        level: .gold,
        category: "generics",
        tags: ["ワイルドカード", "上限境界", "PECS"],
        code: """
import java.util.*;

public class Test {
    static double sum(List<? extends Number> list) {
        double total = 0;
        for (Number n : list) {
            total += n.doubleValue();
        }
        return total;
    }
    public static void main(String[] args) {
        List<Integer> ints = Arrays.asList(1, 2, 3);
        System.out.println(sum(ints));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "6.0",
                   correct: true, misconception: nil,
                   explanation: "1+2+3=6をdouble型で返します。println(double)は小数点付きの6.0を出力します。List<Integer>はList<? extends Number>として渡せます。"),
            Choice(id: "b", text: "6",
                   correct: false, misconception: "double型がintのように出力されると誤解",
                   explanation: "戻り値はdouble型です。System.out.println(double)は必ず小数点付きで出力するため6ではなく6.0になります。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "List<Integer>をList<? extends Number>に渡せないと誤解",
                   explanation: "<? extends Number>はNumberのサブタイプのリストを受け取れます。IntegerはNumberのサブタイプなので問題ありません。"),
            Choice(id: "d", text: "ClassCastException",
                   correct: false, misconception: nil,
                   explanation: "IntegerはNumberのサブタイプとして型安全に扱えます。ClassCastExceptionは発生しません。"),
        ],
        explanationRef: "explain-gold-generics-001",
        designIntent: "<? extends T>はT型のサブタイプを持つコレクションをread-onlyで扱うパターンです。PECSの法則：Producer Extends, Consumer Super。"
    )

    // MARK: - Silver: 文字列の比較 (== vs equals)

    static let silverString001 = Quiz(
        id: "silver-string-001",
        level: .silver,
        category: "string",
        tags: ["String", "==", "equals", "プール"],
        code: """
public class Test {
    public static void main(String[] args) {
        String a = "hello";
        String b = "hello";
        String c = new String("hello");
        System.out.println((a == b) + " " + (a == c));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "true true",
                   correct: false, misconception: "==が常に内容を比較すると誤解",
                   explanation: "==は参照の同一性を比較します。new Stringで作ったcはプール外の別オブジェクトなのでa==cはfalseです。"),
            Choice(id: "b", text: "true false",
                   correct: true, misconception: nil,
                   explanation: "リテラル \"hello\" は文字列定数プールで共有されるためa==bはtrue。new String(\"hello\")は別オブジェクトを生成するためa==cはfalse。"),
            Choice(id: "c", text: "false false",
                   correct: false, misconception: "Stringの比較は常に==では一致しないと誤解",
                   explanation: "リテラル同士はプールで共有されるためa==bはtrueです。"),
            Choice(id: "d", text: "false true",
                   correct: false, misconception: nil,
                   explanation: "プール内のリテラルとnew Stringは別の参照になるため、a==cがtrueになることはありません。"),
        ],
        explanationRef: "explain-silver-string-001",
        designIntent: "Stringの==比較は参照（メモリアドレス）の比較。内容を比較するには必ずequals()を使う、というSilver頻出ポイント。"
    )

    // MARK: - Silver: オートボクシングとIntegerキャッシュ

    static let silverAutoboxing001 = Quiz(
        id: "silver-autoboxing-001",
        level: .silver,
        category: "data-types",
        tags: ["オートボクシング", "Integer", "キャッシュ"],
        code: """
public class Test {
    public static void main(String[] args) {
        Integer a = 100;
        Integer b = 100;
        Integer c = 200;
        Integer d = 200;
        System.out.println((a == b) + " " + (c == d));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "true true",
                   correct: false, misconception: "Integer同士の==は常に値を比較すると誤解",
                   explanation: "Integerは参照型。==は参照比較で、200はキャッシュ範囲外なので別オブジェクトになります。"),
            Choice(id: "b", text: "true false",
                   correct: true, misconception: nil,
                   explanation: "Javaは-128〜127のIntegerをキャッシュして共有します。100は同じ参照、200は別の参照になります。"),
            Choice(id: "c", text: "false false",
                   correct: false, misconception: nil,
                   explanation: "100はIntegerキャッシュで共有されるためa==bはtrueです。"),
            Choice(id: "d", text: "false true",
                   correct: false, misconception: nil,
                   explanation: "200はキャッシュ範囲外なのでc==dはfalseになります。"),
        ],
        explanationRef: "explain-silver-autoboxing-001",
        designIntent: "Integer.valueOf()の内部キャッシュ（-128〜127）が引き起こす落とし穴。Wrapper同士の比較は必ずequalsを使うべき。"
    )

    // MARK: - Silver: switchのフォールスルー

    static let silverSwitch001 = Quiz(
        id: "silver-switch-001",
        level: .silver,
        category: "control-flow",
        tags: ["switch", "break", "フォールスルー"],
        code: """
public class Test {
    public static void main(String[] args) {
        int x = 2;
        switch (x) {
            case 1: System.out.print("A");
            case 2: System.out.print("B");
            case 3: System.out.print("C");
                break;
            case 4: System.out.print("D");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "B",
                   correct: false, misconception: "case毎に自動でbreakが入ると誤解",
                   explanation: "case 2: で実行が始まりますが、breakがないため case 3: に流れ落ちます（フォールスルー）。"),
            Choice(id: "b", text: "BC",
                   correct: true, misconception: nil,
                   explanation: "x=2でcase 2:に入り、break無しでcase 3:にフォールスルーします。case 3:にbreakがあるためそこで終了し、BとCが出力されます。"),
            Choice(id: "c", text: "BCD",
                   correct: false, misconception: nil,
                   explanation: "case 3: にbreakがあるためそこでswitchを抜けます。case 4: には到達しません。"),
            Choice(id: "d", text: "ABCD",
                   correct: false, misconception: nil,
                   explanation: "switchはマッチしたcaseから実行を始めます。case 1: は実行されません。"),
        ],
        explanationRef: "explain-silver-switch-001",
        designIntent: "従来のswitch文はbreakがないと次のcaseに流れる「フォールスルー」が発生。Java 14以降のswitch式（→）ではこの問題は起きない。"
    )

    // MARK: - Gold: Stream API（filter/map/collect）

    static let goldStream001 = Quiz(
        id: "gold-stream-001",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "filter", "map", "中間操作"],
        code: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        List<Integer> nums = List.of(1, 2, 3, 4, 5);
        int result = nums.stream()
            .filter(n -> n % 2 == 0)
            .mapToInt(Integer::intValue)
            .sum();
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "6",
                   correct: true, misconception: nil,
                   explanation: "filter で偶数 [2, 4] を抽出し、mapToInt で IntStream に変換、sum で合計 2+4=6 が得られます。"),
            Choice(id: "b", text: "9",
                   correct: false, misconception: "filterの条件を奇数と勘違い",
                   explanation: "n % 2 == 0 は偶数のみ通すフィルタです。奇数（1+3+5=9）ではありません。"),
            Choice(id: "c", text: "15",
                   correct: false, misconception: "filterが効いていないと誤解",
                   explanation: "filterによって偶数だけが残ります。全要素の合計15ではありません。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "Integer::intValueがIntStreamに変換できないと誤解",
                   explanation: "mapToIntはToIntFunctionを受け取り、Integer::intValueはint値を返すメソッド参照として有効です。"),
        ],
        explanationRef: "explain-gold-stream-001",
        designIntent: "Stream APIは「中間操作（filter/map）→終端操作（sum/collect）」のパイプライン。中間操作は遅延評価され、終端操作で初めて実行される。"
    )

    // MARK: - Gold: Optional

    static let goldOptional001 = Quiz(
        id: "gold-optional-001",
        level: .gold,
        category: "optional-api",
        tags: ["Optional", "ofNullable", "orElse"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        String s = null;
        String result = Optional.ofNullable(s)
            .map(String::toUpperCase)
            .orElse("DEFAULT");
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "DEFAULT",
                   correct: true, misconception: nil,
                   explanation: "ofNullable(null)は空のOptionalを返します。空に対するmapは空のままで、orElseの引数 \"DEFAULT\" が返されます。"),
            Choice(id: "b", text: "null",
                   correct: false, misconception: "Optionalがnullをそのまま伝搬すると誤解",
                   explanation: "Optionalの目的はまさにnullを安全に扱うことです。orElseで明示的にデフォルト値が返されます。"),
            Choice(id: "c", text: "NullPointerException",
                   correct: false, misconception: "ofNullableがNPEを投げると誤解",
                   explanation: "ofNullableはnullを受け取っても例外を投げず、空のOptionalを返します。NPEを投げるのは of() の方。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: nil,
                   explanation: "Optional.ofNullable は null 許容のファクトリで、文法的に問題ありません。"),
        ],
        explanationRef: "explain-gold-optional-001",
        designIntent: "of() はnullを受けるとNPE。ofNullable() はnullを空Optionalに変換。orElseは値がない時のデフォルト。"
    )

    // MARK: - Silver: オーバーロード（型昇格 vs ボクシング）

    static let silverOverload002 = Quiz(
        id: "silver-overload-002",
        level: .silver,
        category: "overload-resolution",
        tags: ["オーバーロード", "型昇格", "ボクシング"],
        code: """
public class Test {
    static void call(long x) {
        System.out.println("long");
    }
    static void call(Integer x) {
        System.out.println("Integer");
    }
    public static void main(String[] args) {
        call(10);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "long",
                   correct: true, misconception: nil,
                   explanation: "10はintリテラルです。完全一致がない場合、ボクシングより先にintからlongへの型昇格が試されます。"),
            Choice(id: "b", text: "Integer",
                   correct: false, misconception: "ボクシングが型昇格より優先されると誤解",
                   explanation: "Integerへのボクシングより、longへの型昇格が優先されます。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "候補が2つあると常に曖昧になると誤解",
                   explanation: "優先順位によりcall(long)が明確に選ばれるため曖昧ではありません。"),
            Choice(id: "d", text: "実行時エラー",
                   correct: false, misconception: nil,
                   explanation: "オーバーロード解決はコンパイル時に完了するため、実行時エラーにはなりません。"),
        ],
        explanationRef: "explain-silver-overload-002",
        designIntent: "オーバーロード解決では、完全一致の次に型昇格が試され、ボクシングはその後。順序を覚えているかを確認する問題。"
    )

    // MARK: - Silver: 配列のデフォルト値

    static let silverArrayDefaults001 = Quiz(
        id: "silver-array-defaults-001",
        level: .silver,
        category: "data-types",
        tags: ["配列", "初期値", "int"],
        code: """
public class Test {
    public static void main(String[] args) {
        int[] nums = new int[3];
        System.out.println(nums[1]);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "0",
                   correct: true, misconception: nil,
                   explanation: "newで生成されたint配列の各要素は0で初期化されます。nums[1]も0です。"),
            Choice(id: "b", text: "null",
                   correct: false, misconception: "配列要素が常にnullで初期化されると誤解",
                   explanation: "参照型配列の要素はnullですが、intはプリミティブ型なので0です。"),
            Choice(id: "c", text: "ArrayIndexOutOfBoundsException",
                   correct: false, misconception: nil,
                   explanation: "長さ3の配列の有効なインデックスは0, 1, 2です。nums[1]は範囲内です。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: nil,
                   explanation: "配列生成とアクセスは文法的に正しいため、コンパイルエラーにはなりません。"),
        ],
        explanationRef: "explain-silver-array-defaults-001",
        designIntent: "プリミティブ配列のデフォルト値を問う基礎問題。intは0、booleanはfalse、参照型はnull。"
    )

    // MARK: - Silver: フィールド隠蔽とメソッドオーバーライド

    static let silverInheritance001 = Quiz(
        id: "silver-inheritance-001",
        level: .silver,
        category: "inheritance",
        tags: ["継承", "オーバーライド", "フィールド隠蔽"],
        code: """
class Parent {
    String name = "parent";
    String getName() { return name; }
}
class Child extends Parent {
    String name = "child";
    String getName() { return name; }
}
public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        System.out.println(p.name + " " + p.getName());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "parent parent",
                   correct: false, misconception: "参照型Parentですべて決まると誤解",
                   explanation: "フィールドアクセスは参照型で決まりますが、メソッド呼び出しは実体の型で動的に決まります。"),
            Choice(id: "b", text: "parent child",
                   correct: true, misconception: nil,
                   explanation: "p.nameは参照型Parentのフィールド、p.getName()は実体Childのオーバーライドメソッドが呼ばれます。"),
            Choice(id: "c", text: "child child",
                   correct: false, misconception: "フィールドも動的ディスパッチされると誤解",
                   explanation: "フィールドはオーバーライドされません。参照型Parentのnameが使われます。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: nil,
                   explanation: "Parent型の変数にChildインスタンスを代入するアップキャストは有効です。"),
        ],
        explanationRef: "explain-silver-inheritance-001",
        designIntent: "フィールドは隠蔽、メソッドはオーバーライド。静的/動的な解決の違いを見抜く問題。"
    )

    // MARK: - Silver: コンストラクタのthis呼び出し

    static let silverConstructor001 = Quiz(
        id: "silver-constructor-001",
        level: .silver,
        category: "classes",
        tags: ["コンストラクタ", "this", "初期化"],
        code: """
class Box {
    int value;
    Box() {
        this(10);
        value++;
    }
    Box(int value) {
        this.value = value;
    }
}
public class Test {
    public static void main(String[] args) {
        System.out.println(new Box().value);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "0",
                   correct: false, misconception: "intフィールドのデフォルト値だけで終わると誤解",
                   explanation: "コンストラクタが実行されるため、valueは10に設定されたあとインクリメントされます。"),
            Choice(id: "b", text: "10",
                   correct: false, misconception: "this(10)の後のvalue++を見落とし",
                   explanation: "this(10)でvalueは10になり、その後value++で11になります。"),
            Choice(id: "c", text: "11",
                   correct: true, misconception: nil,
                   explanation: "引数なしコンストラクタはthis(10)を呼び、valueを10にした後、value++で11にします。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "this(...)呼び出し自体が禁止されていると誤解",
                   explanation: "this(...)はコンストラクタの先頭文であれば有効です。このコードでは先頭にあるためコンパイルできます。"),
        ],
        explanationRef: "explain-silver-constructor-001",
        designIntent: "this(...)は同一クラスの別コンストラクタ呼び出し。必ずコンストラクタの先頭文でなければならない点も重要。"
    )

    // MARK: - Silver: StringBuilderの可変性

    static let silverStringBuilder001 = Quiz(
        id: "silver-stringbuilder-001",
        level: .silver,
        category: "string",
        tags: ["StringBuilder", "可変", "toString"],
        code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("A");
        String s = sb.append("B").toString();
        sb.append("C");
        System.out.println(s + " " + sb);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "A ABC",
                   correct: false, misconception: "append前の値がsに入ると誤解",
                   explanation: "sはappend(\"B\")後にtoString()した結果なので\"AB\"です。"),
            Choice(id: "b", text: "AB AB",
                   correct: false, misconception: "StringBuilderの後続変更がないと誤解",
                   explanation: "sb.append(\"C\")によりStringBuilder本体は\"ABC\"になります。"),
            Choice(id: "c", text: "AB ABC",
                   correct: true, misconception: nil,
                   explanation: "toString()で作ったString sは\"AB\"のまま。StringBuilder sbはさらに変更されて\"ABC\"になります。"),
            Choice(id: "d", text: "ABC ABC",
                   correct: false, misconception: "StringもStringBuilderの変更に追従すると誤解",
                   explanation: "Stringは不変です。toString()で得たsは後からsbを変更しても変わりません。"),
        ],
        explanationRef: "explain-silver-stringbuilder-001",
        designIntent: "StringBuilderは可変、Stringは不変。toString()で切り出したStringが後続のappendに追従しないことを確認する問題。"
    )

    // MARK: - Gold: Optional orElseの即時評価

    static let goldOptional002 = Quiz(
        id: "gold-optional-002",
        level: .gold,
        category: "optional-api",
        tags: ["Optional", "orElse", "orElseGet", "評価タイミング"],
        code: """
import java.util.*;

public class Test {
    static String fallback() {
        System.out.print("F");
        return "fallback";
    }
    public static void main(String[] args) {
        String result = Optional.of("java").orElse(fallback());
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "java",
                   correct: false, misconception: "値があるとorElseの引数が評価されないと誤解",
                   explanation: "orElseの引数はメソッド呼び出し前に評価されます。fallback()が実行され、先にFが出力されます。"),
            Choice(id: "b", text: "Fjava",
                   correct: true, misconception: nil,
                   explanation: "orElse(fallback())のfallback()は即時評価されます。その後Optional内の\"java\"が返され、Fjavaと出力されます。"),
            Choice(id: "c", text: "Ffallback",
                   correct: false, misconception: "値があってもfallbackの戻り値が採用されると誤解",
                   explanation: "fallback()は実行されますが、Optionalに値があるため戻り値\"fallback\"は採用されません。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: nil,
                   explanation: "Optional.of(\"java\").orElse(String) は有効な呼び出しです。"),
        ],
        explanationRef: "explain-gold-optional-002",
        designIntent: "orElseは引数を即時評価、orElseGetは必要な時だけSupplierを評価。副作用や重い処理では差が出る。"
    )

    // MARK: - Gold: Stream findFirst

    static let goldStream002 = Quiz(
        id: "gold-stream-002",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "map", "filter", "findFirst"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        int result = List.of("a", "bb", "ccc").stream()
            .map(String::length)
            .filter(n -> n > 1)
            .findFirst()
            .orElse(0);
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "0",
                   correct: false, misconception: "filterで全要素が除外されると誤解",
                   explanation: "\"bb\"と\"ccc\"は長さが1より大きいため残ります。"),
            Choice(id: "b", text: "1",
                   correct: false, misconception: "map後の最初の要素をそのまま返すと誤解",
                   explanation: "1はfilter(n > 1)で除外されます。"),
            Choice(id: "c", text: "2",
                   correct: true, misconception: nil,
                   explanation: "長さは1, 2, 3。filterで2, 3が残り、findFirstで最初の2が返されます。"),
            Choice(id: "d", text: "3",
                   correct: false, misconception: "最後の一致要素を返すと誤解",
                   explanation: "findFirstはストリーム順序で最初に一致した要素を返します。"),
        ],
        explanationRef: "explain-gold-stream-002",
        designIntent: "Streamの中間操作とfindFirstの組み合わせ。順序付きストリームでは最初に条件を満たす要素が返る。"
    )

    // MARK: - Gold: superワイルドカード

    static let goldGenerics002 = Quiz(
        id: "gold-generics-002",
        level: .gold,
        category: "generics",
        tags: ["ワイルドカード", "下限境界", "PECS"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<? super Integer> nums = new ArrayList<Number>();
        nums.add(10);
        Object value = nums.get(0);
        System.out.println(value);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "10",
                   correct: true, misconception: nil,
                   explanation: "<? super Integer>にはIntegerを安全に追加できます。getの戻り型はObjectですが、中身は10です。"),
            Choice(id: "b", text: "null",
                   correct: false, misconception: "getで型が分からないとnullになると誤解",
                   explanation: "型がObjectになるだけで、格納された値は失われません。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "super境界には追加できないと誤解",
                   explanation: "<? super Integer>はIntegerの追加が安全なため、nums.add(10)はコンパイルできます。"),
            Choice(id: "d", text: "ClassCastException",
                   correct: false, misconception: nil,
                   explanation: "Objectとして取得してprintlnしているだけなので、キャスト例外は発生しません。"),
        ],
        explanationRef: "explain-gold-generics-002",
        designIntent: "<? super T> はTを入れるConsumer向き。取り出すときは具体型が保証できないためObjectとして扱う。"
    )

    // MARK: - Gold: AtomicInteger

    static let goldConcurrency002 = Quiz(
        id: "gold-concurrency-001",
        level: .gold,
        category: "concurrency",
        tags: ["AtomicInteger", "getAndIncrement", "並行処理"],
        code: """
import java.util.concurrent.atomic.*;

public class Test {
    public static void main(String[] args) {
        AtomicInteger n = new AtomicInteger(1);
        System.out.println(n.getAndIncrement() + " " + n.get());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1 1",
                   correct: false, misconception: "getAndIncrementが値を変えないと誤解",
                   explanation: "getAndIncrementは現在値を返した後、内部値を1増やします。"),
            Choice(id: "b", text: "1 2",
                   correct: true, misconception: nil,
                   explanation: "最初に現在値1を返し、その後2に更新されます。続くget()は2を返します。"),
            Choice(id: "c", text: "2 2",
                   correct: false, misconception: "インクリメント後の値を返すと誤解",
                   explanation: "getAndIncrementは後置インクリメント相当です。返すのは更新前の値です。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: nil,
                   explanation: "AtomicIntegerとgetAndIncrementはjava.util.concurrent.atomicパッケージの有効なAPIです。"),
        ],
        explanationRef: "explain-gold-concurrency-001",
        designIntent: "AtomicIntegerの更新系メソッドの戻り値を確認する問題。incrementAndGetとの違いが頻出。"
    )

    // MARK: - Gold: Path normalize

    static let goldPathNormalize001 = Quiz(
        id: "gold-path-normalize-001",
        level: .gold,
        category: "io",
        tags: ["Path", "normalize", "NIO.2"],
        code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path p = Path.of("a/../b/./c.txt").normalize();
        System.out.println(p.getNameCount());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1",
                   correct: false, misconception: "ファイル名だけが残ると誤解",
                   explanation: "normalize後の相対パスは b/c.txt なので、名前要素はbとc.txtの2つです。"),
            Choice(id: "b", text: "2",
                   correct: true, misconception: nil,
                   explanation: "a/.. は打ち消され、./ は削除されます。残る名前要素はbとc.txtで2個です。"),
            Choice(id: "c", text: "4",
                   correct: false, misconception: "normalize前の要素数を数えていると誤解",
                   explanation: "normalizeにより冗長な . や .. が整理されます。"),
            Choice(id: "d", text: "InvalidPathException",
                   correct: false, misconception: nil,
                   explanation: "この文字列は有効な相対パスです。例外は発生しません。"),
        ],
        explanationRef: "explain-gold-path-normalize-001",
        designIntent: "NIO.2のPath.normalizeはパス文字列を正規化するだけで、実ファイルの存在確認はしない。"
    )

    // MARK: - Silver: 制御構文 (switch式)

    static let silverControlFlow001 = Quiz(
        id: "silver-control-flow-001",
        level: .silver,
        category: "control-flow",
        tags: ["switch式", "yield", "Java 14+"],
        code: """
public class Test {
    public static void main(String[] args) {
        int val = 2;
        String res = switch (val) {
            case 1 -> "One";
            case 2 -> { yield "Two"; }
            default -> "Other";
        };
        System.out.println(res);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "Two",
                   correct: true, misconception: nil,
                   explanation: "アロー構文(->)を用いたswitch式では、ブロック{}を使う場合にyield文で値を返せます。"),
            Choice(id: "b", text: "コンパイルエラー",
                   correct: false, misconception: "アロー構文とyieldは併用できないと誤解",
                   explanation: "アロー構文でも、複数行の処理を書くためにブロック{}を用いた場合はyieldで値を返すのが正しい構文です。"),
            Choice(id: "c", text: "実行時エラー",
                   correct: false, misconception: nil,
                   explanation: "構文は正しく、実行時に例外は発生しません。"),
            Choice(id: "d", text: "Other",
                   correct: false, misconception: "breakがないためフォールスルーすると誤解",
                   explanation: "アロー構文(->)ではフォールスルーは発生しません。条件に一致したブロックのみが実行されます。"),
        ],
        explanationRef: "explain-silver-control-flow-001",
        designIntent: "switch式におけるアロー構文とブロック内でのyieldの正しい使い方を見抜かせる。"
    )

    // MARK: - Gold: クラスとインターフェース (record)

    static let goldClasses001 = Quiz(
        id: "gold-classes-001",
        level: .gold,
        category: "classes",
        tags: ["record", "final", "イミュータブル"],
        code: """
public class Test {
    record Item(String name) {}

    public static void main(String[] args) {
        var item = new Item("Apple");
        item.name = "Banana";
        System.out.println(item.name());
    }
}
""",
        question: "このコードをコンパイルおよび実行したときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "Banana",
                   correct: false, misconception: "recordのフィールドが変更可能であると誤解",
                   explanation: "recordのコンポーネントから作られるフィールドはfinalです。再代入はできません。"),
            Choice(id: "b", text: "Apple",
                   correct: false, misconception: "代入が無視されると誤解",
                   explanation: "finalフィールドへの代入は無視されるのではなく、コンパイル時にエラーになります。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "recordのコンポーネントから作られるフィールドはfinalです。item.nameへ再代入しようとしているため、コンパイルエラーになります。"),
            Choice(id: "d", text: "UnsupportedOperationExceptionがスローされる",
                   correct: false, misconception: "実行時の不変コレクションの挙動と混同",
                   explanation: "recordのフィールド変更は実行時例外ではなく、コンパイルエラーとして検出されます。"),
        ],
        explanationRef: "explain-gold-classes-001",
        designIntent: "recordのコンポーネントから作られるフィールドがfinalであり、再代入できない仕様を確認する。"
    )

    // MARK: - Silver: 複数ファイルとオーバーライド

    static let silverMultiFileOverride001 = Quiz(
        id: "silver-multifile-override-001",
        level: .silver,
        category: "inheritance",
        tags: ["複数ファイル", "継承", "オーバーライド", "動的束縛"],
        code: """
public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        System.out.println(p.name());
    }
}
""",
        codeTabs: [
            CodeFile(
                filename: "Parent.java",
                code: """
class Parent {
    String name() {
        return "Parent";
    }
}
"""
            ),
            CodeFile(
                filename: "Child.java",
                code: """
class Child extends Parent {
    @Override
    String name() {
        return "Child";
    }
}
"""
            ),
            CodeFile(
                filename: "Test.java",
                code: """
public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        System.out.println(p.name());
    }
}
"""
            ),
        ],
        question: "3つのファイルを同じパッケージでコンパイルして実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "Parent",
                   correct: false, misconception: "参照型Parentでメソッド呼び出し先が固定されると誤解",
                   explanation: "インスタンスメソッドは動的束縛されるため、実体であるChildのname()が呼ばれます。"),
            Choice(id: "b", text: "Child",
                   correct: true, misconception: nil,
                   explanation: "Parent型の変数pにChildインスタンスが入っています。name()はChildでオーバーライドされているため、Childが出力されます。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "publicでないParent/Childを別ファイルに置けないと誤解",
                   explanation: "同じパッケージ内なら、package-privateなParent/Childを別ファイルから参照できます。publicクラスはTestだけなのでファイル名規則にも違反しません。"),
            Choice(id: "d", text: "ClassCastException",
                   correct: false, misconception: nil,
                   explanation: "ChildはParentのサブクラスなので、Parent型への代入は安全なアップキャストです。"),
        ],
        explanationRef: "explain-silver-multifile-override-001",
        designIntent: "複数ファイル構成でも、同じパッケージのpackage-privateクラスは参照できる。メソッド呼び出しは実体の型で動的に決まる。"
    )
}
