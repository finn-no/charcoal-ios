//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

final class MapFilter: Filter {

    // MARK: - Public properies

    static let filterKey = "map"

    // MARK: - Internal properties

    let latitudeNode: Filter
    let longitudeNode: Filter
    let radiusNode: Filter
    let geoLocationNode: Filter

    // MARK: - Setup

    init(title: String, name: String) {
        latitudeNode = Filter(title: "", name: "lat")
        longitudeNode = Filter(title: "", name: "lon")
        radiusNode = Filter(title: "", name: "radius")
        geoLocationNode = Filter(title: "", name: "geoLocationName")
        super.init(title: title, name: name, value: nil, numberOfResults: 0)
        setup()
    }
}

private extension MapFilter {
    func setup() {
        add(child: latitudeNode)
        add(child: longitudeNode)
        add(child: radiusNode)
        add(child: geoLocationNode)
    }
}
