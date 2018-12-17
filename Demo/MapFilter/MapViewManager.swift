//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import MapKit
import UIKit

class MapViewManager: NSObject, MapFilterViewManager {
    var mapView: UIView {
        return mapKitMapView
    }

    let mapKitMapView: MKMapView
    weak var delegate: MapFilterManagerDelegate?

    override init() {
        mapKitMapView = MKMapView(frame: .zero)
        super.init()
        mapKitMapView.delegate = self
    }

    func mapViewLengthForMeters(_ meters: Int) -> CGFloat {
        let coordinateRegion = MKCoordinateRegion(center: mapKitMapView.centerCoordinate, latitudinalMeters: CLLocationDistance(meters), longitudinalMeters: CLLocationDistance(meters))
        let rect = mapKitMapView.convert(coordinateRegion, toRectTo: mapKitMapView)
        return rect.width
    }

    func pan(to point: CLLocationCoordinate2D, radius: Int) {
        let coordinateRegion = MKCoordinateRegion(center: point, latitudinalMeters: CLLocationDistance(radius), longitudinalMeters: CLLocationDistance(radius))
        mapKitMapView.setRegion(coordinateRegion, animated: true)
    }
}

extension MapViewManager: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        delegate?.mapFilterViewManagerDidChangeZoom()
    }
}
