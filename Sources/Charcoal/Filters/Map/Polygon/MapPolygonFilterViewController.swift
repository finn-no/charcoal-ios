//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import MapKit
import UIKit

protocol MapPolygonFilterViewControllerDelegate: AnyObject {
    func mapPolygonFilterViewControllerDidSelectFilter(_ mapPolygonFilterViewController: MapPolygonFilterViewController)
    func mapPolygonFilterViewControllerDidSelectInitialArea(_ mapPolygonFilterViewController: MapPolygonFilterViewController)
    func mapPolygonFilterViewController(_ mapPolygonFilterViewController: MapPolygonFilterViewController, searchIsEnabled: Bool)
    func mapPolygonFilterViewControllerWillBeginTextEditing(_ mapPolygonFilterViewController: MapPolygonFilterViewController)
    func mapPolygonFilterViewControllerWillEndTextEditing(_ mapPolygonFilterViewController: MapPolygonFilterViewController)
}

final class MapPolygonFilterViewController: UIViewController {
    weak var searchLocationDataSource: SearchLocationDataSource? {
        didSet {
            searchLocationViewController.searchLocationDataSource = searchLocationDataSource
        }
    }

    private enum State {
        case initialAreaSelection
        case bbox
        case polygon
        case invalidPolygon
    }

    weak var delegate: MapPolygonFilterViewControllerDelegate?

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
    private var isAwaitingLocationAuthorizationStatus = true
    private var isAwaitingCenterOnUserLocation = false

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

