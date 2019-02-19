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

    init(title: String, name: String, latitudeName: String,
         longitudeName: String, radiusName: String, locationName: String) {
        latitudeFilter = Filter(title: "", name: latitudeName)
        longitudeFilter = Filter(title: "", name: longitudeName)
        radiusFilter = Filter(title: "", name: radiusName)
        locationNameFilter = Filter(title: "", name: locationName)

        super.init(title: title, name: name, value: nil, numberOfResults: 0)
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
