//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import MapKit
import UIKit

class MapViewManager: MapFilterViewManager {
    var mapView: UIView {
        return mapKitMapView
    }

    let mapKitMapView: MKMapView

    init() {
        mapKitMapView = MKMapView(frame: .zero)
    }

    func updateSelection(_ point: CLLocationCoordinate2D, radius: Int) {
        mapKitMapView.setCenter(point, animated: true)
        // TODO: radius with overlay...
    }
}
