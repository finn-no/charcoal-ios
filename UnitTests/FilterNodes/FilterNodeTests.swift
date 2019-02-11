//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class FilterNodeTests: XCTestCase {
    func testAddChild() {
        let filterNode = CCFilterNode(title: "Test", name: "test")
        filterNode.add(child: CCFilterNode(title: "Child 1", name: "child-1"))
        filterNode.add(child: CCFilterNode(title: "Child 2", name: "child-2"))
        XCTAssertEqual(filterNode.children.count, 2)
    }

    func testAddChildAtIndex() {
        let filterNode = CCFilterNode(title: "Test", name: "test")
        filterNode.add(child: CCFilterNode(title: "Child 1", name: "index-0"))
        filterNode.add(child: CCFilterNode(title: "Child 2", name: "index-2"))
        filterNode.add(child: CCFilterNode(title: "Child 3", name: "index-1"), at: 1)
        XCTAssertEqual(filterNode.child(at: 1)?.name, "index-1")
    }

    func testUrlItem() {
        let filterNode = CCFilterNode(title: "Title", name: "name", value: "value", isSelected: true, numberOfResults: 0)
        let urlItems = filterNode.queryItems
        XCTAssertEqual(urlItems.count, 1)
    }

    func testUrlItemValueNil() {
        let filterNode = CCFilterNode(title: "Title", name: "name", value: nil, isSelected: true, numberOfResults: 0)
        let urlItems = filterNode.queryItems
        XCTAssertEqual(urlItems.count, 0)
    }

    func testMultipleUrlItemsRootNotSelected() {
        let filterNode = CCFilterNode(title: "Title", name: "name")
        filterNode.add(child: CCFilterNode(title: "Title1", name: "name1", value: "value1", isSelected: true))
        filterNode.add(child: CCFilterNode(title: "Title2", name: "name2", value: "value2", isSelected: true))
        let urlItems = filterNode.queryItems
        XCTAssertEqual(urlItems.count, 2)
    }

    func testMultipleUrlItemsRootIsSelected() {
        let filterNode = CCFilterNode(title: "Title", name: "name", value: "value", isSelected: true)
        filterNode.add(child: CCFilterNode(title: "Title1", name: "name1", value: "value1", isSelected: true))
        filterNode.add(child: CCFilterNode(title: "Title2", name: "name2", value: "value2", isSelected: true))
        let urlItems = filterNode.queryItems
        XCTAssertEqual(urlItems.count, 1)
    }

    func testDelegateSelection() {
        let filterNode = CCFilterNode(title: "Title", name: "name", value: "value", isSelected: true)
        let child1 = CCFilterNode(title: "Title1", name: "name1", value: "value1")
        let child2 = CCFilterNode(title: "Title2", name: "name2", value: "value2")
        filterNode.add(child: child1)
        filterNode.add(child: child2)

        child1.isSelected = true
        XCTAssertFalse(filterNode.isSelected)
        child2.isSelected = true
        XCTAssertTrue(filterNode.isSelected)
    }

    func testReset() {
        let filterNode = CCFilterNode(title: "Title", name: "name", value: "value", isSelected: true)
        let child1 = CCFilterNode(title: "Title1", name: "name1", value: "value1", isSelected: true)
        let child2 = CCFilterNode(title: "Title2", name: "name2", value: "value2", isSelected: true)
        filterNode.add(child: child1)
        filterNode.add(child: child2)

        filterNode.reset()
        XCTAssertFalse(filterNode.isSelected || child1.isSelected || child2.isSelected)
    }
}
