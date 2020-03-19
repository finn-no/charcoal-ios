//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit
import FinniversKit

protocol MapPolygonFilterViewDelegate: MKMapViewDelegate {
    func mapPolygonFilterViewDidSelectLocationButton(_ mapPolygonFilterView: MapPolygonFilterView)
    func mapPolygonFilterViewDidSelectInitialAreaSelectionButton(_ mapPolygonFilterView: MapPolygonFilterView, coordinates: [CLLocationCoordinate2D])
}

final class MapPolygonFilterView: UIView {
    private static let defaultRadius = 40000
    private static let defaultCenterCoordinate = CLLocationCoordinate2D(latitude: 59.9171, longitude: 10.7275)
    private static let userLocationButtonWidth: CGFloat = 46
    private var polygon: MKPolygon?
    private var annotations = [PolygonSearchAnnotation]()
    private var dragStartPosition: CGPoint = .zero
    private var previousPolygonRenderer: MKPolygonRenderer? = nil

    weak var delegate: MapPolygonFilterViewDelegate?

    var searchBar: UISearchBar? {
        didSet {
            oldValue?.removeFromSuperview()
            setupSearchBar(searchBar)
        }
    }

    var locationName: String? {
        get {
            return searchBar?.text
        }
        set {
            searchBar?.text = newValue
        }
    }

    var centerCoordinate: CLLocationCoordinate2D {
        return mapView.centerCoordinate
    }

    var isUserLocationButtonHighlighted = false {
        didSet {
            userLocationButton.isHighlighted = isUserLocationButtonHighlighted
        }
    }

    private(set) var radius: Int
    private let initialCenterCoordinate: CLLocationCoordinate2D?

    private var updateViewDispatchWorkItem: DispatchWorkItem? {
        didSet {
            oldValue?.cancel()
        }
    }

    // MARK: - Subviews

    private lazy var mapContainerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var mapView: MKMapView = {
        let view = MKMapView(frame: .zero)
        view.showsUserLocation = true
        view.isRotateEnabled = false
        view.isPitchEnabled = false
        view.isZoomEnabled = true
        view.layer.cornerRadius = 8
        view.delegate = self
        return view
    }()

