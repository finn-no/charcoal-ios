//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class RangeNodeTests: XCTestCase {
    func testSetup() {
        let rangeNode = CCRangeFilterNode(title: "Range", name: "range")

        XCTAssertEqual(rangeNode.children.count, 2)

        XCTAssertEqual(rangeNode.lowValueNode.name, "range_from")
        XCTAssertEqual(rangeNode.highValueNode.name, "range_to")
    }

    func testUrlItems() {
        let rangeNode = CCRangeFilterNode(title: "Range", name: "range")

        rangeNode.lowValueNode.value = "value1"
        rangeNode.lowValueNode.isSelected = true

        rangeNode.highValueNode.value = "value2"
        rangeNode.highValueNode.isSelected = true

        let urlItems = rangeNode.queryItems
        XCTAssertEqual(urlItems.count, 2)

        rangeNode.lowValueNode.isSelected = false
        let urlItems2 = rangeNode.queryItems
        XCTAssertEqual(urlItems2.count, 1)
    }
}
