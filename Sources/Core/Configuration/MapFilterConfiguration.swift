//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public struct MapFilterConfiguration {
    public let mapName: String
    public let latitudeName: String
    public let longitudeName: String
    public let radiusName: String
    public let locationName: String

    public static var `default`: MapFilterConfiguration {
        return MapFilterConfiguration(
            mapName: "",
            latitudeName: "lat",
            longitudeName: "lon",
            radiusName: "radius",
            locationName: "geoLocationName"
        )
    }
}
