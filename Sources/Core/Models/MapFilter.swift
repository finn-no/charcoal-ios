//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

final class MapFilter: Filter {

    // MARK: - Public properies

    static let filterKey = "map"

    // MARK: - Internal properties

    let latitudeFilter: Filter
    let longitudeFilter: Filter
    let radiusFilter: Filter
    let locationNameFilter: Filter

    // MARK: - Setup

    init(title: String, name: String) {
        latitudeFilter = Filter(title: "", name: "lat")
        longitudeFilter = Filter(title: "", name: "lon")
        radiusFilter = Filter(title: "", name: "radius")
        locationNameFilter = Filter(title: "", name: "geoLocationName")
        super.init(title: title, name: name, value: nil, numberOfResults: 0)
        setup()
    }
}

private extension MapFilter {
    func setup() {
        add(child: latitudeFilter)
        add(child: longitudeFilter)
        add(child: radiusFilter)
        add(child: locationNameFilter)
    }
}
