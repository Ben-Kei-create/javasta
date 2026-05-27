# WidgetKit セットアップ手順

`JavastaWidget/` ディレクトリのコードは用意済みです。
以下の Xcode 操作を行うと、小/中サイズのホーム画面ウィジェットが動作します。

---

## 1. Widget Extension ターゲットを追加

1. Xcode でプロジェクトを開く
2. `File → New → Target…` を選択
3. **Widget Extension** を選んで `Next`
4. 設定:
   - Product Name: `JavastaWidget`
   - Bundle Identifier: `com.fumiakiMogi777.JavastaWidget`
   - Include Configuration Intent: **OFF**（チェックしない）
   - Include Live Activity: **OFF**
5. `Finish` → 「Activate」を選択

---

## 2. 自動生成ファイルを差し替え

Xcode が生成したデフォルトの Swift ファイルを削除し、
リポジトリにある以下のファイルをターゲットに追加します。

```
JavastaWidget/JavastaWidget.swift
JavastaWidget/JavastaWidgetBundle.swift
```

ファイルをドラッグ＆ドロップ or `Add Files to "Javasta"…` で、
**Target Membership を `JavastaWidget` にチェック**。

> `JavastaApp.swift` や `StudyModels.swift` など本体コードへの依存は
> ウィジェットからは不要です（WidgetKit は独立プロセスで動くため、
> 専用の `WidgetData.load()` で UserDefaults から直接読みます）。

---

## 3. App Group を設定

**本体アプリ・ウィジェット両方のターゲット**に App Group を追加します。

1. プロジェクトナビゲータでターゲット `Javasta` を選択
2. `Signing & Capabilities` → `+ Capability` → **App Groups**
3. `+` を押して `group.com.fumiakiMogi777.Javasta` を追加
4. 同様にターゲット `JavastaWidget` にも同じ App Group を追加

---

## 4. ProgressStore の動作確認

`ProgressStore.swift` は `UserDefaults(suiteName: "group.com.fumiakiMogi777.Javasta")` を
デフォルトとして使うよう変更済みです。

App Group の設定が完了すると：
- 本体アプリが書き込んだ進捗データをウィジェットが自動で読む
- ウィジェットは 30 分ごとにリフレッシュ

---

## 5. テスト方法

1. シミュレータでアプリをビルド・実行
2. ホーム画面を長押し → `+` ボタン → 「Javasta」を検索
3. Small / Medium ウィジェットを追加して確認

---

## ファイル構成

```
JavastaWidget/
├── JavastaWidget.swift         # Small・Medium ウィジェット定義
└── JavastaWidgetBundle.swift   # @main WidgetBundle
```

| ウィジェット | サイズ | 表示内容 |
|---|---|---|
| JavastaSmallWidget | systemSmall | 連続日数 + 今日の進捗リング |
| JavastaMediumWidget | systemMedium | 今日の進捗バー + 連続日数 + 正答率 |
