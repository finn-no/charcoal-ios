//
//  MapViewFinder.swift
//  Charcoal
//
//  Created by Graneggen, Nina Røsdal on 27/03/2020.
//

import Foundation
import MapKit

class MapViewFinder: UIView {

    private let radius: Int?
    private var centerCoordinate: CLLocationCoordinate2D?

    lazy var mapView: MKMapView = {
        let view = MKMapView(frame: .zero)
        view.showsUserLocation = false
        view.isRotateEnabled = false
        view.isPitchEnabled = false
        view.isZoomEnabled = false
        return view
    }()

    init(radius: Int?, centerCoordinate: CLLocationCoordinate2D?) {
        self.radius = radius
        self.centerCoordinate = centerCoordinate
        super.init(frame: .zero)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .red
        addSubview(mapView)
        mapView.fillInSuperview()
        mapView.setRegion(mapView.centeredRegion(for: 48), animated: true)
    }
}

private extension MKMapView {
    func centeredRegion(for radius: CLLocationDistance) -> MKCoordinateRegion {
        return MKCoordinateRegion(
            center: centerCoordinate,
            latitudinalMeters: CLLocationDistance(radius),
            longitudinalMeters: CLLocationDistance(radius)
        )
    }
}
