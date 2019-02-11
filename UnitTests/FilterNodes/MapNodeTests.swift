//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class MapNodeTests: XCTestCase {
    func testSetup() {
        let rangeNode = CCMapFilterNode(title: "Map", name: "map")
        XCTAssertEqual(rangeNode.children.count, 4)
        XCTAssertEqual(rangeNode.latitudeNode.name, "lat")
        XCTAssertEqual(rangeNode.longitudeNode.name, "lon")
        XCTAssertEqual(rangeNode.radiusNode.name, "radius")
        XCTAssertEqual(rangeNode.geoLocationNode.name, "geoLocationName")
    }
}
