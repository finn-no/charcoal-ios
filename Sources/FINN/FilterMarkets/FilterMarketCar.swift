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

extension FilterMarketCar: FINNFilterConfiguration {
    public var preferenceFilterKeys: [FilterKey] {
        switch self {
        case .norway, .abroad:
            return [.published, .priceChanged, .dealerSegment]
        case .mobileHome, .caravan:
            return [.published, .caravanDealerSegment]
        }
    }

    public var rootLevelFilterKeys: [FilterKey] {
        switch self {
        case .norway:
            return [
                .query,
                .preferences,
                .make,
                .salesForm,
                .year,
                .mileage,
                .leasepriceInit,
                .leasepriceMonth,
                .price,
                .location,
                .map,
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
                .query,
                .preferences,
                .make,
                .salesForm,
                .year,
                .mileage,
                .leasepriceInit,
                .leasepriceMonth,
                .price,
                .location,
                .map,
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
                .query,
                .preferences,
                .make,
                .salesForm,
                .year,
                .mileage,
                .price,
                .location,
                .map,
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
                .query,
                .preferences,
                .make,
                .salesForm,
                .year,
                .mileage,
                .price,
                .location,
                .map,
                .noOfSleepers,
                .caravanSegment,
                .length,
                .width,
                .weight,
            ]
        }
    }

    public var contextFilterKeys: Set<FilterKey> {
        return [
            .leasepriceInit,
            .leasepriceMonth,
        ]
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
        case .year:
            let minimumValue: Int

            switch self {
            case .norway, .abroad:
                minimumValue = 1950
            case .mobileHome, .caravan:
                minimumValue = 1990
            }

            return RangeFilterInfo(
                minimumValue: minimumValue,
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
        case .mileage:
            let maximumValue: Int

            switch self {
            case .caravan:
                maximumValue = 20000
            default:
                maximumValue = 200_000
            }

            return RangeFilterInfo(
                minimumValue: 0,
                maximumValue: maximumValue,
                valueKind: .incremented(1000),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "km",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: false
            )
        case .price:
            let maximumValue: Int

            switch self {
            case .norway, .abroad, .caravan:
                maximumValue = 700_000
            case .mobileHome:
                maximumValue = 1_000_000
            }

            return RangeFilterInfo(
                minimumValue: 0,
                maximumValue: maximumValue,
                valueKind: .incremented(10000),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "kr",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: true,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: true
            )
        case .leasepriceInit:
            return RangeFilterInfo(
                minimumValue: 0,
                maximumValue: 150_000,
                valueKind: .incremented(10000),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "kr",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: true
            )
        case .leasepriceMonth:
            return RangeFilterInfo(
                minimumValue: 0,
                maximumValue: 10000,
                valueKind: .incremented(1000),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "kr",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: true
            )
        case .engineEffect:
            let minimumValue: Int
            let maximumValue: Int

            switch self {
            case .norway, .abroad:
                minimumValue = 0
                maximumValue = 500
            default:
                minimumValue = 0
                maximumValue = 300
            }

            return RangeFilterInfo(
                minimumValue: minimumValue,
                maximumValue: maximumValue,
                valueKind: .incremented(10),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "hk",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: false
            )
        case .numberOfSeats:
            let maximumValue: Int

            switch self {
            case .norway, .abroad:
                maximumValue = 10
            case .mobileHome:
                maximumValue = 8
            default:
                return nil
            }

            return RangeFilterInfo(
                minimumValue: 0,
                maximumValue: maximumValue,
                valueKind: .incremented(1),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "seter",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: false
            )
        case .noOfSleepers:
            return RangeFilterInfo(
                minimumValue: 0,
                maximumValue: 8,
                valueKind: .incremented(1),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "stk.",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: false
            )
        case .length:
            let minimumValue: Int

            switch self {
            case .mobileHome:
                minimumValue = 600
            case .caravan:
                minimumValue = 500
            default:
                return nil
            }

            return RangeFilterInfo(
                minimumValue: minimumValue,
                maximumValue: 950,
                valueKind: .incremented(50),
                hasLowerBoundOffset: true,
                hasUpperBoundOffset: true,
                unit: "cm",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: false
            )
        case .width:
            return RangeFilterInfo(
                minimumValue: 200,
                maximumValue: 350,
                valueKind: .incremented(10),
                hasLowerBoundOffset: true,
                hasUpperBoundOffset: true,
                unit: "cm",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: false
            )
        case .weight:
            let minimumValue: Int
            let maximumValue: Int

            switch self {
            case .mobileHome:
                minimumValue = 3500
                maximumValue = 7500
            case .caravan:
                minimumValue = 1000
                maximumValue = 3500
            default:
                return nil
            }

            return RangeFilterInfo(
                minimumValue: minimumValue,
                maximumValue: maximumValue,
                valueKind: .incremented(100),
                hasLowerBoundOffset: true,
                hasUpperBoundOffset: true,
                unit: "kg",
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
