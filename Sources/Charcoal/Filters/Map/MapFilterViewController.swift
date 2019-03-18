//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit

public protocol MapFilterDataSource: AnyObject {
    var mapTileOverlay: MKTileOverlay? { get }
    func loadLocationName(for coordinate: CLLocationCoordinate2D, zoomLevel: Int, completion: (String?) -> Void)
}

final class MapFilterViewController: FilterViewController {
    var mapDataSource: MapFilterDataSource? {
        didSet {
            if let mapTileOverlay = mapDataSource?.mapTileOverlay {
                mapFilterView.setMapTileOverlay(mapTileOverlay)
            }
        }
    }

    var searchLocationDataSource: SearchLocationDataSource? {
        didSet {
            searchLocationViewController.searchLocationDataSource = searchLocationDataSource
        }
    }

    // MARK: - Private properties

    private let latitudeFilter: Filter
    private let longitudeFilter: Filter
    private let radiusFilter: Filter
    private let locationNameFilter: Filter
    private let locationManager = CLLocationManager()
    private var nextRegionChangeIsFromUserInteraction = false
    private var hasChanges = false
    private var isMapLoaded = false

    private lazy var mapFilterView: MapFilterView = {
        let mapFilterView = MapFilterView(radius: radius, centerCoordinate: coordinate)
        mapFilterView.translatesAutoresizingMaskIntoConstraints = false
        mapFilterView.searchBar = searchLocationViewController.searchBar
        mapFilterView.locationName = locationName
        mapFilterView.delegate = self
        return mapFilterView
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

    public override func viewDidLoad() {
        super.viewDidLoad()

        bottomButton.buttonTitle = "apply_button_title".localized()
        view.backgroundColor = .milk

        showBottomButton(true, animated: false)
        setup()

        if canUpdateLocation {
            mapFilterView.isUserLocatonButtonEnabled = true
        }
    }

    override func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        radius = mapFilterView.radius
        coordinate = mapFilterView.centerCoordinate
        locationName = mapFilterView.locationName

        super.filterBottomButtonView(filterBottomButtonView, didTapButton: button)
    }

    // MARK: - Setup

    private func setup() {
        view.addSubview(mapFilterView)

        NSLayoutConstraint.activate([
            mapFilterView.topAnchor.constraint(equalTo: view.topAnchor),
            mapFilterView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomButton.height),
            mapFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func returnToMapFromLocationSearch() {
        mapFilterView.searchBar = searchLocationViewController.searchBar
        mapFilterView.setNeedsLayout()

        searchLocationViewController.remove()
    }

    private func attemptToActivateUserLocationSupport() {
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Not authorized
            let title = "location_error_title".localized()
            let message = "location_error_message".localized()
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "cancel".localized(), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - MapFilterViewDelegate

extension MapFilterViewController: MapFilterViewDelegate {
    func mapFilterViewDidSelectLocationButton(_ mapFilterView: MapFilterView) {
        guard canUpdateLocation else {
            attemptToActivateUserLocationSupport()
            return
        }

        nextRegionChangeIsFromUserInteraction = true
        mapFilterView.centerOnUserLocation()
    }

    func mapFilterView(_ mapFilterView: MapFilterView, didChangeRadius radius: Int) {
        hasChanges = true
        self.radius = radius
    }
}

// MARK: - MKMapViewDelegate

extension MapFilterViewController: MKMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        guard !isMapLoaded else {
            return
        }

        isMapLoaded = true
        mapFilterView.centerOnInitialCoordinate()
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let tileOverlay = overlay as? MKTileOverlay else {
            return MKOverlayRenderer(overlay: overlay)
        }

        return MKTileOverlayRenderer(tileOverlay: tileOverlay)
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
        mapFilterView.updateRadiusView()

        let coordinate = mapView.centerCoordinate

        if nextRegionChangeIsFromUserInteraction {
            hasChanges = true
            locationName = nil

            let zoomLevel = mapView.calcZoomLevel()

            mapDataSource?.loadLocationName(for: coordinate, zoomLevel: zoomLevel, completion: { [weak self] name in
                self?.locationName = name
            })
        }

        if hasChanges {
            self.coordinate = coordinate
        }

        nextRegionChangeIsFromUserInteraction = false
    }

    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        mapFilterView.startAnimatingLocationButton()
    }

    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        mapFilterView.stopAnimatingLocationButton()
    }

    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        mapFilterView.stopAnimatingLocationButton()
    }
}

// MARK: - CLLocationManagerDelegate

extension MapFilterViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            mapFilterView.centerOnUserLocation()
        case .denied, .notDetermined, .restricted:
            break
        }
    }
}

// MARK: - SearchLocationViewControllerDelegate

extension MapFilterViewController: SearchLocationViewControllerDelegate {
    public func searchLocationViewControllerDidSelectCurrentLocation(_ searchLocationViewController: SearchLocationViewController) {
        returnToMapFromLocationSearch()
        delegate?.filterViewControllerWillEndTextEditing(self)
        mapFilterView.centerOnUserLocation()
    }

    public func searchLocationViewControllerWillBeginEditing(_ searchLocationViewController: SearchLocationViewController) {
        // Add view controller as child view controller
        add(searchLocationViewController)
        delegate?.filterViewControllerWillBeginTextEditing(self)
    }

    public func searchLocationViewControllerDidCancelSearch(_ searchLocationViewController: SearchLocationViewController) {
        returnToMapFromLocationSearch()
        delegate?.filterViewControllerWillEndTextEditing(self)
    }

    public func searchLocationViewController(_ searchLocationViewController: SearchLocationViewController,
                                             didSelectLocation location: LocationInfo?) {
        returnToMapFromLocationSearch()
        delegate?.filterViewControllerWillEndTextEditing(self)

        if let location = location {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)

            hasChanges = true
            locationName = location.name
            self.coordinate = coordinate

            mapFilterView.centerOnCoordinate(coordinate, animated: true)
        }
    }
}

// MARK: - Store

private extension MapFilterViewController {
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
            radius = mapFilterView.radius
        }
    }

    var locationName: String? {
        get {
            return selectionStore.value(for: locationNameFilter)
        }
        set {
            selectionStore.setValue(newValue, for: locationNameFilter)
            mapFilterView.locationName = newValue
        }
    }
}

// MARK: - Private extensions

private extension MKMapView {
    /// Calculates current zoom level of the map
    func calcZoomLevel() -> Int {
        return Int(log2(360 * (Double(frame.size.width / 256) / region.span.longitudeDelta)) + 1)
    }
}

private func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
