import SwiftUI

struct SplashView: View {
    var onFinish: () -> Void

    private let fullCode = """
public class Main {
    public static void main(String[] args) {
        System.out.println("Hello!! Javasta");
    }
}
"""

    @State private var typedCount: Int = 0
    @State private var cursorOn: Bool = true
    @State private var showLogo: Bool = false
    @State private var fadeOut: Bool = false

    private var typedPrefix: String {
        let end = fullCode.index(fullCode.startIndex, offsetBy: min(typedCount, fullCode.count))
        return String(fullCode[..<end])
    }

    private var lines: [String] {
        let prefix = typedPrefix
        let split = prefix.components(separatedBy: "\n")
        if split.isEmpty { return [""] }
        return split
    }

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            VStack(spacing: Spacing.md) {
                Spacer(minLength: Spacing.xl)

                editorWindow

                if showLogo {
                    logoBlock
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer()
            }
            .padding(.horizontal, Spacing.md)
        }
        .opacity(fadeOut ? 0 : 1)
        .preferredColorScheme(.dark)
        .task {
            await runAnimation()
        }
        .onAppear {
            startCursorBlink()
        }
    }

    // MARK: - Editor window

    private var editorWindow: some View {
        VStack(spacing: 0) {
            titleBar
            Rectangle().fill(Color.jbBorder).frame(height: 1)
            codeArea
        }
        .background(Color.jbCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .stroke(Color.jbBorder, lineWidth: 1)
        )
    }

    private var titleBar: some View {
        HStack(spacing: Spacing.sm) {
            Circle().fill(Color(hex: "FF5F57")).frame(width: 11, height: 11)
            Circle().fill(Color(hex: "FEBC2E")).frame(width: 11, height: 11)
            Circle().fill(Color(hex: "28C840")).frame(width: 11, height: 11)

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.jbSyntaxType)
                Text("Main.java")
                    .font(.codeFont(11))
                    .foregroundStyle(Color.jbText)
            }

            Spacer()

            Color.clear.frame(width: 33, height: 1)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 10)
    }

    private var codeArea: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.offset) { idx, lineText in
                let isLast = idx == lines.count - 1
                HStack(spacing: 0) {
                    Text("\(idx + 1)")
                        .font(.codeFont(11))
                        .foregroundStyle(Color.jbSubtext)
                        .frame(width: 28, alignment: .trailing)
                        .padding(.trailing, Spacing.sm)

                    Rectangle().fill(Color.jbBorder).frame(width: 1)

                    HStack(spacing: 0) {
                        tokenizedLine(lineText)
                        if isLast { cursor }
                    }
                    .padding(.leading, Spacing.md)

                    Spacer(minLength: 0)
                }
                .frame(height: 22)
            }
        }
        .padding(.vertical, Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func tokenizedLine(_ line: String) -> some View {
        let tokens = JavaTokenizer.tokenize(line).first ?? []
        return HStack(spacing: 0) {
            ForEach(Array(tokens.enumerated()), id: \.offset) { _, token in
                Text(token.text)
                    .font(.codeFont(13))
                    .foregroundStyle(tokenColor(token.kind))
            }
        }
    }

    private var cursor: some View {
        Rectangle()
            .fill(Color.jbAccent)
            .frame(width: 8, height: 16)
            .opacity(cursorOn ? 1 : 0)
    }

    private func tokenColor(_ kind: CodeToken.Kind) -> Color {
        switch kind {
        case .keyword: return .jbSyntaxKeyword
        case .type:    return .jbSyntaxType
        case .method:  return .jbSyntaxMethod
        case .string:  return .jbSyntaxString
        case .number:  return .jbSyntaxNumber
        case .comment: return .jbSyntaxComment
        case .plain:   return .jbText
        }
    }

    // MARK: - Logo block

    private var logoBlock: some View {
        VStack(spacing: 4) {
            Text("ジャバスタ")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(Color.jbText)
            Text("JAVASTA")
                .font(.system(size: 11, weight: .semibold).monospacedDigit())
                .foregroundStyle(Color.jbAccent)
                .tracking(4)
        }
        .padding(.top, Spacing.lg)
    }

    // MARK: - Animation

    private func runAnimation() async {
        // Brief opening delay
        try? await Task.sleep(nanoseconds: 250_000_000)

        for index in 0...fullCode.count {
            typedCount = index
            let ch = index > 0
                ? fullCode[fullCode.index(fullCode.startIndex, offsetBy: index - 1)]
                : Character(" ")
            // Variable typing speed: pauses on newlines look natural
            let delay: UInt64
            switch ch {
            case "\n":   delay = 90_000_000
            case " ":    delay = 18_000_000
            case "{", "}", ";": delay = 70_000_000
            default:     delay = 28_000_000
            }
            try? await Task.sleep(nanoseconds: delay)
        }

        // After typing finishes, reveal logo
        try? await Task.sleep(nanoseconds: 300_000_000)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            showLogo = true
        }

        // Hold for a moment, then fade out
        try? await Task.sleep(nanoseconds: 900_000_000)
        withAnimation(.easeInOut(duration: 0.45)) {
            fadeOut = true
        }
        try? await Task.sleep(nanoseconds: 470_000_000)
        onFinish()
    }

    private func startCursorBlink() {
        Task {
            while !fadeOut {
                try? await Task.sleep(nanoseconds: 500_000_000)
                cursorOn.toggle()
            }
        }
    }
}

#Preview {
    SplashView(onFinish: {})
}
