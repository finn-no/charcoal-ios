//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class FilterContainer {

    // MARK: - Public properties

    public var verticals: [Vertical]?

    // MARK: - Private properties

    let rootFilter: Filter

    // MARK: - Setup

    init(root: Filter) {
        rootFilter = root
    }
}
