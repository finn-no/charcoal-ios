//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import FinniversKit
import MapKit
import UIKit

class MapViewManager: NSObject, MapFilterViewManager {
    let locationName: String? = nil

    func centerOnUserLocation() {
        didTapLocateUserButton()
    }

    var centerCoordinate: CLLocationCoordinate2D? {
        get {
            return mapKitMapView.centerCoordinate
        }
        set {
            guard let newCenter = newValue else {
                return
            }
            mapKitMapView.setCenter(newCenter, animated: false)
        }
    }

    private let pulseAnimationKey = "LocateUserPulseAnimation"
    private lazy var locateUserButton: UIButton = {
        let buttonWidth = 46
        let button = UIButton(type: .custom)
        button.tintColor = .primaryBlue
        button.backgroundColor = UIColor(white: 1, alpha: 0.8)
        button.layer.cornerRadius = CGFloat(buttonWidth / 2)
        button.setImage(UIImage(named: ImageAsset.locateUserOutlined), for: .normal)
        button.setImage(UIImage(named: ImageAsset.locateUserFilled), for: .highlighted)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapLocateUserButton), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: CGFloat(buttonWidth)),
            button.heightAnchor.constraint(equalTo: button.widthAnchor),
        ])
        button.isHidden = CLLocationManager.authorizationStatus() == .restricted
        return button
    }()

    private lazy var mapKitMapView: MKMapView = {
        let mapKitMapView = MKMapView(frame: .zero)
        mapKitMapView.delegate = self
        mapKitMapView.addSubview(locateUserButton)
        NSLayoutConstraint.activate([
            locateUserButton.topAnchor.constraint(equalTo: mapKitMapView.compatibleTopAnchor, constant: .mediumSpacing),
            locateUserButton.trailingAnchor.constraint(equalTo: mapKitMapView.trailingAnchor, constant: -.mediumSpacing),
        ])
        return mapKitMapView
    }()

    public weak var mapFilterViewManagerDelegate: MapFilterViewManagerDelegate?
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.activityType = .other
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        return locationManager
    }()

    private var nextRegionChangeIsFromUserInteraction = false

    override init() {
        super.init()
        setup()
    }

    private func setup() {
    }

    func addMapView(toFillInside containerView: UIView) {
        containerView.addSubview(mapKitMapView)
        mapKitMapView.fillInSuperview()
        DispatchQueue.main.async {
            self.mapKitMapView.showsUserLocation = true
        }
    }

    func mapViewLengthForMeters(_ meters: Int) -> CGFloat {
        let coordinateRegion = MKCoordinateRegion(center: mapKitMapView.centerCoordinate, latitudinalMeters: CLLocationDistance(meters), longitudinalMeters: CLLocationDistance(meters))
        let rect = mapKitMapView.convert(coordinateRegion, toRectTo: mapKitMapView)
        return rect.width
    }

    func selectionRadiusChangedTo(_ radius: Int) {
        let radiusToShow = Double(radius) * 2.2
        let coordinateRegion = MKCoordinateRegion(center: mapKitMapView.centerCoordinate, latitudinalMeters: CLLocationDistance(radiusToShow), longitudinalMeters: CLLocationDistance(radiusToShow))
        mapKitMapView.setRegion(coordinateRegion, animated: true)
    }

    @objc private func didTapLocateUserButton() {
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == .denied {
            print("Location services not enabled")
            // TODO: tell user
            return
        }

        locateUserButton.layer.removeAnimation(forKey: pulseAnimationKey)
        let authorizationStatus = CLLocationManager.authorizationStatus()
        switch authorizationStatus {
        case .denied:
            // User said no
            return
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return
        case .restricted:
            // User can not change authorization, should not get her
            return
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            break
        }

        locateUserButton.isHighlighted = true
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.fromValue = 0.6
        pulseAnimation.toValue = 1.0
        pulseAnimation.repeatCount = Float.greatestFiniteMagnitude
        pulseAnimation.autoreverses = true
        pulseAnimation.duration = 0.8
        locateUserButton.layer.add(pulseAnimation, forKey: pulseAnimationKey)

        locationManager.requestLocation()
    }
}

extension MapViewManager: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("regionWillChangeAnimated")
        guard let gestureRecognizers = mapView.subviews.first?.gestureRecognizers else {
            return
        }
        // Look through gesture recognizers to determine whether this region change is from user interaction
        for gestureRecogizer in gestureRecognizers {
            if gestureRecogizer.state == .began || gestureRecogizer.state == .ended {
                nextRegionChangeIsFromUserInteraction = true
                break
            }
        }
    }

    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapFilterViewManagerDelegate?.mapFilterViewManagerDidChangeRegion(self, userInitiated: nextRegionChangeIsFromUserInteraction, animated: animated)
        nextRegionChangeIsFromUserInteraction = false
    }
}

extension MapViewManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError \(error)")
        locateUserButton.isHighlighted = false
        locateUserButton.layer.removeAnimation(forKey: pulseAnimationKey)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            didTapLocateUserButton()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else {
            // TODO: show error mesage?
            print("No location retrieved")
            return
        }
        guard latestLocation.horizontalAccuracy < 100 else {
            // Not good enough, try again
            print("Inaccurate user location, trying again")
            locationManager.requestLocation()
            return
        }
        print("Succesfully found user location \(latestLocation.coordinate)")
        locateUserButton.layer.removeAnimation(forKey: pulseAnimationKey)
        mapKitMapView.setCenter(latestLocation.coordinate, animated: true)
    }
}
