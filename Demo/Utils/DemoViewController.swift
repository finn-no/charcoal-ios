//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import UIKit

class DemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.mainBackground

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.numberOfTapsRequired = 2
        tapGesture.numberOfTouchesRequired = 2
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        dismiss(animated: true)
    }
}
