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
        case .mc:
            return buildRangeFilterInfoForMCMarket(from: filterData)
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
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: false, isCurrencyValueRange: false)
        case .engineEffect:
            lowValue = 0
            highValue = 500
            unit = "hk"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 10
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .mileage:
            lowValue = 0
            highValue = 200_000
            unit = "km"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 1000
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .numberOfSeats:
            lowValue = 0
            highValue = 10
            unit = "seter"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .price:
            lowValue = 0
            highValue = 500_000
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

    func buildRangeFilterInfoForMCMarket(from filterData: FilterData) -> RangeFilterInfoType? {
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
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: false, isCurrencyValueRange: false)
        case .engineEffect:
            lowValue = 0
            highValue = 200
            unit = "hk"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 10
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .mileage:
            lowValue = 0
            highValue = 200_000
            unit = "km"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 1000
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .price:
            lowValue = 0
            highValue = 250_000
            unit = "kr"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 1000
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
        case .engineVolume:
            lowValue = 50
            highValue = 1000
            unit = "ccm"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 25
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
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
