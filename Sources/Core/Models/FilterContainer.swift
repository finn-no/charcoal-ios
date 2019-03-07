//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class FilterContainer {

    // MARK: - Public properties

    public var verticals: [Vertical]?

    // MARK: - Internal properties

    var rootFilter: Filter

    // MARK: - Setup

    init(root: Filter) {
        rootFilter = root
    }

    // MARK: - Public methods

    public func merge(with other: FilterContainer) {
        rootFilter.merge(with: other.rootFilter)
    }

    public func resetHits() {
        resetHits(for: rootFilter)
    }

    // MARK: - Private methods

    private func resetHits(for filter: Filter) {
        filter.numberOfResults = 0
        for subfilter in filter.subfilters {
            resetHits(for: subfilter)
        }
    }
}
