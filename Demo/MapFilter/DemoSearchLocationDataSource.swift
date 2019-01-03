//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal

private struct DemoLocation: LocationInfo {
    var name: String
    var latitude: Double
    var longitude: Double
}

class DemoSearchLocationDataSource: SearchLocationDataSource {
    private let locations = [
        DemoLocation(name: "Water", latitude: 59.00911958255264, longitude: 10.40964093117625),
        DemoLocation(name: "Countryside", latitude: 60.00227524, longitude: 10.7310662),
    ]

    func searchLocationViewController(_ searchLocationViewController: SearchLocationViewController, didRequestLocationsFor searchQuery: String, completion: @escaping ((SearchLocationDataSourceResult) -> Void)) {
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(200)) {
            completion(.finished(text: searchQuery, locations: self.locations))
        }
    }

    func recentLocation(in searchLocationViewController: SearchLocationViewController) -> [LocationInfo] {
        return locations
    }

    func homeAddressLocation(in searchLocationViewController: SearchLocationViewController) -> LocationInfo? {
        return DemoLocation(name: "Grensen 5-7, Oslo", latitude: 59.91383369869115, longitude: 10.743777933233664)
    }

    func showCurrentLocation(in searchLocationViewController: SearchLocationViewController) -> Bool {
        return true
    }
}
