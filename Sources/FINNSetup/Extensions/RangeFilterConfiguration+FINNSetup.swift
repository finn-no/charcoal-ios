//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation
import Charcoal

extension RangeFilterConfiguration {
    static func configuration(minimumValue: Int, maximumValue: Int, increment: Int, unit: FilterUnit) -> RangeFilterConfiguration {
        return RangeFilterConfiguration(
            minimumValue: minimumValue,
            maximumValue: maximumValue,
            valueKind: .incremented(increment),
            hasLowerBoundOffset: minimumValue > 0,
            hasUpperBoundOffset: true,
            unit: unit,
            usesSmallNumberInputFont: maximumValue > 1_000_000
        )
    }

    static func yearConfiguration(minimumValue: Int) -> RangeFilterConfiguration {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        let currentYear = gregorianCalendar.component(.year, from: Date())
        return .configuration(
            minimumValue: minimumValue,
            maximumValue: currentYear,
            increment: 1,
            unit: .year
        )
    }

    static func mileageConfiguration(maximumValue: Int) -> RangeFilterConfiguration {
        return .configuration(minimumValue: 0, maximumValue: maximumValue, increment: 1000, unit: .kilometers)
    }

    static func numberOfSeatsConfiguration(maximumValue: Int) -> RangeFilterConfiguration {
        return .configuration(minimumValue: 0, maximumValue: maximumValue, increment: 1, unit: .seats)
    }

    static func horsePowerConfiguration(minimumValue: Int, maximumValue: Int) -> RangeFilterConfiguration {
        return .configuration(minimumValue: minimumValue, maximumValue: maximumValue, increment: 10, unit: .horsePower)
    }

    static func numberOfItemsConfiguration(minimumValue: Int, maximumValue: Int) -> RangeFilterConfiguration {
        return .configuration(minimumValue: minimumValue, maximumValue: maximumValue, increment: 1, unit: .items)
    }
}