    init(locationNameFilter: Filter, bboxFilter: Filter, polygonFilter: Filter,
         selectionStore: FilterSelectionStore) {
        self.locationNameFilter = locationNameFilter
        self.bboxFilter = bboxFilter
        self.polygonFilter = polygonFilter
        self.selectionStore = selectionStore
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func viewDidAppear(_ animated: Bool) {
        let searchIsEnabled = state != .invalidPolygon && state != .initialAreaSelection
        delegate?.mapPolygonFilterViewController(self, searchIsEnabled: searchIsEnabled)
    }

    // MARK: - Setup

    private func setup() {
        locationManager.delegate = self

        view.addSubview(mapPolygonFilterView)
        mapPolygonFilterView.fillInSuperview()

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
        guard annotations.count > 0 else {
            state = .initialAreaSelection
            return
        }
        mapPolygonFilterView.drawPolygon(with: annotations)
        mapPolygonFilterView.configure(for: .polygonSelection)
        centerMapOnPolygonCenter()
    }

    // MARK: - Private methods

    private func configure(for state: State) {
        switch state {
        case .initialAreaSelection:
            delegate?.mapPolygonFilterViewController(self, searchIsEnabled: false)
            annotations.removeAll()
            resetFilterValues()
            mapPolygonFilterView.configure(for: .initialAreaSelection)

        case .polygon, .bbox:
            delegate?.mapPolygonFilterViewController(self, searchIsEnabled: true)
            annotations.filter { $0.type == .intermediate }.forEach { annotation in
                mapPolygonFilterView.addAnnotation(annotation)
            }
        case .invalidPolygon:
            delegate?.mapPolygonFilterViewController(self, searchIsEnabled: false)
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
            let minLongitude = longitudes.min(),
            minLatitude > 0,
            minLongitude > 0
        else { return }

        let midLatitude = (maxLatitude + minLatitude) / 2
        let midLongitude = (maxLongitude + minLongitude) / 2

        let centerCoordinate = CLLocationCoordinate2D(latitude: midLatitude, longitude: midLongitude)

        let minLocation = CLLocation(latitude: minLatitude, longitude: minLongitude)
        let maxLocation = CLLocation(latitude: maxLatitude, longitude: maxLongitude)
        let distance = minLocation.distance(from: maxLocation)

        mapPolygonFilterView.centerOnCoordinate(centerCoordinate, regionDistance: distance)
    }

    private func returnToMapFromLocationSearch() {
        mapPolygonFilterView.searchBar = searchLocationViewController.searchBar
        mapPolygonFilterView.setNeedsLayout()

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

        mapPolygonFilterView.centerOnUserLocation()
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

    private func presentLocationChangedAlert() {
        guard !annotations.isEmpty else { return }

        let alert = UIAlertController(
            title: "map.polygonSearch.locationChanged.alert.title".localized(),
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "map.polygonSearch.locationChanged.alert.keepArea".localized(),
            style: .default,
            handler: nil
        ))

        alert.addAction(UIAlertAction(
            title: "map.polygonSearch.locationChanged.alert.resetArea".localized(),
            style: .destructive,
            handler: { _ in
                self.mapPolygonFilterView.configure(for: .initialAreaSelection)
                self.state = .initialAreaSelection
            }
        ))
        present(alert, animated: true)
    }

    private func showMaxAnnotationsReachedInfo() {
        let infoBoxTitle: String
        if UserDefaults.standard.polygonSearchGuidanceShown,
            !UserDefaults.standard.polygonSearchDidDeletePoint {
            infoBoxTitle = "map.polygonSearch.maxAnnotations.label.title.detailed".localized()
        } else {
            infoBoxTitle = "map.polygonSearch.maxAnnotations.label.title".localized()
        }

        mapPolygonFilterView.showInfoBox(with: infoBoxTitle, completion: { [weak self] in
            self?.displayAnnotationCallout()
        })
    }

    private func displayAnnotationCallout() {
        guard
            !UserDefaults.standard.polygonSearchGuidanceShown,
            state != .bbox
        else { return }
        UserDefaults.standard.polygonSearchGuidanceShown = true

        let visibleVertices = mapPolygonFilterView.visibleAnnotations.filter { $0.type == .vertex }
        guard
            let annotationForCallout = visibleVertices.min(by: { $0.coordinate.latitude < $1.coordinate.latitude })
        else { return }

        mapPolygonFilterView.selectAnnotation(annotationForCallout)
    }

    // MARK: - Polygon handling

    private func setupAnnotations(from coordinates: [CLLocationCoordinate2D]) {
        guard coordinates.count > 2 else { return }
        mapPolygonFilterView.removeAnnotations(annotations)
        annotations.removeAll()

        for coordinate in coordinates {
            let annotation = PolygonSearchAnnotation(type: .vertex)
            annotation.coordinate = coordinate
            annotations.append(annotation)
            mapPolygonFilterView.addAnnotation(annotation)
        }

        if coordinates.count < MapPolygonFilterViewController.maxNumberOfVertices {
            addIntermediatePointsToPolygon()
        }
    }

    @objc private func handleAnnotationMovement(gesture: UILongPressGestureRecognizer) {
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
            gesture.view?.transform = CGAffineTransform(translationX: location.x - dragStartPosition.x,
                                                        y: location.y - dragStartPosition.y)

            let touchedCoordinate = updatedCoordinate(for: annotation, gestureLocation: location)
            updatePolygon(withTemporaryCoordinate: touchedCoordinate, for: annotation)

        } else if gesture.state == .ended || gesture.state == .cancelled {
            guard dragStartPosition != location else { return }

            let coordinate = updatedCoordinate(for: annotation, gestureLocation: location)
            updatePolygon(withFinalCoordinate: coordinate, for: annotation, withView: annotationView)
        }
    }

    @objc private func handleAnnotationDoubleTap(gesture: UITapGestureRecognizer) {
        UserDefaults.standard.polygonSearchDidDeletePoint = true

        guard annotations.filter({ $0.type == .vertex }).count > 4 else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            mapPolygonFilterView.showInfoBox(
                with: "map.polygonSearch.minAnnotations.label.title".localized(),
                completion: nil
            )
            return
        }
        guard
            let annotationView = gesture.view as? MKAnnotationView,
            let annotation = annotationView.annotation as? PolygonSearchAnnotation,
            annotation.type == .vertex,
            let index = index(of: annotation)
        else { return }

        if annotations.filter({ $0.type == .vertex }).count == MapPolygonFilterViewController.maxNumberOfVertices {
            mapPolygonFilterView.removeAnnotation(annotation)
            annotations.remove(at: index)
            addIntermediatePointsToPolygon()

        } else {
            let leadingIntermediateIndex = indexBefore(index)
            let trailingIntermediateIndex = indexAfter(index)
            let leadingVertexAnnotation = annotations[indexBefore(leadingIntermediateIndex)]

            let annotationsToRemove = [
                annotation,
                annotations[leadingIntermediateIndex],
                annotations[trailingIntermediateIndex],
            ]
            mapPolygonFilterView.removeAnnotations(annotationsToRemove)
            annotations.removeAll(where: { annotationsToRemove.contains($0) })
            addIntermediatePoint(after: leadingVertexAnnotation)
        }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        state = isPolygonStateValid() ? .polygon : .invalidPolygon
        mapPolygonFilterView.drawPolygon(with: annotations)
        updateFilterValues()
    }

