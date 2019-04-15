//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class IntExtensionsTests: XCTestCase {
    func testDecimalFormatted() {
        XCTAssertEqual(10.decimalFormatted, "10")
        XCTAssertEqual(100.decimalFormatted, "100")
        XCTAssertEqual(1000.decimalFormatted, "1 000")
        XCTAssertEqual(10000.decimalFormatted, "10 000")
        XCTAssertEqual(100_000.decimalFormatted, "100 000")
        XCTAssertEqual(10_000_000.decimalFormatted, "10 000 000")
    }
}
