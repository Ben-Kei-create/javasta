import Foundation

extension Quiz {
    static let samples: [Quiz] = [
        silverOverload001,
        silverException001,
        silverExceptionFinally001,
        silverString001,
        silverStringPool001,
        silverAutoboxing001,
        silverSwitch001,
        silverControlFlow001,
        silverControlFlow002,
        silverOverload002,
        silverOverloadVarargs001,
        silverArrayDefaults001,
        silverInheritance001,
        silverInheritanceException001,
        silverMultiFileOverride001,
        silverConstructor001,
        silverConstructorChain001,
        silverStringBuilder001,
        silverException002,
        silverCollections001,
        silverJavaBasics001,
        silverClasses002,
        silverLambda001,
        silverDataTypes002,
        silverDataTypesPassByValue,
        goldGenerics001,
        goldGenerics002,
        goldGenerics003,
        goldGenericsErasure001,
        goldLambdaEffectivelyFinal001,
        goldStream001,
        goldStream002,
        goldStream003,
        goldStream004,
        goldStream005,
        goldStreamLazy001,
        goldOptional001,
        goldOptional002,
        goldOptional003,
        goldClasses001,
        goldClasses002,
        goldDateTime001,
        goldCollections001,
        goldConcurrency001,
        goldConcurrency002,
        goldConcurrency003,
        goldConcurrency004,
        goldIo001,
        goldPathNormalize001,
        goldIo002,
        goldModule001,
        goldModule002,
        goldLocalization001,
        goldLocalization002,
        goldAnnotations001,
        goldJdbc001,
        goldJdbc002,
        silverJavaBasics002,
        silverArray002,
        silverPolymorphism001,
    ] + goldExpansion
    
    
    
    // MARK: - Gold: ラムダ式とEffectively Final
        static let goldLambdaEffectivelyFinal001 = Quiz(
            id: "gold-lambda-effectively-final-001",
            level: .gold,
            category: "lambda-streams",
            tags: ["ラムダ式", "effectively final", "スコープ"],
            code: """
    public class Test {
        public static void main(String[] args) {
            int count = 0;
            Runnable r = () -> {
                // System.out.println(count); // コメントを外すと？
            };
            count++;
            r.run();
        }
    }
    """,
            question: "コメントアウトされている行を有効にした場合、このコードはどうなるか？",
            choices: [
                Choice(id: "a", text: "正常にコンパイルでき、1を出力する", correct: false, misconception: "実行時の値が参照されると誤解", explanation: "ラムダ式内で参照するローカル変数は、変更されてはいけません。"),
                Choice(id: "b", text: "コンパイルエラーになる", correct: true, misconception: nil, explanation: "ラムダ式から参照されるローカル変数は、final または『実質的に final（effectively final）』である必要があります。このコードでは変数countが後でインクリメントされているため、条件を満たしません。"),
                Choice(id: "c", text: "正常にコンパイルでき、0を出力する", correct: false, misconception: nil, explanation: "Javaのラムダは変数の値をコピーして保持するわけではなく、アクセス制限（final制約）を設けることで整合性を保っています。"),
                Choice(id: "d", text: "実行時に例外が発生する", correct: false, misconception: nil, explanation: "実行時ではなく、コンパイル時に変数の書き換えが検知されます。")
            ],
            explanationRef: "explain-gold-lambda-effectively-final-001",
            designIntent: "ラムダ式が「外部の変数を閉じ込める（キャプチャする）」際の制約と、メモリ上での変数の扱われ方を理解させる。"
        )

        // MARK: - Silver: オーバーライドと例外の投げ分け
        static let silverInheritanceException001 = Quiz(
            id: "silver-inheritance-exception-001",
            level: .silver,
            category: "inheritance",
            tags: ["継承", "オーバーライド", "チェック例外"],
            code: """
    import java.io.*;

    class Super {
        void display() throws IOException { System.out.print("Super "); }
    }
    class Sub extends Super {
        @Override
        void display() { System.out.print("Sub "); }
    }
    public class Test {
        public static void main(String[] args) throws IOException {
            Super s = new Sub();
            s.display();
        }
    }
    """,
            question: "このコードを実行したとき、出力される結果はどれか？",
            choices: [
                Choice(id: "a", text: "Sub", correct: true, misconception: nil, explanation: "オーバーライドする側は、親クラスが投げる例外よりも『狭い』例外を投げるか、あるいは例外を投げないように定義することができます。"),
                Choice(id: "b", text: "Super", correct: false, misconception: nil, explanation: "インスタンスメソッドは動的束縛されるため、Subのメソッドが呼ばれます。"),
                Choice(id: "c", text: "コンパイルエラー（Sub側でthrows IOExceptionが必要）", correct: false, misconception: "親と同じ例外を宣言しなればならないと誤解", explanation: "例外を減らす方向のオーバーライドは許可されています。"),
                Choice(id: "d", text: "コンパイルエラー（mainでcatchが必要）", correct: false, misconception: nil, explanation: "mainメソッドに throws IOException があるため、コンパイルは通ります。")
            ],
            explanationRef: "explain-silver-inheritance-exception-001",
            designIntent: "オーバーライドにおける「メソッドシグネチャ」の制約、特に例外の範囲が「親より広くなってはいけない」というルールを、型の階層構造と合わせて理解させる。"
        )
    
    
    
    
    
    
    
    
    
    
    // MARK: - Gold: Stream APIの遅延評価と中間操作の罠
        static let goldStreamLazy001 = Quiz(
            id: "gold-stream-lazy-001",
            level: .gold,
            category: "lambda-streams",
            tags: ["Stream API", "遅延評価", "中間操作", "終端操作"],
            code: """
    import java.util.stream.*;
    import java.util.*;

    public class Test {
        public static void main(String[] args) {
            List<String> list = new ArrayList<>(Arrays.asList("A", "B"));
            Stream<String> stream = list.stream()
                .filter(s -> {
                    System.out.print(s + " ");
                    return true;
                });
                
            list.add("C");
            System.out.print("Size: " + stream.count());
        }
    }
    """,
            question: "このコードを実行したとき、出力される結果はどれか？",
            choices: [
                Choice(id: "a", text: "A B Size: 2", correct: false, misconception: "Stream生成時にデータが決まると誤解", explanation: "Streamは終端操作(count)が呼ばれた瞬間にソース(list)を見に行きます。"),
                Choice(id: "b", text: "A B C Size: 3", correct: true, misconception: nil, explanation: "filterなどの「中間操作」は終端操作が呼ばれるまで実行されません。終端操作(count)が呼ばれた時点でのリストの状態（Cが追加された後）が反映され、すべての要素がfilterを通ります。"),
                Choice(id: "c", text: "Size: 3", correct: false, misconception: "filter内の出力が行われないと誤解", explanation: "count()は終端操作なので、パイプラインが実行され、中のprintも動作します。"),
                Choice(id: "d", text: "実行時例外 (ConcurrentModificationException)", correct: false, misconception: "Stream操作中のリスト変更は常に例外になると誤解", explanation: "終端操作が始まる「前」にリストを変更するのは安全です。操作中に変更すると例外になります。")
            ],
            explanationRef: "explain-gold-stream-lazy-001",
            designIntent: "「中間操作は組み立てるだけで、終端操作の瞬間に動き出す」という遅延評価の本質を、実行順序を追うことで理解させる。"
        )

