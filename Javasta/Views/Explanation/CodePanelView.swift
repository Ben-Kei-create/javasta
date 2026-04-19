import SwiftUI

// MARK: - Syntax Tokenizer

struct CodeToken {
    enum Kind { case keyword, type, method, string, number, comment, plain }
    let text: String
    let kind: Kind
}

enum JavaTokenizer {
    private static let keywords: Set<String> = [
        "public", "private", "protected", "static", "final", "abstract",
        "class", "interface", "enum", "extends", "implements",
        "void", "return", "new", "this", "super",
        "if", "else", "for", "while", "do", "switch", "case",
        "break", "continue", "default",
        "try", "catch", "finally", "throw", "throws",
        "import", "package", "true", "false", "null",
        "instanceof", "synchronized", "volatile", "transient",
        "var", "record", "sealed", "permits",
    ]
    private static let primitives: Set<String> = [
        "int", "long", "short", "byte", "double", "float", "boolean", "char",
    ]
    private static let stdTypes: Set<String> = [
        "String", "Integer", "Long", "Double", "Float", "Boolean",
        "Character", "Object", "Number", "System", "Math",
        "List", "Map", "Set", "ArrayList", "HashMap", "HashSet",
        "Optional", "Stream", "Arrays", "Collections",
    ]

    static func tokenize(_ code: String) -> [[CodeToken]] {
        code.components(separatedBy: "\n").map { tokenizeLine($0) }
    }

    private static func tokenizeLine(_ line: String) -> [CodeToken] {
        if let range = line.range(of: "//") {
            let before = String(line[..<range.lowerBound])
            let comment = String(line[range.lowerBound...])
            return tokenizeSegment(before) + [CodeToken(text: comment, kind: .comment)]
        }
        if line.trimmingCharacters(in: .whitespaces).hasPrefix("/*") ||
           line.trimmingCharacters(in: .whitespaces).hasPrefix("*") {
            return [CodeToken(text: line, kind: .comment)]
        }
        return tokenizeSegment(line)
    }

    private static func tokenizeSegment(_ text: String) -> [CodeToken] {
        var tokens: [CodeToken] = []
        var word = ""
        var i = text.startIndex

        func flush(nextChar: Character? = nil) {
            guard !word.isEmpty else { return }
            tokens.append(CodeToken(text: word, kind: classify(word, nextChar: nextChar)))
            word = ""
        }

        while i < text.endIndex {
            let c = text[i]
            if c == "\"" || c == "'" {
                flush()
                let quote = c
                var s = String(c)
                i = text.index(after: i)
                while i < text.endIndex && text[i] != quote {
                    if text[i] == "\\" { s.append(text[i]); i = text.index(after: i) }
                    if i < text.endIndex { s.append(text[i]); i = text.index(after: i) }
                }
                if i < text.endIndex { s.append(text[i]); i = text.index(after: i) }
                tokens.append(CodeToken(text: s, kind: .string))
            } else if c.isLetter || c == "_" || (!word.isEmpty && c.isNumber) {
                word.append(c)
                i = text.index(after: i)
            } else if c.isNumber && word.isEmpty {
                var n = ""
                while i < text.endIndex && (text[i].isNumber || text[i] == "." || text[i] == "L" || text[i] == "f") {
                    n.append(text[i]); i = text.index(after: i)
                }
                tokens.append(CodeToken(text: n, kind: .number))
            } else {
                flush(nextChar: c)
                tokens.append(CodeToken(text: String(c), kind: .plain))
                i = text.index(after: i)
            }
        }
        flush()
        return postProcess(tokens)
    }

    private static func classify(_ word: String, nextChar: Character? = nil) -> CodeToken.Kind {
        if keywords.contains(word)   { return .keyword }
        if primitives.contains(word) { return .type }
        if stdTypes.contains(word)   { return .type }
        if word.first?.isUppercase == true { return .type }
        if nextChar == "(" { return .method }
        return .plain
    }

