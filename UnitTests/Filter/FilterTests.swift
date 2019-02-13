//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class FilterSelectionStoreTests: XCTestCase {
    private let store = FilterSelectionStore()

    override func tearDown() {
        store.clear()
        super.tearDown()
    }

    // MARK: - Tests

    func testValueForNode() {
        let node = CCFilterNode(title: "Test", name: "test", value: "valueA")

        store.select(node: node)
        XCTAssertEqual(store.value(for: node), "valueA")

        store.select(node: node, value: "valueB")
        XCTAssertEqual(store.value(for: node), "valueB")
    }

    func testClear() {
        let nodeA = CCFilterNode(title: "Test A", name: "testA", value: "valueB")
        let nodeB = CCFilterNode(title: "Test B", name: "testB", value: "valueB")

        store.select(node: nodeA)
        store.select(node: nodeB)

        XCTAssertTrue(store.isSelected(node: nodeA))
        XCTAssertTrue(store.isSelected(node: nodeB))

        store.clear()

        XCTAssertFalse(store.isSelected(node: nodeA))
        XCTAssertFalse(store.isSelected(node: nodeB))
    }

    func testSelect() {
        let node = CCFilterNode(title: "Test", name: "test", value: "value")

        store.select(node: node)
        XCTAssertTrue(store.isSelected(node: node))
    }

    func testDeselect() {
        let node = CCFilterNode(title: "Test", name: "test", value: "value")

        store.select(node: node)
        XCTAssertTrue(store.isSelected(node: node))

        store.deselect(node: node)
        XCTAssertFalse(store.isSelected(node: node))
    }

    func testToggle() {
        let node = CCFilterNode(title: "Test", name: "test", value: "value")

        store.toggle(node: node)
        XCTAssertTrue(store.isSelected(node: node))

        store.toggle(node: node)
        XCTAssertFalse(store.isSelected(node: node))
    }

    func testIsSelected() {
        let parent = CCFilterNode(title: "Test", name: "parent", value: "value")
        let childA = CCFilterNode(title: "Child A", name: "childA", value: "valueB")
        let childB = CCFilterNode(title: "Child B", name: "childB", value: "valueB")

        parent.add(child: childA)
        parent.add(child: childB)

        store.select(node: childA)
        XCTAssertTrue(store.isSelected(node: childA))
        XCTAssertFalse(store.isSelected(node: parent))

        store.select(node: childB)
        XCTAssertTrue(store.isSelected(node: childB))
        XCTAssertTrue(store.isSelected(node: parent))
    }

    func testQueryItems() {
        let node = CCFilterNode(title: "Test", name: "test", value: "value")
        store.select(node: node)

        let expected = [URLQueryItem(name: "test", value: "value")]
        XCTAssertEqual(store.queryItems(for: node), expected)
    }

    func testQueryItemsWithChildren() {
        let parent = CCFilterNode(title: "Test", name: "parent", value: "value")
        let childA = CCFilterNode(title: "Child A", name: "childA", value: "valueA")
        let childB = CCFilterNode(title: "Child B", name: "childB", value: "valueB")

        parent.add(child: childA)
        parent.add(child: childB)

        store.select(node: childA)
        store.select(node: childB)

        let expected = [
            URLQueryItem(name: "childA", value: "valueA"),
            URLQueryItem(name: "childB", value: "valueB"),
        ]

        XCTAssertEqual(store.queryItems(for: parent), expected)
    }

    func testTitles() {
        let node = CCFilterNode(title: "Test", name: "test", value: "value")

        store.select(node: node)
        XCTAssertEqual(store.titles(for: node), ["Test"])
    }

    func testTitlesWithChildren() {
        let parent = CCFilterNode(title: "Parent", name: "parent", value: "value")
        let childA = CCFilterNode(title: "Child A", name: "childA", value: "valueA")
        let childB = CCFilterNode(title: "Child B", name: "childB", value: "valueB")

        parent.add(child: childA)
        parent.add(child: childB)

        store.select(node: childA)
        store.select(node: childB)
        XCTAssertEqual(store.titles(for: parent), ["Parent"])

        store.deselect(node: childB)
        XCTAssertEqual(store.titles(for: parent), ["Child A"])
    }

    func testHasSelectedChildren() {
        let parent = CCFilterNode(title: "Parent", name: "parent", value: "value")
        let child = CCFilterNode(title: "Child A", name: "childA", value: "valueA")
        parent.add(child: child)

        store.select(node: child)
        XCTAssertTrue(store.hasSelectedChildren(node: parent))
    }

    func testSelectedChildren() {
        let parent = CCFilterNode(title: "Parent", name: "parent", value: "value")
        let child = CCFilterNode(title: "Child A", name: "childA", value: "valueA")
        parent.add(child: child)

        XCTAssertTrue(store.selectedChildren(for: parent).isEmpty)

        store.select(node: child)
        XCTAssertEqual(store.selectedChildren(for: parent).count, 1)
    }
}
