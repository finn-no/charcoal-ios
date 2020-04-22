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
        let filterA = Filter(title: "Test A", key: "testA", value: "valueB")
        let filterB = Filter(title: "Test B", key: "testB", value: "valueB")

        store.setValue(from: filterA)
        store.setValue(from: filterB)

        XCTAssertTrue(store.isSelected(filterA))
        XCTAssertTrue(store.isSelected(filterB))

        store.clear()

        XCTAssertFalse(store.isSelected(filterA))
        XCTAssertFalse(store.isSelected(filterB))
    }

    func testSetValueFromfilter() {
        let filter = Filter(title: "Test", key: "test", value: "valueA")

        store.setValue(from: filter)
        XCTAssertEqual(store.value(for: filter), "valueA")
    }

    func testSetValueForfilter() {
        let filter = Filter(title: "Test", key: "test")

        store.setValue("valueB", for: filter)
        XCTAssertEqual(store.value(for: filter), "valueB")

        store.setValue(10, for: filter)
        XCTAssertEqual(store.value(for: filter), 10)
    }

    func testRemoveValuesForfilter() {
        let filter = Filter(title: "Test", key: "test", value: "value")

        store.setValue(from: filter)
        XCTAssertTrue(store.isSelected(filter))

        store.removeValues(for: filter)
        XCTAssertFalse(store.isSelected(filter))
    }

    func testRemoveValuesForfilterWithSubfilters() {
        let subfilterA = Filter(title: "subfilter A", key: "subfilterA", value: "valueB")
        let subfilterB = Filter(title: "subfilter B", key: "subfilterB", value: "valueB")
        let subfilters = [subfilterA, subfilterB]
        let filter = Filter(title: "Test", key: "filter", value: "value", subfilters: subfilters)

        store.setValue(from: filter)
        store.setValue(from: subfilterA)
        store.setValue(from: subfilterB)

        store.removeValues(for: filter)
        XCTAssertFalse(store.isSelected(filter))
        XCTAssertFalse(store.isSelected(subfilterA))
        XCTAssertFalse(store.isSelected(subfilterB))
    }

    func testToggleValueForfilter() {
        let filter = Filter(title: "Test", key: "test", value: "value")

        store.toggleValue(for: filter)
        XCTAssertTrue(store.isSelected(filter))

        store.toggleValue(for: filter)
        XCTAssertFalse(store.isSelected(filter))
    }

    func testIsSelected() {
        let subfilterA = Filter(title: "subfilter A", key: "subfilterA", value: "valueB")
        let subfilterB = Filter(title: "subfilter B", key: "subfilterB", value: "valueB")
        let subfilters = [subfilterA, subfilterB]
        let filter = Filter(title: "Test", key: "filter", value: "value", subfilters: subfilters)

        store.setValue(from: subfilterA)
        XCTAssertTrue(store.isSelected(subfilterA))
        XCTAssertFalse(store.isSelected(filter))

        store.setValue(from: subfilterB)
        XCTAssertTrue(store.isSelected(subfilterB))
        XCTAssertFalse(store.isSelected(filter))
    }

    func testIsSelectedWithRanges() {
        let config = RangeFilterConfiguration.makeStub()
        let filter = Filter.range(title: "Range", key: "range", lowValueKey: "range_from", highValueKey: "range_to", config: config)
        let lowValueFilter = filter.subfilters[0]
        let highValueFilter = filter.subfilters[1]

        store.setValue(10, for: lowValueFilter)
        store.removeValues(for: highValueFilter)
        XCTAssertTrue(store.isSelected(lowValueFilter))
        XCTAssertFalse(store.isSelected(highValueFilter))
        XCTAssertTrue(store.isSelected(filter))

        store.removeValues(for: lowValueFilter)
        store.setValue(20, for: highValueFilter)
        XCTAssertFalse(store.isSelected(lowValueFilter))
        XCTAssertTrue(store.isSelected(highValueFilter))
        XCTAssertTrue(store.isSelected(filter))

        store.setValue(10, for: lowValueFilter)
        store.setValue(20, for: highValueFilter)
        XCTAssertTrue(store.isSelected(lowValueFilter))
        XCTAssertTrue(store.isSelected(highValueFilter))
        XCTAssertTrue(store.isSelected(filter))
    }

    func testIsSelectedWithMap() {
        let filter = Filter.map(title: "Map", key: "map", latitudeKey: "lat", longitudeKey: "lon", radiusKey: "r", locationKey: "loc", bboxKey: "bbox", polygonKey: "polylocation")

        store.setValue(10, for: filter.subfilters[2])
        XCTAssertTrue(store.isSelected(filter.subfilters[2]))
        XCTAssertTrue(store.isSelected(filter))
    }

    func testQueryItemsForFilter() {
        let filter = Filter(title: "Test", key: "test", value: "value")
        store.setValue(from: filter)

        let expected = [URLQueryItem(name: "test", value: "value")]
        XCTAssertEqual(store.queryItems(for: filter), expected)
    }

    func testQueryItemsForFiltersWithSubfilters() {
        let subfilterA = Filter(title: "subfilter A", key: "subfilterA", value: "valueA")
        let subfilterB = Filter(title: "subfilter B", key: "subfilterB", value: "valueB")
        let subfilters = [subfilterA, subfilterB]
        let filter = Filter(title: "Test", key: "filter", value: "value", subfilters: subfilters)

        store.setValue(from: subfilterA)
        store.setValue(from: subfilterB)

        let expected = [
            URLQueryItem(name: "subfilterA", value: "valueA"),
            URLQueryItem(name: "subfilterB", value: "valueB"),
        ]

        XCTAssertEqual(store.queryItems(for: filter), expected)
    }

    func testQueryItemsForFilterContainer() {
        let filter = Filter(title: "Test", key: "test", value: "value")
        let container = FilterContainer(rootFilters: [filter], freeTextFilter: nil, inlineFilter: nil, numberOfResults: 0)

        store.setValue(from: filter)

        let expected = [URLQueryItem(name: "test", value: "value")]
        XCTAssertEqual(store.queryItems(for: container), expected)
    }

    func testTitles() {
        let filter = Filter(title: "Test", key: "test", value: "value")

        store.setValue(from: filter)
        XCTAssertEqual(store.titles(for: filter), [SelectionTitle(value: "Test")])
    }

    func testTitlesWithSubfilters() {
        let subfilterA = Filter(title: "subfilter A", key: "subfilterA", value: "valueA")
        let subfilterB = Filter(title: "subfilter B", key: "subfilterB", value: "valueB")
        let subfilters = [subfilterA, subfilterB]
        let filter = Filter(title: "filter", key: "filter", value: "value", subfilters: subfilters)

        store.setValue(from: subfilterA)
        store.setValue(from: subfilterB)
        XCTAssertEqual(store.titles(for: filter), [SelectionTitle(value: "subfilter A"), SelectionTitle(value: "subfilter B")])

        store.removeValues(for: subfilterB)
        XCTAssertEqual(store.titles(for: filter), [SelectionTitle(value: "subfilter A")])
    }

    func testTitlesWithRanges() {
        let config = RangeFilterConfiguration.makeStub()
        let filter = Filter.range(title: "Range", key: "range", lowValueKey: "from", highValueKey: "to", config: config)
        let lowValueFilter = filter.subfilters[0]
        let highValueFilter = filter.subfilters[1]

        XCTAssertTrue(store.titles(for: filter).isEmpty)

        store.setValue(10, for: lowValueFilter)
        store.removeValues(for: highValueFilter)
        XCTAssertEqual(store.titles(for: filter), [
            SelectionTitle(value: "Fra 10 kr", accessibilityLabel: "Fra 10 kroner"),
        ])

        store.removeValues(for: lowValueFilter)
        store.setValue(100, for: highValueFilter)
        XCTAssertEqual(store.titles(for: filter), [
            SelectionTitle(value: "Opptil 100 kr", accessibilityLabel: "Opptil 100 kroner"),
        ])

        store.setValue(10, for: lowValueFilter)
        store.setValue(100, for: highValueFilter)
        XCTAssertEqual(store.titles(for: filter), [
            SelectionTitle(value: "10 - 100 kr", accessibilityLabel: "Fra 10 Opptil 100 kroner"),
        ])
    }

    func testTitlesWithSteppers() {
        let config = StepperFilterConfiguration(minimumValue: 0, maximumValue: 10, unit: "stk.")
        let filter = Filter.stepper(title: "Stepper", key: "stepper", config: config)

        store.setValue(10, for: filter)
        XCTAssertEqual(store.titles(for: filter), [SelectionTitle(value: "10+")])
    }

    func testTitlesWithMap() {
        let filter = Filter.map(title: "Map", key: "map", latitudeKey: "lat", longitudeKey: "lon", radiusKey: "r", locationKey: "loc", bboxKey: "bbox", polygonKey: "polylocation")
        XCTAssertTrue(store.titles(for: filter).isEmpty)

        store.setValue(10, for: filter.subfilters[2])
        XCTAssertEqual(store.titles(for: filter), [SelectionTitle(value: "10 m")])
    }

    func testIsValid() {
        let filter = Filter(title: "Test", key: "test", value: "value")

        store.setValue(from: filter)
        XCTAssertTrue(store.isValid(filter))
    }

    func testIsValidWithRange() {
        let config = RangeFilterConfiguration.makeStub()
        let filter = Filter.range(title: "Range", key: "range", lowValueKey: "range_from", highValueKey: "range_to", config: config)
        let lowValueFilter = filter.subfilters[0]
        let highValueFilter = filter.subfilters[1]

        XCTAssertTrue(store.isValid(filter))

        store.setValue(100, for: lowValueFilter)
        store.removeValues(for: highValueFilter)
        XCTAssertTrue(store.isValid(filter))

        store.removeValues(for: lowValueFilter)
        store.setValue(100, for: highValueFilter)
        XCTAssertTrue(store.isValid(filter))

        store.setValue(100, for: lowValueFilter)
        store.setValue(100, for: highValueFilter)
        XCTAssertTrue(store.isValid(filter))

        store.setValue(100, for: lowValueFilter)
        store.setValue(200, for: highValueFilter)
        XCTAssertTrue(store.isValid(filter))

        store.setValue(300, for: lowValueFilter)
        store.setValue(200, for: highValueFilter)
        XCTAssertFalse(store.isValid(filter))
    }

    func testHasSelectedSubfilters() {
        let subfilter = Filter(title: "subfilter A", key: "subfilterA", value: "valueA")
        let filter = Filter(title: "filter", key: "filter", value: "value", subfilters: [subfilter])

        store.setValue(from: subfilter)
        XCTAssertTrue(store.hasSelectedSubfilters(for: filter))
    }

    func testHasSelectedSubfiltersWithPredicate() {
        let subfilter = Filter(title: "subfilter A", key: "subfilterA", value: "valueA")
        let filter = Filter(title: "filter", key: "filter", value: "value", subfilters: [subfilter])

        store.setValue(from: subfilter)
        XCTAssertTrue(store.hasSelectedSubfilters(for: filter, where: { $0.key == "subfilterA" }))
        XCTAssertFalse(store.hasSelectedSubfilters(for: filter, where: { $0.key == "subfilterB" }))
    }

    func testSelectedSubfilters() {
        let subfilter = Filter(title: "subfilter A", key: "subfilterA", value: "valueA")
        let filter = Filter(title: "filter", key: "filter", value: "value", subfilters: [subfilter])

        store.setValue(from: subfilter)
        XCTAssertEqual(store.selectedSubfilters(for: filter).count, 1)
    }

    func testSelectedSubfiltersWithPredicate() {
        let subfilter = Filter(title: "subfilter A", key: "subfilterA", value: "valueA")
        let filter = Filter(title: "filter", key: "filter", value: "value", subfilters: [subfilter])

        store.setValue(from: subfilter)
        XCTAssertEqual(store.selectedSubfilters(for: filter, where: { $0.key == "subfilterA" }).count, 1)
        XCTAssertTrue(store.selectedSubfilters(for: filter, where: { $0.key == "subfilterB" }).isEmpty)
    }

    func testSyncSelection() {
        let rootFilters = [
            Filter(title: "subfilter A", key: "subfilterA", value: "valueA"),
            Filter(title: "subfilter B", key: "subfilterB", value: "valueB"),
        ]
        let inlineFilter = Filter.inline(
            title: "Inline",
            key: "inline",
            subfilters: [
                Filter(title: "subfilter C", key: "subfilterC", value: "valueC"),
                Filter(title: "subfilter D", key: "subfilterD", value: "valueD"),
            ]
        )
        let queryItems = Set([
            URLQueryItem(name: "filter", value: "value"),
            URLQueryItem(name: "subfilterB", value: "valueB"),
            URLQueryItem(name: "subfilterD", value: "valueD"),
        ])

        let container = FilterContainer(rootFilters: rootFilters, freeTextFilter: nil, inlineFilter: inlineFilter, numberOfResults: 0)

        store.set(selection: queryItems)
        store.syncSelection(with: container)

        XCTAssertFalse(store.isSelected(rootFilters[0]))
        XCTAssertTrue(store.isSelected(rootFilters[1]))
        XCTAssertFalse(store.isSelected(inlineFilter))
        XCTAssertFalse(store.isSelected(inlineFilter.subfilters[0]))
        XCTAssertTrue(store.isSelected(inlineFilter.subfilters[1]))
        XCTAssertEqual(store.queryItems(for: container).count, 2)
    }
}
