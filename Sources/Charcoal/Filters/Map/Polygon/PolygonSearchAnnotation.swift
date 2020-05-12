//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation
import MapKit

class PolygonSearchAnnotation: MKPointAnnotation {
    var type: PointType

    init(type: PointType) {
        self.type = type
        super.init()
    }

    enum PointType {
        case vertex
        case intermediate
    }

    func getMidwayCoordinate(other: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: (coordinate.latitude + other.latitude) / 2,
            longitude: (coordinate.longitude + other.longitude) / 2
        )
    }
}
