//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal

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

extension FilterMarketBoat: FilterConfiguration {
    public var preferenceFilterKeys: [FilterKey] {
        switch self {
        case .boatSale:
            return [.published, .dealerSegment, .segment]
        case .boatMotor, .boatParts, .boatDock:
            return [.published, .dealerSegment]
        default:
            return [.published]
        }
    }

    public var rootLevelFilterKeys: [FilterKey] {
        switch self {
        case .boatSale:
            return [
                .motorAdLocation,
                .boatClass,
                .make,
                .price,
                .lengthFeet,
                .width,
                .year,
                .speed,
                .motorIncluded,
                .motorType,
                .material,
                .fuel,
                .map,
                .location,
                .noOfSleepers,
                .noOfSeats,
                .motorSize,
            ]
        case .boatUsedWanted:
            return [
                .boatClass,
                .price,
                .map,
                .location,
            ]
        case .boatRent:
            return [
                .boatClass,
                .make,
                .price,
                .lengthFeet,
                .width,
                .year,
                .fuel,
                .map,
                .location,
                .noOfSleepers,
                .noOfSeats,
                .motorSize,
            ]
        case .boatMotor, .boatParts, .boatPartsMotorWanted:
            return [
                .type,
                .price,
                .map,
                .location,
                .engineEffect,
            ]
        case .boatDock, .boatDockWanted:
            return [
                .price,
                .width,
                .map,
                .location,
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

            return .configuration(minimumValue: 0, maximumValue: maximumValue, increment: increment, unit: .currency)
        case .lengthFeet:
            return .configuration(minimumValue: 0, maximumValue: 60, increment: 1, unit: .feet)
        case .year:
            return .yearConfiguration(minimumValue: 1985)
        case .speed:
            return .configuration(minimumValue: 0, maximumValue: 100, increment: 2, unit: .knots)
        case .motorSize, .engineEffect:
            return .horsePowerConfiguration(minimumValue: 0, maximumValue: 500)
        case .noOfSeats:
            return .numberOfSeatsConfiguration(maximumValue: 20)
        case .noOfSleepers:
            return .numberOfItemsConfiguration(minimumValue: 0, maximumValue: 10)
        case .width:
            return .configuration(minimumValue: 250, maximumValue: 500, increment: 10, unit: .centimeters)
        default:
            return nil
        }
    }

    public func stepperConfiguration(forKey key: FilterKey) -> StepperFilterConfiguration? {
        return nil
    }
}
