//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import MapKit
import UIKit

protocol MapPolygonFilterViewDelegate: MKMapViewDelegate {
    func mapPolygonFilterViewDidSelectLocationButton(_ mapPolygonFilterView: MapPolygonFilterView)
    func mapPolygonFilterViewDidSelectInitialAreaSelectionButton(_ mapPolygonFilterView: MapPolygonFilterView, coordinates: [CLLocationCoordinate2D])
    func mapPolygonFilterViewDidSelectRedoAreaSelectionButton(_ mapPolygonFilterView: MapPolygonFilterView)
}

final class MapPolygonFilterView: UIView {
    private static let defaultRadius = 40000
    private static let defaultCenterCoordinate = CLLocationCoordinate2D(latitude: 59.9171, longitude: 10.7275)
    private static let userLocationButtonWidth: CGFloat = 46
    private static let viewFinderDiameter: CGFloat = 96
    private var polygon: MKPolygon?

    private(set) var annotationPointsInMapView = [CGPoint]()

    weak var delegate: MapPolygonFilterViewDelegate? {
        didSet {
            mapView.delegate = delegate
        }
    }

    enum State { case squareAreaSelection, polygonSelection }
    private var state = State.squareAreaSelection

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

    lazy var mapView: MKMapView = {
        let view = MKMapView(frame: .zero)
        view.showsUserLocation = true
        view.isRotateEnabled = false
        view.isPitchEnabled = false
        view.isZoomEnabled = true
        view.layer.cornerRadius = 8
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

    private lazy var redoAreaSelectionButton: UIButton = {
        let button = UIButton(withAutoLayout: true)
        button.backgroundColor = Theme.mainBackground
        button.tintColor = .btnPrimary

        button.layer.cornerRadius = MapPolygonFilterView.userLocationButtonWidth / 2
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.5

        button.setImage(UIImage(named: .arrowCounterClockwise), for: .normal)
        button.addTarget(self, action: #selector(didTapRedoAreaSelectionButton), for: .touchUpInside)

        return button
    }()

    private lazy var initialAreaSelectionButton: Button = {
        let button = Button(style: .callToAction, size: .small, withAutoLayout: true)
        button.setTitle("map.polygonSearch.initialAreaSelection.button".localized(), for: .normal)
        button.addTarget(self, action: #selector(didTapAreaSelectionButton), for: .touchUpInside)

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.5

        button.setImage(UIImage(named: .areaSelectionPin).withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = .ice
        button.adjustsImageWhenHighlighted = false
        button.imageEdgeInsets = UIEdgeInsets(leading: -.spacingS)

        return button
    }()

    private lazy var vertexAnnotationImage: UIImage = {
        let clickableAreaSize: CGFloat = 40
        let diameter: CGFloat = 20
        let borderWidth: CGFloat = 2.5
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: clickableAreaSize, height: clickableAreaSize))
        return renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.bgPrimary.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.accentSecondaryBlue.cgColor)
            ctx.cgContext.setLineWidth(borderWidth)

            let margin = (clickableAreaSize - diameter) / 2
            let rectangle = CGRect(x: borderWidth + margin, y: borderWidth + margin, width: diameter - borderWidth * 2, height: diameter - borderWidth * 2)
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
    }()

    private lazy var intermediateAnnotationImage: UIImage = {
        let clickableAreaSize: CGFloat = 40
        let diameter: CGFloat = 14
        let borderWidth: CGFloat = 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: clickableAreaSize, height: clickableAreaSize))
        return renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.bgPrimary.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.accentSecondaryBlue.cgColor)
            ctx.cgContext.setLineWidth(borderWidth)
            ctx.cgContext.setAlpha(0.6)

            let margin = (clickableAreaSize - diameter) / 2
            let rectangle = CGRect(x: borderWidth + margin, y: borderWidth + margin, width: diameter - borderWidth * 2, height: diameter - borderWidth * 2)
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
    }()

    private lazy var squareSelectionOverlayView = MapPolygonSquareSelectionOverlayView(withAutoLayout: true)

    // MARK: - Init

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 250, height: 100))

        setup()
        setInitialRegion(animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - API

    func location(for gesture: UILongPressGestureRecognizer) -> CGPoint {
        return gesture.location(in: mapView)
    }

    func pointForAnnoatation(_ annotation: PolygonSearchAnnotation) -> CGPoint { // rename
        return mapView.convert(annotation.coordinate, toPointTo: mapView)
    }

    func coordinateForPoint(_ point: CGPoint) -> CLLocationCoordinate2D {
        return mapView.convert(point, toCoordinateFrom: mapView)
    }

    func setMapTileOverlay(_ overlay: MKTileOverlay) {
        mapView.addOverlay(overlay, level: .aboveLabels)
    }

    func centerOnCoordinate(_ coordinate: CLLocationCoordinate2D, regionDistance: CLLocationDistance? = nil, animated: Bool) {
        mapView.setCenter(coordinate, animated: animated)
        guard let distance = regionDistance else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: distance * 1.1, longitudinalMeters: distance * 1.1)
        mapView.setRegion(region, animated: true)
    }

    func centerOnUserLocation() {
        if let location = mapView.userLocation.location {
            centerOnCoordinate(location.coordinate, animated: true)
        }
    }

    private func setInitialRegion(animated: Bool = true) {
        let region = mapView.centeredRegion(for: Double(MapPolygonFilterView.defaultRadius) * 2.2)
        mapView.setRegion(region, animated: animated)
    }

    func initialSquareOverlayToCoordinates() -> [CLLocationCoordinate2D] {
        let offset = squareSelectionOverlayView.width / 2
        return [
            mapView.convert(CGPoint(x: mapView.center.x - offset, y: mapView.center.y - offset), toCoordinateFrom: mapView),
            mapView.convert(CGPoint(x: mapView.center.x + offset, y: mapView.center.y - offset), toCoordinateFrom: mapView),
            mapView.convert(CGPoint(x: mapView.center.x + offset, y: mapView.center.y + offset), toCoordinateFrom: mapView),
            mapView.convert(CGPoint(x: mapView.center.x - offset, y: mapView.center.y + offset), toCoordinateFrom: mapView),
        ]
    }

    // MARK: - Actions

    @objc private func didTapLocateUserButton() {
        delegate?.mapPolygonFilterViewDidSelectLocationButton(self)
    }

    @objc private func didTapAreaSelectionButton() {
        delegate?.mapPolygonFilterViewDidSelectInitialAreaSelectionButton(self, coordinates: initialSquareOverlayToCoordinates())
    }

    @objc private func didTapRedoAreaSelectionButton() {
        delegate?.mapPolygonFilterViewDidSelectRedoAreaSelectionButton(self)
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = Theme.mainBackground

        addSubview(mapContainerView)

        mapContainerView.addSubview(mapView)
        mapContainerView.addSubview(squareSelectionOverlayView)
        mapContainerView.addSubview(userLocationButton)
        mapContainerView.addSubview(initialAreaSelectionButton)
        mapContainerView.addSubview(redoAreaSelectionButton)

        mapView.fillInSuperview()
        squareSelectionOverlayView.fillInSuperview()

        configure(for: .squareAreaSelection)

        NSLayoutConstraint.activate([
            mapContainerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            mapContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .spacingM),
            mapContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.spacingM),
            mapContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.spacingS),

            userLocationButton.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.topAnchor, constant: .spacingS),
            userLocationButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -.spacingS),
            userLocationButton.widthAnchor.constraint(equalToConstant: 46),
            userLocationButton.heightAnchor.constraint(equalTo: userLocationButton.widthAnchor),

            redoAreaSelectionButton.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.topAnchor, constant: .spacingS),
            redoAreaSelectionButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: .spacingS),
            redoAreaSelectionButton.widthAnchor.constraint(equalToConstant: 46),
            redoAreaSelectionButton.heightAnchor.constraint(equalTo: redoAreaSelectionButton.widthAnchor),

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

    // MARK: - API

    func configure(for state: State) {
        switch state {
        case .squareAreaSelection:
            mapView.removeAnnotations(mapView.annotations)
            if let polygon = polygon {
                mapView.removeOverlay(polygon)
            }
            polygon = nil
            squareSelectionOverlayView.isHidden = false
            initialAreaSelectionButton.isHidden = false
            redoAreaSelectionButton.isHidden = true

        case .polygonSelection:
            redoAreaSelectionButton.isHidden = false
            squareSelectionOverlayView.isHidden = true
            initialAreaSelectionButton.isHidden = true
        }
    }

    func drawPolygon(with annotations: [PolygonSearchAnnotation]) {
        drawPolygon(with: annotations.map { $0.coordinate })
        if mapView.frame.size.height > 0 {
            annotationPointsInMapView = annotations.map({ pointForAnnoatation($0) })
        }
    }

    func drawPolygon(with coordinates: [CLLocationCoordinate2D]) {
        if let polygon = polygon {
            mapView.removeOverlay(polygon)
        }
        polygon = nil

        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polygon)
        self.polygon = polygon
    }

    func addAnnotation(_ annotation: PolygonSearchAnnotation) {
        mapView.addAnnotation(annotation)
    }

    func removeAnnotations(_ annotations: [PolygonSearchAnnotation]) {
        mapView.removeAnnotations(annotations)
    }

    func imageForAnnotation(ofType pointType: PolygonSearchAnnotation.PointType) -> UIImage {
        return pointType == .vertex ? vertexAnnotationImage : intermediateAnnotationImage
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
