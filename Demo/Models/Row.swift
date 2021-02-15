//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import UIKit

struct Row {
    let title: String
    let setup: Setup?
    let usingBottomSheet: Bool
    let type: UIViewController.Type

    // MARK: - Init

    init(title: String, type: UIViewController.Type = CharcoalViewController.self, setup: Setup? = nil, usingBottomSheet: Bool = false) {
        self.title = title
        self.type = type
        self.setup = setup
        self.usingBottomSheet = usingBottomSheet
    }

    init(title: String, type: UIViewController.Type = CharcoalViewController.self, filterContainer: FilterContainer) {
        self.init(title: title, type: type, setup: Setup(filterContainer: filterContainer), usingBottomSheet: true)
    }
}
