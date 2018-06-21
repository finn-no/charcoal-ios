//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import FilterKit
import XCTest

class FilterDecodingTests: BaseTestCase {
    lazy var decodedTestFilter: Filter? = {
        return filterDataFromJSONFile(named: "DecodingTestFilter")
    }()

    func testFilterCanBeDecodedFromJSONData() {
        // Given
        let data = dataFromJSONFile(named: "DecodingTestFilter")

        // When
        let filter: Filter?

        if let data = data {
            filter = try? JSONDecoder().decode(Filter.self, from: data)
        } else {
            filter = nil
        }

        // Then
        XCTAssertNotNil(data)
        XCTAssertNotNil(filter)
    }

    func testFilterPropertiesAreDecodedWithExpectedValues() {
        // Given
        let filter = decodedTestFilter

        // When
        let expectedMarket = "car-norway"
        let expectedHits = 70070
        let expetedFilterTitle = "Biler i Norge"
        let expectedNumberOfRawFilterKeys = 23
        let expectedNumberOfFilterDataElements = 21 // raw filter keys 'market' and 'q' should not be parsed into filter data

        // Then
        XCTAssertNotNil(filter)
        XCTAssertEqual(filter?.market, expectedMarket)
        XCTAssertEqual(filter?.hits, expectedHits)
        XCTAssertEqual(filter?.filterTitle, expetedFilterTitle)
        XCTAssertEqual(filter?.rawFilterKeys.count, expectedNumberOfRawFilterKeys)
        XCTAssertEqual(filter?.filters.count, expectedNumberOfFilterDataElements)
    }

    func testFilterDataElementWithNestedQueriesWithFiltersIsDecodedWithExpectedValues() {
        // Given
        let filterDataElement = decodedTestFilter?.filterData(forKey: .make)

        // When
        let firstQueryElement = filterDataElement?.queries?.first

        // Then
        XCTAssertNotNil(filterDataElement)
        XCTAssertEqual(filterDataElement?.key, .make)
        XCTAssertEqual(filterDataElement?.isRange, false)
        XCTAssertEqual(filterDataElement?.title, "Merke")
        XCTAssertEqual(filterDataElement?.queries?.count, 86)

        XCTAssertNotNil(firstQueryElement)
        XCTAssertEqual(firstQueryElement?.title, "Abarth")
        XCTAssertEqual(firstQueryElement?.value, "0.8093")
        XCTAssertEqual(firstQueryElement?.totalResults, 6)

        XCTAssertNotNil(firstQueryElement?.filter)
        XCTAssertEqual(firstQueryElement?.filter?.title, "Modell")
        XCTAssertEqual(firstQueryElement?.filter?.queries.count, 3)

        XCTAssertNotNil(firstQueryElement?.filter?.queries.first)
        XCTAssertEqual(firstQueryElement?.filter?.queries.first?.title, "124 Spider")
        XCTAssertEqual(firstQueryElement?.filter?.queries.first?.value, "1.8093.2000412")
        XCTAssertEqual(firstQueryElement?.filter?.queries.first?.totalResults, 2)
    }

    func testFilterDataWithRangeIsDecodedWithExpectedValues() {
        // Given, When
        let filterDataElement = decodedTestFilter?.filterData(forKey: .numberOfSeats)

        // Then
        XCTAssertNotNil(filterDataElement)
        XCTAssertEqual(filterDataElement?.key, .numberOfSeats)
        XCTAssertEqual(filterDataElement?.title, "Antall seter")

        XCTAssertEqual(filterDataElement?.isRange, true)
        XCTAssertNil(filterDataElement?.queries)
    }

    func testFilterDataWithQueriesWithoutFilterIsDecodedWithExpectedValues() {
        // Given
        let filterDataElement = decodedTestFilter?.filterData(forKey: .transmission)

        // When
        let firstQueryElement = filterDataElement?.queries?.first

        // Then
        XCTAssertNotNil(filterDataElement)
        XCTAssertEqual(filterDataElement?.key, .transmission)
        XCTAssertEqual(filterDataElement?.title, "Girkasse")
        XCTAssertEqual(filterDataElement?.isRange, false)

        XCTAssertNotNil(firstQueryElement)
        XCTAssertEqual(firstQueryElement?.title, "Automat")
        XCTAssertEqual(firstQueryElement?.value, "2")
        XCTAssertEqual(firstQueryElement?.totalResults, 37283)
        XCTAssertNil(firstQueryElement?.filter)
    }
}
