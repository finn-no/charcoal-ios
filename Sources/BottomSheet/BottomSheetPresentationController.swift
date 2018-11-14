//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol BottomSheetPresentationControllerDelegate: UIAdaptivePresentationControllerDelegate {
    func bottomsheetPresentationController(_ bottomsheetPresentationController: BottomSheetPresentationController, willTransitionFromContentSizeMode current: BottomSheetPresentationController.ContentSizeMode, to new: BottomSheetPresentationController.ContentSizeMode)
    func bottomsheetPresentationController(_ bottomsheetPresentationController: BottomSheetPresentationController, didTransitionFromContentSizeMode current: BottomSheetPresentationController.ContentSizeMode, to new: BottomSheetPresentationController.ContentSizeMode)
    func bottomsheetPresentationController(_ bottomsheetPresentationController: BottomSheetPresentationController, shouldBeginTransitionWithTranslation translation: CGPoint, from contentSizeMode: BottomSheetPresentationController.ContentSizeMode) -> Bool
}

public final class BottomSheetPresentationController: UIPresentationController {
    private lazy var dimmingView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPresentedViewController))
        view.addGestureRecognizer(tapGesture)
        return view
    }()

    private lazy var swipeHandle: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .sardine
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var swipeHandleContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .milk
        view.layer.cornerRadius = .mediumLargeSpacing
        view.isUserInteractionEnabled = false
        return view
    }()

    private static let swipeHandleSize = CGSize(width: 33, height: 4)

    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(sender:)))
        panGestureRecognizer.delegate = self
        return panGestureRecognizer
    }()

    private var presentedViewTopAnchorConstraint: NSLayoutConstraint?

    /// The percentage of the tranisitioning threshold when panning between expanded and compact. Value between 0.0 and 1.0
    public var transitionThresholdInPercentage: CGFloat = 0.40
    /// The percentage of the dismissal threshold. Value between 0.0 and 1.0
    public var dismisalThresholdInPercentage: CGFloat = 0.5
    /// The current content size mode of the bottomsheet
    public private(set) var currentContentSizeMode: ContentSizeMode
    /// The interaction controller for dismissal
    public private(set) var interactiveDismissalController: BottomSheetInteractiveDismissalController?

    public override var presentationStyle: UIModalPresentationStyle {
        return .overCurrentContext
    }

    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerViewFrame = containerView?.frame else {
            return .zero
        }

        return rect(for: currentContentSizeMode, in: containerViewFrame)
    }

    private var bottomSheetPresentationControllerDelegate: BottomSheetPresentationControllerDelegate? {
        return (presentedViewController as? FilterNavigationController)?.currentFilterViewController
    }

    public override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        currentContentSizeMode = .compact
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    public override func containerViewWillLayoutSubviews() {
        guard let containerView = containerView, let presentedView = presentedView, presentedView.superview != nil, dimmingView.superview != nil else {
            return
        }
        presentedView.translatesAutoresizingMaskIntoConstraints = false

        let presentedViewTopAnchor: NSLayoutConstraint
        if let presentedViewTopAnchorConstraint = presentedViewTopAnchorConstraint {
            presentedViewTopAnchor = presentedViewTopAnchorConstraint
        } else {
            let constant = frameOfPresentedViewInContainerView.origin.y
            presentedViewTopAnchor = presentedView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: constant)
        }

        NSLayoutConstraint.activate([
            presentedViewTopAnchor,
            presentedView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            presentedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            presentedView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

            swipeHandleContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            swipeHandleContainer.bottomAnchor.constraint(equalTo: presentedView.topAnchor, constant: .mediumLargeSpacing),
            swipeHandleContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            swipeHandleContainer.topAnchor.constraint(equalTo: presentedView.topAnchor, constant: -.mediumLargeSpacing),

            swipeHandle.bottomAnchor.constraint(equalTo: presentedView.topAnchor),
            swipeHandle.centerXAnchor.constraint(equalTo: swipeHandleContainer.centerXAnchor),
            swipeHandle.widthAnchor.constraint(equalToConstant: BottomSheetPresentationController.swipeHandleSize.width),
            swipeHandle.heightAnchor.constraint(equalToConstant: BottomSheetPresentationController.swipeHandleSize.height),
        ])

        presentedViewTopAnchorConstraint = presentedViewTopAnchor
    }

    public override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }

        containerView.addSubview(dimmingView)
        presentedView?.addSubview(swipeHandleContainer)
        presentedView?.sendSubviewToBack(swipeHandleContainer)
        swipeHandleContainer.addSubview(swipeHandle)

        dimmingView.alpha = 0.0

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.dimmingView.alpha = 1.0
        }, completion: nil)

        bottomSheetPresentationControllerDelegate?.bottomsheetPresentationController(self, willTransitionFromContentSizeMode: currentContentSizeMode, to: currentContentSizeMode)
    }

    public override func presentationTransitionDidEnd(_ completed: Bool) {
        guard completed else {
            dimmingView.removeFromSuperview()
            swipeHandleContainer.removeFromSuperview()
            return
        }

        guard let containerView = containerView, let presentedView = presentedView else {
            return
        }

        containerView.addGestureRecognizer(panGestureRecognizer)

        interactiveDismissalController = BottomSheetInteractiveDismissalController(containerView: containerView, presentedView: presentedView, dismissalTransitioningRect: dismissalTransitionRect(in: containerView.frame), dismissalPercentageThreshold: dismisalThresholdInPercentage)
        interactiveDismissalController?.dismissalDidBegin = dismissPresentedViewController

        bottomSheetPresentationControllerDelegate?.bottomsheetPresentationController(self, didTransitionFromContentSizeMode: currentContentSizeMode, to: currentContentSizeMode)
    }

    public override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.dimmingView.alpha = 0.0
        }, completion: nil)
    }

    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        guard completed else {
            containerView?.layoutIfNeeded()
            return
        }

        dimmingView.removeFromSuperview()
        swipeHandle.removeFromSuperview()
        presentedViewTopAnchorConstraint = nil
    }
}

