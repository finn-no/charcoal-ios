//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

enum FilterMarket: String {
    case bap, realestate, car

    init?(market: String) {
        guard let market = FilterMarket.allMarkets.first(where: { market.hasPrefix($0.rawValue) }) else {
            return nil
        }

        self = market
    }

    static var allMarkets: [FilterMarket] {
        return [.bap, .realestate, car]
    }

    var preferenceFilterKeys: [FilterKey] {
        switch self {
        case .bap:
            return [.searchType, .segment, .condition, .published]
        case .realestate:
            return [.published, .isSold, .isNewProperty, .isSold]
        case .car:
            return [.condition, .published, .priceChanged, .dealerSegment]
        }
    }

    var supportedFiltersKeys: [FilterKey] {
        switch self {
        case .bap:
            return [
                .location,
                .category,
                .price,
            ]
        case .realestate:
            return [
                .location,
                .price,
                .priceCollective,
                .rent,
                .area,
                .noOfBedrooms,
                .constructionYear,
                .propertyType,
                .ownershipType,
                .facilities,
                .viewing,
                .floorNavigator,
                .energyLabel,
                .plotArea,
            ]
        case .car:
            return [
                .make,
                .salesForm,
                .year,
                .mileage,
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
                .warrantyInsurance,
                .wheelSets,
                .registrationClass,
            ]
        }
    }
}
