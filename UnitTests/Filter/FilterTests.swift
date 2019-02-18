//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class FilterTests: XCTestCase {
    func testIsLeafFilter() {
        let filter = Filter(title: "Test", name: "test")
        XCTAssertTrue(filter.isLeafFilter)

        filter.add(child: Filter(title: "Child 1", name: "child-1"))
        filter.add(child: Filter(title: "Child 2", name: "child-2"))
        XCTAssertFalse(filter.isLeafFilter)
    }

    func testAddChild() {
        let filter = Filter(title: "Test", name: "test")
        filter.add(child: Filter(title: "Child 1", name: "child-1"))
        filter.add(child: Filter(title: "Child 2", name: "child-2"))
        XCTAssertEqual(filter.children.count, 2)
    }

    func testAddChildAtIndex() {
        let filter = Filter(title: "Test", name: "test")
        filter.add(child: Filter(title: "Child 1", name: "index-0"))
        filter.add(child: Filter(title: "Child 2", name: "index-2"))
        filter.add(child: Filter(title: "Child 3", name: "index-1"), at: 1)
        XCTAssertEqual(filter.child(at: 1)?.name, "index-1")
    }
}