        // MARK: - Gold: Genericsの型消去とシグネチャ衝突
        static let goldGenericsErasure001 = Quiz(
            id: "gold-generics-erasure-001",
            level: .gold,
            category: "generics",
            tags: ["ジェネリクス", "型消去", "オーバーロード"],
            code: """
    import java.util.*;

    public class Test {
        // A: List<String>を受け取る
        public void print(List<String> list) {
            System.out.println("Strings");
        }

        // B: List<Integer>を受け取る
        // public void print(List<Integer> list) {
        //     System.out.println("Integers");
        // }

        public static void main(String[] args) {
            new Test().print(Arrays.asList("a", "b"));
        }
    }
    """,
            question: "コメントアウトされている『B』のメソッドを有効にした場合、このクラスはどうなるか？",
            choices: [
                Choice(id: "a", text: "正常にコンパイルでき、オーバーロードとして機能する", correct: false, misconception: "型引数が違えば別メソッドだと誤解", explanation: "Javaのジェネリクスはコンパイル後に型情報が消去されます。"),
                Choice(id: "b", text: "コンパイルエラーになる", correct: true, misconception: nil, explanation: "型消去（Type Erasure）により、両方のメソッドはコンパイル後に `print(List list)` という同じシグネチャになってしまいます。そのため、オーバーロードが成立せず衝突します。"),
                Choice(id: "c", text: "実行時に ClassCastException が発生する", correct: false, misconception: nil, explanation: "実行時ではなく、コンパイル時点で重複定義としてエラーになります。"),
                Choice(id: "d", text: "コンパイルは通るが、呼び出し時に曖昧さでエラーになる", correct: false, misconception: nil, explanation: "定義自体の時点でエラーになります。")
            ],
            explanationRef: "explain-gold-generics-erasure-001",
            designIntent: "コンパイル時と実行時で「型」がどう変化するか、Java特有の『型消去』の仕組みを理解させる。"
        )
    
    
    // MARK: - Silver: コンストラクタ・チェーンと実行順序
        static let silverConstructorChain001 = Quiz(
            id: "silver-constructor-chain-001",
            level: .silver,
            category: "classes",
            tags: ["コンストラクタ", "継承", "super"],
            code: """
    class A {
        A() { System.out.print("A "); }
    }
    class B extends A {
        B() { 
            this("n");
            System.out.print("B1 "); 
        }
        B(String s) { 
            System.out.print("B2 "); 
        }
    }
    public class Test {
        public static void main(String[] args) {
            new B();
        }
    }
    """,
            question: "このコードを実行したとき、出力される結果はどれか？",
            choices: [
                Choice(id: "a", text: "A B1 B2", correct: false, misconception: "this()の呼び出し順を誤解", explanation: "B()からthis()を呼ぶと、まずB(String)に飛びますが、その前に親クラスAのコンストラクタが動きます。"),
                Choice(id: "b", text: "B2 B1 A", correct: false, misconception: "親クラスが後に実行されると誤解", explanation: "親クラスのコンストラクタは常に子クラスの処理より先に完了します。"),
                Choice(id: "c", text: "A B2 B1", correct: true, misconception: nil, explanation: "new B() -> B() -> this()によりB(String)へ -> B(String)の先頭で暗黙のsuper()が呼ばれA()実行 -> B(String)の残りを実行(B2) -> B()に戻り残りを実行(B1) という順序です。"),
                Choice(id: "d", text: "A B1", correct: false, misconception: "this()で飛んだ先の処理が無視されると誤解", explanation: "this()で呼び出したコンストラクタもすべて実行されます。")
            ],
            explanationRef: "explain-silver-constructor-chain-001",
            designIntent: "「まず親から」という原則と、this()による同一クラス内での連鎖がどう組み合わさるかをスタックの変化で理解させる。"
        )

