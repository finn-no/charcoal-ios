//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public enum FilterMarketJob: String, CaseIterable {
    case fullTime = "job-full-time"
    case partTime = "job-part-time"
    case management = "job-management"
}

extension FilterMarketJob: CCFilterConfiguration {
    public func viewModel(for rangeNode: CCRangeFilterNode) -> RangeFilterInfo? {
        return createFilterInfoFrom(filterNode: rangeNode)
    }
}

// MARK: - FilterConfiguration

extension FilterMarketJob: FilterConfiguration {
    func handlesVerticalId(_ vertical: String) -> Bool {
        return rawValue == vertical
    }

    var preferenceFilterKeys: [FilterKey] {
        return [.published]
    }

    var supportedFiltersKeys: [FilterKey] {
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

    var mapFilterKey: FilterKey? {
        return .location
    }

    func createFilterInfoFrom(filterNode: CCFilterNode) -> RangeFilterInfo? {
        return nil
    }
}
