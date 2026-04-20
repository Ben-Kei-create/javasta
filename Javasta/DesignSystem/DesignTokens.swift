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
}

extension Font {
    static func codeFont(_ size: CGFloat = 13) -> Font {
        .system(size: size, design: .monospaced)
    }
}

extension Animation {
    static let jbSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let jbFast   = Animation.spring(response: 0.3, dampingFraction: 0.8)
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
    static var jbScaled: JBScaledButtonStyle { JBScaledButtonStyle() }
}
