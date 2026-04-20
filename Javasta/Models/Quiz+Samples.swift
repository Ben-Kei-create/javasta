import Foundation

extension Quiz {
    static let samples: [Quiz] = [
        silverOverload001,
        silverException001,
        silverString001,
        silverAutoboxing001,
        silverSwitch001,
        goldGenerics001,
        goldStream001,
        goldOptional001,
    ]

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
                   explanation: "5はintリテラル。Javaの[オーバーロード](javasta://term/overload)解決は完全一致を最優先するため、print(int)が選ばれます。"),
            Choice(id: "b", text: "long: 5",
                   correct: false, misconception: "型の自動昇格が常に起こると誤解",
                   explanation: "int→longへの[型昇格](javasta://term/type-promotion)は完全一致するメソッドがない場合のみ。ここではprint(int)と完全一致するため昇格しません。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "オーバーロードが曖昧と誤解",
                   explanation: "5はintリテラルなのでprint(int)と完全一致します。曖昧さはなく、[コンパイル](javasta://term/compile)エラーにはなりません。"),
            Choice(id: "d", text: "実行時エラー",
                   correct: false, misconception: nil,
                   explanation: "このコードに実行時エラーの要因はありません。正常にコンパイル・実行されます。"),
        ],
        explanationRef: "explain-silver-overload-001",
        designIntent: "Javaの[オーバーロード](javasta://term/overload)解決は「完全一致 → [型昇格](javasta://term/type-promotion) → [オートボクシング](javasta://term/boxing) → [可変長引数](javasta://term/varargs)」の順で試みられます。"
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
}
