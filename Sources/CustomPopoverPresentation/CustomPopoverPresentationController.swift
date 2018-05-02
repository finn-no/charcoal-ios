//
//  Copyright © 2018 FINN.no. All rights reserved.
//

import UIKit

final class CustomPopoverPresentationController: UIPopoverPresentationController {
    
    private var snapshotView: UIView?
    
    override public var presentationStyle: UIModalPresentationStyle {
        return .popover
    }
    
    public override var arrowDirection: UIPopoverArrowDirection {
        return .up
    }
    
    private static let defaultPopoverLayoutMargins = UIEdgeInsets(top: .smallSpacing, left: 0, bottom: 0, right: 0)
    
    private var _popoverLayouMargins: UIEdgeInsets?
    public override var popoverLayoutMargins: UIEdgeInsets {
        get {
            return _popoverLayouMargins ?? CustomPopoverPresentationController.defaultPopoverLayoutMargins
        }
        set {
            _popoverLayouMargins = newValue
        }
    }
    
    public override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        backgroundColor = .milk
        self.popoverBackgroundViewClass = PopoverBackgroundView.self
    }
    
    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        guard let dimmingView = self.dimmingView, let sourceView = sourceView, let snapshotView = sourceView.snapshotView(afterScreenUpdates: false) else {
            return
        }
        
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        snapshotView.frame = sourceView.convert(sourceView.bounds, to: containerView)
        snapshotView.alpha = 0.0
        containerView?.addSubview(snapshotView)
        self.snapshotView = snapshotView
        
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            snapshotView.alpha = 1.0
        })
    }
    
    public override func presentationTransitionDidEnd(_ completed: Bool) {
        if completed == false {
            snapshotView?.removeFromSuperview()
        }
        
        super.presentationTransitionDidEnd(completed)
    }
    
    public override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.snapshotView?.alpha = 0.0
        })
    }
    
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            snapshotView?.removeFromSuperview()
        }
        
        super.dismissalTransitionDidEnd(completed)
    }
}

private extension CustomPopoverPresentationController {
    
    var dimmingView: UIView? {
        return containerView?.subviews.filter({ $0.isView(named: "UIDimmingView")}).first
    }
}

private extension UIView {
    func isView(named name: String) -> Bool {
        return String(describing: type(of: self)) == name
    }
}
