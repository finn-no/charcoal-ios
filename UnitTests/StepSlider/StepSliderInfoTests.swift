//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class StepSliderInfoTests: XCTestCase {
    func testInitWithStepValues() {
        let info = StepSliderInfo(
            minimumValue: 100,
            maximumValue: 10000,
            stepValues: [150, 200, 500, 750, 1000, 2500, 5000, 7500],
            hasLowerBoundOffset: false,
            hasUpperBoundOffset: false
        )

        XCTAssertEqual(info.minimumValue, 100)
        XCTAssertEqual(info.maximumValue, 10000)
        XCTAssertFalse(info.hasLowerBoundOffset)
        XCTAssertFalse(info.hasUpperBoundOffset)
        XCTAssertEqual(info.values, [100, 150, 200, 500, 750, 1000, 2500, 5000, 7500, 10000])
        XCTAssertEqual(info.referenceValues, [100, 1000, 10000])
    }

    func testInitWithStepValuesAndOffsets() {
        let info = StepSliderInfo(
            minimumValue: 100,
            maximumValue: 10000,
            stepValues: [150, 200, 500, 750, 1000, 2500, 5000, 7500],
            hasLowerBoundOffset: true,
            hasUpperBoundOffset: true,
            accessibilityStepIncrement: 2
        )

        XCTAssertEqual(info.minimumValue, 100)
        XCTAssertEqual(info.maximumValue, 10000)
        XCTAssertTrue(info.hasLowerBoundOffset)
        XCTAssertTrue(info.hasUpperBoundOffset)
        XCTAssertEqual(info.values, [100, 150, 200, 500, 750, 1000, 2500, 5000, 7500, 10000])
        XCTAssertEqual(info.referenceValues, [100, 1000, 10000])
    }

    func testReferenceValuesWithTwoElements() {
        let info1 = StepSliderInfo(
            minimumValue: 0,
            maximumValue: 1,
            incrementedBy: 1,
            hasLowerBoundOffset: false,
            hasUpperBoundOffset: false
        )

        XCTAssertEqual(info1.referenceValues, [0, 1])
    }

    func testInitWithIncrement() {
        let info = StepSliderInfo(
            minimumValue: 100,
            maximumValue: 5000,
            incrementedBy: 1000,
            hasLowerBoundOffset: true,
            hasUpperBoundOffset: true,
            accessibilityStepIncrement: 2
        )

        XCTAssertEqual(info.minimumValue, 100)
        XCTAssertEqual(info.maximumValue, 5000)
        XCTAssertTrue(info.hasLowerBoundOffset)
        XCTAssertTrue(info.hasUpperBoundOffset)
        XCTAssertEqual(info.values, [100, 1100, 2100, 3100, 4100, 5000])
        XCTAssertEqual(info.referenceValues, [100, 3100, 5000])
    }

    func testValueForStepWithoutOffsets() {
        let info = StepSliderInfo(
            minimumValue: 0,
            maximumValue: 5,
            incrementedBy: 1,
            hasLowerBoundOffset: true,
            hasUpperBoundOffset: true
        )

        XCTAssertNil(info.value(for: .lowerBound))
        XCTAssertNil(info.value(for: .upperBound))
        XCTAssertEqual(info.value(for: .value(index: 0, rounded: false)), 0)
        XCTAssertEqual(info.value(for: .value(index: 2, rounded: false)), 2)
        XCTAssertEqual(info.value(for: .value(index: 2, rounded: true)), 2)
    }

    func testValueForStepWithOffsets() {
        let info = StepSliderInfo(
            minimumValue: 0,
            maximumValue: 5,
            incrementedBy: 1,
            hasLowerBoundOffset: false,
            hasUpperBoundOffset: false
        )

        XCTAssertEqual(info.value(for: .lowerBound), 0)
        XCTAssertEqual(info.value(for: .upperBound), 5)
        XCTAssertEqual(info.value(for: .value(index: 0, rounded: false)), 0)
        XCTAssertEqual(info.value(for: .value(index: 2, rounded: false)), 2)
        XCTAssertEqual(info.value(for: .value(index: 2, rounded: true)), 2)
    }

    func testIsValidRangeValue() {
        let info = StepSliderInfo(
            minimumValue: 0,
            maximumValue: 5,
            incrementedBy: 1,
            hasLowerBoundOffset: false,
            hasUpperBoundOffset: false
        )

        XCTAssertTrue(info.isValidRangeValue(.maximum(highValue: 1000)))
        XCTAssertTrue(info.isValidRangeValue(.minimum(lowValue: 1000)))
        XCTAssertTrue(info.isValidRangeValue(.closed(lowValue: 0, highValue: 5)))
        XCTAssertTrue(info.isValidRangeValue(.closed(lowValue: 1, highValue: 4)))
        XCTAssertTrue(info.isValidRangeValue(.closed(lowValue: 2, highValue: 2)))
        XCTAssertFalse(info.isValidRangeValue(.closed(lowValue: 2, highValue: 1)))
        XCTAssertFalse(info.isValidRangeValue(.closed(lowValue: 10, highValue: 10000)))
    }
}
