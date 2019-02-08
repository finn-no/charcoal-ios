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
}
