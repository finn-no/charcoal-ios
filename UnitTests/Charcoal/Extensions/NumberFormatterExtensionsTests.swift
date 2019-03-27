//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class NumberFormatterExtensionsTests: XCTestCase {
    func testFormatterWithSeparator() {
        let formatter = NumberFormatter.formatterWithSeparator
        XCTAssertEqual(formatter.string(from: 10), "10")
        XCTAssertEqual(formatter.string(from: 100), "100")
        XCTAssertEqual(formatter.string(from: 1000), "1 000")
        XCTAssertEqual(formatter.string(from: 10000), "10 000")
        XCTAssertEqual(formatter.string(from: 100_000), "100 000")
        XCTAssertEqual(formatter.string(from: 1_000_000), "1 000 000")
    }
}
