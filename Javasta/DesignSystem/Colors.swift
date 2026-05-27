import SwiftUI
import UIKit

extension Color {

    // MARK: - Background / Surface

    /// 最も暗い背景（ページ背景）
    static let jbBackground = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "0D1117") : UIColor(hex: "F6F8FA")
    })

    /// カード背景
    static let jbCard = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "161B22") : UIColor(hex: "FFFFFF")
    })

    /// カード内ネストコンテナ
    static let jbSurface = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "1C2128") : UIColor(hex: "F0F1F3")
    })

    /// 区切り線・枠線
    static let jbBorder = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "30363D") : UIColor(hex: "D0D7DE")
    })

    // MARK: - Text

    static let jbText = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "E6EDF3") : UIColor(hex: "24292F")
    })

    static let jbSubtext = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "7D8590") : UIColor(hex: "656D76")
    })

    // MARK: - Accent / Semantic  (ライト/ダーク共通)

    static let jbAccent  = Color(hex: "FF8A3D")
    static let jbSuccess = Color(hex: "1A7F37")   // light でも見やすい緑
    static let jbWarning = Color(hex: "BF8700")   // light でも見やすい黄
    static let jbError   = Color(hex: "CF222E")   // light でも見やすい赤

    // MARK: - Syntax (コードブロックは常にダーク背景なので固定)

    static let jbSyntaxKeyword = Color(hex: "FF7B72")
    static let jbSyntaxString  = Color(hex: "A5D6FF")
    static let jbSyntaxType    = Color(hex: "FFA657")
    static let jbSyntaxMethod  = Color(hex: "D2A8FF")
    static let jbSyntaxComment = Color(hex: "8B949E")
    static let jbSyntaxNumber  = Color(hex: "79C0FF")

    // MARK: - Hex initializer

    init(hex: String) {
        let h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b)
    }
}

private extension UIColor {
    convenience init(hex: String) {
        let h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255
        let g = CGFloat((int >> 8) & 0xFF) / 255
        let b = CGFloat(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
