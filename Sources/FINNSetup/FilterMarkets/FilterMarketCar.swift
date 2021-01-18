//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal

public enum FilterMarketCar: String, CaseIterable {
    case norway = "car-norway"
    case abroad = "car-abroad"
    case mobileHome = "mobile-home"
    case caravan
}

// MARK: - FilterConfiguration

extension FilterMarketCar: FilterConfiguration {
    public var preferenceFilterKeys: [FilterKey] {
        switch self {
        case .norway, .abroad:
            return [.published, .dealerSegment, .priceChanged]
        case .mobileHome, .caravan:
            return [.published, .caravanDealerSegment]
        }
    }

    public var rootLevelFilterKeys: [FilterKey] {
        switch self {
        case .norway:
            return [
                .make,
                .salesForm,
                .year,
                .mileage,
                .leasepriceInit,
                .leasepriceMonth,
                .batteryCapacity,
                .drivingRange,
                .maxTrailerWeight,
                .price,
                .map,
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
                .map,
                .location,
                .year,
                .batteryCapacity,
                .drivingRange,
                .maxTrailerWeight,
                .price,
                .mileage,
                .engineEffect,
                .numberOfSeats,
                .bodyType,
                .engineFuel,
                .exteriorColour,
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
                .salesForm,
                .map,
                .location,
                .make,
                .year,
                .price,
                .mileage,
                .mobileHomeSegment,
                .noOfSleepers,
                .numberOfSeats,
                .engineEffect,
                .wheelDrive,
                .transmission,
                .length,
                .weight,
            ]
        case .caravan:
            return [
                .salesForm,
                .map,
                .location,
                .make,
                .year,
                .price,
                .mileage,
                .caravanSegment,
                .noOfSleepers,
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
            .batteryCapacity,
            .drivingRange,
            .maxTrailerWeight,
        ]
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
            switch self {
            case .norway, .abroad:
                return .yearConfiguration(minimumValue: 1950)
            case .mobileHome, .caravan:
                return .yearConfiguration(minimumValue: 1990)
            }
        case .mileage:
            switch self {
            case .caravan:
                return .mileageConfiguration(maximumValue: 20000)
            default:
                return .mileageConfiguration(maximumValue: 200_000)
            }
        case .price:
            switch self {
            case .norway, .abroad, .caravan:
                return .configuration(minimumValue: 0, maximumValue: 700_000, increment: 10000, unit: .currency)
            case .mobileHome:
                return .configuration(minimumValue: 0, maximumValue: 1_000_000, increment: 10000, unit: .currency)
            }
        case .leasepriceInit:
            return .configuration(minimumValue: 0, maximumValue: 150_000, increment: 10000, unit: .currency)
        case .leasepriceMonth:
            return .configuration(minimumValue: 0, maximumValue: 10000, increment: 1000, unit: .currency)
        case .engineEffect:
            switch self {
            case .norway, .abroad:
                return .horsePowerConfiguration(minimumValue: 0, maximumValue: 500)
            default:
                return .horsePowerConfiguration(minimumValue: 0, maximumValue: 300)
            }
        case .numberOfSeats:
            switch self {
            case .norway, .abroad:
                return .numberOfSeatsConfiguration(maximumValue: 10)
            case .mobileHome:
                return .numberOfSeatsConfiguration(maximumValue: 8)
            default:
                return nil
            }
        case .noOfSleepers:
            return .numberOfItemsConfiguration(minimumValue: 0, maximumValue: 8)
        case .length:
            switch self {
            case .mobileHome:
                return .configuration(minimumValue: 600, maximumValue: 950, increment: 50, unit: .centimeters)
            case .caravan:
                return .configuration(minimumValue: 500, maximumValue: 950, increment: 50, unit: .centimeters)
            default:
                return nil
            }
        case .width:
            return .configuration(minimumValue: 200, maximumValue: 350, increment: 10, unit: .centimeters)
        case .weight:
            switch self {
            case .mobileHome:
                return .configuration(minimumValue: 3500, maximumValue: 7500, increment: 100, unit: .kilograms)
            case .caravan:
                return .configuration(minimumValue: 1000, maximumValue: 3500, increment: 100, unit: .kilograms)
            default:
                return nil
            }
        case .batteryCapacity:
            return .configuration(minimumValue: 0, maximumValue: 150, increment: 10, unit: .kiloWattHour)
        case .drivingRange:
            return .configuration(minimumValue: 0, maximumValue: 750, increment: 50, unit: .kilometers)
        case .maxTrailerWeight:
            return .configuration(minimumValue: 0, maximumValue: 4000, increment: 200, unit: .kilograms)
        default:
            return nil
        }
    }

    public func stepperConfiguration(forKey key: FilterKey) -> StepperFilterConfiguration? {
        return nil
    }
}