    private lazy var userLocationButton: UIButton = {
        let button = UIButton(withAutoLayout: true)
        button.backgroundColor = Theme.mainBackground
        button.tintColor = .btnPrimary

        button.layer.cornerRadius = MapPolygonFilterView.userLocationButtonWidth / 2
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.5

        button.setImage(UIImage(named: .locateUserOutlined), for: .normal)
        button.setImage(UIImage(named: .locateUserFilled), for: .highlighted)
        button.addTarget(self, action: #selector(didTapLocateUserButton), for: .touchUpInside)

        return button
    }()

    private lazy var initialAreaSelectionButton: Button = {
        let button = Button(style: .callToAction, size: .small, withAutoLayout: true)
        button.setTitle("Fest kartutsnittet her", for: .normal)
        button.addTarget(self, action: #selector(didTapAreaSelectionButton), for: .touchUpInside)

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.5

        return button
    }()

    private lazy var radiusOverlayView = MapPolygonOverlayView(withAutoLayout: true)

    // MARK: - Init

    init(radius: Int?, centerCoordinate: CLLocationCoordinate2D?) {
        self.radius = radius ?? MapPolygonFilterView.defaultRadius
        initialCenterCoordinate = centerCoordinate
        super.init(frame: CGRect(x: 0, y: 0, width: 250, height: 100))

        setup()
        updateRegion(animated: false)
        centerOnInitialCoordinate()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func layoutSubviews() {
        super.layoutSubviews()

        // Update radius so it fits for new view sizes
        let updateViewWorkItem = DispatchWorkItem { [weak self] in
            self?.updateRegion()
        }

        updateViewDispatchWorkItem = updateViewWorkItem

        // Use a delay incase the view is being changed to new sizes by user
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: updateViewWorkItem)
    }

    // MARK: - API

    func setMapTileOverlay(_ overlay: MKTileOverlay) {
        mapView.addOverlay(overlay, level: .aboveLabels)
    }

    func centerOnInitialCoordinate() {
        let userCoordinate = mapView.userLocation.location?.coordinate
        let centerCoordinate = initialCenterCoordinate ?? userCoordinate ?? MapPolygonFilterView.defaultCenterCoordinate

        centerOnCoordinate(centerCoordinate, animated: false)
    }

    func centerOnCoordinate(_ coordinate: CLLocationCoordinate2D, animated: Bool) {
        mapView.setCenter(coordinate, animated: animated)
    }

    func centerOnUserLocation() {
        if let location = mapView.userLocation.location {
            centerOnCoordinate(location.coordinate, animated: true)
        }
    }

    func updateRadiusView() {
//        let region = mapView.centeredRegion(for: Double(radius))
//        radiusOverlayView.width = mapView.convert(region, toRectTo: mapView).width
    }

    private func updateRegion(animated: Bool = true) {
        let region = mapView.centeredRegion(for: Double(radius) * 2.2)

        mapView.setRegion(region, animated: animated)
        updateRadiusView()
    }

    func configurePolygons(_ polygonPoints: [CLLocationCoordinate2D]) {
        radiusOverlayView.isHidden = true
        initialAreaSelectionButton.isHidden = true

        polygon = MKPolygon(coordinates: polygonPoints, count: polygonPoints.count)
        mapView.addOverlay(polygon!)

        for (index, point) in polygonPoints.enumerated() {
            let annotation = PolygonSearchAnnotation(type: .vertex)
            annotation.title = "Annotation \(annotations.count)"
            annotation.coordinate = point
            annotations.append(annotation)
            mapView.addAnnotation(annotation)

            let nextPoint = index == polygonPoints.count - 1 ? polygonPoints.first : polygonPoints[index + 1]
            addIntermediatePoint(after: annotation, nextPoint: nextPoint)
        }
    }

    private func addIntermediatePoint(after annotation: PolygonSearchAnnotation, nextPoint: CLLocationCoordinate2D?) {
        guard let nextPoint = nextPoint else { return }
        let midwayPointCoordinate = annotation.getMidwayCoordinate(other: nextPoint)
        let midwayAnnotation = PolygonSearchAnnotation(type: .intermediate)
        midwayAnnotation.title = "Annotation \(annotations.count)"
        midwayAnnotation.coordinate = midwayPointCoordinate
        annotations.append(midwayAnnotation)
        mapView.addAnnotation(midwayAnnotation)
    }

    // MARK: - Actions

    @objc private func didTapLocateUserButton() {
        delegate?.mapPolygonFilterViewDidSelectLocationButton(self)
    }

    @objc private func didTapAreaSelectionButton() {
        let offset = radiusOverlayView.width/2
        let coordinates = [
            mapView.convert(CGPoint(x: mapView.center.x - offset, y: mapView.center.y - offset), toCoordinateFrom: mapView),
            mapView.convert(CGPoint(x: mapView.center.x + offset, y: mapView.center.y - offset), toCoordinateFrom: mapView),
            mapView.convert(CGPoint(x: mapView.center.x + offset, y: mapView.center.y + offset), toCoordinateFrom: mapView),
            mapView.convert(CGPoint(x: mapView.center.x - offset, y: mapView.center.y + offset), toCoordinateFrom: mapView)
        ]
        delegate?.mapPolygonFilterViewDidSelectInitialAreaSelectionButton(self, coordinates: coordinates)
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = Theme.mainBackground

        addSubview(mapContainerView)

        mapContainerView.addSubview(mapView)
        mapContainerView.addSubview(radiusOverlayView)
        mapContainerView.addSubview(userLocationButton)
        mapContainerView.addSubview(initialAreaSelectionButton)

        mapView.fillInSuperview()
        radiusOverlayView.fillInSuperview()

        NSLayoutConstraint.activate([
            mapContainerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            mapContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .spacingM),
            mapContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.spacingM),
            mapContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.spacingS),

            userLocationButton.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.topAnchor, constant: .spacingS),
            userLocationButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -.spacingS),
            userLocationButton.widthAnchor.constraint(equalToConstant: 46),
            userLocationButton.heightAnchor.constraint(equalTo: userLocationButton.widthAnchor),

            initialAreaSelectionButton.bottomAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.bottomAnchor, constant: -.spacingS),
            initialAreaSelectionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }

    private func setupSearchBar(_ searchBar: UISearchBar?) {
        guard let searchBar = searchBar else { return }

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.removeFromSuperview()
        searchBar.preservesSuperviewLayoutMargins = false

        addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: mapContainerView.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .spacingS),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.spacingS),
        ])
    }
}

// MARK: - Private extensions

private extension MKMapView {
    func centeredRegion(for radius: CLLocationDistance) -> MKCoordinateRegion {
        return MKCoordinateRegion(
            center: centerCoordinate,
            latitudinalMeters: CLLocationDistance(radius),
            longitudinalMeters: CLLocationDistance(radius)
        )
    }
}

