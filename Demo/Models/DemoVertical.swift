//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal

struct DemoVertical: Vertical {
    let name: String
    let title: String
    var isCurrent: Bool
    let isExternal: Bool

    init(name: String, title: String, isCurrent: Bool = false, isExternal: Bool = false) {
        self.name = name
        self.title = title
        self.isCurrent = isCurrent
        self.isExternal = isExternal
    }
}
