//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension UIFont {
    static var bodyRegular: UIFont {
        return UIFont.detail.withSize(16).scaledFont(forTextStyle: .callout)
    }
}
