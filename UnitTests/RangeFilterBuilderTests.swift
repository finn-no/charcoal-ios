//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import FilterKit
import XCTest

class RangeFilterBuilderTests: BaseTestCase {
    lazy var decodedTestFilter: Filter? = {
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

        XCTAssertEqual(yearRangefilterInfo?.name, "Årsmodell")
        XCTAssertEqual(yearRangefilterInfo?.name, yearRangeFilterData?.title)
        XCTAssertEqual(yearRangefilterInfo?.lowValue, fromYear)
        XCTAssertEqual(yearRangefilterInfo?.highValue, currentYear)
        XCTAssertEqual(yearRangefilterInfo?.steps, currentYear - fromYear)
        XCTAssertEqual(yearRangefilterInfo?.unit, "år")
    }
}
