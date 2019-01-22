//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

enum FilterMarketMC: String, CaseIterable {
    case mc
    case mopedScooter = "moped-scooter"
    case snowmobile
    case atv
}

extension FilterMarketMC: FilterConfiguration {
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
