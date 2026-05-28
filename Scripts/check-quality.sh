#!/usr/bin/env bash
# ============================================================
# check-quality.sh — コンテンツ品質チェック（ビルド不要）
#
# 使い方:
#   ./Scripts/check-quality.sh
#
# 出力:
#   - 問題数（Silver/Gold別）
#   - ID 重複チェック
#   - explanationRef 参照整合性
#   - 未登録の展開ファイル検出
# ============================================================

set -euo pipefail

MODELS="$(dirname "$0")/../Javasta/Models"
SERVICES="$(dirname "$0")/../Javasta/Services"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Javasta コンテンツ品質チェック"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── 問題ファイル数 ────────────────────────────────────────────
QUIZ_FILES=$(find "$MODELS" -name "Quiz+*Expansion.swift" | wc -l | tr -d ' ')
EXPL_FILES=$(find "$MODELS" -name "Explanation+*Expansion.swift" | wc -l | tr -d ' ')
echo ""
echo "📁 問題展開ファイル数:     ${QUIZ_FILES} ファイル"
echo "📁 解説展開ファイル数:     ${EXPL_FILES} ファイル"

# ── 問題 ID 総数 ──────────────────────────────────────────────
TOTAL_QUIZ_IDS=$(grep -rh 'id: "' "$MODELS"/Quiz+*.swift 2>/dev/null | grep -v '//' | wc -l | tr -d ' ')
echo ""
echo "📝 問題 ID 総定義数:       ${TOTAL_QUIZ_IDS} 件（重複含む可能性あり）"

# ── Silver / Gold 内訳 ───────────────────────────────────────
SILVER_COUNT=$(grep -rh 'level: \.silver' "$MODELS"/Quiz+*.swift 2>/dev/null | grep -v '//' | wc -l | tr -d ' ')
GOLD_COUNT=$(grep -rh 'level: \.gold' "$MODELS"/Quiz+*.swift 2>/dev/null | grep -v '//' | wc -l | tr -d ' ')
echo "   Silver: ${SILVER_COUNT} 件"
echo "   Gold:   ${GOLD_COUNT} 件"

# ── Quiz+Samples.swift への登録チェック ──────────────────────
SAMPLES_FILE="$MODELS/Quiz+Samples.swift"
echo ""
echo "🔗 Quiz+Samples.swift 登録状況:"
REGISTERED=0
UNREGISTERED=()
for f in "$MODELS"/Quiz+*Expansion.swift; do
  basename_f=$(basename "$f")
  # ファイル名から展開名を取得: Quiz+FooExpansion.swift → Foo
  expansion_name="${basename_f#Quiz+}"
  expansion_name="${expansion_name%Expansion.swift}"
  # camelCase に変換（先頭小文字）
  prop_lower="$(tr '[:upper:]' '[:lower:]' <<< "${expansion_name:0:1}")${expansion_name:1}Expansion"
  if grep -q "QuizExpansion\.${prop_lower}" "$SAMPLES_FILE" 2>/dev/null; then
    REGISTERED=$((REGISTERED+1))
  else
    UNREGISTERED+=("$prop_lower (from $basename_f)")
  fi
done
echo "   登録済み:      ${REGISTERED} / $(find "$MODELS" -name "Quiz+*Expansion.swift" | wc -l | tr -d ' ') ファイル"
if [[ ${#UNREGISTERED[@]} -gt 0 ]]; then
  echo "   ⚠️  未登録:"
  for item in "${UNREGISTERED[@]}"; do
    echo "      - QuizExpansion.$item"
  done
fi

# ── Explanation+Samples.swift 登録チェック ───────────────────
EXPL_SAMPLES="$MODELS/Explanation+Samples.swift"
echo ""
echo "🔗 Explanation+Samples.swift 登録状況:"
E_REGISTERED=0
E_UNREGISTERED=()
for f in "$MODELS"/Explanation+*Expansion.swift; do
  basename_f=$(basename "$f")
  expansion_name="${basename_f#Explanation+}"
  expansion_name="${expansion_name%Expansion.swift}"
  prop_lower="$(tr '[:upper:]' '[:lower:]' <<< "${expansion_name:0:1}")${expansion_name:1}AuthoredSamples"
  if grep -q "${prop_lower}" "$EXPL_SAMPLES" 2>/dev/null; then
    E_REGISTERED=$((E_REGISTERED+1))
  else
    E_UNREGISTERED+=("$prop_lower (from $basename_f)")
  fi
done
echo "   登録済み:      ${E_REGISTERED} / $(find "$MODELS" -name "Explanation+*Expansion.swift" | wc -l | tr -d ' ') ファイル"
if [[ ${#E_UNREGISTERED[@]} -gt 0 ]]; then
  echo "   ⚠️  未登録:"
  for item in "${E_UNREGISTERED[@]}"; do
    echo "      - $item"
  done
fi

# ── ID 重複チェック ──────────────────────────────────────────
echo ""
echo "🔍 ID 重複チェック:"
DUPES=$(grep -rh 'id: "' "$MODELS"/Quiz+*.swift 2>/dev/null | grep -v '//' \
  | sed 's/.*id: "\([^"]*\)".*/\1/' \
  | sort | uniq -d)
if [[ -z "$DUPES" ]]; then
  echo "   ✅ 重複なし"
else
  echo "   ❌ 重複 ID 発見:"
  echo "$DUPES" | while read -r line; do echo "      - $line"; done
fi

# ── explanationRef → Explanation 存在確認 ───────────────────
echo ""
echo "🔗 explanationRef 整合性:"
REFS=$(grep -rh 'explanationRef: "' "$MODELS"/Quiz+*.swift 2>/dev/null | grep -v '//' \
  | sed 's/.*explanationRef: "\([^"]*\)".*/\1/' | sort -u)
MISSING=0
while IFS= read -r ref; do
  if ! grep -qr "\"${ref}\"" "$MODELS"/Explanation+*.swift 2>/dev/null; then
    if [[ $MISSING -eq 0 ]]; then echo "   ⚠️  Explanation が見つからない ref:"; fi
    echo "      - $ref"
    MISSING=$((MISSING+1))
  fi
done <<< "$REFS"
if [[ $MISSING -eq 0 ]]; then
  echo "   ✅ 全 ref に Explanation が存在"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " チェック完了"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
