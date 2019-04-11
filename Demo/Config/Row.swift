//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FINNSetup
import UIKit

struct Row {
    let title: String
    let setup: Setup?
    let usingBottomSheet: Bool
    let type: UIViewController.Type

    init(title: String, type: UIViewController.Type = CharcoalViewController.self, setup: Setup? = nil, usingBottomSheet: Bool = false) {
        self.title = title
        self.type = type
        self.setup = setup
        self.usingBottomSheet = usingBottomSheet
    }
}