        // MARK: - Silver: オーバーロードと可変長引数の優先順位
        static let silverOverloadVarargs001 = Quiz(
            id: "silver-overload-varargs-001",
            level: .silver,
            category: "overload-resolution",
            tags: ["オーバーロード", "可変長引数", "型昇格"],
            code: """
    public class Test {
        static void m(int... x) { System.out.print("A "); }
        static void m(long x)   { System.out.print("B "); }
        static void m(Integer x){ System.out.print("C "); }

        public static void main(String[] args) {
            int n = 5;
            m(n);
        }
    }
    """,
            question: "このコードを実行したとき、出力される結果はどれか？",
            choices: [
                Choice(id: "a", text: "A", correct: false, misconception: "可変長引数が優先されると誤解", explanation: "可変長引数は、他のどの候補にも一致しない場合の「最後の手段」です。"),
                Choice(id: "b", text: "B", correct: true, misconception: nil, explanation: "Javaのオーバーロード解決優先順位は、1.完全一致 2.型昇格(Widening) 3.ボクシング 4.可変長引数 です。intからlongへの型昇格が優先されます。"),
                Choice(id: "c", text: "C", correct: false, misconception: "ボクシングが型昇格より優先されると誤解", explanation: "ボクシング(Integer)よりも型昇格(long)の方が優先度が高いです。"),
                Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "曖昧な呼び出しになると誤解", explanation: "優先順位が明確に定義されているため、コンパイル可能です。")
            ],
            explanationRef: "explain-silver-overload-varargs-001",
            designIntent: "「完全一致がないとき、次にJavaがどこを探しに行くか」という優先順位のルールを確実に覚えさせる。"
        )
    // MARK: - Silver: ポリモーフィズムと静的束縛の罠
        static let silverPolymorphism001 = Quiz(
            id: "silver-polymorphism-001",
            level: .silver,
            category: "inheritance",
            tags: ["ポリモーフィズム", "静的束縛", "動的束縛", "フィールド"],
            code: """
    class Parent {
        int x = 10;
        static void print() { System.out.print("P1 "); }
        void show() { System.out.print("P2 "); }
    }
    class Child extends Parent {
        int x = 20;
        static void print() { System.out.print("C1 "); }
        void show() { System.out.print("C2 "); }
    }
    public class Test {
        public static void main(String[] args) {
            Parent p = new Child();
            System.out.print(p.x + " ");
            p.print();
            p.show();
        }
    }
    """,
            question: "このコードを実行したとき、出力される結果はどれか？",
            choices: [
                Choice(id: "a", text: "10 P1 P2", correct: false, misconception: "すべてParentクラスのものが呼ばれると誤解", explanation: "インスタンスメソッドのshow()は、実体であるChildのものが呼ばれます。"),
                Choice(id: "b", text: "20 C1 C2", correct: false, misconception: "すべてChildクラスのものが呼ばれると誤解", explanation: "フィールドとstaticメソッドは、変数の型(Parent)に依存します。"),
                Choice(id: "c", text: "10 P1 C2", correct: true, misconception: nil, explanation: "変数の型がParent、実体がChildです。フィールド(x)とstaticメソッド(print)は変数の型(Parent)で決まりますが、インスタンスメソッド(show)は実体の型(Child)でオーバーライドされたものが動的に選ばれます。"),
                Choice(id: "d", text: "10 C1 C2", correct: false, misconception: "staticメソッドも動的束縛されると誤解", explanation: "staticメソッドはオーバーライドされません（隠蔽）。変数の型であるParentのprintが呼ばれます。")
            ],
            explanationRef: "explain-silver-polymorphism-001",
            designIntent: "変数の型で決まるもの（フィールド、static）と、インスタンスの型で決まるもの（インスタンスメソッド）の違いを視覚的に理解させる。"
        )

        // MARK: - Silver: try-catch-finallyのreturn上書き
        static let silverExceptionFinally001 = Quiz(
            id: "silver-exception-finally-001",
            level: .silver,
            category: "exception-handling",
            tags: ["例外処理", "finally", "return"],
            code: """
    public class Test {
        public static void main(String[] args) {
            System.out.println(calc());
        }
        static int calc() {
            try {
                return 1;
            } finally {
                return 2;
            }
        }
    }
    """,
            question: "このコードを実行したとき、出力される結果はどれか？",
            choices: [
                Choice(id: "a", text: "1", correct: false, misconception: "tryブロックのreturnが優先されると誤解", explanation: "tryブロック内でreturnが宣言されても、メソッドを抜ける前に必ずfinallyブロックが実行されます。"),
                Choice(id: "b", text: "2", correct: true, misconception: nil, explanation: "tryブロックで「1」を返そうとしますが、メソッドを抜ける前にfinallyブロックが実行され、そこで「2」がreturnされるため、結果が上書きされます。"),
                Choice(id: "c", text: "1 2", correct: false, misconception: "両方の値が順に返されると誤解", explanation: "メソッドの戻り値は1つだけです。"),
                Choice(id: "d", text: "コンパイルエラー", correct: false, misconception: "到達不能コード(Unreachable code)になると誤解", explanation: "finally内にreturnを書くことは文法上許されています（非推奨ですが、試験では頻出です）。")
            ],
            explanationRef: "explain-silver-exception-finally-001",
            designIntent: "コールスタック上で「戻り値が一時保存され、finallyで上書きされる」という奇妙な動きをステップ実行で体感させる。"
        )

        // MARK: - Silver: String Poolと参照比較
        static let silverStringPool001 = Quiz(
            id: "silver-string-pool-001",
            level: .silver,
            category: "string",
            tags: ["String", "文字列プール", "同値性"],
            code: """
    public class Test {
        public static void main(String[] args) {
            String s1 = "Java";
            String s2 = "Java";
            String s3 = new String("Java");
            
            System.out.print((s1 == s2) + " ");
            System.out.print((s1 == s3) + " ");
            System.out.print(s1.equals(s3));
        }
    }
    """,
            question: "このコードを実行したとき、出力される結果はどれか？",
            choices: [
                Choice(id: "a", text: "true true true", correct: false, misconception: "文字が同じなら==もtrueになると誤解", explanation: "new String()で作ったオブジェクトは、プールとは別の新しいインスタンスになります。"),
                Choice(id: "b", text: "false false true", correct: false, misconception: "毎回新しいインスタンスが作られると誤解", explanation: "文字列リテラル(\"Java\")はString Poolで共有されるため、s1とs2は同じインスタンスを指します。"),
                Choice(id: "c", text: "true false true", correct: true, misconception: nil, explanation: "s1とs2はString Pool内の同じインスタンスを指すため == はtrue。s3はnewによりHeap上に新しく作られたインスタンスを指すため == はfalse。equalsは文字の中身を比較するためtrueです。"),
                Choice(id: "d", text: "true false false", correct: false, misconception: "equalsが参照比較だと誤解", explanation: "Stringクラスのequalsメソッドは、文字の並びが同じであればtrueを返します。")
            ],
            explanationRef: "explain-silver-string-pool-001",
            designIntent: "ヒープメモリ上の「String Pool（定数プール）」と「通常のヒープ領域」への参照の違いを視覚化して、== と equals の違いを根本から理解させる。"
        )
    
    // MARK: - Silver: 参照の値渡し
        static let silverDataTypesPassByValue = Quiz(
            id: "silver-datatypes-pass-by-value-001",
            level: .silver,
            category: "data-types",
            tags: ["参照型", "メソッド引数", "ヒープ"],
            code: """
    class Dog { 
        String name; 
    }

    public class Test {
        public static void main(String[] args) {
            Dog d = new Dog();
            d.name = "Pochi";
            
            changeName(d);
            
            System.out.println(d.name);
        }
        
        static void changeName(Dog dog) {
            dog.name = "Hachi";
            dog = new Dog();
            dog.name = "Taro";
        }
    }
    """,
            question: "このコードを実行したとき、出力される結果はどれか？",
            choices: [
                Choice(id: "a", text: "Pochi",
                       correct: false, misconception: "メソッドに渡すと値のコピーが渡されるため、元のオブジェクトは変更されないと誤解（プリミティブ型との混同）",
                       explanation: "参照型をメソッドに渡す場合、参照のコピーが渡されるため、メソッド内で元のインスタンスのフィールドを変更できます。"),
                Choice(id: "b", text: "Hachi",
                       correct: true, misconception: nil,
                       explanation: "メソッド内の最初の行で元のDogインスタンスの名前がHachiに書き換わります。その後、変数dogには新しいインスタンスが代入されますが、mainメソッドの変数dの参照先は変わらないため、Hachiが出力されます。"),
                Choice(id: "c", text: "Taro",
                       correct: false, misconception: "メソッド内で新しいインスタンスを代入すると、呼び出し元の変数dの参照先も変わると誤解",
                       explanation: "メソッド内で引数変数dogにnew Dog()を代入しても、それはローカル変数dogの参照先が変わるだけで、mainの変数dには影響しません。"),
                Choice(id: "d", text: "コンパイルエラー",
                       correct: false, misconception: "引数で受け取った変数への再代入はできないと誤解",
                       explanation: "引数にfinalがついていないため、再代入はコンパイル可能です。")
            ],
            explanationRef: "explain-silver-datatypes-pass-by-value-001",
            designIntent: "Javaの「参照の値渡し」の核心を突く問題。ヒープ上の同じオブジェクトを指している状態と、ローカル変数が別のオブジェクトを指し直す状態の違いを理解させる。"
        )
    
    // MARK: - Silver: ガベージコレクション (GC)
        static let silverJavaBasics002 = Quiz(

            id: "silver-java-basics-002",
            level: .silver,
            category: "java-basics",
            tags: ["GC", "参照", "スコープ"],
            code: """
    public class Test {
        public static void main(String[] args) {
            Object obj1 = new Object(); // [1]
            Object obj2 = new Object(); // [2]
            
            obj1 = obj2;                // [3]
            obj2 = null;                // [4]
            
            // ここでGCの対象になっているオブジェクトはどれか？
        }
    }
    """,
            question: "コメント [4] の実行直後において、ガベージコレクション(GC)の対象となるオブジェクトはどれか？",
            choices: [
                Choice(id: "a", text: "[1] で生成されたオブジェクトのみ",
                       correct: true, misconception: nil,
                       explanation: "[3]でobj1にobj2の参照が代入されたことで、[1]で生成されたオブジェクトを指す参照がなくなりました。そのため[1]はGC対象です。"),
                Choice(id: "b", text: "[2] で生成されたオブジェクトのみ",
                       correct: false, misconception: "nullを代入した変数の元のオブジェクトが必ずGC対象になると誤解",
                       explanation: "[4]でobj2にnullを代入しましたが、その前に[3]でobj1が[2]のオブジェクトを参照しているため、[2]はまだGC対象ではありません。"),
                Choice(id: "c", text: "[1]と[2] で生成された両方のオブジェクト",
                       correct: false, misconception: "null代入で関連するすべてが消えると誤解",
                       explanation: "[2]のオブジェクトは変数obj1から参照され続けています。"),
                Choice(id: "d", text: "GCの対象になるオブジェクトはない",
                       correct: false, misconception: nil,
                       explanation: "[1]のオブジェクトは誰からも参照されなくなっているため、GCの対象になります。"),
            ],
            explanationRef: "explain-silver-java-basics-002",
            designIntent: "参照変数の代入とnullの代入を追いかけ、どのインスタンスが「到達不能(GC対象)」になったかを見抜かせる。"
        )

        // MARK: - Silver: 多次元配列
        static let silverArray002 = Quiz(
            id: "silver-array-002",
            level: .silver,
            category: "data-types",
            tags: ["多次元配列", "非対称配列", "NullPointerException"],
            code: """
    public class Test {
        public static void main(String[] args) {
            int[][] array = new int[2][];
            array[0] = new int[2];
            array[0][1] = 5;
            
            System.out.println(array[0][1] + " " + array[1][0]);
        }
    }
    """,
            question: "このコードを実行したとき、出力される結果はどれか？",
            choices: [
                Choice(id: "a", text: "5 0",
                       correct: false, misconception: "初期化していない多次元配列の要素も0になると誤解",
                       explanation: "array[1] はインスタンス化されていないため null です。array[1][0] にアクセスすると例外が発生します。"),
                Choice(id: "b", text: "5 null",
                       correct: false, misconception: "プリミティブ配列の要素がnullを返すと誤解",
                       explanation: "int型の要素はnullにはなり得ず、アクセス自体ができません。"),
                Choice(id: "c", text: "NullPointerException",
                       correct: true, misconception: nil,
                       explanation: "new int[2][] で生成した配列の要素(array[0], array[1])は参照型であり、デフォルト値は null です。array[1] に配列を割り当てる前に array[1][0] にアクセスしたため、NPEがスローされます。"),
                Choice(id: "d", text: "コンパイルエラー",
                       correct: false, misconception: "多次元配列は全ての次元のサイズを同時に指定しなければならないと誤解",
                       explanation: "new int[2][] のように、1次元目だけサイズを指定して非対称配列を作るのは文法的に正しいです。"),
            ],
            explanationRef: "explain-silver-array-002",
            designIntent: "多次元配列（配列の配列）において、1次元目だけを初期化した場合、2次元目がデフォルトでnullになる仕様を確認する。"
        )

        // MARK: - Gold: JDBC (ResultSet)
        static let goldJdbc001 = Quiz(
            id: "gold-jdbc-001",
            level: .gold,
            category: "jdbc",
            tags: ["JDBC", "ResultSet", "next()"],
            code: """
    import java.sql.*;

    public class Test {
        public static void main(String[] args) throws SQLException {
            // 接続等は正常に完了しているものとする
            Connection conn = DriverManager.getConnection("jdbc:h2:mem:");
            Statement stmt = conn.createStatement();
            stmt.execute("CREATE TABLE users (name VARCHAR)");
            stmt.execute("INSERT INTO users VALUES ('Alice')");
            
            ResultSet rs = stmt.executeQuery("SELECT name FROM users");
            System.out.println(rs.getString(1));
        }
    }
    """,
            question: "このコードを実行したときの挙動として正しいものはどれか？",
            choices: [
                Choice(id: "a", text: "Alice",
                       correct: false, misconception: "executeQuery直後に1行目のデータが取得できると誤解",
                       explanation: "ResultSetのカーソルは初期状態では「最初の行の直前(before first)」を指しています。"),
                Choice(id: "b", text: "SQLExceptionがスローされる",
                       correct: true, misconception: nil,
                       explanation: "カーソルが有効な行を指していない状態で getString() などのデータ取得メソッドを呼び出すと、実行時例外（SQLException）が発生します。取得前に rs.next() を呼び出す必要があります。"),
                Choice(id: "c", text: "null",
                       correct: false, misconception: "カーソル未移動時はnullが返ると誤解",
                       explanation: "nullではなく例外がスローされます。"),
                Choice(id: "d", text: "コンパイルエラー",
                       correct: false, misconception: nil,
                       explanation: "SQLExceptionは throws で宣言されているためコンパイルは通ります。"),
            ],
            explanationRef: "explain-gold-jdbc-001",
            designIntent: "JDBCのResultSetにおけるカーソルの初期位置（before first）と、next()呼び出しの必要性を見抜かせる。"
        )

        // MARK: - Gold: ローカライゼーション (ResourceBundle)
        static let goldLocalization001 = Quiz(
            id: "gold-localization-001",
            level: .gold,
            category: "localization",
            tags: ["ResourceBundle", "Locale", "フォールバック"],
            code: """
    import java.util.*;

    public class Test {
        public static void main(String[] args) {
            // 以下のプロパティファイルが存在する
            // Msg_fr_FR.properties (値: "Bonjour FR")
            // Msg_fr.properties    (値: "Bonjour")
            // Msg.properties       (値: "Hello")
            
            // 現在のデフォルトロケールは en_US である
            
            Locale loc = new Locale("fr", "CA"); // フランス語・カナダ
            ResourceBundle rb = ResourceBundle.getBundle("Msg", loc);
            
            System.out.println(rb.getString("greet"));
        }
    }
    """,
            question: "このコードを実行したとき、取得される値はどれか？",
            choices: [
                Choice(id: "a", text: "Bonjour FR",
                       correct: false, misconception: "言語が同じなら他の地域(FR)も探すと誤解",
                       explanation: "要求された地域はCA(カナダ)なので、FR(フランス)のファイルは読み込まれません。"),
                Choice(id: "b", text: "Bonjour",
                       correct: true, misconception: nil,
                       explanation: "Msg_fr_CA を探して見つからないため、地域を落として Msg_fr を探します。Msg_fr.properties が存在するため、その値が採用されます。"),
                Choice(id: "c", text: "Hello",
                       correct: false, misconception: "完全一致がないとデフォルトロケール(en_US)や基底ファイルに直接飛ぶと誤解",
                       explanation: "デフォルトロケール(en_US)を探す前に、要求されたロケール(fr_CA)の言語のみのファイル(Msg_fr)を探します。"),
                Choice(id: "d", text: "MissingResourceException",
                       correct: false, misconception: nil,
                       explanation: "フォールバックにより Msg_fr.properties が見つかるため例外は発生しません。"),
            ],
            explanationRef: "explain-gold-localization-001",
            designIntent: "ResourceBundleの検索順序（要求ロケール → デフォルトロケール → 基底ファイル）と、地域落ち(言語のみ)のフォールバックを理解しているか。"
        )

        // MARK: - Gold: Stream API (Collectors.groupingBy)
        static let goldStream003 = Quiz(
            id: "gold-stream-003",
            level: .gold,
            category: "lambda-streams",
            tags: ["Stream", "Collectors", "groupingBy"],
            code: """
    import java.util.*;
    import java.util.stream.*;

    public class Test {
        public static void main(String[] args) {
            List<String> list = List.of("A", "BB", "C", "DDD");
            
            Map<Integer, List<String>> map = list.stream()
                .collect(Collectors.groupingBy(String::length));
                
            System.out.println(map.get(1));
        }
    }
    """,
            question: "このコードを実行したとき、出力される結果はどれか？",
            choices: [
                Choice(id: "a", text: "A",
                       correct: false, misconception: "戻り値が単一の要素になると誤解",
                       explanation: "groupingByはキーに対して「要素のリスト」を値とするMapを作成します。単一の文字列ではありません。"),
                Choice(id: "b", text: "[A]",
                       correct: false, misconception: "Cが見落とされると誤解",
                       explanation: "長さ1の文字列は \"A\" と \"C\" の2つ存在します。"),
                Choice(id: "c", text: "[A, C]",
                       correct: true, misconception: nil,
                       explanation: "groupingBy(String::length) は、文字列の「長さ」をキーとして要素をグループ化します。長さ1のキー(1)には \"A\" と \"C\" のリストが入ります。"),
                Choice(id: "d", text: "コンパイルエラー",
                       correct: false, misconception: "groupingByの引数型が不正であると誤解",
                       explanation: "String::lengthはキーを抽出するFunctionとして正しく機能します。"),
            ],
            explanationRef: "explain-gold-stream-003",
            designIntent: "Collectors.groupingByが「キー抽出関数」を受け取り、Map<K, List<V>>を返すという高度な集計操作を理解しているか。"
        )

    // MARK: - Silver: Javaの基本 (ローカル変数の初期化)
        static let silverJavaBasics001 = Quiz(
            id: "silver-java-basics-001",
            level: .silver,
            category: "java-basics",
            tags: ["ローカル変数", "初期化", "コンパイルエラー"],
            code: """
    public class Test {
        int instanceVar;
        
        public static void main(String[] args) {
            int localVar;
            Test t = new Test();
            
            if (t.instanceVar == 0) {
                localVar = 10;
            }
            System.out.println(localVar);
        }
    }
    """,
            question: "このコードをコンパイルおよび実行したときの結果として正しいものはどれか？",
            choices: [
                Choice(id: "a", text: "10",
                       correct: false, misconception: "if文が必ずtrueになるため初期化されると誤解",
                       explanation: "コンパイラは実行時のロジック（if文が必ず成立するか）まで深く推論しません。初期化されないルートが存在し得ると判断されます。"),
                Choice(id: "b", text: "0",
                       correct: false, misconception: "ローカル変数も自動で0に初期化されると誤解",
                       explanation: "インスタンス変数（フィールド）はデフォルト値で初期化されますが、ローカル変数は自動初期化されません。"),
                Choice(id: "c", text: "コンパイルエラー",
                       correct: true, misconception: nil,
                       explanation: "ローカル変数 localVar が確実に初期化される前に使用（println）されているため、コンパイルエラーになります。"),
                Choice(id: "d", text: "実行時エラー",
                       correct: false, misconception: nil,
                       explanation: "ローカル変数の未初期化はコンパイル時に検出されるため、実行時エラーには到達しません。"),
            ],
            explanationRef: "explain-silver-java-basics-001",
            designIntent: "インスタンス変数（自動初期化）とローカル変数（明示的な初期化が必須）の違いと、コンパイラの確実な初期化チェックを見抜かせる。"
        )

        // MARK: - Silver: クラスとインターフェース (static変数)
        static let silverClasses002 = Quiz(
            id: "silver-classes-002",
            level: .silver,
            category: "classes",
            tags: ["static", "クラス変数", "インスタンス"],
            code: """
    public class Test {
        static int count = 0;
        
        Test() {
            count++;
        }
        
        public static void main(String[] args) {
            Test t1 = new Test();
            Test t2 = new Test();
            t1.count = 5;
            
            System.out.println(t2.count);
        }
    }
    """,
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                Choice(id: "a", text: "1",
                       correct: false, misconception: "インスタンスごとに別々の変数を持つと誤解",
                       explanation: "countはstatic変数（クラス変数）であるため、すべてのインスタンスで1つの変数を共有します。"),
                Choice(id: "b", text: "2",
                       correct: false, misconception: "t1.count = 5 の代入がt2に影響しないと誤解",
                       explanation: "t1.countもt2.countも、実体はTest.countという同一の変数を指しています。"),
                Choice(id: "c", text: "5",
                       correct: true, misconception: nil,
                       explanation: "static変数はクラス全体で共有されます。t1経由で5を代入した後、t2経由で参照しても同じ共有変数の値（5）が取得されます。"),
                Choice(id: "d", text: "コンパイルエラー",
                       correct: false, misconception: "インスタンス変数経由でのstaticアクセスは禁止されていると誤解",
                       explanation: "推奨はされませんが、インスタンス（t1やt2）経由でstatic変数にアクセスすることは文法上可能です。"),
            ],
            explanationRef: "explain-silver-classes-002",
            designIntent: "static変数がクラス全体で共有される概念と、インスタンス経由でも同じ値にアクセスできる仕様を確認する。"
        )

        // MARK: - Silver: ラムダ式 (省略記法)
        static let silverLambda001 = Quiz(
            id: "silver-lambda-001",
            level: .silver,
            category: "lambda-streams",
            tags: ["ラムダ式", "省略記法", "Predicate"],
            code: """
    import java.util.function.Predicate;

    public class Test {
        public static void main(String[] args) {
            Predicate<String> p1 = s -> s.isEmpty();
            Predicate<String> p2 = s -> { s.isEmpty(); }; // (注: ここにエラーがあるか問う)
            
            System.out.println(p1.test(""));
        }
    }
    """,
            question: "このコードについて正しい説明はどれか？",
            choices: [
                Choice(id: "a", text: "true と出力される",
                       correct: false, misconception: "p2の文法が正しいと誤解",
                       explanation: "p2の記述にコンパイルエラーが含まれているため、実行まで到達しません。"),
                Choice(id: "b", text: "p1の行でコンパイルエラーになる",
                       correct: false, misconception: "引数のカッコ()やreturnが必須であると誤解",
                       explanation: "引数が1つで型推論可能な場合、カッコは省略可能です。また、単一式の場合は波カッコ{}とreturnも省略できます(p1は正しい)。"),
                Choice(id: "c", text: "p2の行でコンパイルエラーになる",
                       correct: true, misconception: nil,
                       explanation: "ラムダ式で波カッコ {} を使用した場合、戻り値が必要な関数インターフェース（Predicateなど）では明示的に return を書く必要があります。"),
                Choice(id: "d", text: "実行時エラーになる",
                       correct: false, misconception: nil,
                       explanation: "文法エラー(return抜け)によるコンパイルエラーです。"),
            ],
            explanationRef: "explain-silver-lambda-001",
            designIntent: "ラムダ式の正しい省略ルール（{}を使うならreturnが必須）を理解しているか問う。"
        )

        // MARK: - Silver: 制御構文 (拡張for文と参照)
        static let silverControlFlow002 = Quiz(
            id: "silver-control-flow-002",
            level: .silver,
            category: "control-flow",
            tags: ["拡張for文", "配列", "値渡し"],
            code: """
    public class Test {
        public static void main(String[] args) {
            int[] numbers = {1, 2, 3};
            
            for (int n : numbers) {
                n = n * 2;
            }
            
            System.out.println(numbers[0]);
        }
    }
    """,
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                Choice(id: "a", text: "1",
                       correct: true, misconception: nil,
                       explanation: "拡張for文の変数 n には配列要素の「値」がコピーされます。変数 n を変更しても、元の配列 numbers の要素は変更されません。"),
                Choice(id: "b", text: "2",
                       correct: false, misconception: "配列の要素自体が書き換わると誤解",
                       explanation: "配列の要素を直接書き換えるには、インデックスを使った通常のfor文 (numbers[i] = ...) が必要です。"),
                Choice(id: "c", text: "3",
                       correct: false, misconception: "最後の要素が出力されると誤解",
                       explanation: "numbers[0] なので最初の要素が出力されます。"),
                Choice(id: "d", text: "コンパイルエラー",
                       correct: false, misconception: nil,
                       explanation: "拡張for文内でループ変数を変更することは文法的に許可されています（ただし元の配列には影響しません）。"),
            ],
            explanationRef: "explain-silver-control-flow-002",
            designIntent: "拡張for文で一時変数に代入しても、元の配列やコレクションの中身は書き換わらないというJavaの基本仕様を確認する。"
        )

        // MARK: - Silver: データ型 (参照渡し・値渡し)
        static let silverDataTypes002 = Quiz(
            id: "silver-data-types-002",
            level: .silver,
            category: "data-types",
            tags: ["参照", "メソッド引数", "String"],
            code: """
    public class Test {
        static void modify(String s, StringBuilder sb) {
            s = s.concat("World");
            sb.append("World");
        }
        
        public static void main(String[] args) {
            String str = "Hello";
            StringBuilder builder = new StringBuilder("Hello");
            
            modify(str, builder);
            
            System.out.println(str + " " + builder);
        }
    }
    """,
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                Choice(id: "a", text: "HelloWorld HelloWorld",
                       correct: false, misconception: "Stringもメソッド内で変更されると誤解",
                       explanation: "Stringは不変クラスであり、メソッド内で変数sに再代入しても、呼び出し元のstrの参照先は変わりません。"),
                Choice(id: "b", text: "Hello Hello",
                       correct: false, misconception: "StringBuilderもメソッド内で変更されないと誤解",
                       explanation: "StringBuilderは可変オブジェクトであり、メソッド内で同じインスタンスを変更するため呼び出し元にも影響します。"),
                Choice(id: "c", text: "Hello HelloWorld",
                       correct: true, misconception: nil,
                       explanation: "Stringは不変であり再代入は呼び出し元に影響しませんが、StringBuilderは可変であり同じオブジェクトを変更するため呼び出し元に影響（副作用）が出ます。"),
                Choice(id: "d", text: "コンパイルエラー",
                       correct: false, misconception: nil,
                       explanation: "文法的な問題はありません。"),
            ],
            explanationRef: "explain-silver-data-types-002",
            designIntent: "Javaのメソッド引数は「参照の値渡し」。不変クラス(String)の再代入と、可変クラス(StringBuilder)のメソッド呼び出しの違いを問う。"
        )
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
        id: "gold-concurrency-002",
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
        explanationRef: "explain-gold-concurrency-002",
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

    // MARK: - Gold: コレクション (TreeSetとComparator)

    static let goldCollections001 = Quiz(
        id: "gold-collections-001",
        level: .gold,
        category: "collections",
        tags: ["TreeSet", "Comparator", "重複判定"],
        code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Set<String> set = new TreeSet<>(Comparator.comparingInt(String::length));
        set.add("aa");
        set.add("bb");
        set.add("c");
        System.out.println(set.size());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1",
                   correct: false, misconception: "最後に追加した要素だけが残ると誤解",
                   explanation: "長さ1の\"c\"と長さ2の\"aa\"はComparator上は別要素です。"),
            Choice(id: "b", text: "2",
                   correct: true, misconception: nil,
                   explanation: "TreeSetの重複判定はComparatorの比較結果で決まります。\"aa\"と\"bb\"は長さが同じで比較結果0となるため、片方だけが保持されます。"),
            Choice(id: "c", text: "3",
                   correct: false, misconception: "equalsだけで重複判定されると誤解",
                   explanation: "TreeSetではequalsではなく、自然順序または指定Comparatorによる比較結果0が重複扱いになります。"),
            Choice(id: "d", text: "ClassCastException",
                   correct: false, misconception: "TreeSetでは必ずComparableが必要だと誤解",
                   explanation: "ここではComparatorを渡しているため、Stringの自然順序ではなく長さで比較できます。"),
        ],
        explanationRef: "explain-gold-collections-001",
        designIntent: "TreeSetの要素重複はequalsではなくComparator/compareToの結果0で判断される点を確認する。"
    )

    // MARK: - Gold: ジェネリクス (型消去)

    static let goldGenerics003 = Quiz(
        id: "gold-generics-003",
        level: .gold,
        category: "generics",
        tags: ["型消去", "オーバーロード", "List"],
        code: """
import java.util.*;

public class Test {
    static void print(List<String> values) {
        System.out.println("String");
    }
    static void print(List<Integer> values) {
        System.out.println("Integer");
    }
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる",
                   correct: false, misconception: "型引数の違いだけでオーバーロードできると誤解",
                   explanation: "ジェネリクスの型引数は型消去されるため、どちらもprint(List)として扱われます。"),
            Choice(id: "b", text: "List<String>側だけが有効になる",
                   correct: false, misconception: "先に書いたメソッドが優先されると誤解",
                   explanation: "同じ消去後シグネチャを持つメソッドは同時に宣言できないため、優先順位ではなくコンパイルエラーです。"),
            Choice(id: "c", text: "コンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "List<String>とList<Integer>は型消去後にどちらもListになるため、メソッドシグネチャが衝突します。"),
            Choice(id: "d", text: "実行時にClassCastExceptionが発生する",
                   correct: false, misconception: "ジェネリクスの問題は実行時まで遅れると誤解",
                   explanation: "この衝突はコンパイル時に検出されるため、実行時には到達しません。"),
        ],
        explanationRef: "explain-gold-generics-003",
        designIntent: "型消去により、型引数だけが異なるメソッドをオーバーロードできないことを確認する。"
    )

    // MARK: - Gold: Stream API (peekの遅延評価)

    static let goldStream004 = Quiz(
        id: "gold-stream-004",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "peek", "遅延評価"],
        code: """
import java.util.stream.Stream;

public class Test {
    public static void main(String[] args) {
        Stream.of("A", "B").peek(System.out::print);
        System.out.print("X");
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "ABX",
                   correct: false, misconception: "peekがその場ですぐ実行されると誤解",
                   explanation: "peekは中間操作です。終端操作がないため、AやBを出力する処理は実行されません。"),
            Choice(id: "b", text: "X",
                   correct: true, misconception: nil,
                   explanation: "Streamの中間操作は遅延評価されます。終端操作がないためpeekは動かず、最後のSystem.out.print(\"X\")だけが実行されます。"),
            Choice(id: "c", text: "XAB",
                   correct: false, misconception: "ストリーム処理が後から自動実行されると誤解",
                   explanation: "終端操作が呼ばれない限り、ストリームパイプラインは実行されません。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "戻り値のStreamを受け取らないとエラーになると誤解",
                   explanation: "戻り値を使わないメソッド呼び出し式として文法上は有効です。"),
        ],
        explanationRef: "explain-gold-stream-004",
        designIntent: "peekを含む中間操作は終端操作がないと実行されない、というStreamの遅延評価を見抜かせる。"
    )

    // MARK: - Gold: Stream API (reduce)

    static let goldStream005 = Quiz(
        id: "gold-stream-005",
        level: .gold,
        category: "lambda-streams",
        tags: ["Stream", "reduce", "identity"],
        code: """
import java.util.stream.Stream;

public class Test {
    public static void main(String[] args) {
        int result = Stream.of(1, 2, 3)
            .reduce(10, Integer::sum);
        System.out.println(result);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "6",
                   correct: false, misconception: "identityが初期値として加算されないと誤解",
                   explanation: "reduceのidentityは畳み込みの初期値です。1+2+3だけではありません。"),
            Choice(id: "b", text: "10",
                   correct: false, misconception: "ストリーム要素が無視されると誤解",
                   explanation: "要素が存在する場合、identityから始めて各要素を累積します。"),
            Choice(id: "c", text: "16",
                   correct: true, misconception: nil,
                   explanation: "identityの10から開始し、1、2、3を順に加算するため、10+1+2+3で16です。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "Integer::sumがBinaryOperatorとして使えないと誤解",
                   explanation: "Integer::sumは2つのintを受け取ってintを返すため、Integerのreduceで利用できます。"),
        ],
        explanationRef: "explain-gold-stream-005",
        designIntent: "reduce(identity, accumulator)のidentityが初期値として必ず使われることを確認する。"
    )

    // MARK: - Gold: Optional (ofとofNullable)

    static let goldOptional003 = Quiz(
        id: "gold-optional-003",
        level: .gold,
        category: "optional-api",
        tags: ["Optional", "of", "null"],
        code: """
import java.util.Optional;

public class Test {
    public static void main(String[] args) {
        try {
            Optional.of(null);
            System.out.println("OK");
        } catch (NullPointerException e) {
            System.out.println("NPE");
        }
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "OK",
                   correct: false, misconception: "Optional.ofがnullを空として扱うと誤解",
                   explanation: "Optional.of(null)はnullを許容しません。空Optionalにしたい場合はofNullableを使います。"),
            Choice(id: "b", text: "NPE",
                   correct: true, misconception: nil,
                   explanation: "Optional.of()にnullを渡すとNullPointerExceptionが発生し、catch節でNPEが出力されます。"),
            Choice(id: "c", text: "null",
                   correct: false, misconception: "Optionalがnull文字列を出力すると誤解",
                   explanation: "Optional.of(null)はOptionalを生成せず、例外をスローします。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "nullを渡す呼び出し自体が文法エラーだと誤解",
                   explanation: "呼び出し自体はコンパイルできます。問題は実行時にNullPointerExceptionが発生する点です。"),
        ],
        explanationRef: "explain-gold-optional-003",
        designIntent: "Optional.ofは非null専用、ofNullableはnull許容というAPIの使い分けを確認する。"
    )

    // MARK: - Gold: クラスとインターフェース (sealed)

    static let goldClasses002 = Quiz(
        id: "gold-classes-002",
        level: .gold,
        category: "classes",
        tags: ["sealed", "permits", "Java 17"],
        code: """
sealed interface Service permits FileService {}

final class FileService implements Service {}

final class NetworkService implements Service {}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる",
                   correct: false, misconception: "interfaceなら誰でも実装できると誤解",
                   explanation: "sealed interfaceはpermitsで許可した型だけが直接実装できます。"),
            Choice(id: "b", text: "NetworkServiceの宣言でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "ServiceはFileServiceだけをpermitsしています。NetworkServiceは許可されていないため、直接実装できません。"),
            Choice(id: "c", text: "FileServiceの宣言でコンパイルエラー",
                   correct: false, misconception: "sealedのサブクラスはsealedでなければならないと誤解",
                   explanation: "sealed型の直接サブタイプはfinal、sealed、non-sealedのいずれかを指定します。FileServiceはfinalなので有効です。"),
            Choice(id: "d", text: "実行時にSecurityExceptionが発生する",
                   correct: false, misconception: "継承制限が実行時チェックだと誤解",
                   explanation: "sealedの継承制限はコンパイル時に検出されます。"),
        ],
        explanationRef: "explain-gold-classes-002",
        designIntent: "sealed型ではpermitsに列挙された型だけが直接継承/実装できることを確認する。"
    )

    // MARK: - Gold: Date-Time API (不変性)

    static let goldDateTime001 = Quiz(
        id: "gold-date-time-001",
        level: .gold,
        category: "classes",
        tags: ["Date-Time API", "LocalDate", "不変"],
        code: """
import java.time.LocalDate;

public class Test {
    public static void main(String[] args) {
        LocalDate date = LocalDate.of(2026, 4, 19);
        date.plusDays(1);
        System.out.println(date);
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "2026-04-19",
                   correct: true, misconception: nil,
                   explanation: "LocalDateは不変です。plusDays(1)は新しいLocalDateを返しますが、戻り値を受け取っていないためdate自体は変わりません。"),
            Choice(id: "b", text: "2026-04-20",
                   correct: false, misconception: "plusDaysが元のオブジェクトを書き換えると誤解",
                   explanation: "Date-Time APIの主要クラスは不変であり、変更系メソッドは新しいインスタンスを返します。"),
            Choice(id: "c", text: "2026/04/19",
                   correct: false, misconception: "LocalDateの標準出力形式を誤解",
                   explanation: "LocalDate.toString()はISO-8601形式のyyyy-MM-ddで出力されます。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: nil,
                   explanation: "plusDaysの戻り値を使わなくてもコンパイルはできます。"),
        ],
        explanationRef: "explain-gold-date-time-001",
        designIntent: "Date-Time APIの不変性と、戻り値を受け取らない変更系メソッドの落とし穴を確認する。"
    )

    // MARK: - Gold: モジュールシステム (exports)

    static let goldModule001 = Quiz(
        id: "gold-module-001",
        level: .gold,
        category: "module-system",
        tags: ["module-info", "exports", "カプセル化"],
        code: """
module com.example.app {
    exports com.example.api;
    requires java.logging;
}
""",
        codeTabs: [
            CodeFile(
                filename: "module-info.java",
                code: """
module com.example.app {
    exports com.example.api;
    requires java.logging;
}
"""
            ),
            CodeFile(
                filename: "com/example/api/PublicApi.java",
                code: """
package com.example.api;

public class PublicApi {}
"""
            ),
            CodeFile(
                filename: "com/example/internal/Helper.java",
                code: """
package com.example.internal;

public class Helper {}
"""
            ),
        ],
        question: "他のモジュールから直接参照できるpublic型として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "PublicApiだけ",
                   correct: true, misconception: nil,
                   explanation: "exportsされているのはcom.example.apiだけです。publicクラスであっても、exportsされていないパッケージの型は他モジュールから直接参照できません。"),
            Choice(id: "b", text: "Helperだけ",
                   correct: false, misconception: "クラス名やディレクトリ名だけで公開範囲が決まると誤解",
                   explanation: "com.example.internalはexportsされていないため、Helperは他モジュールに公開されません。"),
            Choice(id: "c", text: "PublicApiとHelperの両方",
                   correct: false, misconception: "publicならモジュール外から常に見えると誤解",
                   explanation: "JPMSではpublicであることに加え、そのパッケージがexportsされている必要があります。"),
            Choice(id: "d", text: "どちらも参照できない",
                   correct: false, misconception: "requiresだけが公開範囲を決めると誤解",
                   explanation: "exports com.example.apiにより、PublicApiが属するパッケージは他モジュールに公開されます。"),
        ],
        explanationRef: "explain-gold-module-001",
        designIntent: "モジュール境界ではpublic型でもexportsされていないパッケージは隠蔽されることを確認する。"
    )

    // MARK: - Gold: モジュールシステム (requires transitive)

    static let goldModule002 = Quiz(
        id: "gold-module-002",
        level: .gold,
        category: "module-system",
        tags: ["requires transitive", "readability", "java.sql"],
        code: """
module lib.core {
    requires transitive java.sql;
    exports lib.api;
}

module app.main {
    requires lib.core;
}
""",
        codeTabs: [
            CodeFile(
                filename: "lib.core/module-info.java",
                code: """
module lib.core {
    requires transitive java.sql;
    exports lib.api;
}
"""
            ),
            CodeFile(
                filename: "app.main/module-info.java",
                code: """
module app.main {
    requires lib.core;
}
"""
            ),
        ],
        question: "app.mainモジュールからjava.sqlの型を参照する場合の説明として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "app.mainにも必ずrequires java.sqlが必要",
                   correct: false, misconception: "transitiveの効果を見落としている",
                   explanation: "明示的に書いても構いませんが、lib.coreがrequires transitive java.sqlしているため、app.mainはjava.sqlも読めます。"),
            Choice(id: "b", text: "requires transitiveによりapp.mainもjava.sqlを読める",
                   correct: true, misconception: nil,
                   explanation: "requires transitiveは、自分を読むモジュールにも依存先モジュールを読み取らせます。app.mainはlib.coreをrequiresしているため、java.sqlも読めます。"),
            Choice(id: "c", text: "exports lib.apiがあるためjava.sqlを読める",
                   correct: false, misconception: "exportsとrequiresの役割を混同",
                   explanation: "exportsはパッケージ公開、requiresは依存モジュールの読み取りです。java.sqlを読む理由はrequires transitiveです。"),
            Choice(id: "d", text: "java.sqlは標準モジュールなのでrequiresは常に不要",
                   correct: false, misconception: "java.base以外も自動で読めると誤解",
                   explanation: "暗黙的に読めるのはjava.baseです。java.sqlなどは通常requiresが必要です。"),
        ],
        explanationRef: "explain-gold-module-002",
        designIntent: "requires transitiveが依存先の可読性を利用側へ伝播させる仕組みを確認する。"
    )

    // MARK: - Gold: 並行処理 (CompletableFuture)

    static let goldConcurrency003 = Quiz(
        id: "gold-concurrency-003",
        level: .gold,
        category: "concurrency",
        tags: ["CompletableFuture", "thenApply", "join"],
        code: """
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) {
        CompletableFuture<Integer> future = CompletableFuture
            .supplyAsync(() -> 10)
            .thenApply(n -> n + 5);
        System.out.println(future.join());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "10",
                   correct: false, misconception: "thenApplyの変換結果を見落としている",
                   explanation: "thenApplyは前段の結果10を受け取り、15に変換したCompletableFutureを返します。"),
            Choice(id: "b", text: "15",
                   correct: true, misconception: nil,
                   explanation: "supplyAsyncの結果10にthenApplyで5を加えます。join()は完了を待って結果15を返します。"),
            Choice(id: "c", text: "CompletableFuture[15]",
                   correct: false, misconception: "futureそのものが出力されると誤解",
                   explanation: "printlnしているのはfutureではなくfuture.join()の戻り値です。"),
            Choice(id: "d", text: "コンパイルエラー",
                   correct: false, misconception: "非同期処理では戻り値型が合わないと誤解",
                   explanation: "thenApplyによりCompletableFuture<Integer>として型がつながります。"),
        ],
        explanationRef: "explain-gold-concurrency-003",
        designIntent: "CompletableFutureのthenApplyによる結果変換とjoinによる値取得を確認する。"
    )

    // MARK: - Gold: 並行処理 (invokeAll)

    static let goldConcurrency004 = Quiz(
        id: "gold-concurrency-004",
        level: .gold,
        category: "concurrency",
        tags: ["ExecutorService", "invokeAll", "Future"],
        code: """
import java.util.*;
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) throws Exception {
        ExecutorService es = Executors.newFixedThreadPool(2);
        List<Callable<String>> tasks = List.of(
            () -> { Thread.sleep(50); return "A"; },
            () -> "B"
        );
        for (Future<String> f : es.invokeAll(tasks)) {
            System.out.print(f.get());
        }
        es.shutdown();
    }
}
""",
        question: "このコードを実行したとき、出力として最も適切なのはどれか？",
        choices: [
            Choice(id: "a", text: "AB",
                   correct: true, misconception: nil,
                   explanation: "invokeAllはすべてのタスク完了を待ち、渡したタスクリストと同じ順序でFutureのリストを返します。Bが先に完了しても取得順はA、Bです。"),
            Choice(id: "b", text: "BA",
                   correct: false, misconception: "完了順にFutureが並ぶと誤解",
                   explanation: "タスクの完了順ではなく、入力リストの順序でFutureが返されます。"),
            Choice(id: "c", text: "Aだけ",
                   correct: false, misconception: "Thread.sleepによりBが無視されると誤解",
                   explanation: "invokeAllはすべてのタスクが完了するまで待機します。"),
            Choice(id: "d", text: "RejectedExecutionException",
                   correct: false, misconception: "shutdown前のタスク投入が拒否されると誤解",
                   explanation: "shutdownはタスク完了後に呼ばれており、ここでは拒否は発生しません。"),
        ],
        explanationRef: "explain-gold-concurrency-004",
        designIntent: "invokeAllの戻り値の順序は完了順ではなく入力順であることを確認する。"
    )

    // MARK: - Gold: 入出力 (Path.relativize)

    static let goldIo002 = Quiz(
        id: "gold-io-002",
        level: .gold,
        category: "io",
        tags: ["NIO.2", "Path", "relativize"],
        code: """