// MARK: - ContentSizeMode

public extension BottomSheetPresentationController {
    enum ContentSizeMode {
        case compact, expanded

        func bottomSheetHeight(for containerHeight: CGFloat) -> CGFloat {
            let expandedHeightCalcuation = { (0.92 * containerHeight).rounded() }
            switch self {
            case .compact:
                if !isSupported(for: containerHeight) {
                    return expandedHeightCalcuation()
                }
                let compactHeight: CGFloat
                if containerHeight > 800 {
                    compactHeight = 0.6 * containerHeight
                } else {
                    compactHeight = 0.7 * containerHeight
                }
                return max(450, compactHeight.rounded())
            case .expanded:
                return expandedHeightCalcuation()
            }
        }

        func isSupported(for containerHeight: CGFloat) -> Bool {
            if self == .compact && containerHeight < 570 {
                return false
            }
            return true
        }
    }
}

// MARK: - Transitions

public extension BottomSheetPresentationController {
    func transition(to contentSizeMode: ContentSizeMode) {
        guard let containerView = containerView else {
            return
        }

        let fromContentSizeMode = currentContentSizeMode
        let newContentSizeMode: ContentSizeMode
        if contentSizeMode.isSupported(for: containerView.frame.height) {
            newContentSizeMode = contentSizeMode
        } else {
            newContentSizeMode = .expanded
        }

        presentedViewTopAnchorConstraint?.constant = rect(for: newContentSizeMode, in: containerView.frame).origin.y

        let animations: (() -> Void) = { [weak self] in
            self?.containerView?.layoutIfNeeded()
        }

        let completion: ((Bool) -> Void) = { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.currentContentSizeMode = newContentSizeMode

            strongSelf.bottomSheetPresentationControllerDelegate?.bottomsheetPresentationController(strongSelf, didTransitionFromContentSizeMode: fromContentSizeMode, to: newContentSizeMode)
        }

        bottomSheetPresentationControllerDelegate?.bottomsheetPresentationController(self, willTransitionFromContentSizeMode: fromContentSizeMode, to: newContentSizeMode)

        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: [.curveEaseInOut], animations: animations, completion: completion)
    }
}

// MARK: - Helpers

private extension BottomSheetPresentationController {
    func rect(for contentSizeMode: ContentSizeMode, in rect: CGRect) -> CGRect {
        let height = contentSizeMode.bottomSheetHeight(for: rect.height)
        let origin = CGPoint(x: 0, y: rect.height - height)
        let size = CGSize(width: rect.width, height: height)

        return CGRect(origin: origin, size: size)
    }

