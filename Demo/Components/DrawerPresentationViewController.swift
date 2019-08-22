//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import FinniversKit

final class DrawerPresentationViewController: UIViewController {
    public lazy var transition: HorizontalSlideTransition = {
        let transition = HorizontalSlideTransition(containerSize: HorizontalSlideTransition.ContainerSize(portrait: 0.45, landscape: 0.35))
        transition.delegate = self
        return transition
    }()

    public lazy var charcoalViewController = CharcoalViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .milk

        addChild(charcoalViewController)
        view.addSubview(charcoalViewController.view)
        charcoalViewController.didMove(toParent: self)
    }
}

extension DrawerPresentationViewController: HorizontalSlideTransitionDelegate {
    func horizontalSlideTransitionDidDismiss(_ horizontalSlideTransition: HorizontalSlideTransition) {}
}
