//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit

final class MapPolygonFilterViewController: FilterViewController {
    weak var mapDataSource: MapFilterDataSource? {
        didSet {
            if let mapTileOverlay = mapDataSource?.mapTileOverlay {
                mapPolygonFilterView.setMapTileOverlay(mapTileOverlay)
            }
        }
    }

    weak var searchLocationDataSource: SearchLocationDataSource? {
        didSet {
            searchLocationViewController.searchLocationDataSource = searchLocationDataSource
        }
    }

    // MARK: - Private properties

    private let latitudeFilter: Filter
    private let longitudeFilter: Filter
    private let locationNameFilter: Filter
    private let bboxFilter: Filter
    private let polygonFilter: Filter
    private let locationManager = CLLocationManager()
    private var hasRequestedLocationAuthorization = false
    private var nextRegionChangeIsFromUserInteraction = false
    private var hasChanges = false
    private var isMapLoaded = false
    private var annotationDidMove = false
    private var dragStartPosition: CGPoint = .zero
    private var annotations = [PolygonSearchAnnotation]()

    private lazy var mapPolygonFilterView: MapPolygonFilterView = {
        let mapPolygonFilterView = MapPolygonFilterView(centerCoordinate: coordinate)
        mapPolygonFilterView.translatesAutoresizingMaskIntoConstraints = false
        mapPolygonFilterView.searchBar = searchLocationViewController.searchBar
        mapPolygonFilterView.locationName = locationName
        mapPolygonFilterView.delegate = self
        return mapPolygonFilterView
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

    init(title: String, latitudeFilter: Filter, longitudeFilter: Filter,
         locationNameFilter: Filter, bboxFilter: Filter, polygonFilter: Filter, selectionStore: FilterSelectionStore) {
        self.latitudeFilter = latitudeFilter
        self.longitudeFilter = longitudeFilter
        self.locationNameFilter = locationNameFilter
        self.bboxFilter = bboxFilter
        self.polygonFilter = polygonFilter
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
        locationName = mapPolygonFilterView.locationName

        if !annotationDidMove {
            let bboxCoordinates = [
                annotations.map( { $0.coordinate.longitude } ).min() ?? 0,
                annotations.map( { $0.coordinate.latitude } ).min() ?? 0,
                annotations.map( { $0.coordinate.longitude } ).max() ?? 0,
                annotations.map( { $0.coordinate.latitude } ).max() ?? 0
            ]
            guard !bboxCoordinates.contains(0) else { return }
            bbox = bboxCoordinates.map({ String($0) }).joined(separator: ",")
            polygon = nil
        } else {
            polygon = createPolygonQuery(for: annotations.filter({ $0.type == .vertex }).map({ $0.coordinate }))
            bbox = nil
        }
        super.filterBottomButtonView(filterBottomButtonView, didTapButton: button)
    }

    // MARK: - Setup

    private func setup() {
        view.addSubview(mapPolygonFilterView)

        NSLayoutConstraint.activate([
            mapPolygonFilterView.topAnchor.constraint(equalTo: view.topAnchor),
            mapPolygonFilterView.bottomAnchor.constraint(equalTo: bottomButton.topAnchor),
            mapPolygonFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapPolygonFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    // MARK: - Internal methods

    func resetFilterValues() {
        selectionStore.removeValues(for: [latitudeFilter, longitudeFilter, locationNameFilter, bboxFilter, polygonFilter])
    }

    // MARK: - Private methods

    private func returnToMapFromLocationSearch() {
        mapPolygonFilterView.searchBar = searchLocationViewController.searchBar
        mapPolygonFilterView.setNeedsLayout()

        searchLocationViewController.remove()
    }

    private func centerOnUserLocation() {
        guard canUpdateLocation else {
            attemptToActivateUserLocationSupport()
            return
        }

        mapPolygonFilterView.centerOnUserLocation()
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

    // MARK: - Networking

    private func createPolygonQuery(for coordinates: [CLLocationCoordinate2D]) -> String? {
        var query = ""
        for coordinate in coordinates {
            query += queryString(for: coordinate) + ","
        }
        query += queryString(for: coordinates[0])
        return query
    }

    private func queryString(for coordinate: CLLocationCoordinate2D) -> String {
        return String(coordinate.longitude) + " " + String(coordinate.latitude)
    }

    // MARK: - Polygon calculations

    @objc func handleAnnotationMovement(gesture: UILongPressGestureRecognizer) {
        annotationDidMove = true
        let location = mapPolygonFilterView.location(for: gesture)

        guard
            let annotationView = gesture.view as? MKAnnotationView,
            let annotation = annotationView.annotation as? PolygonSearchAnnotation
        else { return }

        if gesture.state == .began {
            dragStartPosition = location

        } else if gesture.state == .changed {
            gesture.view?.transform = CGAffineTransform(translationX: location.x - dragStartPosition.x, y: location.y - dragStartPosition.y)

            let translate = CGPoint(x: location.x - dragStartPosition.x, y: location.y - dragStartPosition.y)
            let originalLocation = mapPolygonFilterView.pointForAnnoatation(annotation)
            let updatedLocation = CGPoint(x: originalLocation.x + translate.x, y: originalLocation.y + translate.y)
            let touchedCoordinate = mapPolygonFilterView.coordinateForPoint(updatedLocation)

            updatePolygon(draggedAnnotation: annotation, touchedCoordinate: touchedCoordinate)
            updateNeighborPositions(draggedAnnotation: annotation, annotationCoordinate: touchedCoordinate)

        } else if gesture.state == .ended || gesture.state == .cancelled {
            if annotation.type == .intermediate {
                annotation.type = .vertex
                annotationView.image = mapPolygonFilterView.imageForAnnotation(ofType: .vertex)
                if let index = index(of: annotation) {
                    addIntermediatePoint(after: annotation, nextPoint: annotations[indexAfter(index)].coordinate)
                    let previousAnnotation = annotations[indexBefore(index)]
                    addIntermediatePoint(after: previousAnnotation, nextPoint: annotation.coordinate)
                }
            }
            let translate = CGPoint(x: location.x - dragStartPosition.x, y: location.y - dragStartPosition.y)
            let originalLocation = mapPolygonFilterView.pointForAnnoatation(annotation)
            let updatedLocation = CGPoint(x: originalLocation.x + translate.x, y: originalLocation.y + translate.y)

            annotationView.transform = .identity
            annotation.coordinate = mapPolygonFilterView.coordinateForPoint(updatedLocation)
            updateNeighborPositions(draggedAnnotation: annotation, annotationCoordinate: annotation.coordinate)

            mapPolygonFilterView.drawPolygon(with: annotations)
        }
    }

    private func updatePolygon(draggedAnnotation: PolygonSearchAnnotation, touchedCoordinate: CLLocationCoordinate2D) {
        guard let annotationIndex = index(of: draggedAnnotation) else { return }
        var coordinates = annotations.map({ $0.coordinate })
        coordinates[annotationIndex] = touchedCoordinate
        mapPolygonFilterView.drawPolygon(with: coordinates)
    }

    private func updateNeighborPositions(draggedAnnotation: PolygonSearchAnnotation, annotationCoordinate: CLLocationCoordinate2D) {
        guard let index = index(of: draggedAnnotation) else { return }
        let annotation = annotations[index]

        let previousIndex = indexBefore(index)
        let neighborBefore = annotations[previousIndex]
        if neighborBefore.type == .intermediate {
            let previousVertex = annotations[indexBefore(previousIndex)]
            let intermediatePosition = previousVertex.getMidwayCoordinate(other: annotationCoordinate)
            neighborBefore.coordinate = intermediatePosition // should we update in the view instead? not actually needed
        }

        let nextIndex = indexAfter(index)
        let neighborAfter = annotations[nextIndex]
        if neighborAfter.type == .intermediate {
            let indexAfterNextIndex = indexAfter(nextIndex)
            let nextVertex = annotations[indexAfterNextIndex]
            let intermediatePosition = nextVertex.getMidwayCoordinate(other: annotationCoordinate)
            neighborAfter.coordinate = intermediatePosition
        }
    }

    private func addIntermediatePoint(after annotation: PolygonSearchAnnotation, nextPoint: CLLocationCoordinate2D?) {
        guard let nextPoint = nextPoint else { return }
        let midwayPointCoordinate = annotation.getMidwayCoordinate(other: nextPoint)
        let midwayAnnotation = PolygonSearchAnnotation(type: .intermediate)
        midwayAnnotation.title = "Annotation \(annotations.count)"
        midwayAnnotation.coordinate = midwayPointCoordinate
        guard let annotationIndex = index(of: annotation) else { return }
        annotations.insert(midwayAnnotation, at: annotationIndex + 1)
        mapPolygonFilterView.addAnnotation(midwayAnnotation)
    }

    private func index(of annotation: PolygonSearchAnnotation) -> Int? {
        return annotations.firstIndex(where: { $0.title == annotation.title })
    }

    private func indexBefore(_ index: Int) -> Int {
        return index > 0 ? index - 1 : annotations.count - 1
    }

    private func indexAfter(_ index: Int) -> Int {
        return index + 1 < annotations.count ? index + 1 : 0
    }
}

// MARK: - MapFilterViewDelegate

extension MapPolygonFilterViewController: MapPolygonFilterViewDelegate {
    func mapPolygonFilterViewDidSelectInitialAreaSelectionButton(_ mapPolygonFilterView: MapPolygonFilterView, coordinates: [CLLocationCoordinate2D]) {
        annotations.removeAll()

        for (index, coordinate) in coordinates.enumerated() {
            let annotation = PolygonSearchAnnotation(type: .vertex)
            annotation.title = "Annotation \(annotations.count)"
            annotation.coordinate = coordinate
            annotations.append(annotation)
            mapPolygonFilterView.addAnnotation(annotation)

            let nextPoint = index == coordinates.count - 1 ? coordinates.first : coordinates[index + 1]
            addIntermediatePoint(after: annotation, nextPoint: nextPoint)
        }
        annotationDidMove = false
        mapPolygonFilterView.configure(for: .polygonSelection)
        mapPolygonFilterView.drawPolygon(with: annotations)
    }

    func mapPolygonFilterViewDidSelectLocationButton(_ mapPolygonFilterView: MapPolygonFilterView) {
        nextRegionChangeIsFromUserInteraction = true
        centerOnUserLocation()
    }
}

// MARK: - MKmapPolygonViewDelegate

extension MapPolygonFilterViewController: MKMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        guard !isMapLoaded else {
            return
        }

        isMapLoaded = true
        mapPolygonFilterView.centerOnInitialCoordinate()
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let polygon = MKPolygonRenderer(overlay: overlay)
            polygon.strokeColor = UIColor.accentSecondaryBlue
            polygon.fillColor = UIColor.accentSecondaryBlue.withAlphaComponent(0.15)
            polygon.lineWidth = 2
            if #available(iOS 13.0, *) {
                // MapKit renders overlays as vectors by default from iOS 13, but we are opting out of it.
                // The polygon is a large and complex overlay, that performs better when rendered as a bitmap.
                polygon.shouldRasterize = true
            }
            return polygon
        }
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

        mapPolygonFilterView.isUserLocationButtonHighlighted = coordinate == mapView.userLocation.coordinate

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
            mapPolygonFilterView.centerOnInitialCoordinate()
            hasRequestedLocationAuthorization = false
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard
            !(annotation is MKUserLocation),
            let annotation = annotation as? PolygonSearchAnnotation
        else { return nil }

        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if let view = view {
            view.annotation = annotation
        }
        else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            view?.canShowCallout = false
            view?.isDraggable = false

            let drag = UILongPressGestureRecognizer(target: self, action: #selector(handleAnnotationMovement(gesture:)))
            drag.minimumPressDuration = 0
            drag.allowableMovement = .greatestFiniteMagnitude
            view?.addGestureRecognizer(drag)
        }
        view?.image = mapPolygonFilterView.imageForAnnotation(ofType: annotation.type)
        return view
    }
}

// MARK: - SearchLocationViewControllerDelegate

extension MapPolygonFilterViewController: SearchLocationViewControllerDelegate {
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

            mapPolygonFilterView.centerOnCoordinate(coordinate, animated: true)
        }
    }
}

// MARK: - Store

private extension MapPolygonFilterViewController {

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
        }
    }

    var locationName: String? {
        get {
            return selectionStore.value(for: locationNameFilter)
        }
        set {
            selectionStore.setValue(newValue, for: locationNameFilter)
            mapPolygonFilterView.locationName = newValue
        }
    }

    var bbox: String? {
        get {
            return selectionStore.value(for: bboxFilter)
        }
        set {
            selectionStore.setValue(newValue, for: bboxFilter)
        }
    }

    var polygon: String? {
        get {
            return selectionStore.value(for: polygonFilter)
        }
        set {
            selectionStore.setValue(newValue, for: polygonFilter)
        }
    }
}

// MARK: - Private extensions

private func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return (fabs(lhs.latitude - rhs.latitude) <= 1e-5) && (fabs(lhs.longitude - rhs.longitude) <= 1e-5)
}
