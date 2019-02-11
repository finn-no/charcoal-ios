//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public class CCMapFilterNode: CCFilterNode {

    // MARK: - Public properies

    public static let filterKey = "map"

    // MARK: - Internal properties

    let latitudeNode: CCFilterNode
    let longitudeNode: CCFilterNode
    let radiusNode: CCFilterNode
    let geoLocationNode: CCFilterNode

    // MARK: - Setup

    public init(title: String, name: String) {
        latitudeNode = CCFilterNode(title: "", name: "lat")
        longitudeNode = CCFilterNode(title: "", name: "lon")
        radiusNode = CCFilterNode(title: "", name: "radius")
        geoLocationNode = CCFilterNode(title: "", name: "geoLocationName")
        super.init(title: title, name: name, value: nil, isSelected: false, numberOfResults: 0)
        setup()
    }
}

private extension CCMapFilterNode {
    func setup() {
        add(child: latitudeNode)
        add(child: longitudeNode)
        add(child: radiusNode)
        add(child: geoLocationNode)
    }
}
