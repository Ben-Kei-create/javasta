# Javasta Content Generation Guide

このアプリの問題・学習コンテンツを大量生成するときの仕様メモ。

## 追加先ファイル

- 問題: `Javasta/Models/Quiz+Samples.swift`
- 問題の実行トレース解説: `Javasta/Models/Explanation+Samples.swift`
- 学習レッスン: `Javasta/Models/Lesson+Samples.swift`
- カテゴリ追加: `Javasta/Models/AppModels.swift`
- 試験範囲マッピング追加: `Javasta/Models/StudyModels.swift`
- 用語リンク追加: `Javasta/Models/Glossary+Samples.swift`

## 問題データの形式

`Quiz+Samples.swift` に `static let` として追加し、必ず `Quiz.samples` の配列にも入れる。

```swift
static let silverOverload003 = Quiz(
    id: "silver-overload-003",
    level: .silver,
    category: "overload-resolution",
    tags: ["オーバーロード", "型昇格"],
    code: """
public class Test {
    static void call(long x) { System.out.println("long"); }
    static void call(Integer x) { System.out.println("Integer"); }
    public static void main(String[] args) {
        call(10);
    }
}
""",
    question: "このコードを実行したとき、出力されるのはどれか？",
    choices: [
        Choice(id: "a", text: "long",
               correct: true, misconception: nil,
               explanation: "intリテラル10は、ボクシングより先にlongへ型昇格されます。"),
        Choice(id: "b", text: "Integer",
               correct: false, misconception: "ボクシングが型昇格より優先されると誤解",
               explanation: "オーバーロード解決では型昇格がボクシングより優先されます。"),
        Choice(id: "c", text: "コンパイルエラー",
               correct: false, misconception: "候補が複数あると必ず曖昧になると誤解",
               explanation: "優先順位によりcall(long)が明確に選ばれます。"),
        Choice(id: "d", text: "実行時エラー",
               correct: false, misconception: nil,
               explanation: "オーバーロード解決はコンパイル時に行われます。"),
    ],
    explanationRef: "explain-silver-overload-003",
    designIntent: "型昇格とボクシングの優先順位を確認する問題。"
)
```

## 問題生成ルール

- `id` は一意にする。形式は `silver-topic-001` / `gold-topic-001`。
- `level` は `.silver` または `.gold`。
- Java Bronzeはアプリ内の独立レベルとしては作らない。Bronze相当の基礎は、Silverの前提レッスン・用語解説・選択肢解説に混ぜる。
- `category` は `QuizCategory.rawValue` を使う。新カテゴリが必要なら `AppModels.swift` に追加。
- `choices` は原則4択。正解は必ず1つだけ。
- 各選択肢に `explanation` を入れる。不正解にはできるだけ `misconception` を入れる。
- `tags` は2から5個。弱点分析・分野選択に使う。
- `code` は原則 `public class Test` と `main` を含める。
- 出力問題は、OS差・Locale差・時刻差が出ないコードにする。
- `Path` の区切り文字など環境差が出るものは、`getNameCount()` のように安定した値で問う。
- ランダム、現在日時、スレッドの実行順など、結果が不定になる問題は避ける。
- コンパイルエラー問題を作る場合は、どの行・なぜエラーかを `explanation` に明記する。

## 複数ファイル問題

複数ファイルをまたぐ問題は、`code` に主ファイル（通常 `Test.java`）を入れ、`codeTabs` に全ファイルを並べる。UIではタブで切り替えられる。

