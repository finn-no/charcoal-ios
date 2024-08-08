//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import UIKit

class Setup {
    var filterContainer: FilterContainer
    var verticals: [DemoVertical]
    let showVerticalsReloadButton: Bool

    var current: DemoVertical? {
        didSet {
            oldValue?.isCurrent = false
            current?.isCurrent = true
        }
    }

    init(filterContainer: FilterContainer, verticals: [DemoVertical], showVerticalsReloadButton: Bool = false) {
        defer { current = verticals.first }
        self.filterContainer = filterContainer
        self.verticals = verticals
        self.showVerticalsReloadButton = showVerticalsReloadButton
    }
}
