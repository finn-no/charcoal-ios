//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class FilterTests: XCTestCase {
    func testListFilter() {
        let subfilters = [
            Filter.list(title: "Child A", key: "childA"),
            Filter.list(title: "Child B", key: "childB"),
        ]
        let filter = Filter.list(
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

        switch filter.kind {
        case .list:
            break
        default:
            XCTFail("Incorrect filter kind")
        }
    }

    func testSearchFilter() {
        let filter = Filter.search(title: "Search", key: "q")

        XCTAssertEqual(filter.title, "Search")
        XCTAssertEqual(filter.key, "q")
        XCTAssertNil(filter.value)
        XCTAssertEqual(filter.numberOfResults, 0)
        XCTAssertEqual(filter.style, .normal)
        XCTAssertTrue(filter.subfilters.isEmpty)

        switch filter.kind {
        case .search:
            break
        default:
            XCTFail("Incorrect filter kind")
        }
    }

    func testInlineFilter() {
        let subfilters = [
            Filter.list(title: "Child A", key: "childA"),
            Filter.list(title: "Child B", key: "childB"),
        ]
        let filter = Filter.inline(title: "Inline", key: "inline", subfilters: subfilters)

        XCTAssertEqual(filter.title, "Inline")
        XCTAssertEqual(filter.key, "inline")
        XCTAssertNil(filter.value)
        XCTAssertEqual(filter.numberOfResults, 0)
        XCTAssertEqual(filter.style, .normal)
        XCTAssertEqual(filter.subfilters.count, 2)

        switch filter.kind {
        case .inline:
            break
        default:
            XCTFail("Incorrect filter kind")
        }
    }

    func testStepperFilter() {
        let filter = Filter.stepper(title: "Stepper", key: "stepper", style: .context)

        XCTAssertEqual(filter.title, "Stepper")
        XCTAssertEqual(filter.key, "stepper")
        XCTAssertNil(filter.value)
        XCTAssertEqual(filter.numberOfResults, 0)
        XCTAssertEqual(filter.style, .context)
        XCTAssertTrue(filter.subfilters.isEmpty)

        switch filter.kind {
        case .stepper:
            break
        default:
            XCTFail("Incorrect filter kind")
        }
    }

    func testRangeFilter() {
        let filter = Filter.range(
            title: "Range",
            key: "range",
            lowValueKey: "range_from",
            highValueKey: "range_to",
            style: .context
        )

        XCTAssertEqual(filter.title, "Range")
        XCTAssertEqual(filter.key, "range")
        XCTAssertNil(filter.value)
        XCTAssertEqual(filter.numberOfResults, 0)
        XCTAssertEqual(filter.style, .context)
        XCTAssertEqual(filter.subfilters.count, 2)

        switch filter.kind {
        case let .range(lowValueFilter, highValueFilter):
            XCTAssertEqual(lowValueFilter.key, "range_from")
            XCTAssertEqual(highValueFilter.key, "range_to")
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
            locationKey: "loc"
        )

        XCTAssertEqual(filter.title, "Map")
        XCTAssertEqual(filter.key, "map")
        XCTAssertNil(filter.value)
        XCTAssertEqual(filter.numberOfResults, 0)
        XCTAssertEqual(filter.style, .normal)
        XCTAssertEqual(filter.subfilters.count, 4)

        switch filter.kind {
        case let .map(latitudeFilter, longitudeFilter, radiusFilter, locationNameFilter):
            XCTAssertEqual(latitudeFilter.key, "lat")
            XCTAssertEqual(longitudeFilter.key, "lon")
            XCTAssertEqual(radiusFilter.key, "r")
            XCTAssertEqual(locationNameFilter.key, "loc")
        default:
            XCTFail("Incorrect filter kind")
        }
    }
}

// MARK: - TestDataDecoder

extension FilterTests: TestDataDecoder {
    func testContextFilterSetup() {
        guard let config = FilterMarket(market: "bap-sale") else { return }
        let filterSetup = filterDataFromJSONFile(named: "ContextFilterTestData")
        let filter = filterSetup?.filterContainer(using: config)
        let categoryFilter = filter?.rootFilter.subfilters.first(where: { $0.key == "category" })
        let shoeSizeFilter = filter?.rootFilter.subfilters.first(where: { $0.key == "shoe_size" })
        XCTAssertEqual(categoryFilter?.style, .normal)
        XCTAssertEqual(shoeSizeFilter?.style, .context)
    }
}
