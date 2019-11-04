//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension UIColor {
    class var silver: UIColor {
        return UIColor(red: 212 / 255, green: 228 / 255, blue: 242 / 255, alpha: 1.0)
    }

    class var spaceGray: UIColor {
        return UIColor(red: 128 / 255, green: 143 / 255, blue: 166 / 255, alpha: 1.0)
    }

    class var chevron: UIColor {
        return UIColor(red: 199 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1.0)
    }

    class var darkIce: UIColor {
        return UIColor(red: 38 / 255, green: 38 / 255, blue: 51 / 255, alpha: 1.0)
    }
}

extension CGColor {
    class var silver: CGColor {
        return UIColor.silver.cgColor
    }
}
