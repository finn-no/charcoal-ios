//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final public class BottomsheetPresentationController: UIPresentationController {

    private lazy var dimmingView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPresentedViewController))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(sender:)))
        panGestureRecognizer.delegate = self
        return panGestureRecognizer
    }()
    
    private var presentedViewTopAnchorConstraint: NSLayoutConstraint?
    
    /// The percentage of the tranisitioning threshold. Value between 0.0 and 1.0
    public var transitionThresholdInPercentage: CGFloat = 0.25
    /// The percentage of the dismissal threshold. Value between 0.0 and 1.0
    public var dismisalThresholdInPercentage: CGFloat = 0.3
    /// The current content size mode of the bottomsheet
    public private(set) var currentContentSizeMode: ContentSizeMode
    /// The interaction controller for dismissal
    public private(set) var interactiveDismissalController: BottomsheetInteractiveDismissalController?

    public override var presentationStyle: UIModalPresentationStyle {
        return .overCurrentContext
    }
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerViewFrame = containerView?.frame else {
            return .zero
        }
        
        return rect(for: currentContentSizeMode, in: containerViewFrame)
    }

    override public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.currentContentSizeMode = .compact
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    public override func containerViewWillLayoutSubviews() {
        guard let containerView = containerView, let presentedView = presentedView, presentedView.superview != nil, dimmingView.superview != nil else {
            return
        }
        
        presentedView.translatesAutoresizingMaskIntoConstraints = false
        
        let topAnchorContraint: NSLayoutConstraint
        if let presentedViewTopAnchorConstraint = presentedViewTopAnchorConstraint {
            topAnchorContraint = presentedViewTopAnchorConstraint
        } else {
            let constant = rect(for: currentContentSizeMode, in: containerView.frame).origin.y
            topAnchorContraint = presentedView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: constant)
        }
        
        NSLayoutConstraint.activate([
            topAnchorContraint,
            presentedView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            presentedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            presentedView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
        
        self.presentedViewTopAnchorConstraint = topAnchorContraint
    }
    
    public override func presentationTransitionWillBegin() {
        containerView?.addSubview(dimmingView)
        dimmingView.alpha = 0.0
        
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.dimmingView.alpha = 1.0
        }, completion: nil)
    }
    
    public override func presentationTransitionDidEnd(_ completed: Bool) {
        guard completed else {
            dimmingView.removeFromSuperview()
            return
        }
        
        guard let containerView = containerView, let presentedView = presentedView else {
            return
        }
        
        containerView.addGestureRecognizer(panGestureRecognizer)
        
        self.interactiveDismissalController = BottomsheetInteractiveDismissalController(containerView: containerView, presentedView: presentedView, dismissalTransitioningRect: dismissalTransitionRect(in: containerView.frame), dismissalPercentageThreshold: dismisalThresholdInPercentage)
        
        interactiveDismissalController?.dismissalDidBegin = dismissPresentedViewController
    }
    
    public override func dismissalTransitionWillBegin() {
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.dimmingView.alpha = 0.0
        }, completion: nil)
    }
    
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        guard completed else {
            return
        }
        
        dimmingView.removeFromSuperview()
    }
}


// MARK: - ContentSizeMode
public extension BottomsheetPresentationController {
    enum ContentSizeMode {
        case compact, expanded
        
        var percentageOfSizeInSuperview: CGFloat {
            switch self {
            case .compact:
                return 0.4
            case .expanded:
                return 0.9
            }
        }
    }
}

// MARK: - Transitions
private extension BottomsheetPresentationController {
    func transition(to contentSizeMode: ContentSizeMode) {
        self.currentContentSizeMode = contentSizeMode
        
        presentedViewTopAnchorConstraint?.constant = frameOfPresentedViewInContainerView.origin.y
        
        let animations: (() -> Void) = { [weak self] in
            self?.containerView?.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: [.curveEaseInOut], animations: animations, completion: nil)
    }
}


// MARK: - Helpers
private extension BottomsheetPresentationController {
    func rect(for contentSizeMode: ContentSizeMode, in rect: CGRect) -> CGRect {
        let origin = CGPoint(x: 0, y: rect.height * (1.0 - contentSizeMode.percentageOfSizeInSuperview))
        let size = CGSize(width: rect.width, height: rect.height - origin.y)
        
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
            return CGRect(x: transitioningRect.origin.x, y: transitioningRect.origin.y + thresholdInPoints, width: transitioningRect.width, height: transitioningRect.height - thresholdInPoints)
        case .expanded:
            let thresholdInPoints = transitioningRect.height * transitioningThreshold
            return CGRect(x: transitioningRect.origin.x, y: transitioningRect.origin.y, width: transitioningRect.width, height: transitioningRect.height - thresholdInPoints)
        }
    }
    
    func dismissalTransitionRect(in rect: CGRect, dismissalThreshold: CGFloat = 0.0) -> CGRect {
        let compactSizeRect = self.rect(for: .compact, in: rect)
        let thresholdInPoints = compactSizeRect.height * dismissalThreshold
        
        return CGRect(x: compactSizeRect.origin.x, y: compactSizeRect.origin.y + thresholdInPoints, width: compactSizeRect.width, height: compactSizeRect.height - thresholdInPoints)
    }
}


// MARK: - Gestures
private extension BottomsheetPresentationController {
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
extension BottomsheetPresentationController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === panGestureRecognizer {
            if let otherPanGestureRecognizer = otherGestureRecognizer as? UIPanGestureRecognizer, let scrollView = otherPanGestureRecognizer.view as? UIScrollView {
                return panGestureRecognizer(panGestureRecognizer, shouldRecognizeSimultaneouslyWith: otherPanGestureRecognizer, forScrollView: scrollView)
            }
        }
        
        return true
    }

    private func panGestureRecognizer(_ panGestureRecognizer: UIPanGestureRecognizer, shouldRecognizeSimultaneouslyWith otherPanGestureRecognizer: UIPanGestureRecognizer, forScrollView scrollView: UIScrollView) -> Bool {
        let panDirection = verticalPanDirection(from: panGestureRecognizer.translation(in: panGestureRecognizer.view).y)

        switch (currentContentSizeMode, panDirection) {
        case (.compact, .up):
            scrollView.isScrollEnabled = false
            return true
        case (.compact, .down):
            scrollView.isScrollEnabled = false
            return true
        case (.expanded, .down):
            let isScrollViewScrolledToTop = scrollView.contentOffset.y == 0

            if isScrollViewScrolledToTop {
                scrollView.isScrollEnabled = false
                return true
            } else {
                scrollView.isScrollEnabled = true
                return false
            }
        case (.expanded, .up):
            scrollView.isScrollEnabled = true
            return false
        }
    }
}
