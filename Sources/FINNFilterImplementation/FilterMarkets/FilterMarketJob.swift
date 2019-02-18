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
    public func viewModel(forKey key: String) -> RangeFilterInfo? {
        return nil
    }

    public func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical
    }

    public var preferenceFilterKeys: [FilterKey] {
        return [.published]
    }

    public var supportedFiltersKeys: [FilterKey] {
        switch self {
        case .partTime:
            return [
                .location,
                .occupation,
                .industry,
                .jobDuration,
                .jobSector,
            ]
        case .fullTime, .management:
            return [
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

    public var mapFilterKey: FilterKey? {
        return .location
    }
}
