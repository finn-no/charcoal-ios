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
            lowerBoundOffset: 0,
            upperBoundOffset: 0
        )

        XCTAssertEqual(info.minimumValue, 100)
        XCTAssertEqual(info.maximumValue, 10000)
        XCTAssertEqual(info.range, 100 ... 10000)
        XCTAssertEqual(info.values, [100, 150, 200, 500, 750, 1000, 2500, 5000, 7500, 10000])
        XCTAssertEqual(info.effectiveRange, 100 ... 10000)
        XCTAssertEqual(info.effectiveValues, [100, 150, 200, 500, 750, 1000, 2500, 5000, 7500, 10000])
        XCTAssertEqual(info.accessibilityStepIncrement, 1)
        XCTAssertEqual(info.referenceValues, [100, 1000, 10000])
    }

    func testInitWithStepValuesAndOffsets() {
        let info = StepSliderInfo(
            minimumValue: 100,
            maximumValue: 10000,
            stepValues: [150, 200, 500, 750, 1000, 2500, 5000, 7500],
            lowerBoundOffset: 100,
            upperBoundOffset: 100,
            accessibilityStepIncrement: 2
        )

        XCTAssertEqual(info.minimumValue, 100)
        XCTAssertEqual(info.maximumValue, 10000)
        XCTAssertEqual(info.range, 100 ... 10000)
        XCTAssertEqual(info.values, [100, 150, 200, 500, 750, 1000, 2500, 5000, 7500, 10000])
        XCTAssertEqual(info.effectiveRange, 0 ... 10100)
        XCTAssertEqual(info.effectiveValues, [0, 100, 150, 200, 500, 750, 1000, 2500, 5000, 7500, 10000, 10100])
        XCTAssertEqual(info.accessibilityStepIncrement, 2)
        XCTAssertEqual(info.referenceValues, [100, 1000, 10000])
    }

    func testReferenceValuesWithTwoElements() {
        let info1 = StepSliderInfo(
            minimumValue: 0,
            maximumValue: 1,
            incrementedBy: 1,
            lowerBoundOffset: 0,
            upperBoundOffset: 0
        )

        XCTAssertEqual(info1.referenceValues, [0, 1])
    }

    func testInitWithIncrement() {
        let info = StepSliderInfo(
            minimumValue: 100,
            maximumValue: 5000,
            incrementedBy: 1000,
            lowerBoundOffset: 100,
            upperBoundOffset: 100,
            accessibilityStepIncrement: 2
        )

        XCTAssertEqual(info.minimumValue, 100)
        XCTAssertEqual(info.maximumValue, 5000)
        XCTAssertEqual(info.range, 100 ... 5000)
        XCTAssertEqual(info.values, [100, 1100, 2100, 3100, 4100, 5000])
        XCTAssertEqual(info.effectiveRange, 0 ... 5100)
        XCTAssertEqual(info.effectiveValues, [0, 100, 1100, 2100, 3100, 4100, 5000, 5100])
        XCTAssertEqual(info.accessibilityStepIncrement, 2)
        XCTAssertEqual(info.referenceValues, [100, 3100, 5000])
    }

    func testIsLowValueInValidRange() {
        let info = StepSliderInfo(
            minimumValue: 0,
            maximumValue: 5,
            incrementedBy: 1,
            lowerBoundOffset: 1,
            upperBoundOffset: 1
        )

        XCTAssertTrue(info.isLowValueInValidRange(2))
        XCTAssertTrue(info.isLowValueInValidRange(5))

        XCTAssertFalse(info.isLowValueInValidRange(-1))
        XCTAssertFalse(info.isLowValueInValidRange(-5))
        XCTAssertFalse(info.isLowValueInValidRange(0))
    }

    func testIsHighValueInValidRange() {
        let info = StepSliderInfo(
            minimumValue: 0,
            maximumValue: 5,
            incrementedBy: 1,
            lowerBoundOffset: 1,
            upperBoundOffset: 1
        )

        XCTAssertTrue(info.isHighValueInValidRange(0))
        XCTAssertTrue(info.isHighValueInValidRange(3))
        XCTAssertTrue(info.isHighValueInValidRange(5))

        XCTAssertFalse(info.isHighValueInValidRange(6))
    }
}
