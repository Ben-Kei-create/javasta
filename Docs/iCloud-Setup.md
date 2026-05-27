# iCloud Key-Value Storage セットアップ手順

Javasta では `CloudSyncManager` が `NSUbiquitousKeyValueStore` を使って
学習進捗をデバイス間で同期します。以下の手順で Xcode の Capability を設定してください。

---

## 1. iCloud Capability を追加する

1. Xcode でプロジェクトファイル（`Javasta.xcodeproj`）を開く
2. **TARGETS → Javasta** を選択
3. **Signing & Capabilities** タブを開く
4. 左上の **＋ Capability** ボタンをクリック
5. 検索欄に `iCloud` と入力し、**iCloud** を選択してダブルクリック

## 2. Key-Value Storage を有効にする

Capability が追加されたら、**iCloud** セクション内にある

- [x] **Key-Value Storage**

のチェックボックスをオンにします。

> **注意**: "CloudKit" は今回使用しません。Key-Value Storage のみ有効にしてください。

## 3. App Group の確認

WidgetKit との共有 UserDefaults に使用している App Group が
iCloud Capability と同じ Apple Developer チームに紐付いていることを確認してください。

詳細は [WidgetKit-Setup.md](WidgetKit-Setup.md) を参照してください。

## 4. Entitlements の確認

上記手順を完了すると、`Javasta.entitlements` に以下のキーが自動追加されます。

```xml
<key>com.apple.developer.ubiquity-kvstore-identifier</key>
<string>$(TeamIdentifierPrefix)$(CFBundleIdentifier)</string>
```

これで `NSUbiquitousKeyValueStore.default` がアプリ内で動作します。

## 5. シミュレーターでの動作確認

- シミュレーターでは iCloud KVS は動作しません（実機のみ）。
- 実機 2 台（同一 Apple ID でサインイン）でテストしてください。
- `NSUbiquitousKeyValueStore.default.synchronize()` の戻り値が `false` の場合、
  Capability が正しく設定されていないことを示します。

## 6. KVS の制限事項

| 項目 | 制限 |
|---|---|
| 1 キーあたりの値サイズ | 1 MB |
| KVS 全体のストレージ | 1 MB |
| キー数 | 1024 |

Javasta では `answerHistory` を KVS 書き込み時に最新 500 件に制限し、
マージ後は最新 2000 件を保持することで制限内に収まるよう設計されています。
