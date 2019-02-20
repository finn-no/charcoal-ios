//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class FilterTests: XCTestCase {
    func testAddSubfilter() {
        let filter = Filter(title: "Test", key: "test")
        filter.add(subfilter: Filter(title: "subfilter 1", key: "subfilter-1"))
        filter.add(subfilter: Filter(title: "subfilter 2", key: "subfilter-2"))
        XCTAssertEqual(filter.subfilters.count, 2)
    }

    func testAddSubfilterAtIndex() {
        let filter = Filter(title: "Test", key: "test")
        filter.add(subfilter: Filter(title: "subfilter 1", key: "index-0"))
        filter.add(subfilter: Filter(title: "subfilter 2", key: "index-2"))
        filter.add(subfilter: Filter(title: "subfilter 3", key: "index-1"), at: 1)
        XCTAssertEqual(filter.subfilter(at: 1)?.key, "index-1")
    }
}

extension FilterTests: TestDataDecoder {
    func testContextFilterSetup() {
        guard let config = FilterMarket(market: "bap-sale") else { return }
        let filterSetup = filterDataFromJSONFile(named: "ContextFilterTestData")
        let filter = filterSetup?.filterContainer(using: config)
        let categoryFilter = filter?.rootFilter.subfilters.first(where: { $0.key == "category" })
        let shoeSizeFilter = filter?.rootFilter.subfilters.first(where: { $0.key == "shoe_size" })
        XCTAssertEqual(categoryFilter?.kind, .normal)
        XCTAssertEqual(shoeSizeFilter?.kind, .context)
    }
}
