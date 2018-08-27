//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import FilterKit
import XCTest

class RangeFilterBuilderTests: BaseDecodingTestCase {
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
            steps = (currentYear + filterInfo.additionalUpperBoundOffset) - (fromYear - filterInfo.additionalLowerBoundOffset)
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

    func testCreatingDefaultReferenceValues() {
        // Given
        let lowValue = 0
        let highValue = 30000

        // When
        let referenceValues = RangeFilterInfoBuilder.defaultReferenceValuesForRange(withLowValue: lowValue, andHighValue: highValue)

        // Then
        guard referenceValues.count == 3 else {
            XCTAssertFalse(true, "There should be 3 reference values in the array")
            return
        }

        XCTAssertEqual(referenceValues[0], 0)
        XCTAssertEqual(referenceValues[1], 15000)
        XCTAssertEqual(referenceValues[2], 30000)
    }

    func testCreatingDefaultReferenceWhenValuesRepresentYears() {
        // Given
        let lowValue = 1950
        let highValue = 2018

        // When
        let referenceValues = RangeFilterInfoBuilder.defaultReferenceValuesForRange(withLowValue: lowValue, andHighValue: highValue)

        // Then
        guard referenceValues.count == 3 else {
            XCTAssertFalse(true, "There should be 3 reference values in the array")
            return
        }

        XCTAssertEqual(referenceValues[0], 1950)
        XCTAssertEqual(referenceValues[1], 1984)
        XCTAssertEqual(referenceValues[2], 2018)
    }

    func testCalculatingStepsByIncrement() {
        // Given
        let lowValue = 1_000_000
        let highValue = 10_000_000
        let rangeBoundsOffsets = (100_000, 100_000)
        let increments = 10000

        // When
        let calculatedSteps = RangeFilterInfoBuilder.calculatedStepsForRange(withLowValue: lowValue, highValue: highValue, rangeBoundsOffsets: rangeBoundsOffsets, incrementedBy: increments)

        // Then
        XCTAssertEqual(calculatedSteps, 920)
    }

    func testCalculatingStepsByIncrementWhenValuesRepresentYears() {
        // Given
        let lowValue = 1950
        let highValue = 2018
        let rangeBoundsOffsets = (1, 1)
        let increments = 1

        // When
        let calculatedSteps = RangeFilterInfoBuilder.calculatedStepsForRange(withLowValue: lowValue, highValue: highValue, rangeBoundsOffsets: rangeBoundsOffsets, incrementedBy: increments)

        // Then
        XCTAssertEqual(calculatedSteps, 70)
    }
}
