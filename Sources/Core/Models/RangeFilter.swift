//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

final class RangeFilter: Filter {

    // MARK: - Internal properties

    let lowValueFilter: Filter
    let highValueFilter: Filter

    init(title: String, name: String, lowValueKey: String, highValueKey: String, kind: Kind = .normal) {
        lowValueFilter = Filter(title: "", key: lowValueKey)
        highValueFilter = Filter(title: "", key: highValueKey)
        super.init(title: title, key: name, kind: kind)
        setup()
    }
}

extension RangeFilter {
    func setup() {
        add(subfilter: lowValueFilter)
        add(subfilter: highValueFilter)
    }
}
