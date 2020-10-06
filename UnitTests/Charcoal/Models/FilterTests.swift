//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
@testable import FINNSetup
import XCTest

final class FilterTests: XCTestCase {
    func testListFilter() {
        let subfilters = [
            Filter(title: "Child A", key: "childA"),
            Filter(title: "Child B", key: "childB"),
        ]
        let filter = Filter(
            title: "List",
            key: "list",
            value: "value",
            numberOfResults: 10,
            style: .context,
            subfilters: subfilters
        )

        XCTAssertEqual(filter.title, "List")
        XCTAssertEqual(filter.key, "list")
        XCTAssertEqual(filter.value, "value")
        XCTAssertEqual(filter.numberOfResults, 10)
        XCTAssertEqual(filter.style, .context)
        XCTAssertEqual(filter.subfilters.count, 2)
        XCTAssertEqual(filter.kind, .standard)
    }

    func testFreeTextFilter() {
        let filter = Filter.freeText(title: "Search", key: "q")

        XCTAssertEqual(filter.title, "Search")
        XCTAssertEqual(filter.key, "q")
        XCTAssertNil(filter.value)
        XCTAssertEqual(filter.numberOfResults, 0)
        XCTAssertEqual(filter.style, .normal)
        XCTAssertTrue(filter.subfilters.isEmpty)
        XCTAssertEqual(filter.kind, .freeText)
    }

    func testInlineFilter() {
        let subfilters = [
            Filter(title: "Child A", key: "childA"),
            Filter(title: "Child B", key: "childB"),
        ]
        let filter = Filter.inline(title: "Inline", key: "inline", subfilters: subfilters)

        XCTAssertEqual(filter.title, "Inline")
        XCTAssertEqual(filter.key, "inline")
        XCTAssertNil(filter.value)
        XCTAssertEqual(filter.numberOfResults, 0)
        XCTAssertEqual(filter.style, .normal)
        XCTAssertEqual(filter.subfilters.count, 2)
        XCTAssertEqual(filter.kind, .standard)
    }

    func testStepperFilter() {
        let config = StepperFilterConfiguration(minimumValue: 0, maximumValue: 10, unit: "stk.")
        let filter = Filter.stepper(title: "Stepper", key: "stepper", config: config, style: .context)

        XCTAssertEqual(filter.title, "Stepper")
        XCTAssertEqual(filter.key, "stepper")
        XCTAssertNil(filter.value)
        XCTAssertEqual(filter.numberOfResults, 0)
        XCTAssertEqual(filter.style, .context)
        XCTAssertTrue(filter.subfilters.isEmpty)
        XCTAssertEqual(filter.kind, Filter.Kind.stepper(config: config))
    }

    func testExternalFilter() {
        let filter = Filter.external(
            title: "External",
            key: "external",
            value: "test",
            numberOfResults: 3,
            style: .context
        )

        XCTAssertEqual(filter.title, "External")
        XCTAssertEqual(filter.key, "external")
        XCTAssertEqual(filter.value, "test")
        XCTAssertEqual(filter.numberOfResults, 3)
        XCTAssertEqual(filter.style, .context)
        XCTAssertTrue(filter.subfilters.isEmpty)
        XCTAssertEqual(filter.kind, .external)
    }

    func testRangeFilter() {
        let config = RangeFilterConfiguration.makeStub()

        let filter = Filter.range(
            title: "Range",
            key: "range",
            lowValueKey: "range_from",
            highValueKey: "range_to",
            config: config,
            style: .context
        )

        XCTAssertEqual(filter.title, "Range")
        XCTAssertEqual(filter.key, "range")
        XCTAssertNil(filter.value)
        XCTAssertEqual(filter.numberOfResults, 0)
        XCTAssertEqual(filter.style, .context)
        XCTAssertEqual(filter.subfilters.count, 2)

        switch filter.kind {
        case let .range(lowValueFilter, highValueFilter, rangeConfig):
            XCTAssertEqual(lowValueFilter.key, "range_from")
            XCTAssertEqual(highValueFilter.key, "range_to")
            XCTAssertEqual(rangeConfig, config)
        default:
            XCTFail("Incorrect filter kind")
        }
    }

