//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FINNSetup
import UIKit

struct Row {
    let title: String
    let type: UIViewController.Type
    let setup: Setup?

    init(title: String, type: UIViewController.Type = CharcoalViewController.self, setup: Setup? = nil) {
        self.title = title
        self.type = type
        self.setup = setup
    }
}
