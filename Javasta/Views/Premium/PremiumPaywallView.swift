import StoreKit
import SwiftUI

struct PremiumPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var purchase = PurchaseManager.shared

    private let features: [(icon: String, color: Color, title: String, body: String)] = [
        ("graduationcap.fill",  .orange,        "模擬試験（Silver）",   "本番形式・時間制限・採点付き"),
        ("star.fill",           .yellow,        "Gold 問題すべて",       "Java Gold 全問・解説・統計"),
        ("chart.bar.fill",      Color(red: 0.4, green: 0.8, blue: 0.4), "Gold 統計",    "正答率・弱点分野を可視化"),
        ("icloud.fill",         .cyan,          "クラウド同期",          "複数デバイス間で進捗を共有"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.jbBackground.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.lg) {
                        heroSection
                        featuresSection
                        purchaseSection
                        footerNote
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, Spacing.xxl)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.jbSubtext)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
        .alert("購入エラー", isPresented: .constant(purchase.purchaseError != nil)) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchase.purchaseError ?? "")
        }
        .onChange(of: purchase.isPremium) { _, isPremium in
            if isPremium { dismiss() }
        }
    }

    // MARK: Hero

    private var heroSection: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.jbAccent.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: "crown.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.jbAccent)
            }
            .padding(.top, Spacing.md)

            Text("Javasta プレミアム")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.jbText)

            Text("Gold・模擬試験をすべて解放")
                .font(.system(size: 15))
                .foregroundStyle(Color.jbSubtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Features

    private var featuresSection: some View {
        VStack(spacing: Spacing.xs) {
            ForEach(features, id: \.title) { f in
                HStack(spacing: Spacing.md) {
                    Image(systemName: f.icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(f.color)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(f.color.opacity(0.12)))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(f.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.jbText)
                        Text(f.body)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.jbSubtext)
                    }

                    Spacer()

                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.jbSuccess)
                }
                .padding(Spacing.sm)
                .jbCard()
            }
        }
    }

    // MARK: Purchase

    private var purchaseSection: some View {
        VStack(spacing: Spacing.sm) {
            // Price display
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(purchase.product?.displayPrice ?? "¥900")
                    .font(.system(size: 36, weight: .heavy).monospacedDigit())
                    .foregroundStyle(Color.jbAccent)
                Text("買い切り")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.jbSubtext)
            }

            // Purchase button
            Button(action: {
                Task { await purchase.purchase() }
            }) {
                Group {
                    if purchase.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("購入する")
                            .font(.system(size: 17, weight: .bold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .fill(Color.jbAccent)
                )
            }
            .buttonStyle(.plain)
            .disabled(purchase.isLoading)

            // Restore button
            Button(action: {
                Task { await purchase.restorePurchases() }
            }) {
                Text("購入を復元する")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.jbSubtext)
                    .frame(height: 40)
            }
            .buttonStyle(.plain)
            .disabled(purchase.isLoading)
        }
        .padding(.top, Spacing.xs)
    }

    // MARK: Footer

    private var footerNote: some View {
        Text("購入は一度だけ。買い切り価格で永久にご利用いただけます。\nApp Store のアカウント規約が適用されます。")
            .font(.system(size: 11))
            .foregroundStyle(Color.jbSubtext.opacity(0.7))
            .multilineTextAlignment(.center)
            .lineSpacing(3)
    }
}
