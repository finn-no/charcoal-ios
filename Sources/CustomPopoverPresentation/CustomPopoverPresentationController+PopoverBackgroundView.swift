//
//  Copyright © 2018 FINN.no. All rights reserved.
//

import UIKit

extension CustomPopoverPresentationController {
    class PopoverBackgroundView: UIPopoverBackgroundView {
        
        static let defaultCornerRadius: CGFloat = 4.0
        
        var arrowView: UIImageView?
        
        private var _arrowOffset: CGFloat = 0.0
        override var arrowOffset: CGFloat {
            get { return _arrowOffset }
            set {
                _arrowOffset = newValue
                setNeedsLayout()
            }
        }
        
        override var arrowDirection: UIPopoverArrowDirection {
            get { return .up }
            set { fatalError("Setting arrowDirection is not available for \(type(of: self))") }
        }
        
        override class var wantsDefaultContentAppearance: Bool {
            return false
        }
        
        override static func contentViewInsets() -> UIEdgeInsets {
            return UIEdgeInsets(top: .verySmallSpacing, left: -10, bottom: 0, right: -10)
        }
        
        override static func arrowBase() -> CGFloat {
            return 10
        }
        
        override static func arrowHeight() -> CGFloat {
            return 10
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let insets = PopoverBackgroundView.contentViewInsets()
            if arrowView == nil {
                let width = PopoverBackgroundView.arrowBase()
                let height = PopoverBackgroundView.arrowHeight()
                let x = ((self.frame.size.width / 2)  + self.arrowOffset) - (width / 2)
                let y = insets.top + (height / 2)
                let frame = CGRect(x: x, y: y, width: width, height: height)
                
                let arrowView = UIImageView(frame: frame)
                arrowView.backgroundColor = .milk
                arrowView.transform = CGAffineTransform(rotationAngle: .pi / 4)
                addSubview(arrowView)
                
                self.arrowView = arrowView
            }
            
            layer.masksToBounds = false
            layer.shadowColor = UIColor.black.withAlphaComponent(0.7).cgColor
            layer.shadowOpacity = 0.5
            layer.shadowOffset = CGSize(width: 0, height: 1)
            layer.shadowRadius = 1.0
            let originMinidingInsets = CGPoint(x: self.frame.origin.x + insets.left , y: self.frame.origin.y + insets.top + PopoverBackgroundView.arrowHeight())
            let sizeMindingInsets = CGSize(width: self.frame.width - (insets.left + insets.right), height: self.frame.height - originMinidingInsets.y)
            let rectMindingInsets = CGRect(origin: originMinidingInsets, size: sizeMindingInsets)
            layer.shadowPath = UIBezierPath(rect: rectMindingInsets).cgPath
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
            
            superview?.subviews.forEach({ subview in
                if subview != self {
                    subview.layer.masksToBounds = true
                    subview.layer.cornerRadius = PopoverBackgroundView.defaultCornerRadius
                }
            })
        }
    }
}
