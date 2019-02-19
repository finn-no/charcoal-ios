//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterMarketCar: String, CaseIterable {
    case norway = "car-norway"
    case abroad = "car-abroad"
    case mobileHome = "mobile-home"
    case caravan
}

// MARK: - FilterConfiguration

extension FilterMarketCar: FilterConfiguration {
    public func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical
    }

    public var preferenceFilterKeys: [FilterKey] {
        switch self {
        case .norway, .abroad:
            return [.published, .priceChanged, .dealerSegment]
        case .mobileHome, .caravan:
            return [.published, .caravanDealerSegment]
        }
    }

    public var supportedFiltersKeys: [FilterKey] {
        switch self {
        case .norway:
            return [
                .make,
                .salesForm,
                .year,
                .mileage,
                .leasepriceInit,
                .leasepriceMonth,
                .price,
                .location,
                .bodyType,
                .engineFuel,
                .exteriorColour,
                .engineEffect,
                .numberOfSeats,
                .wheelDrive,
                .transmission,
                .carEquipment,
                .wheelSets,
                .warrantyInsurance,
                .condition,
                .registrationClass,
            ]
        case .abroad:
            return [
                .make,
                .salesForm,
                .year,
                .mileage,
                .leasepriceInit,
                .leasepriceMonth,
                .price,
                .location,
                .bodyType,
                .engineFuel,
                .exteriorColour,
                .engineEffect,
                .numberOfSeats,
                .wheelDrive,
                .transmission,
                .carEquipment,
                .wheelSets,
                .warrantyInsurance,
                .condition,
                .registrationClass,
            ]
        case .mobileHome:
            return [
                .make,
                .salesForm,
                .year,
                .mileage,
                .price,
                .location,
                .noOfSleepers,
                .numberOfSeats,
                .engineEffect,
                .mobileHomeSegment,
                .transmission,
                .wheelDrive,
                .length,
                .weight,
            ]
        case .caravan:
            return [
                .make,
                .salesForm,
                .year,
                .mileage,
                .price,
                .location,
                .noOfSleepers,
                .caravanSegment,
                .length,
                .width,
                .weight,
            ]
        }
    }

    public var contextFilters: Set<FilterKey> {
        return [
            .leasepriceInit,
            .leasepriceMonth,
        ]
    }

    public var mapFilterKey: FilterKey? {
        return .location
    }

    public var mapFilterConfig: MapFilterConfiguration? {
        return .default
    }

    public func viewModel(forKey key: String) -> RangeFilterInfo? {
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
            switch self {
            case .norway, .abroad:
                lowValue = 1950
            case .mobileHome, .caravan:
                lowValue = 1990
            }
            highValue = Calendar.current.component(.year, from: Date())
            unit = "år"
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: false, isCurrencyValueRange: false)
        case .mileage:
            switch self {
            case .caravan:
                highValue = 20000
            default:
                highValue = 200_000
            }
            lowValue = 0
            unit = "km"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 1000
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .price:
            switch self {
            case .norway, .abroad, .caravan:
                highValue = 700_000
            case .mobileHome:
                highValue = 1_000_000
            }
            lowValue = 0
            unit = "kr"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 10000
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: true, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
        case .leasepriceInit:
            lowValue = 0
            highValue = 150_000
            unit = "kr"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 10000
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
        case .leasepriceMonth:
            lowValue = 0
            highValue = 10000
            unit = "kr"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 1000
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
        case .engineEffect:
            switch self {
            case .norway, .abroad:
                lowValue = 0
                highValue = 500
            default:
                lowValue = 0
                highValue = 300
            }
            unit = "hk"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 10
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .numberOfSeats:
            switch self {
            case .norway, .abroad:
                highValue = 10
            case .mobileHome:
                highValue = 8
            default:
                return nil
            }
            lowValue = 0
            unit = "seter"
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .noOfSleepers:
            lowValue = 0
            highValue = 8
            unit = "stk."
            rangeBoundsOffsets = (hasLowerBoundOffset: false, hasUpperBoundOffset: true)
            increment = 1
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .length:
            switch self {
            case .mobileHome:
                lowValue = 600
            case .caravan:
                lowValue = 500
            default:
                return nil
            }
            highValue = 950
            unit = "cm"
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            increment = 50
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .width:
            lowValue = 200
            highValue = 350
            unit = "cm"
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            increment = 10
            accessibilityValues = (stepIncrement: nil, valueSuffix: nil)
            appearanceProperties = (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: false)
        case .weight:
            switch self {
            case .mobileHome:
                lowValue = 3500
                highValue = 7500
            case .caravan:
                lowValue = 1000
                highValue = 3500
            default: return nil
            }
            unit = "kg"
            rangeBoundsOffsets = (hasLowerBoundOffset: true, hasUpperBoundOffset: true)
            increment = 100
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
