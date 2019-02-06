//
//  Copyright © 2019 FINN.no. All rights reserved.
//

import Foundation

extension CCRangeFilterNode {
    enum Key: String, CaseIterable {
        case from = "_from", to = "_to"
    }

    enum Index: Int, CaseIterable {
        case from, to
    }
}

class CCRangeFilterNode: CCFilterNode {
    init(title: String, name: String) {
        super.init(title: title, name: name)
        setup()
    }
}

extension CCRangeFilterNode {
    func setup() {
        children = Index.allCases.map { CCFilterNode(title: "", name: name + Key.allCases[$0.rawValue].rawValue) }
    }
}
