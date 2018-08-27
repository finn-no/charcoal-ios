//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import FilterKit
import XCTest

class ContentSizeModeTest: XCTestCase {
    let iPhone5ScreenHeight: CGFloat = 568
    let iPhone6ScreenHeight: CGFloat = 667
    let iPhone6PlusScreenHeight: CGFloat = 736

    func testCompactContentSizeModeIsSupportedForiPhone6ScreenSize() {
        let compactMode = BottomSheetPresentationController.ContentSizeMode.compact

        let isSupported = compactMode.isSupported(for: iPhone6ScreenHeight)

        XCTAssertTrue(isSupported)
    }

    func testCompactContentSizeModeIsNotSupportedForiPhone5ScreenSize() {
        let compactMode = BottomSheetPresentationController.ContentSizeMode.compact

        let isSupported = compactMode.isSupported(for: iPhone5ScreenHeight)

        XCTAssertFalse(isSupported)
    }

    func testCompactContentSizeModeGetsExpandedHeightForiPhone5ScreenSize() {
        let compactMode = BottomSheetPresentationController.ContentSizeMode.compact
        let expandedMode = BottomSheetPresentationController.ContentSizeMode.expanded

        let compactHeight = compactMode.bottomSheetHeight(for: iPhone5ScreenHeight)
        let expandedHeight = expandedMode.bottomSheetHeight(for: iPhone5ScreenHeight)

        XCTAssertEqual(compactHeight, expandedHeight)
    }

    func testExpandedHeightIsMoreThanCompactHeightForAboveiPhone5ScreenSize() {
        let compactMode = BottomSheetPresentationController.ContentSizeMode.compact
        let expandedMode = BottomSheetPresentationController.ContentSizeMode.expanded

        let compactHeight = compactMode.bottomSheetHeight(for: iPhone6ScreenHeight)
        let expandedHeight = expandedMode.bottomSheetHeight(for: iPhone6ScreenHeight)

        XCTAssertGreaterThan(expandedHeight, compactHeight)
    }

    func testCompactHeightIsMoreForPlusSizeDevices() {
        let compactMode = BottomSheetPresentationController.ContentSizeMode.compact

        let normalCompactHeight = compactMode.bottomSheetHeight(for: iPhone6ScreenHeight)
        let plusCompactHeight = compactMode.bottomSheetHeight(for: iPhone6PlusScreenHeight)

        XCTAssertGreaterThan(plusCompactHeight, normalCompactHeight)
    }
}
