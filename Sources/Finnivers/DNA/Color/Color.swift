//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension UIColor {
    class var ice: UIColor {
        return UIColor(r: 241, g: 249, b: 255)!
    }

    class var milk: UIColor {
        return UIColor(r: 255, g: 255, b: 255)!
    }

    class var licorice: UIColor {
        return UIColor(r: 71, g: 68, b: 69)!
    }

    class var primaryBlue: UIColor {
        return UIColor(r: 0, g: 99, b: 251)!
    }

    class var secondaryBlue: UIColor {
        return UIColor(r: 6, g: 190, b: 251)!
    }

    class var stone: UIColor {
        return UIColor(r: 118, g: 118, b: 118)!
    }

    class var sardine: UIColor {
        return UIColor(r: 195, g: 204, b: 217)!
    }

    class var salmon: UIColor {
        return UIColor(r: 255, g: 206, b: 215)!
    }

    class var mint: UIColor {
        return UIColor(r: 204, g: 255, b: 236)!
    }

    class var toothPaste: UIColor {
        return UIColor(r: 182, g: 240, b: 255)!
    }

    class var banana: UIColor {
        return UIColor(r: 255, g: 245, b: 200)!
    }

    class var cherry: UIColor {
        return UIColor(r: 218, g: 36, b: 0)!
    }

    class var watermelon: UIColor {
        return UIColor(r: 255, g: 88, b: 68)!
    }

    class var pea: UIColor {
        return UIColor(r: 104, g: 226, b: 184)!
    }

    class var silver: UIColor {
        return UIColor(red: 212 / 255, green: 228 / 255, blue: 242 / 255, alpha: 1.0)
    }

    class var spaceGray: UIColor {
        return UIColor(red: 128 / 255, green: 143 / 255, blue: 166 / 255, alpha: 1.0)
    }

    convenience init?(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
}

extension CGColor {
    class var ice: CGColor {
        return UIColor.ice.cgColor
    }

    class var milk: CGColor {
        return UIColor.milk.cgColor
    }

    class var licorice: CGColor {
        return UIColor.licorice.cgColor
    }

    class var primaryBlue: CGColor {
        return UIColor.primaryBlue.cgColor
    }

    class var secondaryBlue: CGColor {
        return UIColor.secondaryBlue.cgColor
    }

    class var stone: CGColor {
        return UIColor.stone.cgColor
    }

    class var sardine: CGColor {
        return UIColor.sardine.cgColor
    }

    class var salmon: CGColor {
        return UIColor.salmon.cgColor
    }

    class var mint: CGColor {
        return UIColor.mint.cgColor
    }

    class var toothPaste: CGColor {
        return UIColor.toothPaste.cgColor
    }

    class var banana: CGColor {
        return UIColor.banana.cgColor
    }

    class var cherry: CGColor {
        return UIColor.cherry.cgColor
    }

    class var watermelon: CGColor {
        return UIColor.watermelon.cgColor
    }

    class var pea: CGColor {
        return UIColor.pea.cgColor
    }

    class var silver: CGColor {
        return UIColor.silver.cgColor
    }
}

// MARK: - Button

extension UIColor {
    class var callToActionButtonHighlightedBodyColor: UIColor {
        return primaryBlue.withAlphaComponent(0.8)
    }

    class var destructiveButtonHighlightedBodyColor: UIColor {
        return cherry.withAlphaComponent(0.8)
    }

    class var defaultButtonHighlightedBodyColor: UIColor {
        return UIColor(r: 241, g: 249, b: 255)!
    }

    class var linkButtonHighlightedTextColor: UIColor {
        return primaryBlue.withAlphaComponent(0.8)
    }

    class var flatButtonHighlightedTextColor: UIColor {
        return primaryBlue.withAlphaComponent(0.8)
    }
}

extension CGColor {
    class var callToActionButtonHighlightedBodyColor: CGColor {
        return UIColor.callToActionButtonHighlightedBodyColor.cgColor
    }

    class var destructiveButtonHighlightedBodyColor: CGColor {
        return UIColor.destructiveButtonHighlightedBodyColor.cgColor
    }

    class var defaultButtonHighlightedBodyColor: CGColor {
        return UIColor.defaultButtonHighlightedBodyColor.cgColor
    }

    class var linkButtonHighlightedTextColor: CGColor {
        return UIColor.linkButtonHighlightedTextColor.cgColor
    }

    class var flatButtonHighlightedTextColor: CGColor {
        return UIColor.flatButtonHighlightedTextColor.cgColor
    }
}
