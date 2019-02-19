//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class MapFilterTests: XCTestCase {
    func testInit() {
        let filter = MapFilter(title: "Map", key: "map", latitudeKey: "lat", longitudeKey: "lon", radiusKey: "r", locationKey: "loc")

        XCTAssertEqual(filter.title, "Map")
        XCTAssertEqual(filter.key, "map")
        XCTAssertEqual(filter.latitudeFilter.key, "lat")
        XCTAssertEqual(filter.longitudeFilter.key, "lon")
        XCTAssertEqual(filter.radiusFilter.key, "r")
        XCTAssertEqual(filter.locationNameFilter.key, "loc")
        XCTAssertEqual(filter.kind, .normal)
    }
}
