import XCTest
@testable import Javasta

final class JavaTokenizerTests: XCTestCase {
    func testLineCommentStartsOutsideStringLiteral() {
        let tokens = JavaTokenizer.tokenize(#"String url = "https://example.com"; // comment"#)[0]

        XCTAssertEqual(tokens.filter { $0.kind == .string }.map(\.text), [#""https://example.com""#])
        XCTAssertEqual(tokens.last?.kind, .comment)
        XCTAssertEqual(tokens.last?.text, "// comment")
    }

    func testLineCommentMarkerInsideStringIsNotComment() {
        let tokens = JavaTokenizer.tokenize(#"System.out.println("http://localhost");"#)[0]

        XCTAssertEqual(tokens.filter { $0.kind == .string }.map(\.text), [#""http://localhost""#])
        XCTAssertFalse(tokens.contains { $0.kind == .comment })
    }

    func testEscapedQuoteDoesNotEndStringBeforeCommentMarker() {
        let tokens = JavaTokenizer.tokenize(#"String s = "quote \" // still string"; // comment"#)[0]

        XCTAssertEqual(tokens.filter { $0.kind == .comment }.map(\.text), ["// comment"])
        XCTAssertEqual(tokens.filter { $0.kind == .string }.map(\.text), [#""quote \" // still string""#])
    }
}
