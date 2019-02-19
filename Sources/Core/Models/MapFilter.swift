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

    init(title: String, key: String, latitudeKey: String,
         longitudeKey: String, radiusKey: String, locationKey: String) {
        latitudeFilter = Filter(title: "", key: latitudeKey)
        longitudeFilter = Filter(title: "", key: longitudeKey)
        radiusFilter = Filter(title: "", key: radiusKey)
        locationNameFilter = Filter(title: "", key: locationKey)

        super.init(title: title, key: key, value: nil, numberOfResults: 0)
        setup()
    }
}

private extension MapFilter {
    func setup() {
        add(subfilter: latitudeFilter)
        add(subfilter: longitudeFilter)
        add(subfilter: radiusFilter)
        add(subfilter: locationNameFilter)
    }
}
