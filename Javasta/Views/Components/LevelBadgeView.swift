import SwiftUI

struct LevelBadgeView: View {
    let level: JavaLevel
    var zoomPercent: Int? = nil
    var onTap: (() -> Void)? = nil

    var body: some View {
        if let onTap {
            Button(action: onTap) { content }
                .buttonStyle(.plain)
        } else {
            content
        }
    }

    private var content: some View {
        Group {
            if let zoomPercent {
                Text("\(zoomPercent)%")
                    .font(.system(size: 11, weight: .bold).monospacedDigit())
                    .foregroundStyle(.white)
            } else {
                Text(level.displayName)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 3)
        .background(Capsule().fill(Color(hex: level.badgeColor)))
    }
}
