//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol CCFilterConfiguration {
    func viewController(for filterNode: CCFilterNode) -> CCViewController?
}
