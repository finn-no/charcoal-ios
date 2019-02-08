//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class FilterTests: XCTestCase {
    func testUrlEncoded() {
        let rootNode = CCFilterNode(title: "Root", name: "root")
        rootNode.add(child: CCFilterNode(title: "Child 1", name: "name1", value: "value1", isSelected: true, numberOfResults: 0))
        rootNode.add(child: CCFilterNode(title: "Child 2", name: "name2", value: "value2", isSelected: true, numberOfResults: 0))
        let filter = CCFilter(root: rootNode)
        XCTAssertEqual(filter.urlEncoded, "name1=value1&name2=value2")
    }
}