extension MapPolygonFilterView: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.btnPrimary
            circle.fillColor = UIColor.btnPrimary.withAlphaComponent(0.15)
            circle.lineWidth = 2
            return circle
        } else if overlay is MKPolygon {
            let polygon = MKPolygonRenderer(overlay: overlay)
            polygon.strokeColor = UIColor.btnPrimary
            polygon.fillColor = UIColor.btnPrimary.withAlphaComponent(0.15)
            polygon.lineWidth = 2
            if previousPolygonRenderer != nil {
                previousPolygonRenderer!.alpha = 0
            }
            previousPolygonRenderer = polygon
            return polygon
        } else if let tileOverlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if let view = view {
            view.annotation = annotation
        }
        else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            view?.canShowCallout = false
            if let annotation = annotation as? PolygonSearchAnnotation {
                view?.image = annotation.type == .vertex ? UIImage(named: .sliderThumbActive) : UIImage(named: .sliderThumb)
            }
            view?.isDraggable = false

            let drag = UILongPressGestureRecognizer(target: self, action: #selector(handleDrag(gesture:)))
            drag.minimumPressDuration = 0
            drag.allowableMovement = .greatestFiniteMagnitude
            view?.addGestureRecognizer(drag)
        }
        return view
    }

    @objc func handleDrag(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: mapView)

        if gesture.state == .began {
            dragStartPosition = location
        } else if gesture.state == .changed {
            gesture.view?.transform = CGAffineTransform(translationX: location.x - dragStartPosition.x, y: location.y - dragStartPosition.y)
            let touchedCoordinate = mapView.convert(location, toCoordinateFrom: mapView)

            guard let annotationView = gesture.view as? MKAnnotationView,
                let draggedAnnotation = annotationView.annotation as? PolygonSearchAnnotation else { return }

            updatePolygon(draggedAnnotation: draggedAnnotation, touchedCoordinate: touchedCoordinate)
            updateNeighborPositions(draggedAnnotation: draggedAnnotation, annotationCoordinate: touchedCoordinate)

        } else if gesture.state == .ended || gesture.state == .cancelled {

            if let annotationView = gesture.view as? MKAnnotationView,
                let annotation = annotationView.annotation as? PolygonSearchAnnotation {

                if annotation.type == .intermediate {
                    annotation.type = .vertex
                    annotationView.image = UIImage(named: .sliderThumbActive)
                    // add neighbors around
                }

                let translate = CGPoint(x: location.x - dragStartPosition.x, y: location.y - dragStartPosition.y)
                let originalLocation = mapView.convert(annotation.coordinate, toPointTo: mapView)
                let updatedLocation = CGPoint(x: originalLocation.x + translate.x, y: originalLocation.y + translate.y)

                annotationView.transform = .identity
                annotation.coordinate = mapView.convert(updatedLocation, toCoordinateFrom: mapView)
                updateNeighborPositions(draggedAnnotation: annotation, annotationCoordinate: annotation.coordinate)
                drawPolygon(with: annotations.map({ $0.coordinate })) // remove filter for main after fixing intermediate
            }
        }
    }

    private func updateNeighborPositions(draggedAnnotation: PolygonSearchAnnotation, annotationCoordinate: CLLocationCoordinate2D) {
        guard let index = annotations.firstIndex(where: { $0.title == draggedAnnotation.title } ) else { return }
        let annotation = annotations[index]

        let previousIndex = indexBefore(index)
        let neighborBefore = annotations[previousIndex]
        if neighborBefore.type == .intermediate {
            let previousVertex = annotations[indexBefore(previousIndex)]
            let intermediatePosition = previousVertex.getMidwayCoordinate(other: annotationCoordinate)
            neighborBefore.coordinate = intermediatePosition
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

    private func indexBefore(_ index: Int) -> Int {
        return index > 0 ? index - 1 : annotations.count - 1
    }

    private func indexAfter(_ index: Int) -> Int {
        return index + 1 < annotations.count ? index + 1 : 0
    }

    private func updatePolygon(draggedAnnotation: PolygonSearchAnnotation, touchedCoordinate: CLLocationCoordinate2D) {
        var coordinates = [CLLocationCoordinate2D]()
        for annotation in annotations {
            if annotation.title != draggedAnnotation.title {
                if annotation.type == .intermediate { continue }
                coordinates.append(annotation.coordinate)
            } else {
                coordinates.append(touchedCoordinate)
            }
        }
        drawPolygon(with: coordinates)
    }

    func drawPolygon(with coordinates: [CLLocationCoordinate2D]) {
        if let polygon = polygon {
            // Ideally, we want to remove the overlay once we redraw a new polygon.
            // However, there is a bug in iOS 13.2 and 13.3 where removing overlay causes MapKit to flutter.
            // https://forums.developer.apple.com/thread/125631
            // https://stackoverflow.com/questions/58674817/ios-13-2-removing-overlay-from-mapkit-causing-map-to-flicker
            // A temporary solution is to change alpha of the prevoius polygon to 0, in rendererFor overlay.
            // Rumors say the issue is fixed in iOS 13.4 beta 🤞
//            mapView.removeOverlay(polygon)
        }
        polygon = nil

        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polygon)
        self.polygon = polygon
    }
}
