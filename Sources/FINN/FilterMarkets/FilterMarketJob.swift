//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterMarketJob: String, CaseIterable {
    case fullTime = "job-full-time"
    case partTime = "job-part-time"
    case management = "job-management"
}

// MARK: - FilterConfiguration

extension FilterMarketJob: FINNFilterConfiguration {
    public var preferenceFilterKeys: [FilterKey] {
        return [.published]
    }

    public var supportedFiltersKeys: [FilterKey] {
        switch self {
        case .partTime:
            return [
                .map,
                .location,
                .occupation,
                .industry,
                .jobDuration,
                .jobSector,
            ]
        case .fullTime, .management:
            return [
                .map,
                .location,
                .occupation,
                .industry,
                .jobDuration,
                .extent,
                .jobSector,
                .managerRole,
            ]
        }
    }

    public var contextFilterKeys: Set<FilterKey> {
        return []
    }

    public var mutuallyExclusiveFilterKeys: Set<FilterKey> {
        return [.location, .map]
    }

    public var searchFilterKey: FilterKey? {
        return .query
    }

    public var preferencesFilterKey: FilterKey? {
        return .preferences
    }

    public func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical
    }

    public func rangeViewModel(forKey key: String) -> RangeFilterInfo? {
        return nil
    }
}
