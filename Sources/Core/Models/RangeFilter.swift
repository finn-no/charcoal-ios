//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

final class RangeFilter: Filter {

    // MARK: - Internal properties

    let lowValueFilter: Filter
    let highValueFilter: Filter

    init(title: String, name: String) {
        lowValueFilter = Filter(title: "", name: name + "_from")
        highValueFilter = Filter(title: "", name: name + "_to")
        super.init(title: title, name: name)
        setup()
    }
}

extension RangeFilter {
    func setup() {
        add(child: lowValueFilter)
        add(child: highValueFilter)
    }
}
