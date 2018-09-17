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
        let key = filterData.key
        let name = filterData.title
        let lowValue: Int
        let highValue: Int
        let steps: Int
        let unit: String
        let rangeBoundsOffsets: RangeFilterInfo.RangeBoundsOffsets
        let referenceValues: RangeFilterInfo.ReferenceValues
        let accessibilityValues: RangeFilterInfo.AccessibilityValues
        let appearanceProperties: RangeFilterInfo.AppearenceProperties

        switch filterData.key {
        case .year:
            lowValue = 1950
            highValue = Calendar.current.component(.year, from: Date())
            unit = "år"
            rangeBoundsOffsets = (10, 10)
            referenceValues = defaultReferenceValuesForRange(withLowValue: lowValue, andHighValue: highValue)
            steps = calculatedStepsForRange(withLowValue: lowValue, highValue: highValue, rangeBoundsOffsets: rangeBoundsOffsets, incrementedBy: 1)
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: false, isCurrencyValueRange: false)
        case .engineEffect:
            lowValue = 0
            highValue = 500
            unit = "hk"
            rangeBoundsOffsets = (0, 10)
            referenceValues = defaultReferenceValuesForRange(withLowValue: lowValue, andHighValue: highValue)
            steps = calculatedStepsForRange(withLowValue: lowValue, highValue: highValue, rangeBoundsOffsets: rangeBoundsOffsets, incrementedBy: 10)
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .mileage:
            lowValue = 0
            highValue = 200_000
            unit = "km"
            rangeBoundsOffsets = (0, 1000)
            referenceValues = defaultReferenceValuesForRange(withLowValue: lowValue, andHighValue: highValue)
            steps = calculatedStepsForRange(withLowValue: lowValue, highValue: highValue, rangeBoundsOffsets: rangeBoundsOffsets, incrementedBy: 1000)
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .numberOfSeats:
            lowValue = 0
            highValue = 10
            unit = "seter"
            rangeBoundsOffsets = (0, 1)
            referenceValues = defaultReferenceValuesForRange(withLowValue: lowValue, andHighValue: highValue)
            steps = calculatedStepsForRange(withLowValue: lowValue, highValue: highValue, rangeBoundsOffsets: rangeBoundsOffsets, incrementedBy: 1)
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .price:
            lowValue = 0
            highValue = 500_000
            unit = "kr"
            rangeBoundsOffsets = (0, 1000)
            referenceValues = defaultReferenceValuesForRange(withLowValue: lowValue, andHighValue: highValue)
            steps = calculatedStepsForRange(withLowValue: lowValue, highValue: highValue, rangeBoundsOffsets: rangeBoundsOffsets, incrementedBy: 1000)
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
        default:
            return nil
        }

        return RangeFilterInfo(
            key: key,
            title: name,
            lowValue: lowValue,
            highValue: highValue,
            steps: steps,
            rangeBoundsOffsets: rangeBoundsOffsets,
            unit: unit,
            referenceValues: referenceValues,
            accesibilityValues: accessibilityValues,
            appearanceProperties: appearanceProperties
        )
    }

    func buildRangeFilterInfoForRealestateMarket(from filterData: FilterData) -> RangeFilterInfoType? {
        let key = filterData.key
        let name = filterData.title
        let lowValue: Int
        let highValue: Int
        let steps: Int
        let unit: String
        let rangeBoundsOffsets: RangeFilterInfo.RangeBoundsOffsets
        let referenceValues: RangeFilterInfo.ReferenceValues
        let accessibilityValues: RangeFilterInfo.AccessibilityValues
        let appearanceProperties: RangeFilterInfo.AppearenceProperties

        switch filterData.key {
        case .price, .priceCollective:
            lowValue = 0
            highValue = 10_000_000
            rangeBoundsOffsets = (0, 100_000)
            unit = "kr"
            referenceValues = defaultReferenceValuesForRange(withLowValue: lowValue, andHighValue: highValue)
            steps = calculatedStepsForRange(withLowValue: lowValue, highValue: highValue, rangeBoundsOffsets: rangeBoundsOffsets, incrementedBy: 10000)
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: true, displaysUnitInNumberInput: false, isCurrencyValueRange: true)
        case .rent:
            lowValue = 0
            highValue = 20000
            rangeBoundsOffsets = (0, 1000)
            unit = "kr"
            referenceValues = defaultReferenceValuesForRange(withLowValue: lowValue, andHighValue: highValue)
            steps = calculatedStepsForRange(withLowValue: lowValue, highValue: highValue, rangeBoundsOffsets: rangeBoundsOffsets, incrementedBy: 100)
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
        case .noOfBedrooms:
            lowValue = 0
            highValue = 6
            rangeBoundsOffsets = (1, 1)
            unit = "soverom"
            referenceValues = defaultReferenceValuesForRange(withLowValue: lowValue, andHighValue: highValue)
            steps = calculatedStepsForRange(withLowValue: lowValue, highValue: highValue, rangeBoundsOffsets: rangeBoundsOffsets, incrementedBy: 1)
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: true, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .area:
            lowValue = 0
            highValue = 400
            rangeBoundsOffsets = (0, 10)
            unit = "m\u{00B2}"
            referenceValues = defaultReferenceValuesForRange(withLowValue: lowValue, andHighValue: highValue)
            steps = calculatedStepsForRange(withLowValue: lowValue, highValue: highValue, rangeBoundsOffsets: rangeBoundsOffsets, incrementedBy: 1)
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: true, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .plotArea:
            lowValue = 0
            highValue = 6000
            rangeBoundsOffsets = (0, 100)
            unit = "m\u{00B2}"
            referenceValues = defaultReferenceValuesForRange(withLowValue: lowValue, andHighValue: highValue)
            steps = calculatedStepsForRange(withLowValue: lowValue, highValue: highValue, rangeBoundsOffsets: rangeBoundsOffsets, incrementedBy: 10)
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .constructionYear:
            lowValue = 1900
            highValue = Calendar.current.component(.year, from: Date())
            rangeBoundsOffsets = (10, 10)
            unit = ""
            referenceValues = defaultReferenceValuesForRange(withLowValue: lowValue, andHighValue: highValue)
            steps = calculatedStepsForRange(withLowValue: lowValue, highValue: highValue, rangeBoundsOffsets: rangeBoundsOffsets, incrementedBy: 1)
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: false, isCurrencyValueRange: false)
        default:
            return nil
        }

        return RangeFilterInfo(
            key: key,
            title: name,
            lowValue: lowValue,
            highValue: highValue,
            steps: steps,
            rangeBoundsOffsets: rangeBoundsOffsets,
            unit: unit,
            referenceValues: referenceValues,
            accesibilityValues: accessibilityValues,
            appearanceProperties: appearanceProperties
        )
    }

    func buildRangeFilterInfoForBAPMarket(from filterData: FilterData) -> RangeFilterInfoType? {
        let key = filterData.key
        let name = filterData.title
        let lowValue: Int
        let highValue: Int
        let steps: Int
        let unit: String
        let rangeBoundsOffsets: RangeFilterInfo.RangeBoundsOffsets
        let referenceValues: RangeFilterInfo.ReferenceValues
        let accessibilityValues: RangeFilterInfo.AccessibilityValues
        let appearanceProperties: RangeFilterInfo.AppearenceProperties

        switch filterData.key {
        case .price:
            lowValue = 0
            highValue = 30000
            unit = "kr"
            rangeBoundsOffsets = (0, 1000)
            referenceValues = defaultReferenceValuesForRange(withLowValue: lowValue, andHighValue: highValue)
            steps = calculatedStepsForRange(withLowValue: lowValue, highValue: highValue, rangeBoundsOffsets: rangeBoundsOffsets, incrementedBy: 1000)
            accessibilityValues = (accessibilitySteps: nil, accessibilityValueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
        default:
            return nil
        }

        return RangeFilterInfo(
            key: key,
            title: name,
            lowValue: lowValue,
            highValue: highValue,
            steps: steps,
            rangeBoundsOffsets: rangeBoundsOffsets,
            unit: unit,
            referenceValues: referenceValues,
            accesibilityValues: accessibilityValues,
            appearanceProperties: appearanceProperties
        )
    }

    func defaultReferenceValuesForRange(withLowValue lowValue: Int, andHighValue highValue: Int) -> [Int] {
        return RangeFilterInfoBuilder.defaultReferenceValuesForRange(withLowValue: lowValue, andHighValue: highValue)
    }

    func calculatedStepsForRange(withLowValue lowValue: Int, highValue: Int, rangeBoundsOffsets: RangeFilterInfo.RangeBoundsOffsets, incrementedBy increments: Int) -> Int {
        return RangeFilterInfoBuilder.calculatedStepsForRange(withLowValue: lowValue, highValue: highValue, rangeBoundsOffsets: rangeBoundsOffsets, incrementedBy: increments)
    }
}

extension RangeFilterInfoBuilder {
    static func defaultReferenceValuesForRange(withLowValue lowValue: Int, andHighValue highValue: Int) -> [Int] {
        let midValue = lowValue + ((highValue - lowValue) / 2)
        return [lowValue, midValue, highValue]
    }

    static func calculatedStepsForRange(withLowValue lowValue: Int, highValue: Int, rangeBoundsOffsets: RangeFilterInfo.RangeBoundsOffsets, incrementedBy increments: Int) -> Int {
        let lowerBound = lowValue - rangeBoundsOffsets.lowerBoundOffset
        let upperBound = highValue + rangeBoundsOffsets.upperBoundOffset
        let range = lowerBound ... upperBound
        let steps = (range.upperBound - range.lowerBound) / increments

        return steps
    }
}
