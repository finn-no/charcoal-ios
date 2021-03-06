//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
@testable import FINNSetup
import XCTest

class FilterSetupTests: XCTestCase, TestDataDecoder {
    private lazy var filterSetupDecodedUsingDecodable: FilterSetup? = {
        return filterDataFromJSONFile(named: "DecodingTestFilter")
    }()

    private lazy var filterSetupDecodedFromDictionary: FilterSetup? = {
        return filterDataFromDictionaryDecodedFromJSONFile(named: "DecodingTestFilter")
    }()

    func testFilterCanBeDecodedFromJSONData() {
        // Given
        let data = dataFromJSONFile(named: "DecodingTestFilter")

        // When
        let filter: FilterSetup?

        if let data = data {
            filter = try? JSONDecoder().decode(FilterSetup.self, from: data)
        } else {
            filter = nil
        }

        // Then
        XCTAssertNotNil(data)
        XCTAssertNotNil(filter)
    }

    func testFilterCanBeDecodedFromDictionaryData() {
        // Given
        let data = dataFromJSONFile(named: "DecodingTestFilter")

        // When
        let filter: FilterSetup?

        if let data = data, let decodedData = ((try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyHashable: Any]) as [AnyHashable: Any]??) {
            filter = FilterSetup.decode(from: decodedData)
        } else {
            filter = nil
        }

        // Then
        XCTAssertNotNil(data)
        XCTAssertNotNil(filter)
    }

    func testFilterPropertiesAreDecodedWithExpectedValues() {
        testFilterPropertiesAreDecodedWithExpectedValues(filterSetup: filterSetupDecodedUsingDecodable)
    }

    func testFilterFromDictionaryPropertiesAreDecodedWithExpectedValues() {
        testFilterPropertiesAreDecodedWithExpectedValues(filterSetup: filterSetupDecodedFromDictionary)
    }

    func testFilterDataElementWithNestedQueriesWithFiltersIsDecodedWithExpectedValues() {
        testFilterDataElementWithNestedQueriesWithFiltersIsDecodedWithExpectedValues(filterSetup: filterSetupDecodedUsingDecodable)
    }

    func testFilterDataFromDictionaryElementWithNestedQueriesWithFiltersIsDecodedWithExpectedValues() {
        testFilterDataElementWithNestedQueriesWithFiltersIsDecodedWithExpectedValues(filterSetup: filterSetupDecodedFromDictionary)
    }

    func testFilterDataWithRangeIsDecodedWithExpectedValues() {
        testFilterDataWithRangeIsDecodedWithExpectedValues(filterSetup: filterSetupDecodedUsingDecodable)
    }

    func testFilterDataFromDictionaryWithRangeIsDecodedWithExpectedValues() {
        testFilterDataWithRangeIsDecodedWithExpectedValues(filterSetup: filterSetupDecodedFromDictionary)
    }

    func testFilterDataWithQueriesWithoutFilterIsDecodedWithExpectedValues() {
        testFilterDataWithQueriesWithoutFilterIsDecodedWithExpectedValues(filterSetup: filterSetupDecodedUsingDecodable)
    }

    func testFilterDataFromDictionaryWithQueriesWithoutFilterIsDecodedWithExpectedValues() {
        testFilterDataWithQueriesWithoutFilterIsDecodedWithExpectedValues(filterSetup: filterSetupDecodedFromDictionary)
    }
}

private extension FilterSetupTests {
    func testFilterPropertiesAreDecodedWithExpectedValues(filterSetup: FilterSetup?) {
        // When
        let expectedMarket = "car-norway"
        let expectedHits = 63455
        let expetedFilterTitle = "Biler i Norge"
        let expectedNumberOfFilterDataElements = 22

        // Then
        XCTAssertNotNil(filterSetup)
        XCTAssertEqual(filterSetup?.market, expectedMarket)
        XCTAssertEqual(filterSetup?.hits, expectedHits)
        XCTAssertEqual(filterSetup?.filterTitle, expetedFilterTitle)
        XCTAssertEqual(filterSetup?.filters.count, expectedNumberOfFilterDataElements)
    }

    func testFilterDataElementWithNestedQueriesWithFiltersIsDecodedWithExpectedValues(filterSetup: FilterSetup?) {
        // Given
        let filterDataElement = filterSetup?.filterData(forKey: FilterKey.make)

        // When
        let firstQueryElement = filterDataElement?.queries.first

        // Then
        XCTAssertNotNil(filterDataElement)
        XCTAssertEqual(FilterKey(stringValue: filterDataElement?.parameterName ?? ""), .make)
        XCTAssertEqual(filterDataElement?.parameterName, "make")
        XCTAssertNotEqual(filterDataElement?.isRange, true)
        XCTAssertEqual(filterDataElement?.title, "Merke")
        XCTAssertEqual(filterDataElement?.queries.count, 84)

        XCTAssertNotNil(firstQueryElement)
        XCTAssertEqual(firstQueryElement?.title, "Abarth")
        XCTAssertEqual(firstQueryElement?.value, "0.8093")
        XCTAssertEqual(firstQueryElement?.totalResults, 9)

        XCTAssertNotNil(firstQueryElement?.filter)
        XCTAssertEqual(firstQueryElement?.filter?.parameterName, "model")
        XCTAssertEqual(firstQueryElement?.filter?.title, "Modell")
        XCTAssertEqual(firstQueryElement?.filter?.queries.count, 3)

        XCTAssertNotNil(firstQueryElement?.filter?.queries.first)
        XCTAssertEqual(firstQueryElement?.filter?.queries.first?.title, "124 Spider")
        XCTAssertEqual(firstQueryElement?.filter?.queries.first?.value, "1.8093.2000412")
        XCTAssertEqual(firstQueryElement?.filter?.queries.first?.totalResults, 2)
    }

    func testFilterDataWithRangeIsDecodedWithExpectedValues(filterSetup: FilterSetup?) {
        // Given, When
        let filterDataElement = filterSetup?.filterData(forKey: FilterKey.numberOfSeats)

        // Then
        XCTAssertNotNil(filterDataElement)
        XCTAssertEqual(FilterKey(stringValue: filterDataElement?.parameterName ?? ""), .numberOfSeats)
        XCTAssertEqual(filterDataElement?.parameterName, "number_of_seats")
        XCTAssertEqual(filterDataElement?.title, "Antall seter")

        XCTAssertEqual(filterDataElement?.isRange, true)
        XCTAssertEqual(filterDataElement?.queries.count, 0)
    }

    func testFilterDataWithQueriesWithoutFilterIsDecodedWithExpectedValues(filterSetup: FilterSetup?) {
        // Given
        let filterDataElement = filterSetup?.filterData(forKey: FilterKey.transmission)

        // When
        let firstQueryElement = filterDataElement?.queries.first

        // Then
        XCTAssertNotNil(filterDataElement)
        XCTAssertEqual(FilterKey(stringValue: filterDataElement?.parameterName ?? ""), .transmission)
        XCTAssertEqual(filterDataElement?.parameterName, "transmission")
        XCTAssertEqual(filterDataElement?.title, "Girkasse")
        XCTAssertNotEqual(filterDataElement?.isRange, true)

        XCTAssertNotNil(firstQueryElement)
        XCTAssertEqual(firstQueryElement?.title, "Automat")
        XCTAssertEqual(firstQueryElement?.value, "2")
        XCTAssertEqual(firstQueryElement?.totalResults, 33282)
        XCTAssertNil(firstQueryElement?.filter)
    }
}