    private func updatePolygon(withTemporaryCoordinate coordinate: CLLocationCoordinate2D,
                               for annotation: PolygonSearchAnnotation) {
        guard let index = index(of: annotation) else { return }
        var coordinates = annotations.map { $0.coordinate }
        coordinates[index] = coordinate
        mapPolygonFilterView.drawPolygon(with: coordinates)
        updateNeighborPositions(around: annotation, with: coordinate)
    }

    private func updatePolygon(withFinalCoordinate coordinate: CLLocationCoordinate2D,
                               for annotation: PolygonSearchAnnotation,
                               withView annotationView: MKAnnotationView) {
        annotationView.transform = .identity
        annotation.coordinate = coordinate

        // Annotation must be removed and readded for display priorities to work as intended
        mapPolygonFilterView.removeAnnotation(annotation)
        mapPolygonFilterView.addAnnotation(annotation)

        if annotation.type == .intermediate {
            convertToVertexAnnotation(annotation: annotation, with: annotationView)
        } else {
            updateNeighborPositions(around: annotation, with: coordinate)
        }

        state = isPolygonStateValid() ? .polygon : .invalidPolygon
        mapPolygonFilterView.drawPolygon(with: annotations)
        updateFilterValues()
    }

    private func updatedCoordinate(for annotation: PolygonSearchAnnotation,
                                   gestureLocation: CGPoint) -> CLLocationCoordinate2D {
        let translate = CGPoint(x: gestureLocation.x - dragStartPosition.x,
                                y: gestureLocation.y - dragStartPosition.y)

        let originalLocation = mapPolygonFilterView.point(for: annotation)

        let updatedLocation = CGPoint(x: originalLocation.x + translate.x,
                                      y: originalLocation.y + translate.y)

        return mapPolygonFilterView.coordinate(for: updatedLocation)
    }

    private func updateNeighborPositions(around movingAnnotation: PolygonSearchAnnotation,
                                         with coordinate: CLLocationCoordinate2D) {
        guard let index = index(of: movingAnnotation) else { return }

        let previousIndex = indexBefore(index)
        let neighborBefore = annotations[previousIndex]
        if neighborBefore.type == .intermediate {
            let previousVertex = annotations[indexBefore(previousIndex)]
            let intermediatePosition = previousVertex.getMidwayCoordinate(other: coordinate)
            neighborBefore.coordinate = intermediatePosition
        }

        let nextIndex = indexAfter(index)
        let neighborAfter = annotations[nextIndex]
        if neighborAfter.type == .intermediate {
            let nextVertex = annotations[indexAfter(nextIndex)]
            let intermediatePosition = nextVertex.getMidwayCoordinate(other: coordinate)
            neighborAfter.coordinate = intermediatePosition
        }
    }

    private func convertToVertexAnnotation(annotation: PolygonSearchAnnotation,
                                           with annotationView: MKAnnotationView) {
        annotation.type = .vertex

        if annotations.filter({ $0.type == .vertex }).count >= MapPolygonFilterViewController.maxNumberOfVertices {
            mapPolygonFilterView.removeAnnotations(annotations.filter { $0.type == .intermediate })
            annotations.removeAll(where: { $0.type == .intermediate })
            showMaxAnnotationsReachedInfo()

        } else if let index = index(of: annotation) {
            addIntermediatePoint(after: annotation)
            let previousAnnotation = annotations[indexBefore(index)]
            addIntermediatePoint(after: previousAnnotation)
        }
    }

