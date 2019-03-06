//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterMarketB2B: String, CaseIterable {
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

extension FilterMarketB2B: FINNFilterConfiguration {
    public var preferenceFilterKeys: [FilterKey] {
        return [.published, .dealerSegment]
    }

    public var rootLevelFilterKeys: [FilterKey] {
        switch self {
        case .truck, .truckAbroad:
            return [
                .query,
                .preferences,
                .location,
                .map,
                .truckSegment,
                .make,
                .price,
                .year,
                .engineEffect,
                .weight,
            ]
        case .bus:
            return [
                .query,
                .preferences,
                .location,
                .map,
                .busSegment,
                .make,
                .price,
                .year,
                .engineEffect,
            ]
        case .construction:
            return [
                .query,
                .preferences,
                .location,
                .map,
                .constructionSegment,
                .make,
                .price,
                .year,
                .engineEffect,
            ]
        case .agricultureTractor, .agricultureThresher:
            return [
                .query,
                .preferences,
                .location,
                .map,
                .make,
                .price,
                .year,
                .engineEffect,
            ]
        case .agricultureTools:
            return [
                .query,
                .preferences,
                .location,
                .map,
                .category,
                .price,
                .year,
            ]
        case .vanNorway, .vanAbroad:
            return [
                .query,
                .preferences,
                .make,
                .year,
                .mileage,
                .price,
                .bodyType,
                .location,
                .map,
                .engineFuel,
                .exteriorColour,
                .engineEffect,
                .numberOfSeats,
                .wheelDrive,
                .transmission,
                .wheelSets,
                .warrantyInsurance,
                .condition,
                .salesForm,
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
            let minimumValue: Int
            let maximumValue: Int

            switch self {
            case .bus:
                minimumValue = 0
                maximumValue = 500_000
            case .agricultureTractor:
                minimumValue = 0
                maximumValue = 1_000_000
            case .vanNorway, .vanAbroad:
                minimumValue = 10000
                maximumValue = 700_000
            default:
                minimumValue = 30000
                maximumValue = 1_000_000
            }

            return RangeFilterInfo(
                minimumValue: minimumValue,
                maximumValue: maximumValue,
                valueKind: .incremented(10000),
                hasLowerBoundOffset: minimumValue > 0,
                hasUpperBoundOffset: true,
                unit: "kr",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: true
            )
        case .year:
            let minimumValue: Int

            switch self {
            case .bus, .vanNorway, .vanAbroad:
                minimumValue = 1990
            default:
                minimumValue = 1985
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
        case .engineEffect:
            let minimumValue: Int
            let maximumValue: Int

            switch self {
            case .bus:
                minimumValue = 100
                maximumValue = 500
            case .agricultureTractor, .agricultureThresher:
                minimumValue = 0
                maximumValue = 500
            case .vanNorway, .vanAbroad:
                minimumValue = 50
                maximumValue = 500
            default:
                minimumValue = 100
                maximumValue = 600
            }

            return RangeFilterInfo(
                minimumValue: minimumValue,
                maximumValue: maximumValue,
                valueKind: .incremented(10),
                hasLowerBoundOffset: minimumValue > 0,
                hasUpperBoundOffset: true,
                unit: "hk",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: false
            )
        case .weight:
            return RangeFilterInfo(
                minimumValue: 1000,
                maximumValue: 40000,
                valueKind: .incremented(50),
                hasLowerBoundOffset: true,
                hasUpperBoundOffset: true,
                unit: "kg",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: false
            )
        case .mileage:
            return RangeFilterInfo(
                minimumValue: 0,
                maximumValue: 200_000,
                valueKind: .incremented(1000),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "km",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: false
            )
        case .numberOfSeats:
            return RangeFilterInfo(
                minimumValue: 0,
                maximumValue: 10,
                valueKind: .incremented(1),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "seter",
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
