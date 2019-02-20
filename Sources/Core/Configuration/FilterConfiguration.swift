//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterConfiguration {
    var preferenceFilters: [String] { get }
    var supportedFilters: [String] { get }
    var contextFilters: Set<String> { get }
    var mutuallyExclusiveFilters: [[String]] { get }
    var searchFilter: String? { get }
    var preferencesFilter: String? { get }
    var locationFilter: String? { get }
    var mapFilter: String? { get }

    func handlesVerticalId(_ vertical: String) -> Bool
    func rangeViewModel(forKey key: String) -> RangeFilterInfo?
}
