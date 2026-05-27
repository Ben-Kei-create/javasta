import SwiftUI

struct GlossaryListView: View {
    @State private var search: String = ""

    // MARK: - Filtered & grouped data

    private var filteredTerms: [GlossaryTerm] {
        let q = search.trimmingCharacters(in: .whitespaces).lowercased()
        let sorted = GlossaryTerm.samples.sorted { $0.term.lowercased() < $1.term.lowercased() }
        guard !q.isEmpty else { return sorted }
        return sorted.filter { term in
            term.term.lowercased().contains(q)
            || term.aliases.joined(separator: " ").lowercased().contains(q)
            || plainText(term.summary).lowercased().contains(q)
        }
    }

    /// 先頭文字でグループ化（英→数の順、日本語はひらがな読み）
    private var groupedTerms: [(key: String, terms: [GlossaryTerm])] {
        let grouped = Dictionary(grouping: filteredTerms) { term -> String in
            let first = term.term.unicodeScalars.first
            if let s = first, CharacterSet.uppercaseLetters.union(.lowercaseLetters).contains(s) {
                return String(term.term.prefix(1)).uppercased()
            }
            return "#"
        }
        return grouped
            .sorted { a, b in
                if a.key == "#" { return false }
                if b.key == "#" { return true }
                return a.key < b.key
            }
            .map { (key: $0.key, terms: $0.value) }
    }

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                    // 検索バー
                    searchBar
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.sm)
                        .padding(.bottom, Spacing.md)

                    if filteredTerms.isEmpty {
                        emptyState
                    } else if !search.isEmpty {
                        // 検索時はグループなし・フラット表示
                        VStack(spacing: Spacing.sm) {
                            ForEach(filteredTerms) { term in
                                NavigationLink(value: term.id) {
                                    termRow(term)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                        searchResultCount
                    } else {
                        // 通常時：先頭文字でグループ
                        ForEach(groupedTerms, id: \.key) { group in
                            Section {
                                VStack(spacing: Spacing.sm) {
                                    ForEach(group.terms) { term in
                                        NavigationLink(value: term.id) {
                                            termRow(term)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, Spacing.md)
                                .padding(.bottom, Spacing.md)
                            } header: {
                                sectionHeader(group.key)
                            }
                        }
                    }

                    Spacer(minLength: Spacing.xxl)
                }
            }
        }
        .navigationTitle("用語集")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Search bar

    private var searchBar: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(Color.jbSubtext)
            TextField("用語・説明を検索", text: $search)
                .font(.system(size: 15))
                .foregroundStyle(Color.jbText)
                .tint(Color.jbAccent)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !search.isEmpty {
                Button(action: { search = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.jbSubtext)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 12)
        .jbCard()
    }

    // MARK: - Section header

    private func sectionHeader(_ letter: String) -> some View {
        HStack {
            Text(letter)
                .font(.system(size: 13, weight: .bold).monospaced())
                .foregroundStyle(Color.jbAccent)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.jbAccent.opacity(0.12)))
            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .background(Color.jbBackground)
    }

    // MARK: - Term row

    private func termRow(_ term: GlossaryTerm) -> some View {
        HStack(spacing: Spacing.md) {
            // 先頭文字アイコン
            Text(String(term.term.prefix(1)))
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.jbAccent)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: Radius.sm).fill(Color.jbAccent.opacity(0.1)))

            VStack(alignment: .leading, spacing: 5) {
                // 用語名 + エイリアス
                HStack(spacing: Spacing.xs) {
                    Text(term.term)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.jbText)
                        .multilineTextAlignment(.leading)
                    if !term.aliases.isEmpty {
                        Text(term.aliases.first ?? "")
                            .font(.codeFont(11))
                            .foregroundStyle(Color.jbSubtext)
                            .lineLimit(1)
                    }
                }

                // サマリー（3行まで）
                Text(plainText(term.summary))
                    .font(.system(size: 13))
                    .foregroundStyle(Color.jbSubtext)
                    .lineLimit(3)
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundStyle(Color.jbSubtext.opacity(0.6))
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .jbCard()
    }

    // MARK: - Search result count

    private var searchResultCount: some View {
        Text("\(filteredTerms.count)件ヒット")
            .font(.system(size: 12))
            .foregroundStyle(Color.jbSubtext)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, Spacing.sm)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundStyle(Color.jbSubtext.opacity(0.5))
            Text("「\(search)」に一致する用語が見つかりません")
                .font(.system(size: 14))
                .foregroundStyle(Color.jbSubtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
        .padding(.horizontal, Spacing.lg)
    }

    // MARK: - Helpers

    /// Markdown リンク `[text](url)` を text だけに展開
    private func plainText(_ markdown: String) -> String {
        let pattern = #"\[([^\]]+)\]\([^)]+\)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return markdown }
        let mutable = NSMutableString(string: markdown)
        regex.replaceMatches(
            in: mutable,
            range: NSRange(location: 0, length: mutable.length),
            withTemplate: "$1"
        )
        return mutable as String
    }
}
