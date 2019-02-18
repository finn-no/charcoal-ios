//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class CCFilter {

    // MARK: - Public properties

    public var verticals: [Vertical]?

    // MARK: - Private properties

    let root: CCFilterNode

    // MARK: - Setup

    init(root: CCFilterNode) {
        self.root = root
    }
}
