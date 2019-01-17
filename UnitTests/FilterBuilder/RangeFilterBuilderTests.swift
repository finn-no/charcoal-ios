//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

class RangeFilterBuilderTests: XCTestCase, TestDataDecoder {
    lazy var decodedTestFilter: FilterSetup? = {
        return filterDataFromJSONFile(named: "RangeFilterBuilderTestsFilter")
    }()

    func testRangeFilterBuilderBuildsExpectedRangeFilterInfo() {
        // Given
        let filter = decodedTestFilter
        let builder: RangeFilterInfoBuilder?
        if let filter = filter {
            builder = RangeFilterInfoBuilder(filter: filter)
        } else {
            builder = nil
        }

        // When
        let yearRangeFilterData = filter?.filterData(forKey: .year)
        let yearRangefilterInfo: RangeFilterInfoType?
        if let yearRangeFilterData = yearRangeFilterData {
            yearRangefilterInfo = builder?.buildRangeFilterInfo(from: yearRangeFilterData)
        } else {
            yearRangefilterInfo = nil
        }
        let fromYear = 1950
        let currentYear = Calendar.current.component(.year, from: Date())

        // Then
        XCTAssertNotNil(yearRangeFilterData)
        XCTAssertNotNil(yearRangefilterInfo)

        XCTAssertEqual(yearRangefilterInfo?.title, "Årsmodell")
        XCTAssertEqual(yearRangefilterInfo?.title, yearRangeFilterData?.title)
        XCTAssertEqual(yearRangefilterInfo?.sliderInfo.minimumValue, fromYear)
        XCTAssertEqual(yearRangefilterInfo?.sliderInfo.maximumValue, currentYear)
        XCTAssertEqual(yearRangefilterInfo?.sliderInfo.values.count, currentYear - fromYear - 1)
        XCTAssertEqual(yearRangefilterInfo?.unit, "år")
    }
}
