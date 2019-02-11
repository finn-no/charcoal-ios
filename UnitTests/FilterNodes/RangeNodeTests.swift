//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class RangeNodeTests: XCTestCase {
    func testSetup() {
        let rangeNode = CCRangeFilterNode(title: "Range", name: "range")

        XCTAssertEqual(rangeNode.children.count, 2)

        XCTAssertEqual(rangeNode.lowNode.name, "range_from")
        XCTAssertEqual(rangeNode.highNode.name, "range_to")
    }

    func testUrlItems() {
        let rangeNode = CCRangeFilterNode(title: "Range", name: "range")

        rangeNode.lowNode.value = "value1"
        rangeNode.lowNode.isSelected = true

        rangeNode.highNode.value = "value2"
        rangeNode.highNode.isSelected = true

        let urlItems = rangeNode.queryItems
        XCTAssertEqual(urlItems.count, 2)

        rangeNode.lowNode.isSelected = false
        let urlItems2 = rangeNode.queryItems
        XCTAssertEqual(urlItems2.count, 1)
    }
}
