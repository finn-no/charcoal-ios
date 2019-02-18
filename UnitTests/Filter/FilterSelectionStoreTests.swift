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
        let filterA = Filter(title: "Test A", name: "testA", value: "valueB")
        let filterB = Filter(title: "Test B", name: "testB", value: "valueB")

        store.setValue(from: filterA)
        store.setValue(from: filterB)

        XCTAssertTrue(store.isSelected(filterA))
        XCTAssertTrue(store.isSelected(filterB))

        store.clear()

        XCTAssertFalse(store.isSelected(filterA))
        XCTAssertFalse(store.isSelected(filterB))
    }

    func testSetValueFromfilter() {
        let filter = Filter(title: "Test", name: "test", value: "valueA")

        store.setValue(from: filter)
        XCTAssertEqual(store.value(for: filter), "valueA")
    }

    func testSetValueForfilter() {
        let filter = Filter(title: "Test", name: "test")

        store.setValue("valueB", for: filter)
        XCTAssertEqual(store.value(for: filter), "valueB")

        store.setValue(10, for: filter)
        XCTAssertEqual(store.value(for: filter), 10)
    }

    func testRemoveValuesForfilter() {
        let filter = Filter(title: "Test", name: "test", value: "value")

        store.setValue(from: filter)
        XCTAssertTrue(store.isSelected(filter))

        store.removeValues(for: filter)
        XCTAssertFalse(store.isSelected(filter))
    }

    func testRemoveValuesForfilterWithChildren() {
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

    func testToggleValueForfilter() {
        let filter = Filter(title: "Test", name: "test", value: "value")

        store.toggleValue(for: filter)
        XCTAssertTrue(store.isSelected(filter))

        store.toggleValue(for: filter)
        XCTAssertFalse(store.isSelected(filter))
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
        let filter = Filter(title: "Test", name: "test", value: "value")
        store.setValue(from: filter)

        let expected = [URLQueryItem(name: "test", value: "value")]
        XCTAssertEqual(store.queryItems(for: filter), expected)
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
        let filter = Filter(title: "Test", name: "test", value: "value")

        store.setValue(from: filter)
        XCTAssertEqual(store.titles(for: filter), ["Test"])
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
        XCTAssertTrue(store.hasSelectedChildren(parent))
    }

    func testSelectedChildren() {
        let parent = Filter(title: "Parent", name: "parent", value: "value")
        let child = Filter(title: "Child A", name: "childA", value: "valueA")
        parent.add(child: child)

        store.setValue(from: child)
        XCTAssertEqual(store.selectedChildren(for: parent).count, 1)
    }
}
