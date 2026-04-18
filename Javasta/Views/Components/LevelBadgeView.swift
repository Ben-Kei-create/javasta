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
        HStack(spacing: 6) {
            Text(level.displayName)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)

            if let zoomPercent {
                Rectangle()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: 1, height: 9)
                Text("\(zoomPercent)%")
                    .font(.system(size: 10, weight: .semibold).monospacedDigit())
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 3)
        .background(Capsule().fill(Color(hex: level.badgeColor)))
    }
}
