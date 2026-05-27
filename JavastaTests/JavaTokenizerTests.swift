import Testing
@testable import Javasta

@Suite("Javaトークナイザー") struct JavaTokenizerTests {
    @Test("文字列リテラル外の行コメントが正しくトークン化されること") func testLineCommentStartsOutsideStringLiteral() {
        let tokens = JavaTokenizer.tokenize(#"String url = "https://example.com"; // comment"#)[0]

        #expect(tokens.filter { $0.kind == .string }.map(\.text) == [#""https://example.com""#])
        #expect(tokens.last?.kind == .comment)
        #expect(tokens.last?.text == "// comment")
    }

    @Test("文字列内の行コメントマーカーがコメントとして扱われないこと") func testLineCommentMarkerInsideStringIsNotComment() {
        let tokens = JavaTokenizer.tokenize(#"System.out.println("http://localhost");"#)[0]

        #expect(tokens.filter { $0.kind == .string }.map(\.text) == [#""http://localhost""#])
        #expect(!tokens.contains { $0.kind == .comment })
    }

    @Test("エスケープされたクォートがコメントマーカー前に文字列を終了させないこと") func testEscapedQuoteDoesNotEndStringBeforeCommentMarker() {
        let tokens = JavaTokenizer.tokenize(#"String s = "quote \" // still string"; // comment"#)[0]

        #expect(tokens.filter { $0.kind == .comment }.map(\.text) == ["// comment"])
        #expect(tokens.filter { $0.kind == .string }.map(\.text) == [#""quote \" // still string""#])
    }

    // MARK: - 数値リテラル

    @Test("16進数リテラルが数値トークンとして認識されること") func testHexLiteralIsTokenizedAsNumber() {
        let tokens = JavaTokenizer.tokenize("int x = 0xFF;")[0]
        #expect(tokens.filter { $0.kind == .number }.map(\.text) == ["0xFF"])
    }

    @Test("大文字Xの16進数リテラルが数値トークンとして認識されること") func testHexLiteralUpperCaseXIsTokenizedAsNumber() {
        let tokens = JavaTokenizer.tokenize("long v = 0XDEAD_BEEF;")[0]
        #expect(tokens.filter { $0.kind == .number }.map(\.text) == ["0XDEAD_BEEF"])
    }

    @Test("2進数リテラルが数値トークンとして認識されること") func testBinaryLiteralIsTokenizedAsNumber() {
        let tokens = JavaTokenizer.tokenize("int b = 0b1010;")[0]
        #expect(tokens.filter { $0.kind == .number }.map(\.text) == ["0b1010"])
    }

    @Test("アンダースコア付き2進数リテラルが数値トークンとして認識されること") func testBinaryLiteralWithUnderscoreIsTokenizedAsNumber() {
        let tokens = JavaTokenizer.tokenize("byte flags = 0b1010_0110;")[0]
        #expect(tokens.filter { $0.kind == .number }.map(\.text) == ["0b1010_0110"])
    }

    @Test("アンダースコア付き10進数リテラルが数値トークンとして認識されること") func testDecimalWithUnderscoreIsTokenizedAsNumber() {
        let tokens = JavaTokenizer.tokenize("int million = 1_000_000;")[0]
        #expect(tokens.filter { $0.kind == .number }.map(\.text) == ["1_000_000"])
    }

    @Test("Lサフィックス付き数値トークンにサフィックスが含まれること") func testLongSuffixIsIncludedInNumberToken() {
        let tokens = JavaTokenizer.tokenize("long l = 100L;")[0]
        #expect(tokens.filter { $0.kind == .number }.map(\.text) == ["100L"])
    }

    @Test("浮動小数点リテラルが数値トークンとして認識されること") func testFloatLiteralIsTokenizedAsNumber() {
        let tokens = JavaTokenizer.tokenize("float f = 3.14f;")[0]
        #expect(tokens.filter { $0.kind == .number }.map(\.text) == ["3.14f"])
    }

    @Test("科学的記数法リテラルが数値トークンとして認識されること") func testScientificNotationIsTokenizedAsNumber() {
        let tokens = JavaTokenizer.tokenize("double d = 1.5e10;")[0]
        #expect(tokens.filter { $0.kind == .number }.map(\.text) == ["1.5e10"])
    }

    // MARK: - char リテラル

    @Test("charリテラルが文字列トークンとして認識されること") func testCharLiteralIsTokenizedAsString() {
        let tokens = JavaTokenizer.tokenize("char c = 'A';")[0]
        #expect(tokens.filter { $0.kind == .string }.map(\.text) == ["'A'"])
    }

    @Test("エスケープシーケンス付きcharリテラルが文字列トークンとして認識されること") func testEscapedCharLiteralIsTokenizedAsString() {
        let tokens = JavaTokenizer.tokenize(#"char nl = '\n';"#)[0]
        #expect(tokens.filter { $0.kind == .string }.map(\.text) == [#"'\n'"#])
    }

    // MARK: - ブロックコメント

    @Test("スラッシュアスタリスクで始まる行がブロックコメントとして認識されること") func testBlockCommentLineStartingWithSlashStarIsComment() {
        let tokens = JavaTokenizer.tokenize("/* inline block comment */")[0]
        #expect(tokens.first?.kind == .comment)
    }

    @Test("アスタリスクで始まるJavadoc継続行がコメントとして認識されること") func testBlockCommentContinuationLineStartingWithStarIsComment() {
        let tokens = JavaTokenizer.tokenize(" * Javadoc continuation line")[0]
        #expect(tokens.first?.kind == .comment)
    }
}
