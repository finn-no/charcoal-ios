//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterConfiguration {
    var preferenceFilterKeys: [FilterKey] { get }
    var supportedFiltersKeys: [FilterKey] { get }
    var contextFilters: Set<FilterKey> { get }
    var filterKeyWithMapSubfilter: FilterKey? { get }
    var searchFilterKey: FilterKey? { get }
    var preferencesFilterKey: FilterKey? { get }

    func handlesVerticalId(_ vertical: String) -> Bool
    func viewModel(forKey key: String) -> RangeFilterInfo?
}
