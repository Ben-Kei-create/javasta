import StoreKit
import SwiftUI

/// プレミアム購入ペイウォール画面。
/// Gold レベルや Silver 模擬試験をタップしたときにシートとして表示する。
struct PremiumPaywallView: View {
    @State private var store = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // ヘッダー
                    headerSection
                        .padding(.top, Spacing.xl)

                    // 特典リスト
                    benefitsSection
                        .padding(.top, Spacing.lg)

                    // 比較表
                    comparisonTable
                        .padding(.top, Spacing.lg)
                        .padding(.horizontal, Spacing.md)

                    // 購入ボタン
                    purchaseSection
                        .padding(.top, Spacing.lg)
                        .padding(.horizontal, Spacing.md)

                    // 小文字注記
                    legalNote
                        .padding(.top, Spacing.md)
                        .padding(.bottom, Spacing.xxl)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("閉じる") { dismiss() }
                    .foregroundStyle(Color.jbSubtext)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.jbAccent.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "bolt.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.jbAccent)
            }

            Text("プレミアムプラン")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.jbText)

            Text("買い切り · 一度の支払いで永続利用")
                .font(.system(size: 14))
                .foregroundStyle(Color.jbSubtext)

            // 価格バッジ
            if let product = store.product {
                Text(product.displayPrice)
                    .font(.system(size: 36, weight: .black).monospacedDigit())
                    .foregroundStyle(Color.jbAccent)
            } else {
                Text("¥980")
                    .font(.system(size: 36, weight: .black).monospacedDigit())
                    .foregroundStyle(Color.jbAccent)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, Spacing.lg)
    }

    // MARK: - Benefits

    private var benefitsSection: some View {
        VStack(spacing: Spacing.sm) {
            benefitRow(
                icon: "briefcase.fill",
                tint: Color.jbAccent,
                title: "Gold レベル 全解放",
                detail: "ラムダ・Stream API・並行処理・モジュールなど\nGold 試験対策問題 \(goldCount)問 + レッスン全件"
            )
            benefitRow(
                icon: "graduationcap.fill",
                tint: Color.jbSuccess,
                title: "Silver 模擬試験",
                detail: "本番形式で時間計測・合否判定。\nSilver 合格ラインを確実に超えるための仕上げ"
            )
            benefitRow(
                icon: "chart.bar.fill",
                tint: Color.jbAccent,
                title: "Gold 統計・弱点分析",
                detail: "カテゴリ別正答率・模試スコア推移をグラフで確認"
            )
            benefitRow(
                icon: "arrow.clockwise",
                tint: Color.jbSubtext,
                title: "買い切り・永続利用",
                detail: "サブスクなし。一度購入すれば\nアップデートも含めてずっと使える"
            )
        }
        .padding(.horizontal, Spacing.md)
    }

    private func benefitRow(icon: String, tint: Color, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: Radius.sm).fill(tint.opacity(0.12)))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.jbText)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.jbSubtext)
                    .lineSpacing(3)
            }

            Spacer()
        }
        .padding(Spacing.md)
        .jbCard()
    }

    // MARK: - Comparison table

    private var comparisonTable: some View {
        VStack(spacing: 0) {
            // ヘッダー行
            HStack {
                Text("コンテンツ")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.jbSubtext)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("無料")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.jbSubtext)
                    .frame(width: 52, alignment: .center)
                Text("プレミアム")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.jbAccent)
                    .frame(width: 76, alignment: .center)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.jbSurface)
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: Radius.md, topTrailingRadius: Radius.md
            ))

            Divider().background(Color.jbBorder)

            let rows: [(String, Bool, Bool)] = [
                ("Silver 問題 全件", true, true),
                ("Silver レッスン・用語集", true, true),
                ("Silver 模擬試験", false, true),
                ("Gold 問題 全件", false, true),
                ("Gold レッスン 全件", false, true),
                ("Gold 統計・分析", false, true),
            ]

            ForEach(Array(rows.enumerated()), id: \.offset) { i, row in
                HStack {
                    Text(row.0)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.jbText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    checkCell(row.1, free: true)
                        .frame(width: 52)
                    checkCell(row.2, free: false)
                        .frame(width: 76)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 10)
                .background(i % 2 == 0 ? Color.jbCard : Color.jbSurface.opacity(0.5))

                if i < rows.count - 1 {
                    Divider().background(Color.jbBorder.opacity(0.5))
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.jbBorder, lineWidth: 1))
    }

    private func checkCell(_ value: Bool, free: Bool) -> some View {
        Group {
            if value {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(free ? Color.jbSubtext : Color.jbSuccess)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.jbSubtext.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Purchase section

    private var purchaseSection: some View {
        VStack(spacing: Spacing.sm) {
            // エラー表示
            if let error = store.purchaseError {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.jbError)
                    .multilineTextAlignment(.center)
            }

            // 購入ボタン
            Button {
                Task { await store.purchase() }
            } label: {
                ZStack {
                    if store.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 15, weight: .bold))
                            Text(store.product.map { "プレミアムを \($0.displayPrice) で購入" }
                                 ?? "プレミアムを ¥980 で購入")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .fill(Color.jbAccent)
                )
            }
            .buttonStyle(JBScaledButtonStyle(scaleAmount: 0.97))
            .disabled(store.isLoading)

            // 復元ボタン
            Button {
                Task { await store.restorePurchases() }
            } label: {
                Text("購入を復元する")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.jbSubtext)
            }
            .buttonStyle(.plain)
            .disabled(store.isLoading)
        }
    }

    // MARK: - Legal

    private var legalNote: some View {
        Text("一度の買い切り購入です。サブスクリプションではありません。\nApp Store のご利用規約が適用されます。")
            .font(.system(size: 11))
            .foregroundStyle(Color.jbSubtext.opacity(0.6))
            .multilineTextAlignment(.center)
            .padding(.horizontal, Spacing.lg)
    }

    // MARK: - Helpers

    private var goldCount: Int {
        QuestionBank.quizzes(version: .se17, level: .gold).count
    }
}

// MARK: - Lock overlay helper

/// プレミアム限定コンテンツに重ねるロックオーバーレイ
struct PremiumLockOverlay: View {
    let label: String
    var tint: Color = Color.jbAccent

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "lock.fill")
                .font(.system(size: 11, weight: .semibold))
            Text(label)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(tint.opacity(0.12))
                .overlay(Capsule().stroke(tint.opacity(0.4), lineWidth: 1))
        )
    }
}
