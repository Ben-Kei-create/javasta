import SwiftUI

struct GlossaryListView: View {
    @State private var search: String = ""

    private var filteredTerms: [GlossaryTerm] {
        let q = search.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return GlossaryTerm.samples }
        return GlossaryTerm.samples.filter { term in
            term.term.lowercased().contains(q) ||
            term.aliases.joined(separator: " ").lowercased().contains(q) ||
            plainSummary(term.summary).lowercased().contains(q)
        }
    }

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    searchBar

                    if filteredTerms.isEmpty {
                        emptyState
                    } else {
                        ForEach(filteredTerms) { term in
                            NavigationLink(value: term.id) {
                                termRow(term)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Spacer(minLength: Spacing.xxl)
                }
                .padding(Spacing.md)
            }
        }
        .navigationTitle("用語集")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    private var searchBar: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13))
                .foregroundStyle(Color.jbSubtext)
            TextField("用語を検索", text: $search)
                .font(.system(size: 14))
                .foregroundStyle(Color.jbText)
                .tint(Color.jbAccent)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !search.isEmpty {
                Button(action: { search = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.jbSubtext)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbBorder, lineWidth: 1)
                )
        )
        .padding(.bottom, Spacing.xs)
    }

    private func termRow(_ term: GlossaryTerm) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "character.book.closed.fill")
                .font(.system(size: 15))
                .foregroundStyle(Color.jbAccent)
                .frame(width: 36, height: 36)
                .background(RoundedRectangle(cornerRadius: Radius.sm).fill(Color.jbAccent.opacity(0.12)))

            VStack(alignment: .leading, spacing: 3) {
                Text(term.term)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.jbText)
                    .multilineTextAlignment(.leading)
                Text(plainSummary(term.summary))
                    .font(.system(size: 12))
                    .foregroundStyle(Color.jbSubtext)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundStyle(Color.jbSubtext)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbBorder, lineWidth: 1)
                )
        )
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 28))
                .foregroundStyle(Color.jbSubtext)
            Text("該当する用語が見つかりません")
                .font(.system(size: 13))
                .foregroundStyle(Color.jbSubtext)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }

    /// Markdown の [text](url) を text 部分だけに展開
    private func plainSummary(_ markdown: String) -> String {
        let pattern = #"\[([^\]]+)\]\([^)]+\)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return markdown }
        let mutable = NSMutableString(string: markdown)
        regex.replaceMatches(in: mutable, range: NSRange(location: 0, length: mutable.length), withTemplate: "$1")
        return mutable as String
    }
}
