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

    func testClear() {
        let nodeA = Filter(title: "Test A", name: "testA", value: "valueB")
        let nodeB = Filter(title: "Test B", name: "testB", value: "valueB")

        store.setValue(from: nodeA)
        store.setValue(from: nodeB)

        XCTAssertTrue(store.isSelected(nodeA))
        XCTAssertTrue(store.isSelected(nodeB))

        store.clear()

        XCTAssertFalse(store.isSelected(nodeA))
        XCTAssertFalse(store.isSelected(nodeB))
    }

    func testSetValueFromNode() {
        let node = Filter(title: "Test", name: "test", value: "valueA")

        store.setValue(from: node)
        XCTAssertEqual(store.value(for: node), "valueA")
    }

    func testSetValueForNode() {
        let node = Filter(title: "Test", name: "test")

        store.setValue("valueB", for: node)
        XCTAssertEqual(store.value(for: node), "valueB")

        store.setValue(10, for: node)
        XCTAssertEqual(store.value(for: node), 10)
    }

    func testRemoveValuesForNode() {
        let node = Filter(title: "Test", name: "test", value: "value")

        store.setValue(from: node)
        XCTAssertTrue(store.isSelected(node))

        store.removeValues(for: node)
        XCTAssertFalse(store.isSelected(node))
    }

    func testRemoveValuesForNodeWithChildren() {
        let parent = Filter(title: "Test", name: "parent", value: "value")
        let childA = Filter(title: "Child A", name: "childA", value: "valueB")
        let childB = Filter(title: "Child B", name: "childB", value: "valueB")

        parent.add(child: childA)
        parent.add(child: childB)

        store.setValue(from: parent)
        store.setValue(from: childA)
        store.setValue(from: childB)

        store.removeValues(for: parent)
        XCTAssertFalse(store.isSelected(parent))
        XCTAssertFalse(store.isSelected(childA))
        XCTAssertFalse(store.isSelected(childB))
    }

    func testToggleValueForNode() {
        let node = Filter(title: "Test", name: "test", value: "value")

        store.toggleValue(for: node)
        XCTAssertTrue(store.isSelected(node))

        store.toggleValue(for: node)
        XCTAssertFalse(store.isSelected(node))
    }

    func testIsSelected() {
        let parent = Filter(title: "Test", name: "parent", value: "value")
        let childA = Filter(title: "Child A", name: "childA", value: "valueB")
        let childB = Filter(title: "Child B", name: "childB", value: "valueB")

        parent.add(child: childA)
        parent.add(child: childB)

        store.setValue(from: childA)
        XCTAssertTrue(store.isSelected(childA))
        XCTAssertFalse(store.isSelected(parent))

        store.setValue(from: childB)
        XCTAssertTrue(store.isSelected(childB))
        XCTAssertTrue(store.isSelected(parent))
    }

    func testQueryItems() {
        let node = Filter(title: "Test", name: "test", value: "value")
        store.setValue(from: node)

        let expected = [URLQueryItem(name: "test", value: "value")]
        XCTAssertEqual(store.queryItems(for: node), expected)
    }

    func testQueryItemsWithChildren() {
        let parent = Filter(title: "Test", name: "parent", value: "value")
        let childA = Filter(title: "Child A", name: "childA", value: "valueA")
        let childB = Filter(title: "Child B", name: "childB", value: "valueB")

        parent.add(child: childA)
        parent.add(child: childB)

        store.setValue(from: childA)
        store.setValue(from: childB)

        let expected = [
            URLQueryItem(name: "childA", value: "valueA"),
            URLQueryItem(name: "childB", value: "valueB"),
        ]

        XCTAssertEqual(store.queryItems(for: parent), expected)
    }

    func testTitles() {
        let node = Filter(title: "Test", name: "test", value: "value")

        store.setValue(from: node)
        XCTAssertEqual(store.titles(for: node), ["Test"])
    }

    func testTitlesWithChildren() {
        let parent = Filter(title: "Parent", name: "parent", value: "value")
        let childA = Filter(title: "Child A", name: "childA", value: "valueA")
        let childB = Filter(title: "Child B", name: "childB", value: "valueB")

        parent.add(child: childA)
        parent.add(child: childB)

        store.setValue(from: childA)
        store.setValue(from: childB)
        XCTAssertEqual(store.titles(for: parent), ["Parent"])

        store.removeValues(for: childB)
        XCTAssertEqual(store.titles(for: parent), ["Child A"])
    }

    func testHasSelectedChildren() {
        let parent = Filter(title: "Parent", name: "parent", value: "value")
        let child = Filter(title: "Child A", name: "childA", value: "valueA")
        parent.add(child: child)

        store.setValue(from: child)
        XCTAssertTrue(store.hasSelectedChildren(node: parent))
    }

    func testSelectedChildren() {
        let parent = Filter(title: "Parent", name: "parent", value: "value")
        let child = Filter(title: "Child A", name: "childA", value: "valueA")
        parent.add(child: child)

        store.setValue(from: child)
        XCTAssertEqual(store.selectedChildren(for: parent).count, 1)
    }
}