    private func addIntermediatePointsToPolygon() {
        guard annotations.filter({ $0.type == .intermediate }).isEmpty else { return }
        let vertexAnnotations = annotations

        for annotation in vertexAnnotations {
            addIntermediatePoint(after: annotation)
        }
    }

    private func addIntermediatePoint(after annotation: PolygonSearchAnnotation) {
        guard
            annotation.type == .vertex,
            let annotationIndex = index(of: annotation)
        else { return }

        let nextAnnotation = annotations[indexAfter(annotationIndex)]
        guard nextAnnotation.type == .vertex else { return }

        let midwayCoordinate = annotation.getMidwayCoordinate(other: nextAnnotation.coordinate)
        let midwayAnnotation = PolygonSearchAnnotation(type: .intermediate)
        midwayAnnotation.coordinate = midwayCoordinate
        annotations.insert(midwayAnnotation, at: annotationIndex + 1)
        if state != .invalidPolygon {
            mapPolygonFilterView.addAnnotation(midwayAnnotation)
        }
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
        return !polygon.hasIntersectingEdges
    }

    private func index(of annotation: PolygonSearchAnnotation) -> Int? {
        return annotations.firstIndex(where: { $0 == annotation })
    }

    private func indexBefore(_ index: Int) -> Int {
        return index > 0 ? index - 1 : annotations.count - 1
    }

    private func indexAfter(_ index: Int) -> Int {
        return index + 1 < annotations.count ? index + 1 : 0
    }
}

// MARK: - MapPolygonFilterViewDelegate

extension MapPolygonFilterViewController: MapPolygonFilterViewDelegate {
    func mapPolygonFilterViewDidSelectRedoAreaSelectionButton(_ mapPolygonFilterView: MapPolygonFilterView) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()

        if state == .bbox {
            state = .initialAreaSelection
            return
        }

        let preferredStyle: UIAlertController.Style = traitCollection.horizontalSizeClass == .compact ? .actionSheet : .alert

        let alertController = UIAlertController(
            title: "map.polygonSearch.resetPolygon.alert.title".localized(),
            message: nil,
            preferredStyle: preferredStyle
        )
        alertController.addAction(UIAlertAction(
            title: "map.polygonSearch.resetPolygon.alert.action".localized(),
            style: .destructive,
            handler: { _ in
                self.state = .initialAreaSelection
            }
        )
        )
        alertController.addAction(UIAlertAction(
            title: "cancel".localized(),
            style: .cancel,
            handler: nil
        )
        )
        present(alertController, animated: true)
    }

    func mapPolygonFilterViewDidSelectInitialAreaSelectionButton(_ mapPolygonFilterView: MapPolygonFilterView,
                                                                 coordinates: [CLLocationCoordinate2D]) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        state = .bbox
        setupAnnotations(from: coordinates)
        mapPolygonFilterView.drawPolygon(with: annotations)
        mapPolygonFilterView.configure(for: .polygonSelection)
        updateFilterValues()
        delegate?.mapPolygonFilterViewControllerDidSelectInitialArea(self)
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
            polygon.strokeColor = MapPolygonFilterView.overlayColor

            var validPolygonAlphaComponent: CGFloat = 0.15
            var invalidPolygonAlphaComponent: CGFloat = 0.2
            if traitCollection.userInterfaceStyle == .dark {
                validPolygonAlphaComponent = 0.05
                invalidPolygonAlphaComponent = 0.1
            }
            polygon.fillColor = state != .invalidPolygon ?
                MapPolygonFilterView.overlayColor.withAlphaComponent(validPolygonAlphaComponent) :
                UIColor.textNegative.withAlphaComponent(invalidPolygonAlphaComponent)
            polygon.lineWidth = 2

            // MapKit renders overlays as vectors by default from iOS 13, but we are opting out of it.
            // The polygon is a large and complex overlay, that performs better when rendered as a bitmap.
            polygon.shouldRasterize = true

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

        let reuseIdentifier = "polygonpin"

        var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if let view = view {
            view.annotation = annotation
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            view?.canShowCallout = true
            view?.isDraggable = false

            let longPressGestureRecognizer = UILongPressGestureRecognizer(
                target: self,
                action: #selector(handleAnnotationMovement(gesture:))
            )
            longPressGestureRecognizer.minimumPressDuration = 0
            longPressGestureRecognizer.allowableMovement = .greatestFiniteMagnitude
            longPressGestureRecognizer.delegate = self
            view?.addGestureRecognizer(longPressGestureRecognizer)

            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                    action: #selector(handleAnnotationDoubleTap(gesture:)))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            view?.addGestureRecognizer(doubleTapGestureRecognizer)
        }
        view?.image = mapPolygonFilterView.imageForAnnotation(ofType: annotation.type)
        view?.displayPriority = annotation.type == .vertex ? .required : .defaultHigh
        view?.collisionMode = .circle
        return view
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard !(view.annotation is MKUserLocation) else { return }

        let label = Label(style: .detail)
        label.text = "map.polygonSearch.doubleClick.callout.title".localized()
        label.textAlignment = .center
        label.numberOfLines = 0
        view.detailCalloutAccessoryView = label

        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
    }
}

