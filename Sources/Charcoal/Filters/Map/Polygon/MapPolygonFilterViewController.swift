//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit

protocol MapPolygonFilterViewControllerDelegate: AnyObject {
    func mapPolygonFilterViewControllerDidSelectFilter(_ mapPolygonFilterViewController: MapPolygonFilterViewController)
    func mapPolygonFilterViewController(_ mapPolygonFilterViewController: MapPolygonFilterViewController, didSelect selection: CharcoalViewController.PolygonSelection)
}

final class MapPolygonFilterViewController: FilterViewController {
    weak var searchLocationDataSource: SearchLocationDataSource? {
        didSet {
            searchLocationViewController.searchLocationDataSource = searchLocationDataSource
        }
    }

    private enum State {
        case bbox
        case polygon
        case invalidPolygon
    }

    weak var mapPolygonFilterDelegate: MapPolygonFilterViewControllerDelegate?

    static let annotationId = "polygonpin"

    // MARK: - Private properties

    private let locationNameFilter: Filter
    private let bboxFilter: Filter
    private let polygonFilter: Filter
    private let locationManager = CLLocationManager()
    private var hasRequestedLocationAuthorization = false
    private var nextRegionChangeIsFromUserInteraction = false
    private var didSelectLocationButton = false
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

    override func filterBottomButtonView(_ filterBottomButtonView: FilterBottomButtonView, didTapButton button: UIButton) {
        if annotations.isEmpty {
            let coordinates = mapPolygonFilterView.initialAreaOverlayToCoordinates()
            for coordinate in coordinates {
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
        if let coordinateQuery: String = selectionStore.value(for: polygonFilter),
            let polygonCoordinates = PolygonData.createPolygonCoordinates(from: coordinateQuery) {
            coordinates = polygonCoordinates
            state = .polygon
        } else if let bboxQuery: String = selectionStore.value(for: bboxFilter),
            let bboxCoordinates = PolygonData.createBBoxCoordinates(from: bboxQuery) {
            coordinates = bboxCoordinates
            state = .bbox
        }
        setupAnnotations(from: coordinates)
        guard annotations.count > 0 else { return }
        mapPolygonFilterView.drawPolygon(with: annotations)
        mapPolygonFilterView.configure(for: .polygonSelection)
        centerMapOnPolygonCenter()
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

        mapPolygonFilterView.centerOnCoordinate(centerCoordinate, regionDistance: distance)
    }

    private func updateFilterValues() {
        guard state != .invalidPolygon else { return }

        mapPolygonFilterDelegate?.mapPolygonFilterViewControllerDidSelectFilter(self)
        locationName = mapPolygonFilterView.locationName

        let vertexAnnotationCoordinates = annotations.filter { $0.type == .vertex }.map { $0.coordinate }

        switch state {
        case .bbox:
            bbox = PolygonData.createBBoxQuery(for: vertexAnnotationCoordinates)
            polygon = nil

        case .polygon:
            polygon = PolygonData.createPolygonQuery(for: vertexAnnotationCoordinates)
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

    private func presentLocationChangedAlert() {
        guard !annotations.isEmpty else { return }

        let alert = UIAlertController(title: "map.polygonSearch.locationChanged.alert.title".localized(), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "map.polygonSearch.locationChanged.alert.keepArea".localized(), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "map.polygonSearch.locationChanged.alert.resetArea".localized(), style: .destructive, handler: { _ in
            self.annotations.removeAll()
            self.mapPolygonFilterView.configure(for: .initialAreaSelection)
        }))
        present(alert, animated: true)
    }

    // MARK: - Polygon handling

    private func setupAnnotations(from coordinates: [CLLocationCoordinate2D]) {
        guard coordinates.count > 2 else { return }
        annotations.removeAll()
        let shouldAppendIntermediateAnnotations = coordinates.count < MapPolygonFilterViewController.maxNumberOfVertices

        for (index, coordinate) in coordinates.enumerated() {
            let annotation = PolygonSearchAnnotation(type: .vertex)
            annotation.title = "Annotation \(annotations.count)"
            annotation.coordinate = coordinate
            annotations.append(annotation)
            mapPolygonFilterView.addAnnotation(annotation)

            if shouldAppendIntermediateAnnotations {
                let nextCoordinate = index == coordinates.count - 1 ? coordinates.first : coordinates[index + 1]
                addIntermediatePoint(after: annotation, nextCoordinate: nextCoordinate)
            }
        }
    }

    private func resetPolygon() {
        annotations.removeAll()
        resetFilterValues()
        state = .bbox
        mapPolygonFilterView.configure(for: .initialAreaSelection)
    }

    @objc private func handleAnnotationMovement(gesture: UILongPressGestureRecognizer) {
        if state == .bbox {
            state = .polygon
            mapPolygonFilterDelegate?.mapPolygonFilterViewController(self, didSelect: .polygonArea)
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

            let touchedCoordinate = updatedCoordinate(for: annotation, gestureLocation: location)
            updatePolygon(movingAnnotation: annotation, with: touchedCoordinate)
            updateNeighborPositions(around: annotation, with: touchedCoordinate)

        } else if gesture.state == .ended || gesture.state == .cancelled {
            if annotation.type == .intermediate {
                convertToVertexAnnotation(annotation: annotation, with: annotationView)
            }
            annotationView.transform = .identity
            annotation.coordinate = updatedCoordinate(for: annotation, gestureLocation: location)
            updateNeighborPositions(around: annotation, with: annotation.coordinate)

            state = isPolygonStateValid() ? .polygon : .invalidPolygon
            mapPolygonFilterView.drawPolygon(with: annotations)
            updateFilterValues()
        }
    }

    @objc private func handleAnnotationDoubleTap(gesture: UITapGestureRecognizer) {
        print("DOUBLE TAPPED")
    }

    private func updatedCoordinate(for annotation: PolygonSearchAnnotation, gestureLocation: CGPoint) -> CLLocationCoordinate2D {
        let translate = CGPoint(x: gestureLocation.x - dragStartPosition.x, y: gestureLocation.y - dragStartPosition.y)
        let originalLocation = mapPolygonFilterView.point(for: annotation)
        let updatedLocation = CGPoint(x: originalLocation.x + translate.x, y: originalLocation.y + translate.y)
        return mapPolygonFilterView.coordinate(for: updatedLocation)
    }

    private func updatePolygon(movingAnnotation: PolygonSearchAnnotation, with coordinate: CLLocationCoordinate2D) {
        guard let index = index(of: movingAnnotation) else { return }
        var coordinates = annotations.map { $0.coordinate }
        coordinates[index] = coordinate
        mapPolygonFilterView.drawPolygon(with: coordinates)
    }

    private func updateNeighborPositions(around movingAnnotation: PolygonSearchAnnotation, with coordinate: CLLocationCoordinate2D) {
        guard let index = index(of: movingAnnotation) else { return }

        let previousIndex = indexBefore(index, in: annotations)
        let neighborBefore = annotations[previousIndex]
        if neighborBefore.type == .intermediate {
            let previousVertex = annotations[indexBefore(previousIndex, in: annotations)]
            let intermediatePosition = previousVertex.getMidwayCoordinate(other: coordinate)
            neighborBefore.coordinate = intermediatePosition
        }

        let nextIndex = indexAfter(index, in: annotations)
        let neighborAfter = annotations[nextIndex]
        if neighborAfter.type == .intermediate {
            let nextVertex = annotations[indexAfter(nextIndex, in: annotations)]
            let intermediatePosition = nextVertex.getMidwayCoordinate(other: coordinate)
            neighborAfter.coordinate = intermediatePosition
        }
    }

    private func convertToVertexAnnotation(annotation: PolygonSearchAnnotation, with annotationView: MKAnnotationView) {
        annotation.type = .vertex
        annotationView.image = mapPolygonFilterView.imageForAnnotation(ofType: .vertex)

        if annotations.filter({ $0.type == .vertex }).count >= MapPolygonFilterViewController.maxNumberOfVertices {
            mapPolygonFilterView.removeAnnotations(annotations.filter { $0.type == .intermediate })
            annotations.removeAll(where: { $0.type == .intermediate })
        } else if let index = index(of: annotation) {
            addIntermediatePoint(after: annotation, nextCoordinate: annotations[indexAfter(index, in: annotations)].coordinate)
            let previousAnnotation = annotations[indexBefore(index, in: annotations)]
            addIntermediatePoint(after: previousAnnotation, nextCoordinate: annotation.coordinate)
        }
    }

    private func addIntermediatePoint(after annotation: PolygonSearchAnnotation, nextCoordinate: CLLocationCoordinate2D?) {
        guard
            let nextCoordinate = nextCoordinate,
            let annotationIndex = index(of: annotation)
        else { return }

        let midwayCoordinate = annotation.getMidwayCoordinate(other: nextCoordinate)
        let midwayAnnotation = PolygonSearchAnnotation(type: .intermediate)
        midwayAnnotation.title = "Annotation \(annotations.count)"
        midwayAnnotation.coordinate = midwayCoordinate
        annotations.insert(midwayAnnotation, at: annotationIndex + 1)
        mapPolygonFilterView.addAnnotation(midwayAnnotation)
    }

    private func isPolygonStateValid() -> Bool {
        let vertexAnnotations = annotations.filter { $0.type == .vertex }
        guard
            vertexAnnotations.count > 3,
            let lastAnnotation = vertexAnnotations.last
        else { return false }

        var edges = [PolygonEdge]()
        var previousPoint = mapPolygonFilterView.point(for: lastAnnotation)

        for annotation in vertexAnnotations {
            let point = mapPolygonFilterView.point(for: annotation)
            edges.append(PolygonEdge(previousPoint, point))
            previousPoint = point
        }

        let polygon = Polygon(edges: edges)
        return !polygon.hasIntersectingEdges()
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

// MARK: - MapPolygonFilterViewDelegate

extension MapPolygonFilterViewController: MapPolygonFilterViewDelegate {
    func mapPolygonFilterViewDidSelectRedoAreaSelectionButton(_ mapPolygonFilterView: MapPolygonFilterView) {
        if state == .bbox {
            resetPolygon()
            return
        }

        let alertController = UIAlertController(title: "map.polygonSearch.resetPolygon.alert.title".localized(), message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "map.polygonSearch.resetPolygon.alert.action".localized(), style: .destructive, handler: { _ in
            self.resetPolygon()
        }))
        alertController.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        present(alertController, animated: true)
    }

    func mapPolygonFilterViewDidSelectInitialAreaSelectionButton(_ mapPolygonFilterView: MapPolygonFilterView, coordinates: [CLLocationCoordinate2D]) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        setupAnnotations(from: coordinates)
        state = .bbox
        mapPolygonFilterView.drawPolygon(with: annotations)
        mapPolygonFilterView.configure(for: .polygonSelection)
        updateFilterValues()
        mapPolygonFilterDelegate?.mapPolygonFilterViewController(self, didSelect: .initialBboxArea)
    }

    func mapPolygonFilterViewDidSelectLocationButton(_ mapPolygonFilterView: MapPolygonFilterView) {
        nextRegionChangeIsFromUserInteraction = true
        centerOnUserLocation()
        didSelectLocationButton = true
    }
}

// MARK: - MKMapViewDelegate

extension MapPolygonFilterViewController: MKMapViewDelegate {
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
        }
        if didSelectLocationButton, !mapPolygonFilterView.polygonIsVisibleInMap() {
            presentLocationChangedAlert()
        }
        didSelectLocationButton = false
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

        var view = mapView.dequeueReusableAnnotationView(withIdentifier: MapPolygonFilterViewController.annotationId)
        if let view = view {
            view.annotation = annotation
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: MapPolygonFilterViewController.annotationId)
            view?.canShowCallout = false
            view?.isDraggable = false

            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleAnnotationMovement(gesture:)))
            longPressGestureRecognizer.minimumPressDuration = 0
            longPressGestureRecognizer.allowableMovement = .greatestFiniteMagnitude
            longPressGestureRecognizer.delegate = self
            view?.addGestureRecognizer(longPressGestureRecognizer)

            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleAnnotationDoubleTap(gesture:)))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            view?.addGestureRecognizer(doubleTapGestureRecognizer)
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
        presentLocationChangedAlert()
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

            locationName = location.name

            let previousCenter = mapPolygonFilterView.centerCoordinate

            mapPolygonFilterView.centerOnCoordinate(coordinate)

            if let previousCenter = previousCenter,
                !(previousCenter == coordinate) {
                presentLocationChangedAlert()
            }
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
