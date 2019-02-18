//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class CCFilter {

    // MARK: - Public properties

    public var verticals: [Vertical]?

    // MARK: - Private properties

    let root: Filter

    // MARK: - Setup

    init(root: Filter) {
        self.root = root
    }
}
