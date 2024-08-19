//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit

protocol MapRadiusFilterViewControllerDelegate: AnyObject {
    func mapRadiusFilterViewControllerDidChangeRadius(_ mapRadiusFilterViewController: MapRadiusFilterViewController)
    func mapRadiusFilterViewControllerWillEndTextEditing(_ mapRadiusFilterViewController: MapRadiusFilterViewController)
    func mapRadiusFilterViewControllerWillBeginTextEditing(_ mapRadiusFilterViewController: MapRadiusFilterViewController)
}

final class MapRadiusFilterViewController: UIViewController {
    weak var searchLocationDataSource: SearchLocationDataSource? {
        didSet {
            searchLocationViewController.searchLocationDataSource = searchLocationDataSource
        }
    }

    weak var delegate: MapRadiusFilterViewControllerDelegate?

    // MARK: - Private properties

    private let latitudeFilter: Filter
    private let longitudeFilter: Filter
    private let radiusFilter: Filter
    private let locationNameFilter: Filter
    private let locationManager = CLLocationManager()
    private var hasRequestedLocationAuthorization = false
    private var nextRegionChangeIsFromUserInteraction = false
    private var hasChanges = false
    private var isMapLoaded = false
    private var isAwaitingLocationAuthorizationStatus = true
    private var isAwaitingCenterOnUserLocation = false

    private lazy var mapRadiusFilterView: MapRadiusFilterView = {
        let mapRadiusFilterView = MapRadiusFilterView(radius: radius, centerCoordinate: coordinate)
        mapRadiusFilterView.translatesAutoresizingMaskIntoConstraints = false
        mapRadiusFilterView.searchBar = searchLocationViewController.searchBar
        mapRadiusFilterView.locationName = locationName
        mapRadiusFilterView.delegate = self
        return mapRadiusFilterView
    }()

    private lazy var searchLocationViewController: SearchLocationViewController = {
        let searchLocationViewController = SearchLocationViewController()
        searchLocationViewController.delegate = self
        return searchLocationViewController
    }()

    private let selectionStore: FilterSelectionStore

    private var isLocationAuthorized: Bool {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .notDetermined, .restricted, .denied:
            return false
        default:
            return false
        }
    }

    // MARK: - Init

    init(latitudeFilter: Filter, longitudeFilter: Filter, radiusFilter: Filter,
         locationNameFilter: Filter, selectionStore: FilterSelectionStore) {
        self.latitudeFilter = latitudeFilter
        self.longitudeFilter = longitudeFilter
        self.radiusFilter = radiusFilter
        self.locationNameFilter = locationNameFilter
        self.selectionStore = selectionStore
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        locationManager.delegate = self

        view.addSubview(mapRadiusFilterView)
        mapRadiusFilterView.fillInSuperview()
    }

    // MARK: - Private methods

    private func returnToMapFromLocationSearch() {
        mapRadiusFilterView.searchBar = searchLocationViewController.searchBar
        mapRadiusFilterView.setNeedsLayout()

        searchLocationViewController.remove()
    }

    private func centerOnUserLocation() {
        guard !isAwaitingLocationAuthorizationStatus else {
            isAwaitingCenterOnUserLocation = true
            return
        }
        guard isLocationAuthorized else {
            attemptToActivateUserLocationSupport()
            return
        }

        mapRadiusFilterView.centerOnUserLocation()
    }

    private func attemptToActivateUserLocationSupport() {
        if locationManager.authorizationStatus == .notDetermined {
            hasRequestedLocationAuthorization = true
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Not authorized
            let title = "map.locationError.title".localized()
            let message = "map.locationError.message".localized()
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "cancel".localized(), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - MapRadiusFilterViewDelegate

extension MapRadiusFilterViewController: MapRadiusFilterViewDelegate {
    func mapRadiusFilterViewDidSelectLocationButton(_ mapRadiusFilterView: MapRadiusFilterView) {
        nextRegionChangeIsFromUserInteraction = true
        centerOnUserLocation()
    }

    func mapRadiusFilterView(_ mapRadiusFilterView: MapRadiusFilterView, didChangeRadius radius: Int) {
        hasChanges = true
        self.radius = radius
        delegate?.mapRadiusFilterViewControllerDidChangeRadius(self)
    }
}

// MARK: - MKMapViewDelegate

extension MapRadiusFilterViewController: MKMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        guard !isMapLoaded else {
            return
        }

        isMapLoaded = true
        mapRadiusFilterView.centerOnInitialCoordinate()
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return MKOverlayRenderer(overlay: overlay)
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
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

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let coordinate = mapView.centerCoordinate

        mapRadiusFilterView.updateRadiusView()
        mapRadiusFilterView.isUserLocationButtonHighlighted = coordinate == mapView.userLocation.coordinate

        if nextRegionChangeIsFromUserInteraction {
            locationName = nil
            hasChanges = true
        }

        if hasChanges {
            self.coordinate = coordinate
        }

        nextRegionChangeIsFromUserInteraction = false
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if hasRequestedLocationAuthorization {
            mapRadiusFilterView.centerOnInitialCoordinate()
            hasRequestedLocationAuthorization = false
        }
    }
}

