import Foundation

extension Quiz {
    static let silverExpansion: [Quiz] = [
        silverJavaBasics003,
        silverJavaBasics004,
        silverDataTypes003,
        silverDataTypes004,
        silverDataTypes005,
        silverString002,
        silverString003,
        silverStringBuilder002,
        silverArray003,
        silverCollections002,
        silverCollections003,
        silverControlFlow003,
        silverControlFlow004,
        silverControlFlow005,
        silverOverload003,
        silverClasses003,
        silverClasses004,
        silverInheritance002,
        silverInheritance003,
        silverInheritance004,
        silverException003,
        silverException004,
        silverLambda002,
        silverArrayList001,
        silverJavaBasics005,
        silverDataTypes006,
        silverDataTypes007,
        silverDataTypes008,
        silverString004,
        silverStringBuilder003,
        silverArray004,
        silverArray005,
        silverCollections004,
        silverCollections005,
        silverControlFlow006,
        silverControlFlow007,
        silverOverload004,
        silverClasses005,
        silverInheritance005,
        silverInheritance006,
        silverException005,
        silverLambda003,
    ]

    // MARK: - Silver: Javaの基本 (mainメソッド)

    static let silverJavaBasics003 = Quiz(
        id: "silver-java-basics-003",
        level: .silver,
        category: "java-basics",
        tags: ["main", "エントリポイント", "オーバーロード"],
        code: """
public class Test {
    public static void main(String[] args) {
        System.out.print("A");
        main(10);
    }

    public static void main(int value) {
        System.out.print(value);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "A10",
                   correct: true, misconception: nil,
                   explanation: "JVMが起動時に呼ぶのはString[]引数のmainです。その中からオーバーロードされたmain(int)を通常メソッドとして呼べるため、A10が出力されます。"),
            Choice(id: "b", text: "10",
                   correct: false, misconception: "main(int)が起動時に選ばれると誤解",
                   explanation: "起動エントリポイントとして認識されるのはpublic static void main(String[] args)です。"),
            Choice(id: "c", text: "A",
                   correct: false, misconception: "mainはオーバーロード呼び出しできないと誤解",
                   explanation: "mainも通常のstaticメソッドなので、同じクラス内からmain(10)として呼び出せます。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "mainメソッドを複数定義できないと誤解",
                   explanation: "引数リストが異なるためオーバーロードとして有効です。"),
        ],
        explanationRef: "explain-silver-java-basics-003",
        designIntent: "起動エントリポイントとしてのmainと、通常のオーバーロードメソッドとしてのmainを区別できるか確認する。"
    )

    // MARK: - Silver: Javaの基本 (import)

    static let silverJavaBasics004 = Quiz(
        id: "silver-java-basics-004",
        level: .silver,
        category: "java-basics",
        tags: ["import", "java.lang", "StringBuilder"],
        code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("A");
        System.out.println(sb);
    }
}
""",
        question: "このコードについて正しい説明はどれか？",
        choices: [
            Choice(id: "a", text: "import java.util.StringBuilder; が必要なのでコンパイルエラー",
                   correct: false, misconception: "StringBuilderがjava.utilにあると誤解",
                   explanation: "StringBuilderはjava.lang.StringBuilderです。java.utilではなく、java.langは自動インポートされます。"),
            Choice(id: "b", text: "import java.lang.StringBuilder; が必要なのでコンパイルエラー",
                   correct: false, misconception: "java.langの明示importが必須と誤解",
                   explanation: "java.langパッケージは自動インポートされます。"),
            Choice(id: "c", text: "正常にコンパイルでき、Aと出力される",
                   correct: true, misconception: nil,
                   explanation: "StringBuilderはjava.langパッケージのクラスです。java.langは自動的にインポートされるため、明示的なimportなしで利用できます。"),
            Choice(id: "d", text: "実行時にClassNotFoundExceptionが発生する",
                   correct: false, misconception: "import漏れが実行時エラーになると誤解",
                   explanation: "importや型解決の問題はコンパイル時に扱われます。このコードは正常にコンパイルできます。"),
        ],
        explanationRef: "explain-silver-java-basics-004",
        designIntent: "java.langパッケージの自動インポートと、importの役割を確認する。"
    )

    // MARK: - Silver: データ型 (複合代入)

    static let silverDataTypes003 = Quiz(
        id: "silver-data-types-003",
        level: .silver,
        category: "data-types",
        tags: ["short", "複合代入", "暗黙キャスト"],
        code: """
public class Test {
    public static void main(String[] args) {
        short s = 1;
        s += 1;
        System.out.println(s);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2",
                   correct: true, misconception: nil,
                   explanation: "複合代入演算子 += は内部で暗黙のキャストを含みます。s = (short)(s + 1) に近い動作になるためコンパイルできます。"),
            Choice(id: "b", text: "1",
                   correct: false, misconception: "右辺の加算が反映されないと誤解",
                   explanation: "s += 1 により値は1増えます。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "s = s + 1 と同じだと誤解",
                   explanation: "s = s + 1 はintへの昇格によりエラーですが、s += 1 は暗黙キャストを含むため有効です。"),
            Choice(id: "d", text: "実行時エラー",
                   correct: false, misconception: nil,
                   explanation: "このコードに実行時例外の要因はありません。"),
        ],
        explanationRef: "explain-silver-data-types-003",
        designIntent: "複合代入演算子が暗黙キャストを含むため、通常代入と結果が変わることを確認する。"
    )

    // MARK: - Silver: データ型 (char)

    static let silverDataTypes004 = Quiz(
        id: "silver-data-types-004",
        level: .silver,
        category: "data-types",
        tags: ["char", "インクリメント", "数値表現"],
        code: """
public class Test {
    public static void main(String[] args) {
        char c = 'A';
        c++;
        System.out.println((int) c);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "65",
                   correct: false, misconception: "インクリメント前の'A'のコード値を出すと誤解",
                   explanation: "'A'のコード値は65ですが、c++により次の文字に進みます。"),
            Choice(id: "b", text: "66",
                   correct: true, misconception: nil,
                   explanation: "'A'は65です。c++により'B'相当になり、intへキャストすると66が出力されます。"),
            Choice(id: "c", text: "B",
                   correct: false, misconception: "charとして出力されると誤解",
                   explanation: "printlnしているのは(int)cなので、文字ではなく数値が出力されます。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "charをインクリメントできないと誤解",
                   explanation: "charは整数型の一種なのでインクリメント可能です。"),
        ],
        explanationRef: "explain-silver-data-types-004",
        designIntent: "charが整数型として扱われることと、キャスト後の出力を確認する。"
    )

    // MARK: - Silver: データ型 (数値昇格)

