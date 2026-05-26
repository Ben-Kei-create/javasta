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

    // MARK: - 数値リテラル

    func testHexLiteralIsTokenizedAsNumber() {
        let tokens = JavaTokenizer.tokenize("int x = 0xFF;")[0]
        XCTAssertEqual(tokens.filter { $0.kind == .number }.map(\.text), ["0xFF"])
    }

    func testHexLiteralUpperCaseXIsTokenizedAsNumber() {
        let tokens = JavaTokenizer.tokenize("long v = 0XDEAD_BEEF;")[0]
        XCTAssertEqual(tokens.filter { $0.kind == .number }.map(\.text), ["0XDEAD_BEEF"])
    }

    func testBinaryLiteralIsTokenizedAsNumber() {
        let tokens = JavaTokenizer.tokenize("int b = 0b1010;")[0]
        XCTAssertEqual(tokens.filter { $0.kind == .number }.map(\.text), ["0b1010"])
    }

    func testBinaryLiteralWithUnderscoreIsTokenizedAsNumber() {
        let tokens = JavaTokenizer.tokenize("byte flags = 0b1010_0110;")[0]
        XCTAssertEqual(tokens.filter { $0.kind == .number }.map(\.text), ["0b1010_0110"])
    }

    func testDecimalWithUnderscoreIsTokenizedAsNumber() {
        let tokens = JavaTokenizer.tokenize("int million = 1_000_000;")[0]
        XCTAssertEqual(tokens.filter { $0.kind == .number }.map(\.text), ["1_000_000"])
    }

    func testLongSuffixIsIncludedInNumberToken() {
        let tokens = JavaTokenizer.tokenize("long l = 100L;")[0]
        XCTAssertEqual(tokens.filter { $0.kind == .number }.map(\.text), ["100L"])
    }

    func testFloatLiteralIsTokenizedAsNumber() {
        let tokens = JavaTokenizer.tokenize("float f = 3.14f;")[0]
        XCTAssertEqual(tokens.filter { $0.kind == .number }.map(\.text), ["3.14f"])
    }

    func testScientificNotationIsTokenizedAsNumber() {
        let tokens = JavaTokenizer.tokenize("double d = 1.5e10;")[0]
        XCTAssertEqual(tokens.filter { $0.kind == .number }.map(\.text), ["1.5e10"])
    }

    // MARK: - char リテラル

    func testCharLiteralIsTokenizedAsString() {
        let tokens = JavaTokenizer.tokenize("char c = 'A';")[0]
        XCTAssertEqual(tokens.filter { $0.kind == .string }.map(\.text), ["'A'"])
    }

    func testEscapedCharLiteralIsTokenizedAsString() {
        let tokens = JavaTokenizer.tokenize(#"char nl = '\n';"#)[0]
        XCTAssertEqual(tokens.filter { $0.kind == .string }.map(\.text), [#"'\n'"#])
    }

    // MARK: - ブロックコメント

    func testBlockCommentLineStartingWithSlashStarIsComment() {
        let tokens = JavaTokenizer.tokenize("/* inline block comment */")[0]
        XCTAssertEqual(tokens.first?.kind, .comment)
    }

    func testBlockCommentContinuationLineStartingWithStarIsComment() {
        let tokens = JavaTokenizer.tokenize(" * Javadoc continuation line")[0]
        XCTAssertEqual(tokens.first?.kind, .comment)
    }
}
