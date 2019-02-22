//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FINNFilterConfiguration: FilterConfiguration {
    var preferenceFilterKeys: [FilterKey] { get }
    var supportedFiltersKeys: [FilterKey] { get }
    var contextFilterKeys: Set<FilterKey> { get }
    var mutuallyExclusiveFilterKeys: Set<FilterKey> { get }
    var searchFilterKey: FilterKey? { get }
    var preferencesFilterKey: FilterKey? { get }
}

public extension FINNFilterConfiguration {
    var preferenceFilters: [String] {
        return preferenceFilterKeys.map({ $0.rawValue })
    }

    var supportedFilters: [String] {
        return supportedFiltersKeys.map({ $0.rawValue })
    }

    var contextFilters: Set<String> {
        return Set(contextFilterKeys.map({ $0.rawValue }))
    }

    var mutuallyExclusiveFilters: Set<String> {
        return Set(mutuallyExclusiveFilterKeys.map({ $0.rawValue }))
    }

    var searchFilter: String? {
        return searchFilterKey?.rawValue
    }

    var preferencesFilter: String? {
        return preferencesFilterKey?.rawValue
    }
}
