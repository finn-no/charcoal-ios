//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import FinniversKit
import MapKit
import UIKit

class MapViewManager: NSObject, MapFilterViewManager {
    var isMapLoaded: Bool = false

    var mapView: UIView {
        return mapKitMapView
    }

    private let pulseAnimationKey = "LocateUserPulseAnimation"
    private lazy var locateUserButton: UIView = {
        if #available(iOS 11.0, *), !usesCustomLocateUserButton {
            let button = MKUserTrackingButton(mapView: mapKitMapView)
            button.backgroundColor = UIColor(white: 1, alpha: 0.8)
            button.layer.cornerRadius = 5
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        } else {
            let button = UIButton(type: .custom)
            button.tintColor = .primaryBlue
            button.backgroundColor = UIColor(white: 1, alpha: 0.8)
            button.layer.cornerRadius = 5
            button.setImage(UIImage(named: ImageAsset.locateUser), for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(didTapLocateUserButton), for: .touchUpInside)
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 35),
                button.heightAnchor.constraint(equalTo: button.widthAnchor),
            ])
            return button
        }
    }()

    private var usesCustomLocateUserButton: Bool {
        if #available(iOS 11.0, *) {
            return false
        } else {
            return true
        }
    }

    let mapKitMapView: MKMapView
    weak var delegate: MapFilterManagerDelegate?
    let locationManager = CLLocationManager()

    override init() {
        mapKitMapView = MKMapView(frame: .zero)
        super.init()
        locationManager.delegate = self
        mapKitMapView.delegate = self
        mapKitMapView.showsScale = true
        mapKitMapView.showsUserLocation = true
        mapKitMapView.addSubview(locateUserButton)

        NSLayoutConstraint.activate([
            locateUserButton.bottomAnchor.constraint(equalTo: mapKitMapView.compatibleBottomAnchor, constant: -.mediumLargeSpacing),
            locateUserButton.trailingAnchor.constraint(equalTo: mapKitMapView.trailingAnchor, constant: -.mediumLargeSpacing),
        ])
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

    @objc private func didTapLocateUserButton() {
        mapKitMapView.setUserTrackingMode(.follow, animated: true)
    }
}

extension MapViewManager: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        delegate?.mapFilterViewManagerDidChangeZoom()
        mapKitMapView.setUserTrackingMode(.none, animated: true)
    }

    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        isMapLoaded = true
        delegate?.mapFilterViewManagerDidLoadMap()
    }

    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        isMapLoaded = false
    }

    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        if usesCustomLocateUserButton {
            let pulseAnimation = CABasicAnimation(keyPath: "opacity")
            pulseAnimation.fromValue = 0.6
            pulseAnimation.toValue = 1.0
            pulseAnimation.repeatCount = Float.greatestFiniteMagnitude
            pulseAnimation.autoreverses = true
            pulseAnimation.duration = 0.8
            locateUserButton.layer.add(pulseAnimation, forKey: pulseAnimationKey)
        }
    }

    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        locateUserButton.layer.removeAnimation(forKey: pulseAnimationKey)
    }

    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        locateUserButton.layer.removeAnimation(forKey: pulseAnimationKey)
    }

    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        guard mode != .none else {
            print("MKUserTrackingMode turned off")
            return
        }
        let authorizationStatus = CLLocationManager.authorizationStatus()
        switch authorizationStatus {
        case .denied:
            // TODO: user has disabled, show message about how to enable
            mapKitMapView.setUserTrackingMode(.none, animated: false)
            return
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return
        case .restricted:
            // TODO: User can not change authorization, so button should probably not be shown at all
            return
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            break
        }
        print("Mode \(mode == .follow)")
        if mode == .followWithHeading {
            mapKitMapView.setUserTrackingMode(.none, animated: false)
            return
        }
    }
}

extension MapViewManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
}
