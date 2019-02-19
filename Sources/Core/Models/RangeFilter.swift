//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

final class RangeFilter: Filter {
    let lowValueFilter: Filter
    let highValueFilter: Filter

    // MARK: - Init

    init(title: String, key: String, lowValueKey: String, highValueKey: String, kind: Kind = .normal) {
        lowValueFilter = Filter(title: "", key: lowValueKey)
        highValueFilter = Filter(title: "", key: highValueKey)
        super.init(title: title, key: key, kind: kind)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        add(subfilter: lowValueFilter)
        add(subfilter: highValueFilter)
    }
}
