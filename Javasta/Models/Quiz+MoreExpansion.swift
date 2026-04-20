import Foundation

extension Quiz {
    static let mixedExpansion: [Quiz] = [
        goldGenerics005,
        goldGenerics006,
        goldStream008,
        goldOptional005,
        goldConcurrency007,
        goldIo004,
        goldDateTime002,
        goldClasses004,
        goldClasses005,
        goldCollections003,
        goldLocalization004,
        goldAnnotations002,
        silverJavaBasics006,
        silverDataTypes009,
        silverDataTypes010,
        silverString005,
        silverControlFlow008,
        silverOverload005,
        silverClasses006,
        silverInheritance007,
        silverException006,
        silverCollections006,
        silverLambda004,
        silverArray006,
        goldException006,
        goldStream009,
        goldOptional006,
        goldCollections004,
        goldClasses006,
        goldDateTime003,
        silverDataTypes011,
        silverOperators001,
        silverOperators002,
        silverArray007,
        silverStringBuilder004,
        silverControlFlow009,
        silverString006,
        silverArray008,
        silverOverload006,
        silverException007,
        silverClasses007,
        silverDataTypes012,
        goldStream010,
        goldGenerics007,
        goldOptional007,
        goldDateTime004,
        goldConcurrency008,
        goldIo005,
    ]

    // MARK: - Gold: Generics (extends wildcard)