    static let silverDataTypes005 = Quiz(
        id: "silver-data-types-005",
        level: .silver,
        category: "data-types",
        tags: ["byte", "数値昇格", "コンパイルエラー"],
        code: """
public class Test {
    public static void main(String[] args) {
        byte b = 10;
        b = b + 1;
        System.out.println(b);
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "11と出力される",
                   correct: false, misconception: "byte同士の演算結果もbyteになると誤解",
                   explanation: "byte、short、charは算術演算時にintへ昇格します。b + 1の型はintです。"),
            Choice(id: "b", text: "10と出力される",
                   correct: false, misconception: "代入が無視されると誤解",
                   explanation: "代入が無視されるのではなく、型不一致でコンパイルエラーになります。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "b + 1はint型です。intをbyteへ代入するには明示キャストが必要です。"),
            Choice(id: "d", text: "実行時にArithmeticException",
                   correct: false, misconception: "整数演算の型変換が実行時例外になると誤解",
                   explanation: "この問題はコンパイル時の型チェックで検出されます。"),
        ],
        explanationRef: "explain-silver-data-types-005",
        designIntent: "byte/short/charの算術演算がintへ昇格する基本ルールを確認する。"
    )

    // MARK: - Silver: String (trim)

    static let silverString002 = Quiz(
        id: "silver-string-002",
        level: .silver,
        category: "string",
        tags: ["String", "trim", "不変"],
        code: """
public class Test {
    public static void main(String[] args) {
        String s = " Java ";
        s.trim();
        System.out.println("[" + s + "]");
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "[Java]",
                   correct: false, misconception: "trimが元のStringを変更すると誤解",
                   explanation: "Stringは不変です。trimは新しい文字列を返しますが、戻り値を受け取っていません。"),
            Choice(id: "b", text: "[ Java ]",
                   correct: true, misconception: nil,
                   explanation: "s.trim()の戻り値を代入していないため、sは元の\" Java \"のままです。"),
            Choice(id: "c", text: "[Java ]",
                   correct: false, misconception: "先頭だけ削除されると誤解",
                   explanation: "trim自体は前後の空白を削除しますが、このコードでは戻り値を使っていません。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "戻り値を使わないメソッド呼び出しが禁止と誤解",
                   explanation: "戻り値を無視してもコンパイルは可能です。"),
        ],
        explanationRef: "explain-silver-string-002",
        designIntent: "Stringの不変性と、戻り値を受け取らないメソッド呼び出しの落とし穴を確認する。"
    )

    // MARK: - Silver: String (substring)

    static let silverString003 = Quiz(
        id: "silver-string-003",
        level: .silver,
        category: "string",
        tags: ["String", "substring", "インデックス"],
        code: """
public class Test {
    public static void main(String[] args) {
        String s = "abcdef";
        System.out.println(s.substring(2, 5));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "cde",
                   correct: true, misconception: nil,
                   explanation: "substring(2, 5)は開始インデックス2を含み、終了インデックス5を含みません。取り出されるのはcdeです。"),
            Choice(id: "b", text: "cdef",
                   correct: false, misconception: "終了インデックスも含むと誤解",
                   explanation: "第2引数の終了位置は含まれません。"),
            Choice(id: "c", text: "bcd",
                   correct: false, misconception: "インデックスが1始まりだと誤解",
                   explanation: "Stringのインデックスは0始まりです。"),
            Choice(id: "d", text: "StringIndexOutOfBoundsException",
                   correct: false, misconception: "終了インデックス5が範囲外だと誤解",
                   explanation: "長さ6の文字列では終了インデックス5は有効です。終了位置は含まれません。"),
        ],
        explanationRef: "explain-silver-string-003",
        designIntent: "substringの開始は含む、終了は含まないという頻出ルールを確認する。"
    )

    // MARK: - Silver: StringBuilder (delete)

    static let silverStringBuilder002 = Quiz(
        id: "silver-stringbuilder-002",
        level: .silver,
        category: "string",
        tags: ["StringBuilder", "delete", "メソッドチェーン"],
        code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("abcdef");
        sb.delete(1, 4).append("X");
        System.out.println(sb);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "aefX",
                   correct: true, misconception: nil,
                   explanation: "delete(1, 4)はインデックス1以上4未満、つまりbcdを削除します。その後Xを追加するためaefXです。"),
            Choice(id: "b", text: "afX",
                   correct: false, misconception: "終了インデックス4も削除されると誤解",
                   explanation: "終了インデックスは含まれないため、eは残ります。"),
            Choice(id: "c", text: "abcdefX",
                   correct: false, misconception: "StringBuilderも不変と誤解",
                   explanation: "StringBuilderは可変です。deleteにより同じインスタンスが変更されます。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "deleteの戻り値でappendできないと誤解",
                   explanation: "deleteはStringBuilder自身を返すため、メソッドチェーンできます。"),
        ],
        explanationRef: "explain-silver-stringbuilder-002",
        designIntent: "StringBuilderの可変性、deleteの範囲、メソッドチェーンを確認する。"
    )

    // MARK: - Silver: 配列 (非対称配列)

    static let silverArray003 = Quiz(
        id: "silver-array-003",
        level: .silver,
        category: "data-types",
        tags: ["配列", "多次元配列", "NullPointerException"],
        code: """
public class Test {
    public static void main(String[] args) {
        int[][] nums = new int[2][];
        System.out.println(nums[0][0]);
    }
}
""",
        question: "このコードを実行したとき、結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "0",
                   correct: false, misconception: "2次元目も自動生成されると誤解",
                   explanation: "new int[2][]では1次元目だけが生成され、各要素はnullです。"),
            Choice(id: "b", text: "NullPointerException",
                   correct: true, misconception: nil,
                   explanation: "nums[0]はまだnullです。そのnullに対して[0]でアクセスしようとしているためNullPointerExceptionが発生します。"),
            Choice(id: "c", text: "ArrayIndexOutOfBoundsException",
                   correct: false, misconception: "添字範囲外と誤解",
                   explanation: "nums[0]自体は範囲内ですが、その参照先がnullです。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "2次元目のサイズ省略が不可と誤解",
                   explanation: "Javaでは1次元目のサイズだけ指定して、多次元配列を後から作ることができます。"),
        ],
        explanationRef: "explain-silver-array-003",
        designIntent: "多次元配列は配列の配列であり、未生成の内側配列はnullになることを確認する。"
    )

    // MARK: - Silver: コレクション (remove overload)

    static let silverCollections002 = Quiz(
        id: "silver-collections-002",
        level: .silver,
        category: "collections",
        tags: ["ArrayList", "remove", "オーバーロード"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<Integer> list = new ArrayList<>(List.of(1, 2, 3));
        list.remove(1);
        System.out.println(list);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "[1, 3]",
                   correct: true, misconception: nil,
                   explanation: "remove(1)はint引数なのでremove(int index)が選ばれます。インデックス1の要素2が削除されます。"),
            Choice(id: "b", text: "[2, 3]",
                   correct: false, misconception: "値1が削除されると誤解",
                   explanation: "Integerの値1を削除したい場合はremove(Integer.valueOf(1))のようにObject版を呼ぶ必要があります。"),
            Choice(id: "c", text: "[1, 2]",
                   correct: false, misconception: "最後の要素が削除されると誤解",
                   explanation: "インデックス1は2番目の要素です。最後の要素ではありません。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "removeのオーバーロードが曖昧と誤解",
                   explanation: "intリテラル1はremove(int)に完全一致するため曖昧ではありません。"),
        ],
        explanationRef: "explain-silver-collections-002",
        designIntent: "ArrayList.remove(int)とremove(Object)のオーバーロード解決を確認する。"
    )

    // MARK: - Silver: コレクション (List.of immutable)

    static let silverCollections003 = Quiz(
        id: "silver-collections-003",
        level: .silver,
        category: "collections",
        tags: ["List.of", "不変リスト", "UnsupportedOperationException"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> list = List.of("A", "B");
        try {
            list.add("C");
            System.out.println(list.size());
        } catch (UnsupportedOperationException e) {
            System.out.println("UOE");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "3",
                   correct: false, misconception: "List.ofで作ったリストを変更できると誤解",
                   explanation: "List.ofで作成したリストは不変です。addは許可されません。"),
            Choice(id: "b", text: "2",
                   correct: false, misconception: "addが無視されると誤解",
                   explanation: "変更操作は無視されるのではなく、例外をスローします。"),
            Choice(id: "c", text: "UOE",
                   correct: true, misconception: nil,
                   explanation: "不変リストにaddしようとするとUnsupportedOperationExceptionが発生し、catch節でUOEが出力されます。"),
            Choice(id: "d", text: "NullPointerException",
                   correct: false, misconception: "List.ofのnull禁止と混同",
                   explanation: "このコードにはnull要素はありません。問題は不変リストへの変更操作です。"),
        ],
        explanationRef: "explain-silver-collections-003",
        designIntent: "List.ofで作成される不変リストの変更操作がUnsupportedOperationExceptionになることを確認する。"
    )

    // MARK: - Silver: 制御構文 (do-while)

    static let silverControlFlow003 = Quiz(
        id: "silver-control-flow-003",
        level: .silver,
        category: "control-flow",
        tags: ["do-while", "ループ", "実行順"],
        code: """
public class Test {
    public static void main(String[] args) {
        int i = 5;
        do {
            System.out.print(i++);
        } while (i < 5);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "何も出力されない",
                   correct: false, misconception: "条件判定が先に行われると誤解",
                   explanation: "do-whileは本体を実行してから条件を判定します。"),
            Choice(id: "b", text: "5",
                   correct: true, misconception: nil,
                   explanation: "doブロックは最低1回実行されます。5を出力してiが6になり、その後条件i < 5がfalseとなって終了します。"),
            Choice(id: "c", text: "56",
                   correct: false, misconception: "条件false後ももう1回実行されると誤解",
                   explanation: "条件判定がfalseになった時点でループは終了します。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: nil,
                   explanation: "do-while構文として正しいコードです。"),
        ],
        explanationRef: "explain-silver-control-flow-003",
        designIntent: "do-whileは条件に関係なく最低1回本体を実行することを確認する。"
    )

