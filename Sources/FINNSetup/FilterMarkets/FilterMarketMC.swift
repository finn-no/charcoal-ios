//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal

public enum FilterMarketMC: String, CaseIterable {
    case mc
    case mopedScooter = "moped-scooter"
    case snowmobile
    case atv
}

// MARK: - FilterConfiguration

extension FilterMarketMC: FilterConfiguration {
    public var preferenceFilterKeys: [FilterKey] {
        switch self {
        case .mc:
            return [.published, .dealerSegment, .mcCondition]
        default:
            return [.published, .dealerSegment]
        }
    }

    public var rootLevelFilterKeys: [FilterKey] {
        switch self {
        case .mc, .mopedScooter:
            return [
                .make,
                .price,
                .year,
                .mileage,
                .category,
                .map,
                .location,
                .engineVolume,
                .engineEffect,
            ]
        case .snowmobile, .atv:
            return [
                .make,
                .price,
                .year,
                .mileage,
                .map,
                .location,
                .engineVolume,
                .engineEffect,
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

    public func rangeConfiguration(forKey key: FilterKey) -> RangeFilterConfiguration? {
        switch key {
        case .year:
            return .yearConfiguration(minimumValue: 1950)
        case .engineEffect:
            return .horsePowerConfiguration(minimumValue: 0, maximumValue: 200)
        case .mileage:
            return .mileageConfiguration(maximumValue: 200_000)
        case .price:
            return .configuration(minimumValue: 0, maximumValue: 250_000, increment: 1000, unit: .currency)
        case .engineVolume:
            return .configuration(minimumValue: 50, maximumValue: 1000, increment: 25, unit: .cubicCentimeters)
        default:
            return nil
        }
    }

    public func stepperConfiguration(forKey key: FilterKey) -> StepperFilterConfiguration? {
        return nil
    }
}
