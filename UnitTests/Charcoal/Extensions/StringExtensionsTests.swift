//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class StringExtensionsTests: XCTestCase {
    func testRemovingWhitespaces() {
        let text = "Test String"
        XCTAssertEqual(text.removingWhitespaces(), "TestString")
    }

    func testRemoveWhitespaces() {
        var text = "Test String"
        text.removeWhitespaces()
        XCTAssertEqual(text, "TestString")
    }

    func testReplacementRangeWithWhitespaces() {
        let text = "1 000 000"
        let replacementRange = NSRange(location: 5, length: 1)
        let replacementString = ""
        let stringRange = text.replacementRangeNotConsideringWhitespaces(
            from: replacementRange,
            replacementString: replacementString
        )!
        let range = NSRange(stringRange, in: text)

        XCTAssertEqual(range.location, 4)
        XCTAssertEqual(range.length, 2)
    }

    func testReplacementRangeWithoutWhitespaces() {
        let text = "100"
        let replacementRange = NSRange(location: 1, length: 1)
        let replacementString = ""
        let stringRange = text.replacementRangeNotConsideringWhitespaces(
            from: replacementRange,
            replacementString: replacementString
        )!
        let range = NSRange(stringRange, in: text)

        XCTAssertEqual(range.location, 1)
        XCTAssertEqual(range.length, 1)
    }

    func testReplacementRangeWithReplacementString() {
        let text = "100"
        let replacementRange = NSRange(location: 1, length: 1)
        let replacementString = "2"
        let stringRange = text.replacementRangeNotConsideringWhitespaces(
            from: replacementRange,
            replacementString: replacementString
        )!
        let range = NSRange(stringRange, in: text)

        XCTAssertEqual(range.location, 1)
        XCTAssertEqual(range.length, 1)
    }
}
