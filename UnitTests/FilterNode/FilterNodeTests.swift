//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class FilterNodeTests: XCTestCase {
    func testIsLeafNode() {
        let filterNode = Filter(title: "Test", name: "test")
        XCTAssertTrue(filterNode.isLeafNode)

        filterNode.add(child: Filter(title: "Child 1", name: "child-1"))
        filterNode.add(child: Filter(title: "Child 2", name: "child-2"))
        XCTAssertFalse(filterNode.isLeafNode)
    }

    func testAddChild() {
        let filterNode = Filter(title: "Test", name: "test")
        filterNode.add(child: Filter(title: "Child 1", name: "child-1"))
        filterNode.add(child: Filter(title: "Child 2", name: "child-2"))
        XCTAssertEqual(filterNode.children.count, 2)
    }

    func testAddChildAtIndex() {
        let filterNode = Filter(title: "Test", name: "test")
        filterNode.add(child: Filter(title: "Child 1", name: "index-0"))
        filterNode.add(child: Filter(title: "Child 2", name: "index-2"))
        filterNode.add(child: Filter(title: "Child 3", name: "index-1"), at: 1)
        XCTAssertEqual(filterNode.child(at: 1)?.name, "index-1")
    }
}
