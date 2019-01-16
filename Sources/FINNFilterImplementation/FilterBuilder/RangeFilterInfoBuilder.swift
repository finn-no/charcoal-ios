//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class RangeFilterInfoBuilder {
    let filter: FilterSetup

    init(filter: FilterSetup) {
        self.filter = filter
    }

    func buildRangeFilterInfo(from filterData: FilterData) -> RangeFilterInfoType? {
        guard let market = FilterMarket(market: filter.market) else {
            return nil
        }

        switch market {
        case .bap:
            return buildRangeFilterInfoForBAPMarket(from: filterData)
        case .car:
            return buildRangeFilterInfoForCarMarket(from: filterData)
        case .realestate:
            return buildRangeFilterInfoForRealestateMarket(from: filterData)
        }
    }
}

private extension RangeFilterInfoBuilder {
    func buildRangeFilterInfoForCarMarket(from filterData: FilterData) -> RangeFilterInfoType? {
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
        case .year:
            lowValue = 1950
            highValue = Calendar.current.component(.year, from: Date())
            unit = "år"
            rangeBoundsOffsets = (10, 10)
            increment = 1
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: false, isCurrencyValueRange: false)
        case .engineEffect:
            lowValue = 0
            highValue = 500
            unit = "hk"
            rangeBoundsOffsets = (0, 10)
            increment = 10
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .mileage:
            lowValue = 0
            highValue = 200_000
            unit = "km"
            rangeBoundsOffsets = (0, 1000)
            increment = 1000
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .numberOfSeats:
            lowValue = 0
            highValue = 10
            unit = "seter"
            rangeBoundsOffsets = (0, 1)
            increment = 1
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .price:
            lowValue = 0
            highValue = 500_000
            unit = "kr"
            rangeBoundsOffsets = (0, 1000)
            increment = 1000
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
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

    func buildRangeFilterInfoForRealestateMarket(from filterData: FilterData) -> RangeFilterInfoType? {
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
            rangeBoundsOffsets = (0, 100_000)
            unit = "kr"
            increment = 10000
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: true, displaysUnitInNumberInput: false, isCurrencyValueRange: true)
        case .rent:
            lowValue = 0
            highValue = 20000
            rangeBoundsOffsets = (0, 1000)
            unit = "kr"
            increment = 100
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
        case .noOfBedrooms:
            lowValue = 0
            highValue = 6
            rangeBoundsOffsets = (1, 1)
            unit = "soverom"
            increment = 1
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: true, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .area:
            lowValue = 0
            highValue = 400
            rangeBoundsOffsets = (0, 10)
            unit = "m\u{00B2}"
            increment = 1
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: true, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .plotArea:
            lowValue = 0
            highValue = 6000
            rangeBoundsOffsets = (0, 100)
            unit = "m\u{00B2}"
            increment = 10
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .constructionYear:
            lowValue = 1900
            highValue = Calendar.current.component(.year, from: Date())
            rangeBoundsOffsets = (10, 10)
            unit = ""
            increment = 1
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
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

    func buildRangeFilterInfoForBAPMarket(from filterData: FilterData) -> RangeFilterInfoType? {
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
            rangeBoundsOffsets = (0, 1000)
            increment = 1000
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
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
