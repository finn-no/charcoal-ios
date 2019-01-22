//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

protocol FilterConfiguration {
    func handlesVerticalId(_ vertical: String) -> Bool
    var preferenceFilterKeys: [FilterKey] { get }
    var supportedFiltersKeys: [FilterKey] { get }
    var mapFilterKey: FilterKey? { get }
}

enum FilterMarket: FilterConfiguration {
    enum Bap: String, FilterConfiguration, CaseIterable {
        case bap

        func handlesVerticalId(_ vertical: String) -> Bool {
            return rawValue == vertical || vertical.hasPrefix(rawValue + "-")
        }

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

        var mapFilterKey: FilterKey? {
            return .location
        }
    }

    enum Realestate: String, FilterConfiguration, CaseIterable {
        case homes = "realestate-homes"

        func handlesVerticalId(_ vertical: String) -> Bool {
            return rawValue == vertical
        }

        var preferenceFilterKeys: [FilterKey] {
            return [.published, .isSold, .isNewProperty, .isPrivateBroker]
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

        var mapFilterKey: FilterKey? {
            return .location
        }
    }

    enum Car: String, FilterConfiguration, CaseIterable {
        case norway = "car-norway"
        case abroad = "car-abroad"

        func handlesVerticalId(_ vertical: String) -> Bool {
            return rawValue == vertical
        }

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

        var mapFilterKey: FilterKey? {
            return .location
        }
    }

    enum MC: String, FilterConfiguration, CaseIterable {
        case mc
        case mopedScooter = "moped-scooter"
        case snowmobile
        case atv

        func handlesVerticalId(_ vertical: String) -> Bool {
            return rawValue == vertical
        }

        var preferenceFilterKeys: [FilterKey] {
            switch self {
            case .mc:
                return [.published, .segment, .dealerSegment]
            default:
                return [.published, .dealerSegment]
            }
        }

        var supportedFiltersKeys: [FilterKey] {
            switch self {
            case .mc:
                return [
                    .location,
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
                    .location,
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
                    .location,
                    .make,
                    .price,
                    .year,
                    .mileage,
                    .engineEffect,
                    .engineVolume,
                ]
            }
        }

        var mapFilterKey: FilterKey? {
            return .location
        }
    }

    enum Job: String, FilterConfiguration, CaseIterable {
        case fullTime = "job-full-time"
        case partTime = "job-part-time"
        case management = "job-management"

        func handlesVerticalId(_ vertical: String) -> Bool {
            return rawValue == vertical
        }

        var preferenceFilterKeys: [FilterKey] {
            return [.published]
        }

        var supportedFiltersKeys: [FilterKey] {
            switch self {
            case .partTime:
                return [
                    .location,
                    .occupation,
                    .industry,
                    .jobDuration,
                    .jobSector,
                ]
            case .fullTime, .management:
                return [
                    .location,
                    .occupation,
                    .industry,
                    .jobDuration,
                    .extent,
                    .jobSector,
                    .managerRole,
                ]
            }
        }

        var mapFilterKey: FilterKey? {
            return .location
        }
    }

    case bap(Bap)
    case realestate(Realestate)
    case car(Car)
    case mc(MC)
    case job(Job)

    init?(market: String) {
        guard let market = FilterMarket.allCases.first(where: { $0.handlesVerticalId(market) }) else {
            return nil
        }

        self = market
    }

    private var currentFilterConfig: FilterConfiguration {
        switch self {
        case let .bap(bap):
            return bap
        case let .realestate(realestate):
            return realestate
        case let .car(car):
            return car
        case let .mc(mc):
            return mc
        case let .job(job):
            return job
        }
    }

    func handlesVerticalId(_ vertical: String) -> Bool {
        return currentFilterConfig.handlesVerticalId(vertical)
    }

    var preferenceFilterKeys: [FilterKey] {
        return currentFilterConfig.preferenceFilterKeys
    }

    var supportedFiltersKeys: [FilterKey] {
        return currentFilterConfig.supportedFiltersKeys
    }

    var mapFilterKey: FilterKey? {
        return currentFilterConfig.mapFilterKey
    }
}

extension FilterMarket: CaseIterable {
    static var allCases: [FilterMarket] {
        return Bap.allCases.map(FilterMarket.bap)
            + Realestate.allCases.map(FilterMarket.realestate)
            + Car.allCases.map(FilterMarket.car)
            + MC.allCases.map(FilterMarket.mc)
            + Job.allCases.map(FilterMarket.job)
    }
}
