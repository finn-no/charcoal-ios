//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public class FilterNavigationController: UINavigationController {
    public var currentFilterViewController: AnyFilterViewController? {
        return topViewController as? AnyFilterViewController
    }
}
