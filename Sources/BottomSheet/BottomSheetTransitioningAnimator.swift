//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public final class BottomSheetTransitioningAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    public enum TransitionType {
        case presentation, dismissal
    }

    public var transitionType: TransitionType?

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let transitionType = transitionType else {
            transitionContext.completeTransition(false)
            return
        }

        switch transitionType {
        case .presentation:
            animatePresentationTransition(using: transitionContext)
        case .dismissal:
            animateDismissalTransition(using: transitionContext)
        }
    }
}

private extension BottomSheetTransitioningAnimator {
    func animatePresentationTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let presentedViewController = transitionContext.viewController(forKey: .to), let presentingViewController = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        let finalFrame = transitionContext.finalFrame(for: presentedViewController)
        presentedViewController.view.frame = transitionContext.finalFrame(for: presentedViewController)

        transitionContext.containerView.insertSubview(presentedViewController.view, aboveSubview: presentingViewController.view)

        let animationDuration = transitionDuration(using: transitionContext)
        let offScreenTransform = CGAffineTransform(translationX: 0, y: transitionContext.containerView.frame.maxY - finalFrame.origin.y)
        presentedViewController.view.transform = offScreenTransform

        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.curveEaseInOut], animations: {
            presentedViewController.view.transform = .identity
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

    func animateDismissalTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let dismissingViewController = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        let animationDuration = transitionDuration(using: transitionContext)
        let finalFrame = transitionContext.finalFrame(for: dismissingViewController)
        let offScreenTransform = CGAffineTransform(translationX: 0, y: transitionContext.containerView.frame.maxY - finalFrame.origin.y)

        UIView.animateKeyframes(withDuration: animationDuration, delay: 0, options: [], animations: {
            UIView.setAnimationCurve(.linear)
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                dismissingViewController.view.transform = offScreenTransform
            })
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
