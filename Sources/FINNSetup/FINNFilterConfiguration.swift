//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterConfiguration {
    var preferenceFilterKeys: [FilterKey] { get }
    var rootLevelFilterKeys: [FilterKey] { get }
    var contextFilterKeys: Set<FilterKey> { get }
    var mutuallyExclusiveFilterKeys: Set<FilterKey> { get }
    var verticalsCalloutText: String? { get }

    func handlesVerticalId(_ vertical: String) -> Bool
    func rangeConfiguration(forKey key: FilterKey) -> RangeFilterConfiguration?
    func stepperConfiguration(forKey key: FilterKey) -> StepperFilterConfiguration?
}

public extension FilterConfiguration {
    func mutuallyExclusiveFilters(for key: FilterKey) -> Set<FilterKey> {
        guard mutuallyExclusiveFilterKeys.contains(key) else {
            return []
        }

        return mutuallyExclusiveFilterKeys.filter { $0 != key }
    }
}
