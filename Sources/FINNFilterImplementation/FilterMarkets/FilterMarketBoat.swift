//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

enum FilterMarketBoat: String, CaseIterable {
    case bap
}

// MARK: - FilterConfiguration

extension FilterMarketBoat: FilterConfiguration {
    func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical || vertical.hasPrefix(rawValue + "-")
    }

    var preferenceFilterKeys: [FilterKey] {
        return []
    }

    var supportedFiltersKeys: [FilterKey] {
        return [
        ]
    }

    var mapFilterKey: FilterKey? {
        return .location
    }

    func createFilterInfoFrom(rangeFilterData: FilterData) -> FilterInfoType? {
        return nil
    }
}
