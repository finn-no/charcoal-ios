//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

final class RangeFilter: Filter {

    // MARK: - Internal properties

    let lowValueFilter: Filter
    let highValueFilter: Filter

    init(title: String, name: String, lowValueName: String, highValueName: String, kind: Kind = .normal) {
        lowValueFilter = Filter(title: "", name: lowValueName)
        highValueFilter = Filter(title: "", name: highValueName)
        super.init(title: title, name: name, kind: kind)
        setup()
    }
}

extension RangeFilter {
    func setup() {
        add(subfilter: lowValueFilter)
        add(subfilter: highValueFilter)
    }
}
