//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    func add(_ childViewController: UIViewController) {
        guard childViewController.parent == nil else { return }

        addChild(childViewController)
        childViewController.view.frame = view.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else { return }

        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}
