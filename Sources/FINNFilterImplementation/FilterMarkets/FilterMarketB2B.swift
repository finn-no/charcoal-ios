//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

enum FilterMarketB2B: String, CaseIterable {
    case truck
    case truckAbroad = "truck-abroad"
    case bus
    case construction
    case agricultureTractor = "agriculture-tractor"
    case agricultureThresher = "agriculture-thresher"
    case agricultureTools = "agriculture-tools"
    case vanNorway = "van-norway"
    case vanAbroad = "van-abroad"
}

// MARK: - FilterConfiguration

extension FilterMarketB2B: FilterConfiguration {
    func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical
    }

    var preferenceFilterKeys: [FilterKey] {
        return [.published, .dealerSegment]
    }

    var supportedFiltersKeys: [FilterKey] {
        switch self {
        case .truck, .truckAbroad:
            return [
                .location,
                .truckSegment,
                .make,
                .price,
                .year,
                .engineEffect,
                .weight
            ]
        case .bus:
            return [
                .location,
                .busSegment,
                .make,
                .price,
                .year,
                .engineEffect
            ]
        case .construction:
            return [
                .location,
                .constructionSegment,
                .make,
                .price,
                .year,
                .engineEffect
            ]
        case .agricultureTractor, .agricultureThresher:
            return [
                .location,
                .make,
                .price,
                .year,
                .engineEffect
            ]
        case .agricultureTools:
            return [
                .location,
                .category,
                .price,
                .year
            ]
        case .vanNorway, .vanAbroad:
            return [
                .make,
                .year,
                .mileage,
                .price,
                .bodyType,
                .location,
                .engineFuel,
                .exteriorColour,
                .engineEffect,
                .numberOfSeats,
                .wheelDrive,
                .transmission,
                .wheelSets,
                .warrantyInsurance,
                .condition,
                .salesForm
            ]
        }
    }

    var mapFilterKey: FilterKey? {
        return .location
    }

    func createFilterInfoFrom(rangeFilterData: FilterData) -> FilterInfoType? {
        let parameterName = rangeFilterData.parameterName
        let name = rangeFilterData.title
        let lowValue: Int
        let highValue: Int
        let increment: Int
        let unit: String
        let rangeBoundsOffsets: RangeFilterInfo.RangeBoundsOffsets
        let accessibilityValues: RangeFilterInfo.AccessibilityValues
        let appearanceProperties: RangeFilterInfo.AppearenceProperties

        guard let filterKey = FilterKey(stringValue: rangeFilterData.parameterName) else {
            return nil
        }

        switch filterKey {
        case .price:
            switch self {
            case .bus:
                lowValue = 0
                highValue = 500_000
                increment = 10_000
                rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            case .agricultureTractor:
                lowValue = 0
                highValue = 1_000_000
                increment = 10_000
                rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            case .vanNorway, .vanAbroad:
                lowValue = 10_000
                highValue = 700_000
                increment = 10_000
                rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            default:
                lowValue = 30_000
                highValue = 1_000_000
                increment = 10_000
                rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            }
            unit = "kr"
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
        case .year:
            switch self {
            case .bus, .vanNorway, .vanAbroad:
                lowValue = 1990
            default:
                lowValue = 1985
            }

            highValue = Calendar.current.component(.year, from: Date())
            unit = "år"
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: false, isCurrencyValueRange: false)
        case .engineEffect:
            switch self {
            case .bus:
                lowValue = 100
                highValue = 500
                rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            case .agricultureTractor, .agricultureThresher:
                lowValue = 0
                highValue = 500
                rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            case .vanNorway, .vanAbroad:
                lowValue = 50
                highValue = 500
                rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            default:
                lowValue = 100
                highValue = 600
                rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            }
            unit = "hk"
            increment = 10
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .weight:
            lowValue = 1_000
            highValue = 40_000
            unit = "kg"
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            increment = 50
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
