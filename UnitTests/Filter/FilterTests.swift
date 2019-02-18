//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class FilterTests: XCTestCase {
    func testIsLeafFilter() {
        let filter = Filter(title: "Test", name: "test")
        XCTAssertTrue(filter.isLeafFilter)

        filter.add(subfilter: Filter(title: "subfilter 1", name: "subfilter-1"))
        filter.add(subfilter: Filter(title: "subfilter 2", name: "subfilter-2"))
        XCTAssertFalse(filter.isLeafFilter)
    }

    func testAddsubfilter() {
        let filter = Filter(title: "Test", name: "test")
        filter.add(subfilter: Filter(title: "subfilter 1", name: "subfilter-1"))
        filter.add(subfilter: Filter(title: "subfilter 2", name: "subfilter-2"))
        XCTAssertEqual(filter.subfilters.count, 2)
    }

    func testAddsubfilterAtIndex() {
        let filter = Filter(title: "Test", name: "test")
        filter.add(subfilter: Filter(title: "subfilter 1", name: "index-0"))
        filter.add(subfilter: Filter(title: "subfilter 2", name: "index-2"))
        filter.add(subfilter: Filter(title: "subfilter 3", name: "index-1"), at: 1)
        XCTAssertEqual(filter.subfilter(at: 1)?.name, "index-1")
    }
}
