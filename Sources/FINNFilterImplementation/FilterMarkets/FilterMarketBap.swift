//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

enum FilterMarketBap: String, CaseIterable {
    case bap
}

extension FilterMarketBap: FilterConfiguration {
    func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical || vertical.hasPrefix(rawValue + "-")
    }

    var preferenceFilterKeys: [FilterKey] {
        return [.searchType, .segment, .condition, .published]
    }

    var supportedFiltersKeys: [FilterKey] {
        return [
            .location,
            .category,
            .price,
        ]
    }

    var mapFilterKey: FilterKey? {
        return .location
    }

    func createRangeFilterFrom(filterData: FilterData) -> RangeFilterInfoType? {
        let parameterName = filterData.parameterName
        let name = filterData.title
        let lowValue: Int
        let highValue: Int
        let increment: Int
        let unit: String
        let rangeBoundsOffsets: RangeFilterInfo.RangeBoundsOffsets
        let accessibilityValues: RangeFilterInfo.AccessibilityValues
        let appearanceProperties: RangeFilterInfo.AppearenceProperties

        guard let filterKey = FilterKey(stringValue: filterData.parameterName) else {
            return nil
        }
        switch filterKey {
        case .price:
            lowValue = 0
            highValue = 30000
            unit = "kr"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 1000
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
        default:
            return nil
        }

        return RangeFilterInfo(
            parameterName: parameterName,
            title: name,
            lowValue: lowValue,
            highValue: highValue,
            increment: increment,
            rangeBoundsOffsets: rangeBoundsOffsets,
            unit: unit,
            accesibilityValues: accessibilityValues,
            appearanceProperties: appearanceProperties
        )
    }
}
