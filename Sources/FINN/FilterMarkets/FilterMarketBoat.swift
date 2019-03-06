//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterMarketBoat: String, CaseIterable {
    case boatSale = "boat-sale"
    case boatUsedWanted = "boat-used-wanted"
    case boatRent = "boat-rent"
    case boatMotor = "boat-motor"
    case boatParts = "boat-parts"
    case boatPartsMotorWanted = "boat-parts-motor-wanted"
    case boatDock = "boat-dock"
    case boatDockWanted = "boat-dock-wanted"
}

// MARK: - FilterConfiguration

extension FilterMarketBoat: FINNFilterConfiguration {
    public var preferenceFilterKeys: [FilterKey] {
        switch self {
        case .boatSale:
            return [.published, .segment]
        default:
            return [.published]
        }
    }

    public var rootLevelFilterKeys: [FilterKey] {
        switch self {
        case .boatSale:
            return [
                .query,
                .preferences,
                .location,
                .map,
                .motorAdLocation,
                .boatClass,
                .make,
                .price,
                .lengthFeet,
                .year,
                .motorIncluded,
                .motorType,
                .fuel,
                .motorSize,
                .noOfSeats,
                .noOfSleepers,
                .dealerSegment,
            ]
        case .boatUsedWanted:
            return [
                .query,
                .preferences,
                .location,
                .map,
                .boatClass,
                .price,
            ]
        case .boatRent:
            return [
                .query,
                .preferences,
                .location,
                .map,
                .boatClass,
                .price,
                .lengthFeet,
                .year,
                .fuel,
                .motorSize,
                .noOfSeats,
                .noOfSleepers,
            ]
        case .boatMotor, .boatParts:
            return [
                .query,
                .preferences,
                .location,
                .map,
                .type,
                .price,
                .engineEffect,
                .dealerSegment,
            ]
        case .boatPartsMotorWanted:
            return [
                .query,
                .preferences,
                .location,
                .map,
                .type,
                .price,
                .engineEffect,
            ]
        case .boatDock:
            return [
                .query,
                .preferences,
                .location,
                .map,
                .width,
                .price,
                .dealerSegment,
            ]
        case .boatDockWanted:
            return [
                .query,
                .preferences,
                .location,
                .map,
                .width,
                .price,
            ]
        }
    }

    public var contextFilterKeys: Set<FilterKey> {
        return []
    }

    public var mutuallyExclusiveFilterKeys: Set<FilterKey> {
        return [.location, .map]
    }

    public func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical
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
        case .price:
            lowValue = 0
            switch self {
            case .boatSale, .boatUsedWanted:
                highValue = 1_000_000
                increment = 10000
            case .boatMotor, .boatParts, .boatRent, .boatPartsMotorWanted:
                highValue = 100_000
                increment = 1000
            case .boatDock:
                highValue = 200_000
                increment = 1000
            case .boatDockWanted:
                highValue = 10000
                increment = 1000
            }
            unit = "kr"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
        case .lengthFeet:
            lowValue = 0
            highValue = 60
            unit = "fot"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .year:
            lowValue = 1985
            highValue = Calendar.current.component(.year, from: Date())
            unit = "år"
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: false, isCurrencyValueRange: false)
        case .motorSize:
            lowValue = 0
            highValue = 500
            unit = "hk"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 10
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .noOfSeats:
            lowValue = 0
            highValue = 20
            unit = "stk."
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .noOfSleepers:
            lowValue = 0
            highValue = 10
            unit = "stk."
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .width:
            lowValue = 250
            highValue = 500
            unit = "cm"
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            increment = 10
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

    public func stepperViewModel(forKey key: String) -> StepperFilterInfo? {
        return nil
    }
}
