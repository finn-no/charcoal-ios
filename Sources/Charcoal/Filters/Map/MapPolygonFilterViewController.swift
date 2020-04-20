//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit

protocol MapPolygonFilterViewControllerDelegate: AnyObject {
    func mapPolygonFilterViewControllerDidSelectFilter(_ mapPolygonFilterViewController: MapPolygonFilterViewController)
}

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

    private let locationNameFilter: Filter
    private let bboxFilter: Filter
    private let polygonFilter: Filter
    private let locationManager = CLLocationManager()
    private var hasRequestedLocationAuthorization = false
    private var nextRegionChangeIsFromUserInteraction = false
    private var hasChanges = false
    private var isMapLoaded = false
    private var dragStartPosition: CGPoint = .zero
    private var annotations = [PolygonSearchAnnotation]()
    private static let maxNumberOfVertices = 10

    private var state: State = .bbox {
        didSet {
            if oldValue != state {
                configure(for: state)
            }
        }
    }

    private enum State {
        case bbox
        case polygon
        case invalidPolygon
    }

    private lazy var mapPolygonFilterView: MapPolygonFilterView = {
        let mapPolygonFilterView = MapPolygonFilterView()
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

    weak var mapPolygonFilterDelegate: MapPolygonFilterViewControllerDelegate?

    // MARK: - Init

    init(title: String, locationNameFilter: Filter, bboxFilter: Filter, polygonFilter: Filter, selectionStore: FilterSelectionStore) {
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

    override func viewDidAppear(_ animated: Bool) {
        if annotations.count > 0 {
            mapPolygonFilterView.drawPolygon(with: annotations)
        }
    }

    override func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        if annotations.isEmpty {
            let coordinates = mapPolygonFilterView.initialSquareOverlayToCoordinates()
            for (index, coordinate) in coordinates.enumerated() {
                let annotation = PolygonSearchAnnotation(type: .vertex)
                annotation.coordinate = coordinate
                annotations.append(annotation)
            }
        }
        updateFilterValues()
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

        var coordinates = [CLLocationCoordinate2D]()
        if let coordinateQuery: String = selectionStore.value(for: polygonFilter) {
            coordinates = createPolygonCoordinates(from: coordinateQuery)
            state = .polygon
        } else if let bboxQuery: String = selectionStore.value(for: bboxFilter) {
            coordinates = createBboxCoordinates(from: bboxQuery)
            state = .bbox
        }
        setupAnnotations(from: coordinates)
        guard annotations.count > 0 else {
            centerOnUserLocation()
            return
        }
        mapPolygonFilterView.configure(for: .polygonSelection)
        mapPolygonFilterView.drawPolygon(with: annotations)
        centerMapOnPolygonCenter()
    }

    private func centerMapOnPolygonCenter() {
        let latitudes = annotations.map { $0.coordinate.latitude }
        let longitudes = annotations.map { $0.coordinate.longitude }

        guard
            let maxLatitude = latitudes.max(),
            let minLatitude = latitudes.min(),
            let maxLongitude = longitudes.max(),
            let minLongitude = longitudes.min()
        else { return }

        let midLatitude = (maxLatitude + minLatitude) / 2
        let midLongitude = (maxLongitude + minLongitude) / 2

        let centerCoordinate = CLLocationCoordinate2D(latitude: midLatitude, longitude: midLongitude)

        let minLocation = CLLocation(latitude: minLatitude, longitude: minLongitude)
        let maxLocation = CLLocation(latitude: maxLatitude, longitude: maxLongitude)
        let distance = minLocation.distance(from: maxLocation)

        mapPolygonFilterView.centerOnCoordinate(centerCoordinate, regionDistance: distance, animated: true)
    }

    // MARK: - Internal methods

    func resetFilterValues() {
        selectionStore.removeValues(for: [locationNameFilter, bboxFilter, polygonFilter])
    }

    // MARK: - Private methods

    private func configure(for state: State) {
        switch state {
        case .polygon, .bbox:
            bottomButton.isEnabled = true
            annotations.filter { $0.type == .intermediate }.forEach { annotation in
                mapPolygonFilterView.addAnnotation(annotation)
            }
        case .invalidPolygon:
            bottomButton.isEnabled = false
            mapPolygonFilterView.removeAnnotations(annotations.filter { $0.type == .intermediate })
        }
    }

    private func updateFilterValues() {
        guard state != .invalidPolygon else { return }

        mapPolygonFilterDelegate?.mapPolygonFilterViewControllerDidSelectFilter(self)
        locationName = mapPolygonFilterView.locationName

        switch state {
        case .bbox:
            let bboxCoordinates = [
                annotations.map { $0.coordinate.longitude }.min() ?? 0,
                annotations.map { $0.coordinate.latitude }.min() ?? 0,
                annotations.map { $0.coordinate.longitude }.max() ?? 0,
                annotations.map { $0.coordinate.latitude }.max() ?? 0,
            ]
            guard !bboxCoordinates.contains(0) else { return }
            bbox = bboxCoordinates.map { String($0) }.joined(separator: ",")
            polygon = nil

        case .polygon:
            polygon = createPolygonQuery(for: annotations.filter { $0.type == .vertex }.map { $0.coordinate })
            bbox = nil

        default:
            break
        }
    }

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

    private func resetPolygon() {
        annotations.removeAll()
        resetFilterValues()
        state = .bbox
        mapPolygonFilterView.configure(for: .squareAreaSelection)
    }

    private func presentLocationChangedAlertIfNeeded() {
        guard
            !annotations.isEmpty,
            mapPolygonFilterView.annotationPointsInMapView.count == annotations.count
        else { return }

        let alert = UIAlertController(title: "map.polygonSearch.locationChanged.alert.title".localized(), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "yes".localized(), style: .default, handler: { [weak self] _ in
            self?.repositionPolygon()
        }))
        alert.addAction(UIAlertAction(title: "no".localized(), style: .default, handler: { [weak self] _ in
            self?.annotations.removeAll()
            self?.mapPolygonFilterView.configure(for: .squareAreaSelection)
        }))
        present(alert, animated: true)
    }

    private func repositionPolygon() {
        let pointsInMapView = mapPolygonFilterView.annotationPointsInMapView
        for (index, annotation) in annotations.enumerated() {
            annotation.coordinate = mapPolygonFilterView.coordinateForPoint(pointsInMapView[index])
        }
        mapPolygonFilterView.drawPolygon(with: annotations)
        updateFilterValues()
    }

    // MARK: - Networking

    // TODO: Move networking code?

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

    private func createPolygonCoordinates(from query: String) -> [CLLocationCoordinate2D] {
        guard let formattedString = query.removingPercentEncoding else { return [] }
        var coordinates = [CLLocationCoordinate2D]()
        var points = formattedString.components(separatedBy: ",")
        points.removeLast() // The same coordinate is appended on beginning and end of the query, to close the polygon.
        for point in points {
            let pointCoordinate = point.components(separatedBy: " ").compactMap { Double($0) }
            guard pointCoordinate.count == 2 else { return [] }
            coordinates.append(CLLocationCoordinate2D(latitude: pointCoordinate[1], longitude: pointCoordinate[0]))
        }
        return coordinates
    }

    private func createBboxCoordinates(from query: String) -> [CLLocationCoordinate2D] {
        guard
            let values = (query.removingPercentEncoding)?.split(separator: ",").compactMap({ Double($0) }),
            values.count == 4
        else { return [] }

        let southWestCoordinate = CLLocationCoordinate2D(latitude: values[1], longitude: values[0])
        let northEastCoordinate = CLLocationCoordinate2D(latitude: values[3], longitude: values[2])
        let northWestCoordinate = CLLocationCoordinate2D(latitude: southWestCoordinate.latitude, longitude: northEastCoordinate.longitude)
        let southEastCoordinate = CLLocationCoordinate2D(latitude: northEastCoordinate.latitude, longitude: southWestCoordinate.longitude)

        return [southWestCoordinate, northWestCoordinate, northEastCoordinate, southEastCoordinate]
    }

    // MARK: - Polygon calculations

    private func setupAnnotations(from coordinates: [CLLocationCoordinate2D]) {
        annotations.removeAll()
        let shouldAppendIntermediateAnnotations = coordinates.count < MapPolygonFilterViewController.maxNumberOfVertices

        for (index, coordinate) in coordinates.enumerated() {
            let annotation = PolygonSearchAnnotation(type: .vertex)
            annotation.title = "Annotation \(annotations.count)"
            annotation.coordinate = coordinate
            annotations.append(annotation)
            mapPolygonFilterView.addAnnotation(annotation)

            if shouldAppendIntermediateAnnotations {
                let nextPoint = index == coordinates.count - 1 ? coordinates.first : coordinates[index + 1]
                addIntermediatePoint(after: annotation, nextPoint: nextPoint)
            }
        }
    }

    @objc func handleAnnotationMovement(gesture: UILongPressGestureRecognizer) {
        if state == .bbox {
            state = .polygon
        }
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

                if annotations.filter({ $0.type == .vertex }).count >= MapPolygonFilterViewController.maxNumberOfVertices {
                    mapPolygonFilterView.removeAnnotations(annotations.filter { $0.type == .intermediate })
                    annotations.removeAll(where: { $0.type == .intermediate })
                } else if let index = index(of: annotation) {
                    addIntermediatePoint(after: annotation, nextPoint: annotations[indexAfter(index, in: annotations)].coordinate)
                    let previousAnnotation = annotations[indexBefore(index, in: annotations)]
                    addIntermediatePoint(after: previousAnnotation, nextPoint: annotation.coordinate)
                }
            }
            let translate = CGPoint(x: location.x - dragStartPosition.x, y: location.y - dragStartPosition.y)
            let originalLocation = mapPolygonFilterView.pointForAnnoatation(annotation)
            let updatedLocation = CGPoint(x: originalLocation.x + translate.x, y: originalLocation.y + translate.y)

            annotationView.transform = .identity
            annotation.coordinate = mapPolygonFilterView.coordinateForPoint(updatedLocation)
            updateNeighborPositions(draggedAnnotation: annotation, annotationCoordinate: annotation.coordinate)

            state = isPolygonStateValid(draggedAnnotation: annotation) ? .polygon : .invalidPolygon
            mapPolygonFilterView.drawPolygon(with: annotations)
            updateFilterValues()
        }
    }

    private func isPolygonStateValid(draggedAnnotation: PolygonSearchAnnotation) -> Bool {
        let vertexAnnotations = annotations.filter { $0.type == .vertex }
        guard
            vertexAnnotations.count > 3,
            let lastAnnotation = vertexAnnotations.last
        else { return false }

        var edges = [PolygonEdge]()
        var previousPoint = mapPolygonFilterView.pointForAnnoatation(lastAnnotation)

        for (index, annotation) in vertexAnnotations.enumerated() {
            let point = mapPolygonFilterView.pointForAnnoatation(vertexAnnotations[index])
            let edge = PolygonEdge(previousPoint, point)
            edges.append(edge)
            previousPoint = point
        }

        let polygon = Polygon(edges: edges)
        return !polygon.hasIntersectingEdges()
    }

    private func updatePolygon(draggedAnnotation: PolygonSearchAnnotation, touchedCoordinate: CLLocationCoordinate2D) {
        guard let annotationIndex = index(of: draggedAnnotation) else { return }
        var coordinates = annotations.map { $0.coordinate }
        coordinates[annotationIndex] = touchedCoordinate
        mapPolygonFilterView.drawPolygon(with: coordinates)
    }

    private func updateNeighborPositions(draggedAnnotation: PolygonSearchAnnotation, annotationCoordinate: CLLocationCoordinate2D) {
        guard let index = index(of: draggedAnnotation) else { return }

        let previousIndex = indexBefore(index, in: annotations)
        let neighborBefore = annotations[previousIndex]
        if neighborBefore.type == .intermediate {
            let previousVertex = annotations[indexBefore(previousIndex, in: annotations)]
            let intermediatePosition = previousVertex.getMidwayCoordinate(other: annotationCoordinate)
            neighborBefore.coordinate = intermediatePosition // should we update in the view instead? not actually needed
        }

        let nextIndex = indexAfter(index, in: annotations)
        let neighborAfter = annotations[nextIndex]
        if neighborAfter.type == .intermediate {
            let indexAfterNextIndex = indexAfter(nextIndex, in: annotations)
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

    private func indexBefore(_ index: Int, in array: [AnyObject]) -> Int {
        return index > 0 ? index - 1 : array.count - 1
    }

    private func indexAfter(_ index: Int, in array: [AnyObject]) -> Int {
        return index + 1 < array.count ? index + 1 : 0
    }
}

// MARK: - MapFilterViewDelegate

extension MapPolygonFilterViewController: MapPolygonFilterViewDelegate {
    func mapPolygonFilterViewDidSelectRedoAreaSelectionButton(_ mapPolygonFilterView: MapPolygonFilterView) {
        if state == .bbox {
            resetPolygon()
            return
        }

        let alertController = UIAlertController(title: "map.polygonSearch.resetPolygon.alert.title".localized(), message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "map.polygonSearch.resetPolygon.alert.action".localized(), style: .destructive, handler: {_ in
            self.resetPolygon()
        }))
        alertController.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        present(alertController, animated: true)
    }

    func mapPolygonFilterViewDidSelectInitialAreaSelectionButton(_ mapPolygonFilterView: MapPolygonFilterView, coordinates: [CLLocationCoordinate2D]) {
        setupAnnotations(from: coordinates)
        state = .bbox
        mapPolygonFilterView.configure(for: .polygonSelection)
        mapPolygonFilterView.drawPolygon(with: annotations)
        updateFilterValues()
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
//        mapPolygonFilterView.centerOnInitialCoordinate()
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let polygon = MKPolygonRenderer(overlay: overlay)
            polygon.strokeColor = UIColor.accentSecondaryBlue
            polygon.fillColor = state != .invalidPolygon ? UIColor.accentSecondaryBlue.withAlphaComponent(0.15) : UIColor.red.withAlphaComponent(0.20)
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

        nextRegionChangeIsFromUserInteraction = false
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if hasRequestedLocationAuthorization {
            centerOnUserLocation()
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
        } else {
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
        presentLocationChangedAlertIfNeeded()
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

            mapPolygonFilterView.centerOnCoordinate(coordinate, animated: true)
            presentLocationChangedAlertIfNeeded()
        }
    }
}

// MARK: - Store

private extension MapPolygonFilterViewController {

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