    // MARK: - Silver: 制御構文 (ラベル付きbreak)

    static let silverControlFlow004 = Quiz(
        id: "silver-control-flow-004",
        level: .silver,
        category: "control-flow",
        tags: ["ラベル", "break", "ネストループ"],
        code: """
public class Test {
    public static void main(String[] args) {
        outer:
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                if (i == 1 && j == 1) break outer;
                System.out.print(i + "" + j + " ");
            }
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "00 01 02 10",
                   correct: true, misconception: nil,
                   explanation: "i=1,j=1でbreak outerが実行されるため、その直前までの00 01 02 10が出力されます。"),
            Choice(id: "b", text: "00 01 02 10 11",
                   correct: false, misconception: "break前に11が出力されると誤解",
                   explanation: "if文はprintlnより前にあるため、i=1,j=1では出力せずにループを抜けます。"),
            Choice(id: "c", text: "00 01 02 10 12 20 21 22",
                   correct: false, misconception: "内側ループだけを抜けると誤解",
                   explanation: "break outerは外側ラベルのループまで抜けます。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "ラベル付きbreakが使えないと誤解",
                   explanation: "ラベル付きbreakはJavaの有効な構文です。"),
        ],
        explanationRef: "explain-silver-control-flow-004",
        designIntent: "ラベル付きbreakがネストした外側ループまで終了させることを確認する。"
    )

    // MARK: - Silver: 制御構文 (default fall-through)

    static let silverControlFlow005 = Quiz(
        id: "silver-control-flow-005",
        level: .silver,
        category: "control-flow",
        tags: ["switch", "default", "フォールスルー"],
        code: """
public class Test {
    public static void main(String[] args) {
        int x = 9;
        switch (x) {
            default: System.out.print("D");
            case 1: System.out.print("A");
            case 2: System.out.print("B");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "D",
                   correct: false, misconception: "defaultで自動的にswitchを抜けると誤解",
                   explanation: "breakがないため、defaultから後続caseへフォールスルーします。"),
            Choice(id: "b", text: "DAB",
                   correct: true, misconception: nil,
                   explanation: "一致するcaseがないためdefaultから開始し、breakがないのでcase 1、case 2へ流れます。"),
            Choice(id: "c", text: "AB",
                   correct: false, misconception: "defaultの位置が最後でないと無視されると誤解",
                   explanation: "defaultはどこに書いても有効です。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "defaultは最後に書く必要があると誤解",
                   explanation: "defaultの位置は最後でなくても構文上有効です。"),
        ],
        explanationRef: "explain-silver-control-flow-005",
        designIntent: "defaultの位置とフォールスルーの組み合わせを確認する。"
    )

    // MARK: - Silver: オーバーロード (boxing vs varargs)

    static let silverOverload003 = Quiz(
        id: "silver-overload-003",
        level: .silver,
        category: "overload-resolution",
        tags: ["オーバーロード", "ボクシング", "可変長引数"],
        code: """
public class Test {
    static void call(Integer x) {
        System.out.println("Integer");
    }

    static void call(int... x) {
        System.out.println("varargs");
    }

    public static void main(String[] args) {
        call(1);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "Integer",
                   correct: true, misconception: nil,
                   explanation: "完全一致がない場合、可変長引数よりボクシングが優先されます。intはIntegerへボクシングされ、call(Integer)が選ばれます。"),
            Choice(id: "b", text: "varargs",
                   correct: false, misconception: "可変長引数が優先されると誤解",
                   explanation: "可変長引数は最後の手段です。ボクシングで候補が見つかるためvarargsは選ばれません。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "候補が2つあると曖昧になると誤解",
                   explanation: "優先順位によりcall(Integer)が明確に選ばれます。"),
            Choice(id: "d", text: "実行時エラー",
                   correct: false, misconception: nil,
                   explanation: "オーバーロード解決はコンパイル時に決まります。"),
        ],
        explanationRef: "explain-silver-overload-003",
        designIntent: "オーバーロード解決の優先順位で、ボクシングが可変長引数より優先されることを確認する。"
    )

    // MARK: - Silver: クラス (初期化順序)

    static let silverClasses003 = Quiz(
        id: "silver-classes-003",
        level: .silver,
        category: "classes",
        tags: ["初期化順序", "static", "コンストラクタ"],
        code: """
class Sample {
    static { System.out.print("S"); }
    { System.out.print("I"); }
    Sample() { System.out.print("C"); }
}

public class Test {
    public static void main(String[] args) {
        new Sample();
        new Sample();
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "SICIC",
                   correct: true, misconception: nil,
                   explanation: "static初期化ブロックはクラスロード時に1回だけ実行されます。各インスタンス生成時にインスタンス初期化ブロックI、コンストラクタCが実行されます。"),
            Choice(id: "b", text: "SICSIC",
                   correct: false, misconception: "staticブロックがインスタンスごとに実行されると誤解",
                   explanation: "static初期化はクラス単位で1回だけです。"),
            Choice(id: "c", text: "ICIC",
                   correct: false, misconception: "staticブロックが実行されないと誤解",
                   explanation: "Sampleを初めて使うタイミングでstatic初期化ブロックが実行されます。"),
            Choice(id: "d", text: "SCIIC",
                   correct: false, misconception: "コンストラクタが初期化ブロックより先と誤解",
                   explanation: "インスタンス初期化ブロックはコンストラクタ本体より前に実行されます。"),
        ],
        explanationRef: "explain-silver-classes-003",
        designIntent: "static初期化、インスタンス初期化、コンストラクタの実行順を確認する。"
    )

    // MARK: - Silver: クラス (this呼び出し位置)

    static let silverClasses004 = Quiz(
        id: "silver-classes-004",
        level: .silver,
        category: "classes",
        tags: ["コンストラクタ", "this", "先頭文"],
        code: """
class Box {
    Box() {
        System.out.print("A");
        this(1);
    }

    Box(int value) {}
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる",
                   correct: false, misconception: "this(...)をコンストラクタ内ならどこでも書けると誤解",
                   explanation: "this(...)による別コンストラクタ呼び出しは、コンストラクタの先頭文でなければなりません。"),
            Choice(id: "b", text: "Aと出力される",
                   correct: false, misconception: "実行まで到達すると誤解",
                   explanation: "コンストラクタ呼び出し位置の制約に違反しているためコンパイルエラーです。"),
            Choice(id: "c", text: "this(1)の行でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "this(1)はコンストラクタの先頭に置く必要があります。System.out.printの後に書くことはできません。"),
            Choice(id: "d", text: "実行時にStackOverflowError",
                   correct: false, misconception: "コンストラクタ呼び出しが循環すると誤解",
                   explanation: "循環呼び出しではなく、先頭文ではないことが問題です。"),
        ],
        explanationRef: "explain-silver-classes-004",
        designIntent: "this(...)またはsuper(...)はコンストラクタの先頭文にしか書けないことを確認する。"
    )

    // MARK: - Silver: 継承 (static method hiding)

    static let silverInheritance002 = Quiz(
        id: "silver-inheritance-002",
        level: .silver,
        category: "inheritance",
        tags: ["static", "メソッド隠蔽", "継承"],
        code: """
class Parent {
    static void show() { System.out.println("Parent"); }
}

class Child extends Parent {
    static void show() { System.out.println("Child"); }
}

public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        p.show();
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "Parent",
                   correct: true, misconception: nil,
                   explanation: "staticメソッドはオーバーライドされず、参照型に基づいて解決されます。pの型はParentなのでParent.showが呼ばれます。"),
            Choice(id: "b", text: "Child",
                   correct: false, misconception: "staticメソッドも動的ディスパッチされると誤解",
                   explanation: "動的ディスパッチされるのはインスタンスメソッドです。staticメソッドは隠蔽です。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "インスタンス変数経由でstaticメソッドを呼べないと誤解",
                   explanation: "推奨はされませんが、参照変数経由でstaticメソッドを呼ぶことは構文上可能です。"),
            Choice(id: "d", text: "ClassCastException",
                   correct: false, misconception: nil,
                   explanation: "ChildはParentのサブクラスなので代入は安全です。"),
        ],
        explanationRef: "explain-silver-inheritance-002",
        designIntent: "staticメソッド隠蔽とインスタンスメソッドのオーバーライドの違いを確認する。"
    )

    // MARK: - Silver: 継承 (default method conflict)

    static let silverInheritance003 = Quiz(
        id: "silver-inheritance-003",
        level: .silver,
        category: "inheritance",
        tags: ["interface", "defaultメソッド", "継承衝突"],
        code: """
interface A {
    default void run() { System.out.println("A"); }
}

interface B {
    default void run() { System.out.println("B"); }
}

class C implements A, B {}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる",
                   correct: false, misconception: "どちらかのdefaultが自動選択されると誤解",
                   explanation: "同じシグネチャのdefaultメソッドを複数継承すると、実装クラス側で明示的に解決する必要があります。"),
            Choice(id: "b", text: "Cの宣言でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "AとBのrun()が衝突します。Cはrun()をオーバーライドして、どちらを使うかまたは独自実装を明示する必要があります。"),
            Choice(id: "c", text: "実行時にAmbiguousMethodException",
                   correct: false, misconception: "defaultメソッド衝突が実行時まで遅れると誤解",
                   explanation: "衝突はコンパイル時に検出されます。"),
            Choice(id: "d", text: "Bのrunが優先される",
                   correct: false, misconception: "後に書いたinterfaceが優先されると誤解",
                   explanation: "implementsの順序で優先順位は決まりません。"),
        ],
        explanationRef: "explain-silver-inheritance-003",
        designIntent: "複数interfaceから同じdefaultメソッドを継承した場合の解決ルールを確認する。"
    )

    // MARK: - Silver: 継承 (covariant return)

    static let silverInheritance004 = Quiz(
        id: "silver-inheritance-004",
        level: .silver,
        category: "inheritance",
        tags: ["オーバーライド", "共変戻り値", "ポリモーフィズム"],
        code: """
class Parent {
    Parent copy() { return new Parent(); }
}

class Child extends Parent {
    @Override
    Child copy() { return new Child(); }
}

public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        System.out.println(p.copy().getClass().getSimpleName());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "Parent",
                   correct: false, misconception: "参照型Parentのcopyが呼ばれると誤解",
                   explanation: "インスタンスメソッドは実体の型で動的に選ばれます。"),
            Choice(id: "b", text: "Child",
                   correct: true, misconception: nil,
                   explanation: "Child.copy()がオーバーライドされて呼ばれ、Childインスタンスを返します。戻り値型をサブタイプにする共変戻り値は有効です。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "戻り値型が完全一致でないとオーバーライドできないと誤解",
                   explanation: "戻り値型は親メソッドの戻り値型のサブタイプにできます。"),
            Choice(id: "d", text: "ClassCastException",
                   correct: false, misconception: nil,
                   explanation: "キャストを行っていないためClassCastExceptionは発生しません。"),
        ],
        explanationRef: "explain-silver-inheritance-004",
        designIntent: "共変戻り値と動的ディスパッチを組み合わせて理解しているか確認する。"
    )

    // MARK: - Silver: 例外処理 (catch order)

    static let silverException003 = Quiz(
        id: "silver-exception-003",
        level: .silver,
        category: "exception-handling",
        tags: ["catch", "到達不能", "例外階層"],
        code: """
public class Test {
    public static void main(String[] args) {
        try {
            System.out.println("try");
        } catch (Exception e) {
            System.out.println("Exception");
        } catch (RuntimeException e) {
            System.out.println("Runtime");
        }
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "tryと出力される",
                   correct: false, misconception: "catch順序のコンパイルチェックを見落とし",
                   explanation: "実行前に、後続のRuntimeException catchが到達不能としてコンパイルエラーになります。"),
            Choice(id: "b", text: "Exceptionと出力される",
                   correct: false, misconception: "例外がないのにcatchへ進むと誤解",
                   explanation: "try内で例外は発生していませんが、それ以前にcatch順序が不正です。"),
            Choice(id: "c", text: "RuntimeExceptionのcatchが到達不能でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "ExceptionはRuntimeExceptionの親クラスです。親を先にcatchすると、後ろの子クラスcatchに到達できません。"),
            Choice(id: "d", text: "実行時エラー",
                   correct: false, misconception: "到達不能catchが実行時に判定されると誤解",
                   explanation: "到達不能なcatch節はコンパイル時に検出されます。"),
        ],
        explanationRef: "explain-silver-exception-003",
        designIntent: "catch節はサブクラスから親クラスの順に書く必要があることを確認する。"
    )

    // MARK: - Silver: 例外処理 (catch finally)

    static let silverException004 = Quiz(
        id: "silver-exception-004",
        level: .silver,
        category: "exception-handling",
        tags: ["try-catch-finally", "実行順", "RuntimeException"],
        code: """
public class Test {
    public static void main(String[] args) {
        try {
            throw new RuntimeException();
        } catch (RuntimeException e) {
            System.out.print("C");
        } finally {
            System.out.print("F");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "C",
                   correct: false, misconception: "catch後にfinallyが実行されないと誤解",
                   explanation: "finallyはcatch処理の後にも実行されます。"),
            Choice(id: "b", text: "F",
                   correct: false, misconception: "catchが実行されないと誤解",
                   explanation: "RuntimeExceptionはcatchされるため、Cが先に出力されます。"),
            Choice(id: "c", text: "CF",
                   correct: true, misconception: nil,
                   explanation: "例外がcatchされてCを出力し、その後finallyが必ず実行されてFを出力します。"),
            Choice(id: "d", text: "FC",
                   correct: false, misconception: "finallyがcatchより先に実行されると誤解",
                   explanation: "例外が対応するcatchで処理され、その後finallyが実行されます。"),
        ],
        explanationRef: "explain-silver-exception-004",
        designIntent: "try-catch-finallyの基本的な実行順を確認する。"
    )

    // MARK: - Silver: ラムダ式 (Predicate.negate)

    static let silverLambda002 = Quiz(
        id: "silver-lambda-002",
        level: .silver,
        category: "lambda-streams",
        tags: ["Predicate", "negate", "ラムダ式"],
        code: """
import java.util.function.Predicate;

public class Test {
    public static void main(String[] args) {
        Predicate<String> p = s -> s.length() > 2;
        System.out.println(p.negate().test("Hi"));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "true",
                   correct: true, misconception: nil,
                   explanation: "\"Hi\"の長さは2なのでp.test(\"Hi\")はfalseです。negate()により結果が反転しtrueになります。"),
            Choice(id: "b", text: "false",
                   correct: false, misconception: "negateの反転を見落としている",
                   explanation: "元のPredicateはfalseですが、negate()で反転されます。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "Predicateにnegateがないと誤解",
                   explanation: "Predicateにはdefaultメソッドnegate()があります。"),
            Choice(id: "d", text: "NullPointerException",
                   correct: false, misconception: nil,
                   explanation: "nullは渡していないためNullPointerExceptionは発生しません。"),
        ],
        explanationRef: "explain-silver-lambda-002",
        designIntent: "Predicateのdefaultメソッドnegateとラムダ式の評価を確認する。"
    )

    // MARK: - Silver: ArrayList (add index)

    static let silverArrayList001 = Quiz(
        id: "silver-arraylist-001",
        level: .silver,
        category: "collections",
        tags: ["ArrayList", "add", "インデックス"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>();
        list.add("A");
        list.add(1, "B");
        System.out.println(list);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "[A, B]",
                   correct: true, misconception: nil,
                   explanation: "サイズ1のリストに対してadd(1, \"B\")は末尾追加として有効です。インデックスは0からsizeまで指定できます。"),
            Choice(id: "b", text: "[B, A]",
                   correct: false, misconception: "インデックス1が先頭だと誤解",
                   explanation: "インデックス0が先頭です。インデックス1はAの後ろです。"),
            Choice(id: "c", text: "IndexOutOfBoundsException",
                   correct: false, misconception: "add(index, element)でindex=sizeが不可と誤解",
                   explanation: "addではindexがsizeと等しい場合、末尾追加として有効です。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: nil,
                   explanation: "ArrayListとListの使い方として正しいコードです。"),
        ],
        explanationRef: "explain-silver-arraylist-001",
        designIntent: "ArrayList.add(index, element)で指定できるインデックス範囲を確認する。"
    )

    // MARK: - Silver: Javaの基本 (識別子)

    static let silverJavaBasics005 = Quiz(
        id: "silver-java-basics-005",
        level: .silver,
        category: "java-basics",
        tags: ["識別子", "_", "$"],
        code: """
public class Test {
    public static void main(String[] args) {
        int _score = 10;
        int $bonus = 5;
        System.out.println(_score + $bonus);
    }
}
""",
        question: "このコードをコンパイルおよび実行したときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "15",
                   correct: true, misconception: nil,
                   explanation: "_scoreや$bonusは識別子として有効です。10 + 5で15が出力されます。"),
            Choice(id: "b", text: "_scoreが不正な識別子なのでコンパイルエラー",
                   correct: false, misconception: "アンダースコアを含む識別子がすべて禁止だと誤解",
                   explanation: "単独の_はJava 9以降で識別子にできませんが、_scoreのように他の文字と組み合わせることはできます。"),
            Choice(id: "c", text: "$bonusが不正な識別子なのでコンパイルエラー",
                   correct: false, misconception: "$を識別子に使えないと誤解",
                   explanation: "$は識別子に使えます。ただし通常のアプリケーションコードでは多用しません。"),
            Choice(id: "d", text: "実行時にIllegalArgumentException",
                   correct: false, misconception: nil,
                   explanation: "識別子の妥当性はコンパイル時に扱われます。このコードは正常に実行されます。"),
        ],
        explanationRef: "explain-silver-java-basics-005",
        designIntent: "Javaの識別子に使える文字と、単独アンダースコアの例外を区別できるか確認する。"
    )

    // MARK: - Silver: データ型 (整数除算と浮動小数点)

    static let silverDataTypes006 = Quiz(
        id: "silver-data-types-006",
        level: .silver,
        category: "data-types",
        tags: ["数値昇格", "double", "除算"],
        code: """
public class Test {
    public static void main(String[] args) {
        int a = 5;
        double b = 2;
        System.out.println(a / b);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2",
                   correct: false, misconception: "int同士の除算として扱われると誤解",
                   explanation: "右辺にdouble型のbがあるため、doubleの除算になります。"),
            Choice(id: "b", text: "2.0",
                   correct: false, misconception: "先に整数除算してからdoubleになると誤解",
                   explanation: "5 / 2を整数除算してからdoubleにするのではなく、5.0 / 2.0として評価されます。"),
            Choice(id: "c", text: "2.5",
                   correct: true, misconception: nil,
                   explanation: "intのaはdoubleへ昇格し、double同士の除算として2.5が出力されます。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "intとdoubleを一緒に演算できないと誤解",
                   explanation: "数値昇格により、intはdoubleへ変換されます。"),
        ],
        explanationRef: "explain-silver-data-types-006",
        designIntent: "片方がdoubleの場合、整数除算ではなく浮動小数点除算になることを確認する。"
    )

    // MARK: - Silver: データ型 (縮小変換)

    static let silverDataTypes007 = Quiz(
        id: "silver-data-types-007",
        level: .silver,
        category: "data-types",
        tags: ["long", "int", "縮小変換"],
        code: """
public class Test {
    public static void main(String[] args) {
        long x = 10;
        int y = x;
        System.out.println(y);
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "10と出力される",
                   correct: false, misconception: "値が小さければ暗黙変換できると誤解",
                   explanation: "変数xの型はlongです。値が10でも、longからintへの暗黙代入はできません。"),
            Choice(id: "b", text: "0と出力される",
                   correct: false, misconception: "変換できない値が初期値になると誤解",
                   explanation: "型不一致はコンパイルエラーであり、初期値に置き換わることはありません。"),
            Choice(id: "c", text: "int y = x; の行でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "longからintは縮小変換です。明示キャストがないためコンパイルエラーになります。"),
            Choice(id: "d", text: "実行時にClassCastException",
                   correct: false, misconception: "プリミティブ変換を参照型キャストと混同",
                   explanation: "プリミティブ型の代入互換性はコンパイル時に判定されます。"),
        ],
        explanationRef: "explain-silver-data-types-007",
        designIntent: "値ではなく式の型に基づいて代入可能性が判断されることを確認する。"
    )

    // MARK: - Silver: データ型 (ローカル変数初期化)

    static let silverDataTypes008 = Quiz(
        id: "silver-data-types-008",
        level: .silver,
        category: "data-types",
        tags: ["ローカル変数", "初期化", "コンパイルエラー"],
        code: """
public class Test {
    public static void main(String[] args) {
        int x;
        if (args.length > 0) {
            x = 1;
        }
        System.out.println(x);
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "0と出力される",
                   correct: false, misconception: "ローカル変数にもデフォルト値があると誤解",
                   explanation: "フィールドにはデフォルト値がありますが、ローカル変数は使用前に明示的な初期化が必要です。"),
            Choice(id: "b", text: "1と出力される",
                   correct: false, misconception: "if文が必ず実行されると誤解",
                   explanation: "args.lengthが0の場合、xは代入されません。コンパイラはその経路を考慮します。"),
            Choice(id: "c", text: "System.out.println(x); の行でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "xが初期化されない可能性があるため、ローカル変数を読み出す行でコンパイルエラーになります。"),
            Choice(id: "d", text: "実行時にNullPointerException",
                   correct: false, misconception: nil,
                   explanation: "intはプリミティブ型でnullにはなりません。問題は未初期化のローカル変数です。"),
        ],
        explanationRef: "explain-silver-data-types-008",
        designIntent: "フィールドのデフォルト値とローカル変数の初期化ルールを区別できるか確認する。"
    )

    // MARK: - Silver: String (replace)

    static let silverString004 = Quiz(
        id: "silver-string-004",
        level: .silver,
        category: "string",
        tags: ["String", "replace", "不変"],
        code: """
public class Test {
    public static void main(String[] args) {
        String s = "banana";
        s.replace('a', 'o');
        System.out.println(s);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "bonono",
                   correct: false, misconception: "replaceが元のStringを変更すると誤解",
                   explanation: "Stringは不変です。replaceは新しいStringを返しますが、戻り値を代入していません。"),
            Choice(id: "b", text: "banana",
                   correct: true, misconception: nil,
                   explanation: "s.replace('a', 'o')の戻り値を使っていないため、sは元のbananaのままです。"),
            Choice(id: "c", text: "bonana",
                   correct: false, misconception: "最初の1文字だけ置換されると誤解",
                   explanation: "replace自体は一致する文字をすべて置換しますが、このコードでは戻り値を捨てています。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "char引数のreplaceが存在しないと誤解",
                   explanation: "replace(char oldChar, char newChar)は有効なメソッドです。"),
        ],
        explanationRef: "explain-silver-string-004",
        designIntent: "Stringの不変性と、戻り値を代入しないメソッド呼び出しの結果を確認する。"
    )

    // MARK: - Silver: StringBuilder (insert/deleteCharAt)

    static let silverStringBuilder003 = Quiz(
        id: "silver-stringbuilder-003",
        level: .silver,
        category: "string",
        tags: ["StringBuilder", "insert", "deleteCharAt"],
        code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("abc");
        sb.insert(1, "X").deleteCharAt(3);
        System.out.println(sb);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "aXb",
                   correct: true, misconception: nil,
                   explanation: "insert(1, \"X\")でaXbcになり、deleteCharAt(3)でインデックス3のcが削除されます。"),
            Choice(id: "b", text: "aXbc",
                   correct: false, misconception: "deleteCharAtの効果を見落としている",
                   explanation: "deleteCharAt(3)が続けて呼ばれているため、cが削除されます。"),
            Choice(id: "c", text: "Xabc",
                   correct: false, misconception: "insertのインデックス1を先頭と誤解",
                   explanation: "インデックス0が先頭です。インデックス1はaの後ろです。"),
            Choice(id: "d", text: "StringIndexOutOfBoundsException",
                   correct: false, misconception: "deleteCharAt(3)が範囲外だと誤解",
                   explanation: "aXbcの長さは4なので、インデックス3は有効です。"),
        ],
        explanationRef: "explain-silver-stringbuilder-003",
        designIntent: "StringBuilderの変更後インデックスとメソッドチェーンを追跡できるか確認する。"
    )

    // MARK: - Silver: 配列 (参照共有)

    static let silverArray004 = Quiz(
        id: "silver-array-004",
        level: .silver,
        category: "data-types",
        tags: ["配列", "参照", "代入"],
        code: """
public class Test {
    public static void main(String[] args) {
        int[] a = {1, 2};
        int[] b = a;
        b[0] = 9;
        System.out.println(a[0]);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1",
                   correct: false, misconception: "配列代入でコピーが作られると誤解",
                   explanation: "配列変数の代入は参照のコピーです。配列本体は共有されます。"),
            Choice(id: "b", text: "9",
                   correct: true, misconception: nil,
                   explanation: "aとbは同じ配列を参照しています。b[0]の変更はa[0]からも見えます。"),
            Choice(id: "c", text: "0",
                   correct: false, misconception: "配列要素が初期値に戻ると誤解",
                   explanation: "明示的に初期化した配列要素は、代入によって0には戻りません。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "配列参照の代入ができないと誤解",
                   explanation: "同じint[]型同士なので代入できます。"),
        ],
        explanationRef: "explain-silver-array-004",
        designIntent: "配列変数の代入が浅い参照コピーであることを確認する。"
    )

    // MARK: - Silver: 配列 (参照型配列の初期値)

    static let silverArray005 = Quiz(
        id: "silver-array-005",
        level: .silver,
        category: "data-types",
        tags: ["配列", "参照型", "初期値"],
        code: """
public class Test {
    public static void main(String[] args) {
        String[] values = new String[2];
        System.out.println(values[0]);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "null",
                   correct: true, misconception: nil,
                   explanation: "参照型配列の各要素は初期値nullになります。printlnはnull参照を文字列nullとして出力します。"),
            Choice(id: "b", text: "空文字",
                   correct: false, misconception: "String配列の初期値が\"\"だと誤解",
                   explanation: "Stringも参照型です。配列要素の初期値は空文字ではなくnullです。"),
            Choice(id: "c", text: "ArrayIndexOutOfBoundsException",
                   correct: false, misconception: "インデックス0が範囲外だと誤解",
                   explanation: "長さ2の配列ではインデックス0は有効です。"),
            Choice(id: "d", text: "NullPointerException",
                   correct: false, misconception: "nullをprintlnすると例外になると誤解",
                   explanation: "null参照そのものをprintlnに渡すだけならNullPointerExceptionにはなりません。"),
        ],
        explanationRef: "explain-silver-array-005",
        designIntent: "参照型配列の初期値と、println(null)の扱いを確認する。"
    )

    // MARK: - Silver: コレクション (Arrays.asList)

    static let silverCollections004 = Quiz(
        id: "silver-collections-004",
        level: .silver,
        category: "collections",
        tags: ["Arrays.asList", "固定サイズリスト", "set"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> list = Arrays.asList("A", "B");
        list.set(1, "C");
        System.out.println(list);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "[A, B]",
                   correct: false, misconception: "setが無視されると誤解",
                   explanation: "Arrays.asListのリストはサイズ変更できませんが、既存要素の置換は可能です。"),
            Choice(id: "b", text: "[A, C]",
                   correct: true, misconception: nil,
                   explanation: "setは既存要素の置換なので有効です。インデックス1のBがCに置き換わります。"),
            Choice(id: "c", text: "UnsupportedOperationException",
                   correct: false, misconception: "Arrays.asListではsetも禁止だと誤解",
                   explanation: "add/removeのようなサイズ変更は不可ですが、setは可能です。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: nil,
                   explanation: "Arrays.asListとList.setの使い方として正しいコードです。"),
        ],
        explanationRef: "explain-silver-collections-004",
        designIntent: "Arrays.asListで得た固定サイズリストの、setとadd/removeの違いを確認する。"
    )

    // MARK: - Silver: コレクション (ArrayListとnull)

    static let silverCollections005 = Quiz(
        id: "silver-collections-005",
        level: .silver,
        category: "collections",
        tags: ["ArrayList", "null", "size"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>();
        list.add(null);
        list.add("A");
        System.out.println(list.size());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1",
                   correct: false, misconception: "null要素は追加されないと誤解",
                   explanation: "ArrayListはnull要素を保持できます。nullも1要素として数えます。"),
            Choice(id: "b", text: "2",
                   correct: true, misconception: nil,
                   explanation: "nullと\"A\"の2要素が追加されるため、sizeは2です。"),
            Choice(id: "c", text: "NullPointerException",
                   correct: false, misconception: "ArrayList.add(null)が例外になると誤解",
                   explanation: "ArrayListはnullを許容します。List.ofはnull不可なので混同に注意します。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: nil,
                   explanation: "String型のリストにもnullは代入可能です。"),
        ],
        explanationRef: "explain-silver-collections-005",
        designIntent: "ArrayListのnull許容とList.ofのnull禁止を混同しないか確認する。"
    )

    // MARK: - Silver: 制御構文 (continue)

    static let silverControlFlow006 = Quiz(
        id: "silver-control-flow-006",
        level: .silver,
        category: "control-flow",
        tags: ["continue", "for", "ループ"],
        code: """
public class Test {
    public static void main(String[] args) {
        for (int i = 0; i < 4; i++) {
            if (i == 2) continue;
            System.out.print(i);
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "0123",
                   correct: false, misconception: "continueを無視している",
                   explanation: "iが2のときはcontinueにより出力処理がスキップされます。"),
            Choice(id: "b", text: "013",
                   correct: true, misconception: nil,
                   explanation: "0と1は出力され、2はcontinueでスキップされ、3は出力されます。"),
            Choice(id: "c", text: "01",
                   correct: false, misconception: "continueでループ全体が終了すると誤解",
                   explanation: "continueは現在の反復をスキップするだけで、ループ自体は続きます。"),
            Choice(id: "d", text: "23",
                   correct: false, misconception: "条件成立後だけ出力されると誤解",
                   explanation: "ifの条件が成立した2は出力されません。"),
        ],
        explanationRef: "explain-silver-control-flow-006",
        designIntent: "continueが現在の反復だけをスキップすることを確認する。"
    )

    // MARK: - Silver: 制御構文 (switch fall-through)

    static let silverControlFlow007 = Quiz(
        id: "silver-control-flow-007",
        level: .silver,
        category: "control-flow",
        tags: ["switch", "case", "フォールスルー"],
        code: """
public class Test {
    public static void main(String[] args) {
        int x = 1;
        switch (x) {
            case 0: System.out.print("A");
            case 1: System.out.print("B");
            default: System.out.print("C");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "A",
                   correct: false, misconception: "case 0から始まると誤解",
                   explanation: "xは1なのでcase 1から開始します。"),
            Choice(id: "b", text: "B",
                   correct: false, misconception: "case一致後に自動的にbreakされると誤解",
                   explanation: "従来のswitch文ではbreakがなければ後続ラベルへフォールスルーします。"),
            Choice(id: "c", text: "BC",
                   correct: true, misconception: nil,
                   explanation: "case 1でBを出力し、breakがないためdefaultに流れてCも出力します。"),
            Choice(id: "d", text: "ABC",
                   correct: false, misconception: "先頭caseから順に評価されると誤解",
                   explanation: "実行開始位置は一致したcaseです。case 0の処理は実行されません。"),
        ],
        explanationRef: "explain-silver-control-flow-007",
        designIntent: "switch文で一致したcaseから後続へフォールスルーする流れを確認する。"
    )

    // MARK: - Silver: オーバーロード (widening vs boxing)

    static let silverOverload004 = Quiz(
        id: "silver-overload-004",
        level: .silver,
        category: "overload-resolution",
        tags: ["オーバーロード", "拡大変換", "ボクシング"],
        code: """
public class Test {
    static void call(long x) {
        System.out.println("long");
    }

    static void call(Integer x) {
        System.out.println("Integer");
    }

    public static void main(String[] args) {
        call(1);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "long",
                   correct: true, misconception: nil,
                   explanation: "intリテラル1に対して、拡大変換int->longはボクシングint->Integerより優先されます。"),
            Choice(id: "b", text: "Integer",
                   correct: false, misconception: "ラッパークラスへの変換が優先されると誤解",
                   explanation: "オーバーロード解決では、拡大変換はボクシングより優先されます。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "longとIntegerで曖昧になると誤解",
                   explanation: "優先順位によりcall(long)が選ばれるため曖昧ではありません。"),
            Choice(id: "d", text: "実行時エラー",
                   correct: false, misconception: nil,
                   explanation: "呼び出すメソッドはコンパイル時に決定されます。"),
        ],
        explanationRef: "explain-silver-overload-004",
        designIntent: "オーバーロード解決で拡大変換がボクシングより優先されることを確認する。"
    )

    // MARK: - Silver: クラス (参照の値渡し)

    static let silverClasses005 = Quiz(
        id: "silver-classes-005",
        level: .silver,
        category: "classes",
        tags: ["参照", "値渡し", "StringBuilder"],
        code: """
public class Test {
    static void change(StringBuilder sb) {
        sb.append("B");
        sb = new StringBuilder("C");
    }

    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder("A");
        change(sb);
        System.out.println(sb);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "A",
                   correct: false, misconception: "メソッド内のappendが呼び出し元へ影響しないと誤解",
                   explanation: "同じStringBuilderオブジェクトに対するappendは呼び出し元からも見えます。"),
            Choice(id: "b", text: "AB",
                   correct: true, misconception: nil,
                   explanation: "参照値は値渡しです。appendは同じオブジェクトを変更しますが、sbへの再代入は呼び出し元の変数を変えません。"),
            Choice(id: "c", text: "C",
                   correct: false, misconception: "メソッド内の再代入が呼び出し元にも反映されると誤解",
                   explanation: "change内のsbは仮引数です。new StringBuilder(\"C\")への再代入は呼び出し元のsbには影響しません。"),
            Choice(id: "d", text: "ABC",
                   correct: false, misconception: "再代入後も元のオブジェクトへ追記されると誤解",
                   explanation: "再代入後の新しいStringBuilderは呼び出し元から参照されていません。"),
        ],
        explanationRef: "explain-silver-classes-005",
        designIntent: "Javaは参照そのものを値渡しするため、オブジェクト変更と仮引数再代入の違いが出ることを確認する。"
    )

    // MARK: - Silver: 継承 (フィールド隠蔽)

    static let silverInheritance005 = Quiz(
        id: "silver-inheritance-005",
        level: .silver,
        category: "inheritance",
        tags: ["フィールド", "隠蔽", "参照型"],
        code: """
class Parent {
    String name = "P";
}

class Child extends Parent {
    String name = "C";
}

public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        System.out.println(p.name);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "P",
                   correct: true, misconception: nil,
                   explanation: "フィールドはオーバーライドされません。参照型Parentに基づいてParent.nameが参照されます。"),
            Choice(id: "b", text: "C",
                   correct: false, misconception: "フィールドも動的ディスパッチされると誤解",
                   explanation: "動的ディスパッチされるのはインスタンスメソッドです。フィールドは参照型で決まります。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: false, misconception: "同名フィールドをサブクラスで宣言できないと誤解",
                   explanation: "サブクラスで同名フィールドを宣言するとフィールド隠蔽になります。"),
            Choice(id: "d", text: "ClassCastException",
                   correct: false, misconception: nil,
                   explanation: "ChildインスタンスはParent型の変数へ代入できます。"),
        ],
        explanationRef: "explain-silver-inheritance-005",
        designIntent: "フィールド隠蔽とメソッドオーバーライドの違いを確認する。"
    )

    // MARK: - Silver: 継承 (throwsとオーバーライド)

    static let silverInheritance006 = Quiz(
        id: "silver-inheritance-006",
        level: .silver,
        category: "inheritance",
        tags: ["オーバーライド", "throws", "チェック例外"],
        code: """
class Parent {
    void run() throws java.io.IOException {}
}

class Child extends Parent {
    @Override
    void run() throws Exception {}
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる",
                   correct: false, misconception: "throwsは自由に広げられると誤解",
                   explanation: "オーバーライド時に、チェック例外を親メソッドより広い型へ広げることはできません。"),
            Choice(id: "b", text: "Child.run()のthrows Exceptionでコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "ExceptionはIOExceptionより広いチェック例外です。オーバーライドでは同じ型か、より狭い型にする必要があります。"),
            Choice(id: "c", text: "@Overrideを消せば正常にコンパイルできる",
                   correct: false, misconception: "@Overrideだけが問題だと誤解",
                   explanation: "@Overrideを消しても、同じシグネチャのメソッドなのでオーバーライド規則に違反します。"),
            Choice(id: "d", text: "実行時にIOException",
                   correct: false, misconception: "throws違反が実行時に判定されると誤解",
                   explanation: "throws句の互換性はコンパイル時にチェックされます。"),
        ],
        explanationRef: "explain-silver-inheritance-006",
        designIntent: "オーバーライド時のthrows句ではチェック例外を広げられないことを確認する。"
    )

    // MARK: - Silver: 例外処理 (finallyとreturn)

    static let silverException005 = Quiz(
        id: "silver-exception-005",
        level: .silver,
        category: "exception-handling",
        tags: ["finally", "return", "実行順"],
        code: """
public class Test {
    static int get() {
        try {
            return 1;
        } finally {
            return 2;
        }
    }

    public static void main(String[] args) {
        System.out.println(get());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1",
                   correct: false, misconception: "tryのreturnでfinallyが無視されると誤解",
                   explanation: "returnの前にもfinallyは実行されます。finally内のreturnが最終結果になります。"),
            Choice(id: "b", text: "2",
                   correct: true, misconception: nil,
                   explanation: "tryでreturn 1が準備されますが、finallyが実行され、そのreturn 2が戻り値を上書きします。"),
            Choice(id: "c", text: "12",
                   correct: false, misconception: "両方のreturn値が出力されると誤解",
                   explanation: "returnは1つの値を返します。printlnされるのは最終的な戻り値だけです。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "finally内でreturnできないと誤解",
                   explanation: "finally内のreturnは構文上可能です。ただし例外や戻り値を隠すため実務では避けます。"),
        ],
        explanationRef: "explain-silver-exception-005",
        designIntent: "finallyがreturn前にも実行され、finally内returnが戻り値を上書きすることを確認する。"
    )

    // MARK: - Silver: ラムダ式 (effectively final)

    static let silverLambda003 = Quiz(
        id: "silver-lambda-003",
        level: .silver,
        category: "lambda-streams",
        tags: ["ラムダ式", "effectively final", "ローカル変数"],
        code: """
import java.util.function.Predicate;

public class Test {
    public static void main(String[] args) {
        int base = 1;
        Predicate<Integer> p = x -> x > base;
        base++;
        System.out.println(p.test(2));
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "trueと出力される",
                   correct: false, misconception: "ラムダが変更後のbaseを参照できると誤解",
                   explanation: "ラムダ式から参照するローカル変数はfinalまたはeffectively finalである必要があります。"),
            Choice(id: "b", text: "falseと出力される",
                   correct: false, misconception: "base++後の値で評価されると誤解",
                   explanation: "baseが後で変更されるため、そもそもラムダ式から参照できません。"),
            Choice(id: "c", text: "baseをラムダ式から参照する部分でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "base++によりbaseはeffectively finalではありません。ラムダ式から参照できずコンパイルエラーになります。"),
            Choice(id: "d", text: "実行時にIllegalStateException",
                   correct: false, misconception: "effectively final違反が実行時に判定されると誤解",
                   explanation: "ラムダ式のローカル変数キャプチャ規則はコンパイル時に判定されます。"),
        ],
        explanationRef: "explain-silver-lambda-003",
        designIntent: "ラムダ式から参照するローカル変数はfinalまたはeffectively finalでなければならないことを確認する。"
    )
}
