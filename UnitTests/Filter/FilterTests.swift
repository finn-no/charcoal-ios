//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class FilterTests: XCTestCase {
    func testAddSubfilter() {
        let filter = Filter(title: "Test", name: "test")
        filter.add(subfilter: Filter(title: "subfilter 1", name: "subfilter-1"))
        filter.add(subfilter: Filter(title: "subfilter 2", name: "subfilter-2"))
        XCTAssertEqual(filter.subfilters.count, 2)
    }

    func testAddSubfilterAtIndex() {
        let filter = Filter(title: "Test", name: "test")
        filter.add(subfilter: Filter(title: "subfilter 1", name: "index-0"))
        filter.add(subfilter: Filter(title: "subfilter 2", name: "index-2"))
        filter.add(subfilter: Filter(title: "subfilter 3", name: "index-1"), at: 1)
        XCTAssertEqual(filter.subfilter(at: 1)?.name, "index-1")
    }
}

extension FilterTests: TestDataDecoder {
    func testContextFilterSetup() {
        let filterSetup = filterDataFromJSONFile(named: "ContextFilterTestData")
        let filter = filterSetup?.asCCFilter()
        let categoryFilter = filter?.rootFilter.subfilters.first(where: { $0.name == "category" })
        let shoeSizeFilter = filter?.rootFilter.subfilters.first(where: { $0.name == "shoe_size" })
        XCTAssertEqual(categoryFilter?.kind, .normal)
        XCTAssertEqual(shoeSizeFilter?.kind, .context)
    }
}
