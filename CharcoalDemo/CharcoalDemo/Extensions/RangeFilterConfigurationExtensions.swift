//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal

extension RangeFilterConfiguration {
    static var priceConfiguration: RangeFilterConfiguration {
        let increment = ValueKind.intervals(array: [
            (from: 0, increment: 50),
            (from: 500, increment: 100),
            (from: 1500, increment: 500),
            (from: 6000, increment: 1000),
        ])

        return create(minimumValue: 0, maximumValue: 30000, unit: .currency(unit: "kr"), increment: increment)
    }

    static func create(minimumValue: Int = 0, maximumValue: Int = 10, unit: FilterUnit, increment: ValueKind = .incremented(1)) -> RangeFilterConfiguration {
        RangeFilterConfiguration(
            minimumValue: minimumValue,
            maximumValue: maximumValue,
            valueKind: increment,
            hasLowerBoundOffset: minimumValue > 0,
            hasUpperBoundOffset: true,
            unit: unit,
            usesSmallNumberInputFont: maximumValue >= 1_000_000
        )
    }
}
