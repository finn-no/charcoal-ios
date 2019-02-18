//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

final class RangeFilterNode: Filter {

    // MARK: - Internal properties

    let lowValueNode: Filter
    let highValueNode: Filter

    init(title: String, name: String) {
        lowValueNode = Filter(title: "", name: name + "_from")
        highValueNode = Filter(title: "", name: name + "_to")
        super.init(title: title, name: name)
        setup()
    }
}

extension RangeFilterNode {
    func setup() {
        add(child: lowValueNode)
        add(child: highValueNode)
    }
}
