//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public extension UIScreen {
    var hasWidthLessThaniPhone6DeviceScreenWidth: Bool {
        return bounds.width < 375
    }
}
