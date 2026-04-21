import Foundation

extension QuizExpansion {
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
        silverControlFlow010,
        silverStringBuilder005,
        silverCollections007,
        silverOverload007,
        silverClasses008,
        silverException008,
        silverArray009,
        silverLambda005,
        goldStream012,
        goldStream013,
        goldGenerics008,
        goldOptional008,
        goldCollections005,
        goldConcurrency009,
        goldDateTime005,
        goldIo006,
        goldClasses007,
        silverFinal001,
        silverFinal002,
        silverFinal003,
        silverStatic001,
        silverStatic002,
        silverStatic003,
        silverStatic004,
        goldStatic005,
        goldStatic006,
        silverEnum001,
        silverEnum002,
        silverEnum003,
        goldEnum004,
        goldEnum005,
        silverObject001,
        silverObject002,
        goldObject003,
        goldObject004,
        goldAnnotations003,
        goldAnnotations004,
        goldAnnotations005,
        goldAnnotations006,
        goldAnnotations007,
        goldAnnotations008,
        goldAnnotations009,
        goldAnnotations010,
        goldAnnotations011,
        goldAnnotations012,
        goldException007,
        goldException008,
        goldException009,
        goldException010,
        goldException011,
        goldException012,
        goldException013,
        goldException014,
        goldException015,
        goldException016,
        goldException017,
        goldException018,
        goldException019,
        goldException020,
        goldSecureCoding001,
        goldSecureCoding002,
        goldSecureCoding003,
        goldSecureCoding004,
        goldSecureCoding005,
        goldSecureCoding006,
        goldSecureCoding007,
        goldSecureCoding008,
        goldSecureCoding009,
        goldSecureCoding010,
        goldSecureCoding011,
        goldSecureCoding012,
        goldSecureCoding013,
        goldSecureCoding014,
        goldSecureCoding015,
        goldSecureCoding016,
        goldSecureCoding017,
        goldSecureCoding018,
        goldSecureCoding019,
        goldSecureCoding020,
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

    // MARK: - Mixed Batch Queue-002

    static let silverControlFlow010 = Quiz(
        id: "silver-control-flow-010",
        level: .silver,
        category: "control-flow",
        tags: ["ラベル", "continue", "ネストループ"],
        code: """
public class Test {
    public static void main(String[] args) {
        outer:
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                if (i == 1 && j == 1) continue outer;
                System.out.print(i + "" + j + " ");
            }
        }
    }
}
""",
        question: "このコードを実行したとき、出力として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "00 01 02 10 20 21 22", correct: true, misconception: nil, explanation: "i=1,j=1で外側ループの次周へ進むため、11と12は出力されません。"),
            Choice(id: "b", text: "00 01 02 10 11 12 20 21 22", correct: false, misconception: "continue outerを通常continueと混同", explanation: "ラベル付きcontinueは指定した外側ループの次周へ移ります。"),
            Choice(id: "c", text: "00 01 02 10 20", correct: false, misconception: "i=2の内側ループが止まると誤解", explanation: "i=2では条件に一致しないため、j=0,1,2をすべて出力します。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "ラベル付きcontinueを使えないと誤解", explanation: "ラベル付きcontinueは有効な構文です。"),
        ],
        explanationRef: "explain-silver-control-flow-010",
        designIntent: "ラベル付きcontinueが内側ループではなく指定した外側ループへ制御を移すことを、出力順で追わせる。"
    )

    static let silverStringBuilder005 = Quiz(
        id: "silver-string-builder-005",
        level: .silver,
        category: "string",
        tags: ["StringBuilder", "append", "insert", "delete"],
        code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("abc");
        sb.append("d").insert(1, "X").delete(3, 5);
        System.out.println(sb);
    }
}
""",
        question: "このコードの出力として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "aXb", correct: true, misconception: nil, explanation: "abcd -> aXbcd -> delete(3,5)でcdを削除し、aXbになります。"),
            Choice(id: "b", text: "aXbc", correct: false, misconception: "deleteの終了indexを含む/含まないで混乱", explanation: "delete(3,5)はindex 3以上5未満を削除するため、cとdが消えます。"),
            Choice(id: "c", text: "abXd", correct: false, misconception: "insert位置を末尾寄りに誤解", explanation: "insert(1, \"X\")はindex 1の直前へ挿入します。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "メソッドチェーン不可と誤解", explanation: "StringBuilderの多くの変更メソッドは自分自身を返すためチェーンできます。"),
        ],
        explanationRef: "explain-silver-string-builder-005",
        designIntent: "StringBuilderの破壊的更新と、insert/deleteのインデックス範囲を順に追わせる。"
    )

    static let silverCollections007 = Quiz(
        id: "silver-collections-007",
        level: .silver,
        category: "collections",
        tags: ["Iterator", "remove", "ArrayList"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>(Arrays.asList("A", "B", "C"));
        Iterator<String> it = list.iterator();
        while (it.hasNext()) {
            String s = it.next();
            if (s.equals("B")) it.remove();
        }
        System.out.println(list);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "[A, C]", correct: true, misconception: nil, explanation: "Iterator.next()でBを取得した直後にIterator.remove()するため、Bだけが削除されます。"),
            Choice(id: "b", text: "[A, B, C]", correct: false, misconception: "removeが効かないと誤解", explanation: "Iterator.remove()は直前にnextした要素を削除します。"),
            Choice(id: "c", text: "[B]", correct: false, misconception: "条件一致した要素だけ残ると誤解", explanation: "条件一致したBを削除するコードです。"),
            Choice(id: "d", text: "ConcurrentModificationException", correct: false, misconception: "Iterator経由のremoveも禁止と誤解", explanation: "走査中の削除はIterator.remove()なら安全です。"),
        ],
        explanationRef: "explain-silver-collections-007",
        designIntent: "拡張forやlist.removeではなくIterator.removeを使った安全な走査中削除を確認する。"
    )

    static let silverOverload007 = Quiz(
        id: "silver-overload-007",
        level: .silver,
        category: "overload-resolution",
        tags: ["オーバーロード", "型昇格", "ボクシング"],
        code: """
public class Test {
    static void m(int x) { System.out.println("int"); }
    static void m(Integer x) { System.out.println("Integer"); }