// MARK: - SearchLocationViewControllerDelegate

extension MapRadiusFilterViewController: SearchLocationViewControllerDelegate {
    func searchLocationViewControllerDidSelectCurrentLocation(_ searchLocationViewController: SearchLocationViewController) {
        returnToMapFromLocationSearch()
        delegate?.mapRadiusFilterViewControllerWillEndTextEditing(self)
        centerOnUserLocation()
    }

    func searchLocationViewControllerWillBeginEditing(_ searchLocationViewController: SearchLocationViewController) {
        // Add view controller as child view controller
        add(searchLocationViewController)
        delegate?.mapRadiusFilterViewControllerWillBeginTextEditing(self)
    }

    func searchLocationViewControllerDidCancelSearch(_ searchLocationViewController: SearchLocationViewController) {
        returnToMapFromLocationSearch()
        delegate?.mapRadiusFilterViewControllerWillEndTextEditing(self)
    }

    func searchLocationViewController(_ searchLocationViewController: SearchLocationViewController,
                                      didSelectLocation location: LocationInfo?) {
        returnToMapFromLocationSearch()
        delegate?.mapRadiusFilterViewControllerWillEndTextEditing(self)

        if let location = location {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)

            hasChanges = true
            locationName = location.name
            self.coordinate = coordinate

            mapRadiusFilterView.centerOnCoordinate(coordinate, animated: false)
        }
    }
}

extension MapRadiusFilterViewController: ToggleFilter {
    func resetFilterValues() {
        selectionStore.removeValues(for: [radiusFilter, latitudeFilter, longitudeFilter, locationNameFilter])
    }

    func updateFilterValues() {
        radius = mapRadiusFilterView.radius
        coordinate = mapRadiusFilterView.centerCoordinate
        locationName = mapRadiusFilterView.locationName
    }
}

// MARK: - CLLocationManagerDelegate

extension MapRadiusFilterViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        isAwaitingLocationAuthorizationStatus = false

        if isAwaitingCenterOnUserLocation {
            isAwaitingCenterOnUserLocation = false
            centerOnUserLocation()
        }
    }
}

// MARK: - Store

private extension MapRadiusFilterViewController {
    var radius: Int? {
        get {
            return selectionStore.value(for: radiusFilter)
        }
        set {
            selectionStore.setValue(newValue, for: radiusFilter)
        }
    }

    var coordinate: CLLocationCoordinate2D? {
        get {
            guard let latitude: Double = selectionStore.value(for: latitudeFilter) else {
                return nil
            }

            guard let longitude: Double = selectionStore.value(for: longitudeFilter) else {
                return nil
            }

            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            selectionStore.setValue(newValue?.latitude, for: latitudeFilter)
            selectionStore.setValue(newValue?.longitude, for: longitudeFilter)
            radius = mapRadiusFilterView.radius
        }
    }

    var locationName: String? {
        get {
            return selectionStore.value(for: locationNameFilter)
        }
        set {
            selectionStore.setValue(newValue, for: locationNameFilter)
            mapRadiusFilterView.locationName = newValue
        }
    }
}

// MARK: - Private extensions

private func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return (fabs(lhs.latitude - rhs.latitude) <= 1e-5) && (fabs(lhs.longitude - rhs.longitude) <= 1e-5)
}