    /// ジェネリクスのワイルドカード `?` や型パラメータを補正（plain → typeParam）
    /// `< T >`, `<? extends Number>`, `<T, U>` の中の識別子を type として扱う。
    private static func postProcess(_ tokens: [CodeToken]) -> [CodeToken] {
        var result = tokens
        var depth = 0
        for idx in 0..<result.count {
            let t = result[idx]
            if t.kind == .plain && t.text == "<" {
                depth += 1
            } else if t.kind == .plain && t.text == ">" {
                depth = max(0, depth - 1)
            } else if depth > 0, t.kind == .plain {
                if t.text == "?" {
                    result[idx] = CodeToken(text: t.text, kind: .type)
                } else if let first = t.text.first, first.isLetter,
                          t.text.count == 1 || t.text.allSatisfy({ $0.isUppercase || $0.isNumber }) {
                    // T, K, V, T1 などの型パラメータ
                    result[idx] = CodeToken(text: t.text, kind: .type)
                }
            }
        }
        return result
    }
}

// MARK: - CodePanelView

struct CodePanelView: View {
    let code: String
    let highlightLines: [Int]
    var predictLines: Set<Int> = []
    var zoom: Double = 1.0

    private var lines: [[CodeToken]] { JavaTokenizer.tokenize(code) }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(lines.enumerated()), id: \.offset) { idx, tokens in
                        CodeLineView(
                            lineNumber: idx + 1,
                            tokens: tokens,
                            isHighlighted: highlightLines.contains(idx + 1),
                            hasPredict: predictLines.contains(idx + 1),
                            zoom: zoom
                        )
                        .id(idx + 1)
                    }
                }
                .padding(.vertical, Spacing.xs)
            }
            .onChange(of: highlightLines) { _, newLines in
                if let first = newLines.first {
                    withAnimation(.jbSpring) {
                        proxy.scrollTo(first, anchor: .center)
                    }
                }
            }
        }
    }
}

// MARK: - CodeLineView

private struct CodeLineView: View {
    let lineNumber: Int
    let tokens: [CodeToken]
    let isHighlighted: Bool
    let hasPredict: Bool
    let zoom: Double

    var body: some View {
        HStack(spacing: 0) {
            GutterView(lineNumber: lineNumber, isHighlighted: isHighlighted, hasPredict: hasPredict, zoom: zoom)

            Rectangle()
                .fill(Color.jbBorder)
                .frame(width: 1)

            HStack(spacing: 0) {
                ForEach(Array(tokens.enumerated()), id: \.offset) { _, token in
                    Text(token.text)
                        .font(.codeFont(13 * zoom))
                        .foregroundStyle(tokenColor(token.kind))
                }
            }
            .padding(.leading, Spacing.md)
            .padding(.trailing, Spacing.xl)

            Spacer(minLength: 0)
        }
        .frame(height: 26 * zoom)
        .background(isHighlighted ? Color.jbAccent.opacity(0.07) : Color.clear)
        .animation(.jbFast, value: isHighlighted)
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
}

// MARK: - GutterView

private struct GutterView: View {
    let lineNumber: Int
    let isHighlighted: Bool
    let hasPredict: Bool
    let zoom: Double

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Group {
                if isHighlighted {
                    Image(systemName: "arrowtriangle.right.fill")
                        .font(.system(size: 8 * zoom))
                        .foregroundStyle(Color.jbAccent)
                } else if hasPredict {
                    Circle()
                        .fill(Color.jbWarning)
                        .frame(width: 5 * zoom, height: 5 * zoom)
                } else {
                    Color.clear.frame(width: 8, height: 8)
                }
            }
            .frame(width: 10)

            Text("\(lineNumber)")
                .font(.codeFont(11 * zoom))
                .foregroundStyle(isHighlighted ? Color.jbAccent : Color.jbSubtext)
                .frame(width: 28 * max(zoom, 1.0), alignment: .trailing)
        }
        .frame(width: 52 * max(zoom, 1.0))
        .padding(.leading, Spacing.sm)
    }
}
