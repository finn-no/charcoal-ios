//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public class FilterNavigationController: UINavigationController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
}

extension FilterNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let slider = touch.view as? UISlider, slider.isEnabled, !slider.isHidden {
            return false
        }
        return true
    }
}
