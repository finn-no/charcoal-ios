//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension UIDevice {
    static var isPreiOS11: Bool {
        if #available(iOS 11.0, *) {
            return false
        }
        return true
    }
}
