import SwiftUI

struct CodeSyntaxPalette {
    let keyword: Color
    let string: Color
    let type: Color
    let method: Color
    let comment: Color
    let number: Color
    let plain: Color

    var swatches: [Color] {
        [keyword, type, method, string, number]
    }
}

enum CodeSyntaxTheme: String, CaseIterable, Identifiable {
    case classic
    case ocean
    case forest

    var id: String { rawValue }

    static let storageKey = "codeSyntaxTheme"

    static func value(for rawValue: String) -> CodeSyntaxTheme {
        CodeSyntaxTheme(rawValue: rawValue) ?? .classic
    }

    var displayName: String {
        switch self {
        case .classic: return "標準"
        case .ocean: return "Ocean"
        case .forest: return "Forest"
        }
    }

    var palette: CodeSyntaxPalette {
        switch self {
        case .classic:
            return CodeSyntaxPalette(
                keyword: .jbSyntaxKeyword,
                string: .jbSyntaxString,
                type: .jbSyntaxType,
                method: .jbSyntaxMethod,
                comment: .jbSyntaxComment,
                number: .jbSyntaxNumber,
                plain: .jbText
            )
        case .ocean:
            return CodeSyntaxPalette(
                keyword: Color(hex: "82AAFF"),
                string: Color(hex: "C3E88D"),
                type: Color(hex: "FFCB6B"),
                method: Color(hex: "89DDFF"),
                comment: Color(hex: "697098"),
                number: Color(hex: "F78C6C"),
                plain: .jbText
            )
        case .forest:
            return CodeSyntaxPalette(
                keyword: Color(hex: "8BE9A8"),
                string: Color(hex: "F4D35E"),
                type: Color(hex: "7DD3FC"),
                method: Color(hex: "FFB86C"),
                comment: Color(hex: "7D8B75"),
                number: Color(hex: "CBA6F7"),
                plain: .jbText
            )
        }
    }
}
