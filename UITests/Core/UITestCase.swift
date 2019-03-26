//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import XCTest

class UITestCase: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
    }
}
