import SwiftUI

extension Color {
    static let jbBackground    = Color(hex: "0D1117")
    static let jbCard          = Color(hex: "161B22")
    static let jbBorder        = Color(hex: "30363D")
    static let jbText          = Color(hex: "E6EDF3")
    static let jbSubtext       = Color(hex: "7D8590")
    static let jbAccent        = Color(hex: "FF8A3D")
    static let jbSuccess       = Color(hex: "3FB950")
    static let jbWarning       = Color(hex: "D29922")
    static let jbError         = Color(hex: "F85149")

    static let jbSyntaxKeyword = Color(hex: "FF7B72")
    static let jbSyntaxString  = Color(hex: "A5D6FF")
    static let jbSyntaxType    = Color(hex: "FFA657")
    static let jbSyntaxMethod  = Color(hex: "D2A8FF")
    static let jbSyntaxComment = Color(hex: "8B949E")
    static let jbSyntaxNumber  = Color(hex: "79C0FF")

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
