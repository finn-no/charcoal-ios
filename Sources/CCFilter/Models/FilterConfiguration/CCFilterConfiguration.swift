//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public protocol CCFilterConfiguration {
    func viewController(for filterNode: CCFilterNode) -> CCViewController?
}
