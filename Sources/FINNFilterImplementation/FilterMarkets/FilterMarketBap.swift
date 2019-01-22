//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

enum FilterMarketBap: String, CaseIterable {
    case bap
}

extension FilterMarketBap: FilterConfiguration {
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
