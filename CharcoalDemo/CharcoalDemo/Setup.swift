//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import UIKit

class Setup {
    var filterContainer: FilterContainer
    let markets: [DemoVertical]

    var current: DemoVertical? {
        didSet {
            oldValue?.isCurrent = false
            current?.isCurrent = true
        }
    }

    init(filterContainer: FilterContainer) {
        defer { current = markets.first }
        self.filterContainer = filterContainer
        markets = (filterContainer.verticals as? [DemoVertical]) ?? []
    }
}
