//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

extension RangeFilterConfiguration {
    static func currencyConfiguration(minimumValue: Int, maximumValue: Int, increment: Int) -> RangeFilterConfiguration {
        return RangeFilterConfiguration(
            minimumValue: minimumValue,
            maximumValue: maximumValue,
            valueKind: .incremented(increment),
            hasLowerBoundOffset: minimumValue > 0,
            hasUpperBoundOffset: true,
            unit: "kr",
            accessibilityValueSuffix: nil,
            usesSmallNumberInputFont: maximumValue > 1_000_000,
            displaysUnitInNumberInput: true,
            isCurrencyValueRange: true
        )
    }

    static func yearConfiguration(minimumValue: Int) -> RangeFilterConfiguration {
        return RangeFilterConfiguration(
            minimumValue: minimumValue,
            maximumValue: Calendar.current.component(.year, from: Date()),
            valueKind: .incremented(1),
            hasLowerBoundOffset: true,
            hasUpperBoundOffset: true,
            unit: "år",
            accessibilityValueSuffix: nil,
            usesSmallNumberInputFont: false,
            displaysUnitInNumberInput: false,
            isCurrencyValueRange: false
        )
    }

    static func mileageConfiguration(maximumValue: Int) -> RangeFilterConfiguration {
        return RangeFilterConfiguration(
            minimumValue: 0,
            maximumValue: maximumValue,
            valueKind: .incremented(1000),
            hasLowerBoundOffset: false,
            hasUpperBoundOffset: true,
            unit: "km",
            accessibilityValueSuffix: nil,
            usesSmallNumberInputFont: false,
            displaysUnitInNumberInput: true,
            isCurrencyValueRange: false
        )
    }

    static func numberOfSeatsConfiguration(maximumValue: Int) -> RangeFilterConfiguration {
        return RangeFilterConfiguration(
            minimumValue: 0,
            maximumValue: maximumValue,
            valueKind: .incremented(1),
            hasLowerBoundOffset: false,
            hasUpperBoundOffset: true,
            unit: "seter",
            accessibilityValueSuffix: nil,
            usesSmallNumberInputFont: false,
            displaysUnitInNumberInput: true,
            isCurrencyValueRange: false
        )
    }

    static func weightConfiguration(minimumValue: Int, maximumValue: Int, increment: Int) -> RangeFilterConfiguration {
        return RangeFilterConfiguration(
            minimumValue: minimumValue,
            maximumValue: maximumValue,
            valueKind: .incremented(10),
            hasLowerBoundOffset: minimumValue > 0,
            hasUpperBoundOffset: true,
            unit: "kg",
            accessibilityValueSuffix: nil,
            usesSmallNumberInputFont: false,
            displaysUnitInNumberInput: true,
            isCurrencyValueRange: false
        )
    }

    static func horsePowerConfiguration(minimumValue: Int, maximumValue: Int) -> RangeFilterConfiguration {
        return RangeFilterConfiguration(
            minimumValue: minimumValue,
            maximumValue: maximumValue,
            valueKind: .incremented(10),
            hasLowerBoundOffset: minimumValue > 0,
            hasUpperBoundOffset: true,
            unit: "hk",
            accessibilityValueSuffix: nil,
            usesSmallNumberInputFont: false,
            displaysUnitInNumberInput: true,
            isCurrencyValueRange: false
        )
    }

    static func sizeConfiguration(minimumValue: Int, maximumValue: Int, increment: Int, unit: String = "cm") -> RangeFilterConfiguration {
        return RangeFilterConfiguration(
            minimumValue: minimumValue,
            maximumValue: maximumValue,
            valueKind: .incremented(increment),
            hasLowerBoundOffset: minimumValue > 0,
            hasUpperBoundOffset: true,
            unit: unit,
            accessibilityValueSuffix: nil,
            usesSmallNumberInputFont: false,
            displaysUnitInNumberInput: true,
            isCurrencyValueRange: false
        )
    }

    static func areaConfiguration(minimumValue: Int, maximumValue: Int, increment: Int) -> RangeFilterConfiguration {
        return RangeFilterConfiguration(
            minimumValue: minimumValue,
            maximumValue: maximumValue,
            valueKind: .incremented(increment),
            hasLowerBoundOffset: true,
            hasUpperBoundOffset: true,
            unit: "m\u{00B2}",
            accessibilityValueSuffix: nil,
            usesSmallNumberInputFont: false,
            displaysUnitInNumberInput: true,
            isCurrencyValueRange: false
        )
    }

    static func numberOfItemsConfiguration(minimumValue: Int, maximumValue: Int) -> RangeFilterConfiguration {
        return RangeFilterConfiguration(
            minimumValue: minimumValue,
            maximumValue: maximumValue,
            valueKind: .incremented(1),
            hasLowerBoundOffset: false,
            hasUpperBoundOffset: true,
            unit: "stk.",
            accessibilityValueSuffix: nil,
            usesSmallNumberInputFont: false,
            displaysUnitInNumberInput: true,
            isCurrencyValueRange: false
        )
    }
}
