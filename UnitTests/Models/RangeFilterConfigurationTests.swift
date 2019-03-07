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
            unit: "stk",
            accessibilityValueSuffix: "test",
            usesSmallNumberInputFont: true,
            displaysUnitInNumberInput: true,
            isCurrencyValueRange: false
        )

        XCTAssertEqual(config.minimumValue, 100)
        XCTAssertEqual(config.maximumValue, 10000)
        XCTAssertFalse(config.hasLowerBoundOffset)
        XCTAssertFalse(config.hasUpperBoundOffset)
        XCTAssertEqual(config.values, [100, 150, 200, 500, 750, 1000, 2500, 5000, 7500, 10000])
        XCTAssertEqual(config.referenceValues, [100, 1000, 10000])
        XCTAssertEqual(config.unit, "stk")
        XCTAssertEqual(config.accessibilityValueSuffix, "test")
        XCTAssertTrue(config.usesSmallNumberInputFont)
        XCTAssertTrue(config.displaysUnitInNumberInput)
        XCTAssertFalse(config.isCurrencyValueRange)
    }

    func testInitWithStepValuesAndOffsets() {
        let config = RangeFilterConfiguration(
            minimumValue: 100,
            maximumValue: 10000,
            valueKind: .steps([150, 200, 500, 750, 1000, 2500, 5000, 7500]),
            hasLowerBoundOffset: true,
            hasUpperBoundOffset: true,
            unit: "stk",
            accessibilityValueSuffix: "test",
            usesSmallNumberInputFont: true,
            displaysUnitInNumberInput: true,
            isCurrencyValueRange: false
        )

        XCTAssertEqual(config.minimumValue, 100)
        XCTAssertEqual(config.maximumValue, 10000)
        XCTAssertTrue(config.hasLowerBoundOffset)
        XCTAssertTrue(config.hasUpperBoundOffset)
        XCTAssertEqual(config.values, [100, 150, 200, 500, 750, 1000, 2500, 5000, 7500, 10000])
        XCTAssertEqual(config.referenceValues, [100, 1000, 10000])
        XCTAssertEqual(config.unit, "stk")
        XCTAssertEqual(config.accessibilityValueSuffix, "test")
        XCTAssertTrue(config.usesSmallNumberInputFont)
        XCTAssertTrue(config.displaysUnitInNumberInput)
        XCTAssertFalse(config.isCurrencyValueRange)
    }

    func testReferenceValuesWithTwoElements() {
        let config = RangeFilterConfiguration(
            minimumValue: 0,
            maximumValue: 1,
            valueKind: .incremented(1),
            hasLowerBoundOffset: false,
            hasUpperBoundOffset: false,
            unit: "stk",
            accessibilityValueSuffix: "test",
            usesSmallNumberInputFont: true,
            displaysUnitInNumberInput: true,
            isCurrencyValueRange: false
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
            unit: "stk",
            accessibilityValueSuffix: "test",
            usesSmallNumberInputFont: true,
            displaysUnitInNumberInput: true,
            isCurrencyValueRange: false
        )

        XCTAssertEqual(config.minimumValue, 100)
        XCTAssertEqual(config.maximumValue, 5000)
        XCTAssertTrue(config.hasLowerBoundOffset)
        XCTAssertTrue(config.hasUpperBoundOffset)
        XCTAssertEqual(config.values, [100, 1100, 2100, 3100, 4100, 5000])
        XCTAssertEqual(config.referenceValues, [100, 3100, 5000])
        XCTAssertEqual(config.unit, "stk")
        XCTAssertEqual(config.accessibilityValueSuffix, "test")
        XCTAssertTrue(config.usesSmallNumberInputFont)
        XCTAssertTrue(config.displaysUnitInNumberInput)
        XCTAssertFalse(config.isCurrencyValueRange)
    }

    func testInitWithIntervals() {
        let config = RangeFilterConfiguration(
            minimumValue: 0,
            maximumValue: 4000,
            valueKind: .intervals(
                array: [
                    (range: 0 ..< 200, increment: 50),
                    (range: 200 ..< 500, increment: 100),
                    (range: 500 ..< 2000, increment: 500),
                ],
                defaultIncrement: 1000
            ),
            hasLowerBoundOffset: false,
            hasUpperBoundOffset: true,
            unit: "kr",
            accessibilityValueSuffix: "test",
            usesSmallNumberInputFont: false,
            displaysUnitInNumberInput: true,
            isCurrencyValueRange: true
        )

        XCTAssertEqual(config.minimumValue, 0)
        XCTAssertEqual(config.maximumValue, 4000)
        XCTAssertFalse(config.hasLowerBoundOffset)
        XCTAssertTrue(config.hasUpperBoundOffset)
        XCTAssertEqual(config.values, [0, 50, 100, 150, 200, 300, 400, 500, 1000, 1500, 2000, 3000, 4000])
        XCTAssertEqual(config.referenceValues, [0, 400, 4000])
        XCTAssertEqual(config.unit, "kr")
        XCTAssertEqual(config.accessibilityValueSuffix, "test")
        XCTAssertFalse(config.usesSmallNumberInputFont)
        XCTAssertTrue(config.displaysUnitInNumberInput)
        XCTAssertTrue(config.isCurrencyValueRange)
    }

    func testValueForStepWithoutOffsets() {
        let config = RangeFilterConfiguration(
            minimumValue: 0,
            maximumValue: 5,
            valueKind: .incremented(1),
            hasLowerBoundOffset: true,
            hasUpperBoundOffset: true,
            unit: "stk",
            accessibilityValueSuffix: "test",
            usesSmallNumberInputFont: true,
            displaysUnitInNumberInput: true,
            isCurrencyValueRange: false
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
            unit: "stk",
            accessibilityValueSuffix: "test",
            usesSmallNumberInputFont: true,
            displaysUnitInNumberInput: true,
            isCurrencyValueRange: false
        )

        XCTAssertEqual(config.value(for: .lowerBound), 0)
        XCTAssertEqual(config.value(for: .upperBound), 5)
        XCTAssertEqual(config.value(for: .value(index: 0, rounded: false)), 0)
        XCTAssertEqual(config.value(for: .value(index: 2, rounded: false)), 2)
        XCTAssertEqual(config.value(for: .value(index: 2, rounded: true)), 2)
    }
}
