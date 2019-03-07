//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol FilterConfiguration {
    var preferenceFilters: [String] { get }
    var rootLevelFilters: [String] { get }
    var contextFilters: Set<String> { get }
    var mutuallyExclusiveFilters: Set<String> { get }

    func handlesVerticalId(_ vertical: String) -> Bool
    func rangeConfiguration(forKey key: String) -> RangeFilterConfiguration?
    func stepperConfiguration(forKey key: String) -> StepperFilterConfiguration?
}

// MARK: - Extensions

public extension FilterConfiguration {
    func mutuallyExclusiveFilters(for filter: String) -> Set<String> {
        guard mutuallyExclusiveFilters.contains(filter) else {
            return []
        }

        return mutuallyExclusiveFilters.filter({ $0 != filter })
    }
}
