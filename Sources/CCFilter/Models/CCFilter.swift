//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class CCFilter {
    public var root: CCFilterNode

    public init(root: CCFilterNode) {
        self.root = root
    }
}

public extension CCFilter {
    var urlEncoded: String {
        return root.urlItems.joined(separator: "&")
    }
}
