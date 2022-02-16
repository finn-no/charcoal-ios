//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import UIKit

class DemoVertical: Vertical {
    let id = UUID()
    let title: String
    var isCurrent: Bool
    let isExternal: Bool
    let calloutText: String? = nil

    init(title: String, isCurrent: Bool = false, isExternal: Bool = false) {
        self.title = title
        self.isCurrent = isCurrent
        self.isExternal = isExternal
    }

    static func create(_ count: Int, lastVerticalIsExternal: Bool) -> [DemoVertical] {
        guard count >= 1 else { return [] }
        return (1 ... count).map {
            let isExternal = lastVerticalIsExternal && count > 1 && ($0 % count == 0)
            return DemoVertical(title: "Vertical \($0)", isExternal: isExternal)
        }
    }
}
