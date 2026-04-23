import Foundation

enum GoldBalancedQuestionData {
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
            "gold-balanced-concurrency-execute-submit-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "concurrency",
            tags: ["ExecutorService", "execute", "submit", "例外"],
            code: """
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) throws Exception {
        ExecutorService service = Executors.newSingleThreadExecutor();
        service.execute(() -> { throw new RuntimeException("execute"); });
        Future<?> future = service.submit(() -> { throw new RuntimeException("submit"); });
        try {
            future.get();
        } catch (ExecutionException e) {
            System.out.println(e.getCause().getMessage());
        } finally {
            service.shutdown();
        }
    }
}
""",
            question: "このコードで `submit` 側の例外について正しい説明はどれか？",
            choices: [
                choice("a", "`future.get()` で `ExecutionException` に包まれて観測される", correct: true, explanation: "`submit` したタスク内の例外はFutureに保持され、`get()` で `ExecutionException` として取り出されます。"),
                choice("b", "`submit` した瞬間にmainスレッドへ直接投げられる", misconception: "submitが同期実行だと誤解", explanation: "タスクはExecutor上で実行され、例外はFuture側に保持されます。"),
                choice("c", "`execute` と同じく `Future` なしで `getCause()` できる", misconception: "executeとsubmitを同じ扱いにしている", explanation: "`execute` はFutureを返しません。`submit` だから `future.get()` で原因を取得できます。"),
                choice("d", "例外は完全に破棄され、どこからも確認できない", misconception: "submitの例外保持を見落とし", explanation: "`get()` を呼べば `ExecutionException` として確認できます。"),
            ],
            intent: "executeとsubmitでタスク内例外の観測方法が違うことを確認する。",
            steps: [
                step("`execute` は戻り値を返さないため、タスク内例外をFutureとして保持しません。実行スレッド側の未捕捉例外として扱われます。", [5, 6], [variable("execute task", "Runnable", "throws RuntimeException(\"execute\")", "executor")]),
                step("`submit` はFutureを返します。タスク内で `RuntimeException(\"submit\")` が発生しても、mainへ直接投げずFutureに例外完了として保存します。", [7], [variable("future", "Future<?>", "failed with RuntimeException(\"submit\")", "main")]),
                step("`future.get()` により保存された例外が `ExecutionException` に包まれて投げられます。`getCause().getMessage()` は `submit` です。", [8, 9, 10, 11], [variable("output", "String", "submit", "main")]),
            ]
        ),
        q(
            "gold-balanced-concurrency-invokeany-001",
            difficulty: .standard,
            category: "concurrency",
            tags: ["ExecutorService", "invokeAny", "Callable"],
            code: """
import java.util.*;
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) throws Exception {
        ExecutorService service = Executors.newFixedThreadPool(2);
        try {
            String result = service.invokeAny(List.of(
                () -> { Thread.sleep(200); return "A"; },
                () -> "B"
            ));
            System.out.println(result);
        } finally {
            service.shutdown();
        }
    }
}
""",
            question: "このコードを実行したとき、出力として最も適切なのはどれか？",
            choices: [
                choice("a", "A", misconception: "入力順の先頭が必ず返ると誤解", explanation: "`invokeAny` は入力順ではなく、正常完了したいずれか1つの結果を返します。このコードではBが先に完了します。"),
                choice("b", "B", correct: true, explanation: "2つ目のCallableは待機せず完了するため、`invokeAny` は通常Bを返します。"),
                choice("c", "[A, B]", misconception: "invokeAllと混同", explanation: "全結果のFuture一覧を返すのは `invokeAll` です。`invokeAny` は1つの結果を返します。"),
                choice("d", "TimeoutException", misconception: "sleepがあると自動でタイムアウトすると誤解", explanation: "タイムアウト付きのオーバーロードは使っていません。"),
            ],
            intent: "invokeAnyが全結果ではなく成功した1件の結果を返すことを確認する。",
            steps: [
                step("固定2スレッドなので2つのCallableは並行に開始できます。A側は200ms待機し、B側はすぐに文字列を返します。", [6, 8, 9, 10], [variable("tasks", "List<Callable<String>>", "A sleeps, B returns immediately", "main")]),
                step("`invokeAny` は正常完了したいずれか1つの結果を返します。全タスクのFuture一覧ではありません。", [8], [variable("result", "String", "B", "main")]),
                step("取得した `result` を出力するため、表示は `B` です。最後にExecutorServiceをshutdownします。", [12, 14], [variable("output", "String", "B", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-concurrency-shutdown-reject-001",
            difficulty: .standard,
            category: "concurrency",
            tags: ["ExecutorService", "shutdown", "RejectedExecutionException"],
            code: """
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) {
        ExecutorService service = Executors.newSingleThreadExecutor();
        service.shutdown();
        try {
            service.submit(() -> "x");
        } catch (RejectedExecutionException e) {
            System.out.println(e.getClass().getSimpleName());
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "RejectedExecutionException", correct: true, explanation: "`shutdown()` 後は新規タスクを受け付けないため、`submit` は `RejectedExecutionException` を投げます。"),
                choice("b", "x", misconception: "shutdown後も新規タスクを受け付けると誤解", explanation: "`shutdown()` は既存タスクの完了は待てますが、新規タスクの投入は拒否します。"),
                choice("c", "IllegalStateException", misconception: "Executorの状態エラー型を取り違え", explanation: "ExecutorServiceのタスク拒否は `RejectedExecutionException` です。"),
                choice("d", "何も出力されない", misconception: "submitが静かに無視されると誤解", explanation: "拒否は例外として通知され、catchブロックでクラス名を出力します。"),
            ],
            intent: "shutdown後のExecutorServiceが新規タスクを拒否することを確認する。",
            steps: [
                step("`newSingleThreadExecutor()` でExecutorServiceを作成した直後、`shutdown()` を呼んで終了処理中の状態にします。", [5, 6], [variable("service", "ExecutorService", "shutting down", "main")]),
                step("終了処理中のExecutorServiceへ新しいタスクを `submit` しようとすると、タスクは受け付けられません。", [7, 8], [variable("submitted task", "Callable<String>", "rejected", "main")]),
                step("拒否は `RejectedExecutionException` としてcatchされます。出力しているのは例外クラスの単純名です。", [9, 10], [variable("output", "String", "RejectedExecutionException", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-concurrency-shutdownnow-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "concurrency",
            tags: ["ExecutorService", "shutdownNow", "未開始タスク"],
            code: """
import java.util.concurrent.*;
import java.util.*;

public class Test {
    public static void main(String[] args) {
        ExecutorService service = Executors.newSingleThreadExecutor();
        service.execute(() -> sleepLong());
        service.execute(() -> System.out.println("B"));
        List<Runnable> waiting = service.shutdownNow();
        System.out.println(waiting.size());
    }
    static void sleepLong() {
        try { Thread.sleep(10000); } catch (InterruptedException e) {}
    }
}
""",
            question: "`shutdownNow()` の戻り値について正しい説明はどれか？",
            choices: [
                choice("a", "実行中タスクと未開始タスクの両方が必ず含まれる", misconception: "戻り値の意味を広く取りすぎ", explanation: "戻り値に含まれるのは、開始されていない待機中タスクです。実行中タスクは中断要求されます。"),
                choice("b", "開始されていない待機中タスクが含まれる", correct: true, explanation: "`shutdownNow()` は実行中タスクへ中断を試み、未開始タスクのリストを返します。"),
                choice("c", "完了済みタスクの戻り値が含まれる", misconception: "Future結果の一覧と混同", explanation: "`shutdownNow()` の戻り値は結果ではなく、実行されなかった `Runnable` の一覧です。"),
                choice("d", "常に空リストを返す", misconception: "タスクキューを返す仕様を見落とし", explanation: "未開始タスクがキューに残っていれば、そのタスクが返されます。"),
            ],
            intent: "shutdownNowの戻り値が未開始タスクの一覧であることを確認する。",
            steps: [
                step("単一スレッドExecutorでは、長く眠る最初のタスクが実行中になると、2つ目のタスクはキューで待つ可能性があります。", [6, 7, 8], [variable("running", "Runnable", "sleepLong()", "executor"), variable("queued", "Runnable", "print B", "work queue")]),
                step("`shutdownNow()` は実行中タスクに中断を試み、まだ開始されていないタスクを `List<Runnable>` として返します。", [9], [variable("waiting", "List<Runnable>", "not-started tasks", "main")]),
                step("戻り値は完了結果ではありません。実行済み・実行中タスクの値を集めるAPIではなく、未開始タスクの回収用です。", [9, 10], [variable("rule", "String", "returns pending tasks", "ExecutorService")]),
            ]
        ),
        q(
            "gold-balanced-concurrency-future-timeout-001",
            difficulty: .standard,
            category: "concurrency",
            tags: ["Future", "get", "TimeoutException"],
            code: """
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) throws Exception {
        ExecutorService service = Executors.newSingleThreadExecutor();
        Future<String> future = service.submit(() -> {
            Thread.sleep(200);
            return "done";
        });
        try {
            System.out.println(future.get(10, TimeUnit.MILLISECONDS));
        } catch (TimeoutException e) {
            System.out.println("timeout");
        } finally {
            service.shutdownNow();
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "done", misconception: "getが必ず完了まで待つと誤解", explanation: "引数付き `get` は指定時間だけ待ち、完了しなければ `TimeoutException` を投げます。"),
                choice("b", "timeout", correct: true, explanation: "タスクは200ms眠りますが、`get` は10msしか待たないため `TimeoutException` がcatchされます。"),
                choice("c", "InterruptedException", misconception: "shutdownNowの中断を先に読む誤解", explanation: "`shutdownNow()` はfinallyで呼ばれます。先に `get` のタイムアウトが発生します。"),
                choice("d", "null", misconception: "未完了Futureの値をnullと誤解", explanation: "未完了ならnullを返すのではなく、タイムアウト付きgetでは例外になります。"),
            ],
            intent: "Future.get(timeout, unit)が未完了時にTimeoutExceptionを投げることを確認する。",
            steps: [
                step("タスクは開始後 `Thread.sleep(200)` に入り、200ms後に `done` を返す予定です。", [6, 7, 8], [variable("future", "Future<String>", "running, not completed yet", "executor")]),
                step("mainは `future.get(10, TimeUnit.MILLISECONDS)` で10msだけ待ちます。タスクはまだ終わらないため `TimeoutException` が発生します。", [10, 11, 12], [variable("exception", "TimeoutException", "task not completed within 10ms", "main")]),
                step("catchブロックで `timeout` を出力し、finallyでExecutorServiceに中断を要求します。", [12, 13, 15], [variable("output", "String", "timeout", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-concurrency-cancel-state-001",
            difficulty: .standard,
            category: "concurrency",
            tags: ["FutureTask", "cancel", "isDone", "isCancelled"],
            code: """
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) {
        FutureTask<String> task = new FutureTask<>(() -> "ok");
        boolean cancelled = task.cancel(false);
        System.out.println(cancelled + ":" + task.isDone() + ":" + task.isCancelled());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true:true:true", correct: true, explanation: "未実行のFutureTaskはキャンセルでき、キャンセル済みタスクは完了状態でもあります。"),
                choice("b", "true:false:true", misconception: "キャンセル済みを未完了と誤解", explanation: "`isDone()` は正常完了・例外完了・キャンセル完了を含む完了状態を表します。"),
                choice("c", "false:false:false", misconception: "未実行タスクはキャンセルできないと誤解", explanation: "まだ開始していないため、キャンセルは成功します。"),
                choice("d", "false:true:false", misconception: "cancel(false)が常に失敗すると誤解", explanation: "`mayInterruptIfRunning` がfalseでも、未開始ならキャンセルできます。"),
            ],
            intent: "Futureのキャンセル状態とisDone/isCancelledの関係を確認する。",
            steps: [
                step("`FutureTask` は作成されただけで、まだ `run()` されていません。したがって結果は未計算です。", [5], [variable("task", "FutureTask<String>", "new, not started", "main")]),
                step("未開始タスクに `cancel(false)` を呼ぶとキャンセルに成功し、戻り値は `true` です。", [6], [variable("cancelled", "boolean", "true", "main")]),
                step("キャンセル済みのFutureは完了扱いなので `isDone()` も `true`、`isCancelled()` も `true` になります。", [7], [variable("output", "String", "true:true:true", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-concurrency-thenapplyasync-001",
            difficulty: .standard,
            category: "concurrency",
            tags: ["CompletableFuture", "thenApplyAsync", "join"],
            code: """
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) {
        int result = CompletableFuture.completedFuture(2)
            .thenApplyAsync(n -> n + 3)
            .join();
        System.out.println(result);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2", misconception: "thenApplyAsyncが元の値を変えないと誤解", explanation: "後続ステージは前段の値2を受け取り、5へ変換します。"),
                choice("b", "3", misconception: "加算される値だけを見る誤解", explanation: "`n + 3` なので、前段の2と足して5です。"),
                choice("c", "5", correct: true, explanation: "`completedFuture(2)` の値が `thenApplyAsync` に渡り、`2 + 3` の結果を `join()` で取り出します。"),
                choice("d", "CompletableFuture[5]", misconception: "joinの戻り値をFuture本体と誤解", explanation: "`join()` はCompletableFutureではなく、完了値そのものを返します。"),
            ],
            intent: "CompletableFutureのthenApplyAsyncとjoinによる値の取り出しを確認する。",
            steps: [
                step("`completedFuture(2)` はすでに値2で完了しているCompletableFutureを作ります。", [5], [variable("stage1", "CompletableFuture<Integer>", "completed with 2", "main")]),
                step("`thenApplyAsync` は前段の値2を受け取り、ラムダ `n -> n + 3` で5へ変換する次のステージを作ります。", [6], [variable("stage2", "CompletableFuture<Integer>", "completed with 5", "common pool")]),
                step("`join()` は完了値を取り出すため、`result` は5です。出力も `5` になります。", [7, 8], [variable("result", "int", "5", "main")]),
            ]
        ),
        q(
            "gold-balanced-concurrency-allof-001",
            difficulty: .standard,
            category: "concurrency",
            tags: ["CompletableFuture", "allOf", "join"],
            code: """
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) {
        CompletableFuture<String> a = CompletableFuture.completedFuture("A");
        CompletableFuture<String> b = CompletableFuture.completedFuture("B");
        String result = CompletableFuture.allOf(a, b)
            .thenApply(v -> a.join() + b.join())
            .join();
        System.out.println(result);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "AB", correct: true, explanation: "`allOf` は両方の完了を待つだけで値は持たないため、後段でaとbをjoinして連結しています。"),
                choice("b", "[A, B]", misconception: "allOfが結果リストを返すと誤解", explanation: "`allOf` の完了値は `Void` です。個別の結果は元のFutureから取り出します。"),
                choice("c", "null", misconception: "allOfのVoidをそのまま出力すると誤解", explanation: "このコードは `thenApply` で `a.join() + b.join()` を返しています。"),
                choice("d", "BA", misconception: "完了順で連結されると誤解", explanation: "連結順はコード上の `a.join() + b.join()` の順です。"),
            ],
            intent: "CompletableFuture.allOfは値を集めず完了待ちだけを行うことを確認する。",
            steps: [
                step("`a` と `b` はそれぞれ `A` と `B` で完了済みです。", [5, 6], [variable("a", "CompletableFuture<String>", "A", "main"), variable("b", "CompletableFuture<String>", "B", "main")]),
                step("`CompletableFuture.allOf(a, b)` は両方の完了を待つFutureを返しますが、完了値は結果リストではなく `Void` です。", [7], [variable("v", "Void", "null", "thenApply")]),
                step("後続の `thenApply` で元のFutureから値を取り出し、`A` と `B` を連結するため出力は `AB` です。", [8, 9, 10], [variable("result", "String", "AB", "main")]),
            ]
        ),
        q(
            "gold-balanced-concurrency-handle-001",
            difficulty: .tricky,
            category: "concurrency",
            tags: ["CompletableFuture", "handle", "例外回復"],
            code: """
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) {
        int result = CompletableFuture.<Integer>supplyAsync(() -> {
            throw new IllegalStateException();
        }).handle((value, error) -> error == null ? value : 7)
          .join();
        System.out.println(result);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "7", correct: true, explanation: "前段は例外完了しますが、`handle` は正常時・例外時の両方で呼ばれ、例外時は7を返します。"),
                choice("b", "0", misconception: "例外時にintのデフォルト値になると誤解", explanation: "デフォルト値にはなりません。`handle` の戻り値が次の完了値になります。"),
                choice("c", "IllegalStateException", misconception: "handleでも例外がそのまま出力されると誤解", explanation: "`handle` が例外を値7へ回復しているため、joinは7を返します。"),
                choice("d", "null", misconception: "valueがnullなのでnullになると誤解", explanation: "例外時の `value` はnullですが、式は `error == null ? value : 7` なので7です。"),
            ],
            intent: "CompletableFuture.handleが例外完了も受け取り、値へ回復できることを確認する。",
            steps: [
                step("`supplyAsync` のラムダは `IllegalStateException` を投げるため、前段のCompletableFutureは例外完了します。", [5, 6], [variable("stage1", "CompletableFuture<Integer>", "failed", "common pool")]),
                step("`handle` は正常完了でも例外完了でも呼ばれます。今回は `error` がnullではないため、ラムダは7を返します。", [7], [variable("value", "Integer", "null", "handle"), variable("error", "Throwable", "IllegalStateException", "handle")]),
                step("`handle` の戻り値7で後続ステージが正常完了し、`join()` は7を返します。", [8, 9], [variable("result", "int", "7", "main")]),
            ]
        ),
        q(
            "gold-balanced-concurrency-parallel-findany-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "concurrency",
            tags: ["parallelStream", "findAny", "findFirst", "Optional"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Optional<Integer> result = List.of(1, 2, 3, 4)
            .parallelStream()
            .filter(n -> n > 1)
            .findAny();
        System.out.println(result.get());
    }
}
""",
            question: "このコードの読み方として正しいものはどれか？",
            choices: [
                choice("a", "`findAny()` は常に2を返す", misconception: "遭遇順の先頭と決めつけている", explanation: "並列ストリームの `findAny` は条件を満たす任意の要素を返せます。"),
                choice("b", "`findAny()` は条件を満たす任意の要素を返し得る", correct: true, explanation: "`filter(n > 1)` 後の2,3,4のいずれかが返る可能性があります。順序が必要なら `findFirst` を使います。"),
                choice("c", "`findAny()` はOptionalを返せない", misconception: "終端操作の戻り値を誤解", explanation: "`findAny` の戻り値は `Optional<T>` です。"),
                choice("d", "parallelStreamではfilterを使えない", misconception: "並列ストリームで中間操作が使えないと誤解", explanation: "中間操作は使えます。ただし順序や副作用には注意が必要です。"),
            ],
            intent: "parallelStreamにおけるfindAnyの非決定性とfindFirstとの違いを確認する。",
            steps: [
                step("`parallelStream()` により、要素処理は複数スレッドへ分配され得ます。遭遇順そのものはListにありますが、`findAny` は順序を要求しません。", [5, 6], [variable("source", "List<Integer>", "1, 2, 3, 4", "main")]),
                step("`filter(n -> n > 1)` で候補は2,3,4になります。`findAny` はこの候補の任意の1件で完了できます。", [7, 8], [variable("candidates", "Stream<Integer>", "2, 3, 4", "pipeline")]),
                step("出力値を1つに断定する問題ではなく、`findAny` は順序保証を弱めて並列処理しやすくするAPIだと読むのがポイントです。", [8, 9], [variable("rule", "String", "any matching element", "Stream")]),
            ]
        ),
        q(
            "gold-balanced-concurrency-foreachordered-001",
            difficulty: .standard,
            category: "concurrency",
            tags: ["parallelStream", "forEachOrdered", "sorted"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List.of(3, 1, 2)
            .parallelStream()
            .sorted()
            .forEachOrdered(System.out::print);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "312", misconception: "元のList順のままと誤解", explanation: "`sorted()` により自然順に並び替えられます。"),
                choice("b", "123", correct: true, explanation: "`sorted()` 後の遭遇順は1,2,3で、`forEachOrdered` はその順序を守って出力します。"),
                choice("c", "並列なので毎回ランダム", misconception: "forEachOrderedの順序保証を見落とし", explanation: "`forEach` では順序が崩れ得ますが、`forEachOrdered` は遭遇順を守ります。"),
                choice("d", "コンパイルエラー", misconception: "parallelStreamでsortedできないと誤解", explanation: "並列ストリームでも `sorted` と `forEachOrdered` は使用できます。"),
            ],
            intent: "parallelStreamでもforEachOrderedが遭遇順を守ることを確認する。",
            steps: [
                step("元の要素は3,1,2ですが、`sorted()` により自然順の1,2,3へ並び替えられます。", [5, 6, 7], [variable("after sorted", "Stream<Integer>", "1, 2, 3", "pipeline")]),
                step("`forEachOrdered` は並列ストリームでも遭遇順を守って処理します。ここでの遭遇順はソート後の1,2,3です。", [8], [variable("operation", "Consumer<Integer>", "System.out::print", "terminal")]),
                step("したがって出力は `123` です。順序不要なら `forEach`、順序維持なら `forEachOrdered` と整理します。", [8], [variable("output", "String", "123", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-concurrency-parallel-reduce-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "concurrency",
            tags: ["parallelStream", "reduce", "identity", "combiner"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        int result = List.of(1, 2)
            .parallelStream()
            .reduce(10, (a, b) -> a + b, (a, b) -> a + b);
        System.out.println(result);
    }
}
""",
            question: "この `reduce` の注意点として正しいものはどれか？",
            choices: [
                choice("a", "identityの10は全体で一度だけ必ず使われる", misconception: "逐次reduceと同じ感覚で読んでいる", explanation: "並列reduceでは部分結果ごとにidentityが使われ得ます。"),
                choice("b", "identityは演算の単位元でなければ、並列時に意図しない結果になり得る", correct: true, explanation: "加算なら単位元は0です。10をidentityにすると部分計算ごとに10が混ざる可能性があります。"),
                choice("c", "combinerは逐次ストリームでも必ず呼ばれる", misconception: "3引数reduceのcombinerの役割を誤解", explanation: "combinerは主に並列で部分結果を統合するために使われます。"),
                choice("d", "parallelStreamではreduceを使えない", misconception: "並列ストリームの終端操作を制限しすぎ", explanation: "reduceは使えますが、identity・accumulator・combinerの条件が重要です。"),
            ],
            intent: "並列reduceではidentityが単位元である必要があることを確認する。",
            steps: [
                step("3引数 `reduce` では、identity、accumulator、combinerを指定します。並列では複数の部分結果が作られます。", [5, 6, 7], [variable("identity", "int", "10", "reduce")]),
                step("加算の単位元は0です。10は単位元ではないため、部分結果ごとに10が足されると、逐次の感覚とは違う値になります。", [7], [variable("correct identity", "int", "0", "sum")]),
                step("試験では出力値の暗記より、identityが演算の単位元か、combinerが部分結果を正しく統合するかを確認します。", [7, 8], [variable("rule", "String", "identity must be neutral", "parallel reduce")]),
            ]
        ),
        q(
            "gold-balanced-concurrency-volatile-atomicity-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "concurrency",
            tags: ["volatile", "atomicity", "race condition"],
            code: """
class Counter {
    private volatile int count;
    void increment() {
        count++;
    }
    int get() {
        return count;
    }
}
""",
            question: "この `Counter` の説明として正しいものはどれか？",
            choices: [
                choice("a", "`volatile` により `count++` は原子的になる", misconception: "可視性と原子性を混同", explanation: "`volatile` は主に可視性を保証しますが、読み取り・加算・書き込みの複合操作を原子的にはしません。"),
                choice("b", "`volatile` は他スレッドからの値の見え方には関係するが、`count++` の競合は防がない", correct: true, explanation: "`count++` は複数操作なので、同時実行すると更新ロストが起こり得ます。"),
                choice("c", "`volatile` フィールドは読み取りも書き込みもできない", misconception: "修飾子の意味を誤解", explanation: "`volatile` はアクセス禁止ではありません。メモリ可視性に関わる修飾子です。"),
                choice("d", "`volatile` を付けると `synchronized` と同じロックを取る", misconception: "volatileを排他制御と誤解", explanation: "`volatile` はロックを取得しません。排他が必要なら `synchronized` やAtomicクラスを検討します。"),
            ],
            intent: "volatileは可視性の仕組みであり、複合更新の原子性を保証しないことを確認する。",
            steps: [
                step("`volatile int count` は、あるスレッドの書き込みが他スレッドから見えやすくなる可視性に関わります。", [1, 2], [variable("count", "volatile int", "visible across threads", "Counter")]),
                step("しかし `count++` は、現在値を読む、1を足す、書き戻す、という複数ステップです。同時実行では更新ロストが起こり得ます。", [3, 4, 5], [variable("operation", "count++", "read + add + write", "increment")]),
                step("原子的なカウント更新が必要なら、`AtomicInteger.incrementAndGet()` や同じロックでの `synchronized` を使います。", [4], [variable("rule", "String", "visibility != atomicity", "concurrency")]),
            ]
        ),
        q(
            "gold-balanced-concurrency-atomic-getandincrement-001",
            difficulty: .standard,
            category: "concurrency",
            tags: ["AtomicInteger", "getAndIncrement", "incrementAndGet"],
            code: """
import java.util.concurrent.atomic.*;

public class Test {
    public static void main(String[] args) {
        AtomicInteger value = new AtomicInteger(5);
        int before = value.getAndIncrement();
        int after = value.incrementAndGet();
        System.out.println(before + ":" + after + ":" + value.get());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "5:7:7", correct: true, explanation: "`getAndIncrement` は更新前の5を返して値を6へ進め、`incrementAndGet` は7へ進めて更新後の7を返します。"),
                choice("b", "6:7:7", misconception: "getAndIncrementが更新後を返すと誤解", explanation: "`getAndIncrement` は名前の通りgetが先なので、返す値は更新前です。"),
                choice("c", "5:6:7", misconception: "incrementAndGetの戻り値を更新前と誤解", explanation: "`incrementAndGet` はincrementが先なので、返す値は更新後の7です。"),
                choice("d", "5:7:6", misconception: "最後の値が巻き戻ると誤解", explanation: "2回インクリメントしているため、最終値は7です。"),
            ],
            intent: "AtomicIntegerのgetAndIncrementとincrementAndGetの戻り値の違いを確認する。",
            steps: [
                step("`AtomicInteger` は初期値5で作られます。", [5], [variable("value", "AtomicInteger", "5", "main")]),
                step("`getAndIncrement()` は現在値5を返してから値を6へ増やします。したがって `before` は5です。", [6], [variable("before", "int", "5", "main"), variable("value", "AtomicInteger", "6", "main")]),
                step("`incrementAndGet()` は先に値を7へ増やしてから返します。最終的な `value.get()` も7なので、出力は `5:7:7` です。", [7, 8], [variable("after", "int", "7", "main"), variable("output", "String", "5:7:7", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-collections-concurrenthashmap-compute-001",
            difficulty: .standard,
            category: "collections",
            tags: ["ConcurrentHashMap", "compute", "Map", "concurrency"],
            code: """
import java.util.concurrent.*;

public class Test {
    public static void main(String[] args) {
        ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();
        map.put("a", 1);
        map.compute("a", (k, v) -> v == null ? 10 : v + 10);
        map.compute("b", (k, v) -> v == null ? 10 : v + 10);
        System.out.println(map.get("a") + ":" + map.get("b"));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "11:10", correct: true, explanation: "既存キーaではvが1なので11、未存在キーbではvがnullなので10が格納されます。"),
                choice("b", "10:10", misconception: "既存値を見落とし", explanation: "aには事前に1が入っているため、`v + 10` で11になります。"),
                choice("c", "11:null", misconception: "未存在キーではcomputeされないと誤解", explanation: "`compute` は未存在キーにも呼ばれ、ラムダの戻り値10が格納されます。"),
                choice("d", "NullPointerException", misconception: "vがnullの処理を見落とし", explanation: "ラムダ内で `v == null` を判定しているため、未存在キーでも例外になりません。"),
            ],
            intent: "ConcurrentHashMap.computeの既存キー・未存在キーで渡される値を確認する。",
            steps: [
                step("空の `ConcurrentHashMap` を作り、キー `a` に1を格納します。", [5, 6], [variable("map", "ConcurrentHashMap<String,Integer>", "{a=1}", "main")]),
                step("`compute(\"a\", ...)` では既存値1が `v` に渡るため、戻り値は11になり、aの値が更新されます。", [7], [variable("map[\"a\"]", "Integer", "11", "main")]),
                step("`compute(\"b\", ...)` では `v` がnullです。ラムダは10を返してbに格納するため、出力は `11:10` です。", [8, 9], [variable("output", "String", "11:10", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-concurrency-lock-kind-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "concurrency",
            tags: ["synchronized", "instance lock", "class lock", "static"],
            code: """
class Box {
    synchronized void instanceWork() {}
    static synchronized void staticWork() {}
}
""",
            question: "この2つのメソッドが使うロックについて正しい説明はどれか？",
            choices: [
                choice("a", "どちらも同じ `this` のロックを使う", misconception: "static synchronizedのロックを誤解", explanation: "staticメソッドには `this` がありません。クラスオブジェクトのロックを使います。"),
                choice("b", "`instanceWork` は各インスタンス、`staticWork` は `Box.class` のロックを使う", correct: true, explanation: "インスタンスsynchronizedは `this`、static synchronizedは `Class` オブジェクトがロックです。"),
                choice("c", "`staticWork` はロックを使わない", misconception: "staticと排他制御を無関係と誤解", explanation: "`static synchronized` はクラスオブジェクトで排他制御します。"),
                choice("d", "別インスタンスの `instanceWork` 同士も必ず待ち合う", misconception: "インスタンスごとのロックを見落とし", explanation: "別インスタンスなら `this` が別なので、同じロックではありません。"),
            ],
            intent: "インスタンスsynchronizedとstatic synchronizedのロック対象の違いを確認する。",
            steps: [
                step("`synchronized void instanceWork()` は、呼び出し対象インスタンスの `this` をロックに使います。", [1, 2], [variable("instance lock", "Object", "this", "Box instance")]),
                step("`static synchronized void staticWork()` はインスタンスではなく `Box.class` をロックに使います。", [3], [variable("class lock", "Class<Box>", "Box.class", "class object")]),
                step("同じsynchronizedでも、どのロックを共有しているかで待ち合う相手が変わります。試験ではここを具体的に読む必要があります。", [2, 3], [variable("rule", "String", "instance lock != class lock", "synchronized")]),
            ]
        ),
        q(
            "gold-balanced-module-requires-static-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "module-system",
            tags: ["module", "requires static", "readability"],
            code: """
module com.app {
    requires static com.tool;
}
""",
            question: "`requires static com.tool;` の説明として正しいものはどれか？",
            choices: [
                choice("a", "コンパイル時には必要だが、実行時の必須依存にはしない", correct: true, explanation: "`requires static` はコンパイル時依存を表し、実行時には必須解決されない依存です。"),
                choice("b", "実行時だけ必要で、コンパイル時には読めない", misconception: "staticの意味を逆に読む誤解", explanation: "コンパイル時に読める依存を宣言します。実行時必須ではない点が特徴です。"),
                choice("c", "依存先の全パッケージを自動的にexportsする", misconception: "requiresとexportsを混同", explanation: "読み取り関係とパッケージ公開は別です。"),
                choice("d", "staticメソッドだけを利用できるようにする", misconception: "Javaのstaticメンバと混同", explanation: "モジュール宣言の `static` であり、メソッド修飾子ではありません。"),
            ],
            intent: "requires staticのコンパイル時依存という意味を確認する。",
            steps: [
                step("`requires static com.tool;` は、`com.app` がコンパイル時に `com.tool` を読むことを宣言します。", [1, 2], [variable("compile-time readability", "module", "com.tool", "com.app")]),
                step("通常の `requires` と違い、実行時のモジュール解決で必須依存として要求しない点が特徴です。", [2], [variable("runtime dependency", "module", "optional", "module graph")]),
                step("これはstaticメソッドの利用制限ではありません。モジュール依存の種類として読む必要があります。", [2], [variable("keyword", "requires static", "compile-time dependency", "module-info")]),
            ]
        ),
        q(
            "gold-balanced-module-qualified-exports-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "module-system",
            tags: ["module", "exports to", "qualified exports"],
            code: """
module com.lib {
    exports com.lib.api to com.client;
}

module com.client {
    requires com.lib;
}

module com.other {
    requires com.lib;
}
""",
            question: "`exports com.lib.api to com.client;` の説明として正しいものはどれか？",
            choices: [
                choice("a", "`com.lib.api` はすべてのモジュールへ公開される", misconception: "qualified exportsを通常exportsと混同", explanation: "`to com.client` があるため、公開先は限定されます。"),
                choice("b", "`com.client` にだけ通常アクセス用に公開される", correct: true, explanation: "qualified exportsは指定したモジュールにだけパッケージを公開します。"),
                choice("c", "`com.other` はrequiresしているので同じようにアクセスできる", misconception: "readabilityだけでアクセスできると誤解", explanation: "`requires` で読めても、対象パッケージが自分にexportsされていなければ通常アクセスできません。"),
                choice("d", "リフレクション用にprivateメンバまで開く", misconception: "exportsとopensを混同", explanation: "通常アクセスの公開はexports、深いリフレクションはopensです。"),
            ],
            intent: "qualified exportsが公開先を限定することを確認する。",
            steps: [
                step("`exports com.lib.api to com.client;` は、`com.lib.api` の通常アクセス公開先を `com.client` に限定します。", [1, 2], [variable("exported package", "package", "com.lib.api", "com.lib")]),
                step("`com.client` は `requires com.lib` しており、かつ公開先に指定されているため、そのパッケージへ通常アクセスできます。", [5, 6], [variable("com.client access", "boolean", "true", "module graph")]),
                step("`com.other` も `com.lib` を読めますが、qualified exportsの公開先ではないため同じ通常アクセスはできません。", [9, 10], [variable("com.other access", "boolean", "false", "module graph")]),
            ]
        ),
        q(
            "gold-balanced-module-opens-to-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "module-system",
            tags: ["module", "opens to", "reflection"],
            code: """
module com.app {
    opens com.app.domain to com.framework;
}
""",
            question: "`opens com.app.domain to com.framework;` の説明として正しいものはどれか？",
            choices: [
                choice("a", "`com.app.domain` を通常のimport対象として全モジュールへ公開する", misconception: "opensをexportsと混同", explanation: "`opens` は通常アクセスではなく、主に深いリフレクション用です。"),
                choice("b", "`com.framework` に対して深いリフレクションを許可する", correct: true, explanation: "qualified opensにより、指定モジュールへリフレクションアクセスを開きます。"),
                choice("c", "`com.framework` をコンパイル時に必ず読み取る宣言である", misconception: "opensとrequiresを混同", explanation: "依存関係を宣言するのは `requires` です。"),
                choice("d", "このパッケージ内のpublic型だけを通常アクセスできるようにする", misconception: "publicアクセスとdeep reflectionを混同", explanation: "通常アクセスには `exports` を使います。"),
            ],
            intent: "qualified opensが特定モジュールへの深いリフレクション許可であることを確認する。",
            steps: [
                step("`opens` は、フレームワークなどがリフレクションでprivateメンバへアクセスする場面に関係します。", [1, 2], [variable("opened package", "package", "com.app.domain", "com.app")]),
                step("`to com.framework` が付いているため、開く相手は `com.framework` に限定されます。", [2], [variable("target module", "module", "com.framework", "module-info")]),
                step("通常のimportや型参照を公開するための指定ではありません。exportsとopensを分けて読むのが重要です。", [2], [variable("rule", "String", "opens = reflection", "module system")]),
            ]
        ),
        q(
            "gold-balanced-module-service-provider-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "module-system",
            tags: ["module", "uses", "provides", "ServiceLoader"],
            code: """
module client {
    uses com.example.Plugin;
}

module provider {
    provides com.example.Plugin with com.example.impl.PluginImpl;
}
""",
            question: "このモジュール宣言の読み方として正しいものはどれか？",
            choices: [
                choice("a", "`uses` はサービス実装を提供する側に書く", misconception: "usesとprovidesの方向を逆にしている", explanation: "`uses` はサービスを利用する側、`provides ... with ...` は実装を提供する側に書きます。"),
                choice("b", "`provides` はサービスインターフェースと実装クラスを結び付ける", correct: true, explanation: "`provides com.example.Plugin with ...` により、ServiceLoaderが実装を発見できるようになります。"),
                choice("c", "`provides` を書くと実装パッケージは必ず全モジュールへexportsされる", misconception: "サービス提供と通常公開を混同", explanation: "サービス提供とパッケージexportsは別の指定です。"),
                choice("d", "`uses` と `provides` は実行時には参照されない", misconception: "ServiceLoaderとの関係を見落とし", explanation: "ServiceLoaderによるサービス発見に関係します。"),
            ],
            intent: "JavaモジュールのServiceLoader宣言でuses/providesの役割を確認する。",
            steps: [
                step("`client` モジュールは `uses com.example.Plugin;` により、そのサービス型を利用することを宣言します。", [1, 2], [variable("client", "module", "uses Plugin", "module graph")]),
                step("`provider` モジュールは `provides ... with ...` により、サービス型 `Plugin` の実装として `PluginImpl` を提供します。", [5, 6], [variable("provider", "module", "Plugin -> PluginImpl", "module graph")]),
                step("この宣言は通常のexportsとは別です。ServiceLoaderによる発見と、パッケージの通常公開を混同しないようにします。", [6], [variable("rule", "String", "service binding != exports", "module system")]),
            ]
        ),
        q(
            "gold-balanced-jdbc-parameter-index-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["JDBC", "PreparedStatement", "parameter index"],
            code: """
PreparedStatement ps = conn.prepareStatement(
    "SELECT * FROM users WHERE id = ? AND name = ?"
);
ps.setInt(1, 10);
ps.setString(2, "A");
ResultSet rs = ps.executeQuery();
""",
            question: "この `PreparedStatement` のパラメータ指定について正しいものはどれか？",
            choices: [
                choice("a", "パラメータ番号は0から始まる", misconception: "配列インデックスと混同", explanation: "JDBCのパラメータ番号は1始まりです。"),
                choice("b", "1つ目の `?` に10、2つ目の `?` にAが入る", correct: true, explanation: "`setInt(1, 10)` が1つ目、`setString(2, \"A\")` が2つ目のプレースホルダに対応します。"),
                choice("c", "`setString(2, \"A\")` は3つ目の `?` を表す", misconception: "0始まりで読んでいる", explanation: "1始まりなので2は2つ目のプレースホルダです。"),
                choice("d", "SELECT文なので `executeUpdate()` を使う", misconception: "JDBCの実行メソッドを混同", explanation: "SELECTは通常 `executeQuery()` で `ResultSet` を受け取ります。"),
            ],
            intent: "PreparedStatementのパラメータ番号が1始まりであることを確認する。",
            steps: [
                step("SQLには2つの `?` プレースホルダがあります。JDBCではこれらを1始まりの番号で指定します。", [1, 2], [variable("placeholders", "int", "2", "SQL")]),
                step("`ps.setInt(1, 10)` は1つ目の `?`、`ps.setString(2, \"A\")` は2つ目の `?` に値を設定します。", [4, 5], [variable("param1", "int", "10", "PreparedStatement"), variable("param2", "String", "A", "PreparedStatement")]),
                step("SELECT文なので、実行は `executeQuery()` で `ResultSet` を取得します。", [6], [variable("rs", "ResultSet", "query result", "JDBC")]),
            ]
        ),
        q(
            "gold-balanced-jdbc-execute-boolean-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["JDBC", "Statement", "execute", "executeQuery"],
            code: """
boolean hasResultSet = stmt.execute(sql);
if (hasResultSet) {
    ResultSet rs = stmt.getResultSet();
} else {
    int count = stmt.getUpdateCount();
}
""",
            question: "`Statement.execute(sql)` の戻り値について正しい説明はどれか？",
            choices: [
                choice("a", "更新件数をintで返す", misconception: "executeUpdateと混同", explanation: "更新件数を返すのは `executeUpdate` です。`execute` はbooleanを返します。"),
                choice("b", "最初の結果がResultSetならtrueを返す", correct: true, explanation: "`execute` は結果の種類をbooleanで返し、trueなら `getResultSet()` を使います。"),
                choice("c", "SELECT文では必ずfalseを返す", misconception: "booleanの意味を逆にしている", explanation: "最初の結果が `ResultSet` ならtrueです。SELECTでは通常trueです。"),
                choice("d", "ResultSetそのものを返す", misconception: "executeQueryと混同", explanation: "ResultSetを直接返すのは `executeQuery` です。"),
            ],
            intent: "JDBCのexecute/executeQuery/executeUpdateの戻り値の違いを確認する。",
            steps: [
                step("`stmt.execute(sql)` は、SQLの最初の結果が `ResultSet` かどうかをbooleanで返します。", [1], [variable("hasResultSet", "boolean", "depends on first result", "JDBC")]),
                step("戻り値がtrueなら `stmt.getResultSet()` で結果セットを取得します。", [2, 3], [variable("rs", "ResultSet", "available when true", "JDBC")]),
                step("戻り値がfalseなら更新件数などを `getUpdateCount()` で確認します。戻り値自体が更新件数ではない点がひっかけです。", [4, 5], [variable("count", "int", "update count", "JDBC")]),
            ]
        ),
        q(
            "gold-balanced-jdbc-resultset-cursor-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["JDBC", "ResultSet", "next", "cursor"],
            code: """
ResultSet rs = stmt.executeQuery("SELECT name FROM users");
String name = rs.getString("name");
System.out.println(name);
""",
            question: "このコードの問題点として正しいものはどれか？",
            choices: [
                choice("a", "`ResultSet` は最初から1行目を指しているので問題ない", misconception: "カーソル初期位置を誤解", explanation: "ResultSetのカーソルは最初の行の前にあります。読む前に `next()` が必要です。"),
                choice("b", "`rs.next()` を呼んで行へ進めてから値を読む必要がある", correct: true, explanation: "カーソルを有効な行に移動させる前に `getString` すると不正です。"),
                choice("c", "`getString` は列名では呼べない", misconception: "ResultSet APIを誤解", explanation: "列名でも列番号でも取得できます。"),
                choice("d", "SELECT文には `executeUpdate` が必要", misconception: "JDBCメソッドを混同", explanation: "SELECT文には `executeQuery` が適切です。問題はカーソル移動です。"),
            ],
            intent: "ResultSetのカーソル初期位置とnext()の必要性を確認する。",
            steps: [
                step("`executeQuery` で `ResultSet` を取得した直後、カーソルは最初の行そのものではなく、最初の行の前にあります。", [1], [variable("cursor", "ResultSet cursor", "before first row", "rs")]),
                step("値を読むには、通常 `rs.next()` を呼んで次の行へ移動し、戻り値で行が存在することを確認します。", [2], [variable("required call", "boolean", "rs.next()", "ResultSet")]),
                step("このコードは `next()` なしで `getString` している点が誤りです。列名指定が悪いわけではありません。", [2], [variable("problem", "String", "cursor not positioned", "JDBC")]),
            ]
        ),
        q(
            "gold-balanced-jdbc-try-with-resources-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "jdbc",
            tags: ["JDBC", "try-with-resources", "close order"],
            code: """
try (Connection con = ds.getConnection();
     PreparedStatement ps = con.prepareStatement(sql);
     ResultSet rs = ps.executeQuery()) {
    while (rs.next()) {
        System.out.println(rs.getString(1));
    }
}
""",
            question: "このtry-with-resourcesの終了時の説明として正しいものはどれか？",
            choices: [
                choice("a", "宣言順に `Connection` から閉じられる", misconception: "リソースのクローズ順を誤解", explanation: "try-with-resourcesは宣言と逆順に閉じます。"),
                choice("b", "`ResultSet`、`PreparedStatement`、`Connection` の順に閉じられる", correct: true, explanation: "リソースは後に宣言したものから逆順でcloseされます。"),
                choice("c", "`ResultSet` はAutoCloseableではないので閉じられない", misconception: "JDBCリソースの扱いを誤解", explanation: "`ResultSet` もtry-with-resourcesで扱えるリソースです。"),
                choice("d", "例外が発生した場合はどのリソースも閉じられない", misconception: "try-with-resourcesの保証を見落とし", explanation: "例外時もcloseが試みられます。close時例外は抑制例外になることがあります。"),
            ],
            intent: "JDBCリソースをtry-with-resourcesで逆順に閉じることを確認する。",
            steps: [
                step("try-with-resourcesには `Connection`、`PreparedStatement`、`ResultSet` がこの順で宣言されています。", [1, 2, 3], [variable("resources", "AutoCloseable[]", "con, ps, rs", "try")]),
                step("ブロックを抜けると、リソースは宣言順ではなく逆順にcloseされます。まず `rs`、次に `ps`、最後に `con` です。", [3, 6], [variable("close order", "String", "rs -> ps -> con", "try-with-resources")]),
                step("例外があってもcloseは試みられるため、JDBCではリソースリーク防止の基本形になります。", [1, 6], [variable("rule", "String", "reverse close order", "JDBC")]),
            ]
        ),
        q(
            "gold-balanced-datetime-parse-leapday-001",
            difficulty: .standard,
            category: "date-time",
            tags: ["LocalDate", "parse", "DateTimeParseException"],
            code: """
import java.time.*;
import java.time.format.*;

public class Test {
    public static void main(String[] args) {
        try {
            LocalDate date = LocalDate.parse("2023-02-29");
            System.out.println(date);
        } catch (DateTimeParseException e) {
            System.out.println("invalid");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2023-02-28", misconception: "存在しない日付が自動補正されると誤解", explanation: "`parse` は存在しない日付を勝手に月末へ補正しません。"),
                choice("b", "2023-03-01", misconception: "翌日へ繰り上げられると誤解", explanation: "不正な日付文字列は解析例外になります。"),
                choice("c", "invalid", correct: true, explanation: "2023年はうるう年ではないため2月29日は存在せず、`DateTimeParseException` がcatchされます。"),
                choice("d", "null", misconception: "parse失敗時にnullが返ると誤解", explanation: "`parse` は失敗時にnullではなく例外を投げます。"),
            ],
            intent: "LocalDate.parseが不正日付を例外として扱うことを確認する。",
            steps: [
                step("`LocalDate.parse(\"2023-02-29\")` はISO形式の日付として解析しようとします。", [6, 7], [variable("input", "String", "2023-02-29", "main")]),
                step("2023年はうるう年ではないため、2月29日は有効な日付ではありません。解析は失敗し、`DateTimeParseException` が発生します。", [7, 9], [variable("exception", "DateTimeParseException", "invalid date", "catch")]),
                step("catchブロックで `invalid` を出力します。parse失敗時に自動補正やnull返却はされません。", [9, 10], [variable("output", "String", "invalid", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-datetime-duration-between-001",
            difficulty: .tricky,
            category: "date-time",
            tags: ["Duration", "LocalTime", "between"],
            code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        Duration d = Duration.between(
            LocalTime.of(23, 0),
            LocalTime.of(1, 0)
        );
        System.out.println(d);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "PT2H", misconception: "日付をまたいで翌日扱いになると誤解", explanation: "LocalTimeには日付がないため、23:00から同じ日の1:00へ向かう差は負になります。"),
                choice("b", "PT-22H", correct: true, explanation: "`Duration.between(23:00, 01:00)` は開始から終了まで同じ時刻軸で引くため、-22時間です。"),
                choice("c", "P1D", misconception: "DurationとPeriodを混同", explanation: "時刻間の時間量なのでDurationです。日付ベースのPeriodではありません。"),
                choice("d", "DateTimeException", misconception: "終了が開始より前だと例外になると誤解", explanation: "betweenは負のDurationを返せます。"),
            ],
            intent: "Duration.betweenが負のDurationを返し得ることを確認する。",
            steps: [
                step("開始時刻は23:00、終了時刻は1:00です。`LocalTime` には日付がないため、翌日1:00とは解釈されません。", [5, 6, 7], [variable("start", "LocalTime", "23:00", "main"), variable("end", "LocalTime", "01:00", "main")]),
                step("同じ日の時刻として差を取ると、23:00から1:00は22時間戻る方向です。", [5, 8], [variable("d", "Duration", "PT-22H", "main")]),
                step("`Duration.toString()` の形式で、負の22時間は `PT-22H` と表示されます。", [9], [variable("output", "String", "PT-22H", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-datetime-period-order-001",
            difficulty: .tricky,
            category: "date-time",
            tags: ["Period", "LocalDate", "plusMonths"],
            code: """
import java.time.*;

public class Test {
    public static void main(String[] args) {
        LocalDate date = LocalDate.of(2024, 1, 31)
            .plus(Period.ofMonths(1).plusDays(2));
        System.out.println(date);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2024-02-29", misconception: "days加算を見落とし", explanation: "1か月加算で2月29日に調整された後、さらに2日進みます。"),
                choice("b", "2024-03-02", correct: true, explanation: "2024-01-31に1か月を足すと2024-02-29、そこへ2日足して2024-03-02です。"),
                choice("c", "2024-03-04", misconception: "1か月を31日として計算している", explanation: "Periodの月はカレンダー月として加算され、存在しない日は月末に調整されます。"),
                choice("d", "DateTimeException", misconception: "1月31日+1か月が不正になると誤解", explanation: "不正日付で例外にするのではなく、有効な月末へ調整されます。"),
            ],
            intent: "LocalDateにPeriodの月・日を加えるときの月末調整と順序を確認する。",
            steps: [
                step("基準日は2024-01-31です。2024年はうるう年なので2月末日は29日です。", [5], [variable("base", "LocalDate", "2024-01-31", "main")]),
                step("`Period.ofMonths(1).plusDays(2)` は1か月と2日のPeriodです。まず月ベースの加算で2024-02-29へ調整されます。", [6], [variable("after month", "LocalDate", "2024-02-29", "date calculation")]),
                step("そこから2日加算して2024-03-02になります。出力は `2024-03-02` です。", [6, 7], [variable("date", "LocalDate", "2024-03-02", "main")]),
            ]
        ),
        q(
            "gold-balanced-datetime-formatter-parse-001",
            difficulty: .standard,
            category: "date-time",
            tags: ["DateTimeFormatter", "ofPattern", "parse"],
            code: """
import java.time.*;
import java.time.format.*;

public class Test {
    public static void main(String[] args) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("uuuu/MM/dd");
        LocalDate date = LocalDate.parse("2024/04/05", formatter);
        System.out.println(date);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "2024/04/05", misconception: "入力文字列がそのまま出ると誤解", explanation: "出力しているのはLocalDateです。LocalDateの標準文字列表現はISO形式です。"),
                choice("b", "2024-04-05", correct: true, explanation: "指定フォーマッタで文字列を解析し、LocalDateとして出力するとISO形式の `2024-04-05` になります。"),
                choice("c", "04/05/2024", misconception: "ロケールの短い日付形式と混同", explanation: "このコードはロケール形式ではなく明示パターン `uuuu/MM/dd` を使っています。"),
                choice("d", "DateTimeParseException", misconception: "スラッシュ区切りは常に解析不可と誤解", explanation: "パターンが `uuuu/MM/dd` なので、入力 `2024/04/05` と一致します。"),
            ],
            intent: "DateTimeFormatter.ofPatternで指定した形式によるparseとLocalDateの出力形式を確認する。",
            steps: [
                step("`DateTimeFormatter.ofPattern(\"uuuu/MM/dd\")` により、年/月/日をスラッシュ区切りで読むフォーマッタを作ります。", [6], [variable("formatter", "DateTimeFormatter", "uuuu/MM/dd", "main")]),
                step("入力 `2024/04/05` はパターンに一致するため、`LocalDate` として2024年4月5日に解析されます。", [7], [variable("date", "LocalDate", "2024-04-05", "main")]),
                step("`System.out.println(date)` はLocalDateの標準形式で表示するため、出力は `2024-04-05` です。", [8], [variable("output", "String", "2024-04-05", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-io-createdirectories-001",
            difficulty: .standard,
            category: "io",
            tags: ["Files", "createDirectories", "NIO.2"],
            code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) throws Exception {
        Path base = Files.createTempDirectory("jvs");
        Path dir = base.resolve("a/b");
        Files.createDirectories(dir);
        Files.createDirectories(dir);
        System.out.println(Files.isDirectory(dir));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", correct: true, explanation: "`createDirectories` は必要な親ディレクトリも作成し、既に存在していても例外にせず完了できます。"),
                choice("b", "false", misconception: "親ディレクトリが作られないと誤解", explanation: "`createDirectories` は `a` と `b` のような不足する親も作ります。"),
                choice("c", "FileAlreadyExistsException", misconception: "2回目もcreateDirectoryと同じだと誤解", explanation: "`createDirectory` と違い、`createDirectories` は既存ディレクトリを許容します。"),
                choice("d", "NoSuchFileException", misconception: "親がないと失敗すると誤解", explanation: "不足する親を含めて作るのが `createDirectories` です。"),
            ],
            intent: "Files.createDirectoriesが親ディレクトリ作成と既存許容を行うことを確認する。",
            steps: [
                step("一時ディレクトリを作り、その下の `a/b` を表すPathを作成します。この時点ではまだ `a/b` はありません。", [5, 6], [variable("dir", "Path", "base/a/b", "main")]),
                step("1回目の `Files.createDirectories(dir)` で不足している親 `a` と対象 `b` が作成されます。", [7], [variable("created", "Path", "a/b", "filesystem")]),
                step("2回目は対象ディレクトリが既に存在しますが、`createDirectories` は既存ディレクトリを許容します。`Files.isDirectory(dir)` はtrueです。", [8, 9], [variable("output", "boolean", "true", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-io-path-resolve-absolute-001",
            difficulty: .tricky,
            category: "io",
            tags: ["Path", "resolve", "absolute path"],
            code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path base = Paths.get("/work/app");
        Path result = base.resolve("/tmp/log.txt");
        System.out.println(result);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "/work/app/tmp/log.txt", misconception: "絶対パスも単純連結されると誤解", explanation: "`resolve` の引数が絶対パスの場合、baseは使われず引数側が結果になります。"),
                choice("b", "/tmp/log.txt", correct: true, explanation: "解決対象が絶対パスなので、`base.resolve(other)` の結果はotherそのものです。"),
                choice("c", "/work/tmp/log.txt", misconception: "親を1段戻る処理と混同", explanation: "このコードに `..` や `resolveSibling` はありません。"),
                choice("d", "InvalidPathException", misconception: "絶対パスをresolveできないと誤解", explanation: "絶対パスもPathとして有効で、resolveの仕様に従います。"),
            ],
            intent: "Path.resolveで引数が絶対パスの場合の結果を確認する。",
            steps: [
                step("`base` は `/work/app` を表す絶対Pathです。", [5], [variable("base", "Path", "/work/app", "main")]),
                step("`resolve` の引数 `/tmp/log.txt` も絶対Pathです。この場合、baseに連結せず、引数側のPathが結果になります。", [6], [variable("result", "Path", "/tmp/log.txt", "main")]),
                step("したがって出力は `/tmp/log.txt` です。相対Pathを渡した場合とは結果が異なります。", [7], [variable("output", "String", "/tmp/log.txt", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-io-files-walk-close-001",
            difficulty: .standard,
            category: "io",
            tags: ["Files.walk", "Stream", "try-with-resources"],
            code: """
import java.nio.file.*;
import java.util.stream.*;

public class Test {
    public static void main(String[] args) throws Exception {
        Path dir = Files.createTempDirectory("walk");
        Files.writeString(dir.resolve("a.txt"), "A");
        try (Stream<Path> paths = Files.walk(dir)) {
            long count = paths.filter(Files::isRegularFile).count();
            System.out.println(count);
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "0", misconception: "Files.walkがディレクトリだけ返すと誤解", explanation: "`Files.walk` は開始ディレクトリ配下のファイルも返します。"),
                choice("b", "1", correct: true, explanation: "一時ディレクトリ内に `a.txt` を1つ作り、通常ファイルだけを数えるため1です。"),
                choice("c", "2", misconception: "開始ディレクトリも通常ファイルとして数えると誤解", explanation: "開始ディレクトリはwalkに含まれますが、`Files::isRegularFile` で除外されます。"),
                choice("d", "IllegalStateException", misconception: "try内で既にStreamが閉じていると誤解", explanation: "Streamはtryブロック終了時に閉じられます。`count()` はブロック内で実行されます。"),
            ],
            intent: "Files.walkがStreamを返し、try-with-resourcesで閉じる必要があることを確認する。",
            steps: [
                step("一時ディレクトリを作成し、その直下に `a.txt` を1つ書き込みます。", [6, 7], [variable("dir contents", "Path[]", "a.txt", "filesystem")]),
                step("`Files.walk(dir)` は開始ディレクトリと配下のPathをStreamで返します。I/Oリソースを持つためtry-with-resourcesで閉じます。", [8], [variable("paths", "Stream<Path>", "dir, a.txt", "try")]),
                step("`filter(Files::isRegularFile)` によりディレクトリは除外され、通常ファイル `a.txt` だけが残ります。countは1です。", [9, 10], [variable("count", "long", "1", "main")]),
            ]
        ),
        q(
            "gold-balanced-secure-path-normalize-001",
            difficulty: .tricky,
            category: "secure-coding",
            tags: ["Path", "normalize", "path traversal", "secure coding"],
            code: """
import java.nio.file.*;

public class Test {
    public static void main(String[] args) {
        Path base = Paths.get("/app/data");
        Path target = base.resolve("../secret.txt").normalize();
        System.out.println(target.startsWith(base));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", misconception: "base.resolveしたので必ずbase配下だと誤解", explanation: "`..` をnormalizeすると `/app/secret.txt` になり、`/app/data` 配下ではなくなります。"),
                choice("b", "false", correct: true, explanation: "`base.resolve(\"../secret.txt\").normalize()` は `/app/secret.txt` となり、base `/app/data` からは外れます。"),
                choice("c", "InvalidPathException", misconception: "`..` を不正パスと誤解", explanation: "`..` はPath要素として扱われ、normalizeで構文的に整理されます。"),
                choice("d", "SecurityException", misconception: "normalizeがアクセス制御を行うと誤解", explanation: "`normalize` は文字列的なPath整理であり、セキュリティ検査そのものではありません。"),
            ],
            intent: "Path.normalizeだけではディレクトリトラバーサル対策にならず、startsWith等の検証が必要なことを確認する。",
            steps: [
                step("`base` は `/app/data` です。ユーザー入力のような `../secret.txt` を単純にresolveしています。", [5, 6], [variable("base", "Path", "/app/data", "main")]),
                step("`normalize()` は `..` を構文的に整理するため、targetは `/app/secret.txt` になります。", [6], [variable("target", "Path", "/app/secret.txt", "main")]),
                step("targetは `/app/data` から始まらないため、`target.startsWith(base)` はfalseです。base配下かの検証が重要です。", [7], [variable("output", "boolean", "false", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-secure-serialization-filter-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "secure-coding",
            tags: ["serialization", "ObjectInputFilter", "secure coding"],
            code: """
ObjectInputStream in = new ObjectInputStream(source);
ObjectInputFilter filter = ObjectInputFilter.Config.createFilter(
    "com.example.SafeData;!*"
);
in.setObjectInputFilter(filter);
Object obj = in.readObject();
""",
            question: "この `ObjectInputFilter` の目的として正しいものはどれか？",
            choices: [
                choice("a", "デシリアライズできるクラスを制限する", correct: true, explanation: "フィルタにより許可する型や拒否する型を制御し、危険なデシリアライズを抑制できます。"),
                choice("b", "シリアライズされた全フィールドを暗号化する", misconception: "フィルタと暗号化を混同", explanation: "ObjectInputFilterは暗号化APIではありません。読み込む型などを制限します。"),
                choice("c", "`transient` フィールドを復元する", misconception: "シリアライズ対象外フィールドの扱いと混同", explanation: "`transient` はデフォルトシリアライズ対象外です。フィルタで復元するものではありません。"),
                choice("d", "readObjectを呼ばずにオブジェクトを生成する", misconception: "フィルタを生成処理と誤解", explanation: "フィルタを設定したうえで `readObject()` が読み込みを行います。"),
            ],
            intent: "ObjectInputFilterによるデシリアライズ対象制限をセキュアコーディングとして確認する。",
            steps: [
                step("`ObjectInputStream` は外部データからオブジェクトを復元するため、信頼できない入力ではリスクがあります。", [1], [variable("in", "ObjectInputStream", "reads serialized data", "main")]),
                step("`ObjectInputFilter.Config.createFilter(\"com.example.SafeData;!*\")` は、許可する型と拒否する型のパターンを作っています。", [2, 3], [variable("filter", "ObjectInputFilter", "allow SafeData, reject others", "main")]),
                step("`setObjectInputFilter` 後に `readObject()` することで、デシリアライズ時にフィルタが適用されます。目的は読み込むクラスの制限です。", [4, 5], [variable("purpose", "String", "limit deserialization classes", "security")]),
            ]
        ),
        q(
            "gold-balanced-collections-arraydeque-null-001",
            difficulty: .standard,
            category: "collections",
            tags: ["ArrayDeque", "Queue", "null"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        Deque<String> deque = new ArrayDeque<>();
        try {
            deque.add(null);
        } catch (NullPointerException e) {
            System.out.println("NPE");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "NPE", correct: true, explanation: "`ArrayDeque` はnull要素を許容しないため、`add(null)` で `NullPointerException` が発生します。"),
                choice("b", "null", misconception: "nullが要素として入ると誤解", explanation: "`ArrayDeque` はnullを禁止します。"),
                choice("c", "0", misconception: "サイズを出力していると誤解", explanation: "サイズ出力はなく、catchで `NPE` を出力します。"),
                choice("d", "ClassCastException", misconception: "型変換エラーと混同", explanation: "型の問題ではなく、null禁止による `NullPointerException` です。"),
            ],
            intent: "ArrayDequeがnull要素を許容しないことを確認する。",
            steps: [
                step("`ArrayDeque<String>` を空で作成します。Dequeインターフェースとして参照していますが、実体はArrayDequeです。", [5], [variable("deque", "Deque<String>", "ArrayDeque, empty", "main")]),
                step("`ArrayDeque` はnull要素を許容しません。`deque.add(null)` で `NullPointerException` が投げられます。", [6, 7, 8], [variable("exception", "NullPointerException", "null elements not allowed", "main")]),
                step("catchブロックで `NPE` を出力します。LinkedListなど一部コレクションとの違いが狙われます。", [8, 9], [variable("output", "String", "NPE", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-collections-mapof-duplicate-001",
            difficulty: .standard,
            category: "collections",
            tags: ["Map.of", "duplicate key", "IllegalArgumentException"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        try {
            Map<String, Integer> map = Map.of("a", 1, "a", 2);
            System.out.println(map.size());
        } catch (IllegalArgumentException e) {
            System.out.println("duplicate");
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1", misconception: "後の値で上書きされると誤解", explanation: "`Map.of` は重複キーを許容せず、上書きしません。"),
                choice("b", "2", misconception: "2要素として保持されると誤解", explanation: "Mapは同じキーを2つ保持できず、`Map.of` は生成時に例外を投げます。"),
                choice("c", "duplicate", correct: true, explanation: "`Map.of` に重複キーを渡すと `IllegalArgumentException` が発生します。"),
                choice("d", "NullPointerException", misconception: "null禁止と重複キーを混同", explanation: "nullも禁止ですが、このコードの問題は重複キーです。"),
            ],
            intent: "Map.ofが重複キーをIllegalArgumentExceptionで拒否することを確認する。",
            steps: [
                step("`Map.of(\"a\", 1, \"a\", 2)` は同じキー `a` を2回指定しています。", [6], [variable("keys", "String[]", "a, a", "main")]),
                step("`Map.of` は重複キーを後勝ちで上書きせず、生成時に `IllegalArgumentException` を投げます。", [6, 8], [variable("exception", "IllegalArgumentException", "duplicate key", "main")]),
                step("catchブロックで `duplicate` を出力します。変更不可Mapの生成ルールとして、nullと重複キーは禁止です。", [8, 9], [variable("output", "String", "duplicate", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-collections-listof-add-001",
            difficulty: .standard,
            category: "collections",
            tags: ["List.of", "immutable", "UnsupportedOperationException"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> list = List.of("A");
        try {
            list.add("B");
        } catch (UnsupportedOperationException e) {
            System.out.println(list);
        }
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "[A]", correct: true, explanation: "`List.of` のリストは変更不可です。addは例外となり、元の `[A]` が出力されます。"),
                choice("b", "[A, B]", misconception: "List.ofのリストを変更可能と誤解", explanation: "`List.of` は変更不可リストを返します。"),
                choice("c", "[]", misconception: "例外時にリストが空になると誤解", explanation: "作成済みの `[A]` はそのままです。addが失敗するだけです。"),
                choice("d", "NullPointerException", misconception: "null禁止と混同", explanation: "nullは使っていません。変更不可リストへのaddなので `UnsupportedOperationException` です。"),
            ],
            intent: "List.ofで作成したリストが変更不可であることを確認する。",
            steps: [
                step("`List.of(\"A\")` は要素Aを持つ変更不可リストを作ります。", [5], [variable("list", "List<String>", "[A]", "main")]),
                step("`list.add(\"B\")` は変更操作なので `UnsupportedOperationException` が発生します。Bは追加されません。", [6, 7, 8], [variable("exception", "UnsupportedOperationException", "immutable list", "main")]),
                step("catchブロックで現在のlistを出力します。内容は元の `[A]` のままです。", [8, 9], [variable("output", "String", "[A]", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-generics-super-add-read-001",
            difficulty: .tricky,
            category: "generics",
            tags: ["Generics", "? super", "PECS"],
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
                choice("a", "Integer", correct: true, explanation: "`? super Integer` にはIntegerを追加でき、取り出し型は安全にはObjectです。実体値はIntegerなのでクラス名はIntegerです。"),
                choice("b", "Number", misconception: "宣言されたArrayList<Number>の型が値の実体になると誤解", explanation: "格納した値そのものは `Integer` オブジェクトです。"),
                choice("c", "Object", misconception: "コンパイル時型と実行時型を混同", explanation: "変数の型はObjectですが、実行時オブジェクトのクラスはIntegerです。"),
                choice("d", "コンパイルエラー", misconception: "? super IntegerにIntegerを追加できないと誤解", explanation: "`? super Integer` はIntegerまたはそのサブタイプの追加が安全です。"),
            ],
            intent: "? super IntegerにはIntegerを追加できるが読み取り型はObjectになることを確認する。",
            steps: [
                step("`List<? super Integer>` は、Integerのスーパータイプを要素型に持つリストです。ここでは `ArrayList<Number>` を代入できます。", [5], [variable("list", "List<? super Integer>", "ArrayList<Number>", "main")]),
                step("`list.add(10)` はIntegerの追加なので安全です。読み取るときは具体的なスーパータイプが不明なため、型はObjectとして受けます。", [6, 7], [variable("value", "Object", "Integer(10)", "main")]),
                step("`value.getClass().getSimpleName()` は実行時オブジェクトのクラス名を見るため、出力は `Integer` です。", [8], [variable("output", "String", "Integer", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-collections-comparator-thencomparing-001",
            difficulty: .standard,
            category: "collections",
            tags: ["Comparator", "thenComparing", "sorted"],
            code: """
import java.util.*;

public class Test {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>(List.of("bb", "a", "aa"));
        list.sort(Comparator.comparingInt(String::length).thenComparing(Comparator.naturalOrder()));
        System.out.println(list);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "[a, aa, bb]", correct: true, explanation: "まず長さ順でaが先、長さ2同士のaaとbbは自然順でaa,bbになります。"),
                choice("b", "[a, bb, aa]", misconception: "thenComparingを見落とし", explanation: "長さ2の要素は `thenComparing` により自然順で並びます。"),
                choice("c", "[aa, a, bb]", misconception: "自然順だけで並べていると誤解", explanation: "主キーは長さです。"),
                choice("d", "[bb, a, aa]", misconception: "sortが元順を保持すると誤解", explanation: "Comparatorに従って並び替えられます。"),
            ],
            intent: "Comparator.comparingIntとthenComparingによる複合順序を確認する。",
            steps: [
                step("元のリストは `bb`, `a`, `aa` です。Comparatorの主キーは `String::length` なので、長さ1の `a` が先頭になります。", [5, 6], [variable("primary key", "int", "length", "Comparator")]),
                step("`bb` と `aa` はどちらも長さ2です。同順位の場合、`thenComparing(Comparator.naturalOrder())` で自然順比較します。", [6], [variable("tie break", "Comparator<String>", "natural order", "Comparator")]),
                step("自然順では `aa` が `bb` より前なので、最終結果は `[a, aa, bb]` です。", [7], [variable("list", "List<String>", "[a, aa, bb]", "main")]),
            ]
        ),
        q(
            "gold-balanced-annotation-inherited-001",
            difficulty: .tricky,
            category: "annotations",
            tags: ["@Inherited", "annotation", "reflection"],
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
                choice("a", "true", correct: true, explanation: "`@Inherited` が付いたクラス用アノテーションは、サブクラスの `Class` からも見えるようになります。"),
                choice("b", "false", misconception: "@Inheritedの効果を見落とし", explanation: "`@Inherited` と `RUNTIME` があるため、Child.classから確認できます。"),
                choice("c", "コンパイルエラー", misconception: "@Inheritedをカスタムアノテーションに付けられないと誤解", explanation: "`@Inherited` はアノテーション型に付けるメタアノテーションです。"),
                choice("d", "NullPointerException", misconception: "アノテーション未検出時の挙動を誤解", explanation: "`isAnnotationPresent` はbooleanを返します。"),
            ],
            intent: "@Inheritedがクラス継承時のアノテーション参照に影響することを確認する。",
            steps: [
                step("`Mark` には `@Inherited` と `@Retention(RUNTIME)` が付いています。実行時リフレクションで確認可能です。", [3, 4, 5], [variable("Mark", "annotation", "Inherited + Runtime", "annotation type")]),
                step("`Parent` に `@Mark` が付き、`Child` は `Parent` を継承しています。", [7, 8, 10], [variable("Parent", "Class", "annotated", "class hierarchy"), variable("Child", "Class", "extends Parent", "class hierarchy")]),
                step("`Child.class.isAnnotationPresent(Mark.class)` は `@Inherited` の効果でtrueを返します。", [14], [variable("output", "boolean", "true", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-annotation-target-typeuse-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "annotations",
            tags: ["@Target", "TYPE_USE", "annotation"],
            code: """
import java.lang.annotation.*;

@Target(ElementType.TYPE_USE)
@interface NonNull {}

class Sample {
    String text;
    @NonNull String value;
}
""",
            question: "`@Target(ElementType.TYPE_USE)` の説明として正しいものはどれか？",
            choices: [
                choice("a", "クラス宣言にだけ付けられる", misconception: "TYPEとTYPE_USEを混同", explanation: "クラスやインターフェース宣言そのものは `TYPE` です。`TYPE_USE` は型の使用箇所です。"),
                choice("b", "型が使われる場所にアノテーションを付けられる", correct: true, explanation: "`@NonNull String` のように、型使用箇所に付けるためのターゲットです。"),
                choice("c", "メソッドにだけ付けられる", misconception: "ElementType.METHODと混同", explanation: "メソッド宣言に限定するなら `METHOD` です。"),
                choice("d", "実行時に必ずリフレクションで見える", misconception: "TargetとRetentionを混同", explanation: "見えるかどうかは `@Retention` の指定に依存します。"),
            ],
            intent: "ElementType.TYPE_USEの意味とRetentionとの違いを確認する。",
            steps: [
                step("`@Target(ElementType.TYPE_USE)` は、アノテーションを型の使用箇所へ付けられるようにします。", [3, 4], [variable("target", "ElementType", "TYPE_USE", "annotation")]),
                step("`@NonNull String value;` では、フィールド宣言に現れる `String` という型使用へ `@NonNull` が付いています。", [7, 8], [variable("annotated type", "String", "@NonNull String", "Sample")]),
                step("ただし、実行時に見えるかは `@Retention` の問題です。`@Target` は付けられる場所を決めるだけです。", [3], [variable("rule", "String", "target != retention", "annotation")]),
            ]
        ),
        q(
            "gold-balanced-annotation-element-type-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "annotations",
            tags: ["annotation", "element type", "コンパイルエラー"],
            code: """
import java.util.*;

@interface Bad {
    List<String> value();
}
""",
            question: "このアノテーション型の定義について正しいものはどれか？",
            choices: [
                choice("a", "正常にコンパイルできる", misconception: "アノテーション要素型の制限を見落とし", explanation: "アノテーション要素には任意のジェネリック型を使えません。"),
                choice("b", "`List<String>` はアノテーション要素型として使えないためコンパイルエラー", correct: true, explanation: "要素型に使えるのはプリミティブ、String、Class、enum、annotation、およびそれらの配列などに限られます。"),
                choice("c", "`List<String>` は `@Retention(RUNTIME)` を付ければ使える", misconception: "Retentionで型制限が変わると誤解", explanation: "保持期間を変えても、要素型の制限は変わりません。"),
                choice("d", "戻り値を `ArrayList<String>` にすれば正しい", misconception: "具象クラスならよいと誤解", explanation: "コレクション型自体がアノテーション要素型として使えません。"),
            ],
            intent: "アノテーション要素に使える型の制限を確認する。",
            steps: [
                step("アノテーション型の要素は、メソッドのような形で宣言します。ただし戻り値型には強い制限があります。", [3, 4], [variable("element", "method", "value()", "Bad")]),
                step("`List<String>` は許可されたアノテーション要素型ではありません。ジェネリックなコレクション型は使えないためコンパイルエラーです。", [4], [variable("invalid type", "List<String>", "not allowed", "annotation")]),
                step("使える代表例はプリミティブ、String、Class、enum、annotation、およびそれらの配列です。Retentionではこの制限は変わりません。", [4], [variable("rule", "String", "limited element types", "annotation")]),
            ]
        ),
        q(
            "gold-balanced-localization-resourcebundle-fallback-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "localization",
            tags: ["ResourceBundle", "Locale", "fallback"],
            code: """
// messages.properties
greeting=base

// messages_ja.properties
greeting=ja

// messages_ja_JP.properties は存在しない
ResourceBundle rb = ResourceBundle.getBundle("messages", Locale.JAPAN);
System.out.println(rb.getString("greeting"));
""",
            question: "この場合、`greeting` として取得される値はどれか？",
            choices: [
                choice("a", "ja", correct: true, explanation: "`Locale.JAPAN` は ja_JP ですが、ja_JP用がなければ ja 用、その後baseへフォールバックします。"),
                choice("b", "base", misconception: "言語のみのbundleを飛ばすと誤解", explanation: "`messages_ja.properties` が存在するため、baseより先に使われます。"),
                choice("c", "MissingResourceException", misconception: "完全一致がないと失敗すると誤解", explanation: "ResourceBundleは候補Localeを順に探し、フォールバックします。"),
                choice("d", "ja_JP", misconception: "ファイル名やLocale名が値になると誤解", explanation: "取得するのはプロパティ `greeting` の値です。"),
            ],
            intent: "ResourceBundleのLocaleフォールバック順を確認する。",
            steps: [
                step("要求Localeは `Locale.JAPAN`、つまり `ja_JP` です。しかし `messages_ja_JP.properties` は存在しません。", [7, 8], [variable("requested locale", "Locale", "ja_JP", "ResourceBundle")]),
                step("ResourceBundleは候補をフォールバックして探します。`messages_ja.properties` が存在するため、そこで `greeting=ja` が見つかります。", [4, 5], [variable("selected bundle", "ResourceBundle", "messages_ja.properties", "lookup")]),
                step("したがって `rb.getString(\"greeting\")` は `ja` を返します。baseまで落ちるのは言語用も見つからない場合です。", [8, 9], [variable("output", "String", "ja", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-localization-numberformat-locale-001",
            difficulty: .standard,
            validatedByJavac: false,
            category: "localization",
            tags: ["NumberFormat", "Locale", "currency"],
            code: """
NumberFormat nf = NumberFormat.getCurrencyInstance(Locale.US);
String text = nf.format(1234.5);
""",
            question: "このコードの説明として正しいものはどれか？",
            choices: [
                choice("a", "通貨記号や桁区切りはLocale.USの規則に従う", correct: true, explanation: "`getCurrencyInstance(Locale.US)` は米国ロケールの通貨形式を使います。"),
                choice("b", "現在の端末ロケールが必ず使われる", misconception: "明示Localeを見落とし", explanation: "Locale.USを明示しているため、デフォルトロケールではありません。"),
                choice("c", "formatの戻り値はNumberである", misconception: "formatの戻り値型を誤解", explanation: "`format` は文字列を返します。"),
                choice("d", "parseしない限り例外になる", misconception: "formatとparseを混同", explanation: "formatは数値を文字列化する操作であり、このコードではparseしていません。"),
            ],
            intent: "NumberFormatのLocale指定とformatの戻り値を確認する。",
            steps: [
                step("`NumberFormat.getCurrencyInstance(Locale.US)` により、米国ロケールの通貨フォーマッタを取得します。", [1], [variable("nf", "NumberFormat", "US currency formatter", "main")]),
                step("`format(1234.5)` は数値をロケールに応じた通貨文字列へ変換します。戻り値型はStringです。", [2], [variable("text", "String", "US currency text", "main")]),
                step("明示的にLocale.USを渡しているため、端末のデフォルトロケールに依存する読み方は誤りです。", [1, 2], [variable("rule", "String", "explicit locale wins", "localization")]),
            ]
        ),
        q(
            "gold-balanced-localization-messageformat-order-001",
            difficulty: .standard,
            category: "localization",
            tags: ["MessageFormat", "format", "argument index"],
            code: """
import java.text.*;

public class Test {
    public static void main(String[] args) {
        String text = MessageFormat.format("{1}-{0}-{1}", "A", "B");
        System.out.println(text);
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "A-B-A", misconception: "引数順にそのまま並ぶと誤解", explanation: "プレースホルダの番号で参照する引数が決まります。"),
                choice("b", "B-A-B", correct: true, explanation: "`{1}` は2番目の引数B、`{0}` は1番目の引数Aなので、B-A-Bです。"),
                choice("c", "{1}-{0}-{1}", misconception: "MessageFormatが置換しないと誤解", explanation: "`format` によりプレースホルダが引数で置換されます。"),
                choice("d", "コンパイルエラー", misconception: "同じ引数番号を複数回使えないと誤解", explanation: "同じ番号のプレースホルダは複数回使えます。"),
            ],
            intent: "MessageFormatの引数番号が0始まりで、任意順・複数回参照できることを確認する。",
            steps: [
                step("MessageFormatの引数番号は0始まりです。`{0}` は `\"A\"`、`{1}` は `\"B\"` を参照します。", [5], [variable("arg0", "String", "A", "MessageFormat"), variable("arg1", "String", "B", "MessageFormat")]),
                step("パターンは `{1}-{0}-{1}` なので、2番目、1番目、2番目の順に値が入ります。", [5], [variable("text", "String", "B-A-B", "main")]),
                step("同じ `{1}` を複数回使えるため、最終的な出力は `B-A-B` です。", [6], [variable("output", "String", "B-A-B", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-classes-final-method-001",
            difficulty: .tricky,
            validatedByJavac: false,
            category: "classes",
            tags: ["final", "override", "コンパイルエラー"],
            code: """
class Parent {
    final void work() {}
}

class Child extends Parent {
    void work() {}
}
""",
            question: "このコードについて正しい説明はどれか？",
            choices: [
                choice("a", "正常にコンパイルでき、Childのworkがオーバーライドされる", misconception: "finalメソッドを上書きできると誤解", explanation: "finalメソッドはサブクラスでオーバーライドできません。"),
                choice("b", "finalメソッドをオーバーライドしようとしているためコンパイルエラー", correct: true, explanation: "`Parent.work()` はfinalなので、`Child` で同じシグネチャのインスタンスメソッドを宣言できません。"),
                choice("c", "実行時にだけエラーになる", misconception: "オーバーライド制約が実行時まで遅れると誤解", explanation: "finalメソッドのオーバーライド禁止はコンパイル時に検出されます。"),
                choice("d", "finalはフィールドにしか使えない", misconception: "finalの適用対象を誤解", explanation: "finalはクラス、メソッド、変数に使えます。"),
            ],
            intent: "finalメソッドがオーバーライドできないことを確認する。",
            steps: [
                step("`Parent` の `work()` は `final` 付きのインスタンスメソッドです。", [1, 2], [variable("Parent.work", "method", "final", "Parent")]),
                step("`Child` は `Parent` を継承し、同じシグネチャの `void work()` を宣言しています。これはオーバーライドの形です。", [5, 6], [variable("Child.work", "method", "attempted override", "Child")]),
                step("finalメソッドはオーバーライド禁止なので、このコードはコンパイルエラーです。", [2, 6], [variable("result", "String", "compile error", "compiler")]),
            ]
        ),
        q(
            "gold-balanced-classes-object-equals-001",
            difficulty: .standard,
            category: "classes",
            tags: ["Object", "equals", "StringBuilder"],
            code: """
public class Test {
    public static void main(String[] args) {
        StringBuilder a = new StringBuilder("x");
        StringBuilder b = new StringBuilder("x");
        System.out.println(a.equals(b));
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "true", misconception: "Stringと同じ内容比較だと誤解", explanation: "StringBuilderはequalsを内容比較としてオーバーライドしていません。"),
                choice("b", "false", correct: true, explanation: "2つは別インスタンスであり、StringBuilderのequalsはObject由来の参照比較です。"),
                choice("c", "コンパイルエラー", misconception: "StringBuilder同士をequalsできないと誤解", explanation: "`equals` はObjectのメソッドなので呼び出せます。"),
                choice("d", "NullPointerException", misconception: "どちらかがnullだと誤解", explanation: "どちらもnewされたオブジェクトです。"),
            ],
            intent: "Object.equalsの既定実装とStringBuilderの参照比較を確認する。",
            steps: [
                step("`a` と `b` はどちらも内容 `x` を持つStringBuilderですが、`new` により別々のオブジェクトです。", [3, 4], [variable("a", "StringBuilder", "object #1, x", "main"), variable("b", "StringBuilder", "object #2, x", "main")]),
                step("Stringとは異なり、StringBuilderは `equals` を内容比較としてオーバーライドしていません。Object由来の参照比較になります。", [5], [variable("a == b", "boolean", "false", "heap")]),
                step("参照先が異なるため `a.equals(b)` はfalseです。", [5], [variable("output", "boolean", "false", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-exception-assert-disabled-001",
            difficulty: .standard,
            category: "exception-handling",
            tags: ["assert", "AssertionError", "-ea"],
            code: """
public class Test {
    public static void main(String[] args) {
        assert false : "boom";
        System.out.println("ok");
    }
}
""",
            question: "`java Test` として通常実行した場合、出力されるのはどれか？",
            choices: [
                choice("a", "ok", correct: true, explanation: "assertは通常無効です。`-ea` を付けない実行ではassert文は評価されず、次の行へ進みます。"),
                choice("b", "boom", misconception: "assertメッセージが標準出力に出ると誤解", explanation: "有効時は `AssertionError` のメッセージになりますが、通常実行では評価されません。"),
                choice("c", "AssertionError", misconception: "assertが常に有効だと誤解", explanation: "assertはデフォルトでは無効です。`-ea` で有効化します。"),
                choice("d", "コンパイルエラー", misconception: "assert文を使えないと誤解", explanation: "assert文はJavaの構文として有効です。"),
            ],
            intent: "assertがデフォルト無効で、-eaにより有効化されることを確認する。",
            steps: [
                step("`assert false : \"boom\";` は、アサーションが有効なら `AssertionError` を発生させる文です。", [3], [variable("assert condition", "boolean", "false", "main")]),
                step("ただし通常の `java Test` 実行ではアサーションは無効です。`-ea` を付けた場合に評価されます。", [3], [variable("assertions", "boolean", "disabled", "JVM")]),
                step("assert文は評価されず、次の `System.out.println(\"ok\")` が実行されます。出力は `ok` です。", [4], [variable("output", "String", "ok", "stdout")]),
            ]
        ),
        q(
            "gold-balanced-exception-try-finally-return-001",
            difficulty: .tricky,
            category: "exception-handling",
            tags: ["try-finally", "return", "例外処理"],
            code: """
public class Test {
    static int value() {
        try {
            return 1;
        } finally {
            return 2;
        }
    }
    public static void main(String[] args) {
        System.out.println(value());
    }
}
""",
            question: "このコードを実行したとき、出力されるのはどれか？",
            choices: [
                choice("a", "1", misconception: "tryのreturnが常に優先されると誤解", explanation: "finallyのreturnが後から実行され、tryのreturnを上書きします。"),
                choice("b", "2", correct: true, explanation: "tryでreturn 1が準備されても、finallyのreturn 2が実行されるため戻り値は2です。"),
                choice("c", "3", misconception: "return値が加算されると誤解", explanation: "return値は加算されません。finallyのreturnが優先されます。"),
                choice("d", "コンパイルエラー", misconception: "tryとfinallyの両方でreturnできないと誤解", explanation: "コンパイルはできます。ただし可読性や例外握りつぶしの観点では避けるべき書き方です。"),
            ],
            intent: "finally内のreturnがtryのreturnを上書きする危険な挙動を確認する。",
            steps: [
                step("`value()` が呼ばれるとtryブロックに入り、`return 1` が実行される準備をします。", [2, 3, 4], [variable("pending return", "int", "1", "value")]),
                step("メソッドを抜ける前にfinallyブロックが必ず実行されます。ここで `return 2` が実行され、先に準備された戻り値1を上書きします。", [5, 6], [variable("final return", "int", "2", "value")]),
                step("mainでは `value()` の結果2を出力します。finallyでreturnするコードは例外も隠し得るため注意が必要です。", [10], [variable("output", "String", "2", "stdout")]),
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

extension GoldBalancedQuestionData.Spec {
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
    static let goldBalancedExpansion: [Quiz] = GoldBalancedQuestionData.specs.map(\.quiz)
}
