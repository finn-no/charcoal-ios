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

extension FilterMarketMC: FINNFilterConfiguration {
    public var preferenceFilterKeys: [FilterKey] {
        switch self {
        case .mc:
            return [.published, .segment, .dealerSegment]
        default:
            return [.published, .dealerSegment]
        }
    }

    public var rootLevelFilterKeys: [FilterKey] {
        switch self {
        case .mc:
            return [
                .query,
                .preferences,
                .location,
                .map,
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
                .query,
                .preferences,
                .location,
                .map,
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
                .query,
                .preferences,
                .location,
                .map,
                .make,
                .price,
                .year,
                .mileage,
                .engineEffect,
                .engineVolume,
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
        case .year:
            return RangeFilterInfo(
                minimumValue: 1950,
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
            return RangeFilterInfo(
                minimumValue: 0,
                maximumValue: 200,
                valueKind: .incremented(10),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "hk",
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
        case .price:
            return RangeFilterInfo(
                minimumValue: 0,
                maximumValue: 250_000,
                valueKind: .incremented(1000),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "kr",
                accessibilityValueSuffix: nil,
                usesSmallNumberInputFont: false,
                displaysUnitInNumberInput: true,
                isCurrencyValueRange: true
            )
        case .engineVolume:
            return RangeFilterInfo(
                minimumValue: 50,
                maximumValue: 1000,
                valueKind: .incremented(25),
                hasLowerBoundOffset: false,
                hasUpperBoundOffset: true,
                unit: "ccm",
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
