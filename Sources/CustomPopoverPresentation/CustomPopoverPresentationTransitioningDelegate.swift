//
//  Copyright © 2018 FINN.no. All rights reserved.
//

import UIKit

final public class CustomPopoverPresentationTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public var sourceView: UIView?
    
    public var shouldDismissPopoverHandler: ((_ popoverPresentationController: UIPopoverPresentationController) -> Bool)?
    public var prepareForPopoverPresentationHandler: ((_ popoverPresentationController: UIPopoverPresentationController) -> Void)?
    public var popoverPresentationControllerDidDismissPopoverHandler: ((_ popoverPresentationController: UIPopoverPresentationController) -> Void)?
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        guard let sourceView = sourceView else {
            fatalError("No source view assigned for Popover Presentation. Please assign a sourceView before presentation.")
        }
        
        let popoverPresentationController = CustomPopoverPresentationController(presentedViewController: presented, presenting: presenting)
        popoverPresentationController.sourceView = sourceView
        popoverPresentationController.sourceRect = sourceView.bounds
        popoverPresentationController.delegate = self
        
        return popoverPresentationController
    }
}

extension CustomPopoverPresentationTransitioningDelegate: UIPopoverPresentationControllerDelegate {
    public func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return shouldDismissPopoverHandler?(popoverPresentationController) ?? true
    }
    
    public func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        prepareForPopoverPresentationHandler?(popoverPresentationController)
    }
    
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationControllerDidDismissPopoverHandler?(popoverPresentationController)
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
