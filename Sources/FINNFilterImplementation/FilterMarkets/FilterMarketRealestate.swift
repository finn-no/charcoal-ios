//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

enum FilterMarketRealestate: String, CaseIterable {
    case homes = "realestate-homes"
}

extension FilterMarketRealestate: FilterConfiguration {
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
