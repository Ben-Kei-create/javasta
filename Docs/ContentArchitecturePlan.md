# Javasta Content Architecture Plan

教材品質を落とさずに問題数を増やすための保守方針。

## 現状の課題

- `Quiz+MoreExpansion.swift` と `Explanation+Samples.swift` が大きく、レビュー時に差分の意図を追いにくい。
- 問題、選択肢、解説、試験範囲IDの4点が同時に正しく入っているかを人力で確認しにくい。
- 試験バージョン別の追加では、SE11 / SE17の互換性や範囲の穴を見落としやすい。

## 分割ルール

- 新規の大量問題は、試験区分・級・範囲・目的が分かるExpansionファイルへ追加する。
- `Quiz+Samples.swift` と `Explanation+Samples.swift` は、既存サンプルと小規模な共通解説の置き場として扱う。
- SE11互換問題のように既存問題を再利用する場合は、元問題リスト、変換ロジック、解説リターゲットを同じ責務のファイルへまとめる。
- 1ファイル2,000行を超える新規追加が見込まれる場合は、追加前にファイルを分ける。

## 追加時の必須チェック

- `ContentQualityTests` を通す。
- 販売準備画面で、対象のSE / 級の出題範囲カバレッジがすべて埋まっていることを確認する。
- 模試専用問題を追加した場合は、模試セッションが重複ID・重複類題グループを含まないことを確認する。
- 問題報告が来た問題は、同じ `variantGroupId` の類題にも同じ誤りがないか確認する。

## 次の構造改善候補

1. `Quiz+Samples.swift` から古いSilver基礎問題を `Quiz+SilverFoundationExpansion.swift` へ移す。
2. `Explanation+Samples.swift` から対応する基礎解説を `Explanation+SilverFoundationExpansion.swift` へ移す。
3. 問題と解説のペアを試験範囲ごとに棚卸しし、`examObjectiveId` 未設定の既存問題を段階的に埋める。
4. 将来的に、教材データをJSONまたはYAMLで管理し、Swift定義を生成する方式を検討する。
