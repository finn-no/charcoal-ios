//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal

class DemoVertical: Vertical {
    let id = UUID()
    let title: String
    var isCurrent: Bool
    let isExternal: Bool

    init(title: String, isCurrent: Bool = false, isExternal: Bool = false) {
        self.title = title
        self.isCurrent = isCurrent
        self.isExternal = isExternal
    }
}
