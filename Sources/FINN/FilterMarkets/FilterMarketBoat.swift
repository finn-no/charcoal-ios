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
        guard let filterKey = FilterKey(stringValue: key) else {
            return nil
        }

        switch filterKey {
        case .price:
            let maximumValue: Int
            let increment: Int

            switch self {
            case .boatSale, .boatUsedWanted:
                maximumValue = 1_000_000
                increment = 10000
            case .boatMotor, .boatParts, .boatRent, .boatPartsMotorWanted:
                maximumValue = 100_000
                increment = 1000
            case .boatDock:
                maximumValue = 200_000
                increment = 1000
            case .boatDockWanted:
                maximumValue = 10000
                increment = 1000
            }

            return RangeFilterInfo(
                minimumValue: 0,
                maximumValue: maximumValue,
                valueKind: .incremented(increment),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "kr",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: true
            )
        case .lengthFeet:
            return RangeFilterInfo(
                minimumValue: 0,
                maximumValue: 60,
                valueKind: .incremented(1),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "fot",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: false
            )
        case .year:
            return RangeFilterInfo(
                minimumValue: 1985,
                maximumValue: Calendar.current.component(.year, from: Date()),
                valueKind: .incremented(1),
                hasLowerBoundOffset: true,
                hasUpperBoundOffset: true,
                unit: "år",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: false,
                isCurrencyValueRange: false
            )
        case .motorSize:
            return RangeFilterInfo(
                minimumValue: 0,
                maximumValue: 500,
                valueKind: .incremented(10),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "hk",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: false
            )
        case .noOfSeats:
            return RangeFilterInfo(
                minimumValue: 0,
                maximumValue: 20,
                valueKind: .incremented(1),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "stk.",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: false
            )
        case .noOfSleepers:
            return RangeFilterInfo(
                minimumValue: 0,
                maximumValue: 10,
                valueKind: .incremented(1),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "stk.",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: false
            )
        case .width:
            return RangeFilterInfo(
                minimumValue: 250,
                maximumValue: 500,
                valueKind: .incremented(10),
                hasLowerBoundOffset: true,
                hasUpperBoundOffset: true,
                unit: "cm",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: false
            )
        default:
            return nil
        }
    }

    public func stepperViewModel(forKey key: String) -> StepperFilterInfo? {
        return nil
    }
}
