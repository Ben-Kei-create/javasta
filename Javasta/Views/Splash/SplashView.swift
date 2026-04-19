import SwiftUI

struct SplashView: View {
    var onFinish: () -> Void

    private enum Stage: Int {
        case boot
        case compile
        case link
        case reveal
        case ready
    }

    @State private var stage: Stage = .boot
    @State private var pulse = false
    @State private var fadeOut = false

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let compactHeight = size.height < 700

            ZStack {
                Color.jbBackground.ignoresSafeArea()
                backgroundGrid

                VStack(spacing: compactHeight ? 18 : 26) {
                    Spacer(minLength: compactHeight ? 18 : 44)

                    launchConsole(compactHeight: compactHeight)
                        .frame(maxWidth: min(size.width - 32, 520))
                        .opacity(stage.rawValue >= Stage.compile.rawValue ? 1 : 0)
                        .offset(y: stage.rawValue >= Stage.compile.rawValue ? 0 : 14)

                    logoLockup(width: size.width, compactHeight: compactHeight)
                        .padding(.top, compactHeight ? 0 : 4)

                    statusPill
                        .opacity(stage.rawValue >= Stage.ready.rawValue ? 1 : 0)
                        .offset(y: stage.rawValue >= Stage.ready.rawValue ? 0 : 8)

                    Spacer(minLength: compactHeight ? 18 : 44)
                }
                .padding(.horizontal, Spacing.md)
            }
        }
        .opacity(fadeOut ? 0 : 1)
        .preferredColorScheme(.dark)
        .task {
            await runAnimation()
        }
    }

    // MARK: - Background

    private var backgroundGrid: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            Canvas { context, _ in
                var path = Path()
                for x in stride(from: 0, through: width, by: 28) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }
                for y in stride(from: 0, through: height, by: 28) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
                context.stroke(path, with: .color(Color.jbBorder.opacity(0.18)), lineWidth: 0.6)
            }
            .mask(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.65), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.jbAccent.opacity(0.12),
                            Color.clear,
                            Color.jbSyntaxType.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea()
        }
    }

    // MARK: - Launch console

    private func launchConsole(compactHeight: Bool) -> some View {
        VStack(spacing: 0) {
            titleBar
            Rectangle().fill(Color.jbBorder).frame(height: 1)

            VStack(alignment: .leading, spacing: compactHeight ? 8 : 10) {
                launchLine(
                    symbol: "terminal.fill",
                    text: "javac JavaSta.java",
                    tint: Color.jbSyntaxType,
                    isActive: stage.rawValue >= Stage.compile.rawValue
                )
                launchLine(
                    symbol: "checkmark.seal.fill",
                    text: "BUILD SUCCESS",
                    tint: Color.jbSuccess,
                    isActive: stage.rawValue >= Stage.link.rawValue
                )
                launchLine(
                    symbol: "play.fill",
                    text: "java JavaSta",
                    tint: Color.jbAccent,
                    isActive: stage.rawValue >= Stage.reveal.rawValue
                )
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, compactHeight ? 12 : 16)
        }
        .background(Color.jbCard.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .stroke(Color.jbBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.28), radius: 18, x: 0, y: 14)
        .animation(.jbFast, value: stage)
    }

    private var titleBar: some View {
        HStack(spacing: Spacing.sm) {
            Circle().fill(Color(hex: "FF5F57")).frame(width: 10, height: 10)
            Circle().fill(Color(hex: "FEBC2E")).frame(width: 10, height: 10)
            Circle().fill(Color(hex: "28C840")).frame(width: 10, height: 10)

            Spacer()

            Label("Launch.java", systemImage: "chevron.left.forwardslash.chevron.right")
                .font(.codeFont(11))
                .foregroundStyle(Color.jbSubtext)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer()

            Color.clear.frame(width: 30, height: 1)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 10)
    }

    private func launchLine(symbol: String, text: String, tint: Color, isActive: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(isActive ? tint : Color.jbSubtext.opacity(0.35))
                .frame(width: 18)

            Text(text)
                .font(.codeFont(13))
                .foregroundStyle(isActive ? Color.jbText : Color.jbSubtext.opacity(0.42))
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Spacer(minLength: Spacing.sm)

            if isActive {
                Capsule()
                    .fill(tint)
                    .frame(width: 28, height: 3)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    // MARK: - Logo

    private func logoLockup(width: CGFloat, compactHeight: Bool) -> some View {
        let logoSize = min(max(width * 0.17, 48), compactHeight ? 74 : 88)

        return VStack(spacing: compactHeight ? 8 : 12) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("Java")
                    .foregroundStyle(Color.jbText)
                Text("Sta")
                    .foregroundStyle(Color.jbAccent)
            }
            .font(.system(size: logoSize, weight: .black, design: .rounded))
            .lineLimit(1)
            .minimumScaleFactor(0.58)
            .allowsTightening(true)
            .shadow(color: Color.jbAccent.opacity(stage.rawValue >= Stage.reveal.rawValue ? 0.36 : 0), radius: 18, x: 0, y: 0)
            .scaleEffect(stage.rawValue >= Stage.reveal.rawValue ? 1 : 0.92)
            .opacity(stage.rawValue >= Stage.reveal.rawValue ? 1 : 0)
            .overlay(alignment: .bottom) {
                Capsule()
                    .fill(Color.jbAccent)
                    .frame(width: stage.rawValue >= Stage.ready.rawValue ? min(width * 0.38, 180) : 0, height: 4)
                    .offset(y: compactHeight ? 6 : 8)
            }

            HStack(spacing: 8) {
                Text("SILVER")
                Text("/")
                    .foregroundStyle(Color.jbSubtext)
                Text("GOLD")
            }
            .font(.system(size: 11, weight: .bold).monospacedDigit())
            .tracking(3)
            .foregroundStyle(Color.jbSubtext)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .opacity(stage.rawValue >= Stage.ready.rawValue ? 1 : 0)
        }
        .padding(.vertical, compactHeight ? 4 : 10)
        .animation(.spring(response: 0.58, dampingFraction: 0.78), value: stage)
    }

    private var statusPill: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.jbSuccess)
                .frame(width: 7, height: 7)
                .scaleEffect(pulse ? 1.35 : 0.85)
                .opacity(pulse ? 0.45 : 1)

            Text("READY FOR PRACTICE")
                .font(.system(size: 11, weight: .bold).monospacedDigit())
                .tracking(2)
                .foregroundStyle(Color.jbText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(Color.jbCard.opacity(0.72))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.jbBorder, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true), value: pulse)
    }

    // MARK: - Animation

    private func runAnimation() async {
        pulse = true

        try? await Task.sleep(nanoseconds: 180_000_000)
        withAnimation(.jbFast) { stage = .compile }

        try? await Task.sleep(nanoseconds: 360_000_000)
        withAnimation(.jbFast) { stage = .link }

        try? await Task.sleep(nanoseconds: 320_000_000)
        withAnimation(.spring(response: 0.48, dampingFraction: 0.78)) { stage = .reveal }

        try? await Task.sleep(nanoseconds: 420_000_000)
        withAnimation(.jbSpring) { stage = .ready }

        try? await Task.sleep(nanoseconds: 760_000_000)
        withAnimation(.easeInOut(duration: 0.38)) { fadeOut = true }

        try? await Task.sleep(nanoseconds: 400_000_000)
        onFinish()
    }
}

#Preview {
    SplashView(onFinish: {})
}
