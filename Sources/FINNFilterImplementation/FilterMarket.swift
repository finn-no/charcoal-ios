//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

enum FilterMarket: VerticalConfiguration {
    enum Bap: String, VerticalConfiguration, CaseIterable {
        case bap = "bap-webstore"

        var preferenceFilterKeys: [FilterKey] {
            return [.searchType, .segment, .condition, .published]
        }

        var supportedFiltersKeys: [FilterKey] {
            return [
                .location,
                .category,
                .price,
            ]
        }
    }

    enum Realestate: String, VerticalConfiguration, CaseIterable {
        case homes = "realestate-homes"

        var preferenceFilterKeys: [FilterKey] {
            return [.published, .isSold, .isNewProperty, .isSold]
        }

        var supportedFiltersKeys: [FilterKey] {
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
        }
    }

    enum Car: String, VerticalConfiguration, CaseIterable {
        case norway = "car-norway"
        case abroad = "car-abroad"

        var preferenceFilterKeys: [FilterKey] {
            switch self {
            case .norway:
                return [.condition, .published, .priceChanged, .dealerSegment]
            case .abroad:
                return [.condition, .published, .priceChanged, .dealerSegment]
            }
        }

        var supportedFiltersKeys: [FilterKey] {
            switch self {
            case .norway:
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
            case .abroad:
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

    case bap(Bap)
    case realestate(Realestate)
    case car(Car)

    init?(market: String) {
        guard let market = FilterMarket.allCases.first(where: { market == $0.verticalId }) else {
            return nil
        }

        self = market
    }

    var verticalId: String {
        switch self {
        case let .bap(bap):
            return bap.rawValue
        case let .realestate(realestate):
            return realestate.rawValue
        case let .car(car):
            return car.rawValue
        }
    }

    var preferenceFilterKeys: [FilterKey] {
        switch self {
        case let .bap(bap):
            return bap.preferenceFilterKeys
        case let .realestate(realestate):
            return realestate.preferenceFilterKeys
        case let .car(car):
            return car.preferenceFilterKeys
        }
    }

    var supportedFiltersKeys: [FilterKey] {
        switch self {
        case let .bap(bap):
            return bap.supportedFiltersKeys
        case let .realestate(realestate):
            return realestate.supportedFiltersKeys
        case let .car(car):
            return car.supportedFiltersKeys
        }
    }
}

extension FilterMarket: CaseIterable {
    static var allCases: [FilterMarket] {
        return Bap.allCases.map(FilterMarket.bap)
            + Realestate.allCases.map(FilterMarket.realestate)
            + Car.allCases.map(FilterMarket.car)
    }
}

protocol VerticalConfiguration {
    var preferenceFilterKeys: [FilterKey] { get }
    var supportedFiltersKeys: [FilterKey] { get }
}
