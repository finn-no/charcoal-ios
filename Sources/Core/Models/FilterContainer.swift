//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class FilterContainer {

    // MARK: - Public properties

    public var verticals: [Vertical]?
    public var rootFilter: Filter

    // MARK: - Setup

    init(root: Filter) {
        rootFilter = root
    }

    // MARK: - Public methods

    public func merge(with other: FilterContainer) {
        rootFilter.merge(with: other.rootFilter)
    }
}
