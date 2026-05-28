import SwiftUI

enum Spacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let xl:  CGFloat = 32
    static let xxl: CGFloat = 48
}

enum Radius {
    static let sm: CGFloat = 6
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20   // モーダル・シート・結果画面など大きなカード向け
}

extension Font {
    static func codeFont(_ size: CGFloat = 13) -> Font {
        .system(size: size, design: .monospaced)
    }
}

extension Animation {
    static let jbSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let jbFast   = Animation.spring(response: 0.3, dampingFraction: 0.8)
    /// 大きなレイアウト遷移（結果画面・タブ切り替えなど）向けのゆったりしたスプリング
    static let jbSmooth = Animation.spring(response: 0.55, dampingFraction: 0.82)
}

// MARK: - jbCard ViewModifier

extension View {
    /// カード背景（角丸 + 塗り + ボーダー）を一括で適用する。
    ///
    /// コードベース全体で繰り返されていた
    ///   `.background(RoundedRectangle(...).fill(...).overlay(RoundedRectangle(...).stroke(...)))`
    /// パターンをひとつの呼び出しに集約する。
    ///
    /// ```swift
    /// // Before
    /// .background(
    ///     RoundedRectangle(cornerRadius: Radius.md)
    ///         .fill(Color.jbCard)
    ///         .overlay(RoundedRectangle(cornerRadius: Radius.md)
    ///             .stroke(Color.jbBorder, lineWidth: 1))
    /// )
    ///
    /// // After
    /// .jbCard()
    /// ```
    func jbCard(
        radius: CGFloat = Radius.md,
        fill: Color = Color.jbCard,
        border: Color = Color.jbBorder,
        borderWidth: CGFloat = 1
    ) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: radius)
                .fill(fill)
                .overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(border, lineWidth: borderWidth)
                )
        )
    }
}

// MARK: - Scaled press button style

struct JBScaledButtonStyle: ButtonStyle {
    var scaleAmount: CGFloat = 0.95
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == JBScaledButtonStyle {
    static let jbScaled = JBScaledButtonStyle()
}
