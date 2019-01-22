//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

enum FilterMarketRealestate: String, CaseIterable {
    case homes = "realestate-homes"
}

extension FilterMarketRealestate: FilterConfiguration {
    func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical
    }

    var preferenceFilterKeys: [FilterKey] {
        return [.published, .isSold, .isNewProperty, .isPrivateBroker]
    }

    var supportedFiltersKeys: [FilterKey] {
        return [
            .location,
            .price,
            .priceCollective,
            .rent,
            .area,
            .noOfBedrooms,
            .constructionYear,
            .propertyType,
            .ownershipType,
            .facilities,
            .viewing,
            .floorNavigator,
            .energyLabel,
            .plotArea,
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
        case .price, .priceCollective:
            lowValue = 0
            highValue = 10_000_000
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            unit = "kr"
            increment = 10000
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: true, displaysUnitInNumberInput: false, isCurrencyValueRange: true)
        case .rent:
            lowValue = 0
            highValue = 20000
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            unit = "kr"
            increment = 100
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
        case .noOfBedrooms:
            lowValue = 0
            highValue = 6
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            unit = "soverom"
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: true, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .area:
            lowValue = 0
            highValue = 400
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            unit = "m\u{00B2}"
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: true, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .plotArea:
            lowValue = 0
            highValue = 6000
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            unit = "m\u{00B2}"
            increment = 10
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .constructionYear:
            lowValue = 1900
            highValue = Calendar.current.component(.year, from: Date())
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            unit = ""
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: false, isCurrencyValueRange: false)
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