import java.nio.file.Path;

public class Test {
    public static void main(String[] args) {
        Path base = Path.of("/app/logs");
        Path file = Path.of("/app/logs/2026/app.log");
        Path relative = base.relativize(file);
        System.out.println(relative.getNameCount());
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "1",
                   correct: false, misconception: "ファイル名だけが相対パスになると誤解",
                   explanation: "baseからfileへの相対パスは2026/app.logなので、名前要素は2つです。"),
            Choice(id: "b", text: "2",
                   correct: true, misconception: nil,
                   explanation: "relativeは2026/app.logに相当し、名前要素は2026とapp.logの2つです。"),
            Choice(id: "c", text: "3",
                   correct: false, misconception: "絶対パス全体の要素数を数えていると誤解",
                   explanation: "getNameCountしているのはrelativize後の相対パスです。"),
            Choice(id: "d", text: "IllegalArgumentException",
                   correct: false, misconception: "relativizeは常に例外が出ると誤解",
                   explanation: "両方とも同じ種類の絶対パスなので、相対パスを計算できます。"),
        ],
        explanationRef: "explain-gold-io-002",
        designIntent: "Path.relativizeが基準パスから対象パスまでの相対パスを作ることと、名前要素数の数え方を確認する。"
    )

    // MARK: - Gold: ローカライズ (ResourceBundle)

    static let goldLocalization002 = Quiz(
        id: "gold-localization-002",
        level: .gold,
        category: "localization",
        tags: ["ResourceBundle", "Locale", "フォールバック"],
        code: """
import java.util.*;

public class Test {
    public static class Messages extends ListResourceBundle {
        protected Object[][] getContents() {
            return new Object[][] { {"greeting", "base"} };
        }
    }
    public static class Messages_ja extends ListResourceBundle {
        protected Object[][] getContents() {
            return new Object[][] { {"greeting", "ja"} };
        }
    }
    public static void main(String[] args) {
        ResourceBundle rb = ResourceBundle.getBundle("Test$Messages", Locale.JAPAN);
        System.out.println(rb.getString("greeting"));
    }
}
""",
        question: "このコードを実行したとき、出力されるのはどれか？",
        choices: [
            Choice(id: "a", text: "ja",
                   correct: true, misconception: nil,
                   explanation: "Locale.JAPANはja_JPです。Messages_ja_JPがない場合、Messages_jaが候補となり、その値jaが取得されます。"),
            Choice(id: "b", text: "base",
                   correct: false, misconception: "完全一致がないと必ずベースに落ちると誤解",
                   explanation: "完全一致のMessages_ja_JPがなくても、言語だけ一致するMessages_jaがあればそれが使われます。"),
            Choice(id: "c", text: "greeting",
                   correct: false, misconception: "キー名そのものが返ると誤解",
                   explanation: "getStringはキーに対応する値を返します。"),
            Choice(id: "d", text: "MissingResourceException",
                   correct: false, misconception: "クラスベースのResourceBundleを見落としている",
                   explanation: "Messages_jaが存在し、greetingキーも定義されているため例外は発生しません。"),
        ],
        explanationRef: "explain-gold-localization-002",
        designIntent: "ResourceBundleが言語・国・ベースの順に候補を探すフォールバックを確認する。"
    )

    // MARK: - Gold: アノテーション (@Override)

    static let goldAnnotations001 = Quiz(
        id: "gold-annotations-001",
        level: .gold,
        category: "annotations",
        tags: ["@Override", "オーバーライド", "オーバーロード"],
        code: """
class Parent {
    void run() {}
}

class Child extends Parent {
    @Override
    void run(String name) {}
}
""",
        question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
        choices: [
            Choice(id: "a", text: "正常にコンパイルできる",
                   correct: false, misconception: "runという名前が同じならオーバーライドだと誤解",
                   explanation: "引数リストが異なるため、run(String)はrun()のオーバーライドではありません。"),
            Choice(id: "b", text: "@Overrideの行でコンパイルエラー",
                   correct: true, misconception: nil,
                   explanation: "@Overrideを付けたメソッドは親型のメソッドを実際にオーバーライドしている必要があります。run(String)はオーバーロードなのでエラーです。"),
            Choice(id: "c", text: "実行時にNoSuchMethodErrorが発生する",
                   correct: false, misconception: "アノテーションの検査が実行時だと誤解",
                   explanation: "@Overrideの整合性はコンパイル時に検査されます。"),
            Choice(id: "d", text: "Parent.run()が自動でrun(String)に変換される",
                   correct: false, misconception: "オーバーロードとオーバーライドを混同",
                   explanation: "メソッドの引数リストは自動変換されません。別シグネチャのメソッドです。"),
        ],
        explanationRef: "explain-gold-annotations-001",
        designIntent: "@Overrideがオーバーロード誤りをコンパイル時に検出してくれることを確認する。"
    )

    // MARK: - Gold: JDBC (PreparedStatement)

    static let goldJdbc002 = Quiz(
        id: "gold-jdbc-002",
        level: .gold,
        category: "jdbc",
        tags: ["JDBC", "PreparedStatement", "パラメータ番号"],
        code: """
import java.sql.*;

public class Test {
    static void bind(PreparedStatement ps) throws SQLException {
        ps.setString(0, "Alice");
    }
}
""",
        question: "このJDBCコード片について正しい説明はどれか？",
        choices: [
            Choice(id: "a", text: "0番目のプレースホルダにAliceが設定される",
                   correct: false, misconception: "JDBCのパラメータ番号が0始まりだと誤解",
                   explanation: "JDBCのプレースホルダ番号は0始まりではありません。"),
            Choice(id: "b", text: "setStringの引数型が違うためコンパイルエラー",
                   correct: false, misconception: "setString(int, String)のシグネチャを誤解",
                   explanation: "setString(int parameterIndex, String x)は有効なシグネチャなので、コード自体はコンパイルできます。"),
            Choice(id: "c", text: "パラメータ番号は1始まりなので、実行時にSQLExceptionの原因になる",
                   correct: true, misconception: nil,
                   explanation: "PreparedStatementのパラメータ番号は1から始まります。最初の?に値を設定するにはsetString(1, \"Alice\")と書きます。"),
            Choice(id: "d", text: "PreparedStatementではなくStatementなら0始まりになる",
                   correct: false, misconception: "StatementとPreparedStatementの役割を混同",
                   explanation: "Statementにはプレースホルダへのバインド操作はありません。PreparedStatementのパラメータは1始まりです。"),
        ],
        explanationRef: "explain-gold-jdbc-002",
        designIntent: "PreparedStatementのプレースホルダ番号が1始まりであることを確認する。"
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
