//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

enum FilterMarketBoat: String, CaseIterable {
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
    func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical
    }

    var preferenceFilterKeys: [FilterKey] {
        switch self {
        case .boatSale:
            return [.published, .segment]
        default:
            return [.published]
        }
    }

    var supportedFiltersKeys: [FilterKey] {
        switch self {
        case .boatSale:
            return [
                .location,
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
                .location,
                .boatClass,
                .price,
            ]
        case .boatRent:
            return [
                .location,
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
                .location,
                .type,
                .price,
                .engineEffect,
                .dealerSegment,
            ]
        case .boatPartsMotorWanted:
            return [
                .location,
                .type,
                .price,
                .engineEffect,
            ]
        case .boatDock:
            return [
                .location,
                .width,
                .price,
                .dealerSegment,
            ]
        case .boatDockWanted:
            return [
                .location,
                .width,
                .price,
            ]
        }
    }

    var mapFilterKey: FilterKey? {
        return .location
    }

    func createFilterInfoFrom(rangeFilterData: FilterData) -> FilterInfoType? {
        return nil
    }
}
