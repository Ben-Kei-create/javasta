import SwiftUI

struct VariablePanelView: View {
    let variables: [Explanation.Variable]
    let previousVariables: [Explanation.Variable]
    let callStack: [Explanation.CallStackFrame]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            if !variables.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(variables) { variable in
                            VariableCardView(
                                variable: variable,
                                isChanged: hasChanged(variable)
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.xs)
                }
            } else {
                Text("変数なし")
                    .font(.codeFont(11))
                    .foregroundStyle(Color.jbSubtext)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
            }

            if !callStack.isEmpty {
                CallStackView(frames: callStack)
            }
        }
        .padding(.vertical, Spacing.xs)
    }

    private func hasChanged(_ variable: Explanation.Variable) -> Bool {
        let prev = previousVariables.first { $0.id == variable.id }
        return prev == nil || prev?.value != variable.value
    }
}

// MARK: - VariableCardView

struct VariableCardView: View {
    let variable: Explanation.Variable
    let isChanged: Bool

    @State private var scaleUp = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 3) {
                Text(variable.type)
                    .font(.codeFont(9))
                    .foregroundStyle(Color.jbSyntaxType)
                Text(variable.name)
                    .font(.codeFont(10).weight(.semibold))
                    .foregroundStyle(Color.jbSubtext)
            }

            Text(variable.value)
                .font(.codeFont(14).weight(.bold))
                .foregroundStyle(isChanged ? Color.jbAccent : Color.jbText)
                .scaleEffect(scaleUp ? 1.18 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.5), value: scaleUp)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: Radius.sm)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .stroke(
                            isChanged ? Color.jbAccent.opacity(0.6) : Color.jbBorder,
                            lineWidth: 1
                        )
                )
        )
        .onChange(of: variable.value) { _, _ in
            scaleUp = true
            Task {
                try? await Task.sleep(for: .milliseconds(280))
                scaleUp = false
            }
        }
    }
}

// MARK: - CallStackView

private struct CallStackView: View {
    let frames: [Explanation.CallStackFrame]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                ForEach(Array(frames.enumerated()), id: \.offset) { idx, frame in
                    Text(frame.method)
                        .font(.codeFont(11))
                        .foregroundStyle(
                            idx == frames.count - 1 ? Color.jbAccent : Color.jbSubtext
                        )
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.sm)
                                .fill(Color.jbBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Radius.sm)
                                        .stroke(
                                            idx == frames.count - 1
                                                ? Color.jbAccent.opacity(0.4)
                                                : Color.jbBorder.opacity(0.5),
                                            lineWidth: 1
                                        )
                                )
                        )

                    if idx < frames.count - 1 {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 8))
                            .foregroundStyle(Color.jbSubtext.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.xs)
        }
    }
}
