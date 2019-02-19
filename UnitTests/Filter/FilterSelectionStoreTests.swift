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

    func testRemoveValuesForfilterWithSubfilters() {
        let filter = Filter(title: "Test", name: "filter", value: "value")
        let subfilterA = Filter(title: "subfilter A", name: "subfilterA", value: "valueB")
        let subfilterB = Filter(title: "subfilter B", name: "subfilterB", value: "valueB")

        filter.add(subfilter: subfilterA)
        filter.add(subfilter: subfilterB)

        store.setValue(from: filter)
        store.setValue(from: subfilterA)
        store.setValue(from: subfilterB)

        store.removeValues(for: filter)
        XCTAssertFalse(store.isSelected(filter))
        XCTAssertFalse(store.isSelected(subfilterA))
        XCTAssertFalse(store.isSelected(subfilterB))
    }

    func testToggleValueForfilter() {
        let filter = Filter(title: "Test", name: "test", value: "value")

        store.toggleValue(for: filter)
        XCTAssertTrue(store.isSelected(filter))

        store.toggleValue(for: filter)
        XCTAssertFalse(store.isSelected(filter))
    }

    func testIsSelected() {
        let filter = Filter(title: "Test", name: "filter", value: "value")
        let subfilterA = Filter(title: "subfilter A", name: "subfilterA", value: "valueB")
        let subfilterB = Filter(title: "subfilter B", name: "subfilterB", value: "valueB")

        filter.add(subfilter: subfilterA)
        filter.add(subfilter: subfilterB)

        store.setValue(from: subfilterA)
        XCTAssertTrue(store.isSelected(subfilterA))
        XCTAssertFalse(store.isSelected(filter))

        store.setValue(from: subfilterB)
        XCTAssertTrue(store.isSelected(subfilterB))
        XCTAssertTrue(store.isSelected(filter))
    }

    func testQueryItems() {
        let filter = Filter(title: "Test", name: "test", value: "value")
        store.setValue(from: filter)

        let expected = [URLQueryItem(name: "test", value: "value")]
        XCTAssertEqual(store.queryItems(for: filter), expected)
    }

    func testQueryItemsWithSubfilters() {
        let filter = Filter(title: "Test", name: "filter", value: "value")
        let subfilterA = Filter(title: "subfilter A", name: "subfilterA", value: "valueA")
        let subfilterB = Filter(title: "subfilter B", name: "subfilterB", value: "valueB")

        filter.add(subfilter: subfilterA)
        filter.add(subfilter: subfilterB)

        store.setValue(from: subfilterA)
        store.setValue(from: subfilterB)

        let expected = [
            URLQueryItem(name: "subfilterA", value: "valueA"),
            URLQueryItem(name: "subfilterB", value: "valueB"),
        ]

        XCTAssertEqual(store.queryItems(for: filter), expected)
    }

    func testTitles() {
        let filter = Filter(title: "Test", name: "test", value: "value")

        store.setValue(from: filter)
        XCTAssertEqual(store.titles(for: filter), ["Test"])
    }

    func testTitlesWithSubfilters() {
        let filter = Filter(title: "filter", name: "filter", value: "value")
        let subfilterA = Filter(title: "subfilter A", name: "subfilterA", value: "valueA")
        let subfilterB = Filter(title: "subfilter B", name: "subfilterB", value: "valueB")

        filter.add(subfilter: subfilterA)
        filter.add(subfilter: subfilterB)

        store.setValue(from: subfilterA)
        store.setValue(from: subfilterB)
        XCTAssertEqual(store.titles(for: filter), ["filter"])

        store.removeValues(for: subfilterB)
        XCTAssertEqual(store.titles(for: filter), ["subfilter A"])
    }

    func testIsValid() {
        let filter = Filter(title: "Test", name: "test", value: "value")

        store.setValue(from: filter)
        XCTAssertTrue(store.isValid(filter))
    }

    func testIsValidWithRange() {
        let filter = RangeFilter(title: "Range", name: "range")

        XCTAssertTrue(store.isValid(filter))

        store.setValue(100, for: filter.lowValueFilter)
        store.removeValues(for: filter.highValueFilter)
        XCTAssertTrue(store.isValid(filter))

        store.removeValues(for: filter.lowValueFilter)
        store.setValue(100, for: filter.highValueFilter)
        XCTAssertTrue(store.isValid(filter))

        store.setValue(100, for: filter.lowValueFilter)
        store.setValue(100, for: filter.highValueFilter)
        XCTAssertTrue(store.isValid(filter))

        store.setValue(100, for: filter.lowValueFilter)
        store.setValue(200, for: filter.highValueFilter)
        XCTAssertTrue(store.isValid(filter))

        store.setValue(300, for: filter.lowValueFilter)
        store.setValue(200, for: filter.highValueFilter)
        XCTAssertFalse(store.isValid(filter))
    }

    func testHasSelectedSubfilters() {
        let filter = Filter(title: "filter", name: "filter", value: "value")
        let subfilter = Filter(title: "subfilter A", name: "subfilterA", value: "valueA")
        filter.add(subfilter: subfilter)

        store.setValue(from: subfilter)
        XCTAssertTrue(store.hasSelectedSubfilters(for: filter))
    }

    func testSelectedSubfilters() {
        let filter = Filter(title: "filter", name: "filter", value: "value")
        let subfilter = Filter(title: "subfilter A", name: "subfilterA", value: "valueA")
        filter.add(subfilter: subfilter)

        store.setValue(from: subfilter)
        XCTAssertEqual(store.selectedSubfilters(for: filter).count, 1)
    }
}
