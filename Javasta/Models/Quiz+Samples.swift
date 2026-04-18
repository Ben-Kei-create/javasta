import Foundation

extension Quiz {
    static let samples: [Quiz] = [silverOverload001, silverException001, goldGenerics001]

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
}
