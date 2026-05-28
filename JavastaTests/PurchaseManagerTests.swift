import Testing
@testable import Javasta

// StoreKit 2 の実購入フローはデバイス/エンタイトルメントが必要なため、
// ここではビジネスロジック（アクセス制御・状態遷移）のみテストする。

@Suite("課金マネージャー") struct PurchaseManagerTests {

    // MARK: - canAccess

    @Test("未購入時は Silver にのみアクセスできること") @MainActor func testCanAccessSilverWhenNotPremium() {
        let manager = PurchaseManager.testInstance(isPremium: false)
        #expect(manager.canAccess(level: .silver) == true)
        #expect(manager.canAccess(level: .gold) == false)
    }

    @Test("購入済みは Silver/Gold 両方にアクセスできること") @MainActor func testCanAccessBothLevelsWhenPremium() {
        let manager = PurchaseManager.testInstance(isPremium: true)
        #expect(manager.canAccess(level: .silver) == true)
        #expect(manager.canAccess(level: .gold) == true)
    }

    // MARK: - canAccessMockExam

    @Test("未購入時は模擬試験にアクセスできないこと") @MainActor func testCannotAccessMockExamWhenNotPremium() {
        let manager = PurchaseManager.testInstance(isPremium: false)
        #expect(manager.canAccessMockExam == false)
    }

    @Test("購入済みは模擬試験にアクセスできること") @MainActor func testCanAccessMockExamWhenPremium() {
        let manager = PurchaseManager.testInstance(isPremium: true)
        #expect(manager.canAccessMockExam == true)
    }

    // MARK: - productID

    @Test("プロダクト ID が正しく設定されていること") func testProductIDMatchesAppStoreConnect() {
        #expect(PurchaseManager.productID == "com.fumiakiMogi777.Javasta.premium")
    }
}