```swift
static let silverMultiFileOverride001 = Quiz(
    id: "silver-multifile-override-001",
    level: .silver,
    category: "inheritance",
    tags: ["複数ファイル", "継承", "オーバーライド"],
    code: """
public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        System.out.println(p.name());
    }
}
""",
    codeTabs: [
        Quiz.CodeFile(filename: "Parent.java", code: """
class Parent {
    String name() { return "Parent"; }
}
"""),
        Quiz.CodeFile(filename: "Child.java", code: """
class Child extends Parent {
    @Override
    String name() { return "Child"; }
}
"""),
        Quiz.CodeFile(filename: "Test.java", code: """
public class Test {
    public static void main(String[] args) {
        Parent p = new Child();
        System.out.println(p.name());
    }
}
"""),
    ],
    question: "3つのファイルを同じパッケージでコンパイルして実行したとき、出力されるのはどれか？",
    choices: [
        Choice(id: "a", text: "Parent", correct: false, misconception: "参照型で呼び出し先が固定されると誤解", explanation: "インスタンスメソッドは動的束縛されます。"),
        Choice(id: "b", text: "Child", correct: true, misconception: nil, explanation: "実体はChildなのでChildのname()が呼ばれます。"),
        Choice(id: "c", text: "コンパイルエラー", correct: false, misconception: "package-privateクラスを別ファイルから参照できないと誤解", explanation: "同じパッケージなら参照できます。"),
        Choice(id: "d", text: "ClassCastException", correct: false, misconception: nil, explanation: "安全なアップキャストなので例外は出ません。"),
    ],
    explanationRef: "explain-silver-multifile-override-001",
    designIntent: "複数ファイル構成と動的束縛を同時に確認する。"
)
```

## 学習レッスンの形式

`Lesson+Samples.swift` に追加する。短編教材なら `quickLesson(...)` へ1件追加するだけでよい。

```swift
quickLesson(
    id: "lesson-silver-primitive-widening",
    level: .silver,
    category: .dataTypes,
    title: "プリミティブの型昇格",
    summary: "byte/short/char/int/long/float/double の昇格ルール",
    estimatedMinutes: 5,
    focus: "小さい整数型は演算時にintへ昇格します。",
    examTip: "longからintのような縮小変換は明示キャストが必要です。",
    code: """
byte b = 1;
int x = b + 2;
""",
    relatedQuizIds: ["silver-overload-002"]
)
```

深掘り教材にしたい場合は、既存の `overloadResolution` のように `Lesson(...)` を直接作る。

## 実行トレース解説

`explanationRef` が `Quiz.samples` 内の問題に紐づいていれば、詳細解説が未登録でも汎用トレースが表示される。

より良い体験にしたい重要問題は、`Explanation+Samples.swift` に専用の `Explanation` を追加し、`sample(for:)` の `switch` にcaseを追加する。

## Geminiなどへの依頼プロンプト例

```text
Java SE 17 Silver/Gold試験対策アプリ用の問題をSwiftコード形式で生成してください。

条件:
- 出力は Quiz(...) のSwiftコードのみ
- levelは .silver または .gold
- categoryは次のいずれか: java-basics, classes, overload-resolution, exception-handling, collections, generics, lambda-streams, inheritance, control-flow, data-types, string, optional-api, module-system, concurrency, io, jdbc, localization
- 4択で正解は1つだけ
- 各choiceにexplanationを入れる
- 不正解choiceには可能ならmisconceptionを入れる
- codeはpublic class Testとmainを含める
- 実行結果がOS/Locale/現在日時/スレッド順に依存する問題は作らない
- explanationRefは explain-{id} にする
- designIntentに、この問題で見抜かせたい知識を書く
- Bronze相当の前提知識は、問題の主題ではなく、解説・misconception・関連レッスン案に自然に含める
- 複数ファイル問題を作る場合は、codeにTest.java、codeTabsに全ファイルを入れる
```

## 大量追加時の作業順

1. Gemini等で `Quiz(...)` を生成する。
2. `Quiz+Samples.swift` に `static let` として貼る。
3. `Quiz.samples` 配列に追加する。
4. 必要なら `Lesson+Samples.swift` の `quickLessons` に対応レッスンを追加する。
5. 新カテゴリが必要なら `AppModels.swift` の `QuizCategory` に追加する。
6. Xcodeまたは `xcodebuild` でビルドする。
7. 実機で「すべて見る」「分野を解く」「選択を解く」「模擬試験」を確認する。
