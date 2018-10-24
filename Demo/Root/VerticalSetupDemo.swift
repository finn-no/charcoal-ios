//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit

struct VerticalSetupDemo {
    let verticals: [String: [Vertical]]
    func subVerticals(for market: String) -> [Vertical] {
        return verticals[market] ?? []
    }
}

struct VerticalDemo: Vertical {
    let id: String
    let title: String
    let isCurrent: Bool
    let isExternal: Bool
}
