//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class CCFilter {

    // MARK: - Private properties

    private var root: CCFilterNode

    // MARK: - Setup

    public init(root: CCFilterNode) {
        self.root = root
    }
}

public extension CCFilter {
    var queryItems: [URLQueryItem] {
        return root.queryItems
    }

    func reset() {
        root.reset()
    }
}
