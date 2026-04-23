import Foundation

enum GoldMockAdditionalQuestionData {
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

    private static let allSpecs: [Spec] = [
        q(
            "gold-mock-additional-stream-unordered-limit-001",
            category: "lambda-streams",
            tags: ["模試専用", "Stream", "unordered", "limit"],
            code: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        List<Integer> result = Stream.of(3, 1, 2, 1)
            .sorted()
            .limit(3)
            .collect(Collectors.toList());
        System.out.println(result);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "[1, 1, 2]", correct: true, explanation: "`sorted()` で 1,1,2,3 になり、`limit(3)` で先頭3件が残ります。"),
                choice("b", "[3, 1, 2]", misconception: "sortedを見落とし", explanation: "元の遭遇順ではなく、`sorted()` 後の順序から3件を取ります。"),
                choice("c", "[1, 2, 3]", misconception: "重複が自動で消えると誤解", explanation: "`distinct()` は呼ばれていないため、1の重複は残ります。"),
                choice("d", "3", misconception: "limitの戻り値を件数と誤解", explanation: "`limit` はStreamを返す中間操作で、最終的にListへcollectしています。"),
            ],
            intent: "sortedとlimitの順序、およびdistinctがない場合の重複を確認する。",
            steps: [
                step("元のStreamは `3, 1, 2, 1` です。`sorted()` により自然順の `1, 1, 2, 3` に並びます。", [6, 7], [variable("after sorted", "Stream<Integer>", "1, 1, 2, 3", "pipeline")]),
                step("`limit(3)` は、並び替え後の先頭3件だけを通します。重複を消す操作ではありません。", [8], [variable("after limit", "Stream<Integer>", "1, 1, 2", "pipeline")]),
                step("`collect(Collectors.toList())` でList化し、出力は `[1, 1, 2]` です。", [9, 10], [variable("result", "List<Integer>", "[1, 1, 2]", "main")]),
            ]
        ),
        q(
            "gold-mock-additional-stream-generate-limit-001",
            category: "lambda-streams",
            tags: ["模試専用", "Stream.generate", "limit", "Supplier"],
            code: """
import java.util.concurrent.atomic.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        AtomicInteger i = new AtomicInteger(1);
        int sum = Stream.generate(i::getAndIncrement)
            .limit(3)
            .mapToInt(Integer::intValue)
            .sum();
        System.out.println(sum + ":" + i.get());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "6:4", correct: true, explanation: "generateから1,2,3が取り出され、合計6。`getAndIncrement` は次の値を4に進めます。"),
                choice("b", "6:3", misconception: "getAndIncrementの更新後状態を見落とし", explanation: "3を返した後に内部値は4へ進みます。"),
                choice("c", "3:4", misconception: "limitの件数を合計と誤解", explanation: "出力しているsumは件数ではなく、1+2+3です。"),
                choice("d", "無限ループになる", misconception: "limitによる短絡を見落とし", explanation: "`limit(3)` があるため、3要素だけ生成して終了します。"),
            ],
            intent: "Stream.generateの遅延生成とlimitによる切り詰めを確認する。",
            steps: [
                step("`AtomicInteger` は1で開始し、`i::getAndIncrement` は呼ばれるたびに現在値を返してから増やします。", [6, 7], [variable("i", "AtomicInteger", "1", "main")]),
                step("`limit(3)` によりSupplierは必要な3回だけ呼ばれ、値は1,2,3になります。", [7, 8], [variable("generated", "Stream<Integer>", "1, 2, 3", "pipeline")]),
                step("合計は6で、3回目の取得後にAtomicIntegerの内部値は4です。出力は `6:4` です。", [9, 10, 11], [variable("sum", "int", "6", "main"), variable("i.get()", "int", "4", "main")]),
            ]
        ),
        q(
            "gold-mock-additional-stream-tomap-merge-001",
            category: "lambda-streams",
            tags: ["模試専用", "Collectors.toMap", "merge"],
            code: """
import java.util.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        Map<Integer, String> map = Stream.of("a", "bb", "c")
            .collect(Collectors.toMap(
                String::length,
                s -> s,
                (left, right) -> left + right
            ));
        System.out.println(map.get(1) + ":" + map.get(2));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "ac:bb", correct: true, explanation: "長さ1のキーでaとcが衝突し、マージ関数で `a + c` になります。長さ2はbbです。"),
                choice("b", "c:bb", misconception: "後勝ちで上書きされると誤解", explanation: "このtoMapはマージ関数を指定しているため、衝突時は連結されます。"),
                choice("c", "a:bb", misconception: "先勝ちで残ると誤解", explanation: "マージ関数 `(left, right) -> left + right` により `ac` になります。"),
                choice("d", "IllegalStateException", misconception: "マージ関数がないtoMapと混同", explanation: "重複キーがあっても、マージ関数があるため例外になりません。"),
            ],
            intent: "Collectors.toMapの重複キーとマージ関数の適用を確認する。",
            steps: [
                step("キーは文字列長です。`a` と `c` はどちらも長さ1、`bb` は長さ2です。", [6, 7], [variable("keys", "Map key", "a->1, bb->2, c->1", "collector")]),
                step("キー1で衝突したとき、マージ関数 `(left, right) -> left + right` が呼ばれ、`a` と `c` が連結されます。", [9, 10], [variable("map[1]", "String", "ac", "collector")]),
                step("キー2の値は `bb` のままです。出力は `ac:bb` です。", [12], [variable("output", "String", "ac:bb", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-optional-orelse-throwing-001",
            category: "optional-api",
            tags: ["模試専用", "Optional", "orElse", "orElseGet"],
            code: """
import java.util.*;

public class Test {
    static String fail() {
        throw new RuntimeException("boom");
    }
    public static void main(String[] args) {
        Optional<String> opt = Optional.of("ok");
        try {
            System.out.println(opt.orElse(fail()));
        } catch (RuntimeException e) {
            System.out.println(e.getMessage());
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "ok", misconception: "orElseの引数が遅延評価されると誤解", explanation: "`orElse` の引数はメソッド呼び出し前に評価されるため、`fail()` が先に実行されます。"),
                choice("b", "boom", correct: true, explanation: "`opt` は値を持っていますが、`orElse(fail())` の `fail()` は先に評価され、例外がcatchされます。"),
                choice("c", "Optional[ok]", misconception: "Optional自体が出力されると誤解", explanation: "`orElse` は中身のStringを返すメソッドです。ただし今回は引数評価で例外になります。"),
                choice("d", "コンパイルエラー", misconception: "orElseにメソッド呼び出しを渡せないと誤解", explanation: "型はStringなのでコンパイルできます。実行時にfailが例外を投げます。"),
            ],
            intent: "Optional.orElseは引数を即時評価し、orElseGetとは違うことを確認する。",
            steps: [
                step("`Optional.of(\"ok\")` により、Optionalは値を持っています。", [8], [variable("opt", "Optional<String>", "ok", "main")]),
                step("しかし `orElse(fail())` の引数 `fail()` は、orElse呼び出し前に評価されます。`fail()` はRuntimeExceptionを投げます。", [4, 5, 10], [variable("argument", "String", "throws RuntimeException", "main")]),
                step("catchブロックで例外メッセージ `boom` を出力します。値がある場合に代替処理を遅延したいなら `orElseGet` です。", [11, 12], [variable("output", "String", "boom", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-generics-bridge-cast-001",
            category: "generics",
            tags: ["模試専用", "Generics", "heap pollution", "ClassCastException"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List raw = new ArrayList<String>();
        raw.add(100);
        List<String> strings = raw;
        try {
            String s = strings.get(0);
            System.out.println(s);
        } catch (ClassCastException e) {
            System.out.println("CCE");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "100", misconception: "IntegerがStringとして扱えると誤解", explanation: "取り出し時にStringへの暗黙キャストが入り、IntegerはStringへキャストできません。"),
                choice("b", "CCE", correct: true, explanation: "raw型経由でIntegerが入り、`List<String>` から取り出す時点でClassCastExceptionになります。"),
                choice("c", "コンパイルエラー", misconception: "raw型代入が禁止されると誤解", explanation: "unchecked警告は出ますが、通常はコンパイルできます。"),
                choice("d", "ArrayStoreException", misconception: "配列の実行時型検査と混同", explanation: "これは配列ではなくジェネリクスのヒープ汚染です。発生するのはClassCastExceptionです。"),
            ],
            intent: "raw型によるヒープ汚染と取り出し時の暗黙キャストを確認する。",
            steps: [
                step("`raw` は生のList型なので、`new ArrayList<String>()` に対してIntegerの100を追加できてしまいます。", [5, 6], [variable("raw", "List", "[100]", "main")]),
                step("`List<String> strings = raw;` はunchecked警告を伴いますがコンパイルできます。型安全性は崩れています。", [7], [variable("strings", "List<String>", "same raw list", "main")]),
                step("`strings.get(0)` の結果にはStringへの暗黙キャストが入り、実体がIntegerなので `ClassCastException` になります。", [9, 11, 12], [variable("output", "String", "CCE", "catch")]),
            ]
        ),
        q(
            "gold-mock-additional-generics-extends-add-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "generics",
            tags: ["模試専用", "Generics", "? extends", "コンパイルエラー"],
            code: """
import java.util.*;

class Test {
    void add(List<? extends Number> list) {
        list.add(1);
    }
}
""",
            question: "このコードについて正しい説明はどれか？",
            choices: [
                choice("a", "正常にコンパイルできる", misconception: "? extendsを追加用と誤解", explanation: "`? extends Number` は具体的な要素型が不明なため、Integerを安全には追加できません。"),
                choice("b", "`list.add(1)` が原因でコンパイルエラーになる", correct: true, explanation: "`List<Integer>` かもしれませんが `List<Double>` かもしれないため、非null値は追加できません。"),
                choice("c", "実行時にClassCastExceptionになる", misconception: "コンパイル時制約を実行時問題として読んでいる", explanation: "このコードは実行前にコンパイルで拒否されます。"),
                choice("d", "`Number` にキャストすれば必ず追加できる", misconception: "上限境界の安全性を誤解", explanation: "Numberにしても、実体がList<Double>ならInteger/Numberの追加は安全ではありません。"),
            ],
            intent: "? extendsは読み取り中心で、非null要素を追加できないことを確認する。",
            steps: [
                step("`List<? extends Number>` は、Numberの何らかのサブタイプのListです。具体的な型は呼び出し側で決まります。", [4], [variable("list", "List<? extends Number>", "unknown subtype", "method")]),
                step("実体が `List<Double>` の可能性もあるため、`Integer` である `1` を追加することは型安全ではありません。", [5], [variable("argument", "Integer", "1", "compiler")]),
                step("そのため `list.add(1)` はコンパイルエラーです。読み取りはNumberとして安全ですが、追加は基本的にnull以外できません。", [5], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "gold-mock-additional-collections-tree-map-comparator-001",
            category: "collections",
            tags: ["模試専用", "TreeMap", "Comparator", "key equality"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Map<String, Integer> map = new TreeMap<>(Comparator.comparingInt(String::length));
        map.put("a", 1);
        map.put("b", 2);
        map.put("cc", 3);
        System.out.println(map.size() + ":" + map.get("a") + ":" + map.get("b"));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "3:1:2", misconception: "String.equalsでキーが区別されると誤解", explanation: "TreeMapではComparatorが0とみなすキーは同じキーとして扱われます。"),
                choice("b", "2:2:2", correct: true, explanation: "aとbは長さが同じでComparator上同一キー扱い。bのputで値が2に置き換わり、サイズは2です。"),
                choice("c", "2:1:2", misconception: "サイズだけ置換され値は別管理と誤解", explanation: "同じComparatorキーなので、値も後からputした2に置き換わります。"),
                choice("d", "ClassCastException", misconception: "自然順でないComparatorを使えないと誤解", explanation: "Comparatorを明示しているため、自然順Comparableは不要です。"),
            ],
            intent: "TreeMapのキー同一性がComparatorの比較結果に依存することを確認する。",
            steps: [
                step("TreeMapは `Comparator.comparingInt(String::length)` でキーを比較します。長さが同じなら比較結果は0です。", [5], [variable("comparator", "Comparator<String>", "compare by length", "TreeMap")]),
                step("`a` と `b` はどちらも長さ1なので、TreeMap上は同じキーとして扱われます。`b` のputで値が2に置き換わります。", [6, 7], [variable("length 1 entry", "Map.Entry", "key representative, value=2", "map")]),
                step("`cc` は長さ2なので別キーです。サイズは2、`get(\"a\")` も `get(\"b\")` も長さ1のエントリを見て2を返します。", [8, 9], [variable("output", "String", "2:2:2", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-collections-removeif-001",
            category: "collections",
            tags: ["模試専用", "removeIf", "List"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<Integer> list = new ArrayList<>(List.of(1, 2, 3, 4));
        boolean changed = list.removeIf(n -> n % 2 == 0);
        System.out.println(changed + ":" + list);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true:[1, 3]", correct: true, explanation: "偶数2と4が削除され、1件以上削除されたため戻り値はtrueです。"),
                choice("b", "false:[1, 3]", misconception: "戻り値を削除後の空判定と誤解", explanation: "`removeIf` の戻り値はコレクションが変更されたかどうかです。"),
                choice("c", "true:[2, 4]", misconception: "条件に一致した要素が残ると誤解", explanation: "`removeIf` は条件に一致した要素を削除します。"),
                choice("d", "ConcurrentModificationException", misconception: "removeIfも走査中削除で失敗すると誤解", explanation: "`removeIf` はコレクションが提供する削除メソッドで、安全に処理できます。"),
            ],
            intent: "removeIfの削除対象と戻り値を確認する。",
            steps: [
                step("初期Listは `[1, 2, 3, 4]` です。Predicateは偶数でtrueになります。", [5, 6], [variable("list", "List<Integer>", "[1, 2, 3, 4]", "main")]),
                step("`removeIf` はPredicateがtrueになった要素を削除します。したがって2と4が取り除かれます。", [6], [variable("list", "List<Integer>", "[1, 3]", "main")]),
                step("削除が発生したため戻り値 `changed` はtrueです。出力は `true:[1, 3]` です。", [6, 7], [variable("changed", "boolean", "true", "main")]),
            ]
        ),
        q(
            "gold-mock-additional-concurrency-submit-runnable-result-001",
            category: "concurrency",
            tags: ["模試専用", "ExecutorService", "submit", "Runnable"],
            code: """
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) throws Exception {
        ExecutorService service = Executors.newSingleThreadExecutor();
        try {
            Future<String> future = service.submit(() -> System.out.print("run"), "done");
            System.out.println(":" + future.get());
        } finally {
            service.shutdown();
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "run:done", correct: true, explanation: "`submit(Runnable, result)` はRunnable完了後、指定したresultをFutureの結果にします。"),
                choice("b", ":done", misconception: "Runnable本体が実行されないと誤解", explanation: "Runnableは実行され、`run` を出力します。"),
                choice("c", "run:null", misconception: "RunnableのFutureは常にnullと誤解", explanation: "1引数のsubmit(Runnable)なら結果はnullですが、今回はresultを指定しています。"),
                choice("d", "done:run", misconception: "Future結果が先に出力されると誤解", explanation: "単一スレッドでRunnableが `run` を出力し、get後にmainが `:done` を出力します。"),
            ],
            intent: "ExecutorService.submit(Runnable, result)のFuture結果を確認する。",
            steps: [
                step("`submit(() -> System.out.print(\"run\"), \"done\")` はRunnableとFuture結果用の値を渡すオーバーロードです。", [7], [variable("future result", "String", "done", "executor")]),
                step("タスク実行時にRunnable本体が `run` を出力します。Runnable自体は値を返しません。", [7], [variable("task output", "String", "run", "stdout")]),
                step("タスク完了後、`future.get()` は指定済みの結果 `done` を返します。mainが `:done` を出力し、全体は `run:done` です。", [8], [variable("output", "String", "run:done", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-concurrency-completable-exceptionally-001",
            category: "concurrency",
            tags: ["模試専用", "CompletableFuture", "exceptionally"],
            code: """
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) {
        int result = CompletableFuture.<Integer>failedFuture(new RuntimeException())
            .exceptionally(e -> 4)
            .thenApply(n -> n * 2)
            .join();
        System.out.println(result);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "4", misconception: "thenApplyを見落とし", explanation: "`exceptionally` で4に回復した後、`thenApply` で2倍されます。"),
                choice("b", "8", correct: true, explanation: "例外完了を `exceptionally` が4へ回復し、次の `thenApply` で8になります。"),
                choice("c", "RuntimeException", misconception: "exceptionallyの回復を見落とし", explanation: "例外は値4へ回復しているため、joinは例外を投げません。"),
                choice("d", "0", misconception: "例外時に数値デフォルトになると誤解", explanation: "デフォルト値ではなく、ラムダが返す4が後続に渡ります。"),
            ],
            intent: "CompletableFuture.exceptionallyで例外完了を通常値に回復し、後続処理へ進むことを確認する。",
            steps: [
                step("`failedFuture` はRuntimeExceptionで例外完了したCompletableFutureを作ります。", [5], [variable("stage1", "CompletableFuture<Integer>", "failed", "main")]),
                step("`exceptionally(e -> 4)` が例外を受け取り、代替値4で正常完了に戻します。", [6], [variable("recovered", "Integer", "4", "pipeline")]),
                step("後続の `thenApply(n -> n * 2)` が4を2倍し、`join()` の結果は8です。", [7, 8, 9], [variable("result", "int", "8", "main")]),
            ]
        ),
        q(
            "gold-mock-additional-concurrency-executor-no-shutdown-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "concurrency",
            tags: ["模試専用", "ExecutorService", "shutdown", "lifecycle"],
            code: """
ExecutorService service = Executors.newSingleThreadExecutor();
service.submit(() -> System.out.println("task"));
// service.shutdown(); がない
""",
            question: "このコードの注意点として正しいものはどれか？",
            choices: [
                choice("a", "`submit` したタスクはshutdownしないと必ず実行されない", misconception: "shutdownを実行開始条件と誤解", explanation: "shutdownは新規受付停止と終了処理であり、タスク開始そのものの条件ではありません。"),
                choice("b", "ExecutorServiceをshutdownしないと、非デーモンスレッドが残って終了を妨げることがある", correct: true, explanation: "ExecutorServiceのライフサイクル管理として、不要になったらshutdownする必要があります。"),
                choice("c", "`shutdown()` は実行中タスクを必ず強制停止する", misconception: "shutdownとshutdownNowを混同", explanation: "`shutdown()` は新規受付を止め、投入済みタスクの完了を待つ方向です。"),
                choice("d", "`submit` は自動的にshutdownまで行う", misconception: "Executorの自動終了を期待している", explanation: "ExecutorServiceは明示的な終了処理が必要です。"),
            ],
            intent: "ExecutorServiceのshutdownによるライフサイクル管理を確認する。",
            steps: [
                step("`newSingleThreadExecutor()` はタスク実行用のスレッドを管理するExecutorServiceを作ります。", [1], [variable("service", "ExecutorService", "single thread executor", "main")]),
                step("`submit` はタスクを投入しますが、ExecutorService自体の終了処理までは行いません。", [2], [variable("task", "Runnable", "submitted", "executor")]),
                step("不要になったExecutorServiceをshutdownしないと、スレッドが残りアプリケーション終了を妨げることがあります。", [3], [variable("rule", "String", "call shutdown", "lifecycle")]),
            ]
        ),
        q(
            "gold-mock-additional-concurrency-lock-object-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "concurrency",
            tags: ["模試専用", "synchronized", "lock object"],
            code: """
class Counter {
    private int count;
    void inc() {
        synchronized (new Object()) {
            count++;
        }
    }
}
""",
            question: "この `inc` メソッドの排他制御として正しい説明はどれか？",
            choices: [
                choice("a", "毎回同じロックを使うため、count++は安全に排他される", misconception: "new Objectの位置を見落とし", explanation: "呼び出しごとに別のObjectを作るため、ロックは共有されません。"),
                choice("b", "呼び出しごとに別ロックを作るため、複数スレッド間の排他にはならない", correct: true, explanation: "synchronizedは同じロックを共有して初めて排他になります。"),
                choice("c", "new Object() はコンパイルエラーになる", misconception: "任意オブジェクトをロックに使えないと誤解", explanation: "任意の参照型オブジェクトをロックにできます。問題は共有されないことです。"),
                choice("d", "volatileと同じ可視性だけを保証する", misconception: "synchronizedとvolatileを混同", explanation: "synchronizedはロックによる排他と可視性に関係しますが、このコードではロック共有ができていません。"),
            ],
            intent: "synchronizedは同じロックオブジェクトを共有しなければ排他にならないことを確認する。",
            steps: [
                step("`synchronized (new Object())` は、incが呼ばれるたびに新しいロックオブジェクトを作ります。", [3, 4], [variable("lock", "Object", "new object per call", "inc")]),
                step("別スレッドが同時にincを呼んだ場合、それぞれ別のロックを取るため、互いに待ち合いません。", [4], [variable("mutual exclusion", "boolean", "false across calls", "Counter")]),
                step("`count++` を守るには、フィールドに保持した共通ロックや `synchronized` メソッドなど、共有されるロックが必要です。", [5], [variable("rule", "String", "share the same lock", "synchronized")]),
            ]
        ),
        q(
            "gold-mock-additional-concurrency-copyonwrite-iterator-001",
            category: "concurrency",
            tags: ["模試専用", "CopyOnWriteArrayList", "Iterator"],
            code: """
import java.util.*;
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) {
        CopyOnWriteArrayList<String> list = new CopyOnWriteArrayList<>(List.of("A", "B"));
        Iterator<String> it = list.iterator();
        list.add("C");
        while (it.hasNext()) {
            System.out.print(it.next());
        }
        System.out.println(":" + list.size());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "AB:3", correct: true, explanation: "CopyOnWriteArrayListのIteratorは作成時点のスナップショットを走査します。追加後のCはIteratorには見えませんが、list.sizeは3です。"),
                choice("b", "ABC:3", misconception: "Iteratorが追加後の要素も見ると誤解", explanation: "CopyOnWriteArrayListのIteratorはスナップショットです。"),
                choice("c", "AB:2", misconception: "list自体にもCが追加されないと誤解", explanation: "list.add(\"C\") は成功しており、リストのサイズは3です。"),
                choice("d", "ConcurrentModificationException", misconception: "通常のArrayList Iteratorと混同", explanation: "CopyOnWriteArrayListのIteratorはConcurrentModificationExceptionを投げません。"),
            ],
            intent: "CopyOnWriteArrayListのスナップショットIteratorを確認する。",
            steps: [
                step("初期リストはA,Bです。この時点でIteratorを作成するため、IteratorはA,Bのスナップショットを持ちます。", [6, 7], [variable("iterator snapshot", "String[]", "A, B", "iterator")]),
                step("その後 `list.add(\"C\")` で実際のリストにはCが追加され、サイズは3になります。", [8], [variable("list", "CopyOnWriteArrayList<String>", "[A, B, C]", "main")]),
                step("IteratorはスナップショットのA,Bだけを出力し、最後に現在のlist.sizeで3を出力します。結果は `AB:3` です。", [9, 10, 12], [variable("output", "String", "AB:3", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-module-transitive-static-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "module-system",
            tags: ["模試専用", "module", "requires transitive"],
            code: """
module a {
    requires transitive b;
}
module c {
    requires a;
}
""",
            question: "このモジュール関係について正しい説明はどれか？",
            choices: [
                choice("a", "cはaだけを読み、bは読めない", misconception: "transitiveを通常requiresと同じ扱いにしている", explanation: "aがbをrequires transitiveしているため、aを読むcにもbの読み取りが伝播します。"),
                choice("b", "cはaをrequiresすることでbも読み取れる", correct: true, explanation: "`requires transitive` は依存先の読み取りを利用側へ伝播させます。"),
                choice("c", "bの全パッケージが自動的にexportsされる", misconception: "readabilityとexportsを混同", explanation: "読めることとパッケージが公開されることは別です。"),
                choice("d", "requires transitiveは実行時だけ有効でコンパイル時は無効", misconception: "モジュール解決を実行時専用と誤解", explanation: "コンパイル時の読み取り関係にも影響します。"),
            ],
            intent: "requires transitiveによる読み取り関係の伝播を確認する。",
            steps: [
                step("モジュールaは `requires transitive b;` によりbを読み取り、さらにその読み取りを利用側へ伝播します。", [1, 2], [variable("a reads", "module", "b", "module graph")]),
                step("モジュールcはaをrequiresしています。aのtransitive依存により、cからもbを読む関係が成立します。", [4, 5], [variable("c reads", "module", "a + b", "module graph")]),
                step("ただし、bを読めることと、b内のパッケージがexportsされていることは別問題です。", [2], [variable("rule", "String", "readability != exports", "module system")]),
            ]
        ),
        q(
            "gold-mock-additional-module-open-module-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "module-system",
            tags: ["模試専用", "open module", "opens"],
            code: """
open module app {
    opens app.internal;
}
""",
            question: "この module-info.java について正しい説明はどれか？",
            choices: [
                choice("a", "正しい。open module内でも個別opensは必須である", misconception: "open moduleの意味を誤解", explanation: "open moduleは全パッケージを開くため、個別opensディレクティブは書けません。"),
                choice("b", "open module内で `opens` を書いているためコンパイルエラー", correct: true, explanation: "open module宣言ではモジュール全体がopenになるため、個別のopensディレクティブは許可されません。"),
                choice("c", "`exports` も `requires` もopen moduleでは禁止される", misconception: "禁止対象を広げすぎ", explanation: "open moduleでもexportsやrequiresは使えます。禁止されるのは個別opensです。"),
                choice("d", "実行時までエラーは分からない", misconception: "module-infoの検査時期を誤解", explanation: "module-info.javaの構文・ディレクティブ制約はコンパイル時に検出されます。"),
            ],
            intent: "open moduleと個別opensディレクティブの制約を確認する。",
            steps: [
                step("`open module app` は、モジュール全体を深いリフレクション向けに開く宣言です。", [1], [variable("module", "module", "open app", "module-info")]),
                step("すでに全体がopenなので、内部で個別に `opens app.internal;` を書くことは許可されません。", [2], [variable("opens directive", "String", "not allowed in open module", "compiler")]),
                step("したがってこのmodule-info.javaはコンパイルエラーです。exportsやrequiresまで禁止されるわけではありません。", [1, 2], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "gold-mock-additional-io-readstring-nosuchfile-001",
            category: "io",
            tags: ["模試専用", "Files.readString", "NoSuchFileException"],
            code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        try {
            Files.readString(Paths.get("missing-file-for-javasta.txt"));
            System.out.println("OK");
        } catch (java.io.IOException e) {
            System.out.println(e.getClass().getSimpleName());
        }
    }
}
""",
            question: "存在しないファイルに対してこのコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "OK", misconception: "存在しないファイルを空文字として読むと誤解", explanation: "`Files.readString` は存在しないファイルを空文字として扱いません。"),
                choice("b", "NoSuchFileException", correct: true, explanation: "対象ファイルが存在しないためIOException系の `NoSuchFileException` がcatchされ、クラス名が出力されます。"),
                choice("c", "null", misconception: "読み取り失敗時にnullを返すと誤解", explanation: "失敗時は例外です。"),
                choice("d", "SecurityException", misconception: "存在しないファイルと権限エラーを混同", explanation: "この前提では存在しないことによる `NoSuchFileException` です。"),
            ],
            intent: "Files.readStringが存在しないファイルでNoSuchFileExceptionを投げることを確認する。",
            steps: [
                step("`Paths.get(\"missing-file-for-javasta.txt\")` は相対Pathを作るだけで、ファイル存在確認はまだ行いません。", [6], [variable("path", "Path", "missing-file-for-javasta.txt", "main")]),
                step("`Files.readString` が実際にファイルを開こうとし、存在しないため `NoSuchFileException` が発生します。", [6, 8], [variable("exception", "NoSuchFileException", "missing file", "catch")]),
                step("catchブロックでは例外クラスの単純名を出力するので、結果は `NoSuchFileException` です。", [9], [variable("output", "String", "NoSuchFileException", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-io-path-relativize-001",
            category: "io",
            tags: ["模試専用", "Path", "relativize"],
            code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path a = Paths.get("/work/app/src");
        Path b = Paths.get("/work/test/out");
        System.out.println(a.relativize(b));
    }
}
""",
            question: "Unix系のPathとしてこのコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "../../test/out", correct: true, explanation: "`/work/app/src` から `/work/test/out` へ行くにはsrcからappへ、appからworkへ戻り、test/outへ進みます。"),
                choice("b", "../test/out", misconception: "戻る階層数を1つ少なく見ている", explanation: "共通部分は `/work` なので、`app/src` の2階層分戻ります。"),
                choice("c", "/work/test/out", misconception: "relativizeが絶対パスを返すと誤解", explanation: "`relativize` は基準Pathから対象Pathへの相対Pathを作ります。"),
                choice("d", "IllegalArgumentException", misconception: "同じルート同士でも相対化できないと誤解", explanation: "どちらも同じ絶対パスのルートなので相対化できます。"),
            ],
            intent: "Path.relativizeの共通祖先と戻る階層を確認する。",
            steps: [
                step("基準Pathは `/work/app/src`、対象Pathは `/work/test/out` です。共通部分は `/work` です。", [5, 6], [variable("common root", "Path", "/work", "path calculation")]),
                step("基準側の残りは `app/src` なので2階層戻る必要があります。その後 `test/out` へ進みます。", [7], [variable("relative path", "Path", "../../test/out", "main")]),
                step("したがって `a.relativize(b)` の出力は `../../test/out` です。", [7], [variable("output", "String", "../../test/out", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-serialization-readresolve-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "secure-coding",
            tags: ["模試専用", "serialization", "readResolve"],
            code: """
class Token implements Serializable {
    static final Token INSTANCE = new Token();
    private Object readResolve() {
        return INSTANCE;
    }
}
""",
            question: "`readResolve` の役割として正しいものはどれか？",
            choices: [
                choice("a", "シリアライズ時にフィールドを書き込まないようにする", misconception: "transientと混同", explanation: "保存対象から外すのは `transient` の役割です。"),
                choice("b", "デシリアライズ後に返すオブジェクトを差し替えられる", correct: true, explanation: "`readResolve` は復元されたオブジェクトの代わりに返すインスタンスを指定できます。シングルトン維持などで使われます。"),
                choice("c", "必ずpublicでなければ呼ばれない", misconception: "アクセス修飾子を誤解", explanation: "`readResolve` はprivateでも定義されることがあります。"),
                choice("d", "serialVersionUIDを自動生成する", misconception: "シリアライズ互換性と混同", explanation: "serialVersionUIDは互換性識別子であり、readResolveの役割ではありません。"),
            ],
            intent: "readResolveによるデシリアライズ後のインスタンス差し替えを確認する。",
            steps: [
                step("通常のデシリアライズでは、ストリームから新しいオブジェクトが復元されます。", [1], [variable("deserialized object", "Token", "new restored object", "ObjectInputStream")]),
                step("`readResolve` を定義していると、復元後にその戻り値を最終的なオブジェクトとして使えます。", [3, 4, 5], [variable("resolved object", "Token", "Token.INSTANCE", "serialization")]),
                step("この例では `INSTANCE` を返すため、シングルトンの同一性維持に使える、という読み方になります。", [2, 4], [variable("purpose", "String", "preserve singleton", "secure coding")]),
            ]
        ),
        q(
            "gold-mock-additional-serialization-transient-final-001",
            category: "secure-coding",
            tags: ["模試専用", "serialization", "transient"],
            code: """
import java.io.*;

class User implements Serializable {
    String name = "A";
    transient int score = 10;
}

public class Test {
    public static void main(String[] args) throws Exception {
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        new ObjectOutputStream(bout).writeObject(new User());
        ObjectInputStream in = new ObjectInputStream(
            new ByteArrayInputStream(bout.toByteArray()));
        User u = (User) in.readObject();
        System.out.println(u.name + ":" + u.score);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A:10", misconception: "transientフィールドも保存されると誤解", explanation: "`score` はtransientなのでデフォルトシリアライズ対象外です。"),
                choice("b", "A:0", correct: true, explanation: "`name` は保存されますが、transientなint `score` は復元時にデフォルト値0になります。"),
                choice("c", "null:0", misconception: "通常フィールドも保存されないと誤解", explanation: "`name` はtransientではないため、値Aが保存・復元されます。"),
                choice("d", "A:null", misconception: "intのデフォルト値をnullと誤解", explanation: "intはプリミティブなのでデフォルト値は0です。"),
            ],
            intent: "transientフィールドがシリアライズ対象外となり、復元時にデフォルト値になることを確認する。",
            steps: [
                step("`User` はSerializableで、`name` は通常フィールド、`score` は `transient int` です。", [3, 4, 5], [variable("name", "String", "A", "before serialization"), variable("score", "int", "10 transient", "before serialization")]),
                step("デフォルトシリアライズではtransientフィールドは保存されません。`name` のAだけが通常通り保存されます。", [10, 11], [variable("serialized fields", "String", "name only", "ObjectOutputStream")]),
                step("復元後、`score` はintのデフォルト値0になります。出力は `A:0` です。", [14, 15], [variable("output", "String", "A:0", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-localization-locale-builder-001",
            category: "localization",
            tags: ["模試専用", "Locale.Builder", "Locale"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Locale locale = new Locale.Builder()
            .setLanguage("ja")
            .setRegion("JP")
            .build();
        System.out.println(locale.toLanguageTag());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "ja-JP", correct: true, explanation: "言語ja、地域JPのLocaleを作り、BCP 47形式の言語タグとして `ja-JP` が出力されます。"),
                choice("b", "ja_JP", misconception: "Locale.toStringと混同", explanation: "`toLanguageTag()` はハイフン区切りの言語タグを返します。"),
                choice("c", "JP-ja", misconception: "言語と地域の順序を逆にしている", explanation: "言語が先、地域が後です。"),
                choice("d", "Japanese_Japan", misconception: "表示名とタグを混同", explanation: "表示名ではなく言語タグを出力しています。"),
            ],
            intent: "Locale.BuilderとtoLanguageTagの表記を確認する。",
            steps: [
                step("`Locale.Builder` で言語 `ja`、地域 `JP` を指定しています。", [5, 6, 7, 8], [variable("language", "String", "ja", "Locale.Builder"), variable("region", "String", "JP", "Locale.Builder")]),
                step("`build()` により日本語/日本のLocaleが作られます。", [8], [variable("locale", "Locale", "ja_JP", "main")]),
                step("`toLanguageTag()` はBCP 47形式のハイフン区切りを返すため、出力は `ja-JP` です。", [9], [variable("output", "String", "ja-JP", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-localization-choiceformat-001",
            difficulty: .tricky,
            category: "localization",
            tags: ["模試専用", "ChoiceFormat", "MessageFormat"],
            code: """
import java.text.*;

public class Test {
    public static void main(String[] args) {
        MessageFormat mf = new MessageFormat("{0,choice,0#none|1#one|1<many}");
        System.out.println(mf.format(new Object[]{1}));
        System.out.println(mf.format(new Object[]{2}));
    }
}
""",
            question: "このコードを実行したとき、出力として正しい組み合わせはどれか？",
            choices: [
                choice("a", "one と many", correct: true, explanation: "`1#one` は1以上の境界で1に一致し、`1<many` は1より大きい値に一致します。"),
                choice("b", "many と many", misconception: "1<が1以上だと誤解", explanation: "`1<` は1より大きい値です。1は `1#one` に一致します。"),
                choice("c", "none と one", misconception: "境界の読み方を誤解", explanation: "1はone、2はmanyです。"),
                choice("d", "コンパイルエラー", misconception: "choice形式をMessageFormatで使えないと誤解", explanation: "MessageFormatのchoiceサブフォーマットとして使用できます。"),
            ],
            intent: "ChoiceFormatの#と<の境界条件を確認する。",
            steps: [
                step("パターンは `0#none|1#one|1<many` です。`#` はその境界以上、`<` はその値より大きい範囲を表します。", [5], [variable("pattern", "String", "0#none|1#one|1<many", "MessageFormat")]),
                step("値1は `1#one` に該当します。`1<many` は1より大きい値なので、1には該当しません。", [6], [variable("format(1)", "String", "one", "main")]),
                step("値2は1より大きいため `many` です。出力は1行目 `one`、2行目 `many` です。", [7], [variable("format(2)", "String", "many", "main")]),
            ]
        ),
        q(
            "gold-mock-additional-datetime-zoned-gap-001",
            difficulty: .tricky,
            category: "date-time",
            tags: ["模試専用", "ZonedDateTime", "DST"],
            code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        ZoneId zone = ZoneId.of("America/New_York");
        ZonedDateTime zdt = ZonedDateTime.of(
            LocalDate.of(2024, 3, 10),
            LocalTime.of(2, 30),
            zone
        );
        System.out.println(zdt.toLocalTime());
    }
}
""",
            question: "このコードを実行したとき、出力される時刻はどれか？",
            choices: [
                choice("a", "02:30", misconception: "存在しないローカル時刻がそのまま使われると誤解", explanation: "ニューヨークのこの日時はDST開始で02:30がギャップに入ります。"),
                choice("b", "03:30", correct: true, explanation: "DSTのギャップに入るローカル時刻は、通常ギャップ後の有効な時刻へ調整されます。"),
                choice("c", "01:30", misconception: "前の有効時刻へ戻ると誤解", explanation: "ギャップでは後ろへ進められます。"),
                choice("d", "DateTimeException", misconception: "ZonedDateTime.ofが必ず例外にすると誤解", explanation: "この生成方法ではギャップを調整して有効なZonedDateTimeを作ります。"),
            ],
            intent: "ZonedDateTimeでDSTギャップのローカル時刻が調整されることを確認する。",
            steps: [
                step("America/New_Yorkでは2024-03-10に夏時間が始まり、02時台が存在しないギャップになります。", [5, 7, 8], [variable("local time", "LocalTime", "02:30 in DST gap", "zone rules")]),
                step("`ZonedDateTime.of` はこのギャップ内のローカル時刻を、ギャップ後の有効な時刻へ調整します。", [6, 9, 10], [variable("adjusted time", "LocalTime", "03:30", "ZonedDateTime")]),
                step("`toLocalTime()` で調整後の時刻部分を出力するため、結果は `03:30` です。", [11], [variable("output", "String", "03:30", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-datetime-instant-period-001",
            difficulty: .tricky,
            category: "date-time",
            tags: ["模試専用", "Instant", "Period", "UnsupportedTemporalTypeException"],
            code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        try {
            Instant.now().plus(Period.ofMonths(1));
            System.out.println("OK");
        } catch (DateTimeException e) {
            System.out.println(e.getClass().getSimpleName());
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "OK", misconception: "Instantにも月ベースPeriodを足せると誤解", explanation: "Instantは機械的な時点であり、月のようなカレンダー依存の単位をサポートしません。"),
                choice("b", "UnsupportedTemporalTypeException", correct: true, explanation: "`Period.ofMonths(1)` は月ベース量で、Instantへの加算ではサポートされない単位が使われます。"),
                choice("c", "ArithmeticException", misconception: "オーバーフローと混同", explanation: "この問題は数値範囲ではなく、サポートされない時間単位です。"),
                choice("d", "NullPointerException", misconception: "Periodがnullだと誤解", explanation: "`Period.ofDays(1)` は有効なPeriodを返します。"),
            ],
            intent: "Instantに月ベースのPeriodを加算できないことを確認する。",
            steps: [
                step("`Instant.now()` はタイムライン上の瞬間を表します。年月日カレンダーの概念とは切り離されています。", [6], [variable("instant", "Instant", "current moment", "main")]),
                step("`Period.ofMonths(1)` は月ベースの量です。Instantには月の長さを判断するためのカレンダー文脈がないため、適用できません。", [6], [variable("period", "Period", "P1M", "main")]),
                step("例外は `DateTimeException` のサブクラスである `UnsupportedTemporalTypeException` としてcatchされ、クラス名が出力されます。", [8, 9], [variable("output", "String", "UnsupportedTemporalTypeException", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-annotation-repeatable-container-001",
            difficulty: .tricky,
            category: "annotations",
            tags: ["模試専用", "Repeatable", "reflection"],
            code: """
import java.lang.annotation.*;

@Repeatable(Tags.class)
@Retention(RetentionPolicy.RUNTIME)
@interface Tag { String value(); }

@Retention(RetentionPolicy.RUNTIME)
@interface Tags { Tag[] value(); }

@Tag("A")
@Tag("B")
class Item {}

public class Test {
    public static void main(String[] args) {
        System.out.println(Item.class.getAnnotationsByType(Tag.class).length);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", misconception: "繰り返しアノテーションが実行時に見えないと誤解", explanation: "TagとコンテナTagsの両方にRUNTIMEが付いています。"),
                choice("b", "1", misconception: "コンテナアノテーション1個だけを数えると誤解", explanation: "`getAnnotationsByType(Tag.class)` は繰り返されたTagを展開して返します。"),
                choice("c", "2", correct: true, explanation: "`@Tag(\"A\")` と `@Tag(\"B\")` の2つが取得されます。"),
                choice("d", "コンパイルエラー", misconception: "@Repeatableの基本形を誤解", explanation: "コンテナ `Tags` が `Tag[] value()` を持つため、正しい定義です。"),
            ],
            intent: "RepeatableアノテーションとgetAnnotationsByTypeの取得件数を確認する。",
            steps: [
                step("`Tag` は `@Repeatable(Tags.class)` で繰り返し可能にされ、実行時保持も指定されています。", [3, 4, 5], [variable("Tag", "annotation", "repeatable runtime", "annotation")]),
                step("`Item` には `@Tag(\"A\")` と `@Tag(\"B\")` が2つ付いています。", [10, 11, 12], [variable("annotations", "Tag[]", "A, B", "Item")]),
                step("`getAnnotationsByType(Tag.class)` はコンテナを展開してTag配列を返すため、lengthは2です。", [16], [variable("output", "int", "2", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-annotation-default-value-001",
            category: "annotations",
            tags: ["模試専用", "annotation", "default"],
            code: """
import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)
@interface Level {
    int value() default 3;
}

@Level
class Service {}

public class Test {
    public static void main(String[] args) {
        Level level = Service.class.getAnnotation(Level.class);
        System.out.println(level.value());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", misconception: "intのデフォルト値とアノテーションdefaultを混同", explanation: "アノテーション要素には `default 3` が明示されています。"),
                choice("b", "3", correct: true, explanation: "`@Level` で値を省略しているため、要素 `value` のdefault値3が使われます。"),
                choice("c", "null", misconception: "プリミティブ要素がnullになると誤解", explanation: "intはnullになりません。"),
                choice("d", "NoSuchElementException", misconception: "値省略がエラーになると誤解", explanation: "defaultがあるため省略できます。"),
            ],
            intent: "アノテーション要素のdefault値と省略時の取得を確認する。",
            steps: [
                step("`Level` アノテーションの要素 `value` には `default 3` が指定されています。", [3, 4, 5], [variable("default value", "int", "3", "Level")]),
                step("`@Level` は値を明示していませんが、defaultがあるため有効です。", [8, 9], [variable("Service annotation", "Level", "value omitted", "class")]),
                step("リフレクションで取得した `level.value()` は省略時の値3を返します。", [13, 14], [variable("output", "int", "3", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-exception-suppressed-multiple-001",
            difficulty: .tricky,
            category: "exception-handling",
            tags: ["模試専用", "try-with-resources", "suppressed"],
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
            throw new RuntimeException("body");
        } catch (RuntimeException e) {
            System.out.println(e.getMessage() + ":" + e.getSuppressed()[0].getMessage());
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "body:B", correct: true, explanation: "本体例外bodyが主例外。closeは逆順なのでBの例外が最初の抑制例外になります。"),
                choice("b", "B:A", misconception: "close例外が主例外になると誤解", explanation: "try本体で既に例外がある場合、それが主例外でclose例外はsuppressedです。"),
                choice("c", "body:A", misconception: "リソースが宣言順に閉じると誤解", explanation: "try-with-resourcesは逆順に閉じるため、Bが先です。"),
                choice("d", "A:B", misconception: "本体例外を見落とし", explanation: "本体で `body` が投げられているため主例外はbodyです。"),
            ],
            intent: "try-with-resourcesのclose逆順とsuppressed例外の順序を確認する。",
            steps: [
                step("try本体で `RuntimeException(\"body\")` が投げられます。これが主例外になります。", [11, 12], [variable("primary", "RuntimeException", "body", "try")]),
                step("リソースは宣言と逆順に閉じられるため、まずbのcloseが実行され `B` の例外が発生します。", [11, 4, 5], [variable("first suppressed", "RuntimeException", "B", "close")]),
                step("catchで主例外メッセージと最初のsuppressedメッセージを出力するため、結果は `body:B` です。", [13, 14], [variable("output", "String", "body:B", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-exception-precise-rethrow-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "exception-handling",
            tags: ["模試専用", "multi-catch", "precise rethrow"],
            code: """
import java.io.*;
import java.sql.*;

class Test {
    static void run() throws IOException, SQLException {
        try {
            if (System.currentTimeMillis() > 0) throw new IOException();
            throw new SQLException();
        } catch (Exception e) {
            throw e;
        }
    }
}
""",
            question: "このコードの `throw e;` について正しい説明はどれか？",
            choices: [
                choice("a", "`run` は `throws Exception` と宣言しないと必ずコンパイルできない", misconception: "precise rethrowを知らない", explanation: "catch変数を再代入していない場合、コンパイラはtry内で投げられ得る検査例外に絞って再throwを解析できます。"),
                choice("b", "`throws IOException, SQLException` でコンパイルできる", correct: true, explanation: "try内で投げられる検査例外がIOExceptionとSQLExceptionに限定され、catch変数を変更していないためprecise rethrowが働きます。"),
                choice("c", "`throw e;` は常にRuntimeExceptionに変換される", misconception: "再throwの型を誤解", explanation: "例外型は自動でRuntimeExceptionに変換されません。"),
                choice("d", "catchの型がExceptionなら検査例外チェックは不要になる", misconception: "catchするとthrows不要と誤解", explanation: "catch内で再throwしているため、呼び出し側へ投げる宣言が必要です。"),
            ],
            intent: "precise rethrowによりcatch(Exception)でもthrowsを絞れることを確認する。",
            steps: [
                step("tryブロック内で投げられ得る検査例外は `IOException` と `SQLException` です。", [6, 7, 8], [variable("possible checked exceptions", "Class[]", "IOException, SQLException", "try")]),
                step("catch変数 `e` は再代入されていません。この場合、Javaはprecise rethrowとして、再throwされる型をtry内の可能性に絞れます。", [9, 10], [variable("e", "Exception", "effectively final catch parameter", "catch")]),
                step("したがってメソッド宣言は `throws IOException, SQLException` で足ります。`throws Exception` まで広げる必要はありません。", [5, 10], [variable("throws", "String", "IOException, SQLException", "method")]),
            ]
        ),
        q(
            "gold-mock-additional-jdbc-generated-keys-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["模試専用", "JDBC", "generated keys"],
            code: """
PreparedStatement ps = con.prepareStatement(
    "INSERT INTO users(name) VALUES (?)",
    Statement.RETURN_GENERATED_KEYS
);
ps.setString(1, "A");
ps.executeUpdate();
ResultSet keys = ps.getGeneratedKeys();
""",
            question: "自動生成キーを取得するための説明として正しいものはどれか？",
            choices: [
                choice("a", "`prepareStatement` 時に `Statement.RETURN_GENERATED_KEYS` を指定する", correct: true, explanation: "生成キーを取得したい場合、Statement作成時に生成キー返却を要求し、実行後に `getGeneratedKeys()` を呼びます。"),
                choice("b", "`executeQuery()` を使わないとINSERTは実行できない", misconception: "SELECT用APIと混同", explanation: "INSERT/UPDATE/DELETEは通常 `executeUpdate()` を使います。"),
                choice("c", "`getGeneratedKeys()` は実行前に呼ぶ", misconception: "取得タイミングを誤解", explanation: "SQL実行後に生成されたキーを取得します。"),
                choice("d", "パラメータ番号は0から始まる", misconception: "JDBCパラメータ番号を配列と混同", explanation: "`ps.setString(1, \"A\")` のように1始まりです。"),
            ],
            intent: "JDBCで自動生成キーを取得するためのprepareStatement指定と実行順を確認する。",
            steps: [
                step("INSERT文のPreparedStatementを作るとき、第二引数に `Statement.RETURN_GENERATED_KEYS` を指定しています。", [1, 2, 3], [variable("generated keys flag", "int", "RETURN_GENERATED_KEYS", "PreparedStatement")]),
                step("パラメータは1始まりなので、`setString(1, \"A\")` が1つ目の `?` に対応します。INSERTは `executeUpdate()` で実行します。", [5, 6], [variable("parameter 1", "String", "A", "JDBC")]),
                step("実行後に `ps.getGeneratedKeys()` を呼ぶことで、自動生成キーのResultSetを取得できます。", [7], [variable("keys", "ResultSet", "generated keys", "JDBC")]),
            ]
        ),
        q(
            "gold-mock-additional-jdbc-transaction-rollback-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["模試専用", "JDBC", "transaction", "rollback"],
            code: """
try {
    con.setAutoCommit(false);
    updateA(con);
    updateB(con);
    con.commit();
} catch (SQLException e) {
    con.rollback();
}
""",
            question: "このトランザクション処理について正しい説明はどれか？",
            choices: [
                choice("a", "`setAutoCommit(false)` により、明示的なcommit/rollbackで境界を制御する", correct: true, explanation: "自動コミットを無効化すると、成功時にcommit、失敗時にrollbackする形で複数更新をまとめられます。"),
                choice("b", "`commit()` は失敗時に呼ぶ", misconception: "commitとrollbackを逆に理解", explanation: "commitは成功した変更を確定する操作です。失敗時はrollbackです。"),
                choice("c", "`rollback()` はSELECT文にしか使えない", misconception: "トランザクション対象を誤解", explanation: "rollbackは未確定の更新を取り消すために使われます。"),
                choice("d", "autoCommitをfalseにしても各SQLは即時確定される", misconception: "autoCommitの意味を見落とし", explanation: "falseにすると明示的なcommitまで確定しません。"),
            ],
            intent: "JDBCトランザクションのautoCommit、commit、rollbackの役割を確認する。",
            steps: [
                step("`con.setAutoCommit(false)` により、自動コミットを止めます。以降の更新は明示的なcommitまで確定しません。", [2], [variable("autoCommit", "boolean", "false", "Connection")]),
                step("`updateA` と `updateB` が成功した場合、`con.commit()` で一連の更新を確定します。", [3, 4, 5], [variable("transaction", "String", "updateA + updateB", "Connection")]),
                step("途中で `SQLException` が発生した場合はcatchで `rollback()` を呼び、未確定の変更を取り消します。", [6, 7], [variable("failure action", "String", "rollback", "catch")]),
            ]
        ),
        q(
            "gold-mock-additional-record-compact-constructor-001",
            category: "classes",
            tags: ["模試専用", "record", "compact constructor"],
            code: """
record User(String name) {
    User {
        name = name.trim();
    }
}

public class Test {
    public static void main(String[] args) {
        User u = new User(" A ");
        System.out.println(u.name());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", " A ", misconception: "コンパクトコンストラクタ内の代入が反映されないと誤解", explanation: "コンパクトコンストラクタでは正規コンストラクタ引数を検査・正規化でき、最後にフィールドへ代入されます。"),
                choice("b", "A", correct: true, explanation: "`name = name.trim();` により引数が正規化され、レコードコンポーネントには `A` が格納されます。"),
                choice("c", "null", misconception: "recordのアクセサが値を返さないと誤解", explanation: "`name()` はコンポーネントの値を返します。"),
                choice("d", "コンパイルエラー", misconception: "コンパクトコンストラクタで引数を書き換えられないと誤解", explanation: "コンパクトコンストラクタ内でパラメータ変数を再代入できます。"),
            ],
            intent: "recordのコンパクトコンストラクタで引数を正規化できることを確認する。",
            steps: [
                step("`new User(\" A \")` でコンパクトコンストラクタに入り、パラメータ `name` は前後に空白を持つ文字列です。", [2, 9], [variable("name parameter", "String", "\" A \"", "constructor")]),
                step("`name = name.trim();` により、パラメータ変数は空白を除いた `A` に置き換わります。", [3], [variable("name parameter", "String", "A", "constructor")]),
                step("コンパクトコンストラクタ終了時、正規化後の値がrecordフィールドへ代入されます。`u.name()` は `A` です。", [10], [variable("output", "String", "A", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-sealed-switch-coverage-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "classes",
            tags: ["模試専用", "sealed", "switch", "exhaustive"],
            code: """
sealed interface Shape permits Circle, Square {}
final class Circle implements Shape {}
final class Square implements Shape {}

class Test {
    static int area(Shape s) {
        return switch (s) {
            case Circle c -> 1;
        };
    }
}
""",
            question: "このswitch式について正しい説明はどれか？",
            choices: [
                choice("a", "Circleだけを書けば、残りは自動的に無視される", misconception: "switch式の網羅性を見落とし", explanation: "switch式は値を返すため、すべての可能性を網羅する必要があります。"),
                choice("b", "Squareを処理していないためコンパイルエラーになる", correct: true, explanation: "sealed階層では許可された実装型が分かるため、Circleだけでは網羅的ではありません。"),
                choice("c", "defaultを書いてはいけない", misconception: "sealed switchでdefault禁止と誤解", explanation: "defaultを書くことで網羅性を満たすこともできます。"),
                choice("d", "sealed型はswitchに使えない", misconception: "sealedとパターンswitchの関係を誤解", explanation: "sealed階層はswitchの網羅性判定と相性がよい機能です。"),
            ],
            intent: "sealed階層に対するswitch式の網羅性チェックを確認する。",
            steps: [
                step("`Shape` はsealed interfaceで、許可された実装は `Circle` と `Square` です。", [1, 2, 3], [variable("permitted types", "Class[]", "Circle, Square", "Shape")]),
                step("switch式では `Circle` のcaseだけが定義されています。`Square` の場合に返す値がありません。", [7, 8], [variable("covered types", "Class[]", "Circle only", "switch")]),
                step("switch式は網羅的である必要があるため、Squareのcaseまたはdefaultが必要です。このままではコンパイルエラーです。", [7, 9], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "gold-mock-additional-final-static-hide-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "classes",
            tags: ["模試専用", "static", "final", "method hiding"],
            code: """
class Parent {
    static final void m() {}
}
class Child extends Parent {
    static void m() {}
}
""",
            question: "このコードについて正しい説明はどれか？",
            choices: [
                choice("a", "staticメソッドなのでfinalでも隠蔽できる", misconception: "finalの禁止を見落とし", explanation: "staticメソッドはオーバーライドではなく隠蔽ですが、finalなstaticメソッドは隠蔽できません。"),
                choice("b", "finalなstaticメソッドを隠蔽しようとしているためコンパイルエラー", correct: true, explanation: "`Parent.m()` は `static final` なので、サブクラスで同じシグネチャのstaticメソッドを宣言できません。"),
                choice("c", "実行時にParent.mが必ず呼ばれるだけでコンパイルは通る", misconception: "コンパイル時制約を見落とし", explanation: "finalメソッドの再宣言はコンパイル時に拒否されます。"),
                choice("d", "finalはstaticメソッドには付けられない", misconception: "finalの適用対象を誤解", explanation: "staticメソッドにもfinalを付けられます。"),
            ],
            intent: "static finalメソッドはサブクラスで隠蔽できないことを確認する。",
            steps: [
                step("`Parent.m()` は `static final` メソッドです。staticなので通常は隠蔽の対象ですが、finalが付いています。", [1, 2], [variable("Parent.m", "method", "static final", "Parent")]),
                step("`Child` は同じシグネチャの `static void m()` を宣言しようとしています。これはParent.mの隠蔽にあたります。", [4, 5], [variable("Child.m", "method", "attempted hiding", "Child")]),
                step("finalなメソッドはオーバーライドも隠蔽もできないため、このコードはコンパイルエラーです。", [2, 5], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "gold-mock-additional-object-hashcode-contract-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "classes",
            tags: ["模試専用", "Object", "equals", "hashCode"],
            code: """
class Key {
    private final int id;
    Key(int id) { this.id = id; }
    public boolean equals(Object obj) {
        return obj instanceof Key k && k.id == id;
    }
}
""",
            question: "この `Key` クラスの問題点として正しいものはどれか？",
            choices: [
                choice("a", "equalsをオーバーライドしているがhashCodeをオーバーライドしていない", correct: true, explanation: "equalsで等しいオブジェクトは同じhashCodeを返す必要があります。HashMap/HashSetで問題になります。"),
                choice("b", "equalsの戻り値はintでなければならない", misconception: "Object.equalsのシグネチャを誤解", explanation: "`equals` の戻り値はbooleanです。"),
                choice("c", "instanceofパターンはequals内で使えない", misconception: "構文制限を誤解", explanation: "対応Javaバージョンではinstanceofパターンを使えます。"),
                choice("d", "finalフィールドはequalsで参照できない", misconception: "finalの意味を誤解", explanation: "finalは再代入禁止であり、読み取りはできます。"),
            ],
            intent: "equalsをオーバーライドしたらhashCodeも整合するようにオーバーライドする契約を確認する。",
            steps: [
                step("`equals` はidが同じKey同士を等しいと判定しています。", [4, 5], [variable("equals rule", "String", "same id", "Key")]),
                step("しかし `hashCode` はオーバーライドされていないため、Object由来のハッシュ値になり、equalsで等しい2つが異なるhashCodeになる可能性があります。", [1, 6], [variable("hashCode", "method", "Object default", "Key")]),
                step("Objectの契約では、equalsで等しいオブジェクトは同じhashCodeを返す必要があります。HashSetやHashMapで特に重要です。", [4, 6], [variable("problem", "String", "equals/hashCode contract violation", "Object")]),
            ]
        ),
        q(
            "gold-mock-additional-pattern-instanceof-scope-001",
            category: "classes",
            tags: ["模試専用", "instanceof", "pattern variable", "scope"],
            code: """
public class Test {
    static void print(Object obj) {
        if (obj instanceof String s && s.length() > 1) {
            System.out.println(s.toUpperCase());
        } else {
            System.out.println("no");
        }
    }
    public static void main(String[] args) {
        print("ab");
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "AB", correct: true, explanation: "`obj` はStringで、パターン変数sのスコープ内で `length() > 1` も満たすため、大文字化して出力します。"),
                choice("b", "ab", misconception: "toUpperCaseを見落とし", explanation: "`s.toUpperCase()` を出力しています。"),
                choice("c", "no", misconception: "パターン変数が&&右辺で使えないと誤解", explanation: "`&&` 右辺では左辺のinstanceofがtrueの場合にsを使えます。"),
                choice("d", "コンパイルエラー", misconception: "パターン変数のスコープを誤解", explanation: "`&&` の右辺とif本体では、Stringと判定されたsを利用できます。"),
            ],
            intent: "instanceofパターン変数のスコープと短絡&&での利用を確認する。",
            steps: [
                step("`print(\"ab\")` なので、`obj` の実体はStringです。`obj instanceof String s` はtrueとなり、sがStringとして使えます。", [9, 10, 3], [variable("s", "String", "ab", "if condition")]),
                step("`&&` は左辺がtrueのときだけ右辺を評価するため、右辺の `s.length()` も安全に使えます。長さ2なので条件全体がtrueです。", [3], [variable("condition", "boolean", "true", "if")]),
                step("if本体で `s.toUpperCase()` を出力するため、結果は `AB` です。", [4], [variable("output", "String", "AB", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-lambda-overload-ambiguous-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "lambda-streams",
            tags: ["模試専用", "lambda", "overload", "ambiguous"],
            code: """
import java.util.concurrent.*;

class Test {
    static void run(Callable<Integer> c) {}
    static void run(Supplier<Integer> s) {}
    public static void main(String[] args) {
        run(() -> 1);
    }
}
""",
            question: "このコードについて正しい説明はどれか？",
            choices: [
                choice("a", "Callableが必ず選ばれる", misconception: "throwsの有無で優先されると誤解", explanation: "このラムダはどちらの関数型インターフェースにも適合し、片方に絞れません。"),
                choice("b", "Supplierが必ず選ばれる", misconception: "短いメソッド名getが優先されると誤解", explanation: "関数型メソッド名ではオーバーロード優先度は決まりません。"),
                choice("c", "呼び出しが曖昧でコンパイルエラーになる", correct: true, explanation: "`() -> 1` はCallable<Integer>にもSupplier<Integer>にも適合し、明示キャストなしでは選べません。"),
                choice("d", "実行時にClassCastExceptionになる", misconception: "ラムダの型決定を実行時問題と誤解", explanation: "ターゲット型の決定はコンパイル時です。"),
            ],
            intent: "ラムダ式のターゲット型とオーバーロード曖昧性を確認する。",
            steps: [
                step("`Callable<Integer>` の抽象メソッドは値を返し、`Supplier<Integer>` の抽象メソッドも値を返します。", [4, 5], [variable("candidates", "functional interfaces", "Callable, Supplier", "overload")]),
                step("ラムダ `() -> 1` は引数なしでIntegerを返すため、どちらの候補にも適合します。", [7], [variable("lambda", "expression", "() -> 1", "main")]),
                step("どちらがより具体的か決められないため、呼び出しは曖昧でコンパイルエラーです。明示キャストすれば解決できます。", [7], [variable("result", "String", "ambiguous method call", "compiler")]),
            ]
        ),
        q(
            "gold-mock-additional-methodref-unbound-001",
            category: "lambda-streams",
            tags: ["模試専用", "method reference", "BiPredicate"],
            code: """
import java.util.function.*;

public class Test {
    public static void main(String[] args) {
        BiPredicate<String, String> p = String::startsWith;
        System.out.println(p.test("java", "ja"));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", correct: true, explanation: "非束縛インスタンスメソッド参照では第1引数がレシーバ、第2引数がメソッド引数になります。`\"java\".startsWith(\"ja\")` はtrueです。"),
                choice("b", "false", misconception: "引数の対応を逆に読んでいる", explanation: "`\"ja\".startsWith(\"java\")` ではなく、`\"java\".startsWith(\"ja\")` です。"),
                choice("c", "コンパイルエラー", misconception: "String::startsWithをBiPredicateにできないと誤解", explanation: "レシーバStringとprefix Stringの2引数として適合します。"),
                choice("d", "NullPointerException", misconception: "レシーバがnullだと誤解", explanation: "レシーバは文字列リテラル `java` です。"),
            ],
            intent: "非束縛インスタンスメソッド参照の第1引数がレシーバになることを確認する。",
            steps: [
                step("`String::startsWith` は非束縛インスタンスメソッド参照です。関数型側の第1引数がメソッドを呼ぶレシーバになります。", [5], [variable("p", "BiPredicate<String,String>", "String::startsWith", "main")]),
                step("`p.test(\"java\", \"ja\")` は `\"java\".startsWith(\"ja\")` として評価されます。", [6], [variable("call", "boolean", "\"java\".startsWith(\"ja\")", "main")]),
                step("`java` は `ja` で始まるため、出力は `true` です。", [6], [variable("output", "boolean", "true", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-functional-compose-side-001",
            category: "lambda-streams",
            tags: ["模試専用", "Function", "compose", "andThen"],
            code: """
import java.util.function.*;

public class Test {
    public static void main(String[] args) {
        Function<String, String> f = s -> s + "F";
        Function<String, String> g = s -> s + "G";
        System.out.println(f.compose(g).apply("X"));
        System.out.println(f.andThen(g).apply("X"));
    }
}
""",
            question: "このコードを実行したとき、1行目と2行目の出力として正しいものはどれか？",
            choices: [
                choice("a", "XGF と XFG", correct: true, explanation: "`f.compose(g)` はgの後にf、`f.andThen(g)` はfの後にgです。"),
                choice("b", "XFG と XGF", misconception: "composeとandThenを逆に読んでいる", explanation: "`compose` は引数側の関数を先に適用します。"),
                choice("c", "XFG と XFG", misconception: "両方同じ順序だと誤解", explanation: "composeとandThenでは適用順が逆です。"),
                choice("d", "コンパイルエラー", misconception: "Function同士を合成できないと誤解", explanation: "入出力型がStringで揃っているため合成できます。"),
            ],
            intent: "Function.composeとandThenの適用順を確認する。",
            steps: [
                step("`f` は末尾にF、`g` は末尾にGを付ける関数です。", [5, 6], [variable("f", "Function<String,String>", "append F", "main"), variable("g", "Function<String,String>", "append G", "main")]),
                step("`f.compose(g).apply(\"X\")` は先にgで `XG`、次にfで `XGF` になります。", [7], [variable("first line", "String", "XGF", "stdout")]),
                step("`f.andThen(g).apply(\"X\")` は先にfで `XF`、次にgで `XFG` になります。", [8], [variable("second line", "String", "XFG", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-primitive-stream-average-001",
            category: "lambda-streams",
            tags: ["模試専用", "IntStream", "average", "OptionalDouble"],
            code: """
import java.util.stream.*;

public class Test {
    public static void main(String[] args) {
        double value = IntStream.of(1, 2)
            .average()
            .orElseThrow();
        System.out.println(value);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1", misconception: "整数除算になると誤解", explanation: "`average()` の戻り値はOptionalDoubleで、平均はdoubleです。"),
                choice("b", "1.5", correct: true, explanation: "1と2の平均は1.5で、`orElseThrow()` がdouble値を取り出します。"),
                choice("c", "OptionalDouble[1.5]", misconception: "orElseThrow後もOptionalだと誤解", explanation: "`orElseThrow()` は中身のdoubleを返します。"),
                choice("d", "NoSuchElementException", misconception: "空Streamと誤解", explanation: "IntStreamには1と2があるため、OptionalDoubleは値を持っています。"),
            ],
            intent: "IntStream.averageの戻り値OptionalDoubleと値の取り出しを確認する。",
            steps: [
                step("`IntStream.of(1, 2)` は2つのint値を持つプリミティブStreamです。", [5], [variable("stream", "IntStream", "1, 2", "pipeline")]),
                step("`average()` は平均値を `OptionalDouble` として返します。値がある場合、平均は1.5です。", [6], [variable("average", "OptionalDouble", "1.5", "pipeline")]),
                step("`orElseThrow()` がdoubleの中身を取り出し、出力は `1.5` です。", [7, 8], [variable("value", "double", "1.5", "main")]),
            ]
        ),
        q(
            "gold-mock-additional-primitive-functional-boxing-001",
            category: "lambda-streams",
            tags: ["模試専用", "IntUnaryOperator", "UnaryOperator", "boxing"],
            code: """
import java.util.function.*;

public class Test {
    public static void main(String[] args) {
        IntUnaryOperator op = n -> n + 1;
        UnaryOperator<Integer> boxed = n -> n + 1;
        System.out.println(op.applyAsInt(1) + ":" + boxed.apply(1));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2:2", correct: true, explanation: "どちらも1に1を足します。IntUnaryOperatorはint専用、UnaryOperator<Integer>はIntegerを扱います。"),
                choice("b", "1:2", misconception: "IntUnaryOperatorが変換しないと誤解", explanation: "`applyAsInt(1)` はラムダを実行して2を返します。"),
                choice("c", "2:1", misconception: "UnaryOperator側が更新しないと誤解", explanation: "`boxed.apply(1)` もラムダを実行します。"),
                choice("d", "コンパイルエラー", misconception: "Integerラムダで+演算できないと誤解", explanation: "Integerはアンボクシングされて加算できます。"),
            ],
            intent: "プリミティブ特化関数型インターフェースとBoxingを伴う関数型インターフェースを確認する。",
            steps: [
                step("`IntUnaryOperator` はintを受け取りintを返すプリミティブ特化型です。`applyAsInt(1)` は2を返します。", [5, 7], [variable("op result", "int", "2", "main")]),
                step("`UnaryOperator<Integer>` は参照型Integerを扱います。`n + 1` ではアンボクシングとボクシングが関係しますが、結果は2です。", [6, 7], [variable("boxed result", "Integer", "2", "main")]),
                step("文字列連結により出力は `2:2` です。試験では性能差より、メソッド名 `applyAsInt` などの違いも狙われます。", [7], [variable("output", "String", "2:2", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-map-merge-null-001",
            category: "collections",
            tags: ["模試専用", "Map.merge", "null"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Map<String, Integer> map = new HashMap<>();
        map.put("a", null);
        map.merge("a", 2, Integer::sum);
        map.merge("b", 3, Integer::sum);
        System.out.println(map.get("a") + ":" + map.get("b"));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2:3", correct: true, explanation: "既存値がnullの場合、remapping関数は呼ばれず指定値2が入ります。bも未存在なので3が入ります。"),
                choice("b", "null:3", misconception: "null値が維持されると誤解", explanation: "`merge` は既存値がnullなら指定値を関連付けます。"),
                choice("c", "2:null", misconception: "未存在キーbのmergeを見落とし", explanation: "bは未存在なので値3が追加されます。"),
                choice("d", "NullPointerException", misconception: "既存値nullでInteger::sumが必ず呼ばれると誤解", explanation: "既存値がnullならremapping関数は呼ばれず、指定値が設定されます。"),
            ],
            intent: "Map.mergeで既存値がnullの場合の動作を確認する。",
            steps: [
                step("HashMapにキーaをnull値で入れます。HashMap自体はnull値を許容します。", [5, 6], [variable("map", "Map<String,Integer>", "{a=null}", "main")]),
                step("`merge(\"a\", 2, Integer::sum)` は既存値がnullなので、remapping関数を呼ばず値2を設定します。", [7], [variable("map[\"a\"]", "Integer", "2", "main")]),
                step("キーbは未存在なので値3が追加されます。`get(\"a\")` は2、`get(\"b\")` は3なので、出力は `2:3` です。", [8, 9], [variable("output", "String", "2:3", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-map-compute-null-remove-001",
            category: "collections",
            tags: ["模試専用", "Map.compute", "null removal"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Map<String, Integer> map = new HashMap<>();
        map.put("a", 1);
        map.compute("a", (k, v) -> null);
        System.out.println(map.containsKey("a"));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", misconception: "null値として残ると誤解", explanation: "`compute` のremapping関数がnullを返すと、そのキーのマッピングは削除されます。"),
                choice("b", "false", correct: true, explanation: "`compute` の結果がnullなので、キーaはMapから削除されます。"),
                choice("c", "NullPointerException", misconception: "remapping関数がnullを返せないと誤解", explanation: "戻り値nullは削除の意味として扱われます。"),
                choice("d", "1", misconception: "containsKeyの戻り値を誤解", explanation: "`containsKey` はbooleanを返します。"),
            ],
            intent: "Map.computeでremapping関数がnullを返すとマッピングが削除されることを確認する。",
            steps: [
                step("最初にキーaへ値1を入れます。", [5, 6], [variable("map", "Map<String,Integer>", "{a=1}", "main")]),
                step("`compute(\"a\", (k, v) -> null)` はremapping結果としてnullを返します。Map.computeではこれは削除を意味します。", [7], [variable("compute result", "Integer", "null", "remapping")]),
                step("キーaは削除されたため、`map.containsKey(\"a\")` はfalseです。", [8], [variable("output", "boolean", "false", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-list-replaceall-001",
            category: "collections",
            tags: ["模試専用", "List.replaceAll", "UnaryOperator"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>(List.of("a", "bb"));
        list.replaceAll(s -> s + s.length());
        System.out.println(list);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "[a1, bb2]", correct: true, explanation: "`replaceAll` は各要素をUnaryOperatorの戻り値で置き換えます。"),
                choice("b", "[a, bb, a1, bb2]", misconception: "置換ではなく追加だと誤解", explanation: "`replaceAll` は要素を追加せず、既存要素を置き換えます。"),
                choice("c", "[1, 2]", misconception: "長さだけになると誤解", explanation: "ラムダは `s + s.length()` なので元文字列も残ります。"),
                choice("d", "UnsupportedOperationException", misconception: "ArrayListを変更不可と誤解", explanation: "new ArrayListで作っているため変更可能です。"),
            ],
            intent: "List.replaceAllが各要素を戻り値で置換することを確認する。",
            steps: [
                step("初期リストは `[a, bb]` です。`new ArrayList` で包んでいるため変更可能です。", [5], [variable("list", "ArrayList<String>", "[a, bb]", "main")]),
                step("`replaceAll` は各要素にラムダを適用し、戻り値で元の要素を置き換えます。aはa1、bbはbb2になります。", [6], [variable("list", "ArrayList<String>", "[a1, bb2]", "main")]),
                step("置換後のListを出力するため、結果は `[a1, bb2]` です。", [7], [variable("output", "String", "[a1, bb2]", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-resourcebundle-missing-key-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "localization",
            tags: ["模試専用", "ResourceBundle", "MissingResourceException"],
            code: """
// messages.properties
title=Base

ResourceBundle rb = ResourceBundle.getBundle("messages", Locale.ENGLISH);
System.out.println(rb.getString("missing"));
""",
            question: "bundleは見つかるがキー `missing` が存在しない場合、正しい説明はどれか？",
            choices: [
                choice("a", "空文字が返る", misconception: "欠落キーのデフォルト値を期待している", explanation: "ResourceBundleは存在しないキーに空文字を返しません。"),
                choice("b", "キー名 `missing` がそのまま返る", misconception: "フォールバック表示と混同", explanation: "標準ResourceBundleの `getString` はキー名を代替表示しません。"),
                choice("c", "MissingResourceExceptionが発生する", correct: true, explanation: "bundle自体が見つかっても、指定キーがなければ `MissingResourceException` です。"),
                choice("d", "nullが返る", misconception: "Map.getのような挙動と混同", explanation: "`getString` は欠落時にnullではなく例外を投げます。"),
            ],
            intent: "ResourceBundleでbundle存在とキー存在は別で、キー欠落時は例外になることを確認する。",
            steps: [
                step("`messages.properties` は存在し、`title=Base` というキーを持っています。bundleの取得自体は成功する前提です。", [1, 2, 4], [variable("bundle", "ResourceBundle", "messages.properties", "lookup")]),
                step("しかし `rb.getString(\"missing\")` は存在しないキーを要求しています。", [5], [variable("requested key", "String", "missing", "ResourceBundle")]),
                step("ResourceBundleはキー欠落時に `MissingResourceException` を投げます。空文字やnullは返しません。", [5], [variable("result", "String", "MissingResourceException", "runtime")]),
            ]
        ),
        q(
            "gold-mock-additional-numberformat-parse-position-001",
            difficulty: .tricky,
            category: "localization",
            tags: ["模試専用", "NumberFormat", "parse"],
            code: """
import java.text.*;
import java.util.*;

public class Test {
    public static void main(String[] args) throws Exception {
        NumberFormat nf = NumberFormat.getIntegerInstance(Locale.US);
        Number n = nf.parse("1,234xyz");
        System.out.println(n);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1234", correct: true, explanation: "`parse(String)` は先頭から解析できる部分を数値として読み取り、途中の解析不能文字で停止します。"),
                choice("b", "1", misconception: "カンマで解析が止まると誤解", explanation: "Locale.USの整数形式ではカンマ区切りを扱えます。"),
                choice("c", "ParseException", misconception: "末尾の文字があると全体失敗すると誤解", explanation: "先頭から数値として解析できる部分があるため、1234を返します。"),
                choice("d", "1234xyz", misconception: "戻り値が文字列だと誤解", explanation: "`parse` の戻り値はNumberです。"),
            ],
            intent: "NumberFormat.parse(String)が解析可能な接頭辞を読む挙動を確認する。",
            steps: [
                step("`NumberFormat.getIntegerInstance(Locale.US)` は、US形式の整数フォーマットを扱います。", [6], [variable("nf", "NumberFormat", "US integer", "main")]),
                step("入力 `1,234xyz` のうち、`1,234` はUS形式の整数として解析できます。`xyz` の前で解析が止まります。", [7], [variable("parsed prefix", "String", "1,234", "parse")]),
                step("数値としては1234が返り、出力は `1234` です。", [8], [variable("n", "Number", "1234", "main")]),
            ]
        ),
        q(
            "gold-mock-additional-module-service-missing-uses-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "module-system",
            tags: ["模試専用", "ServiceLoader", "uses", "module"],
            code: """
module client {
    requires service.api;
}

ServiceLoader<MyService> loader = ServiceLoader.load(MyService.class);
""",
            question: "モジュール `client` でServiceLoaderを使う場合の説明として正しいものはどれか？",
            choices: [
                choice("a", "`requires` だけで十分で、`uses` は不要", misconception: "サービス利用宣言を見落とし", explanation: "名前付きモジュールでサービスを利用する場合、サービス型に対する `uses` 宣言が必要です。"),
                choice("b", "`module-info.java` に `uses MyService;` を宣言する", correct: true, explanation: "ServiceLoaderでサービスを利用するモジュールは、利用するサービス型を `uses` で宣言します。"),
                choice("c", "実装側モジュールに `uses` を書く", misconception: "usesとprovidesを逆にしている", explanation: "実装側は `provides ... with ...`、利用側は `uses` です。"),
                choice("d", "`exports` を書けばServiceLoaderが必ず実装を生成する", misconception: "exportsとサービス発見を混同", explanation: "exportsは通常アクセス公開であり、サービス提供宣言ではありません。"),
            ],
            intent: "ServiceLoader利用側モジュールのuses宣言を確認する。",
            steps: [
                step("`requires service.api;` はサービス型を含むモジュールを読むための宣言です。", [1, 2], [variable("readability", "module", "service.api", "client")]),
                step("名前付きモジュールでServiceLoaderを使う利用側は、利用するサービス型を `uses` で宣言する必要があります。", [5], [variable("required directive", "String", "uses MyService;", "module-info")]),
                step("実装を提供する側は `provides ... with ...` です。利用側の `uses` と提供側の `provides` を分けて読みます。", [5], [variable("rule", "String", "client uses, provider provides", "module system")]),
            ]
        ),
        q(
            "gold-mock-additional-assert-sideeffect-001",
            difficulty: .tricky,
            category: "exception-handling",
            tags: ["模試専用", "assert", "-ea", "side effect"],
            code: """
public class Test {
    public static void main(String[] args) {
        int x = 0;
        assert ++x > 0;
        System.out.println(x);
    }
}
""",
            question: "`java Test` として通常実行した場合、出力されるのはどれか？",
            choices: [
                choice("a", "0", correct: true, explanation: "通常実行ではassertは無効なので、`++x` も評価されません。"),
                choice("b", "1", misconception: "assert式が常に評価されると誤解", explanation: "`-ea` なしではassert文自体が無効で、式の副作用も起きません。"),
                choice("c", "AssertionError", misconception: "assertがデフォルト有効だと誤解", explanation: "assertはデフォルトでは無効です。"),
                choice("d", "コンパイルエラー", misconception: "assertに副作用式を書けないと誤解", explanation: "コンパイルはできます。ただし副作用をassertに依存する設計は避けるべきです。"),
            ],
            intent: "assert無効時は条件式の副作用も発生しないことを確認する。",
            steps: [
                step("`x` は0で初期化されます。", [3], [variable("x", "int", "0", "main")]),
                step("通常の `java Test` 実行ではassertが無効です。そのため `assert ++x > 0;` の式は評価されず、`++x` も実行されません。", [4], [variable("assertions", "boolean", "disabled", "JVM")]),
                step("`x` は0のままなので、出力は `0` です。`-ea` を付けた場合とは結果が変わります。", [5], [variable("output", "int", "0", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-security-normalize-absolute-001",
            difficulty: .tricky,
            category: "secure-coding",
            tags: ["模試専用", "Path", "normalize", "secure coding"],
            code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path base = Paths.get("/safe/base");
        Path input = Paths.get("/tmp/evil.txt");
        Path target = base.resolve(input).normalize();
        System.out.println(target.startsWith(base));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", misconception: "base.resolveしたので必ずbase配下だと誤解", explanation: "resolveの引数が絶対Pathの場合、baseは無視されます。"),
                choice("b", "false", correct: true, explanation: "`input` が絶対Pathなので `base.resolve(input)` は `/tmp/evil.txt` になり、base配下ではありません。"),
                choice("c", "InvalidPathException", misconception: "絶対Pathをresolveできないと誤解", explanation: "絶対Pathもresolve可能で、仕様上input側が結果になります。"),
                choice("d", "SecurityException", misconception: "startsWithがアクセス制御を行うと誤解", explanation: "`startsWith` はPath文字列の関係を判定するだけです。"),
            ],
            intent: "Path.resolveで絶対入力がbaseを無視するため、base配下検証が必要なことを確認する。",
            steps: [
                step("`base` は `/safe/base`、`input` は絶対Path `/tmp/evil.txt` です。", [5, 6], [variable("base", "Path", "/safe/base", "main"), variable("input", "Path", "/tmp/evil.txt", "main")]),
                step("`base.resolve(input)` では、引数inputが絶対Pathなのでbaseは使われず、targetは `/tmp/evil.txt` になります。", [7], [variable("target", "Path", "/tmp/evil.txt", "main")]),
                step("targetはbaseで始まらないため、`target.startsWith(base)` はfalseです。セキュアコーディングではこの検証が重要です。", [8], [variable("output", "boolean", "false", "stdout")]),
            ]
        ),
        q(
            "gold-mock-additional-security-serialversionuid-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "secure-coding",
            tags: ["模試専用", "serialVersionUID", "serialization"],
            code: """
class Account implements Serializable {
    private static final long serialVersionUID = 1L;
    private String name;
}
""",
            question: "`serialVersionUID` について正しい説明はどれか？",
            choices: [
                choice("a", "staticなのでシリアライズ対象の通常フィールドとして保存される", misconception: "staticフィールドの扱いを誤解", explanation: "staticフィールドは各インスタンスの状態ではないため、通常のインスタンスデータとして保存されません。"),
                choice("b", "シリアライズ互換性の確認に使われる識別子である", correct: true, explanation: "`serialVersionUID` はストリーム内のクラス記述と現在のクラス定義の互換性確認に使われます。"),
                choice("c", "値は必ず0Lでなければならない", misconception: "値の制約を誤解", explanation: "任意のlong定数として宣言できます。"),
                choice("d", "transientを付けないとコンパイルエラーになる", misconception: "serialVersionUIDの宣言形を誤解", explanation: "通常は `private static final long serialVersionUID` として宣言します。"),
            ],
            intent: "serialVersionUIDの目的とstaticフィールドとしての扱いを確認する。",
            steps: [
                step("`serialVersionUID` は `private static final long` として宣言されています。", [1, 2], [variable("serialVersionUID", "long", "1L", "Account class")]),
                step("これはインスタンス状態として保存する通常フィールドではなく、シリアライズ互換性確認に使われるクラス側の識別子です。", [2], [variable("purpose", "String", "serialization compatibility", "serialization")]),
                step("クラス定義変更時に意図しない互換性不一致を避けるため、明示宣言が推奨されます。", [2, 3], [variable("rule", "String", "declare stable UID", "secure coding")]),
            ]
        ),
    ]

    private static let excludedSpecIds: Set<String> = [
        "gold-mock-additional-stream-unordered-limit-001",
        "gold-mock-additional-collections-removeif-001",
        "gold-mock-additional-module-transitive-static-001",
        "gold-mock-additional-io-readstring-nosuchfile-001",
        "gold-mock-additional-localization-locale-builder-001",
        "gold-mock-additional-primitive-functional-boxing-001",
        "gold-mock-additional-map-compute-null-remove-001",
        "gold-mock-additional-list-replaceall-001",
    ]

    static let specs: [Spec] = allSpecs.filter { !excludedSpecIds.contains($0.id) }

    static func q(
        _ id: String,
        difficulty: QuizDifficulty = .exam,
        estimatedSeconds: Int = 120,
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
        ChoiceSpec(id: id, text: text, correct: correct, misconception: misconception, explanation: explanation)
    }

    static func step(
        _ narration: String,
        _ highlightLines: [Int],
        _ variables: [VariableSpec] = []
    ) -> StepSpec {
        StepSpec(narration: narration, highlightLines: highlightLines, variables: variables)
    }

    static func variable(_ name: String, _ type: String, _ value: String, _ scope: String) -> VariableSpec {
        VariableSpec(name: name, type: type, value: value, scope: scope)
    }
}

extension GoldMockAdditionalQuestionData.Spec {
    var quiz: Quiz {
        Quiz(
            id: id,
            level: .gold,
            difficulty: difficulty,
            estimatedSeconds: estimatedSeconds,
            validatedByJavac: validatedByJavac,
            isMockExamOnly: true,
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
    static let goldMockAdditionalExpansion: [Quiz] = GoldMockAdditionalQuestionData.specs.map(\.quiz)
}
