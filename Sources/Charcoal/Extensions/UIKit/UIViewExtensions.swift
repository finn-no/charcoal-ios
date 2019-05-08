//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension UIView {
    var windowSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        } else {
            return .zero
        }
    }
}
