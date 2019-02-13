//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class CCRangeFilterNode: CCFilterNode {

    // MARK: - Internal properties

    let lowValueNode: CCFilterNode
    let highValueNode: CCFilterNode

    public init(title: String, name: String) {
        lowValueNode = CCFilterNode(title: "", name: name + "_from")
        highValueNode = CCFilterNode(title: "", name: name + "_to")
        super.init(title: title, name: name)
        setup()
    }
}

extension CCRangeFilterNode {
    func setup() {
        add(child: lowValueNode)
        add(child: highValueNode)
    }
}
