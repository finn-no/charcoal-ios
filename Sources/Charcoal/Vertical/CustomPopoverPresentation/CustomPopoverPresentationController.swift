//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol CustomPopoverPresentationControllerDelegate: UIPopoverPresentationControllerDelegate {
    func customPopoverPresentationControllerWillDismissPopover(_ customPopoverPresentationController: CustomPopoverPresentationController)
}

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
        set {
            _ = newValue
            assertionFailure("Only UIPopoverArrowDirection.up is currently permitted for \(String(describing: type(of: self))).")
        }
    }

    private var _popoverLayouMargins: UIEdgeInsets?

    // MARK: - Overrides

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
        super.permittedArrowDirections = [.up]
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

        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.addTarget(self, action: #selector(handleSnaphotViewGesture(_:)))
        snapshotView.addGestureRecognizer(tapGestureRecognizer)

        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
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
        (delegate as? CustomPopoverPresentationControllerDelegate)?.customPopoverPresentationControllerWillDismissPopover(self)

        super.dismissalTransitionWillBegin()

        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.snapshotView?.alpha = 0.0
            self?.presentedViewController.view.alpha = 0.0
        })
    }

    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            snapshotView?.removeFromSuperview()
        }

        super.dismissalTransitionDidEnd(completed)
    }

    // MARK: - Actions

    @objc private func handleSnaphotViewGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Private extensions

private extension UIEdgeInsets {
    static let defaultPopoverLayoutMargins = UIEdgeInsets(top: .smallSpacing, left: 0, bottom: 0, right: 0)
}