    func testMapFilter() {
        let filter = Filter.map(
            title: "Map",
            key: "map",
            latitudeKey: "lat",
            longitudeKey: "lon",
            radiusKey: "r",
            locationKey: "loc",
            bboxKey: "bbox",
            polygonKey: "polylocation"
        )

        XCTAssertEqual(filter.title, "Map")
        XCTAssertEqual(filter.key, "map")
        XCTAssertNil(filter.value)
        XCTAssertEqual(filter.numberOfResults, 0)
        XCTAssertEqual(filter.style, .normal)
        XCTAssertEqual(filter.subfilters.count, 6)

        switch filter.kind {
        case let .map(latitudeFilter, longitudeFilter, radiusFilter, locationNameFilter, bboxFilter, polygonFilter):
            XCTAssertEqual(latitudeFilter.key, "lat")
            XCTAssertEqual(longitudeFilter.key, "lon")
            XCTAssertEqual(radiusFilter.key, "r")
            XCTAssertEqual(locationNameFilter.key, "loc")
            XCTAssertEqual(bboxFilter!.key, "bbox")
            XCTAssertEqual(polygonFilter!.key, "polylocation")
        default:
            XCTFail("Incorrect filter kind")
        }
    }

    func testEquatable() {
        var filter1 = Filter(title: "Title1", key: "key1")
        var filter2 = Filter(title: "Title1", key: "key1")
        XCTAssertEqual(filter1, filter2)

        filter1 = Filter(title: "Title1", key: "key1")
        filter2 = Filter(title: "Title1", key: "key1", value: "value1")
        XCTAssertNotEqual(filter1, filter2)

        filter1 = Filter(title: "Title1", key: "key1")
        filter2 = Filter(title: "Title1", key: "key2")
        XCTAssertNotEqual(filter1, filter2)

        filter1 = Filter(title: "Title1", key: "key1", value: "value1")
        filter2 = Filter(title: "Title1", key: "key1", value: "value2")
        XCTAssertNotEqual(filter1, filter2)

        filter1 = Filter(title: "Title1", key: "key1", value: "value1")
        filter2 = Filter(title: "Title1", key: "key1", value: "value1")
        XCTAssertEqual(filter1, filter2)
    }

    func testMergeFilters() {
        let filter1 = Filter(title: "Title1", key: "key1", subfilters: [
            Filter(title: "Subtitle1", key: "subkey1"),
            Filter(title: "Subtitle3", key: "subkey3"),
        ])

        let filter2 = Filter(title: "Title1", key: "key1", subfilters: [
            Filter(title: "Subtitle1", key: "subkey1"),
            Filter(title: "Subtitle2", key: "subkey2"),
        ])

        filter1.mergeSubfilters(with: filter2)
        XCTAssertEqual(filter1.subfilters.count, 3)
        XCTAssertEqual(filter1.subfilter(at: 2)?.key, "subkey3")
    }
}

// MARK: - TestDataDecoder

extension FilterTests: TestDataDecoder {
    func testContextFilterSetup() {
        guard let config = FilterMarket(market: "bap-sale") else { return }
        let filterSetup = filterDataFromJSONFile(named: "ContextFilterTestData")
        let filter = filterSetup?.filterContainer(using: config)
        let shoeSizeFilter = filter?.rootFilters.first(where: { $0.key == "shoe_size" })
        XCTAssertEqual(shoeSizeFilter?.style, .context)
    }

    func testRootFilterWithoutSubfiltersShouldNotShow() {
        guard let config = FilterMarket(market: "bap-sale") else { return }
        let filterSetup = filterDataFromJSONFile(named: "ContextFilterTestData")
        let filter = filterSetup?.filterContainer(using: config)
        let categoryFilter = filter?.rootFilters.first(where: { $0.key == "category" })
        XCTAssertNil(categoryFilter)
    }
}
