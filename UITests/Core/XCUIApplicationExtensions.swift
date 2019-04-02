//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    func hasNavigationTitle(_ title: String) -> Bool {
        return navigationBars[title].exists
    }
}
