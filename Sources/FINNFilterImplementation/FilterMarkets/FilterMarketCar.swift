//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

enum FilterMarketCar: String, CaseIterable {
    case norway = "car-norway"
    case abroad = "car-abroad"
}

extension FilterMarketCar: FilterConfiguration {
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
