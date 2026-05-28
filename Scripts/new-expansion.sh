#!/usr/bin/env bash
# ============================================================
# new-expansion.sh — 問題バッチ追加テンプレート生成スクリプト
#
# 使い方:
#   ./Scripts/new-expansion.sh MyFeature silver
#   ./Scripts/new-expansion.sh StreamAdvanced gold
#
# 生成されるファイル:
#   Javasta/Models/Quiz+MyFeatureExpansion.swift
#   Javasta/Models/Explanation+MyFeatureExpansion.swift
#
# 生成後の作業（スクリプトが案内します）:
#   1. Quiz ファイルに問題を書く
#   2. Explanation ファイルに解説を書く
#   3. Quiz+Samples.swift に1行追加
#   4. Explanation+Samples.swift に1行追加
# ============================================================

set -euo pipefail

# ── 引数チェック ─────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
  echo "使い方: $0 <ExpansionName> [silver|gold|both]"
  echo "例:     $0 StreamAdvanced gold"
  exit 1
fi

NAME="$1"
LEVEL="${2:-both}"
MODELS_DIR="$(dirname "$0")/../Javasta/Models"
QUIZ_FILE="${MODELS_DIR}/Quiz+${NAME}Expansion.swift"
EXPL_FILE="${MODELS_DIR}/Explanation+${NAME}Expansion.swift"
PROPERTY_NAME="$(tr '[:upper:]' '[:lower:]' <<< "${NAME:0:1}")${NAME:1}Expansion"

# ── 既存ファイルチェック ─────────────────────────────────────
if [[ -f "$QUIZ_FILE" ]]; then
  echo "❌ すでに存在します: $QUIZ_FILE"
  exit 1
fi

# ── Quiz 展開ファイル生成 ─────────────────────────────────────
cat > "$QUIZ_FILE" << SWIFT
import Foundation

extension QuizExpansion {
    // MARK: - ${NAME} 問題セット
    // レベル: ${LEVEL}
    // 追加日: $(date '+%Y-%m-%d')
    //
    // 登録手順:
    //   Quiz+Samples.swift の samples 配列末尾に
    //   + QuizExpansion.${PROPERTY_NAME}
    //   を追加する。

    static let ${PROPERTY_NAME}: [Quiz] = [

        // ── 問題1 ────────────────────────────────────────────────
        Quiz(
            id: "${NAME,,}-001",                // 小文字スネークケース, ユニークなID
            level: .${LEVEL == "both" && echo "silver" || echo "$LEVEL"},
            examVersion: .se17,
            question: "問題文をここに書く",
            code: """
class Example {
    public static void main(String[] args) {
        // コードをここに
    }
}
""",
            choices: [
                Quiz.Choice(id: "a", text: "選択肢A", correct: false, explanation: "Aが不正解の理由"),
                Quiz.Choice(id: "b", text: "選択肢B", correct: true,  explanation: "Bが正解の理由"),
                Quiz.Choice(id: "c", text: "選択肢C", correct: false, explanation: "Cが不正解の理由"),
                Quiz.Choice(id: "d", text: "選択肢D", correct: false, explanation: "Dが不正解の理由"),
            ],
            tags: ["タグ1", "タグ2"],
            explanationRef: "explain-${NAME,,}-001",
            category: "カテゴリ名（任意）",
            difficulty: .medium
        ),

        // 問題2, 3, ... を同じ形式で追加

    ]
}
SWIFT

# ── Explanation 展開ファイル生成 ──────────────────────────────
cat > "$EXPL_FILE" << SWIFT
import Foundation

extension Explanation {
    // MARK: - ${NAME} 解説セット
    // 対応問題: Quiz+${NAME}Expansion.swift
    // 追加日: $(date '+%Y-%m-%d')
    //
    // 登録手順:
    //   Explanation+Samples.swift の authoredSamples クロージャ末尾に
    //   .merging(${PROPERTY_NAME}AuthoredSamples, uniquingKeysWith: { _, new in new })
    //   を追加する。

    static let ${PROPERTY_NAME}AuthoredSamples: [String: Explanation] = Dictionary(
        uniqueKeysWithValues: [
            ${NAME,,}001Explanation,
            // ${NAME,,}002Explanation,
        ].map { (\$0.id, \$0) }
    )

    // ── 問題1 の解説 ──────────────────────────────────────────
    static let ${NAME,,}001Explanation = Explanation(
        id: "explain-${NAME,,}-001",
        initialCode: """
class Example {
    public static void main(String[] args) {
        // 問題と同じコード
    }
}
""",
        steps: [
            step(
                "最初の実行ステップの説明",
                highlight: [1],
                vars: []
            ),
            step(
                "次のステップ",
                highlight: [3],
                vars: [variable("変数名", "型", "値", "スコープ")]
            ),
            step(
                "出力ステップ: 〇〇 が表示される",
                highlight: [4],
                vars: []
            ),
        ]
    )
}
SWIFT

echo ""
echo "✅ ファイルを生成しました:"
echo "   📝 $QUIZ_FILE"
echo "   📖 $EXPL_FILE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "次にやること（2ファイルを編集後）:"
echo ""
echo "  1. Quiz+Samples.swift の samples 配列に追加:"
echo "       + QuizExpansion.${PROPERTY_NAME}"
echo ""
echo "  2. Explanation+Samples.swift の authoredSamples 末尾に追加:"
echo "       .merging(${PROPERTY_NAME}AuthoredSamples, uniquingKeysWith: { _, new in new })"
echo ""
echo "  3. ビルドして確認:"
echo "       ./Scripts/check-quality.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
