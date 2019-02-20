//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FINNFilterConfiguration: FilterConfiguration {
    var preferenceFilterKeys: [FilterKey] { get }
    var supportedFiltersKeys: [FilterKey] { get }
    var contextFilters: Set<FilterKey> { get }
    var searchFilterKey: FilterKey? { get }
    var preferencesFilterKey: FilterKey? { get }
    var locationFilterKey: FilterKey? { get }
    var mapFilterKey: FilterKey? { get }
}

public extension FINNFilterConfiguration {
    var preferenceFilters: [String] {
        return preferenceFilterKeys.map({ $0.rawValue })
    }

    var supportedFilters: [String] {
        return supportedFiltersKeys.map({ $0.rawValue })
    }

    var contextFilters: Set<String> {
        return Set(contextFilters.map({ $0.rawValue }))
    }

    var searchFilter: String? {
        return searchFilterKey?.rawValue
    }

    var preferencesFilter: String? {
        return preferencesFilterKey?.rawValue
    }

    var locationFilter: String? {
        return locationFilterKey?.rawValue
    }

    var mapFilter: String? {
        return mapFilterKey?.rawValue
    }
}
