//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class RangeFilterTests: XCTestCase {
    func testInit() {
        let filter = RangeFilter(title: "Range", key: "range", lowValueKey: "range_from", highValueKey: "range_to", kind: .context)

        XCTAssertEqual(filter.title, "Range")
        XCTAssertEqual(filter.key, "range")
        XCTAssertEqual(filter.lowValueFilter.key, "range_from")
        XCTAssertEqual(filter.highValueFilter.key, "range_to")
        XCTAssertEqual(filter.kind, .context)
    }
}
