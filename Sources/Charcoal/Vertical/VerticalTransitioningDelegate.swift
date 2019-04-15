//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class VerticalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return VerticalPresentationController(presentedViewController: presented,
                                              presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return VerticalPresentationAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return VerticalDismissionAnimator()
    }
}

final class VerticalPresentationController: UIPresentationController {
//    override func frameOfPresentedViewInContainerView() -> CGRect {
//        let height: CGFloat = 200
//        return CGRect(x: 0, y: containerView!.bounds.height - height, width: containerView!.bounds.width, height: height)
//    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}

final class VerticalPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView

        let animationDuration = transitionDuration(using: transitionContext)

        toViewController.view.transform = CGAffineTransform(translationX: 0, y: -containerView.bounds.height)
        //toViewController.view.clipsToBounds = true

        containerView.addSubview(toViewController.view)

        UIView.animate(withDuration: animationDuration, animations: {
            toViewController.view.transform = CGAffineTransform.identity
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}

final class VerticalDismissionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let containerView = transitionContext.containerView

        let animationDuration = transitionDuration(using: transitionContext)

        UIView.animate(withDuration: animationDuration, animations: {
            fromViewController.view.transform = CGAffineTransform(translationX: containerView.bounds.width, y: 0)
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
