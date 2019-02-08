//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal
import XCTest

final class MapNodeTests: XCTestCase {
    func testSetup() {
        let rangeNode = CCMapFilterNode(title: "Map", name: "map")

        XCTAssertEqual(rangeNode.children.count, 4)

        let latitudeNode = rangeNode.child(at: CCMapFilterNode.Index.lat.rawValue)
        let longitudeNode = rangeNode.child(at: CCMapFilterNode.Index.lon.rawValue)
        let radiusNode = rangeNode.child(at: CCMapFilterNode.Index.radius.rawValue)
        let locationNode = rangeNode.child(at: CCMapFilterNode.Index.geoLocationName.rawValue)

        XCTAssertEqual(latitudeNode.name, "lat")
        XCTAssertEqual(longitudeNode.name, "lon")
        XCTAssertEqual(radiusNode.name, "radius")
        XCTAssertEqual(locationNode.name, "geoLocationName")
    }
}
