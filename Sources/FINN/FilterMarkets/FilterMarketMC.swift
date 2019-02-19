//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterMarketMC: String, CaseIterable {
    case mc
    case mopedScooter = "moped-scooter"
    case snowmobile
    case atv
}

// MARK: - FilterConfiguration

extension FilterMarketMC: FilterConfiguration {
    public func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical
    }

    public var preferenceFilterKeys: [FilterKey] {
        switch self {
        case .mc:
            return [.published, .segment, .dealerSegment]
        default:
            return [.published, .dealerSegment]
        }
    }

    public var supportedFiltersKeys: [FilterKey] {
        switch self {
        case .mc:
            return [
                .location,
                .category,
                .make,
                .price,
                .year,
                .mileage,
                .engineEffect,
                .engineVolume,
            ]
        case .mopedScooter:
            return [
                .location,
                .category,
                .make,
                .price,
                .year,
                .mileage,
                .engineEffect,
                .engineVolume,
            ]
        case .snowmobile, .atv:
            return [
                .location,
                .make,
                .price,
                .year,
                .mileage,
                .engineEffect,
                .engineVolume,
            ]
        }
    }

    public var contextFilters: Set<FilterKey> {
        return []
    }

    public var filterKeyWithMapSubfilter: FilterKey? {
        return .location
    }

    public var searchFilterKey: FilterKey? {
        return .query
    }

    public var preferencesFilterKey: FilterKey? {
        return .preferences
    }

    public func rangeViewModel(forKey key: String) -> RangeFilterInfo? {
        let lowValue: Int
        let highValue: Int
        let increment: Int
        let unit: String
        let rangeBoundsOffsets: RangeFilterInfo.RangeBoundsOffsets
        let accessibilityValues: RangeFilterInfo.AccessibilityValues
        let appearanceProperties: RangeFilterInfo.AppearenceProperties

        guard let filterKey = FilterKey(stringValue: key) else {
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
            kind: .slider,
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
