//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class RangeFilterConfigurationTests: XCTestCase {
    func testInitWithStepValues() {
        let config = RangeFilterConfiguration(
            minimumValue: 100,
            maximumValue: 10000,
            valueKind: .steps([150, 200, 500, 750, 1000, 2500, 5000, 7500]),
            hasLowerBoundOffset: false,
            hasUpperBoundOffset: false,
            unit: .items,
            usesSmallNumberInputFont: true
        )

        XCTAssertEqual(config.minimumValue, 100)
        XCTAssertEqual(config.maximumValue, 10000)
        XCTAssertFalse(config.hasLowerBoundOffset)
        XCTAssertFalse(config.hasUpperBoundOffset)
        XCTAssertEqual(config.values, [100, 150, 200, 500, 750, 1000, 2500, 5000, 7500, 10000])
        XCTAssertEqual(config.referenceValues, [100, 1000, 10000])
        XCTAssertEqual(config.unit, .items)
        XCTAssertTrue(config.usesSmallNumberInputFont)
    }

    func testInitWithStepValuesAndOffsets() {
        let config = RangeFilterConfiguration(
            minimumValue: 100,
            maximumValue: 10000,
            valueKind: .steps([150, 200, 500, 750, 1000, 2500, 5000, 7500]),
            hasLowerBoundOffset: true,
            hasUpperBoundOffset: true,
            unit: .items,
            usesSmallNumberInputFont: true
        )

        XCTAssertEqual(config.minimumValue, 100)
        XCTAssertEqual(config.maximumValue, 10000)
        XCTAssertTrue(config.hasLowerBoundOffset)
        XCTAssertTrue(config.hasUpperBoundOffset)
        XCTAssertEqual(config.values, [100, 150, 200, 500, 750, 1000, 2500, 5000, 7500, 10000])
        XCTAssertEqual(config.referenceValues, [100, 1000, 10000])
        XCTAssertEqual(config.unit, .items)
        XCTAssertTrue(config.usesSmallNumberInputFont)
    }

    func testReferenceValuesWithTwoElements() {
        let config = RangeFilterConfiguration(
            minimumValue: 0,
            maximumValue: 1,
            valueKind: .incremented(1),
            hasLowerBoundOffset: false,
            hasUpperBoundOffset: false,
            unit: .items,
            usesSmallNumberInputFont: true
        )

        XCTAssertEqual(config.referenceValues, [0, 1])
    }

    func testInitWithIncrement() {
        let config = RangeFilterConfiguration(
            minimumValue: 100,
            maximumValue: 5000,
            valueKind: .incremented(1000),
            hasLowerBoundOffset: true,
            hasUpperBoundOffset: true,
            unit: .items,
            usesSmallNumberInputFont: true
        )

        XCTAssertEqual(config.minimumValue, 100)
        XCTAssertEqual(config.maximumValue, 5000)
        XCTAssertTrue(config.hasLowerBoundOffset)
        XCTAssertTrue(config.hasUpperBoundOffset)
        XCTAssertEqual(config.values, [100, 1100, 2100, 3100, 4100, 5000])
        XCTAssertEqual(config.referenceValues, [100, 2550, 5000])
        XCTAssertEqual(config.unit, .items)
        XCTAssertTrue(config.usesSmallNumberInputFont)
    }

    func testInitWithIntervals() {
        let config = RangeFilterConfiguration(
            minimumValue: 0,
            maximumValue: 4000,
            valueKind: .intervals(
                array: [
                    (from: 0, increment: 50),
                    (from: 200, increment: 100),
                    (from: 500, increment: 500),
                    (from: 2000, increment: 1000),
                ]
            ),
            hasLowerBoundOffset: false,
            hasUpperBoundOffset: true,
            unit: .currency(unit: "kr"),
            usesSmallNumberInputFont: false
        )

        XCTAssertEqual(config.minimumValue, 0)
        XCTAssertEqual(config.maximumValue, 4000)
        XCTAssertFalse(config.hasLowerBoundOffset)
        XCTAssertTrue(config.hasUpperBoundOffset)
        XCTAssertEqual(config.values, [0, 50, 100, 150, 200, 300, 400, 500, 1000, 1500, 2000, 3000, 4000])
        XCTAssertEqual(config.referenceValues, [0, 400, 4000])
        XCTAssertEqual(config.unit, .currency(unit: "kr"))
        XCTAssertFalse(config.usesSmallNumberInputFont)
    }

    func testValueForStepWithoutOffsets() {
        let config = RangeFilterConfiguration(
            minimumValue: 0,
            maximumValue: 5,
            valueKind: .incremented(1),
            hasLowerBoundOffset: true,
            hasUpperBoundOffset: true,
            unit: .items,
            usesSmallNumberInputFont: true
        )

        XCTAssertNil(config.value(for: .lowerBound))
        XCTAssertNil(config.value(for: .upperBound))
        XCTAssertEqual(config.value(for: .value(index: 0, rounded: false)), 0)
        XCTAssertEqual(config.value(for: .value(index: 2, rounded: false)), 2)
        XCTAssertEqual(config.value(for: .value(index: 2, rounded: true)), 2)
    }

    func testValueForStepWithOffsets() {
        let config = RangeFilterConfiguration(
            minimumValue: 0,
            maximumValue: 5,
            valueKind: .incremented(1),
            hasLowerBoundOffset: false,
            hasUpperBoundOffset: false,
            unit: .items,
            usesSmallNumberInputFont: true
        )

        XCTAssertEqual(config.value(for: .lowerBound), 0)
        XCTAssertEqual(config.value(for: .upperBound), 5)
        XCTAssertEqual(config.value(for: .value(index: 0, rounded: false)), 0)
        XCTAssertEqual(config.value(for: .value(index: 2, rounded: false)), 2)
        XCTAssertEqual(config.value(for: .value(index: 2, rounded: true)), 2)
    }
}
