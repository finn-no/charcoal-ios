//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public final class CustomPopoverPresentationTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public var sourceView: UIView?

    public var shouldDismissPopoverHandler: ((_ popoverPresentationController: UIPopoverPresentationController) -> Bool)?
    public var prepareForPopoverPresentationHandler: ((_ popoverPresentationController: UIPopoverPresentationController) -> Void)?
    public var didDismissPopoverHandler: ((_ popoverPresentationController: UIPopoverPresentationController) -> Void)?
    public var willDismissPopoverHandler: ((_ popoverPresentationController: UIPopoverPresentationController) -> Void)?

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

extension CustomPopoverPresentationTransitioningDelegate: CustomPopoverPresentationControllerDelegate {
    public func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return shouldDismissPopoverHandler?(popoverPresentationController) ?? true
    }

    public func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        prepareForPopoverPresentationHandler?(popoverPresentationController)
    }

    func customPopoverPresentationControllerWillDismissPopover(_ customPopoverPresentationController: CustomPopoverPresentationController) {
        willDismissPopoverHandler?(customPopoverPresentationController)
    }

    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        didDismissPopoverHandler?(popoverPresentationController)
    }

    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
