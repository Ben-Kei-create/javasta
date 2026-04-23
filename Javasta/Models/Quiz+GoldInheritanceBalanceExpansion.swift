import Foundation

enum GoldInheritanceBalanceQuestionData {
    struct ChoiceSpec {
        let id: String
        let text: String
        let correct: Bool
        let misconception: String?
        let explanation: String
    }

    struct VariableSpec {
        let name: String
        let type: String
        let value: String
        let scope: String
    }

    struct StepSpec {
        let narration: String
        let highlightLines: [Int]
        let variables: [VariableSpec]
    }

    struct Spec {
        let id: String
        let difficulty: QuizDifficulty
        let estimatedSeconds: Int
        let validatedByJavac: Bool
        let category: String
        let tags: [String]
        let code: String
        let question: String
        let choices: [ChoiceSpec]
        let explanationRef: String
        let designIntent: String
        let steps: [StepSpec]
    }

    static let specs: [Spec] = [
        q(
            "gold-inheritance-constructor-dispatch-001",
            difficulty: .tricky,
            category: "inheritance",
            tags: ["継承", "コンストラクタ", "オーバーライド", "初期化順序"],
            code: """
class Parent {
    Parent() {
        print();
    }
    void print() {
        System.out.print("P");
    }
}

class Child extends Parent {
    String value = "C";
    void print() {
        System.out.print(value);
    }
}

public class Test {
    public static void main(String[] args) {
        new Child();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "P", misconception: "コンストラクタ内では親クラスのメソッドが固定で呼ばれると誤解", explanation: "メソッド呼び出しは仮想呼び出しです。ParentコンストラクタからでもChild.print()が選ばれます。"),
                choice("b", "C", misconception: "Childのフィールド初期化がParentコンストラクタより前に終わると誤解", explanation: "Childのフィールド初期化はsuper()完了後です。Parentコンストラクタ中はvalueはまだnullです。"),
                choice("c", "null", correct: true, explanation: "ParentコンストラクタからChild.print()が呼ばれますが、Child.valueはまだ初期化前なのでnullが出力されます。"),
                choice("d", "コンパイルエラー", misconception: "コンストラクタからオーバーライドメソッドを呼べないと誤解", explanation: "コンパイルはできます。ただし初期化途中のサブクラス状態を参照し得るため危険です。"),
            ],
            intent: "コンストラクタ中の仮想メソッド呼び出しと、サブクラスフィールド初期化順序を確認する。",
            steps: [
                step("`new Child()` では最初に暗黙の `super()` が実行され、Parentコンストラクタへ入ります。", [16, 17, 1, 2], [variable("object", "Child", "allocated; Child fields not initialized", "heap")]),
                step("Parentコンストラクタ内の `print()` は仮想呼び出しなので、実体型Childの `print()` が選ばれます。", [3, 10, 11], [variable("dispatch target", "method", "Child.print()", "runtime")]),
                step("この時点では `String value = \"C\"` はまだ実行前です。valueは既定値nullのまま参照され、出力は `null` です。", [9, 12], [variable("value", "String", "null", "Child"), variable("output", "String", "null", "stdout")]),
            ]
        ),
        q(
            "gold-inheritance-field-hiding-001",
            difficulty: .tricky,
            category: "inheritance",
            tags: ["継承", "フィールド隠蔽", "ポリモーフィズム"],
            code: """
class A {
    String name = "A";
    String getName() {
        return name;
    }
}

class B extends A {
    String name = "B";
    String getName() {
        return name;
    }
}

public class Test {
    public static void main(String[] args) {
        A obj = new B();
        System.out.println(obj.name + ":" + obj.getName());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A:A", misconception: "メソッドも参照型Aで固定されると誤解", explanation: "インスタンスメソッドは実体型Bで動的ディスパッチされます。"),
                choice("b", "A:B", correct: true, explanation: "`obj.name` は参照型Aのフィールド、`obj.getName()` は実体型Bのメソッドを使います。"),
                choice("c", "B:A", misconception: "フィールドだけが動的に選ばれると誤解", explanation: "フィールドアクセスはポリモーフィックではありません。参照型で決まります。"),
                choice("d", "B:B", misconception: "フィールドもメソッドも実体型Bで選ばれると誤解", explanation: "動的に選ばれるのはオーバーライドされたインスタンスメソッドです。フィールドは隠蔽です。"),
            ],
            intent: "フィールド隠蔽とメソッドオーバーライドの解決タイミングの違いを確認する。",
            steps: [
                step("`A obj = new B();` により、参照型はA、実体型はBです。", [16], [variable("obj reference type", "A", "A", "main"), variable("obj runtime type", "Class", "B", "heap")]),
                step("`obj.name` はフィールドアクセスです。フィールドは参照型Aで解決されるためA.nameの `\"A\"` です。", [17, 2], [variable("obj.name", "String", "A", "main")]),
                step("`obj.getName()` はインスタンスメソッド呼び出しなのでB.getName()が実行され、B.nameの `\"B\"` を返します。出力は `A:B` です。", [17, 9, 10, 11], [variable("obj.getName()", "String", "B", "main"), variable("output", "String", "A:B", "stdout")]),
            ]
        ),
        q(
            "gold-inheritance-static-hiding-001",
            difficulty: .tricky,
            category: "inheritance",
            tags: ["継承", "static", "メソッド隠蔽"],
            code: """
class A {
    static String value() {
        return "A";
    }
    String call() {
        return value();
    }
}

class B extends A {
    static String value() {
        return "B";
    }
}

public class Test {
    public static void main(String[] args) {
        A obj = new B();
        System.out.println(obj.value() + ":" + obj.call());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A:A", correct: true, explanation: "staticメソッドは隠蔽であり、参照型や定義クラスに基づいて解決されます。"),
                choice("b", "A:B", misconception: "call内のvalueだけ実体型Bへ動的ディスパッチされると誤解", explanation: "staticメソッドは動的ディスパッチされません。A.call内のvalue()はA.value()です。"),
                choice("c", "B:A", misconception: "obj.value()だけ実体型Bで選ばれると誤解", explanation: "staticメソッドをインスタンス経由で呼んでも、参照型Aで解決されます。"),
                choice("d", "B:B", misconception: "staticメソッドもオーバーライドされると誤解", explanation: "staticメソッドはオーバーライドではなく隠蔽です。"),
            ],
            intent: "staticメソッド隠蔽とインスタンスメソッドの動的ディスパッチの違いを確認する。",
            steps: [
                step("`obj` の参照型はA、実体型はBです。ただし `value()` はstaticメソッドです。", [16], [variable("obj reference type", "A", "A", "main"), variable("obj runtime type", "Class", "B", "heap")]),
                step("`obj.value()` はインスタンス経由に見えてもstatic呼び出しです。参照型AによりA.value()が選ばれます。", [17, 1, 2], [variable("obj.value()", "String", "A", "main")]),
                step("`obj.call()` はインスタンスメソッドなのでA.call()が実行されますが、call内の `value()` はA.value()へ静的に結び付きます。出力は `A:A` です。", [5, 6, 17], [variable("obj.call()", "String", "A", "main"), variable("output", "String", "A:A", "stdout")]),
            ]
        ),
        q(
            "gold-inheritance-covariant-return-001",
            category: "inheritance",
            tags: ["継承", "オーバーライド", "共変戻り値"],
            code: """
class Parent {
    Number value() {
        return 1;
    }
}

class Child extends Parent {
    Integer value() {
        return 2;
    }
}

public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        Number n = p.value();
        System.out.println(n.getClass().getSimpleName() + ":" + n);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "Number:1", misconception: "参照型Parentの戻り値宣言だけで実行メソッドが決まると誤解", explanation: "実行されるメソッドは実体型Childのオーバーライドメソッドです。"),
                choice("b", "Integer:2", correct: true, explanation: "Child.value()が実行され、Integerの2がNumber型変数nに代入されます。"),
                choice("c", "Integer:1", misconception: "戻り値型だけがChild側に変わると誤解", explanation: "メソッド本体もChild.value()です。戻る値は2です。"),
                choice("d", "コンパイルエラー", misconception: "戻り値型が完全一致しないとオーバーライドできないと誤解", explanation: "戻り値型は親メソッドの戻り値型のサブタイプなら共変戻り値として認められます。"),
            ],
            intent: "共変戻り値と、参照型Parentから呼んだ場合の動的ディスパッチを確認する。",
            steps: [
                step("`Parent p = new Child();` により、参照型はParent、実体型はChildです。", [13], [variable("p reference type", "Parent", "Parent", "main"), variable("p runtime type", "Class", "Child", "heap")]),
                step("`p.value()` はインスタンスメソッドなのでChild.value()が選ばれ、Integerの2を返します。", [14, 6, 7, 8], [variable("p.value()", "Integer", "2", "main")]),
                step("戻り値はNumber型変数nへ代入できます。実体はIntegerなので、クラス名と値を連結して `Integer:2` です。", [14, 15], [variable("n", "Number", "Integer(2)", "main"), variable("output", "String", "Integer:2", "stdout")]),
            ]
        ),
        q(
            "gold-inheritance-private-method-001",
            difficulty: .tricky,
            category: "inheritance",
            tags: ["継承", "private", "オーバーライド"],
            code: """
class Parent {
    private void print() {
        System.out.print("P");
    }
    void call() {
        print();
    }
}

class Child extends Parent {
    void print() {
        System.out.print("C");
    }
}

public class Test {
    public static void main(String[] args) {
        new Child().call();
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "P", correct: true, explanation: "Parentのprivateメソッドはオーバーライドされません。Parent.call()内ではParent.print()が呼ばれます。"),
                choice("b", "C", misconception: "Child.printがParent.printをオーバーライドすると誤解", explanation: "privateメソッドはサブクラスから見えないため、Child.printは別メソッドです。"),
                choice("c", "PC", misconception: "親と子の両方のprintが連続して呼ばれると誤解", explanation: "call内で呼ばれるprintは1回だけです。"),
                choice("d", "コンパイルエラー", misconception: "Child側に同名メソッドを宣言できないと誤解", explanation: "privateメソッドは継承されないため、サブクラスに同名メソッドを宣言できます。"),
            ],
            intent: "privateメソッドはオーバーライド対象ではなく、同名メソッドを作っても動的ディスパッチされないことを確認する。",
            steps: [
                step("`new Child().call()` では、Childはcallを持たないためParent.call()が実行されます。", [16, 5], [variable("receiver", "Child", "new Child()", "main")]),
                step("Parent.call()内の `print()` は、Parentのprivateメソッドへ結び付きます。privateメソッドはオーバーライドされません。", [6, 1, 2], [variable("resolved method", "method", "Parent.print()", "Parent")]),
                step("Parent.print()が `P` を出力します。Child.print()は同名ですが別メソッドなので呼ばれません。", [3, 10, 11], [variable("output", "String", "P", "stdout")]),
            ]
        ),
        q(
            "gold-inheritance-default-class-wins-001",
            category: "inheritance",
            tags: ["継承", "interface", "default method"],
            code: """
interface Named {
    default String name() {
        return "I";
    }
}

class Base {
    public String name() {
        return "B";
    }
}

class Item extends Base implements Named {}

public class Test {
    public static void main(String[] args) {
        System.out.println(new Item().name());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "I", misconception: "interfaceのdefaultメソッドが常に優先されると誤解", explanation: "クラス階層に具象メソッドがある場合、そのメソッドがdefaultメソッドより優先されます。"),
                choice("b", "B", correct: true, explanation: "Base.name()というクラスの具象メソッドが、Named.name()のdefaultメソッドより優先されます。"),
                choice("c", "IB", misconception: "defaultとクラスメソッドの両方が自動実行されると誤解", explanation: "呼び出されるメソッドは1つです。"),
                choice("d", "コンパイルエラー", misconception: "同名メソッドがあると必ず衝突すると誤解", explanation: "クラスの具象メソッドが優先されるため衝突しません。"),
            ],
            intent: "interface default methodとクラス継承の優先順位を確認する。",
            steps: [
                step("ItemはBaseを継承し、Namedを実装しています。どちらにも `name()` があります。", [1, 6, 12], [variable("Item superclass", "Class", "Base", "type"), variable("Item interface", "Interface", "Named", "type")]),
                step("Javaではクラスの具象メソッドがinterfaceのdefaultメソッドより優先されます。", [7, 8, 9, 2, 3, 4], [variable("selected method", "method", "Base.name()", "runtime")]),
                step("`new Item().name()` はBase.name()を実行し、`B` を出力します。", [16], [variable("output", "String", "B", "stdout")]),
            ]
        ),
        q(
            "gold-inheritance-default-conflict-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "inheritance",
            tags: ["継承", "interface", "default method", "compile error"],
            code: """
interface Left {
    default String value() {
        return "L";
    }
}

interface Right {
    default String value() {
        return "R";
    }
}

class Both implements Left, Right {}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "正常にコンパイルできる", misconception: "同じシグネチャならどちらか一方が自動選択されると誤解", explanation: "LeftとRightのdefaultメソッドが衝突するため、Both側で明示的に解決する必要があります。"),
                choice("b", "Bothの宣言でコンパイルエラー", correct: true, explanation: "BothはLeft.value()とRight.value()のどちらを継承するか決められないため、value()をオーバーライドしないとコンパイルできません。"),
                choice("c", "Left.value()が優先される", misconception: "implementsに先に書いたinterfaceが優先されると誤解", explanation: "implementsの記述順ではdefaultメソッド衝突は解決されません。"),
                choice("d", "Right.value()が優先される", misconception: "implementsに後に書いたinterfaceが優先されると誤解", explanation: "後に書いたinterfaceが勝つという規則はありません。"),
            ],
            intent: "複数interfaceのdefaultメソッド衝突は、実装クラスで明示的に解決する必要があることを確認する。",
            steps: [
                step("LeftとRightはどちらも同じシグネチャ `value()` のdefaultメソッドを持ちます。", [1, 2, 6, 7], [variable("Left.value", "default method", "returns L", "interface"), variable("Right.value", "default method", "returns R", "interface")]),
                step("BothはLeftとRightを同時に実装しますが、value()をオーバーライドしていません。", [12], [variable("Both.value", "method", "not declared", "class")]),
                step("継承するdefaultメソッドを決められないため、Bothの宣言でコンパイルエラーです。", [12], [variable("compile result", "String", "error", "javac")]),
            ]
        ),
        q(
            "gold-inheritance-final-method-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "inheritance",
            tags: ["継承", "final", "オーバーライド", "compile error"],
            code: """
class Parent {
    final void run() {
        System.out.print("P");
    }
}

class Child extends Parent {
    void run() {
        System.out.print("C");
    }
}
""",
            question: "このコードをコンパイルしたときの結果として正しいものはどれか？",
            choices: [
                choice("a", "正常にコンパイルできる", misconception: "finalはクラスにだけ影響すると誤解", explanation: "finalメソッドはサブクラスでオーバーライドできません。"),
                choice("b", "Child.run()でコンパイルエラー", correct: true, explanation: "Parent.run()はfinalなので、Childで同じシグネチャのrun()を宣言してオーバーライドすることはできません。"),
                choice("c", "実行するとPが出力される", misconception: "コンパイルは通り、親メソッドが優先されると誤解", explanation: "finalメソッドをオーバーライドしようとした時点でコンパイルエラーです。"),
                choice("d", "実行するとCが出力される", misconception: "finalが動的ディスパッチに影響しないと誤解", explanation: "finalはオーバーライド自体を禁止します。"),
            ],
            intent: "finalメソッドはサブクラスでオーバーライドできないことを確認する。",
            steps: [
                step("Parent.run()にはfinalが付いています。これはサブクラスでのオーバーライド禁止を意味します。", [1, 2], [variable("Parent.run", "method", "final", "Parent")]),
                step("ChildはParentを継承し、同じシグネチャの `void run()` を宣言しています。これはParent.run()のオーバーライドです。", [6, 7], [variable("Child.run", "method", "attempted override", "Child")]),
                step("finalメソッドはオーバーライドできないため、Child.run()の宣言でコンパイルエラーになります。", [7], [variable("compile result", "String", "error", "javac")]),
            ]
        ),
        q(
            "gold-inheritance-non-sealed-chain-001",
            category: "inheritance",
            tags: ["継承", "sealed", "non-sealed", "Java17"],
            code: """
sealed class Base permits Middle {}

non-sealed class Middle extends Base {}

class Leaf extends Middle {}

public class Test {
    public static void main(String[] args) {
        System.out.println(new Leaf() instanceof Base);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", correct: true, explanation: "MiddleはBaseに許可された直接サブクラスで、non-sealedなのでLeafがさらに継承できます。Leafは間接的にBaseのサブタイプです。"),
                choice("b", "false", misconception: "LeafがBaseのpermitsにないためBase扱いにならないと誤解", explanation: "permitsが制限するのは直接サブクラスです。LeafはMiddle経由でBaseのサブタイプです。"),
                choice("c", "コンパイルエラー", misconception: "sealedクラスの子孫はすべてpermitsに列挙が必要と誤解", explanation: "Baseの直接サブクラスMiddleはpermitsにあります。Middleがnon-sealedなので、その先の継承は開かれます。"),
                choice("d", "実行時にClassCastException", misconception: "instanceofが失敗時に例外を投げると誤解", explanation: "instanceofはbooleanを返します。このコードではtrueです。"),
            ],
            intent: "sealedが直接サブタイプを制限し、non-sealedがその先の継承を開くことを確認する。",
            steps: [
                step("Baseはsealedで、直接サブクラスとしてMiddleだけを許可しています。", [1], [variable("Base permits", "Set", "Middle", "type")]),
                step("MiddleはBaseを継承し、`non-sealed` と宣言されているため、さらにLeafがMiddleを継承できます。", [3, 5], [variable("Middle modifier", "String", "non-sealed", "type"), variable("Leaf superclass", "Class", "Middle", "type")]),
                step("LeafはMiddle経由でBaseのサブタイプです。`new Leaf() instanceof Base` はtrueを返し、出力は `true` です。", [9], [variable("instanceof result", "boolean", "true", "main"), variable("output", "String", "true", "stdout")]),
            ]
        ),
        q(
            "gold-inheritance-instanceof-pattern-001",
            category: "inheritance",
            tags: ["継承", "instanceof", "パターンマッチング", "ポリモーフィズム"],
            code: """
class Parent {
    String label() {
        return "P";
    }
}

class Child extends Parent {
    String label() {
        return "C";
    }
}

public class Test {
    public static void main(String[] args) {
        Object obj = new Child();
        if (obj instanceof Parent p) {
            System.out.println(p.label());
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "P", misconception: "パターン変数pの型Parentでメソッド本体も固定されると誤解", explanation: "pの参照型はParentですが、実体はChildなのでlabel()は動的ディスパッチされます。"),
                choice("b", "C", correct: true, explanation: "objはChildインスタンスです。Parent型のパターン変数pに入った後も、label()はChild.label()が実行されます。"),
                choice("c", "何も出力されない", misconception: "Object型の変数はParentのinstanceofに失敗すると誤解", explanation: "実体がChildで、ChildはParentを継承しているためinstanceofはtrueです。"),
                choice("d", "コンパイルエラー", misconception: "instanceofのパターン変数ではメソッドを呼べないと誤解", explanation: "パターン変数pはifブロック内でParent型のローカル変数として使えます。"),
            ],
            intent: "instanceofパターン変数の型と、メソッド呼び出し時の動的ディスパッチを確認する。",
            steps: [
                step("`Object obj = new Child();` で、参照型はObject、実体型はChildです。", [14], [variable("obj reference type", "Object", "Object", "main"), variable("obj runtime type", "Class", "Child", "heap")]),
                step("`obj instanceof Parent p` は、ChildがParentのサブタイプなのでtrueです。pはParent型の変数として使えます。", [15], [variable("p", "Parent", "Child instance", "if")]),
                step("`p.label()` はインスタンスメソッド呼び出しです。実体型Childのlabel()が実行され、出力は `C` です。", [16, 7, 8], [variable("p.label()", "String", "C", "if"), variable("output", "String", "C", "stdout")]),
            ]
        ),
    ]

    static func q(
        _ id: String,
        difficulty: QuizDifficulty = .standard,
        estimatedSeconds: Int = 90,
        validatedByJavac: Bool = true,
        category: String,
        tags: [String],
        code: String,
        question: String,
        choices: [ChoiceSpec],
        intent: String,
        steps: [StepSpec]
    ) -> Spec {
        Spec(
            id: id,
            difficulty: difficulty,
            estimatedSeconds: estimatedSeconds,
            validatedByJavac: validatedByJavac,
            category: category,
            tags: tags,
            code: code,
            question: question,
            choices: choices,
            explanationRef: "explain-\(id)",
            designIntent: intent,
            steps: steps
        )
    }

    static func choice(
        _ id: String,
        _ text: String,
        correct: Bool = false,
        misconception: String? = nil,
        explanation: String
    ) -> ChoiceSpec {
        ChoiceSpec(
            id: id,
            text: text,
            correct: correct,
            misconception: misconception,
            explanation: explanation
        )
    }

    static func step(
        _ narration: String,
        _ highlightLines: [Int],
        _ variables: [VariableSpec] = []
    ) -> StepSpec {
        StepSpec(
            narration: narration,
            highlightLines: highlightLines,
            variables: variables
        )
    }

    static func variable(
        _ name: String,
        _ type: String,
        _ value: String,
        _ scope: String
    ) -> VariableSpec {
        VariableSpec(name: name, type: type, value: value, scope: scope)
    }
}

extension GoldInheritanceBalanceQuestionData.Spec {
    var quiz: Quiz {
        Quiz(
            id: id,
            level: .gold,
            difficulty: difficulty,
            estimatedSeconds: estimatedSeconds,
            validatedByJavac: validatedByJavac,
            category: category,
            tags: tags,
            code: code,
            question: question,
            choices: choices.map {
                Quiz.Choice(
                    id: $0.id,
                    text: $0.text,
                    correct: $0.correct,
                    misconception: $0.misconception,
                    explanation: $0.explanation
                )
            },
            explanationRef: explanationRef,
            designIntent: designIntent
        )
    }
}

extension QuizExpansion {
    static let goldInheritanceBalanceExpansion: [Quiz] = GoldInheritanceBalanceQuestionData.specs.map(\.quiz)
}
