//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class CustomPopoverPresentationController: UIPopoverPresentationController {
    private var snapshotView: UIView?

    public override var presentationStyle: UIModalPresentationStyle {
        return .popover
    }

    public override var arrowDirection: UIPopoverArrowDirection {
        return .up
    }

    public override var permittedArrowDirections: UIPopoverArrowDirection {
        get { return .up }
        set { fatalError("Only UIPopoverArrowDirection.up is currently permitted for \(String(describing: type(of: self))).") }
    }

    private lazy var dimmingView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return view
    }()

    private var _popoverLayouMargins: UIEdgeInsets?
    public override var popoverLayoutMargins: UIEdgeInsets {
        get {
            return _popoverLayouMargins ?? .defaultPopoverLayoutMargins
        }
        set {
            _popoverLayouMargins = newValue
        }
    }

    public override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        backgroundColor = .milk
        popoverBackgroundViewClass = PopoverBackgroundView.self
    }

    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        guard let sourceView = sourceView, let snapshotView = sourceView.snapshotView(afterScreenUpdates: false) else {
            return
        }

        snapshotView.frame = sourceView.convert(sourceView.bounds, to: containerView)
        snapshotView.alpha = 0.0
        containerView?.addSubview(snapshotView)
        self.snapshotView = snapshotView

        dimmingView.alpha = 0.0
        containerView?.insertSubview(dimmingView, at: 0)
        dimmingView.fillInSuperview()

        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.dimmingView.alpha = 1.0
            snapshotView.alpha = 1.0
        })
    }

    public override func presentationTransitionDidEnd(_ completed: Bool) {
        if completed == false {
            dimmingView.removeFromSuperview()
            snapshotView?.removeFromSuperview()
        }

        super.presentationTransitionDidEnd(completed)
    }

    public override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.snapshotView?.alpha = 0.0
            self?.dimmingView.alpha = 0.0
            self?.presentedViewController.view.alpha = 0.0
        })
    }

    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
            snapshotView?.removeFromSuperview()
        }

        super.dismissalTransitionDidEnd(completed)
    }
}

private extension UIEdgeInsets {
    static let defaultPopoverLayoutMargins = UIEdgeInsets(top: .smallSpacing, left: 0, bottom: 0, right: 0)
}
