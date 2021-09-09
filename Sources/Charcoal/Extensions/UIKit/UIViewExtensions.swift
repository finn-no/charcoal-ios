//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension UIView {
    var windowSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.firstKeyWindow?.safeAreaInsets ?? .zero
        } else {
            return .zero
        }
    }
}

// MARK: - Private extension

private extension UIApplication {
    var firstKeyWindow: UIWindow? {
        windows.filter { $0.isKeyWindow }.first
    }
}
