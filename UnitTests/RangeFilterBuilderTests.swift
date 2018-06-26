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
        let steps: Int?
        if let filterInfo = yearRangefilterInfo {
            steps = (currentYear + filterInfo.additionalUpperBoundOffset) - (fromYear - filterInfo.additonalLowerBoundOffset)
        } else {
            steps = nil
        }

        // Then
        XCTAssertNotNil(yearRangeFilterData)
        XCTAssertNotNil(yearRangefilterInfo)
        XCTAssertNotNil(steps)

        XCTAssertEqual(yearRangefilterInfo?.name, "Årsmodell")
        XCTAssertEqual(yearRangefilterInfo?.name, yearRangeFilterData?.title)
        XCTAssertEqual(yearRangefilterInfo?.lowValue, fromYear)
        XCTAssertEqual(yearRangefilterInfo?.highValue, currentYear)
        XCTAssertEqual(yearRangefilterInfo?.steps, steps)
        XCTAssertEqual(yearRangefilterInfo?.unit, "år")
    }

    func testCalculatingStepsByIncrements() {
        // Given
        let lowValue = 1_000_000
        let highValue = 10_000_000
        let rangeBoundsOffsets = (100_000, 100_000)
        let increments = 10_000

        // When
        let calculatedSteps = RangeFilterInfoBuilder.calculatedStepsForRange(withLowValue: lowValue, highValue: highValue, rangeBoundsOffsets: rangeBoundsOffsets, incrementedBy: increments)

        // Then
        XCTAssertEqual(calculatedSteps, 920)
    }
}
