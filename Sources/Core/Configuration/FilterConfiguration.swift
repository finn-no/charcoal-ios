//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterConfiguration {
    var preferenceFilterKeys: [String] { get }
    var supportedFiltersKeys: [String] { get }
    var contextFilters: Set<String> { get }
    var filterKeyWithMapSubfilter: String? { get }
    var searchFilterKey: String? { get }
    var preferencesFilterKey: String? { get }

    func handlesVerticalId(_ vertical: String) -> Bool
    func rangeViewModel(forKey key: String) -> RangeFilterInfo?
}
