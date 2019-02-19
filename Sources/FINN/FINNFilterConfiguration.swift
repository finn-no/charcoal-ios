//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FINNFilterConfiguration: FilterConfiguration {
    var preferenceFilterKeys: [FilterKey] { get }
    var supportedFiltersKeys: [FilterKey] { get }
    var contextFilters: Set<FilterKey> { get }
    var mapFilterParentFilterKey: FilterKey? { get }
    var searchFilterKey: FilterKey? { get }
    var preferencesFilterKey: FilterKey? { get }
}

public extension FINNFilterConfiguration {
    var preferenceFilterKeys: [String] {
        return preferenceFilterKeys.map({ $0.rawValue })
    }

    var supportedFiltersKeys: [String] {
        return supportedFiltersKeys.map({ $0.rawValue })
    }

    var contextFilters: Set<String> {
        return Set(contextFilters.map({ $0.rawValue }))
    }

    var mapFilterParentFilterKey: String? {
        return mapFilterParentFilterKey?.rawValue
    }

    var searchFilterKey: String? {
        return searchFilterKey?.rawValue
    }

    var preferencesFilterKey: String? {
        return preferencesFilterKey?.rawValue
    }
}