    static let goldGenerics005 = Quiz(
        id: "gold-generics-005",
        level: .gold,
        category: "generics",
        tags: ["Generics", "wildcard", "extends"],
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
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "1と出力される",
                   correct: false, misconception: "extendsならIntegerを追加できると誤解",
                   explanation: "? extends Numberは読み取り側ではNumberとして扱えますが、具体的な要素型が不明なためIntegerを追加できません。"),
            Choice(id: "b", text: "nums.add(10)でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "List<? extends Number>には、null以外の値を安全に追加できません。実体がList<Double>かもしれないためです。"),
            Choice(id: "c", text: "実行時にClassCastException",
                   correct: false, misconception: "ジェネリクスの制約が実行時まで遅れると誤解",
                   explanation: "この制約はコンパイル時に検出されます。"),
            Choice(id: "d", text: "UnsupportedOperationException",
                   correct: false, misconception: "ワイルドカードと不変リストを混同",
                   explanation: "問題はリストの変更可否ではなく、型安全に追加できないことです。"),
        ],
        explanationRef: "explain-gold-generics-005",
        designIntent: "PECSのextends側はproducerであり、具体値の追加に使えないことを確認する。"
    )

    // MARK: - Gold: Generics (super wildcard)

    static let goldGenerics006 = Quiz(
        id: "gold-generics-006",
        level: .gold,
        category: "generics",
        tags: ["Generics", "wildcard", "super"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<? super Integer> list = new ArrayList<Number>();
        list.add(10);
        Object value = list.get(0);
        System.out.println(value.getClass().getSimpleName());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "Integer",
                   correct: true, misconception: nil,
                   explanation: "? super IntegerにはIntegerを追加できます。getした値はObject型として受け取り、実体のクラス名はIntegerです。"),
            Choice(id: "b", text: "Number",
                   correct: false, misconception: "変数宣言のArrayList<Number>に引きずられている",
                   explanation: "実際に追加したオブジェクトはIntegerです。getClassは実体の型を返します。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "? super IntegerにIntegerを追加できないと誤解",
                   explanation: "super側はIntegerまたはそのサブタイプを安全に追加できます。"),
            Choice(id: "d", text: "ClassCastException",
                   correct: false, misconception: "get時にIntegerへ暗黙キャストされると誤解",
                   explanation: "valueはObject型で受け取っているためキャストは発生しません。"),
        ],
        explanationRef: "explain-gold-generics-006",
        designIntent: "superワイルドカードでは追加はできるが、読み取り型はObjectになることを確認する。"
    )

    // MARK: - Gold: Stream (short-circuit)

    static let goldStream008 = Quiz(
        id: "gold-stream-008",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "anyMatch", "短絡評価"],
        code: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        boolean result = Stream.of("A", "BB", "CCC")
            .peek(System.out::print)
            .anyMatch(s -> s.length() == 1);
        System.out.println(":" + result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "A:true",
                   correct: true, misconception: nil,
                   explanation: "anyMatchは条件を満たす要素が見つかると短絡します。最初のAだけpeekされ、trueが返ります。"),
            Choice(id: "b", text: "ABBCCC:true",
                   correct: false, misconception: "終端操作では全要素が必ず処理されると誤解",
                   explanation: "anyMatchは短絡終端操作なので、条件成立後の要素は処理されません。"),
            Choice(id: "c", text: ":true",
                   correct: false, misconception: "peekは実行されないと誤解",
                   explanation: "終端操作が呼ばれているため、必要な範囲でpeekも実行されます。"),
            Choice(id: "d", text: "A:false",
                   correct: false, misconception: "lengthの判定を誤っている",
                   explanation: "\"A\"の長さは1なのでanyMatchはtrueになります。"),
        ],
        explanationRef: "explain-gold-stream-008",
        designIntent: "Streamの短絡終端操作では、必要な要素までしか中間操作が実行されないことを確認する。"
    )

    // MARK: - Gold: Optional (orElse eager)

    static let goldOptional005 = Quiz(
        id: "gold-optional-005",
        level: .gold,
        category: "optional-api",
        tags: ["Optional", "orElse", "orElseGet"],
        code: """
import java.util.*;

public class Test {
    static String fallback() {
        System.out.print("F");
        return "B";
    }

    public static void main(String[] args) {
        Optional<String> opt = Optional.of("A");
        System.out.print(opt.orElse(fallback()));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "A",
                   correct: false, misconception: "Optionalが空でないならorElse引数は評価されないと誤解",
                   explanation: "orElseの引数はメソッド呼び出し前に評価されます。"),
            Choice(id: "b", text: "FA",
                   correct: true, misconception: nil,
                   explanation: "fallback()は先に評価されてFを出力します。その後、Optional内のAがorElseの戻り値として出力されます。"),
            Choice(id: "c", text: "FB",
                   correct: false, misconception: "fallbackの戻り値が採用されると誤解",
                   explanation: "Optionalは空ではないため、戻り値として採用されるのはAです。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "orElseにメソッド呼び出しを書けないと誤解",
                   explanation: "Stringを返す式なのでorElseの引数として有効です。"),
        ],
        explanationRef: "explain-gold-optional-005",
        designIntent: "orElseは引数を即時評価し、orElseGetは必要時だけSupplierを実行するという違いを確認する。"
    )

    // MARK: - Gold: Concurrency (Thread start)

    static let goldConcurrency007 = Quiz(
        id: "gold-concurrency-007",
        level: .gold,
        category: "concurrency",
        tags: ["Thread", "start", "IllegalThreadStateException"],
        code: """
public class Test {
    public static void main(String[] args) throws Exception {
        Thread t = new Thread(() -> {});
        t.start();
        t.join();
        try {
            t.start();
            System.out.println("OK");
        } catch (IllegalThreadStateException e) {
            System.out.println("ISE");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "OK",
                   correct: false, misconception: "終了後のThreadを再startできると誤解",
                   explanation: "Threadインスタンスは一度しかstartできません。終了後も再利用不可です。"),
            Choice(id: "b", text: "ISE",
                   correct: true, misconception: nil,
                   explanation: "同じThreadに2回目のstartを呼ぶとIllegalThreadStateExceptionが発生し、ISEが出力されます。"),
            Choice(id: "c", text: "何も出力されない",
                   correct: false, misconception: "例外がcatchされないと誤解",
                   explanation: "IllegalThreadStateExceptionをcatchしてISEを出力しています。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "joinには必ずcatchが必要だと誤解",
                   explanation: "mainがthrows Exceptionを宣言しているため、joinのチェック例外は処理済みです。"),
        ],
        explanationRef: "explain-gold-concurrency-007",
        designIntent: "Threadインスタンスは一度だけstartでき、再起動できないことを確認する。"
    )

    // MARK: - Gold: I/O (Path.resolve)

    static let goldIo004 = Quiz(
        id: "gold-io-004",
        level: .gold,
        category: "io",
        tags: ["Path", "resolve", "absolute path"],
        code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path base = Path.of("/base/app");
        Path result = base.resolve("/tmp/log.txt");
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "/base/app/tmp/log.txt",
                   correct: false, misconception: "絶対パスも単純連結されると誤解",
                   explanation: "resolveの引数が絶対パスの場合、baseは無視されます。"),
            Choice(id: "b", text: "/tmp/log.txt",
                   correct: true, misconception: nil,
                   explanation: "Path.resolveで右側が絶対パスなら、その絶対パス自体が結果になります。"),
            Choice(id: "c", text: "tmp/log.txt",
                   correct: false, misconception: "絶対パスの先頭スラッシュが削除されると誤解",
                   explanation: "絶対パスは絶対パスのまま結果になります。"),
            Choice(id: "d", text: "InvalidPathException",
                   correct: false, misconception: "絶対パスをresolveできないと誤解",
                   explanation: "絶対パスをresolveに渡すこと自体は有効です。"),
        ],
        explanationRef: "explain-gold-io-004",
        designIntent: "Path.resolveで右辺が絶対パスの場合の挙動を確認する。"
    )

    // MARK: - Gold: Date/Time (plusMonths)

    static let goldDateTime002 = Quiz(
        id: "gold-date-time-002",
        level: .gold,
        category: "classes",
        tags: ["LocalDate", "plusMonths", "日付調整"],
        code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        LocalDate date = LocalDate.of(2023, 1, 31);
        System.out.println(date.plusMonths(1));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2023-02-28",
                   correct: true, misconception: nil,
                   explanation: "移動先の月に31日がないため、その月の末日である2023-02-28に調整されます。"),
            Choice(id: "b", text: "2023-03-03",
                   correct: false, misconception: "余った日数が翌月に繰り越されると誤解",
                   explanation: "LocalDate.plusMonthsは余剰日数を繰り越すのではなく、移動先月の有効な末日に調整します。"),
            Choice(id: "c", text: "DateTimeException",
                   correct: false, misconception: "存在しない日付になると例外だと誤解",
                   explanation: "plusMonthsは有効な日付に調整するため、このケースでは例外になりません。"),
            Choice(id: "d", text: "2023-02-31",
                   correct: false, misconception: "存在しない日付が保持されると誤解",
                   explanation: "LocalDateは存在しない日付を表現しません。"),
        ],
        explanationRef: "explain-gold-date-time-002",
        designIntent: "月末日のplusMonthsが移動先月の末日へ調整されることを確認する。"
    )

    // MARK: - Gold: Record (compact constructor)

    static let goldClasses004 = Quiz(
        id: "gold-classes-004",
        level: .gold,
        category: "classes",
        tags: ["Record", "コンパクトコンストラクタ", "final"],
        code: """
public class Test {
    record User(String name) {
        User {
            this.name = name.trim();
        }
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる",
                   correct: false, misconception: "compact constructor内でフィールドに直接代入できると誤解",
                   explanation: "recordコンポーネントのフィールドはfinalです。compact constructorではパラメータを書き換えます。"),
            Choice(id: "b", text: "this.nameへの代入でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "compact constructor内でfinalフィールドへ直接代入できません。正しくは name = name.trim(); のようにパラメータを調整します。"),
            Choice(id: "c", text: "実行時にNullPointerException",
                   correct: false, misconception: "trimの実行まで進むと誤解",
                   explanation: "このコードはコンパイルエラーのため実行されません。"),
            Choice(id: "d", text: "recordはネストできないためコンパイルエラー",
                   correct: false, misconception: "recordのネスト宣言が不可と誤解",
                   explanation: "recordをクラス内に宣言すること自体は可能です。問題はfinalフィールドへの代入です。"),
        ],
        explanationRef: "explain-gold-classes-004",
        designIntent: "recordのcompact constructorではコンポーネントパラメータを調整し、フィールドへ直接代入しないことを確認する。"
    )

    // MARK: - Gold: Sealed classes

    static let goldClasses005 = Quiz(
        id: "gold-classes-005",
        level: .gold,
        category: "classes",
        tags: ["sealed", "permits", "Java17"],
        code: """
sealed class Parent permits Child {}

final class Child extends Parent {}

final class Other extends Parent {}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる",
                   correct: false, misconception: "同じファイルならpermits不要と誤解",
                   explanation: "sealed classを継承できるのはpermitsに列挙されたクラスだけです。"),
            Choice(id: "b", text: "Other extends Parentでコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "ParentはChildだけをpermitsしています。Otherは許可されていないため継承できません。"),
            Choice(id: "c", text: "Childがfinalなのでコンパイルエラー",
                   correct: false, misconception: "sealedの直接サブクラスをfinalにできないと誤解",
                   explanation: "sealed classの直接サブクラスはfinal、sealed、non-sealedのいずれかを明示します。finalは有効です。"),
            Choice(id: "d", text: "実行時にSecurityException",
                   correct: false, misconception: "sealed制約が実行時に判定されると誤解",
                   explanation: "sealedの継承制約はコンパイル時に検出されます。"),
        ],
        explanationRef: "explain-gold-classes-005",
        designIntent: "sealed classのpermitsで許可された直接サブクラスだけが継承できることを確認する。"
    )

    // MARK: - Gold: Collections (TreeSet comparable)

    static let goldCollections003 = Quiz(
        id: "gold-collections-003",
        level: .gold,
        category: "collections",
        tags: ["TreeSet", "Comparable", "raw type"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Set set = new TreeSet();
        try {
            set.add("A");
            set.add(1);
            System.out.println(set.size());
        } catch (ClassCastException e) {
            System.out.println("CCE");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2",
                   correct: false, misconception: "raw typeなら異なる型もTreeSetに並べられると誤解",
                   explanation: "raw typeでコンパイル警告に留まっても、TreeSetは要素比較が必要です。StringとIntegerは相互比較できません。"),
            Choice(id: "b", text: "1",
                   correct: false, misconception: "比較できない要素が無視されると誤解",
                   explanation: "無視されるのではなく、比較時にClassCastExceptionが発生します。"),
            Choice(id: "c", text: "CCE",
                   correct: true, misconception: nil,
                   explanation: "TreeSetはソートのため要素を比較します。StringとIntegerは比較できないためClassCastExceptionが発生します。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "raw typeの警告をエラーと誤解",
                   explanation: "raw typeの使用は警告ですが、通常はコンパイル自体は可能です。"),
        ],
        explanationRef: "explain-gold-collections-003",
        designIntent: "TreeSetは要素比較を行うため、異種型混在が実行時例外につながることを確認する。"
    )

    // MARK: - Gold: Localization (Currency)

    static let goldLocalization004 = Quiz(
        id: "gold-localization-004",
        level: .gold,
        category: "localization",
        tags: ["NumberFormat", "Locale", "Currency"],
        code: """
import java.text.*;
import java.util.*;

public class Test {
    public static void main(String[] args) {
        NumberFormat nf = NumberFormat.getCurrencyInstance(Locale.US);
        System.out.println(nf.format(10));
    }
}
""",
        question: "Locale.USを指定した通貨形式として、出力に最も近いものはどれか？",
        choices: [
            Choice(id: "a", text: "$10.00",
                   correct: true, misconception: nil,
                   explanation: "Locale.USの通貨形式ではドル記号と小数2桁が使われ、10は$10.00の形で表示されます。"),
            Choice(id: "b", text: "10円",
                   correct: false, misconception: "デフォルトLocaleが使われると誤解",
                   explanation: "getCurrencyInstance(Locale.US)でLocaleを明示しているため、米国形式が使われます。"),
            Choice(id: "c", text: "USD 10",
                   correct: false, misconception: "常に通貨コードが表示されると誤解",
                   explanation: "Locale.USの標準的な通貨表示はドル記号を使います。"),
            Choice(id: "d", text: "10.0",
                   correct: false, misconception: "通常の数値formatと混同",
                   explanation: "CurrencyInstanceなので通貨記号と通貨用の桁表現が入ります。"),
        ],
        explanationRef: "explain-gold-localization-004",
        designIntent: "NumberFormatのLocale指定が通貨記号と小数桁に影響することを確認する。"
    )

    // MARK: - Gold: Annotations (Override)

    static let goldAnnotations002 = Quiz(
        id: "gold-annotations-002",
        level: .gold,
        category: "annotations",
        tags: ["@Override", "private", "オーバーライド"],
        code: """
class Parent {
    private void run() {}
}

class Child extends Parent {
    @Override
    private void run() {}
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる",
                   correct: false, misconception: "privateメソッドもオーバーライドできると誤解",
                   explanation: "privateメソッドはサブクラスに継承されないため、オーバーライド対象になりません。"),
            Choice(id: "b", text: "@Overrideの行でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "Child.runはParent.runをオーバーライドしていません。@Overrideによりコンパイラがその誤りを検出します。"),
            Choice(id: "c", text: "実行時にIllegalAccessError",
                   correct: false, misconception: "privateアクセス違反が実行時まで遅れると誤解",
                   explanation: "この問題は@Overrideのコンパイル時チェックで検出されます。"),
            Choice(id: "d", text: "@Overrideを外しても同じエラー",
                   correct: false, misconception: "privateメソッドの同名宣言自体が不可と誤解",
                   explanation: "@Overrideを外せば、Child側の別メソッドとして宣言できます。"),
        ],
        explanationRef: "explain-gold-annotations-002",
        designIntent: "@Overrideが本当にオーバーライドできているかをコンパイル時に検証する役割を確認する。"
    )

    // MARK: - Silver: Javaの基本 (single underscore)

    static let silverJavaBasics006 = Quiz(
        id: "silver-java-basics-006",
        level: .silver,
        category: "java-basics",
        tags: ["識別子", "_", "Java9"],
        code: """
public class Test {
    public static void main(String[] args) {
        int _ = 1;
        System.out.println(_);
    }
}
""",
        question: "このコードをJava 17でコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "1と出力される",
                   correct: false, misconception: "アンダースコア単独も識別子にできると誤解",
                   explanation: "Java 9以降、単独の_はキーワード扱いで識別子として使えません。"),
            Choice(id: "b", text: "int _ = 1; でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "_scoreのような識別子は可能ですが、単独の_は変数名にできません。"),
            Choice(id: "c", text: "System.out.println(_)だけがコンパイルエラー",
                   correct: false, misconception: "宣言はできるが参照だけ不可と誤解",
                   explanation: "そもそも単独の_を変数名として宣言できません。"),
            Choice(id: "d", text: "実行時にNoSuchFieldError",
                   correct: false, misconception: "識別子エラーが実行時に判定されると誤解",
                   explanation: "識別子の妥当性はコンパイル時に判定されます。"),
        ],
        explanationRef: "explain-silver-java-basics-006",
        designIntent: "単独アンダースコアと、アンダースコアを含む識別子の違いを確認する。"
    )

    // MARK: - Silver: var (null inference)

    static let silverDataTypes009 = Quiz(
        id: "silver-data-types-009",
        level: .silver,
        category: "data-types",
        tags: ["var", "型推論", "null"],
        code: """
public class Test {
    public static void main(String[] args) {
        var value = null;
        System.out.println(value);
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "nullと出力される",
                   correct: false, misconception: "varがObjectとして推論されると誤解",
                   explanation: "nullだけでは具体的な型を推論できません。"),
            Choice(id: "b", text: "var value = null; でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "varは初期化式から型を推論します。nullリテラル単独では型を決められません。"),
            Choice(id: "c", text: "Objectとして扱われる",
                   correct: false, misconception: "nullの型をObjectと決め打ちしている",
                   explanation: "varは自動的にObjectへする仕組みではありません。"),
            Choice(id: "d", text: "実行時にNullPointerException",
                   correct: false, misconception: "println(null)と混同",
                   explanation: "実行以前に型推論できずコンパイルエラーになります。"),
        ],
        explanationRef: "explain-silver-data-types-009",
        designIntent: "varの型推論にはnull以外の具体的な初期化式が必要であることを確認する。"
    )

    // MARK: - Silver: 浮動小数点リテラル

    static let silverDataTypes010 = Quiz(
        id: "silver-data-types-010",
        level: .silver,
        category: "data-types",
        tags: ["float", "double", "リテラル"],
        code: """
public class Test {
    public static void main(String[] args) {
        float value = 1.0;
        System.out.println(value);
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "1.0と出力される",
                   correct: false, misconception: "小数リテラルがfloatだと誤解",
                   explanation: "小数リテラル1.0はデフォルトでdoubleです。"),
            Choice(id: "b", text: "float value = 1.0; でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "doubleをfloatへ暗黙の縮小変換はできません。1.0fまたは明示キャストが必要です。"),
            Choice(id: "c", text: "0.0と出力される",
                   correct: false, misconception: "代入失敗時に初期値になると誤解",
                   explanation: "型不一致はコンパイルエラーで、初期値にはなりません。"),
            Choice(id: "d", text: "実行時にArithmeticException",
                   correct: false, misconception: nil,
                   explanation: "数値リテラルの型不一致はコンパイル時に検出されます。"),
        ],
        explanationRef: "explain-silver-data-types-010",
        designIntent: "小数リテラルのデフォルト型がdoubleであることを確認する。"
    )

    // MARK: - Silver: String (new and pool)

    static let silverString005 = Quiz(
        id: "silver-string-005",
        level: .silver,
        category: "string",
        tags: ["String", "文字列プール", "=="],
        code: """
public class Test {
    public static void main(String[] args) {
        String a = "A";
        String b = new String("A");
        System.out.println(a == b);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "true",
                   correct: false, misconception: "内容が同じなら==もtrueだと誤解",
                   explanation: "==は参照の同一性を比較します。内容比較にはequalsを使います。"),
            Choice(id: "b", text: "false",
                   correct: true, misconception: nil,
                   explanation: "aは文字列プールの参照、bはnewで作られた別オブジェクトの参照です。==はfalseです。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "String同士に==を使えないと誤解",
                   explanation: "参照型同士の==はコンパイル可能です。"),
            Choice(id: "d", text: "NullPointerException",
                   correct: false, misconception: nil,
                   explanation: "どちらもnullではありません。"),
        ],
        explanationRef: "explain-silver-string-005",
        designIntent: "Stringの内容比較と参照比較、newによる別インスタンス生成を確認する。"
    )

    // MARK: - Silver: switch null

    static let silverControlFlow008 = Quiz(
        id: "silver-control-flow-008",
        level: .silver,
        category: "control-flow",
        tags: ["switch", "String", "null"],
        code: """
public class Test {
    public static void main(String[] args) {
        String s = null;
        try {
            switch (s) {
                case "A": System.out.println("A");
                default: System.out.println("D");
            }
        } catch (NullPointerException e) {
            System.out.println("NPE");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "D",
                   correct: false, misconception: "nullならdefaultに進むと誤解",
                   explanation: "従来のString switchでは、selectorがnullだとdefaultではなくNullPointerExceptionになります。"),
            Choice(id: "b", text: "NPE",
                   correct: true, misconception: nil,
                   explanation: "switchの対象sがnullなのでNullPointerExceptionが発生し、catchでNPEが出力されます。"),
            Choice(id: "c", text: "何も出力されない",
                   correct: false, misconception: "例外が握りつぶされると誤解",
                   explanation: "catch節でNPEを出力しています。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "Stringをswitchに使えないと誤解",
                   explanation: "Stringはswitchの対象として使えます。問題は実行時のnullです。"),
        ],
        explanationRef: "explain-silver-control-flow-008",
        designIntent: "switchのdefaultはnullの受け皿ではないことを確認する。"
    )

    // MARK: - Silver: オーバーロード (widening)

    static let silverOverload005 = Quiz(
        id: "silver-overload-005",
        level: .silver,
        category: "overload-resolution",
        tags: ["オーバーロード", "拡大変換", "byte"],
        code: """
public class Test {
    static void call(int x) { System.out.println("int"); }
    static void call(long x) { System.out.println("long"); }

    public static void main(String[] args) {
        byte b = 1;
        call(b);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "int",
                   correct: true, misconception: nil,
                   explanation: "byteからint、longのどちらにも拡大変換できますが、より近いintが選ばれます。"),
            Choice(id: "b", text: "long",
                   correct: false, misconception: "より大きい型が優先されると誤解",
                   explanation: "オーバーロードでは最も具体的な適用可能メソッドが選ばれます。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "byteから複数候補があり曖昧だと誤解",
                   explanation: "intのほうがlongより近いため曖昧ではありません。"),
            Choice(id: "d", text: "実行時エラー",
                   correct: false, misconception: nil,
                   explanation: "オーバーロード解決はコンパイル時に決まります。"),
        ],
        explanationRef: "explain-silver-overload-005",
        designIntent: "複数の拡大変換候補がある場合、より近い型のメソッドが選ばれることを確認する。"
    )

    // MARK: - Silver: クラス (default constructor)

    static let silverClasses006 = Quiz(
        id: "silver-classes-006",
        level: .silver,
        category: "classes",
        tags: ["コンストラクタ", "デフォルトコンストラクタ"],
        code: """
class Box {
    Box(int size) {}
}

public class Test {
    public static void main(String[] args) {
        new Box();
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる",
                   correct: false, misconception: "デフォルトコンストラクタが常に生成されると誤解",
                   explanation: "コンストラクタを1つでも明示すると、引数なしコンストラクタは自動生成されません。"),
            Choice(id: "b", text: "new Box(); でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "BoxにはBox(int)しかありません。引数なしで呼べるコンストラクタが存在しないためエラーです。"),
            Choice(id: "c", text: "実行時にNoSuchMethodError",
                   correct: false, misconception: "存在しないコンストラクタ呼び出しが実行時まで遅れると誤解",
                   explanation: "通常のソースコンパイルではコンストラクタ解決はコンパイル時に行われます。"),
            Choice(id: "d", text: "Box(int)が0で呼ばれる",
                   correct: false, misconception: "不足引数にデフォルト値が入ると誤解",
                   explanation: "Javaのメソッドやコンストラクタ呼び出しでは、不足引数が自動補完されません。"),
        ],
        explanationRef: "explain-silver-classes-006",
        designIntent: "明示コンストラクタがあるとデフォルトコンストラクタは生成されないことを確認する。"
    )

    // MARK: - Silver: 継承 (private method)

    static let silverInheritance007 = Quiz(
        id: "silver-inheritance-007",
        level: .silver,
        category: "inheritance",
        tags: ["private", "オーバーライド", "動的ディスパッチ"],
        code: """
class Parent {
    private void run() { System.out.println("Parent"); }
    void call() { run(); }
}

class Child extends Parent {
    void run() { System.out.println("Child"); }
}

public class Test {
    public static void main(String[] args) {
        new Child().call();
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "Parent",
                   correct: true, misconception: nil,
                   explanation: "Parent.runはprivateなのでオーバーライドされません。Parent.call内のrun()はParentのprivateメソッドを呼びます。"),
            Choice(id: "b", text: "Child",
                   correct: false, misconception: "privateメソッドもオーバーライドされると誤解",
                   explanation: "privateメソッドは継承されないため、Child.runは別メソッドです。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "Childで同名メソッドを宣言できないと誤解",
                   explanation: "privateメソッドは継承されないため、同名メソッドを宣言できます。"),
            Choice(id: "d", text: "StackOverflowError",
                   correct: false, misconception: "callとrunが再帰すると誤解",
                   explanation: "再帰呼び出しはありません。Parent.callがParent.runを1回呼びます。"),
        ],
        explanationRef: "explain-silver-inheritance-007",
        designIntent: "privateメソッドはオーバーライドされず、親クラス内の呼び出しは親のprivateメソッドに束縛されることを確認する。"
    )

    // MARK: - Silver: 例外処理 (checked exception)

    static let silverException006 = Quiz(
        id: "silver-exception-006",
        level: .silver,
        category: "exception-handling",
        tags: ["チェック例外", "throws", "Exception"],
        code: """
public class Test {
    public static void main(String[] args) {
        throw new Exception();
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "Exceptionがスローされて終了する",
                   correct: false, misconception: "チェック例外を未処理で投げられると誤解",
                   explanation: "Exceptionはチェック例外です。catchするかthrows宣言が必要です。"),
            Choice(id: "b", text: "throw new Exception(); でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "mainがthrowsを宣言しておらず、try-catchもないため、チェック例外の未処理としてコンパイルエラーです。"),
            Choice(id: "c", text: "RuntimeExceptionとして扱われる",
                   correct: false, misconception: "Exceptionが非チェック例外だと誤解",
                   explanation: "RuntimeExceptionはExceptionのサブクラスですが、Exceptionそのものはチェック例外です。"),
            Choice(id: "d", text: "何も起きない",
                   correct: false, misconception: "throw文が無視されると誤解",
                   explanation: "throw文は例外を投げます。ただしこのコードは未処理のチェック例外でコンパイルできません。"),
        ],
        explanationRef: "explain-silver-exception-006",
        designIntent: "チェック例外はcatchまたはthrowsで処理を宣言しなければならないことを確認する。"
    )

    // MARK: - Silver: Arrays.asList backing array

    static let silverCollections006 = Quiz(
        id: "silver-collections-006",
        level: .silver,
        category: "collections",
        tags: ["Arrays.asList", "配列", "set"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        String[] array = {"A", "B"};
        List<String> list = Arrays.asList(array);
        list.set(0, "C");
        System.out.println(array[0]);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "A",
                   correct: false, misconception: "Arrays.asListが完全なコピーを作ると誤解",
                   explanation: "Arrays.asListで作られるリストは元配列を背後に持ちます。"),
            Choice(id: "b", text: "C",
                   correct: true, misconception: nil,
                   explanation: "list.setで背後の配列要素も変更されます。array[0]はCになります。"),
            Choice(id: "c", text: "UnsupportedOperationException",
                   correct: false, misconception: "Arrays.asListではsetも不可と誤解",
                   explanation: "サイズ変更は不可ですが、既存要素のsetは可能です。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: nil,
                   explanation: "配列からListを作り、setするコードとして有効です。"),
        ],
        explanationRef: "explain-silver-collections-006",
        designIntent: "Arrays.asListのリストは固定サイズで、元配列と要素を共有することを確認する。"
    )

    // MARK: - Silver: Lambda (method reference)

    static let silverLambda004 = Quiz(
        id: "silver-lambda-004",
        level: .silver,
        category: "lambda-streams",
        tags: ["メソッド参照", "Function", "String"],
        code: """
import java.util.function.*;

public class Test {
    public static void main(String[] args) {
        Function<String, String> f = String::trim;
        System.out.println("[" + f.apply(" A ") + "]");
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "[ A ]",
                   correct: false, misconception: "trimが実行されないと誤解",
                   explanation: "f.applyでString::trimが呼び出されます。"),
            Choice(id: "b", text: "[A]",
                   correct: true, misconception: nil,
                   explanation: "String::trimは受け取ったStringのtrim()を呼ぶメソッド参照です。前後の空白が削除されます。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "インスタンスメソッド参照をFunctionに代入できないと誤解",
                   explanation: "String::trimはFunction<String, String>として扱えます。"),
            Choice(id: "d", text: "NullPointerException",
                   correct: false, misconception: nil,
                   explanation: "applyに渡している文字列はnullではありません。"),
        ],
        explanationRef: "explain-silver-lambda-004",
        designIntent: "インスタンスメソッド参照 String::trim が Function<T,R> に対応することを確認する。"
    )

    // MARK: - Silver: enhanced for

    static let silverArray006 = Quiz(
        id: "silver-array-006",
        level: .silver,
        category: "data-types",
        tags: ["配列", "拡張for", "値渡し"],
        code: """
public class Test {
    public static void main(String[] args) {
        int[] nums = {1, 2};
        for (int n : nums) {
            n = 9;
        }
        System.out.println(nums[0]);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1",
                   correct: true, misconception: nil,
                   explanation: "拡張forの変数nは各要素値のコピーです。nに代入しても配列要素は変更されません。"),
            Choice(id: "b", text: "9",
                   correct: false, misconception: "拡張for変数への代入で配列要素が変わると誤解",
                   explanation: "配列要素を書き換えるにはインデックスを使ってnums[i]へ代入する必要があります。"),
            Choice(id: "c", text: "2",
                   correct: false, misconception: "最後の要素が出力されると誤解",
                   explanation: "出力しているのはnums[0]です。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "拡張for変数に代入できないと誤解",
                   explanation: "ループ変数nへの代入は可能です。ただし元配列は変わりません。"),
        ],
        explanationRef: "explain-silver-array-006",
        designIntent: "拡張forのループ変数への代入は元配列の要素を書き換えないことを確認する。"
    )

    // MARK: - Gold: try-with-resources close order

    static let goldException006 = Quiz(
        id: "gold-exception-006",
        level: .gold,
        category: "exception-handling",
        tags: ["try-with-resources", "close", "実行順"],
        code: """
class R implements AutoCloseable {
    private final String name;
    R(String name) { this.name = name; }
    public void close() { System.out.print(name); }
}

public class Test {
    public static void main(String[] args) {
        try (R a = new R("A"); R b = new R("B")) {
            System.out.print("T");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "TAB",
                   correct: false, misconception: "resourcesが宣言順にcloseされると誤解",
                   explanation: "try-with-resourcesのcloseは宣言と逆順に実行されます。"),
            Choice(id: "b", text: "TBA",
                   correct: true, misconception: nil,
                   explanation: "try本体でTを出力し、その後b、aの逆順でcloseされるためTBAです。"),
            Choice(id: "c", text: "ABT",
                   correct: false, misconception: "try本体より前にcloseされると誤解",
                   explanation: "closeはtryブロックの処理後に実行されます。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "AutoCloseableのcloseにthrowsが必須と誤解",
                   explanation: "closeはthrowsを狭めて宣言なしにできます。"),
        ],
        explanationRef: "explain-gold-exception-006",
        designIntent: "try-with-resourcesのclose順序が宣言順の逆であることを確認する。"
    )

    // MARK: - Gold: Stream (flatMap)

    static let goldStream009 = Quiz(
        id: "gold-stream-009",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "flatMap", "count"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        long count = List.of(List.of("A", "B"), List.of("C"))
            .stream()
            .flatMap(List::stream)
            .count();
        System.out.println(count);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2",
                   correct: false, misconception: "外側Listの要素数を数えると誤解",
                   explanation: "flatMap後は内側Listの要素が1本のStreamに展開されます。"),
            Choice(id: "b", text: "3",
                   correct: true, misconception: nil,
                   explanation: "A、B、Cの3要素に平坦化されるためcountは3です。"),
            Choice(id: "c", text: "1",
                   correct: false, misconception: "最後のListだけが処理されると誤解",
                   explanation: "flatMapは各内側Listを順にStream化して連結します。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "List::streamがflatMapに使えないと誤解",
                   explanation: "List::streamは各ListをStreamへ変換するFunctionとして適合します。"),
        ],
        explanationRef: "explain-gold-stream-009",
        designIntent: "flatMapが入れ子のStreamを平坦化し、終端操作が平坦化後の要素を数えることを確認する。"
    )

    // MARK: - Gold: Optional (map null)

    static let goldOptional006 = Quiz(
        id: "gold-optional-006",
        level: .gold,
        category: "optional-api",
        tags: ["Optional", "map", "null"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        String result = Optional.of("A")
            .map(s -> (String) null)
            .orElse("B");
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "A",
                   correct: false, misconception: "mapが元の値を保持すると誤解",
                   explanation: "mapはmapperの戻り値でOptionalを作り直します。"),
            Choice(id: "b", text: "B",
                   correct: true, misconception: nil,
                   explanation: "Optional.mapはmapperの結果をofNullable相当に扱います。nullが返ると空になり、orElseのBが使われます。"),
            Choice(id: "c", text: "null",
                   correct: false, misconception: "Optionalがnullを保持すると誤解",
                   explanation: "Optionalはnull値を保持するのではなく、空として扱います。"),
            Choice(id: "d", text: "NullPointerException",
                   correct: false, misconception: "mapの戻り値nullが常に例外だと誤解",
                   explanation: "mapper自体がnullではないため、戻り値nullは空Optionalとして扱われます。"),
        ],
        explanationRef: "explain-gold-optional-006",
        designIntent: "Optional.mapでmapperがnullを返した場合、空Optionalになることを確認する。"
    )

    // MARK: - Gold: Collections (Comparator chain)

    static let goldCollections004 = Quiz(
        id: "gold-collections-004",
        level: .gold,
        category: "collections",
        tags: ["Comparator", "thenComparing", "sort"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>(List.of("cc", "b", "aa"));
        list.sort(Comparator.comparingInt(String::length)
            .thenComparing(Comparator.naturalOrder()));
        System.out.println(list);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "[aa, b, cc]",
                   correct: false, misconception: "自然順だけでソートされると誤解",
                   explanation: "最初の比較キーはlengthです。長さ1のbが先です。"),
            Choice(id: "b", text: "[b, aa, cc]",
                   correct: true, misconception: nil,
                   explanation: "まず文字列長で並び、同じ長さ2のaaとccは自然順でaa、ccになります。"),
            Choice(id: "c", text: "[cc, b, aa]",
                   correct: false, misconception: "sortが元リストを変更しないと誤解",
                   explanation: "List.sortはリスト自身を並べ替えます。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "thenComparingにComparatorを渡せないと誤解",
                   explanation: "thenComparing(Comparator.naturalOrder())は有効です。"),
        ],
        explanationRef: "explain-gold-collections-004",
        designIntent: "Comparatorの主キーと副キーの順序でソート結果を追えるか確認する。"
    )

    // MARK: - Gold: Classes (inner class)

    static let goldClasses006 = Quiz(
        id: "gold-classes-006",
        level: .gold,
        category: "classes",
        tags: ["inner class", "non-static", "インスタンス"],
        code: """
class Outer {
    class Inner {}
}

public class Test {
    public static void main(String[] args) {
        Outer.Inner inner = new Outer.Inner();
        System.out.println(inner);
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる",
                   correct: false, misconception: "内部クラスもstaticネストクラスと同じ生成方法だと誤解",
                   explanation: "Innerは非static内部クラスなので、Outerインスタンスに結びつけて生成する必要があります。"),
            Choice(id: "b", text: "new Outer.Inner()でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "非static内部クラスは new Outer().new Inner() のように外側インスタンス経由で生成します。"),
            Choice(id: "c", text: "実行時にNullPointerException",
                   correct: false, misconception: "外側インスタンスがnullで実行されると誤解",
                   explanation: "外側インスタンスなしの生成はコンパイル時に拒否されます。"),
            Choice(id: "d", text: "Innerはprivateなのでコンパイルエラー",
                   correct: false, misconception: "内部クラスが暗黙privateだと誤解",
                   explanation: "ここではパッケージプライベートです。問題はstaticでない内部クラスの生成方法です。"),
        ],
        explanationRef: "explain-gold-classes-006",
        designIntent: "非static内部クラスのインスタンス生成には外側クラスのインスタンスが必要であることを確認する。"
    )

    // MARK: - Gold: Date/Time (Duration)

    static let goldDateTime003 = Quiz(
        id: "gold-date-time-003",
        level: .gold,
        category: "classes",
        tags: ["Duration", "LocalTime", "between"],
        code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        Duration d = Duration.between(LocalTime.of(23, 0), LocalTime.of(1, 0));
        System.out.println(d.toHours());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2",
                   correct: false, misconception: "日付をまたいで翌日の1時だと補正されると誤解",
                   explanation: "LocalTimeだけでは日付情報がありません。単純に23:00から同日の1:00への差になります。"),
            Choice(id: "b", text: "-22",
                   correct: true, misconception: nil,
                   explanation: "Duration.between(23:00, 01:00)は後者が前者より22時間前なので-22時間です。"),
            Choice(id: "c", text: "22",
                   correct: false, misconception: "絶対値で返ると誤解",
                   explanation: "Durationは負の期間も表現します。"),
            Choice(id: "d", text: "DateTimeException",
                   correct: false, misconception: "負のDurationが例外になると誤解",
                   explanation: "負のDurationは有効です。"),
        ],
        explanationRef: "explain-gold-date-time-003",
        designIntent: "LocalTimeだけのDuration.betweenは日付またぎ補正をせず、負のDurationを返すことを確認する。"
    )

    // MARK: - Silver: 整数除算

    static let silverDataTypes011 = Quiz(
        id: "silver-data-types-011",
        level: .silver,
        category: "data-types",
        tags: ["int", "除算", "整数演算"],
        code: """
public class Test {
    public static void main(String[] args) {
        System.out.println(5 / 2);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2",
                   correct: true, misconception: nil,
                   explanation: "int同士の除算なので小数部は切り捨てられ、2になります。"),
            Choice(id: "b", text: "2.5",
                   correct: false, misconception: "整数同士でも小数結果になると誤解",
                   explanation: "片方をdoubleにしない限り、int除算です。"),
            Choice(id: "c", text: "3",
                   correct: false, misconception: "四捨五入されると誤解",
                   explanation: "Javaの整数除算は四捨五入ではなく0方向への切り捨てです。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: nil,
                   explanation: "intリテラル同士の除算として有効です。"),
        ],
        explanationRef: "explain-silver-data-types-011",
        designIntent: "整数同士の除算では小数部が切り捨てられることを確認する。"
    )

    // MARK: - Silver: prefix/postfix

    static let silverOperators001 = Quiz(
        id: "silver-operators-001",
        level: .silver,
        category: "data-types",
        tags: ["インクリメント", "前置", "後置"],
        code: """
public class Test {
    public static void main(String[] args) {
        int x = 1;
        System.out.println(x++ + ++x);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "3",
                   correct: false, misconception: "両方とも元の値1で評価されると誤解",
                   explanation: "x++の後にxは2になり、++xで3になります。"),
            Choice(id: "b", text: "4",
                   correct: true, misconception: nil,
                   explanation: "x++は1を返してからxを2にし、++xは3にしてから返します。1 + 3で4です。"),
            Choice(id: "c", text: "5",
                   correct: false, misconception: "x++も増加後の値を返すと誤解",
                   explanation: "後置インクリメントは評価値としては増加前の値を返します。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "同じ式でxを複数回更新できないと誤解",
                   explanation: "Javaではこの式はコンパイル可能です。評価順を追う必要があります。"),
        ],
        explanationRef: "explain-silver-operators-001",
        designIntent: "前置・後置インクリメントの評価値と副作用の順序を確認する。"
    )

    // MARK: - Silver: boolean operators

    static let silverOperators002 = Quiz(
        id: "silver-operators-002",
        level: .silver,
        category: "data-types",
        tags: ["boolean", "&", "短絡評価"],
        code: """
public class Test {
    static boolean check() {
        System.out.print("X");
        return true;
    }

    public static void main(String[] args) {
        System.out.println(false & check());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "false",
                   correct: false, misconception: "&も短絡評価すると誤解",
                   explanation: "booleanの&は右辺も評価します。"),
            Choice(id: "b", text: "Xfalse",
                   correct: true, misconception: nil,
                   explanation: "false & check()ではcheckも実行されXが出力されます。その後、演算結果falseが出力されます。"),
            Choice(id: "c", text: "Xtrue",
                   correct: false, misconception: "&の結果をORのように考えている",
                   explanation: "false & true はfalseです。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "booleanに&を使えないと誤解",
                   explanation: "booleanにも&は使えます。ただし&&と違い短絡評価しません。"),
        ],
        explanationRef: "explain-silver-operators-002",
        designIntent: "booleanの&は短絡せず、&&とは評価有無が異なることを確認する。"
    )

    // MARK: - Silver: array length

    static let silverArray007 = Quiz(
        id: "silver-array-007",
        level: .silver,
        category: "data-types",
        tags: ["配列", "length", "メソッド"],
        code: """
public class Test {
    public static void main(String[] args) {
        int[] nums = {1, 2, 3};
        System.out.println(nums.length());
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "3と出力される",
                   correct: false, misconception: "配列lengthをメソッドだと誤解",
                   explanation: "配列のlengthはフィールドであり、メソッド呼び出しではありません。"),
            Choice(id: "b", text: "nums.length()でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "配列ではnums.lengthと書きます。Stringのlength()メソッドと混同しやすいポイントです。"),
            Choice(id: "c", text: "0と出力される",
                   correct: false, misconception: "length呼び出し失敗が0になると誤解",
                   explanation: "存在しないメソッド呼び出しとしてコンパイルエラーになります。"),
            Choice(id: "d", text: "実行時にNoSuchMethodError",
                   correct: false, misconception: "メソッド解決が実行時まで遅れると誤解",
                   explanation: "通常のソースコンパイルでは、存在しないメソッドはコンパイル時に検出されます。"),
        ],
        explanationRef: "explain-silver-array-007",
        designIntent: "配列のlengthフィールドとStringのlength()メソッドを区別できるか確認する。"
    )

    // MARK: - Silver: StringBuilder equals

    static let silverStringBuilder004 = Quiz(
        id: "silver-stringbuilder-004",
        level: .silver,
        category: "string",
        tags: ["StringBuilder", "equals", "参照比較"],
        code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder a = new StringBuilder("A");
        StringBuilder b = new StringBuilder("A");
        System.out.println(a.equals(b));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "true",
                   correct: false, misconception: "StringBuilder.equalsが内容比較だと誤解",
                   explanation: "StringBuilderはequalsを内容比較用にオーバーライドしていません。"),
            Choice(id: "b", text: "false",
                   correct: true, misconception: nil,
                   explanation: "aとbは別インスタンスです。StringBuilder.equalsはObject由来の参照比較なのでfalseです。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "StringBuilderにequalsがないと誤解",
                   explanation: "equalsはObjectから継承しているため呼び出せます。"),
            Choice(id: "d", text: "NullPointerException",
                   correct: false, misconception: nil,
                   explanation: "aもbもnullではありません。"),
        ],
        explanationRef: "explain-silver-stringbuilder-004",
        designIntent: "StringBuilderのequalsはStringのような内容比較ではないことを確認する。"
    )

    // MARK: - Silver: for scope

    static let silverControlFlow009 = Quiz(
        id: "silver-control-flow-009",
        level: .silver,
        category: "control-flow",
        tags: ["for", "スコープ", "ローカル変数"],
        code: """
public class Test {
    public static void main(String[] args) {
        for (int i = 0; i < 1; i++) {
            System.out.print(i);
        }
        System.out.println(i);
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "00と出力される",
                   correct: false, misconception: "for初期化部のiがループ後も見えると誤解",
                   explanation: "for初期化部で宣言したiのスコープはfor文の中だけです。"),
            Choice(id: "b", text: "System.out.println(i); でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "for文の外ではiはスコープ外です。"),
            Choice(id: "c", text: "0と出力される",
                   correct: false, misconception: "2つ目のprintlnが無視されると誤解",
                   explanation: "無視されるのではなく、iが見えないためコンパイルエラーです。"),
            Choice(id: "d", text: "実行時にNullPointerException",
                   correct: false, misconception: nil,
                   explanation: "プリミティブintのスコープ問題であり、nullは関係ありません。"),
        ],
        explanationRef: "explain-silver-control-flow-009",
        designIntent: "for文の初期化部で宣言した変数のスコープを確認する。"
    )

    // MARK: - Silver: String concatenation order

    static let silverString006 = Quiz(
        id: "silver-string-006",
        level: .silver,
        category: "string",
        tags: ["String", "文字列結合", "評価順"],
        code: """
public class Test {
    public static void main(String[] args) {
        System.out.println(1 + 2 + "A" + 3 + 4);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "3A34",
                   correct: true, misconception: nil,
                   explanation: "左から評価されます。1 + 2は数値加算で3、その後はStringが関わるため文字列結合になります。"),
            Choice(id: "b", text: "12A34",
                   correct: false, misconception: "最初からすべて文字列結合されると誤解",
                   explanation: "Stringが現れる前の1 + 2はint同士の加算です。"),
            Choice(id: "c", text: "3A7",
                   correct: false, misconception: "String後も数値同士なら加算されると誤解",
                   explanation: "\"A\"以降は文字列結合の文脈になり、3と4は文字として連結されます。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: nil,
                   explanation: "数値とStringの+演算は文字列結合として有効です。"),
        ],
        explanationRef: "explain-silver-string-006",
        designIntent: "+演算子が数値加算から文字列結合へ切り替わるタイミングを左結合の評価順で追えるか確認する。"
    )

    // MARK: - Silver: Arrays.compare

    static let silverArray008 = Quiz(
        id: "silver-array-008",
        level: .silver,
        category: "data-types",
        tags: ["配列", "Arrays.compare", "辞書順"],
        code: """
import java.util.Arrays;

public class Test {
    public static void main(String[] args) {
        int[] a = {1, 2};
        int[] b = {1, 3};
        System.out.println(Arrays.compare(a, b));
    }
}
""",
        question: "このコードを実行したとき、出力される値として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "負の値",
                   correct: true, misconception: nil,
                   explanation: "最初に異なる要素は2と3です。2 < 3なので、Arrays.compare(a, b)は負の値を返します。"),
            Choice(id: "b", text: "0",
                   correct: false, misconception: "配列の長さが同じなら0と誤解",
                   explanation: "長さだけでなく、要素を先頭から比較します。"),
            Choice(id: "c", text: "正の値",
                   correct: false, misconception: "配列bの方が大きいことを戻り値の正負と逆に理解",
                   explanation: "aがbより辞書順で小さいため、戻り値は負です。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "プリミティブ配列をcompareできないと誤解",
                   explanation: "Arraysにはint[]用のcompareメソッドが用意されています。"),
        ],
        explanationRef: "explain-silver-array-008",
        designIntent: "Arrays.compareが先頭から要素を比較し、大小関係を戻り値の正負で表すことを確認する。"
    )

    // MARK: - Silver: overload null specificity

    static let silverOverload006 = Quiz(
        id: "silver-overload-006",
        level: .silver,
        category: "overload-resolution",
        tags: ["オーバーロード", "null", "最も具体的"],
        code: """
public class Test {
    static void print(Object value) {
        System.out.println("Object");
    }

    static void print(String value) {
        System.out.println("String");
    }

    public static void main(String[] args) {
        print(null);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "String",
                   correct: true, misconception: nil,
                   explanation: "nullはObjectにもStringにも渡せますが、Stringの方がObjectより具体的な型なのでprint(String)が選ばれます。"),
            Choice(id: "b", text: "Object",
                   correct: false, misconception: "nullはObjectとして扱われると固定的に考えている",
                   explanation: "オーバーロード解決では、適用可能な候補のうち最も具体的なメソッドが選ばれます。"),
            Choice(id: "c", text: "NullPointerException",
                   correct: false, misconception: "null引数だけで例外が発生すると誤解",
                   explanation: "メソッド内でvalueを参照していないため、NullPointerExceptionは発生しません。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "null呼び出しは常に曖昧になると誤解",
                   explanation: "ObjectとStringには親子関係があるため、Stringがより具体的な候補として決まります。"),
        ],
        explanationRef: "explain-silver-overload-006",
        designIntent: "nullを渡したオーバーロードで、最も具体的な参照型メソッドが選ばれることを確認する。"
    )

    // MARK: - Silver: multi-catch parameter

    static let silverException007 = Quiz(
        id: "silver-exception-007",
        level: .silver,
        category: "exception-handling",
        tags: ["multi-catch", "例外", "final"],
        code: """
import java.io.IOException;

public class Test {
    public static void main(String[] args) {
        try {
            throw new IOException();
        } catch (IOException | RuntimeException e) {
            e = new RuntimeException();
            System.out.println("handled");
        }
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "handledと出力される",
                   correct: false, misconception: "catch変数を通常のローカル変数と同じように再代入できると誤解",
                   explanation: "multi-catchの例外パラメータには再代入できません。"),
            Choice(id: "b", text: "e = new RuntimeException(); でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "multi-catchのパラメータは暗黙的にfinalのように扱われるため、catchブロック内で再代入できません。"),
            Choice(id: "c", text: "throw new IOException(); でコンパイルエラー",
                   correct: false, misconception: "IOExceptionをcatchしていてもthrowできないと誤解",
                   explanation: "IOExceptionは直後のcatchで捕捉されるため、throw自体は問題ありません。"),
            Choice(id: "d", text: "実行時にClassCastException",
                   correct: false, misconception: nil,
                   explanation: "問題は実行時ではなく、multi-catchパラメータへの再代入によるコンパイルエラーです。"),
        ],
        explanationRef: "explain-silver-exception-007",
        designIntent: "multi-catchの例外パラメータに再代入できないという制約を確認する。"
    )

    // MARK: - Silver: static initialization

    static let silverClasses007 = Quiz(
        id: "silver-classes-007",
        level: .silver,
        category: "classes",
        tags: ["static", "初期化順序", "フィールド"],
        code: """
public class Test {
    static int x = 1;

    static {
        x += 2;
    }

    static int y = x + 1;

    public static void main(String[] args) {
        System.out.println(x + "," + y);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1,2",
                   correct: false, misconception: "staticブロックが後から実行されると誤解",
                   explanation: "staticフィールド初期化とstaticブロックは、ソースに現れた順に実行されます。"),
            Choice(id: "b", text: "3,4",
                   correct: true, misconception: nil,
                   explanation: "xは1で初期化され、staticブロックで3になります。その後yがx + 1で4になります。"),
            Choice(id: "c", text: "3,2",
                   correct: false, misconception: "yがstaticブロックより先に初期化されると誤解",
                   explanation: "yの宣言はstaticブロックの後にあるため、xが3になった後で初期化されます。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: nil,
                   explanation: "staticフィールドとstatic初期化ブロックの組み合わせとして有効です。"),
        ],
        explanationRef: "explain-silver-classes-007",
        designIntent: "staticフィールド初期化とstatic初期化ブロックが宣言順に実行されることを確認する。"
    )

    // MARK: - Silver: char increment

    static let silverDataTypes012 = Quiz(
        id: "silver-data-types-012",
        level: .silver,
        category: "data-types",
        tags: ["char", "インクリメント", "文字コード"],
        code: """
public class Test {
    public static void main(String[] args) {
        char c = 'A';
        c++;
        System.out.println(c);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "A",
                   correct: false, misconception: "c++の結果が反映されないと誤解",
                   explanation: "後置インクリメントでも、式の評価後に変数c自体は更新されます。"),
            Choice(id: "b", text: "B",
                   correct: true, misconception: nil,
                   explanation: "charは数値的なコード値を持つため、'A'をインクリメントすると次の文字'B'になります。"),
            Choice(id: "c", text: "66",
                   correct: false, misconception: "charが常に数値として表示されると誤解",
                   explanation: "println(char)は文字として出力します。数値として出したい場合はintへキャストします。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "charに++を使えないと誤解",
                   explanation: "charにもインクリメント演算子を使用できます。"),
        ],
        explanationRef: "explain-silver-data-types-012",
        designIntent: "charが整数的に扱える一方、printlnでは文字として表示されることを確認する。"
    )

    // MARK: - Gold: Stream partitioningBy

    static let goldStream010 = Quiz(
        id: "gold-stream-010",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "Collectors", "partitioningBy"],
        code: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        Map<Boolean, List<String>> map = Stream.of("a", "bb", "c")
            .collect(Collectors.partitioningBy(s -> s.length() == 1));

        System.out.println(map.get(true).size() + ":" + map.get(false).get(0));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2:bb",
                   correct: true, misconception: nil,
                   explanation: "長さ1の要素はaとcなのでtrue側は2件です。false側にはbbが入ります。"),
            Choice(id: "b", text: "1:a",
                   correct: false, misconception: "true/falseの分類条件を逆に見ている",
                   explanation: "aはtrue側です。false側の先頭はbbです。"),
            Choice(id: "c", text: "2:a",
                   correct: false, misconception: "false側ではなくtrue側をgetしていると誤解",
                   explanation: "出力の後半はmap.get(false).get(0)なのでbbです。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "partitioningByの戻り値をMap<Boolean, List<T>>として扱えないと誤解",
                   explanation: "partitioningByはBooleanキーのMapへ分類します。"),
        ],
        explanationRef: "explain-gold-stream-010",
        designIntent: "partitioningByがPredicateの結果でtrue/falseの2グループに分けることを確認する。"
    )

    // MARK: - Gold: wildcard add null

    static let goldGenerics007 = Quiz(
        id: "gold-generics-007",
        level: .gold,
        category: "generics",
        tags: ["Generics", "wildcard", "null"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<?> list = new ArrayList<String>();
        list.add(null);
        System.out.println(list.size());
    }
}
""",
        question: "このコードをコンパイルおよび実行したときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "1",
                   correct: true, misconception: nil,
                   explanation: "List<?>には具体的な値は追加できませんが、nullだけは追加できます。そのためサイズは1になります。"),
            Choice(id: "b", text: "0",
                   correct: false, misconception: "null追加が無視されると誤解",
                   explanation: "ArrayListへのnull追加は有効で、要素数にも数えられます。"),
            Choice(id: "c", text: "list.add(null)でコンパイルエラー",
                   correct: false, misconception: "List<?>にはnullも追加できないと誤解",
                   explanation: "任意の参照型に代入可能なnullは、List<?>にも追加できます。"),
            Choice(id: "d", text: "NullPointerException",
                   correct: false, misconception: "nullをArrayListに追加できないと誤解",
                   explanation: "ArrayListはnull要素を許容します。"),
        ],
        explanationRef: "explain-gold-generics-007",
        designIntent: "非境界ワイルドカードでは具体値は追加できないが、nullだけは例外的に追加できることを確認する。"
    )

    // MARK: - Gold: Optional map null

    static let goldOptional007 = Quiz(
        id: "gold-optional-007",
        level: .gold,
        category: "optional-api",
        tags: ["Optional", "map", "null"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Object result = Optional.of("java")
            .map(s -> null)
            .orElse("empty");
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "java",
                   correct: false, misconception: "mapの結果が無視されると誤解",
                   explanation: "mapはOptional内の値を関数の戻り値へ変換します。"),
            Choice(id: "b", text: "null",
                   correct: false, misconception: "mapがnullを含むOptionalを作ると誤解",
                   explanation: "Optional.mapのマッパーがnullを返すと、結果は空のOptionalになります。"),
            Choice(id: "c", text: "empty",
                   correct: true, misconception: nil,
                   explanation: "mapの結果がnullなのでOptionalは空になり、orElseの値emptyが返されます。"),
            Choice(id: "d", text: "NullPointerException",
                   correct: false, misconception: "マッパーの戻り値nullで例外になると誤解",
                   explanation: "mapは内部的にofNullable相当で扱うため、null結果は空になります。"),
        ],
        explanationRef: "explain-gold-optional-007",
        designIntent: "Optional.mapの変換結果がnullの場合、Optional.emptyとして扱われることを確認する。"
    )

    // MARK: - Gold: LocalDate plusMonths

    static let goldDateTime004 = Quiz(
        id: "gold-date-time-004",
        level: .gold,
        category: "data-types",
        tags: ["LocalDate", "plusMonths", "月末"],
        code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        LocalDate date = LocalDate.of(2026, 1, 31);
        System.out.println(date.plusMonths(1));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2026-02-28",
                   correct: true, misconception: nil,
                   explanation: "2026年2月には31日がないため、plusMonths(1)は有効な月末日である2月28日に調整します。"),
            Choice(id: "b", text: "2026-03-03",
                   correct: false, misconception: "存在しない日付分が翌月へ繰り越されると誤解",
                   explanation: "LocalDate.plusMonthsは月末へ調整し、日数差を翌月へ繰り越しません。"),
            Choice(id: "c", text: "2026-02-31",
                   correct: false, misconception: "存在しない日付が保持されると誤解",
                   explanation: "LocalDateは存在しない日付を表現しません。"),
            Choice(id: "d", text: "DateTimeException",
                   correct: false, misconception: "月末調整ではなく例外になると誤解",
                   explanation: "plusMonthsは結果月に同じ日がない場合、月末へ調整します。"),
        ],
        explanationRef: "explain-gold-date-time-004",
        designIntent: "LocalDate.plusMonthsが存在しない日付を月末へ調整する仕様を確認する。"
    )

    // MARK: - Gold: CompletableFuture thenCompose

    static let goldConcurrency008 = Quiz(
        id: "gold-concurrency-008",
        level: .gold,
        category: "concurrency",
        tags: ["CompletableFuture", "thenCompose", "join"],
        code: """
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) {
        CompletableFuture<Integer> future = CompletableFuture.completedFuture(2)
            .thenCompose(n -> CompletableFuture.completedFuture(n * 3));

        System.out.println(future.join());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2",
                   correct: false, misconception: "thenComposeの変換が実行されないと誤解",
                   explanation: "thenComposeは前段の結果2を受け取り、新しいCompletableFutureへつなげます。"),
            Choice(id: "b", text: "6",
                   correct: true, misconception: nil,
                   explanation: "2を受け取り、n * 3のCompletableFutureへ平坦につなぐため、join()で6を取得します。"),
            Choice(id: "c", text: "CompletableFuture[6]",
                   correct: false, misconception: "joinせずFuture自体が出力されると誤解",
                   explanation: "出力しているのはfuture.join()の戻り値です。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "thenComposeのラムダがCompletableFutureを返せないと誤解",
                   explanation: "thenComposeはCompletableFutureを返す関数を受け取り、ネストを平坦化します。"),
        ],
        explanationRef: "explain-gold-concurrency-008",
        designIntent: "thenComposeがCompletableFutureを返す処理を平坦につなぎ、joinで最終値を取得する流れを確認する。"
    )

    // MARK: - Gold: Path relativize

    static let goldIo005 = Quiz(
        id: "gold-io-005",
        level: .gold,
        category: "io",
        tags: ["Path", "relativize", "NIO.2"],
        code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path base = Path.of("/app/logs");
        Path target = Path.of("/app/logs/2026/app.log");
        System.out.println(base.relativize(target));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2026/app.log",
                   correct: true, misconception: nil,
                   explanation: "targetはbase配下のパスなので、baseからtargetへの相対パスは2026/app.logです。"),
            Choice(id: "b", text: "/app/logs/2026/app.log",
                   correct: false, misconception: "relativizeが絶対パスをそのまま返すと誤解",
                   explanation: "relativizeは基準パスから見た相対パスを返します。"),
            Choice(id: "c", text: "../2026/app.log",
                   correct: false, misconception: "baseの親からたどると誤解",
                   explanation: "targetはbaseの子孫なので、親へ戻る..は不要です。"),
            Choice(id: "d", text: "IllegalArgumentException",
                   correct: false, misconception: "絶対パス同士はrelativizeできないと誤解",
                   explanation: "同じ種類の絶対パス同士であればrelativizeできます。"),
        ],
        explanationRef: "explain-gold-io-005",
        designIntent: "Path.relativizeが基準パスから対象パスへの相対表現を返すことを確認する。"
    )
}
