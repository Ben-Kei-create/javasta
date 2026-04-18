import SwiftUI

/// macOS風タイトルバー + ファイルタブ + 拡大ボタンを備えたコード表示コンポーネント。
/// 将来複数ファイル対応できるよう `tabs` を配列で受け取る。
struct CodeBlockView: View {
    struct FileTab: Identifiable, Equatable {
        let id: String
        let filename: String
        let code: String
    }

    let tabs: [FileTab]
    var highlightLines: [Int] = []
    var zoom: Double = 1.0
    var compactHeight: CGFloat = 220

    @State private var activeTabId: String
    @State private var isExpanded: Bool = false
    @AppStorage("codeZoom") private var storedZoom: Double = CodeZoom.default

    init(
        tabs: [FileTab],
        highlightLines: [Int] = [],
        zoom: Double = 1.0,
        compactHeight: CGFloat = 220
    ) {
        self.tabs = tabs
        self.highlightLines = highlightLines
        self.zoom = zoom
        self.compactHeight = compactHeight
        self._activeTabId = State(initialValue: tabs.first?.id ?? "")
    }

    private var activeCode: String {
        tabs.first(where: { $0.id == activeTabId })?.code ?? tabs.first?.code ?? ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider().background(Color.jbBorder)
            CodePanelView(code: activeCode, highlightLines: highlightLines, zoom: zoom)
                .frame(maxHeight: compactHeight)
        }
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbBorder, lineWidth: 1)
                )
        )
        .fullScreenCover(isPresented: $isExpanded) {
            ExpandedCodeView(
                tabs: tabs,
                initialTabId: activeTabId,
                highlightLines: highlightLines,
                onClose: { isExpanded = false }
            )
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: Spacing.sm) {
            HStack(spacing: 6) {
                Circle().fill(Color(hex: "FF5F57")).frame(width: 9, height: 9)
                Circle().fill(Color(hex: "FEBC2E")).frame(width: 9, height: 9)
                Circle().fill(Color(hex: "28C840")).frame(width: 9, height: 9)
            }

            tabStrip

            Spacer(minLength: Spacing.xs)

            Button(action: { isExpanded = true }) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.jbSubtext)
                    .frame(width: 24, height: 22)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.jbBorder, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    @ViewBuilder
    private var tabStrip: some View {
        if tabs.count > 1 {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(tabs) { tab in
                        tabPill(tab)
                    }
                }
            }
        } else if let only = tabs.first {
            tabPill(only)
        }
    }

    private func tabPill(_ tab: FileTab) -> some View {
        let isActive = tab.id == activeTabId
        return Button(action: { activeTabId = tab.id }) {
            HStack(spacing: 5) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(isActive ? Color.jbSyntaxType : Color.jbSubtext.opacity(0.7))
                Text(tab.filename)
                    .font(.codeFont(11))
                    .foregroundStyle(isActive ? Color.jbText : Color.jbSubtext)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(isActive ? Color.jbBackground : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(isActive ? Color.jbBorder : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Convenience

extension CodeBlockView {
    /// `class XXX` を抽出して `XXX.java` を返す。なければフォールバック。
    static func deriveFilename(from code: String, fallback: String = "Main.java") -> String {
        let pattern = #"class\s+([A-Z]\w*)"#
        guard
            let regex = try? NSRegularExpression(pattern: pattern),
            let match = regex.firstMatch(in: code, range: NSRange(code.startIndex..., in: code)),
            let nameRange = Range(match.range(at: 1), in: code)
        else { return fallback }
        return "\(String(code[nameRange])).java"
    }

    /// 単一ファイルの簡易イニシャライザ。
    init(
        code: String,
        filename: String? = nil,
        highlightLines: [Int] = [],
        zoom: Double = 1.0,
        compactHeight: CGFloat = 220
    ) {
        let name = filename ?? Self.deriveFilename(from: code)
        self.init(
            tabs: [FileTab(id: name, filename: name, code: code)],
            highlightLines: highlightLines,
            zoom: zoom,
            compactHeight: compactHeight
        )
    }
}

// MARK: - ExpandedCodeView

private struct ExpandedCodeView: View {
    let tabs: [CodeBlockView.FileTab]
    let initialTabId: String
    let highlightLines: [Int]
    var onClose: () -> Void

    @State private var activeTabId: String
    @AppStorage("codeZoom") private var zoom: Double = CodeZoom.default

    init(
        tabs: [CodeBlockView.FileTab],
        initialTabId: String,
        highlightLines: [Int],
        onClose: @escaping () -> Void
    ) {
        self.tabs = tabs
        self.initialTabId = initialTabId
        self.highlightLines = highlightLines
        self.onClose = onClose
        self._activeTabId = State(initialValue: initialTabId)
    }

    private var activeCode: String {
        tabs.first(where: { $0.id == activeTabId })?.code ?? tabs.first?.code ?? ""
    }

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                Divider().background(Color.jbBorder)
                tabBar
                Divider().background(Color.jbBorder)
                CodePanelView(code: activeCode, highlightLines: highlightLines, zoom: zoom)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(Color.jbBackground)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var topBar: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: onClose) {
                Image(systemName: "arrow.down.right.and.arrow.up.left")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.jbSubtext)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.jbCard))
            }

            Spacer()

            Text("コード全画面")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.jbText)

            Spacer()

            Button(action: { zoom = CodeZoom.next(after: zoom) }) {
                HStack(spacing: 4) {
                    Image(systemName: "textformat.size")
                        .font(.system(size: 11, weight: .semibold))
                    Text("\(CodeZoom.percent(zoom))%")
                        .font(.system(size: 11, weight: .bold).monospacedDigit())
                }
                .foregroundStyle(.white)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.jbAccent))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(tabs) { tab in
                    let isActive = tab.id == activeTabId
                    Button(action: { activeTabId = tab.id }) {
                        HStack(spacing: 5) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(isActive ? Color.jbSyntaxType : Color.jbSubtext)
                            Text(tab.filename)
                                .font(.codeFont(12))
                                .foregroundStyle(isActive ? Color.jbText : Color.jbSubtext)
                        }
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isActive ? Color.jbCard : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(isActive ? Color.jbBorder : Color.clear, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(.vertical, 6)
        .background(Color.jbCard.opacity(0.5))
    }
}
