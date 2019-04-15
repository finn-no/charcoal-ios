//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension CustomPopoverPresentationController {
    class PopoverBackgroundView: UIPopoverBackgroundView {
        override var arrowDirection: UIPopoverArrowDirection {
            get { return .up }
            set {
                _ = newValue
                assertionFailure("Setting arrowDirection is not available for \(type(of: self))")
            }
        }

        override class var wantsDefaultContentAppearance: Bool {
            return false
        }

        override static func arrowBase() -> CGFloat {
            return 0
        }

        override static func arrowHeight() -> CGFloat {
            return 0
        }
    }
}
