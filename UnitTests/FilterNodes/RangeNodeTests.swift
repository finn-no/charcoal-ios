//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class RangeNodeTests: XCTestCase {
    func testSetup() {
        let rangeNode = CCRangeFilterNode(title: "Range", name: "range")

        XCTAssertEqual(rangeNode.children.count, 2)

        let fromNode = rangeNode.child(at: CCRangeFilterNode.Index.from.rawValue)
        let toNode = rangeNode.child(at: CCRangeFilterNode.Index.to.rawValue)

        XCTAssertEqual(fromNode.name, "range_from")
        XCTAssertEqual(toNode.name, "range_to")
    }

    func testUrlItems() {
        let rangeNode = CCRangeFilterNode(title: "Range", name: "range")

        let fromNode = rangeNode.child(at: CCRangeFilterNode.Index.from.rawValue)
        fromNode.value = "value1"
        fromNode.isSelected = true

        let toNode = rangeNode.child(at: CCRangeFilterNode.Index.to.rawValue)
        toNode.value = "value2"
        toNode.isSelected = true

        let urlItems = rangeNode.urlItems
        XCTAssertEqual(urlItems.count, 2)
        XCTAssertEqual(urlItems.first, "range_from=value1")
        XCTAssertEqual(urlItems.last, "range_to=value2")

        fromNode.isSelected = false
        let urlItems2 = rangeNode.urlItems
        XCTAssertEqual(urlItems2.count, 1)
        XCTAssertEqual(urlItems2.first, "range_to=value2")
    }
}
