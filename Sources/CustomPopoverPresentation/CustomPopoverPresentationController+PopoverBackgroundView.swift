//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension CustomPopoverPresentationController {
    class PopoverBackgroundView: UIPopoverBackgroundView {
        var arrowView: UIImageView?

        private var _arrowOffset: CGFloat = 0.0
        override var arrowOffset: CGFloat {
            get { return _arrowOffset }
            set {
                _arrowOffset = newValue
                setNeedsLayout()
            }
        }

        static let popoverArrowImage: UIImage? = {
            return UIImage(named: .popoverArrow, in: .filterKit)
        }()

        override var arrowDirection: UIPopoverArrowDirection {
            get { return .up }
            set { fatalError("Setting arrowDirection is not available for \(type(of: self))") }
        }

        override class var wantsDefaultContentAppearance: Bool {
            return false
        }

        override static func contentViewInsets() -> UIEdgeInsets {
            return UIEdgeInsets(top: .smallSpacing, left: 0, bottom: 0, right: 0)
        }

        override static func arrowBase() -> CGFloat {
            return popoverArrowImage?.size.width ?? 0.0
        }

        override static func arrowHeight() -> CGFloat {
            return popoverArrowImage?.size.height ?? 0.0
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            if arrowView == nil {
                let width = PopoverBackgroundView.arrowBase()
                let height = PopoverBackgroundView.arrowHeight()
                let x = ((self.frame.size.width / 2) + arrowOffset) - (width / 2)
                let y = PopoverBackgroundView.contentViewInsets().top
                let frame = CGRect(x: x, y: y, width: width, height: height)

                let arrowView = UIImageView(frame: frame)
                arrowView.image = PopoverBackgroundView.popoverArrowImage
                addSubview(arrowView)

                self.arrowView = arrowView
            }
        }
    }
}
