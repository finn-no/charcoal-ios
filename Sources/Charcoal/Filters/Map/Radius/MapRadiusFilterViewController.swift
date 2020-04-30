//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit

protocol MapRadiusFilterViewControllerDelegate: AnyObject {
    func mapRadiusFilterViewControllerDidSelectFilter(_ mapRadiusFilterViewController: MapRadiusFilterViewController)
}

final class MapRadiusFilterViewController: FilterViewController {
    weak var searchLocationDataSource: SearchLocationDataSource? {
        didSet {
            searchLocationViewController.searchLocationDataSource = searchLocationDataSource
        }
    }

    weak var mapRadiusFilterDelegate: MapRadiusFilterViewControllerDelegate?

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

    private var canUpdateLocation: Bool {
        guard CLLocationManager.locationServicesEnabled() else {
            return false
        }

        let status = CLLocationManager.authorizationStatus()

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        case .denied, .notDetermined, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    // MARK: - Init

    init(title: String, latitudeFilter: Filter, longitudeFilter: Filter, radiusFilter: Filter,
         locationNameFilter: Filter, selectionStore: FilterSelectionStore) {
        self.latitudeFilter = latitudeFilter
        self.longitudeFilter = longitudeFilter
        self.radiusFilter = radiusFilter
        self.locationNameFilter = locationNameFilter
        super.init(title: title, selectionStore: selectionStore)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        bottomButton.buttonTitle = "applyButton".localized()
        view.backgroundColor = Theme.mainBackground

        showBottomButton(true, animated: false)
        setup()
    }

    override func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        radius = mapRadiusFilterView.radius
        coordinate = mapRadiusFilterView.centerCoordinate
        locationName = mapRadiusFilterView.locationName

        mapRadiusFilterDelegate?.mapRadiusFilterViewControllerDidSelectFilter(self)
        super.filterBottomButtonView(filterBottomButtonView, didTapButton: button)
    }

    // MARK: - Setup

    private func setup() {
        view.addSubview(mapRadiusFilterView)

        NSLayoutConstraint.activate([
            mapRadiusFilterView.topAnchor.constraint(equalTo: view.topAnchor),
            mapRadiusFilterView.bottomAnchor.constraint(equalTo: bottomButton.topAnchor),
            mapRadiusFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapRadiusFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    // MARK: - Internal methods

    func resetFilterValues() {
        selectionStore.removeValues(for: [radiusFilter, latitudeFilter, longitudeFilter, locationNameFilter])
    }

    // MARK: - Private methods

    private func returnToMapFromLocationSearch() {
        mapRadiusFilterView.searchBar = searchLocationViewController.searchBar
        mapRadiusFilterView.setNeedsLayout()

        searchLocationViewController.remove()
    }

    private func centerOnUserLocation() {
        guard canUpdateLocation else {
            attemptToActivateUserLocationSupport()
            return
        }

        mapRadiusFilterView.centerOnUserLocation()
    }

    private func attemptToActivateUserLocationSupport() {
        if CLLocationManager.locationServicesEnabled(), CLLocationManager.authorizationStatus() == .notDetermined {
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
        enableSwipeBack(true)
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
        delegate?.filterViewControllerWillEndTextEditing(self)
        centerOnUserLocation()
    }

    func searchLocationViewControllerWillBeginEditing(_ searchLocationViewController: SearchLocationViewController) {
        // Add view controller as child view controller
        add(searchLocationViewController)
        delegate?.filterViewControllerWillBeginTextEditing(self)
    }

    func searchLocationViewControllerDidCancelSearch(_ searchLocationViewController: SearchLocationViewController) {
        returnToMapFromLocationSearch()
        delegate?.filterViewControllerWillEndTextEditing(self)
    }

    func searchLocationViewController(_ searchLocationViewController: SearchLocationViewController,
                                      didSelectLocation location: LocationInfo?) {
        returnToMapFromLocationSearch()
        delegate?.filterViewControllerWillEndTextEditing(self)

        if let location = location {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)

            hasChanges = true
            locationName = location.name
            self.coordinate = coordinate

            mapRadiusFilterView.centerOnCoordinate(coordinate, animated: true)
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
