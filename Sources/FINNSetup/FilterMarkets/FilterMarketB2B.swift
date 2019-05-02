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

extension FilterMarketB2B: FilterConfiguration {
    public var preferenceFilterKeys: [FilterKey] {
        return [.published, .dealerSegment]
    }

    public var rootLevelFilterKeys: [FilterKey] {
        switch self {
        case .truck, .truckAbroad:
            return [
                .truckSegment,
                .make,
                .price,
                .year,
                .engineEffect,
                .weight,
                .map,
                .location,
            ]
        case .bus:
            return [
                .map,
                .location,
                .busSegment,
                .make,
                .price,
                .year,
                .engineEffect,
            ]
        case .construction:
            return [
                .constructionSegment,
                .price,
                .year,
                .engineEffect,
                .make,
                .map,
                .location,
            ]
        case .agricultureTractor, .agricultureThresher:
            return [
                .make,
                .price,
                .year,
                .engineEffect,
                .map,
                .location,
            ]
        case .agricultureTools:
            return [
                .category,
                .price,
                .year,
                .map,
                .location,
            ]
        case .vanNorway, .vanAbroad:
            return [
                .make,
                .salesForm,
                .map,
                .location,
                .year,
                .price,
                .mileage,
                .bodyType,
                .engineFuel,
                .exteriorColour,
                .engineEffect,
                .numberOfSeats,
                .wheelDrive,
                .transmission,
                .wheelSets,
                .warrantyInsurance,
                .condition,
            ]
        }
    }

    public var contextFilterKeys: Set<FilterKey> {
        return []
    }

    public var mutuallyExclusiveFilterKeys: Set<FilterKey> {
        return [.location, .map]
    }

    public var verticalsCalloutText: String? {
        return "callout.b2b".localized()
    }

    public func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical
    }

    public func rangeConfiguration(forKey key: FilterKey) -> RangeFilterConfiguration? {
        switch key {
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

            return .configuration(
                minimumValue: minimumValue,
                maximumValue: maximumValue,
                increment: 10000,
                unit: .currency
            )
        case .year:
            switch self {
            case .bus, .vanNorway, .vanAbroad:
                return .yearConfiguration(minimumValue: 1990)
            default:
                return .yearConfiguration(minimumValue: 1985)
            }
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

            return .horsePowerConfiguration(minimumValue: minimumValue, maximumValue: maximumValue)
        case .weight:
            return .configuration(minimumValue: 1000, maximumValue: 40000, increment: 50, unit: .kilograms)
        case .mileage:
            return .mileageConfiguration(maximumValue: 200_000)
        case .numberOfSeats:
            return .numberOfSeatsConfiguration(maximumValue: 10)
        default:
            return nil
        }
    }

    public func stepperConfiguration(forKey key: FilterKey) -> StepperFilterConfiguration? {
        return nil
    }
}
