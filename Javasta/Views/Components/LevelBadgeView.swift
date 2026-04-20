import SwiftUI

struct LevelBadgeView: View {
    let level: JavaLevel
    var zoomPercent: Int? = nil
    var onTap: (() -> Void)? = nil

    /// ズーム%のラベルを折りたたみたいユーザー向け。長押しでトグル。
    @AppStorage("codeZoomLabelHidden") private var isLabelHidden: Bool = false

    var body: some View {
        if let onTap {
            Button(action: onTap) { content }
                .buttonStyle(.plain)
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.45).onEnded { _ in
                        if zoomPercent != nil {
                            isLabelHidden.toggle()
                        }
                    }
                )
        } else {
            content
        }
    }

    private var content: some View {
        Group {
            if let zoomPercent {
                if isLabelHidden {
                    Image(systemName: "textformat.size")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                } else {
                    HStack(spacing: 2) {
                        Image(systemName: "textformat.size")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                        Text("\(zoomPercent)%")
                            .font(.system(size: 11, weight: .bold).monospacedDigit())
                            .foregroundStyle(.white)
                    }
                }
            } else {
                Text(level.displayName)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, isLabelHidden && zoomPercent != nil ? 6 : Spacing.sm)
        .padding(.vertical, 3)
        .background(Capsule().fill(Color(hex: level.badgeColor)))
        .animation(.jbFast, value: isLabelHidden)
    }
}
