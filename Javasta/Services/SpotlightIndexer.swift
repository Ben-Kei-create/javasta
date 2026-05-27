import CoreSpotlight
import Foundation

@MainActor
final class SpotlightIndexer {
    static let shared = SpotlightIndexer()

    // アクティビティタイプ
    static let glossaryActivityType = "com.fumiakiMogi777.Javasta.glossary"
    static let lessonActivityType   = "com.fumiakiMogi777.Javasta.lesson"

    private init() {}

    func indexAll() {
        indexGlossaryTerms()
        indexLessons()
    }

    private func indexGlossaryTerms() {
        let items: [CSSearchableItem] = GlossaryTerm.samples.map { term in
            let attrs = CSSearchableItemAttributeSet(contentType: .text)
            attrs.title = term.term
            let desc = term.summary
            attrs.contentDescription = desc.count > 200
                ? String(desc.prefix(200))
                : desc
            attrs.keywords = term.aliases

            let item = CSSearchableItem(
                uniqueIdentifier: "glossary-\(term.id)",
                domainIdentifier: "glossary",
                attributeSet: attrs
            )
            return item
        }

        CSSearchableIndex.default().indexSearchableItems(items) { error in
            if let error {
                print("[SpotlightIndexer] glossary indexing error: \(error)")
            }
        }
    }

    private func indexLessons() {
        let items: [CSSearchableItem] = Lesson.samples.map { lesson in
            let attrs = CSSearchableItemAttributeSet(contentType: .text)
            attrs.title = lesson.title
            attrs.contentDescription = lesson.summary
            attrs.keywords = [lesson.level.displayName, lesson.categoryDisplayName]

            let item = CSSearchableItem(
                uniqueIdentifier: "lesson-\(lesson.id)",
                domainIdentifier: "lesson",
                attributeSet: attrs
            )
            return item
        }

        CSSearchableIndex.default().indexSearchableItems(items) { error in
            if let error {
                print("[SpotlightIndexer] lesson indexing error: \(error)")
            }
        }
    }
}
