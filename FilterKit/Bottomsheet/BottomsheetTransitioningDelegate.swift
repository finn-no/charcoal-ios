//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final public class BotomsheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private let animationController: BottomsheetTransitioningAnimator
    private var presentationController: BottomsheetPresentationController?
    
    public init(for viewController: UIViewController) {
        self.animationController = BottomsheetTransitioningAnimator()
        super.init()
        
        viewController.modalPresentationStyle = .custom
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController.transitionType = .presentation
        return animationController
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController.transitionType = .dismissal
        return animationController
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return presentationController?.interactiveDismissalController
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        guard let presentationController = presentationController else {
            self.presentationController = BottomsheetPresentationController(presentedViewController: presented, presenting: presenting)
            return self.presentationController
        }
        
        return presentationController
    }
}
