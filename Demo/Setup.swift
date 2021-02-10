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

    init(markets: [DemoVertical] = [], filterContainer: FilterContainer) {
        self.markets = markets
        self.filterContainer = filterContainer
        current = markets.first
    }
}
