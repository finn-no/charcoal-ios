//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import UIKit

class Setup {
    var filterContainer: FilterContainer
    let verticals: [DemoVertical]

    var current: DemoVertical? {
        didSet {
            oldValue?.isCurrent = false
            current?.isCurrent = true
        }
    }

    init(filterContainer: FilterContainer, verticals: [DemoVertical]) {
        defer { current = verticals.first }
        self.filterContainer = filterContainer
        self.verticals = verticals
    }
}
