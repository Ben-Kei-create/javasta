import SwiftUI

struct LevelBadgeView: View {
    let level: JavaLevel

    var body: some View {
        Text(level.displayName)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color(hex: level.badgeColor)))
    }
}
