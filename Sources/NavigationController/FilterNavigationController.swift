//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public class FilterNavigationController: UINavigationController {
    var onViewDidLoad: ((FilterNavigationController) -> Void)?

    public override func viewDidLoad() {
        super.viewDidLoad()
        onViewDidLoad?(self)
    }
}