// MARK: - SearchLocationViewControllerDelegate

extension MapPolygonFilterViewController: SearchLocationViewControllerDelegate {
    func searchLocationViewControllerDidSelectCurrentLocation(_ searchLocationViewController: SearchLocationViewController) {
        returnToMapFromLocationSearch()
        delegate?.mapPolygonFilterViewControllerWillEndTextEditing(self)
        centerOnUserLocation()
        presentLocationChangedAlert()
    }

    func searchLocationViewControllerWillBeginEditing(_ searchLocationViewController: SearchLocationViewController) {
        // Add view controller as child view controller
        add(searchLocationViewController)
        delegate?.mapPolygonFilterViewControllerWillBeginTextEditing(self)
    }

    func searchLocationViewControllerDidCancelSearch(_ searchLocationViewController: SearchLocationViewController) {
        returnToMapFromLocationSearch()
        delegate?.mapPolygonFilterViewControllerWillEndTextEditing(self)
    }

    func searchLocationViewController(_ searchLocationViewController: SearchLocationViewController,
                                      didSelectLocation location: LocationInfo?) {
        returnToMapFromLocationSearch()
        delegate?.mapPolygonFilterViewControllerWillEndTextEditing(self)

        if let location = location {
            let coordinate = CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )

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

// MARK: - ToggleFilter

extension MapPolygonFilterViewController: ToggleFilter {
    func resetFilterValues() {
        selectionStore.removeValues(for: [locationNameFilter, bboxFilter, polygonFilter])
    }

    func updateFilterValues() {
        guard state != .invalidPolygon else { return }

        delegate?.mapPolygonFilterViewControllerDidSelectFilter(self)
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
}

// MARK: - CLLocationManagerDelegate

extension MapPolygonFilterViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        isAwaitingLocationAuthorizationStatus = false

        if isAwaitingCenterOnUserLocation {
            isAwaitingCenterOnUserLocation = false
            centerOnUserLocation()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MapPolygonFilterViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = gestureRecognizer.view as? MKAnnotationView,
            view.annotation is PolygonSearchAnnotation {
            return true
        }
        return false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view == otherGestureRecognizer.view,
            let view = gestureRecognizer.view as? MKAnnotationView,
            view.annotation is PolygonSearchAnnotation {
            return true
        }
        return false
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

extension MKPolygonRenderer {
    open override func applyStrokeProperties(to context: CGContext, atZoomScale zoomScale: MKZoomScale) {
        super.applyStrokeProperties(to: context, atZoomScale: zoomScale)
        UIGraphicsPushContext(context)
        if let context = UIGraphicsGetCurrentContext() {
            let scale = UIScreen.main.scale
            context.setLineWidth(2.0 / zoomScale * scale)
        }
    }
}

// MARK: - UserDefaults

private extension UserDefaults {
    var polygonSearchGuidanceShown: Bool {
        get { return bool(forKey: "Charcoal." + #function) }
        set { set(newValue, forKey: "Charcoal." + #function) }
    }

    var polygonSearchDidDeletePoint: Bool {
        get { return bool(forKey: "Charcoal." + #function) }
        set { set(newValue, forKey: "Charcoal." + #function) }
    }
}
