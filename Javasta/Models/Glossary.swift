import Foundation

/// 用語集エントリ。レッスン本文から `[用語](javasta://term/<id>)` で参照される。
struct GlossaryTerm: Codable, Identifiable, Hashable {
    let id: String
    let term: String
    let aliases: [String]
    let summary: String
    let body: String
    let relatedTermIds: [String]
    let relatedLessonIds: [String]
    let relatedQuizIds: [String]
}

extension GlossaryTerm {
    /// 任意のURLが用語リンクなら用語IDを返す。例: `javasta://term/overload` → `"overload"`
    static func parse(url: URL) -> String? {
        guard url.scheme == "javasta", url.host == "term" else { return nil }
        let id = url.lastPathComponent
        return id.isEmpty ? nil : id
    }
}
