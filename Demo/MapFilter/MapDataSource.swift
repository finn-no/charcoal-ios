//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import FinniversKit
import MapKit
import UIKit

final class MapDataSource: MapFilterDataSource {
    var mapTileOverlay: MKTileOverlay? {
        return nil
    }

    func loadLocationName(for coordinate: CLLocationCoordinate2D, zoomLevel: Int, completion: (String?) -> Void) {
        completion(nil)
    }
}
