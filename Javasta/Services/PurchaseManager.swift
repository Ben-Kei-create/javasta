import StoreKit
import Observation

/// StoreKit 2 ベースの課金マネージャー。
/// - productID: App Store Connect で設定するプロダクト ID
/// - isPremium: 購入済みかどうか（@MainActor Observable）
///
/// 解放されるコンテンツ:
///   - Gold レベル（問題・レッスン・統計）すべて
///   - Silver 模擬試験
@MainActor @Observable
final class PurchaseManager {
    static let shared = PurchaseManager()

    /// App Store Connect で設定するプロダクト ID
    nonisolated static let productID = "com.fumiakiMogi777.Javasta.premium"

    private(set) var isPremium: Bool = false
    private(set) var product: Product? = nil
    private(set) var isLoading: Bool = false
    private(set) var purchaseError: String? = nil

    private init() {}

#if DEBUG
    private init(isPremium: Bool) { self.isPremium = isPremium }
#endif

    // MARK: - Accessors

    /// Gold レベルへのアクセス可否
    func canAccess(level: JavaLevel) -> Bool {
        level == .silver || isPremium
    }

    /// 模擬試験へのアクセス可否（Silver/Gold 共に要課金）
    var canAccessMockExam: Bool { isPremium }

    // MARK: - Lifecycle

    /// アプリ起動時に呼ぶ。エンタイトルメント確認 + プロダクト取得。
    func loadOnLaunch() async {
        await checkEntitlements()
        await fetchProduct()
        // バックグラウンドでトランザクション更新を監視
        listenForTransactions()
    }

    // MARK: - Purchase

    func purchase() async {
        guard let product else {
            purchaseError = "商品情報を取得できません。ネットワーク接続を確認してから再試行してください。"
            return
        }
        isLoading = true
        purchaseError = nil
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                isPremium = true
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                purchaseError = "購入が保留中です。承認後に反映されます。"
            @unknown default:
                break
            }
        } catch {
            purchaseError = "購入できませんでした: \(error.localizedDescription)"
        }
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await AppStore.sync()
            await checkEntitlements()
        } catch {
            purchaseError = "復元に失敗しました: \(error.localizedDescription)"
        }
    }

    // MARK: - Internal

    private func fetchProduct() async {
        guard product == nil else { return }
        do {
            let products = try await Product.products(for: [Self.productID])
            product = products.first
        } catch {
            // ネットワーク不可やシミュレータでは失敗することがある
        }
    }

    private func checkEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result, tx.productID == Self.productID {
                isPremium = true
                return
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw StoreError.failedVerification
        case .verified(let value): return value
        }
    }

    private func listenForTransactions() {
        let productID = Self.productID  // nonisolated: safe to capture in detached task
        Task.detached(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard case .verified(let tx) = result, tx.productID == productID else { continue }
                let s = self  // rebind weak var as let to satisfy Swift 6 sendability check
                await MainActor.run { s?.isPremium = true }
                await tx.finish()
            }
        }
    }

    enum StoreError: Error {
        case failedVerification
    }

    // MARK: - Testing

#if DEBUG
    /// テスト用インスタンス。isPremium を任意の初期値で生成する。
    @MainActor static func testInstance(isPremium: Bool) -> PurchaseManager {
        PurchaseManager(isPremium: isPremium)
    }
#endif
}
