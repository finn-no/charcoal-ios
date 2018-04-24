import UIKit

final public class BottomsheetInteractiveDismissalController: UIPercentDrivenInteractiveTransition {
    
    let dismissalTransitioningRect: CGRect
    let dismissalPercentageThreshold: CGFloat
    let containerView: UIView
    let presentedView: UIView
    
    public lazy var gestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(viewPanned(sender:)))
        return panGestureRecognizer
    }()
    
    public var dismissalDidBegin: (() -> Void)?
    public private(set) var isDismissing = false
    
    var initialDismissalTranslation: CGFloat = 0.0
    
    
    init(containerView: UIView, presentedView: UIView, dismissalTransitioningRect: CGRect, dismissalPercentageThreshold: CGFloat) {
        self.containerView = containerView
        self.presentedView = presentedView
        self.dismissalTransitioningRect = dismissalTransitioningRect
        self.dismissalPercentageThreshold = dismissalPercentageThreshold
        super.init()
        self.containerView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func viewPanned(sender: UIPanGestureRecognizer) {
        let translationY = sender.translation(in: containerView).y
        let dismissalPercentage = (translationY - initialDismissalTranslation) / dismissalTransitioningRect.height
        
        switch sender.state {
        case .began, .possible:
            let startPoint = CGPoint(x: presentedView.frame.origin.x, y: presentedView.frame.origin.y + translationY)
            
            if dismissalTransitioningRect.contains(startPoint) && isDismissing == false {
                initialDismissalTranslation = translationY
                dismissalDidBegin?()
                isDismissing = true
            }
        case .changed:
            let currentPoint = presentedView.frame.origin
            
            if dismissalTransitioningRect.contains(currentPoint) && isDismissing == false {
                initialDismissalTranslation = translationY
                dismissalDidBegin?()
                isDismissing = true
            } else if currentPoint.y < dismissalTransitioningRect.origin.y {
                isDismissing = false
                cancel()
            } else {
                update(dismissalPercentage)
            }
        case .cancelled, .failed:
            isDismissing = false
            cancel()
        case .ended:
            if dismissalPercentage < 0 {
                cancel()
            } else if percentComplete >= dismissalPercentageThreshold {
                finish()
            } else {
                cancel()
            }
            
            isDismissing = false
        }
    }
}
