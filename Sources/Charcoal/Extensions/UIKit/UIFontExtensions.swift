//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension UIFont {
    static var bodyRegular: UIFont {
        return UIFont.detail.withSize(16).scaledFont(forTextStyle: .callout)
    }

    static func body(withSize size: CGFloat, textStyle: UIFont.TextStyle = .callout) -> UIFont {
        return UIFont.body.withSize(size).scaledFont(forTextStyle: textStyle)
    }

    static func bodyRegular(withSize size: CGFloat, textStyle: UIFont.TextStyle = .callout) -> UIFont {
        return UIFont.detail.withSize(size).scaledFont(forTextStyle: textStyle)
    }

    static func bodyStrong(withSize size: CGFloat, textStyle: UIFont.TextStyle = .callout) -> UIFont {
        return UIFont.bodyStrong.withSize(size).scaledFont(forTextStyle: textStyle)
    }
}
