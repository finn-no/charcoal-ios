//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import XCTest

final class FilterSelectionUITests: UITestCase {
    func testBottomButtonAppearance() {
        app.launch()

        // 1. Open real estate market
        app.tables.element(boundBy: 0).cells.element(boundBy: 4).tap()
        sleep(1)
        XCTAssertTrue(app.hasNavigationTitle("Filtrer søket"))

        // 2. Open filter
        app.tables.element(boundBy: 1).cells.element(boundBy: 0).tap()
        sleep(1)
        XCTAssertTrue(app.hasNavigationTitle("Kategori"))
        XCTAssertFalse(app.bottomButton.exists)

        // 3. Open subfilter
        app.tables.element(boundBy: 1).cells.element(boundBy: 1).tap()
        sleep(1)
        XCTAssertTrue(app.hasNavigationTitle("Kategori 2"))
        XCTAssertFalse(app.bottomButton.exists)

        // 4. Select filter
        app.tables.element(boundBy: 1).cells.element(boundBy: 0).tap()
        XCTAssertTrue(app.bottomButton.isHittable)

        // 5. Go back to filter
        app.backButton.tap()
        sleep(1)
        XCTAssertTrue(app.hasNavigationTitle("Kategori"))
        XCTAssertTrue(app.bottomButton.isHittable)
    }
}

// MARK: - Private extensions

private extension XCUIApplication {
    var backButton: XCUIElement {
        return navigationBars.buttons.element(boundBy: 0)
    }

    var bottomButton: XCUIElement {
        return buttons["Bruk"]
    }
}