    public static void main(String[] args) {
        short s = 1;
        m(s);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "int", correct: true, misconception: nil, explanation: "shortはintへ型昇格できるため、m(int)が選ばれます。"),
            Choice(id: "b", text: "Integer", correct: false, misconception: "ボクシングが型昇格より優先されると誤解", explanation: "shortからIntegerへの直接ボクシングはできず、型昇格のm(int)が有効です。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "shortを渡せる候補がないと誤解", explanation: "shortからintへの型昇格が可能です。"),
            Choice(id: "d", text: "曖昧エラー", correct: false, misconception: "候補が同順位だと誤解", explanation: "m(int)が明確に適用可能です。"),
        ],
        explanationRef: "explain-silver-overload-007",
        designIntent: "プリミティブの型昇格とボクシングの候補選択を、short引数で見抜かせる。"
    )

    static let silverClasses008 = Quiz(
        id: "silver-classes-008",
        level: .silver,
        category: "classes",
        tags: ["static", "インスタンス初期化", "コンストラクタ"],
        code: """
class Box {
    static int shared = 1;
    int value = shared++;
    Box() { value += shared; }
}

public class Test {
    public static void main(String[] args) {
        Box a = new Box();
        Box b = new Box();
        System.out.println(a.value + " " + b.value + " " + Box.shared);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "3 5 3", correct: true, misconception: nil, explanation: "a生成でvalue=1,shared=2,value=3。b生成でvalue=2,shared=3,value=5です。"),
            Choice(id: "b", text: "2 3 3", correct: false, misconception: "コンストラクタでの加算を見落とし", explanation: "各インスタンス生成時にコンストラクタで現在のsharedがvalueへ加算されます。"),
            Choice(id: "c", text: "3 4 3", correct: false, misconception: "b生成時のshared更新順を誤解", explanation: "bのフィールド初期化ではshared++の旧値2が入り、その後sharedは3になります。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "staticをインスタンス初期化で使えないと誤解", explanation: "staticフィールドはインスタンス初期化式から参照・更新できます。"),
        ],
        explanationRef: "explain-silver-classes-008",
        designIntent: "staticフィールドを共有しながら、インスタンスフィールド初期化とコンストラクタが生成ごとに走る順序を追わせる。"
    )

    static let silverException008 = Quiz(
        id: "silver-exception-008",
        level: .silver,
        category: "exception-handling",
        tags: ["try-finally", "return", "実行順序"],
        code: """
public class Test {
    static int run() {
        try {
            System.out.print("T ");
            return 1;
        } finally {
            System.out.print("F ");
        }
    }
    public static void main(String[] args) {
        System.out.println(run());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "T F 1", correct: true, misconception: nil, explanation: "return値1が準備された後でもfinallyが実行され、その後main側のprintlnが1を出力します。"),
            Choice(id: "b", text: "T 1 F", correct: false, misconception: "finallyが呼び出し元のprintln後に動くと誤解", explanation: "finallyはrun()から戻る前に実行されます。"),
            Choice(id: "c", text: "T 1", correct: false, misconception: "returnでfinallyが飛ばされると誤解", explanation: "returnがあってもfinallyは実行されます。"),
            Choice(id: "d", text: "F 1", correct: false, misconception: "try本体が実行されないと誤解", explanation: "try本体のprintが先に実行されます。"),
        ],
        explanationRef: "explain-silver-exception-008",
        designIntent: "returnを含むtry-finallyで、finallyが呼び出し元へ戻る前に実行されることを確認する。"
    )

    static let silverArray009 = Quiz(
        id: "silver-array-009",
        level: .silver,
        category: "data-types",
        tags: ["配列", "多次元配列", "length"],
        code: """
public class Test {
    public static void main(String[] args) {
        int[][] array = new int[2][];
        array[0] = new int[] {1, 2, 3};
        array[1] = new int[] {4};
        System.out.println(array.length + " " + array[0].length + " " + array[1][0]);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2 3 4", correct: true, misconception: nil, explanation: "外側配列長は2、array[0]の内側長は3、array[1][0]は4です。"),
            Choice(id: "b", text: "2 1 4", correct: false, misconception: "array[0]の長さをarray[1]と混同", explanation: "array[0]には3要素の配列を代入しています。"),
            Choice(id: "c", text: "3 2 4", correct: false, misconception: "外側配列と内側配列の長さを混同", explanation: "new int[2][]なので外側配列の長さは2です。"),
            Choice(id: "d", text: "NullPointerException", correct: false, misconception: "内側配列が未設定のままだと誤解", explanation: "array[0]とarray[1]の両方に配列を代入済みです。"),
        ],
        explanationRef: "explain-silver-array-009",
        designIntent: "ジャグ配列で外側length、内側length、要素アクセスを分けて追わせる。"
    )

    static let silverLambda005 = Quiz(
        id: "silver-lambda-005",
        level: .silver,
        category: "lambda-streams",
        tags: ["Predicate", "and", "短絡評価"],
        code: """
import java.util.function.*;

public class Test {
    public static void main(String[] args) {
        Predicate<String> p = s -> { System.out.print("A"); return s.length() > 2; };
        Predicate<String> q = s -> { System.out.print("B"); return s.startsWith("J"); };
        System.out.println(p.and(q).test("Hi"));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "Afalse", correct: true, misconception: nil, explanation: "pがfalseを返すため、andの右側qは実行されません。"),
            Choice(id: "b", text: "ABfalse", correct: false, misconception: "andで常に両方評価されると誤解", explanation: "Predicate.andは短絡評価します。左がfalseなら右は評価しません。"),
            Choice(id: "c", text: "ABtrue", correct: false, misconception: "Hiが条件を満たすと誤解", explanation: "\"Hi\"の長さは2なので、pはfalseです。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "ブロックラムダでprintできないと誤解", explanation: "戻り値を明示returnしているためPredicateとして有効です。"),
        ],
        explanationRef: "explain-silver-lambda-005",
        designIntent: "Predicate.andの短絡評価と、ラムダ内副作用の実行有無を出力順で確認する。"
    )

    static let goldStream012 = Quiz(
        id: "gold-stream-012",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "flatMap", "distinct", "sorted"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<List<Integer>> nested = Arrays.asList(
            Arrays.asList(2, 1),
            Arrays.asList(2, 3)
        );
        nested.stream()
            .flatMap(List::stream)
            .distinct()
            .sorted()
            .forEach(System.out::print);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "123", correct: true, misconception: nil, explanation: "flatMapで2,1,2,3にし、distinctで重複2を除き、sortedで1,2,3になります。"),
            Choice(id: "b", text: "2123", correct: false, misconception: "distinct/sortedを見落とし", explanation: "distinctで2の重複が消え、sortedで昇順になります。"),
            Choice(id: "c", text: "213", correct: false, misconception: "distinct後の順序のまま出力されると誤解", explanation: "distinct後にsortedがあるため、最終順序は1,2,3です。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "List::streamが使えないと誤解", explanation: "flatMap(List::stream)はList内要素を1本のStreamへ平坦化できます。"),
        ],
        explanationRef: "explain-gold-stream-012",
        designIntent: "flatMap、distinct、sortedの順にStream要素がどう変化するかを追わせる。"
    )

    static let goldStream013 = Quiz(
        id: "gold-stream-013",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "partitioningBy", "Collectors"],
        code: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        Map<Boolean, Long> map = Stream.of("a", "bb", "c")
            .collect(Collectors.partitioningBy(
                s -> s.length() == 1,
                Collectors.counting()
            ));
        System.out.println(map.get(true) + ":" + map.get(false));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2:1", correct: true, misconception: nil, explanation: "長さ1はaとcの2件、false側はbbの1件です。"),
            Choice(id: "b", text: "1:2", correct: false, misconception: "true/false側を逆に理解", explanation: "条件はlength == 1なので、aとcがtrue側です。"),
            Choice(id: "c", text: "2:null", correct: false, misconception: "false側が作られないと誤解", explanation: "partitioningByはtrue/false両方のキーを持つMapを返します。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "下流Collectorを渡せないと誤解", explanation: "partitioningByには下流Collectorを指定できます。"),
        ],
        explanationRef: "explain-gold-stream-013",
        designIntent: "partitioningByのtrue/false分割と下流countingの結果を追わせる。"
    )

    static let goldGenerics008 = Quiz(
        id: "gold-generics-008",
        level: .gold,
        category: "generics",
        tags: ["Generics", "super", "PECS"],
        code: """
import java.util.*;

public class Test {
    static void addAll(List<? super Number> list) {
        list.add(1);
        list.add(2.5);
    }
    public static void main(String[] args) {
        List<Object> values = new ArrayList<>();
        addAll(values);
        System.out.println(values);
    }
}
""",
        question: "このコードを実行したとき、出力として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "[1, 2.5]", correct: true, misconception: nil, explanation: "List<Object>はList<? super Number>として渡せ、IntegerとDoubleを追加できます。"),
            Choice(id: "b", text: "[]", correct: false, misconception: "addAll内の追加が元リストに反映されないと誤解", explanation: "同じListインスタンスへ追加しています。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "super境界にNumberサブタイプを追加できないと誤解", explanation: "? super NumberにはNumberおよびそのサブタイプを安全に追加できます。"),
            Choice(id: "d", text: "ClassCastException", correct: false, misconception: "Objectリストに数値を入れると実行時エラーと誤解", explanation: "ObjectはInteger/Doubleの上位型なので格納可能です。"),
        ],
        explanationRef: "explain-gold-generics-008",
        designIntent: "PECSのConsumer superを、List<Object>へNumber系を追加するコードで確認する。"
    )

    static let goldOptional008 = Quiz(
        id: "gold-optional-008",
        level: .gold,
        category: "optional-api",
        tags: ["Optional", "filter", "orElseGet"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        String result = Optional.of("Java")
            .filter(s -> s.length() > 5)
            .orElseGet(() -> "fallback");
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "Java", correct: false, misconception: "filter条件を満たすと誤解", explanation: "\"Java\"の長さは4なので、length > 5はfalseです。"),
            Choice(id: "b", text: "fallback", correct: true, misconception: nil, explanation: "filterでOptionalが空になり、orElseGetのSupplierが実行されます。"),
            Choice(id: "c", text: "null", correct: false, misconception: "空Optionalがnullになると誤解", explanation: "orElseGetが代替値を返します。"),
            Choice(id: "d", text: "NoSuchElementException", correct: false, misconception: "空Optionalを直接getすると誤解", explanation: "get()ではなくorElseGet()を使っています。"),
        ],
        explanationRef: "explain-gold-optional-008",
        designIntent: "Optional.filterで空になった後、orElseGetが必要時だけ実行される流れを追わせる。"
    )

    static let goldCollections005 = Quiz(
        id: "gold-collections-005",
        level: .gold,
        category: "collections",
        tags: ["Map", "computeIfAbsent", "List"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Map<String, List<Integer>> map = new HashMap<>();
        map.computeIfAbsent("A", k -> new ArrayList<>()).add(1);
        map.computeIfAbsent("A", k -> new ArrayList<>()).add(2);
        System.out.println(map.get("A").size());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1", correct: false, misconception: "2回目でリストが作り直されると誤解", explanation: "キーAは既に存在するため、2回目は既存のListが返されます。"),
            Choice(id: "b", text: "2", correct: true, misconception: nil, explanation: "1回目でListを作成し1を追加、2回目は同じListに2を追加するためサイズ2です。"),
            Choice(id: "c", text: "0", correct: false, misconception: "addがMapに反映されないと誤解", explanation: "computeIfAbsentが返したListはMap内に保持されているListです。"),
            Choice(id: "d", text: "NullPointerException", correct: false, misconception: "get(\"A\")がnullになると誤解", explanation: "computeIfAbsentによりAの値は作成済みです。"),
        ],
        explanationRef: "explain-gold-collections-005",
        designIntent: "computeIfAbsentが既存値を再利用するため、同じListへ要素が蓄積されることを確認する。"
    )

    static let goldConcurrency009 = Quiz(
        id: "gold-concurrency-009",
        level: .gold,
        category: "concurrency",
        tags: ["CompletableFuture", "exceptionally", "thenApply"],
        code: """
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) {
        CompletableFuture<Integer> future = CompletableFuture.<Integer>supplyAsync(() -> {
            throw new RuntimeException();
        }).exceptionally(ex -> 10)
          .thenApply(n -> n + 5);

        System.out.println(future.join());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "10", correct: false, misconception: "exceptionally後のthenApplyを見落とし", explanation: "exceptionallyで10に回復した後、thenApplyで5を加えます。"),
            Choice(id: "b", text: "15", correct: true, misconception: nil, explanation: "例外はexceptionallyで10に変換され、その値にthenApplyで5を加えるため15です。"),
            Choice(id: "c", text: "RuntimeExceptionで異常終了", correct: false, misconception: "exceptionallyで回復しないと誤解", explanation: "exceptionallyが例外を受け取り、代替値10を返しています。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "supplyAsyncの例外ラムダが型推論できないと誤解", explanation: "明示的に<Integer>を指定しているため型は確定しています。"),
        ],
        explanationRef: "explain-gold-concurrency-009",
        designIntent: "CompletableFutureの例外回復後に通常のthenApplyチェーンへ戻る流れを追わせる。"
    )

    static let goldDateTime005 = Quiz(
        id: "gold-date-time-005",
        level: .gold,
        category: "data-types",
        tags: ["LocalTime", "plusMinutes", "日付時刻API"],
        code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        LocalTime time = LocalTime.of(23, 30).plusMinutes(90);
        System.out.println(time);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "00:60", correct: false, misconception: "分が60で止まると誤解", explanation: "LocalTimeは正規化された時刻を表します。"),
            Choice(id: "b", text: "01:00", correct: true, misconception: nil, explanation: "23:30に90分を足すと翌日の01:00になります。LocalTimeは日付を持たないため時刻だけ表示します。"),
            Choice(id: "c", text: "25:00", correct: false, misconception: "24時を超えて表示されると誤解", explanation: "LocalTimeは0:00から23:59:59...の範囲へ循環します。"),
            Choice(id: "d", text: "DateTimeException", correct: false, misconception: "日付をまたぐ加算が例外になると誤解", explanation: "plusMinutesは有効に時刻を循環させます。"),
        ],
        explanationRef: "explain-gold-date-time-005",
        designIntent: "LocalTimeが日付を持たず、24時をまたぐ加算で時刻だけが循環することを確認する。"
    )

    static let goldIo006 = Quiz(
        id: "gold-io-006",
        level: .gold,
        category: "io",
        tags: ["Path", "resolveSibling", "NIO.2"],
        code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path path = Path.of("/app/logs/app.log");
        System.out.println(path.resolveSibling("old.log"));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "/app/logs/old.log", correct: true, misconception: nil, explanation: "resolveSiblingは元パスのファイル名部分を兄弟パスold.logへ置き換えます。"),
            Choice(id: "b", text: "/app/logs/app.log/old.log", correct: false, misconception: "resolveとresolveSiblingを混同", explanation: "resolveなら子として連結しますが、resolveSiblingは同じ親配下の兄弟を解決します。"),
            Choice(id: "c", text: "old.log", correct: false, misconception: "親情報が消えると誤解", explanation: "元パスの親/app/logsは保持されます。"),
            Choice(id: "d", text: "InvalidPathException", correct: false, misconception: "絶対パスの兄弟解決が無効と誤解", explanation: "このresolveSibling呼び出しは有効です。"),
        ],
        explanationRef: "explain-gold-io-006",
        designIntent: "Path.resolveSiblingが親ディレクトリを保ったままファイル名部分を置き換えることを追わせる。"
    )

    static let goldClasses007 = Quiz(
        id: "gold-classes-007",
        level: .gold,
        category: "classes",
        tags: ["record", "コンパクトコンストラクタ", "不変データ"],
        code: """
record Point(int x, int y) {
    Point {
        if (x < 0) x = 0;
    }
}

public class Test {
    public static void main(String[] args) {
        Point p = new Point(-1, 2);
        System.out.println(p.x() + "," + p.y());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "-1,2", correct: false, misconception: "コンパクトコンストラクタ内の代入が無視されると誤解", explanation: "コンパクトコンストラクタではパラメータxを書き換えられ、その値がフィールド初期化に使われます。"),
            Choice(id: "b", text: "0,2", correct: true, misconception: nil, explanation: "引数xは-1ですが、コンパクトコンストラクタ内で0に補正されるためx()は0です。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "recordのコンパクトコンストラクタでパラメータを代入できないと誤解", explanation: "recordコンポーネントのフィールドはfinalですが、コンストラクタパラメータxの再代入は可能です。"),
            Choice(id: "d", text: "0,0", correct: false, misconception: "yもデフォルト値になると誤解", explanation: "yは引数2がそのまま使われます。"),
        ],
        explanationRef: "explain-gold-classes-007",
        designIntent: "recordのコンパクトコンストラクタでパラメータを検証・補正し、その後コンポーネントへ代入される流れを追わせる。"
    )

    // MARK: - Modifier / Static / Enum / Object Batch

    static let silverFinal001 = Quiz(
        id: "silver-final-001",
        level: .silver,
        category: "classes",
        tags: ["final", "ローカル変数", "再代入"],
        code: """
public class Test {
    public static void main(String[] args) {
        final int x = 10;
        x++;
        System.out.println(x);
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "11と出力される", correct: false, misconception: "finalが値の変更を許すと誤解", explanation: "`final` ローカル変数は一度代入すると再代入できません。`x++` も再代入を含みます。"),
            Choice(id: "b", text: "x++でコンパイルエラー", correct: true, misconception: nil, explanation: "`x++` は `x = x + 1` 相当なので、final変数への再代入としてコンパイルエラーになります。"),
            Choice(id: "c", text: "10と出力される", correct: false, misconception: "x++が無視されると誤解", explanation: "不正な変更は無視されるのではなく、コンパイル時に拒否されます。"),
            Choice(id: "d", text: "実行時にUnsupportedOperationException", correct: false, misconception: "finalを実行時制約と誤解", explanation: "final変数への再代入はコンパイル時のエラーです。"),
        ],
        explanationRef: "explain-silver-final-001",
        designIntent: "finalローカル変数に対するインクリメントも再代入であることを確認する。"
    )

    static let silverFinal002 = Quiz(
        id: "silver-final-002",
        level: .silver,
        category: "classes",
        tags: ["final", "フィールド", "コンストラクタ"],
        code: """
class Card {
    final String rank;
    static final String SUIT = "S";

    Card(String rank) {
        this.rank = rank;
    }

    String label() {
        return rank + SUIT;
    }
}

public class Test {
    public static void main(String[] args) {
        Card card = new Card("A");
        System.out.println(card.label());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "AS", correct: true, misconception: nil, explanation: "finalフィールドrankはコンストラクタで一度だけ代入され、static finalのSUITと連結されます。"),
            Choice(id: "b", text: "A", correct: false, misconception: "static finalフィールドが参照できないと誤解", explanation: "同じクラス内のインスタンスメソッドからstaticフィールドを参照できます。"),
            Choice(id: "c", text: "nullS", correct: false, misconception: "finalフィールドが初期化されないと誤解", explanation: "Card(\"A\") のコンストラクタでrankにAが代入されます。"),
            Choice(id: "d", text: "this.rank = rank; でコンパイルエラー", correct: false, misconception: "finalフィールドはコンストラクタでも代入できないと誤解", explanation: "blank finalフィールドはコンストラクタで確実に一度代入できます。"),
        ],
        explanationRef: "explain-silver-final-002",
        designIntent: "finalフィールドは宣言時だけでなくコンストラクタでも初期化できることを追わせる。"
    )

    static let silverFinal003 = Quiz(
        id: "silver-final-003",
        level: .silver,
        category: "inheritance",
        tags: ["final", "継承", "オーバーライド"],
        code: """
class Parent {
    final void show() {
        System.out.print("P");
    }
}

class Child extends Parent {
    void show() {
        System.out.print("C");
    }
}

public class Test {}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる", correct: false, misconception: "finalメソッドも通常通りオーバーライドできると誤解", explanation: "finalメソッドはサブクラスでオーバーライドできません。"),
            Choice(id: "b", text: "Childのshow()宣言でコンパイルエラー", correct: true, misconception: nil, explanation: "Parent.show()がfinalなので、同じシグネチャで再定義しようとするとコンパイルエラーです。"),
            Choice(id: "c", text: "実行するとCと出力される", correct: false, misconception: "実行時の動的ディスパッチまで進むと誤解", explanation: "コンパイルできないため実行されません。"),
            Choice(id: "d", text: "Parentクラスを継承する行でコンパイルエラー", correct: false, misconception: "finalメソッドを持つクラスは継承できないと誤解", explanation: "finalなのはメソッドであり、Parentクラス自体は継承できます。"),
        ],
        explanationRef: "explain-silver-final-003",
        designIntent: "finalメソッドとfinalクラスの違いを、オーバーライド禁止として確認する。"
    )

    static let silverStatic001 = Quiz(
        id: "silver-static-001",
        level: .silver,
        category: "classes",
        tags: ["static", "クラス変数", "共有状態"],
        code: """
class Counter {
    static int total = 0;
    int id = ++total;
}

public class Test {
    public static void main(String[] args) {
        Counter a = new Counter();
        Counter b = new Counter();
        System.out.println(a.id + ":" + b.id + ":" + Counter.total);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1:1:0", correct: false, misconception: "staticフィールドもインスタンスごとに別物と誤解", explanation: "totalはCounterクラスに1つだけ存在し、全インスタンスで共有されます。"),
            Choice(id: "b", text: "1:2:2", correct: true, misconception: nil, explanation: "1個目の生成でtotalは1、2個目の生成でtotalは2になります。"),
            Choice(id: "c", text: "0:1:2", correct: false, misconception: "++totalの前置インクリメント順を誤解", explanation: "前置インクリメントなので、増えた後の値がidに入ります。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "インスタンスフィールド初期化でstaticを使えないと誤解", explanation: "インスタンスフィールド初期化式からstaticフィールドを参照・更新できます。"),
        ],
        explanationRef: "explain-silver-static-001",
        designIntent: "staticフィールドがインスタンス間で共有されることを、生成順と値の変化で追わせる。"
    )

    static let silverStatic002 = Quiz(
        id: "silver-static-002",
        level: .silver,
        category: "classes",
        tags: ["static", "インスタンスメンバ", "this"],
        code: """
class Tool {
    int size = 3;

    static int twice() {
        return size * 2;
    }
}

public class Test {}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "6を返すメソッドとして正常にコンパイルできる", correct: false, misconception: "staticメソッドが暗黙のthisを持つと誤解", explanation: "staticメソッドには特定のインスタンスがないため、sizeを直接参照できません。"),
            Choice(id: "b", text: "return size * 2; でコンパイルエラー", correct: true, misconception: nil, explanation: "非staticフィールドsizeはインスタンスに属するため、staticメソッドからはオブジェクト経由で参照する必要があります。"),
            Choice(id: "c", text: "実行時にNullPointerException", correct: false, misconception: "thisがnullになると誤解", explanation: "this以前に、static文脈から非staticメンバを直接参照できずコンパイルエラーです。"),
            Choice(id: "d", text: "sizeが0として扱われる", correct: false, misconception: "インスタンスなしではデフォルト値になると誤解", explanation: "どのインスタンスのsizeか決まらないため、値は読み出されません。"),
        ],
        explanationRef: "explain-silver-static-002",
        designIntent: "staticメソッドから非staticフィールドを直接参照できない理由を確認する。"
    )

    static let silverStatic003 = Quiz(
        id: "silver-static-003",
        level: .silver,
        category: "classes",
        tags: ["static", "インスタンスメソッド", "クラス内アクセス"],
        code: """
class Item {
    static int rate = 2;
    int price;

    Item(int price) {
        this.price = price;
    }

    int total() {
        return price * rate;
    }

    static void change(int newRate) {
        rate = newRate;
    }
}

public class Test {
    public static void main(String[] args) {
        Item item = new Item(5);
        System.out.print(item.total() + " ");
        Item.change(3);
        System.out.println(item.total());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "10 15", correct: true, misconception: nil, explanation: "インスタンスメソッドtotal()はpriceとstaticなrateの両方にアクセスでき、rate変更後は15になります。"),
            Choice(id: "b", text: "10 10", correct: false, misconception: "staticフィールド変更が既存インスタンスに影響しないと誤解", explanation: "rateはクラス共有なので、既存のitem.total()にも新しい値が使われます。"),
            Choice(id: "c", text: "5 15", correct: false, misconception: "初回のrateを掛け忘れている", explanation: "最初のrateは2なので、5 * 2で10です。"),
            Choice(id: "d", text: "total()内のrate参照でコンパイルエラー", correct: false, misconception: "インスタンスメソッドからstaticへ直接アクセスできないと誤解", explanation: "インスタンスメソッドからstaticメンバを参照することは可能です。"),
        ],
        explanationRef: "explain-silver-static-003",
        designIntent: "クラス内でインスタンスメソッドがインスタンスメンバとstaticメンバの両方へアクセスできることを追わせる。"
    )

    static let silverStatic004 = Quiz(
        id: "silver-static-004",
        level: .silver,
        category: "classes",
        tags: ["static", "null", "メンバ呼び出し"],
        code: """
class Config {
    static int value = 7;
    static String name() {
        return "OK";
    }
}

public class Test {
    public static void main(String[] args) {
        Config config = null;
        System.out.println(config.name() + ":" + config.value);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "OK:7", correct: true, misconception: nil, explanation: "staticメンバはクラスに属するため、null参照を通して書いても実際にはConfigのstaticメンバが解決されます。"),
            Choice(id: "b", text: "NullPointerException", correct: false, misconception: "static呼び出しもインスタンス参照を逆参照すると誤解", explanation: "この式ではstaticメンバ解決なので、通常のインスタンスメンバ呼び出しとは違いNPEになりません。"),
            Choice(id: "c", text: "null:0", correct: false, misconception: "configがnullなのでstatic値も初期化されないと誤解", explanation: "Config.valueはクラス側のフィールドとして7に初期化されています。"),
            Choice(id: "d", text: "config.name()でコンパイルエラー", correct: false, misconception: "参照変数経由のstaticアクセスが構文的に禁止と誤解", explanation: "推奨はConfig.name()ですが、参照変数経由でもコンパイルはできます。"),
        ],
        explanationRef: "explain-silver-static-004",
        designIntent: "nullに対するstaticメンバ呼び出しはインスタンスメンバ呼び出しと異なりNPEにならないことを確認する。"
    )

    static let goldStatic005 = Quiz(
        id: "gold-static-005",
        level: .gold,
        category: "inheritance",
        tags: ["static", "メソッド隠蔽", "動的ディスパッチ"],
        code: """
class Parent {
    static String name() { return "P"; }
    String label() { return "PI"; }
}

class Child extends Parent {
    static String name() { return "C"; }
    String label() { return "CI"; }
}

public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        System.out.println(p.name() + ":" + p.label());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "C:CI", correct: false, misconception: "staticメソッドもオーバーライドされると誤解", explanation: "staticメソッドは参照変数の型Parentで解決されます。"),
            Choice(id: "b", text: "P:CI", correct: true, misconception: nil, explanation: "name()はstaticなのでParent版、label()はインスタンスメソッドなのでChild版が呼ばれます。"),
            Choice(id: "c", text: "P:PI", correct: false, misconception: "インスタンスメソッドも参照型だけで決まると誤解", explanation: "label()はオーバーライドされており、実体Childに基づいて動的に呼ばれます。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "staticメソッドを同名で宣言できないと誤解", explanation: "これはオーバーライドではなくメソッド隠蔽として扱われます。"),
        ],
        explanationRef: "explain-gold-static-005",
        designIntent: "staticメソッド隠蔽とインスタンスメソッドのオーバーライドを同じ式で比較させる。"
    )

    static let goldStatic006 = Quiz(
        id: "gold-static-006",
        level: .gold,
        category: "classes",
        tags: ["static", "初期化順序", "static初期化ブロック"],
        code: """
class Logger {
    static int n = init();

    static {
        System.out.print("B" + n + " ");
        n++;
    }

    Logger() {
        System.out.print("C" + n + " ");
    }

    static int init() {
        System.out.print("A ");
        return 1;
    }
}

public class Test {
    public static void main(String[] args) {
        new Logger();
        new Logger();
        System.out.println(Logger.n);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "A B1 C2 C2 2", correct: true, misconception: nil, explanation: "static初期化は最初のLogger利用時に一度だけ走り、その後コンストラクタが2回実行されます。"),
            Choice(id: "b", text: "A B1 C2 A B1 C2 2", correct: false, misconception: "static初期化がインスタンス生成ごとに走ると誤解", explanation: "staticフィールド初期化とstaticブロックはクラス初期化時に一度だけです。"),
            Choice(id: "c", text: "C0 C0 0", correct: false, misconception: "static初期化よりコンストラクタが先と誤解", explanation: "インスタンス生成前にクラス初期化が完了します。"),
            Choice(id: "d", text: "B0 A C1 C1 1", correct: false, misconception: "staticフィールド初期化とstaticブロックの順序を逆に理解", explanation: "宣言順に実行されるため、まずn = init()、次にstaticブロックです。"),
        ],
        explanationRef: "explain-gold-static-006",
        designIntent: "static初期化が宣言順かつ一度だけ実行され、コンストラクタは生成ごとに実行されることを追わせる。"
    )

    static let silverEnum001 = Quiz(
        id: "silver-enum-001",
        level: .silver,
        category: "classes",
        tags: ["enum", "name", "ordinal"],
        code: """
enum Level {
    LOW, MEDIUM, HIGH
}

public class Test {
    public static void main(String[] args) {
        Level level = Level.MEDIUM;
        System.out.println(level.name() + ":" + level.ordinal());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "MEDIUM:1", correct: true, misconception: nil, explanation: "name()は定数名、ordinal()は宣言順の0始まり番号を返します。MEDIUMは2番目なので1です。"),
            Choice(id: "b", text: "MEDIUM:2", correct: false, misconception: "ordinalが1始まりだと誤解", explanation: "ordinal()は0始まりです。"),
            Choice(id: "c", text: "Level.MEDIUM:1", correct: false, misconception: "name()が型名付き文字列を返すと誤解", explanation: "name()は定数名だけを返します。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "enumでメソッドを呼べないと誤解", explanation: "すべてのenum定数はjava.lang.Enum由来のname()やordinal()を持ちます。"),
        ],
        explanationRef: "explain-silver-enum-001",
        designIntent: "enumのnameとordinalを、宣言順に沿って確認する。"
    )

    static let silverEnum002 = Quiz(
        id: "silver-enum-002",
        level: .silver,
        category: "classes",
        tags: ["enum", "コンストラクタ", "フィールド"],
        code: """
enum Size {
    SMALL(1), LARGE(3);

    private final int code;

    Size(int code) {
        this.code = code;
    }

    int code() {
        return code;
    }
}

public class Test {
    public static void main(String[] args) {
        System.out.println(Size.LARGE.code());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "3", correct: true, misconception: nil, explanation: "LARGE(3)でenumコンストラクタに3が渡され、codeフィールドに保存されます。"),
            Choice(id: "b", text: "1", correct: false, misconception: "最初の定数SMALLの値を参照すると誤解", explanation: "呼び出しているのはSize.LARGE.code()です。"),
            Choice(id: "c", text: "0", correct: false, misconception: "enumフィールドが初期化されないと誤解", explanation: "各enum定数の生成時にコンストラクタでcodeが初期化されます。"),
            Choice(id: "d", text: "enumにコンストラクタを書けないためコンパイルエラー", correct: false, misconception: "enumを単なる定数リストと誤解", explanation: "enumはフィールド・コンストラクタ・メソッドを持てます。"),
        ],
        explanationRef: "explain-silver-enum-002",
        designIntent: "enum定数がコンストラクタ引数と状態を持てることを確認する。"
    )

    static let silverEnum003 = Quiz(
        id: "silver-enum-003",
        level: .silver,
        category: "classes",
        tags: ["enum", "values", "valueOf"],
        code: """
enum Day {
    MON, TUE
}

public class Test {
    public static void main(String[] args) {
        System.out.print(Day.values().length + " ");
        System.out.println(Day.valueOf("MON") == Day.MON);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2 true", correct: true, misconception: nil, explanation: "values()は2つの定数を返し、valueOf(\"MON\")は既存のDay.MON定数そのものを返します。"),
            Choice(id: "b", text: "2 false", correct: false, misconception: "valueOfが新しいenumインスタンスを作ると誤解", explanation: "enum定数は固定の単一インスタンスなので、==で比較できます。"),
            Choice(id: "c", text: "1 true", correct: false, misconception: "現在参照している定数だけがvaluesに入ると誤解", explanation: "values()は宣言済みの全定数を配列で返します。"),
            Choice(id: "d", text: "IllegalArgumentException", correct: false, misconception: "valueOf(\"MON\")が名前を見つけられないと誤解", explanation: "MONは宣言済みの定数名なので有効です。"),
        ],
        explanationRef: "explain-silver-enum-003",
        designIntent: "enumのvaluesとvalueOf、定数の同一性比較を押さえる。"
    )

    static let goldEnum004 = Quiz(
        id: "gold-enum-004",
        level: .gold,
        category: "classes",
        tags: ["enum", "定数固有クラス本体", "抽象メソッド"],
        code: """
enum Op {
    PLUS {
        int apply(int a, int b) { return a + b; }
    },
    TIMES {
        int apply(int a, int b) { return a * b; }
    };

    abstract int apply(int a, int b);
}

public class Test {
    public static void main(String[] args) {
        System.out.println(Op.PLUS.apply(2, 3) + ":" + Op.TIMES.apply(2, 3));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "5:6", correct: true, misconception: nil, explanation: "PLUSは加算、TIMESは乗算としてそれぞれ定数固有のapplyを実行します。"),
            Choice(id: "b", text: "6:5", correct: false, misconception: "各定数の実装を逆に読んでいる", explanation: "PLUSがa + b、TIMESがa * bです。"),
            Choice(id: "c", text: "5:5", correct: false, misconception: "全定数が同じ実装を共有すると誤解", explanation: "定数ごとに異なるクラス本体を持てます。"),
            Choice(id: "d", text: "enumに抽象メソッドを書けないためコンパイルエラー", correct: false, misconception: "enumのクラス的性質を見落としている", explanation: "全定数が実装するならenumに抽象メソッドを宣言できます。"),
        ],
        explanationRef: "explain-gold-enum-004",
        designIntent: "enum定数固有クラス本体により、定数ごとに振る舞いを変えられることを確認する。"
    )

    static let goldEnum005 = Quiz(
        id: "gold-enum-005",
        level: .gold,
        category: "control-flow",
        tags: ["enum", "switch式", "網羅"],
        code: """
enum Color {
    RED, BLUE
}

public class Test {
    static String label(Color color) {
        return switch (color) {
            case RED -> "R";
            case BLUE -> "B";
        };
    }

    public static void main(String[] args) {
        System.out.println(label(Color.BLUE));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "B", correct: true, misconception: nil, explanation: "Color.BLUEはswitch式のBLUEケースに一致し、\"B\"を返します。"),
            Choice(id: "b", text: "R", correct: false, misconception: "最初のcaseが常に選ばれると誤解", explanation: "switchは値に一致するcaseを選びます。"),
            Choice(id: "c", text: "null", correct: false, misconception: "defaultがないとnullになると誤解", explanation: "enumの全定数をcaseで網羅しているためdefaultなしで値を返せます。"),
            Choice(id: "d", text: "defaultがないためコンパイルエラー", correct: false, misconception: "enum switch式の網羅性を見落としている", explanation: "REDとBLUEをすべて扱っているため、このswitch式は網羅的です。"),
        ],
        explanationRef: "explain-gold-enum-005",
        designIntent: "enumを対象にしたswitch式では全定数を網羅すればdefaultなしで値を返せることを確認する。"
    )

    static let silverObject001 = Quiz(
        id: "silver-object-001",
        level: .silver,
        category: "classes",
        tags: ["Object", "equals", "参照同一性"],
        code: """
public class Test {
    public static void main(String[] args) {
        Object a = new Object();
        Object b = a;
        Object c = new Object();
        System.out.println(a.equals(b) + ":" + a.equals(c));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "true:false", correct: true, misconception: nil, explanation: "Objectのequalsはデフォルトでは参照同一性を比較します。bはaと同じ参照、cは別オブジェクトです。"),
            Choice(id: "b", text: "true:true", correct: false, misconception: "Object同士なら内容が同じとみなされると誤解", explanation: "new Object()には内容比較のオーバーライドがないため、別インスタンスはfalseです。"),
            Choice(id: "c", text: "false:false", correct: false, misconception: "equalsが常にfalseを返すと誤解", explanation: "同じ参照を比較すればtrueです。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "Object変数でequalsを呼べないと誤解", explanation: "equalsはObjectクラスのメソッドなので呼び出せます。"),
        ],
        explanationRef: "explain-silver-object-001",
        designIntent: "Object.equalsのデフォルト実装が参照同一性であることを確認する。"
    )

    static let silverObject002 = Quiz(
        id: "silver-object-002",
        level: .silver,
        category: "classes",
        tags: ["Object", "toString", "getClass"],
        code: """
public class Test {
    public static void main(String[] args) {
        Object value = "Java";
        System.out.println(value.getClass().getSimpleName() + ":" + value.toString());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "String:Java", correct: true, misconception: nil, explanation: "変数型はObjectでも実体はStringです。getClass()は実行時クラス、toString()はStringの実装が呼ばれます。"),
            Choice(id: "b", text: "Object:Java", correct: false, misconception: "getClassが変数の宣言型を返すと誤解", explanation: "getClass()は実行時の実体クラスを返します。"),
            Choice(id: "c", text: "String:java.lang.String", correct: false, misconception: "String.toStringがクラス名を返すと誤解", explanation: "StringのtoString()は文字列自身を返します。"),
            Choice(id: "d", text: "ClassCastException", correct: false, misconception: "Object型に入れたStringを戻せないと誤解", explanation: "キャストは行っておらず、Objectのメソッドを呼んでいるだけです。"),
        ],
        explanationRef: "explain-silver-object-002",
        designIntent: "Object参照でも実体クラスのメソッド実装が使われることを、getClassとtoStringで追わせる。"
    )

    static let goldObject003 = Quiz(
        id: "gold-object-003",
        level: .gold,
        category: "classes",
        tags: ["Object", "equals", "hashCode", "HashSet"],
        code: """
import java.util.*;

class Key {
    private final int id;

    Key(int id) {
        this.id = id;
    }

    public boolean equals(Object obj) {
        return obj instanceof Key other && other.id == id;
    }

    public int hashCode() {
        return id;
    }
}

public class Test {
    public static void main(String[] args) {
        Set<Key> set = new HashSet<>();
        set.add(new Key(1));
        set.add(new Key(1));
        System.out.println(set.size());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1", correct: true, misconception: nil, explanation: "equalsとhashCodeがidベースで一致するため、HashSetは2つのKey(1)を同値として扱います。"),
            Choice(id: "b", text: "2", correct: false, misconception: "newしたオブジェクトは常に別要素になると誤解", explanation: "HashSetはequals/hashCodeの契約に基づいて重複判定します。"),
            Choice(id: "c", text: "0", correct: false, misconception: "重複判定で両方消えると誤解", explanation: "1つ目は保持され、2つ目の追加だけが重複として無視されます。"),
            Choice(id: "d", text: "ClassCastException", correct: false, misconception: "instanceofパターンがキャスト例外を投げると誤解", explanation: "instanceofは型が合わなければfalseになるだけです。"),
        ],
        explanationRef: "explain-gold-object-003",
        designIntent: "Object.equals/hashCodeを正しくオーバーライドすると、コレクションの重複判定が値ベースになることを確認する。"
    )

    static let goldObject004 = Quiz(
        id: "gold-object-004",
        level: .gold,
        category: "classes",
        tags: ["Object", "equals", "オーバーロード"],
        code: """
class Key {
    private final int id;

    Key(int id) {
        this.id = id;
    }

    public boolean equals(Key other) {
        return other != null && other.id == id;
    }
}

public class Test {
    public static void main(String[] args) {
        Object a = new Key(1);
        Object b = new Key(1);
        System.out.println(a.equals(b));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "true", correct: false, misconception: "equals(Key)がObject.equalsをオーバーライドしていると誤解", explanation: "equals(Key)はオーバーロードであり、equals(Object)のオーバーライドではありません。"),
            Choice(id: "b", text: "false", correct: true, misconception: nil, explanation: "aの宣言型はObjectなのでequals(Object)が呼び出し対象です。Keyはequals(Object)をオーバーライドしていないため参照比較になります。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "Object変数同士でequalsを呼べないと誤解", explanation: "Objectにはequals(Object)が定義されています。"),
            Choice(id: "d", text: "NullPointerException", correct: false, misconception: "otherがnullになると誤解", explanation: "bはKeyインスタンスを参照しています。そもそもこの呼び出しではequals(Key)は使われません。"),
        ],
        explanationRef: "explain-gold-object-004",
        designIntent: "equals(Object)を正しくオーバーライドせずequals(Key)を追加してしまう典型的な落とし穴を確認する。"
    )

    // MARK: - Gold: Annotations / Exceptions Batch

    static let goldAnnotations003 = Quiz(
        id: "gold-annotations-003",
        level: .gold,
        category: "annotations",
        tags: ["@FunctionalInterface", "defaultメソッド", "staticメソッド"],
        code: """
@FunctionalInterface
interface Task {
    void run();
    default void log() {}
    static Task of(Task task) {
        return task;
    }
}

public class Test {
    public static void main(String[] args) {
        Task task = Task.of(() -> System.out.print("R"));
        task.run();
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "R", correct: true, misconception: nil, explanation: "抽象メソッドはrun()だけです。default/staticメソッドは関数型インターフェースの抽象メソッド数に数えません。"),
            Choice(id: "b", text: "コンパイルエラー", correct: false, misconception: "default/staticメソッドも抽象メソッド数に数えると誤解", explanation: "@FunctionalInterfaceは抽象メソッドが1つなら有効です。"),
            Choice(id: "c", text: "何も出力されない", correct: false, misconception: "ラムダが実行されないと誤解", explanation: "task.run()でラムダ本体が実行されます。"),
            Choice(id: "d", text: "RuntimeException", correct: false, misconception: "Task.ofが例外を投げると誤解", explanation: "Task.ofは受け取ったtaskをそのまま返すだけです。"),
        ],
        explanationRef: "explain-gold-annotations-003",
        designIntent: "@FunctionalInterfaceの抽象メソッド数判定で、default/staticメソッドを除外することを確認する。"
    )

    static let goldAnnotations004 = Quiz(
        id: "gold-annotations-004",
        level: .gold,
        category: "annotations",
        tags: ["@FunctionalInterface", "抽象メソッド", "コンパイルエラー"],
        code: """
@FunctionalInterface
interface Parser {
    String parse(String text);
    int size();
}

public class Test {}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる", correct: false, misconception: "戻り値が違えば1つの関数型として扱えると誤解", explanation: "parseとsizeはどちらも抽象メソッドです。"),
            Choice(id: "b", text: "@FunctionalInterfaceの付いたParserでコンパイルエラー", correct: true, misconception: nil, explanation: "抽象メソッドが2つあるため、関数型インターフェースではありません。"),
            Choice(id: "c", text: "size()だけがdefault扱いになる", correct: false, misconception: "実装がないメソッドが自動的にdefaultになると誤解", explanation: "defaultを明示しないメソッドは抽象メソッドです。"),
            Choice(id: "d", text: "実行時にIllegalStateException", correct: false, misconception: "アノテーション検査が実行時まで遅れると誤解", explanation: "@FunctionalInterfaceの不一致はコンパイル時に検出されます。"),
        ],
        explanationRef: "explain-gold-annotations-004",
        designIntent: "@FunctionalInterfaceが抽象メソッド2つのインターフェースをコンパイル時に拒否することを確認する。"
    )

    static let goldAnnotations005 = Quiz(
        id: "gold-annotations-005",
        level: .gold,
        category: "annotations",
        tags: ["@Deprecated", "組み込みアノテーション", "警告"],
        code: """
class Api {
    @Deprecated
    static String oldName() {
        return "old";
    }
}

public class Test {
    public static void main(String[] args) {
        System.out.println(Api.oldName());
    }
}
""",
        question: "このコードを実行したとき、結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "oldと出力される", correct: true, misconception: nil, explanation: "@Deprecatedは使用時に警告を出すためのメタデータで、メソッド呼び出し自体を禁止しません。"),
            Choice(id: "b", text: "コンパイルエラー", correct: false, misconception: "非推奨APIは使用不可になると誤解", explanation: "通常は警告であり、コンパイルは可能です。"),
            Choice(id: "c", text: "実行時にDeprecatedException", correct: false, misconception: "@Deprecatedが実行時例外を投げると誤解", explanation: "Java標準にDeprecatedExceptionという挙動はありません。"),
            Choice(id: "d", text: "nullと出力される", correct: false, misconception: "非推奨メソッドの戻り値が無効になると誤解", explanation: "メソッド本体は通常通り実行され、oldを返します。"),
        ],
        explanationRef: "explain-gold-annotations-005",
        designIntent: "@Deprecatedはコンパイル警告用であり、実行結果を変えないことを確認する。"
    )

    static let goldAnnotations006 = Quiz(
        id: "gold-annotations-006",
        level: .gold,
        category: "annotations",
        tags: ["カスタムアノテーション", "Retention", "Reflection"],
        code: """
@interface Info {
    String value();
}

@Info("service")
class Service {}

public class Test {
    public static void main(String[] args) {
        System.out.println(Service.class.isAnnotationPresent(Info.class));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "true", correct: false, misconception: "全アノテーションが実行時に反射で読めると誤解", explanation: "Retentionを指定しない場合、実行時反射では取得できません。"),
            Choice(id: "b", text: "false", correct: true, misconception: nil, explanation: "デフォルトのRetentionPolicyはCLASSです。RUNTIMEを指定していないため、isAnnotationPresentはfalseになります。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "カスタムアノテーションにはRetentionが必須と誤解", explanation: "Retention指定は任意です。省略時はCLASSです。"),
            Choice(id: "d", text: "NullPointerException", correct: false, misconception: "Info.classがnullになると誤解", explanation: "クラスリテラルはnullではありません。反射で見えないだけです。"),
        ],
        explanationRef: "explain-gold-annotations-006",
        designIntent: "カスタムアノテーションのデフォルトRetentionがCLASSであり、実行時反射には残らないことを確認する。"
    )

    static let goldAnnotations007 = Quiz(
        id: "gold-annotations-007",
        level: .gold,
        category: "annotations",
        tags: ["@Retention", "RetentionPolicy.RUNTIME", "Reflection"],
        code: """
import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)
@interface Info {
    String value();
    int version() default 1;
}

@Info(value = "service", version = 2)
class Service {}

public class Test {
    public static void main(String[] args) {
        Info info = Service.class.getAnnotation(Info.class);
        System.out.println(info.value() + ":" + info.version());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "service:2", correct: true, misconception: nil, explanation: "RUNTIME保持なので反射でInfoを取得でき、指定したvalueとversionを読めます。"),
            Choice(id: "b", text: "service:1", correct: false, misconception: "明示指定したversionが無視されると誤解", explanation: "version = 2を指定しているため、デフォルト値1ではありません。"),
            Choice(id: "c", text: "NullPointerException", correct: false, misconception: "getAnnotationがnullを返すと誤解", explanation: "RUNTIME保持のため、Infoは実行時に取得できます。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "アノテーションにdefault要素を書けないと誤解", explanation: "アノテーション要素にはdefault値を指定できます。"),
        ],
        explanationRef: "explain-gold-annotations-007",
        designIntent: "@Retention(RUNTIME)を付けたカスタムアノテーションを反射で取得し、要素値を読む流れを確認する。"
    )

    static let goldAnnotations008 = Quiz(
        id: "gold-annotations-008",
        level: .gold,
        category: "annotations",
        tags: ["@Target", "ElementType", "コンパイルエラー"],
        code: """
import java.lang.annotation.*;

@Target(ElementType.METHOD)
@interface Run {}

@Run
class Job {}

public class Test {}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる", correct: false, misconception: "@Targetはドキュメント用途だけだと誤解", explanation: "@Targetはアノテーションを付けられる場所をコンパイラに制限させます。"),
            Choice(id: "b", text: "@Runをclass Jobに付けている行でコンパイルエラー", correct: true, misconception: nil, explanation: "@RunはMETHOD専用です。クラス宣言には付けられません。"),
            Choice(id: "c", text: "@interface Run {} の宣言でコンパイルエラー", correct: false, misconception: "空のアノテーションを宣言できないと誤解", explanation: "要素を持たないマーカーアノテーションは有効です。"),
            Choice(id: "d", text: "実行時にAnnotationFormatError", correct: false, misconception: "Target違反が実行時まで遅れると誤解", explanation: "不正な付与位置はコンパイル時に検出されます。"),
        ],
        explanationRef: "explain-gold-annotations-008",
        designIntent: "@Targetがカスタムアノテーションの使用可能位置を制限することを確認する。"
    )

    static let goldAnnotations009 = Quiz(
        id: "gold-annotations-009",
        level: .gold,
        category: "annotations",
        tags: ["メタアノテーション", "ANNOTATION_TYPE", "@Target"],
        code: """
import java.lang.annotation.*;

@Target(ElementType.ANNOTATION_TYPE)
@interface Role {}

@Role
@interface Secured {}

@Role
class Service {}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる", correct: false, misconception: "ANNOTATION_TYPEが通常クラスも含むと誤解", explanation: "ANNOTATION_TYPEはアノテーション型宣言にだけ付けられるという意味です。"),
            Choice(id: "b", text: "@Roleを@interface Securedに付けた行でコンパイルエラー", correct: false, misconception: "アノテーションにアノテーションを付けられないと誤解", explanation: "RoleはANNOTATION_TYPE対象なので、Securedへの付与は有効です。"),
            Choice(id: "c", text: "@Roleをclass Serviceに付けた行でコンパイルエラー", correct: true, misconception: nil, explanation: "Roleはアノテーション型専用です。通常クラスServiceには付けられません。"),
            Choice(id: "d", text: "実行時にfalseが出力される", correct: false, misconception: "コンパイルエラーのコードが実行されると誤解", explanation: "このコードには出力処理もなく、Target違反でコンパイルできません。"),
        ],
        explanationRef: "explain-gold-annotations-009",
        designIntent: "アノテーションをアノテートするメタアノテーションと、ElementType.ANNOTATION_TYPEの意味を確認する。"
    )

    static let goldAnnotations010 = Quiz(
        id: "gold-annotations-010",
        level: .gold,
        category: "annotations",
        tags: ["@Inherited", "RetentionPolicy.RUNTIME", "Reflection"],
        code: """
import java.lang.annotation.*;

@Inherited
@Retention(RetentionPolicy.RUNTIME)
@interface Mark {}

@Mark
class Parent {}

class Child extends Parent {}

public class Test {
    public static void main(String[] args) {
        System.out.println(Child.class.isAnnotationPresent(Mark.class));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "true", correct: true, misconception: nil, explanation: "@Inheritedが付いたクラスアノテーションは、サブクラス側の反射取得でも継承されたものとして見えます。"),
            Choice(id: "b", text: "false", correct: false, misconception: "アノテーションは絶対に継承されないと誤解", explanation: "@InheritedとRUNTIME保持があるため、Childからも見えます。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "@Inheritedをカスタムアノテーションに付けられないと誤解", explanation: "@Inheritedはアノテーション型に付けるメタアノテーションです。"),
            Choice(id: "d", text: "NullPointerException", correct: false, misconception: "Child.classがnullになると誤解", explanation: "クラスリテラルは常にClassオブジェクトを表します。"),
        ],
        explanationRef: "explain-gold-annotations-010",
        designIntent: "@Inheritedがクラスアノテーションをサブクラス反射から見えるようにすることを確認する。"
    )

    static let goldAnnotations011 = Quiz(
        id: "gold-annotations-011",
        level: .gold,
        category: "annotations",
        tags: ["@Repeatable", "コンテナアノテーション", "Reflection"],
        code: """
import java.lang.annotation.*;

@Repeatable(Tags.class)
@Retention(RetentionPolicy.RUNTIME)
@interface Tag {
    String value();
}

@Retention(RetentionPolicy.RUNTIME)
@interface Tags {
    Tag[] value();
}

@Tag("A")
@Tag("B")
class Service {}

public class Test {
    public static void main(String[] args) {
        System.out.println(Service.class.getAnnotationsByType(Tag.class).length);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1", correct: false, misconception: "同じアノテーションは1つにまとめられて数えられると誤解", explanation: "getAnnotationsByType(Tag.class)は繰り返し付与されたTagを展開して返します。"),
            Choice(id: "b", text: "2", correct: true, misconception: nil, explanation: "@RepeatableとコンテナTagsにより、Tagを2回付けられ、反射でも2件取得できます。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "同じアノテーションを複数回付けられないと誤解", explanation: "@Repeatableを正しく宣言しているため有効です。"),
            Choice(id: "d", text: "0", correct: false, misconception: "RUNTIME保持がないと誤解", explanation: "TagとTagsの両方にRUNTIME保持があります。"),
        ],
        explanationRef: "explain-gold-annotations-011",
        designIntent: "@Repeatableのコンテナアノテーションと、getAnnotationsByTypeでの展開取得を確認する。"
    )

    static let goldAnnotations012 = Quiz(
        id: "gold-annotations-012",
        level: .gold,
        category: "annotations",
        tags: ["カスタムアノテーション", "value要素", "省略記法"],
        code: """
@interface Label {
    String name();
}

@Label("service")
class Service {}

public class Test {}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる", correct: false, misconception: "どの要素名でも単一値なら省略できると誤解", explanation: "省略記法 `@X(\"...\")` が使えるのは要素名がvalueの場合です。"),
            Choice(id: "b", text: "@Label(\"service\")でコンパイルエラー", correct: true, misconception: nil, explanation: "Labelの必須要素はnameです。`@Label(name = \"service\")` と書く必要があります。"),
            Choice(id: "c", text: "nameには空文字が入る", correct: false, misconception: "未指定要素に自動デフォルトが入ると誤解", explanation: "defaultを指定していない要素は必須です。"),
            Choice(id: "d", text: "実行時にAnnotationTypeMismatchException", correct: false, misconception: "要素名間違いが実行時まで遅れると誤解", explanation: "この構文エラーはコンパイル時に検出されます。"),
        ],
        explanationRef: "explain-gold-annotations-012",
        designIntent: "単一要素アノテーションの省略記法はvalue要素にだけ使えることを確認する。"
    )

    static let goldException007 = Quiz(
        id: "gold-exception-007",
        level: .gold,
        category: "exception-handling",
        tags: ["multi-catch", "IOException", "到達不能"],
        code: """
import java.io.*;

public class Test {
    public static void main(String[] args) {
        try {
            throw new FileNotFoundException();
        } catch (IOException | FileNotFoundException e) {
            System.out.println("caught");
        }
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "caughtと出力される", correct: false, misconception: "multi-catchなら親子型を並べてもよいと誤解", explanation: "IOExceptionはFileNotFoundExceptionの親型なので、同じmulti-catchに並べられません。"),
            Choice(id: "b", text: "catch (IOException | FileNotFoundException e)でコンパイルエラー", correct: true, misconception: nil, explanation: "multi-catchの代替型同士にサブタイプ関係があるとコンパイルエラーです。"),
            Choice(id: "c", text: "throw new FileNotFoundException();でコンパイルエラー", correct: false, misconception: "catchしていてもチェック例外をthrowできないと誤解", explanation: "問題はthrowではなく、multi-catchの型の組み合わせです。"),
            Choice(id: "d", text: "実行時にFileNotFoundExceptionで異常終了", correct: false, misconception: "コンパイルエラーを見落としている", explanation: "このコードは実行前にコンパイルで止まります。"),
        ],
        explanationRef: "explain-gold-exception-007",
        designIntent: "multi-catchでは親子関係にある例外型を同時に並べられないことを確認する。"
    )

    static let goldException008 = Quiz(
        id: "gold-exception-008",
        level: .gold,
        category: "exception-handling",
        tags: ["try-with-resources", "suppressed", "AutoCloseable"],
        code: """
class R implements AutoCloseable {
    public void close() {
        throw new RuntimeException("close");
    }
}

public class Test {
    public static void main(String[] args) {
        try (R r = new R()) {
            throw new RuntimeException("body");
        } catch (RuntimeException e) {
            System.out.println(e.getMessage() + ":" + e.getSuppressed()[0].getMessage());
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "body:close", correct: true, misconception: nil, explanation: "try本体の例外が主例外になり、close中の例外はsuppressedとして追加されます。"),
            Choice(id: "b", text: "close:body", correct: false, misconception: "close例外が主例外になると誤解", explanation: "try本体ですでに例外がある場合、closeの例外は抑制例外になります。"),
            Choice(id: "c", text: "bodyだけ出力される", correct: false, misconception: "close例外が消えると誤解", explanation: "close例外はgetSuppressed()から取得できます。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "AutoCloseable.closeは必ずthrows Exceptionを書く必要があると誤解", explanation: "closeはthrowsを狭めて、宣言なしにできます。"),
        ],
        explanationRef: "explain-gold-exception-008",
        designIntent: "try-with-resourcesで本体例外とclose例外が同時に起きたとき、close例外がsuppressedになることを確認する。"
    )

    static let goldException009 = Quiz(
        id: "gold-exception-009",
        level: .gold,
        category: "exception-handling",
        tags: ["try-with-resources", "close順序", "suppressed"],
        code: """
class R implements AutoCloseable {
    private final String name;
    R(String name) { this.name = name; }
    public void close() {
        throw new RuntimeException(name);
    }
}

public class Test {
    public static void main(String[] args) {
        try (R a = new R("A"); R b = new R("B")) {
            throw new RuntimeException("T");
        } catch (RuntimeException e) {
            System.out.println(e.getMessage() + ":" +
                e.getSuppressed()[0].getMessage() +
                e.getSuppressed()[1].getMessage());
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "T:AB", correct: false, misconception: "リソースが宣言順にcloseされると誤解", explanation: "try-with-resourcesは宣言と逆順にcloseします。"),
            Choice(id: "b", text: "T:BA", correct: true, misconception: nil, explanation: "主例外はTで、closeはb、aの順に実行されるためsuppressedはB、Aの順です。"),
            Choice(id: "c", text: "B:A", correct: false, misconception: "close例外が主例外になると誤解", explanation: "try本体のTが主例外です。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "複数リソースを宣言できないと誤解", explanation: "try-with-resourcesではセミコロン区切りで複数リソースを宣言できます。"),
        ],
        explanationRef: "explain-gold-exception-009",
        designIntent: "複数リソースのclose順序と、suppressed例外の並びを確認する。"
    )

    static let goldException010 = Quiz(
        id: "gold-exception-010",
        level: .gold,
        category: "exception-handling",
        tags: ["finally", "throw", "例外上書き"],
        code: """
public class Test {
    static void run() {
        try {
            throw new RuntimeException("try");
        } finally {
            throw new RuntimeException("finally");
        }
    }

    public static void main(String[] args) {
        try {
            run();
        } catch (RuntimeException e) {
            System.out.println(e.getMessage());
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "try", correct: false, misconception: "try側の例外が常に優先されると誤解", explanation: "finallyがthrowで突然完了すると、try側の例外は上書きされます。"),
            Choice(id: "b", text: "finally", correct: true, misconception: nil, explanation: "tryでtry例外が発生した後、finallyがさらにfinally例外を投げるため、呼び出し元に届くのはfinallyです。"),
            Choice(id: "c", text: "try finally", correct: false, misconception: "2つの例外メッセージが連結されると誤解", explanation: "catchで受け取る主例外は1つです。この場合はfinally側です。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "try/finally両方でthrowできないと誤解", explanation: "unchecked例外なので構文としては有効です。"),
        ],
        explanationRef: "explain-gold-exception-010",
        designIntent: "finally内のthrowがtry側の例外を上書きする危険な挙動を確認する。"
    )

    static let goldException011 = Quiz(
        id: "gold-exception-011",
        level: .gold,
        category: "exception-handling",
        tags: ["precise rethrow", "checked exception", "throws"],
        code: """
import java.io.*;

public class Test {
    static void read() throws IOException {
        throw new IOException();
    }

    static void run() throws IOException {
        try {
            read();
        } catch (Exception e) {
            throw e;
        }
    }

    public static void main(String[] args) {
        try {
            run();
        } catch (IOException e) {
            System.out.println("IO");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "IO", correct: true, misconception: nil, explanation: "catch型はExceptionですが、try内で投げ得る検査例外はIOExceptionだけで、eを再代入していないためprecise rethrowが働きます。"),
            Choice(id: "b", text: "コンパイルエラー", correct: false, misconception: "catch(Exception)からthrow eすると必ずthrows Exceptionが必要と誤解", explanation: "Java 7以降のprecise rethrowにより、このケースではthrows IOExceptionで足ります。"),
            Choice(id: "c", text: "Exception", correct: false, misconception: "catch型の名前が出力されると誤解", explanation: "catch(IOException)でIOを出力しています。"),
            Choice(id: "d", text: "何も出力されない", correct: false, misconception: "readの例外が握りつぶされると誤解", explanation: "catch内でthrow eしているため、run呼び出し元へ再送出されます。"),
        ],
        explanationRef: "explain-gold-exception-011",
        designIntent: "precise rethrowにより、catch(Exception)でも実際に投げ得る検査例外型へ狭められることを確認する。"
    )

    static let goldException012 = Quiz(
        id: "gold-exception-012",
        level: .gold,
        category: "exception-handling",
        tags: ["precise rethrow", "catchパラメータ", "再代入"],
        code: """
import java.io.*;

public class Test {
    static void read() throws IOException {
        throw new IOException();
    }

    static void run() throws IOException {
        try {
            read();
        } catch (Exception e) {
            e = new Exception();
            throw e;
        }
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる", correct: false, misconception: "再代入してもprecise rethrowが働くと誤解", explanation: "catchパラメータを再代入すると、正確な再スロー解析の対象外になります。"),
            Choice(id: "b", text: "throw e; でコンパイルエラー", correct: true, misconception: nil, explanation: "eはExceptionとして扱われます。runはthrows IOExceptionだけなので、より広いExceptionを投げられません。"),
            Choice(id: "c", text: "e = new Exception(); でコンパイルエラー", correct: false, misconception: "catchパラメータは常にfinalだと誤解", explanation: "単一catchのパラメータ自体は再代入できます。問題はその後のthrowです。"),
            Choice(id: "d", text: "実行時にIOExceptionが出力される", correct: false, misconception: "コンパイルエラーを見落としている", explanation: "このコードは実行前にコンパイルで止まります。"),
        ],
        explanationRef: "explain-gold-exception-012",
        designIntent: "catchパラメータを再代入するとprecise rethrowによる型の絞り込みが効かなくなることを確認する。"
    )

    static let goldException013 = Quiz(
        id: "gold-exception-013",
        level: .gold,
        category: "exception-handling",
        tags: ["try-with-resources", "effectively final", "Java 9"],
        code: """
class R implements AutoCloseable {
    public void close() {
        System.out.print("C");
    }
}

public class Test {
    public static void main(String[] args) {
        R r = new R();
        try (r) {
            System.out.print("T");
        }
    }
}
""",
        question: "Java 17でこのコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "TC", correct: true, misconception: nil, explanation: "Java 9以降、effectively finalな既存変数をtry-with-resourcesに書けます。本体Tの後にcloseでCです。"),
            Choice(id: "b", text: "CT", correct: false, misconception: "closeがtry本体前に走ると誤解", explanation: "closeはtryブロック終了時に実行されます。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "try-with-resourcesには必ず新規変数宣言が必要と誤解", explanation: "Java 9以降はeffectively finalな既存変数も使えます。"),
            Choice(id: "d", text: "T", correct: false, misconception: "既存変数を使うと自動closeされないと誤解", explanation: "try-with-resourcesに指定したため、終了時にcloseされます。"),
        ],
        explanationRef: "explain-gold-exception-013",
        designIntent: "Java 9以降のtry-with-resourcesでeffectively finalな既存変数を使えることとclose順を確認する。"
    )

    static let goldException014 = Quiz(
        id: "gold-exception-014",
        level: .gold,
        category: "exception-handling",
        tags: ["static初期化", "ExceptionInInitializerError", "Throwable"],
        code: """
class Bad {
    static int value = init();

    static int init() {
        throw new RuntimeException("boom");
    }
}

public class Test {
    public static void main(String[] args) {
        try {
            System.out.println(Bad.value);
        } catch (Throwable e) {
            System.out.println(e.getClass().getSimpleName());
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "RuntimeException", correct: false, misconception: "static初期化中の例外がそのまま届くと誤解", explanation: "クラス初期化中の例外はExceptionInInitializerErrorにラップされます。"),
            Choice(id: "b", text: "ExceptionInInitializerError", correct: true, misconception: nil, explanation: "Bad.valueの初回アクセスでクラス初期化が走り、init()のRuntimeExceptionがExceptionInInitializerErrorとして送出されます。"),
            Choice(id: "c", text: "0", correct: false, misconception: "初期化失敗時にデフォルト値が使われると誤解", explanation: "初期化失敗で値は出力されず、例外が送出されます。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "staticフィールド初期化でメソッドを呼べないと誤解", explanation: "メソッド呼び出しは可能です。実行時のクラス初期化で例外になります。"),
        ],
        explanationRef: "explain-gold-exception-014",
        designIntent: "static初期化中のRuntimeExceptionがExceptionInInitializerErrorとして見えることを確認する。"
    )

    static let goldException015 = Quiz(
        id: "gold-exception-015",
        level: .gold,
        category: "exception-handling",
        tags: ["NumberFormatException", "IllegalArgumentException", "複数catch"],
        code: """
public class Test {
    public static void main(String[] args) {
        try {
            Integer.parseInt("12x");
        } catch (NumberFormatException e) {
            System.out.println("NFE");
        } catch (IllegalArgumentException e) {
            System.out.println("IAE");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "NFE", correct: true, misconception: nil, explanation: "parseIntの失敗でNumberFormatExceptionが発生し、最初のcatchに一致します。"),
            Choice(id: "b", text: "IAE", correct: false, misconception: "親型catchが常に優先されると誤解", explanation: "catchは上から順に判定されます。先にNumberFormatExceptionがあるため、そこで捕捉されます。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "親型catchを後ろに置けないと誤解", explanation: "サブクラスを先、親クラスを後ろに置く順序は有効です。"),
            Choice(id: "d", text: "NumberFormatExceptionで異常終了", correct: false, misconception: "catchされないと誤解", explanation: "NumberFormatException用のcatchがあるため捕捉されます。"),
        ],
        explanationRef: "explain-gold-exception-015",
        designIntent: "NumberFormatExceptionがIllegalArgumentExceptionのサブクラスであり、複数catchは上から順に一致することを確認する。"
    )

    static let goldException016 = Quiz(
        id: "gold-exception-016",
        level: .gold,
        category: "exception-handling",
        tags: ["NullPointerException", "try-catch-finally", "実行順序"],
        code: """
public class Test {
    public static void main(String[] args) {
        try {
            String s = null;
            System.out.print(s.length());
        } catch (NullPointerException e) {
            System.out.print("NPE");
        } finally {
            System.out.print("F");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "NPEF", correct: true, misconception: nil, explanation: "null参照でNullPointerExceptionが発生し、catch後にfinallyが必ず実行されます。"),
            Choice(id: "b", text: "F", correct: false, misconception: "catchが実行されないと誤解", explanation: "NullPointerExceptionに一致するcatchがあります。"),
            Choice(id: "c", text: "NPE", correct: false, misconception: "catch後はfinallyが省略されると誤解", explanation: "finallyはcatchの後にも実行されます。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "null変数の宣言がコンパイルエラーと誤解", explanation: "参照型変数にnullを代入すること自体は有効です。"),
        ],
        explanationRef: "explain-gold-exception-016",
        designIntent: "NullPointerExceptionの発生、catch、finallyの実行順序を出力で追わせる。"
    )

    static let goldException017 = Quiz(
        id: "gold-exception-017",
        level: .gold,
        category: "exception-handling",
        tags: ["ArrayIndexOutOfBoundsException", "IndexOutOfBoundsException", "例外クラス"],
        code: """
public class Test {
    public static void main(String[] args) {
        try {
            int[] values = {1};
            System.out.print(values[1]);
        } catch (IndexOutOfBoundsException e) {
            System.out.println(e.getClass().getSimpleName());
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "IndexOutOfBoundsException", correct: false, misconception: "catch型がそのまま実体クラスになると誤解", explanation: "catch変数の実体は発生した具体例外です。"),
            Choice(id: "b", text: "ArrayIndexOutOfBoundsException", correct: true, misconception: nil, explanation: "配列の範囲外アクセスではArrayIndexOutOfBoundsExceptionが発生し、親型IndexOutOfBoundsExceptionで捕捉できます。"),
            Choice(id: "c", text: "NullPointerException", correct: false, misconception: "配列参照がnullだと誤解", explanation: "valuesは実体配列を参照しています。範囲外アクセスです。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "範囲外添字がコンパイル時に検出されると誤解", explanation: "配列添字の範囲は実行時にチェックされます。"),
        ],
        explanationRef: "explain-gold-exception-017",
        designIntent: "主要例外クラスの継承関係と、catchされた例外の実体クラスを確認する。"
    )

    static let goldException018 = Quiz(
        id: "gold-exception-018",
        level: .gold,
        category: "exception-handling",
        tags: ["throws", "throw", "IOException"],
        code: """
import java.io.*;

public class Test {
    static void run() throws IOException {
        new IOException("created");
    }

    public static void main(String[] args) throws IOException {
        run();
        System.out.println("OK");
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "OK", correct: true, misconception: nil, explanation: "IOExceptionオブジェクトを生成しているだけで、throwしていません。throws宣言だけでも例外は発生しません。"),
            Choice(id: "b", text: "IOExceptionがスローされる", correct: false, misconception: "newした例外は自動的にthrowされると誤解", explanation: "例外を送出するには `throw` が必要です。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "throws宣言があるメソッドは必ずthrowしなければならないと誤解", explanation: "throwsは投げる可能性の宣言であり、必ず投げる義務ではありません。"),
            Choice(id: "d", text: "created", correct: false, misconception: "例外メッセージが自動出力されると誤解", explanation: "例外をthrowしていないためメッセージも出力されません。"),
        ],
        explanationRef: "explain-gold-exception-018",
        designIntent: "throwsは宣言、throwは送出であり、例外オブジェクト生成だけでは例外処理が始まらないことを確認する。"
    )

    static let goldException019 = Quiz(
        id: "gold-exception-019",
        level: .gold,
        category: "exception-handling",
        tags: ["throw", "null", "NullPointerException"],
        code: """
public class Test {
    static void run() {
        throw null;
    }

    public static void main(String[] args) {
        try {
            run();
        } catch (NullPointerException e) {
            System.out.println("NPE");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "NPE", correct: true, misconception: nil, explanation: "`throw null;` は実行時にNullPointerExceptionを発生させます。"),
            Choice(id: "b", text: "コンパイルエラー", correct: false, misconception: "throw nullが文法的に禁止だと誤解", explanation: "nullはThrowable参照として型チェックを通りますが、実行時にNPEになります。"),
            Choice(id: "c", text: "何も出力されない", correct: false, misconception: "throw nullが無視されると誤解", explanation: "例外送出処理として評価され、NPEがcatchされます。"),
            Choice(id: "d", text: "RuntimeException", correct: false, misconception: "throw nullがRuntimeExceptionに変換されると誤解", explanation: "発生する具体例外はNullPointerExceptionです。"),
        ],
        explanationRef: "explain-gold-exception-019",
        designIntent: "throw式にnullを指定した場合、実行時にNullPointerExceptionが発生することを確認する。"
    )

    static let goldException020 = Quiz(
        id: "gold-exception-020",
        level: .gold,
        category: "exception-handling",
        tags: ["複数catch", "到達不能", "RuntimeException"],
        code: """
public class Test {
    public static void main(String[] args) {
        try {
            String s = null;
            s.length();
        } catch (RuntimeException e) {
            System.out.println("R");
        } catch (NullPointerException e) {
            System.out.println("N");
        }
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "Rと出力される", correct: false, misconception: "実行時の捕捉だけを見てコンパイル規則を見落としている", explanation: "後続のNullPointerException catchが到達不能なのでコンパイルできません。"),
            Choice(id: "b", text: "Nと出力される", correct: false, misconception: "より具体的なcatchが後ろでも優先されると誤解", explanation: "catchは上から順です。ただしこの並びはコンパイル時点で拒否されます。"),
            Choice(id: "c", text: "catch (NullPointerException e)でコンパイルエラー", correct: true, misconception: nil, explanation: "NullPointerExceptionはRuntimeExceptionのサブクラスなので、先のcatch(RuntimeException)で捕捉済みとなり到達不能です。"),
            Choice(id: "d", text: "NullPointerExceptionで異常終了", correct: false, misconception: "catchが存在しないと誤解", explanation: "catch以前に、catch順序の問題でコンパイルエラーです。"),
        ],
        explanationRef: "explain-gold-exception-020",
        designIntent: "複数catchブロックはサブクラスを先、親クラスを後に置かないと到達不能になることを確認する。"
    )

    // MARK: - Gold: Secure Coding

    static let goldSecureCoding001 = Quiz(
        id: "gold-secure-coding-001",
        level: .gold,
        category: "secure-coding",
        tags: ["try-with-resources", "final", "FIO"],
        code: """
class R implements AutoCloseable {
    public void close() {
        System.out.print("C");
    }
}

public class Test {
    public static void main(String[] args) {
        try (final R r = new R()) {
            System.out.print("T");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "TC", correct: true, misconception: nil, explanation: "try-with-resources内のリソース変数は明示的にfinalにできます。本体Tの後、closeでCが出ます。"),
            Choice(id: "b", text: "CT", correct: false, misconception: "closeがtry本体前に実行されると誤解", explanation: "closeはtryブロックを抜けるときに実行されます。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "try内のリソース変数にfinalを付けられないと誤解", explanation: "リソース宣言にfinal修飾子を付けることは可能です。"),
            Choice(id: "d", text: "T", correct: false, misconception: "明示finalにするとcloseされないと誤解", explanation: "finalかどうかに関係なく、try-with-resourcesに指定したリソースは自動closeされます。"),
        ],
        explanationRef: "explain-gold-secure-coding-001",
        designIntent: "try-with-resources内で明示的にfinalなリソース変数を宣言でき、自動closeされることを確認する。"
    )

    static let goldSecureCoding002 = Quiz(
        id: "gold-secure-coding-002",
        level: .gold,
        category: "secure-coding",
        tags: ["try-with-resources", "effectively final", "Java 9"],
        code: """
class R implements AutoCloseable {
    public void close() {
        System.out.print("C");
    }
}

public class Test {
    public static void main(String[] args) {
        final R r = new R();
        try (r) {
            System.out.print("T");
        }
    }
}
""",
        question: "Java 17でこのコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "TC", correct: true, misconception: nil, explanation: "Java 9以降、finalまたは実質finalな既存変数をtry-with-resourcesに指定できます。"),
            Choice(id: "b", text: "T", correct: false, misconception: "既存変数は自動closeされないと誤解", explanation: "try (r) に指定しているため、ブロック終了時にcloseされます。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "try-with-resourcesには必ず新規宣言が必要と誤解", explanation: "Java 9以降は既存のfinalまたは実質final変数も使えます。"),
            Choice(id: "d", text: "CT", correct: false, misconception: "close順を逆に読んでいる", explanation: "まずtry本体、その後closeです。"),
        ],
        explanationRef: "explain-gold-secure-coding-002",
        designIntent: "Java 9以降のtry-with-resourcesで既存final変数をリソースとして使えることを確認する。"
    )

    static let goldSecureCoding003 = Quiz(
        id: "gold-secure-coding-003",
        level: .gold,
        category: "secure-coding",
        tags: ["try-with-resources", "effectively final", "コンパイルエラー"],
        code: """
class R implements AutoCloseable {
    public void close() {}
}

public class Test {
    public static void main(String[] args) {
        R r = new R();
        r = new R();
        try (r) {
            System.out.println("T");
        }
    }
}
""",
        question: "Java 17でこのコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "Tと出力される", correct: false, misconception: "再代入済みでもtry (r)に使えると誤解", explanation: "既存変数をリソースに使うにはfinalまたは実質finalである必要があります。"),
            Choice(id: "b", text: "try (r) でコンパイルエラー", correct: true, misconception: nil, explanation: "rは再代入されているため実質finalではなく、try-with-resourcesの既存リソース変数として使えません。"),
            Choice(id: "c", text: "r = new R(); でコンパイルエラー", correct: false, misconception: "通常ローカル変数の再代入も禁止と誤解", explanation: "r自体はfinalではないため再代入は可能です。問題はその後try (r)に使う点です。"),
            Choice(id: "d", text: "実行時にIllegalStateException", correct: false, misconception: "リソース指定違反が実行時に判定されると誤解", explanation: "この制約はコンパイル時に検出されます。"),
        ],
        explanationRef: "explain-gold-secure-coding-003",
        designIntent: "try-with-resourcesに既存変数を指定する場合、finalまたは実質finalでなければならないことを確認する。"
    )

    static let goldSecureCoding004 = Quiz(
        id: "gold-secure-coding-004",
        level: .gold,
        category: "secure-coding",
        tags: ["assert", "-ea", "MSC"],
        code: """
public class Test {
    public static void main(String[] args) {
        assert false : "bad";
        System.out.println("OK");
    }
}
""",
        question: "assertionを有効化せずに `java Test` として実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "OK", correct: true, misconception: nil, explanation: "assertionはデフォルトでは無効です。assert文は評価されず、OKが出力されます。"),
            Choice(id: "b", text: "AssertionError", correct: false, misconception: "assertは常に実行されると誤解", explanation: "assertionは通常、-eaで有効化したときだけ評価されます。"),
            Choice(id: "c", text: "bad", correct: false, misconception: "メッセージだけが出力されると誤解", explanation: "assertion無効時はメッセージ式も評価されません。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "assert文を使えないと誤解", explanation: "assertはJavaの有効な文です。"),
        ],
        explanationRef: "explain-gold-secure-coding-004",
        designIntent: "assertionはデフォルト無効であり、入力検証など必須処理に使ってはいけないことを確認する。"
    )

    static let goldSecureCoding005 = Quiz(
        id: "gold-secure-coding-005",
        level: .gold,
        category: "secure-coding",
        tags: ["assert", "AssertionError", "-ea"],
        code: """
public class Test {
    public static void main(String[] args) {
        try {
            int value = -1;
            assert value > 0 : "positive";
            System.out.println("OK");
        } catch (AssertionError e) {
            System.out.println(e.getMessage());
        }
    }
}
""",
        question: "`java -ea Test` として実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "positive", correct: true, misconception: nil, explanation: "-eaでassertionが有効なため条件が評価され、falseなのでAssertionErrorが発生します。メッセージはpositiveです。"),
            Choice(id: "b", text: "OK", correct: false, misconception: "-ea指定を見落としている", explanation: "assertion有効時はassertが評価され、OKの行には到達しません。"),
            Choice(id: "c", text: "null", correct: false, misconception: "assertの詳細メッセージが使われないと誤解", explanation: "`: \"positive\"` がAssertionErrorのメッセージになります。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "AssertionErrorをcatchできないと誤解", explanation: "AssertionErrorはErrorですが、catchすること自体は可能です。"),
        ],
        explanationRef: "explain-gold-secure-coding-005",
        designIntent: "-eaでassertionが有効になったとき、AssertionErrorと詳細メッセージがどう扱われるか確認する。"
    )

    static let goldSecureCoding006 = Quiz(
        id: "gold-secure-coding-006",
        level: .gold,
        category: "secure-coding",
        tags: ["assert", "-ea", "-da"],
        code: """
public class Test {
    public static void main(String[] args) {
        assert false;
        System.out.println("OK");
    }
}
""",
        question: "`java -ea -da Test` として実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "OK", correct: true, misconception: nil, explanation: "-eaで一度有効化しても、後続の-daでassertionが無効化されます。assertは評価されません。"),
            Choice(id: "b", text: "AssertionError", correct: false, misconception: "-eaだけを見て-daを見落としている", explanation: "assertion制御オプションは順に処理され、後ろの-daが効きます。"),
            Choice(id: "c", text: "false", correct: false, misconception: "assert式の値が出力されると誤解", explanation: "assert文はboolean値を出力する文ではありません。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "-eaと-daを同時指定できないと誤解", explanation: "同時指定は可能で、順に適用されます。"),
        ],
        explanationRef: "explain-gold-secure-coding-006",
        designIntent: "-eaと-daの指定順によりassertionの有効/無効が決まることを確認する。"
    )

    static let goldSecureCoding007 = Quiz(
        id: "gold-secure-coding-007",
        level: .gold,
        category: "secure-coding",
        tags: ["assert", "副作用", "MSC"],
        code: """
public class Test {
    public static void main(String[] args) {
        int count = 0;
        assert ++count > 0;
        System.out.println(count);
    }
}
""",
        question: "assertionを有効化せずに `java Test` として実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "0", correct: true, misconception: nil, explanation: "assertion無効時はassert式自体が評価されないため、++countも実行されません。"),
            Choice(id: "b", text: "1", correct: false, misconception: "assert式の副作用は常に実行されると誤解", explanation: "assert式に副作用を書くと、-eaの有無で挙動が変わります。"),
            Choice(id: "c", text: "AssertionError", correct: false, misconception: "assertionが有効だと思い込んでいる", explanation: "問題ではassertionを有効化していません。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "assert式に++を書けないと誤解", explanation: "構文上は書けますが、セキュアコーディング上は副作用を避けるべきです。"),
        ],
        explanationRef: "explain-gold-secure-coding-007",
        designIntent: "assert式に副作用を書くと実行オプションで状態が変わるため危険であることを確認する。"
    )

    static let goldSecureCoding008 = Quiz(
        id: "gold-secure-coding-008",
        level: .gold,
        category: "secure-coding",
        tags: ["assert", "引数検証", "MSC"],
        code: """
public class Test {
    static int divide(int value) {
        assert value > 0 : "positive";
        return 100 / value;
    }

    public static void main(String[] args) {
        System.out.println(divide(-10));
    }
}
""",
        question: "assertionを有効化せずに `java Test` として実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "-10", correct: true, misconception: nil, explanation: "assertion無効時は引数チェックが実行されず、100 / -10 の結果である-10が出力されます。"),
            Choice(id: "b", text: "AssertionError", correct: false, misconception: "assertを通常の入力検証として扱っている", explanation: "assertionは無効化され得るため、公開メソッドの引数検証に使うべきではありません。"),
            Choice(id: "c", text: "ArithmeticException", correct: false, misconception: "負数除算が例外になると誤解", explanation: "整数の負数除算自体は有効です。0除算ではありません。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "assert文をメソッド内に書けないと誤解", explanation: "assert文は構文的には有効です。問題は安全性です。"),
        ],
        explanationRef: "explain-gold-secure-coding-008",
        designIntent: "assertionは無効化できるため、必須の引数検証に使うと安全性が崩れることを確認する。"
    )

    static let goldSecureCoding009 = Quiz(
        id: "gold-secure-coding-009",
        level: .gold,
        category: "secure-coding",
        tags: ["FIO", "Path", "パストラバーサル"],
        code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path base = Path.of("/app/data").normalize();
        Path target = base.resolve("../secret.txt").normalize();
        System.out.println(target.startsWith(base));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "false", correct: true, misconception: nil, explanation: "base.resolve(\"../secret.txt\").normalize() は /app/secret.txt になり、/app/data 配下ではありません。"),
            Choice(id: "b", text: "true", correct: false, misconception: "resolveした時点でbase配下に固定されると誤解", explanation: "`..` をnormalizeすると親ディレクトリへ抜けられます。startsWithで検証が必要です。"),
            Choice(id: "c", text: "InvalidPathException", correct: false, misconception: "`..` を含むPathが不正だと誤解", explanation: "`..` はPathの名前要素として有効です。"),
            Choice(id: "d", text: "SecurityException", correct: false, misconception: "Path操作だけで権限チェックが走ると誤解", explanation: "このコードはパス文字列を操作しているだけで、ファイルアクセスはしていません。"),
        ],
        explanationRef: "explain-gold-secure-coding-009",
        designIntent: "FIOの基本として、ユーザー入力をresolve/normalizeした後に基準ディレクトリ配下か検証する必要があることを確認する。"
    )

    static let goldSecureCoding010 = Quiz(
        id: "gold-secure-coding-010",
        level: .gold,
        category: "secure-coding",
        tags: ["FIO", "Path.resolve", "absolute path"],
        code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path base = Path.of("/safe/base");
        Path target = base.resolve("/etc/passwd").normalize();
        System.out.println(target);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "/etc/passwd", correct: true, misconception: nil, explanation: "resolveの引数が絶対パスの場合、baseは無視され、引数の絶対パスが結果になります。"),
            Choice(id: "b", text: "/safe/base/etc/passwd", correct: false, misconception: "絶対パスも子パスとして連結されると誤解", explanation: "絶対パスをresolveすると右辺が優先されます。"),
            Choice(id: "c", text: "/safe/base", correct: false, misconception: "不正入力がbaseに丸められると誤解", explanation: "Path APIは自動的に安全な場所へ丸めません。"),
            Choice(id: "d", text: "InvalidPathException", correct: false, misconception: "絶対パスをresolveできないと誤解", explanation: "絶対パスを渡すこと自体は有効です。"),
        ],
        explanationRef: "explain-gold-secure-coding-010",
        designIntent: "FIOで絶対パス入力をそのままresolveすると基準ディレクトリを抜けるため、検証が必要であることを確認する。"
    )

    static let goldSecureCoding011 = Quiz(
        id: "gold-secure-coding-011",
        level: .gold,
        category: "secure-coding",
        tags: ["シリアライズ", "transient", "Serializable"],
        code: """
import java.io.*;

class Account implements Serializable {
    String name = "alice";
    transient String password = "secret";
}

public class Test {
    public static void main(String[] args) throws Exception {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        new ObjectOutputStream(out).writeObject(new Account());

        ObjectInputStream in = new ObjectInputStream(
            new ByteArrayInputStream(out.toByteArray()));
        Account a = (Account) in.readObject();
        System.out.println(a.name + ":" + a.password);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "alice:null", correct: true, misconception: nil, explanation: "transientフィールドpasswordはシリアライズ対象外なので、復元後は参照型のデフォルト値nullです。"),
            Choice(id: "b", text: "alice:secret", correct: false, misconception: "transientでも通常通り保存されると誤解", explanation: "transientは機密値などを永続化対象から外すために使えます。"),
            Choice(id: "c", text: "null:null", correct: false, misconception: "すべてのフィールドが初期化され直すと誤解", explanation: "非transientのnameはシリアライズされた値aliceとして復元されます。"),
            Choice(id: "d", text: "NotSerializableException", correct: false, misconception: "transientフィールドがあるとシリアライズできないと誤解", explanation: "AccountはSerializableを実装しているためシリアライズできます。"),
        ],
        explanationRef: "explain-gold-secure-coding-011",
        designIntent: "シリアライズ時にtransientフィールドが保存されず、復元後にデフォルト値になることを確認する。"
    )

    static let goldSecureCoding012 = Quiz(
        id: "gold-secure-coding-012",
        level: .gold,
        category: "secure-coding",
        tags: ["シリアライズ", "readObject", "InvalidObjectException"],
        code: """
import java.io.*;

class User implements Serializable {
    int age;
    User(int age) { this.age = age; }

    private void readObject(ObjectInputStream in)
        throws IOException, ClassNotFoundException {
        in.defaultReadObject();
        if (age < 0) throw new InvalidObjectException("age");
    }
}

public class Test {
    public static void main(String[] args) throws Exception {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        new ObjectOutputStream(out).writeObject(new User(-1));
        try {
            new ObjectInputStream(
                new ByteArrayInputStream(out.toByteArray())).readObject();
        } catch (InvalidObjectException e) {
            System.out.println(e.getMessage());
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "age", correct: true, misconception: nil, explanation: "readObject内でdefaultReadObject後にageを検証し、負数なのでInvalidObjectException(\"age\")を投げます。"),
            Choice(id: "b", text: "-1", correct: false, misconception: "検証が実行されないと誤解", explanation: "デシリアライズ時にはprivate readObjectが呼ばれます。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "readObjectをprivateで宣言できないと誤解", explanation: "シリアライズのreadObjectフックはprivateで定義します。"),
            Choice(id: "d", text: "ClassCastException", correct: false, misconception: "readObjectの戻り値キャストが原因と誤解", explanation: "このコードは戻り値をキャストしていません。検証例外をcatchしています。"),
        ],
        explanationRef: "explain-gold-secure-coding-012",
        designIntent: "デシリアライズ時にはreadObjectで不変条件を検証し、不正な状態を拒否できることを確認する。"
    )

    static let goldSecureCoding013 = Quiz(
        id: "gold-secure-coding-013",
        level: .gold,
        category: "secure-coding",
        tags: ["シリアライズ", "ObjectInputFilter", "JEP 290"],
        code: """
import java.io.*;

public class Test {
    public static void main(String[] args) throws Exception {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        new ObjectOutputStream(out).writeObject("data");

        ObjectInputStream in = new ObjectInputStream(
            new ByteArrayInputStream(out.toByteArray()));
        in.setObjectInputFilter(info ->
            info.serialClass() == String.class
                ? ObjectInputFilter.Status.REJECTED
                : ObjectInputFilter.Status.UNDECIDED);
        try {
            in.readObject();
        } catch (InvalidClassException e) {
            System.out.println("rejected");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "rejected", correct: true, misconception: nil, explanation: "ObjectInputFilterがStringクラスをREJECTEDにするため、readObject時にInvalidClassExceptionとして拒否されます。"),
            Choice(id: "b", text: "data", correct: false, misconception: "フィルタがログ用途だけだと誤解", explanation: "REJECTEDを返すとデシリアライズは拒否されます。"),
            Choice(id: "c", text: "ClassCastException", correct: false, misconception: "型キャスト失敗と混同", explanation: "キャスト前に入力フィルタで拒否されます。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "ObjectInputFilterをラムダで指定できないと誤解", explanation: "ObjectInputFilterは関数型インターフェースとしてラムダで指定できます。"),
        ],
        explanationRef: "explain-gold-secure-coding-013",
        designIntent: "デシリアライズ入力にObjectInputFilterを設定して、想定外の型を拒否できることを確認する。"
    )

    static let goldSecureCoding014 = Quiz(
        id: "gold-secure-coding-014",
        level: .gold,
        category: "secure-coding",
        tags: ["プラットフォームセキュリティ", "doPrivileged", "最小権限"],
        code: """
import java.security.*;

class Service {
    String load() {
        String value = AccessController.doPrivileged(
            (PrivilegedAction<String>) () -> System.getProperty("user.home"));
        return sanitize(value);
    }

    String sanitize(String value) {
        return value == null ? "" : value.trim();
    }
}
""",
        question: "このコードのセキュアコーディング上の読み方として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "特権で実行されるのはSystem.getPropertyのラムダ内だけ", correct: true, misconception: nil, explanation: "doPrivilegedに渡したPrivilegedActionの中だけが特権境界です。sanitizeは外側で実行されます。"),
            Choice(id: "b", text: "load()全体が特権で実行される", correct: false, misconception: "doPrivileged以降の処理もすべて特権化されると誤解", explanation: "特権化されるのはdoPrivilegedに渡した処理の範囲だけです。"),
            Choice(id: "c", text: "sanitizeも特権ブロックに入れるほど安全", correct: false, misconception: "特権範囲は広いほど安全と誤解", explanation: "特権範囲は必要最小限にするのが原則です。"),
            Choice(id: "d", text: "doPrivilegedは戻り値を返せない", correct: false, misconception: "PrivilegedActionの戻り値を使えないと誤解", explanation: "PrivilegedAction<T>の戻り値をdoPrivilegedの戻り値として受け取れます。"),
        ],
        explanationRef: "explain-gold-secure-coding-014",
        designIntent: "プラットフォームセキュリティで特権ブロックは必要最小限に限定する、という読み方を確認する。"
    )

    static let goldSecureCoding015 = Quiz(
        id: "gold-secure-coding-015",
        level: .gold,
        category: "secure-coding",
        tags: ["プラットフォームセキュリティ", "SecurityException", "unchecked"],
        code: """
public class Test {
    static void check() {
        throw new SecurityException("deny");
    }

    public static void main(String[] args) {
        try {
            check();
        } catch (RuntimeException e) {
            System.out.println(e.getClass().getSimpleName());
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "SecurityException", correct: true, misconception: nil, explanation: "SecurityExceptionはRuntimeExceptionのサブクラスなのでcatch(RuntimeException)で捕捉され、実体クラス名が出力されます。"),
            Choice(id: "b", text: "RuntimeException", correct: false, misconception: "catch型が実体クラスになると誤解", explanation: "getClass().getSimpleName()は発生した具体例外のクラス名を返します。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "SecurityExceptionにはthrows宣言が必要と誤解", explanation: "SecurityExceptionはunchecked例外なのでthrows宣言は必須ではありません。"),
            Choice(id: "d", text: "deny", correct: false, misconception: "クラス名ではなくメッセージが出ると誤解", explanation: "出力しているのはgetClass().getSimpleName()です。"),
        ],
        explanationRef: "explain-gold-secure-coding-015",
        designIntent: "SecurityExceptionはプラットフォームセキュリティで現れるunchecked例外であり、RuntimeExceptionとして捕捉できることを確認する。"
    )

    static let goldSecureCoding016 = Quiz(
        id: "gold-secure-coding-016",
        level: .gold,
        category: "secure-coding",
        tags: ["コレクション", "防御的コピー", "unmodifiableList"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> base = new ArrayList<>();
        base.add("A");
        List<String> view = Collections.unmodifiableList(base);
        List<String> copy = List.copyOf(base);
        base.add("B");
        System.out.println(view.size() + ":" + copy.size());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2:1", correct: true, misconception: nil, explanation: "unmodifiableListは変更不可ビューなので元リストの追加が反映されます。List.copyOfは独立したコピーです。"),
            Choice(id: "b", text: "1:1", correct: false, misconception: "unmodifiableListが防御的コピーを作ると誤解", explanation: "unmodifiableListはラップしたビューであり、元リストの変更は見えます。"),
            Choice(id: "c", text: "2:2", correct: false, misconception: "List.copyOfも元リストを参照し続けると誤解", explanation: "List.copyOfはその時点の要素から変更不可リストを作ります。"),
            Choice(id: "d", text: "UnsupportedOperationException", correct: false, misconception: "base.addも禁止されると誤解", explanation: "禁止されるのはview経由の変更です。base自体はArrayListなので追加できます。"),
        ],
        explanationRef: "explain-gold-secure-coding-016",
        designIntent: "コレクションを外部公開するとき、変更不可ビューと防御的コピーの違いが安全性に影響することを確認する。"
    )

    static let goldSecureCoding017 = Quiz(
        id: "gold-secure-coding-017",
        level: .gold,
        category: "secure-coding",
        tags: ["コレクション", "checkedList", "raw type"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> list = Collections.checkedList(new ArrayList<>(), String.class);
        List raw = list;
        try {
            raw.add(10);
        } catch (ClassCastException e) {
            System.out.println("CCE");
        }
        System.out.println(list.size());
    }
}
""",
        question: "このコードを実行したとき、出力として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "CCE の後に 0", correct: true, misconception: nil, explanation: "checkedListは実行時に要素型を検査します。raw経由でIntegerを追加しようとしてClassCastExceptionになり、追加されません。"),
            Choice(id: "b", text: "1", correct: false, misconception: "raw型経由なら検査をすり抜けると誤解", explanation: "checkedListのラッパーが実行時検査を行います。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "raw型代入が完全に禁止されると誤解", explanation: "raw型使用は警告になりますが、通常はコンパイル自体は通ります。"),
            Choice(id: "d", text: "ArrayStoreException", correct: false, misconception: "配列の実行時型検査と混同", explanation: "コレクションのcheckedListではClassCastExceptionです。"),
        ],
        explanationRef: "explain-gold-secure-coding-017",
        designIntent: "Collections.checkedListがraw型経由のヒープ汚染を実行時に検出できることを確認する。"
    )

    static let goldSecureCoding018 = Quiz(
        id: "gold-secure-coding-018",
        level: .gold,
        category: "secure-coding",
        tags: ["ジェネリクス", "heap pollution", "ClassCastException"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String>[] array = new List[1];
        Object[] objects = array;
        objects[0] = List.of(10);
        try {
            String s = array[0].get(0);
            System.out.println(s);
        } catch (ClassCastException e) {
            System.out.println("CCE");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "CCE", correct: true, misconception: nil, explanation: "配列経由でList<Integer>をList<String>[]に入れ、取得時にIntegerからStringへのキャストが発生してClassCastExceptionになります。"),
            Choice(id: "b", text: "10", correct: false, misconception: "ジェネリクス型が実行時にも完全に保持されると誤解", explanation: "型消去によりList<String>の要素型は実行時配列型では守られません。"),
            Choice(id: "c", text: "ArrayStoreException", correct: false, misconception: "List<Integer>とList<String>が実行時配列型で区別されると誤解", explanation: "実行時の配列要素型はListなので、List.of(10)の代入自体は通ります。"),
            Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "unchecked警告をコンパイルエラーと誤解", explanation: "`new List[1]` からList<String>[]への代入はunchecked警告ですが、通常はコンパイルできます。"),
        ],
        explanationRef: "explain-gold-secure-coding-018",
        designIntent: "ジェネリクス配列とraw/配列共変性によるヒープ汚染が、後でClassCastExceptionにつながることを確認する。"
    )

    static let goldSecureCoding019 = Quiz(
        id: "gold-secure-coding-019",
        level: .gold,
        category: "secure-coding",
        tags: ["ジェネリクス", "List<?>", "null"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<?> values = new ArrayList<String>();
        values.add(null);
        System.out.println(values.size());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1", correct: true, misconception: nil, explanation: "List<?>には具体的な非null値を追加できませんが、nullだけはどの参照型にも代入可能なので追加できます。"),
            Choice(id: "b", text: "0", correct: false, misconception: "add(null)が無視されると誤解", explanation: "add(null)は実行され、サイズは1になります。"),
            Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "List<?>にはnullも追加できないと誤解", explanation: "nullは例外的に追加できます。"),
            Choice(id: "d", text: "NullPointerException", correct: false, misconception: "null追加が常に例外になると誤解", explanation: "ArrayListはnull要素を許容します。"),
        ],
        explanationRef: "explain-gold-secure-coding-019",
        designIntent: "非境界ワイルドカードList<?>では非null要素は追加不可だが、nullは追加できることを確認する。"
    )

    static let goldSecureCoding020 = Quiz(
        id: "gold-secure-coding-020",
        level: .gold,
        category: "secure-coding",
        tags: ["コレクション", "List.of", "null"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        try {
            List<String> list = List.of("A", null);
            System.out.println(list.size());
        } catch (NullPointerException e) {
            System.out.println("NPE");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "NPE", correct: true, misconception: nil, explanation: "List.ofで作る変更不可リストはnull要素を許容しません。生成時にNullPointerExceptionが発生します。"),
            Choice(id: "b", text: "2", correct: false, misconception: "ArrayListと同じようにnullを許容すると誤解", explanation: "List.ofはnullを拒否します。"),
            Choice(id: "c", text: "1", correct: false, misconception: "nullだけが無視されると誤解", explanation: "null要素は無視されず、例外になります。"),
            Choice(id: "d", text: "UnsupportedOperationException", correct: false, misconception: "変更不可リストへの変更失敗と混同", explanation: "今回は生成時のnull拒否なのでNullPointerExceptionです。"),
        ],
        explanationRef: "explain-gold-secure-coding-020",
        designIntent: "List.ofなどのファクトリメソッドはnullを拒否するため、入力値の扱いに注意が必要であることを確認する。"
    )
}