    func transitionRect(in rect: CGRect) -> CGRect {
        let compactSizeRect = self.rect(for: .compact, in: rect)
        let expandedSizeRect = self.rect(for: .expanded, in: rect)
        let transitioningRect = CGRect(x: rect.origin.x, y: expandedSizeRect.origin.y, width: rect.width, height: compactSizeRect.origin.y - expandedSizeRect.origin.y)

        return transitioningRect
    }

    func transitionRect(for contententSizeMode: ContentSizeMode, in rect: CGRect, transitioningThreshold: CGFloat) -> CGRect {
        let transitioningRect = transitionRect(in: rect)

        switch contententSizeMode {
        case .compact:
            let thresholdInPoints = transitioningRect.height * transitioningThreshold
            return CGRect(x: transitioningRect.origin.x, y: transitioningRect.maxY - thresholdInPoints, width: transitioningRect.width, height: rect.height - (transitioningRect.maxY - thresholdInPoints))
        case .expanded:
            let thresholdInPoints = transitioningRect.height * transitioningThreshold
            return CGRect(x: transitioningRect.origin.x, y: 0, width: transitioningRect.width, height: transitioningRect.minY + thresholdInPoints)
        }
    }

    func dismissalTransitionRect(in rect: CGRect, dismissalThreshold: CGFloat = 0.0) -> CGRect {
        let swipeBarOffset = -(.mediumSpacing + BottomSheetPresentationController.swipeHandleSize.height)
        let compactSizeRect = self.rect(for: .compact, in: rect).offsetBy(dx: 0, dy: swipeBarOffset)
        let thresholdInPoints = compactSizeRect.height * dismissalThreshold

        return CGRect(x: compactSizeRect.origin.x, y: compactSizeRect.origin.y + thresholdInPoints, width: compactSizeRect.width, height: (compactSizeRect.height) - thresholdInPoints)
    }
}

// MARK: - Gestures

private extension BottomSheetPresentationController {
    enum VerticalPanDirection {
        case up, down
    }

    func verticalPanDirection(from verticalTranslation: CGFloat) -> VerticalPanDirection {
        return verticalTranslation.isLess(than: 0.0) ? VerticalPanDirection.up : .down
    }

    @objc func handlePanGesture(sender: UIPanGestureRecognizer) {
        guard let containerView = sender.view, let presentedView = presentedView else {
            return
        }

        let translation = sender.translation(in: containerView)
        let panDirection = verticalPanDirection(from: panGestureRecognizer.translation(in: panGestureRecognizer.view).y)

        switch sender.state {
        case .changed:
            let newTopAnchorConstant = rect(for: currentContentSizeMode, in: containerView.frame).origin.y + translation.y
            let minTopAnchorConstant = rect(for: .expanded, in: containerView.frame).minY
            let maxTopAnchorconstant = rect(for: .compact, in: containerView.frame).minY
            presentedViewTopAnchorConstraint?.constant = min(max(newTopAnchorConstant, minTopAnchorConstant), maxTopAnchorconstant)
            containerView.layoutIfNeeded()

        case .ended:
            let isTransitionHandledByInteractiveDismissal = (interactiveDismissalController?.percentComplete ?? 0.0) < 0.0

            if isTransitionHandledByInteractiveDismissal {
                return
            }

            let endPoint = CGPoint(x: presentedView.frame.origin.x, y: presentedView.frame.origin.y - presentedView.transform.ty)
            let compactTransitionRect = transitionRect(for: .compact, in: containerView.frame, transitioningThreshold: transitionThresholdInPercentage)
            let expandedTransitionRect = transitionRect(for: .expanded, in: containerView.frame, transitioningThreshold: transitionThresholdInPercentage)

            switch panDirection {
            case .up:
                if expandedTransitionRect.contains(endPoint) {
                    transition(to: .expanded)
                } else if compactTransitionRect.contains(endPoint) {
                    transition(to: .compact)
                } else {
                    transition(to: currentContentSizeMode)
                }
            case .down:
                if compactTransitionRect.contains(endPoint) {
                    transition(to: .compact)
                } else if expandedTransitionRect.contains(endPoint) {
                    transition(to: .expanded)
                } else {
                    transition(to: currentContentSizeMode)
                }
            }
        default:
            break
        }
    }

    @objc func dismissPresentedViewController() {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension BottomSheetPresentationController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === panGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: containerView)
            return bottomSheetPresentationControllerDelegate?.bottomsheetPresentationController(self, shouldBeginTransitionWithTranslation: translation, from: currentContentSizeMode) ?? true
        }

        return true
    }
}
