//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class FilterContainer {
    // MARK: - Public properties

    public var verticals: [Vertical]?

    // MARK: - Internal properties

    public private(set) var rootFilters: [Filter]
    public private(set) var inlineFilter: Filter?
    public private(set) var freeTextFilter: Filter?
    public private(set) var numberOfResults: Int

    public var allFilters: [Filter] {
        return [freeTextFilter, inlineFilter].compactMap { $0 } + rootFilters
    }

    // MARK: - Setup

    public init(rootFilters: [Filter], freeTextFilter: Filter?, inlineFilter: Filter?, numberOfResults: Int) {
        self.rootFilters = rootFilters
        self.freeTextFilter = freeTextFilter
        self.inlineFilter = inlineFilter
        self.numberOfResults = numberOfResults
    }

    // MARK: - Public methods

    public func merge(with other: FilterContainer) {
        rootFilters.merge(with: other.rootFilters)

        if let otherInlineFilter = other.inlineFilter {
            if let inlineFilter = inlineFilter {
                inlineFilter.mergeSubfilters(with: otherInlineFilter)
            } else {
                inlineFilter = otherInlineFilter
            }
        }

        if let otherFreeTextFilter = other.freeTextFilter {
            freeTextFilter = otherFreeTextFilter
        }
    }

    public func resetHits() {
        numberOfResults = 0

        for filter in allFilters {
            resetHits(for: filter)
        }
    }

    // MARK: - Private methods

    private func resetHits(for filter: Filter) {
        filter.numberOfResults = 0

        for subfilter in filter.subfilters {
            resetHits(for: subfilter)
        }
    }
}
