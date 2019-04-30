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

extension FilterMarketJob: FilterConfiguration {
    public var preferenceFilterKeys: [FilterKey] {
        return [.published]
    }

    public var rootLevelFilterKeys: [FilterKey] {
        switch self {
        case .partTime:
            return [
                .map,
                .location,
                .occupation,
                .industry,
                .jobDuration,
                .jobSector,
                .applicationDeadline,
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
                .applicationDeadline,
            ]
        }
    }

    public var contextFilterKeys: Set<FilterKey> {
        return []
    }

    public var mutuallyExclusiveFilterKeys: Set<FilterKey> {
        return [.location, .map]
    }

    public var verticalsCalloutText: String? {
        return "callout.job".localized()
    }

    public func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical
    }

    public func rangeConfiguration(forKey key: FilterKey) -> RangeFilterConfiguration? {
        return nil
    }

    public func stepperConfiguration(forKey key: FilterKey) -> StepperFilterConfiguration? {
        return nil
    }
}
