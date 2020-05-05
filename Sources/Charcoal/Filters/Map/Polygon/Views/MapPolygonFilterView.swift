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
    weak var delegate: MapPolygonFilterViewDelegate? {
        didSet {
            mapView.delegate = delegate
        }
    }

    enum State {
        case initialAreaSelection
        case polygonSelection
    }

    // MARK: - Private properties

    private static let defaultRadius = 40000
    private static let defaultCenterCoordinate = CLLocationCoordinate2D(latitude: 59.9171, longitude: 10.7275)
    private static let annotationFillColor: CGColor = UIColor.bgPrimary.cgColor
    private static let annotationBorderColor: CGColor = UIColor.accentSecondaryBlue.cgColor

    private var polygon: MKPolygon?

    // MARK: - Internal properties

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

    var isUserLocationButtonHighlighted = false {
        didSet {
            userLocationButton.isHighlighted = isUserLocationButtonHighlighted
        }
    }

    var centerCoordinate: CLLocationCoordinate2D? {
        return mapView.centerCoordinate
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
        return view
    }()

    private lazy var userLocationButton: UIButton = {
        let button = CircleButton()
        button.setImage(UIImage(named: .locateUserOutlined), for: .normal)
        button.setImage(UIImage(named: .locateUserFilled), for: .highlighted)
        button.addTarget(self, action: #selector(didTapLocateUserButton), for: .touchUpInside)
        return button
    }()

    private lazy var redoAreaSelectionButton: UIButton = {
        let button = CircleButton()
        button.setImage(UIImage(named: .arrowCounterClockwise).withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = .iconPrimary
        button.adjustsImageWhenHighlighted = false
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

    private lazy var vertexAnnotationImage: UIImage = annotationImage(clickableAreaSize: 40, diameter: 20, borderWidth: 2.5, alpha: 1)

    private lazy var intermediateAnnotationImage: UIImage = annotationImage(clickableAreaSize: 40, diameter: 14, borderWidth: 2, alpha: 0.6)

    private lazy var initialAreaSelectionOverlayView = InitialAreaSelectionOverlayView(withAutoLayout: true)

    private lazy var infoView = InfoView(withAutoLayout: true)

    // MARK: - Init

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 250, height: 100))

        setup()
        setInitialRegion(animated: false)
        centerOnInitialCoordinate()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = Theme.mainBackground

        addSubview(mapContainerView)

        mapContainerView.addSubview(mapView)
        mapContainerView.addSubview(initialAreaSelectionOverlayView)
        mapContainerView.addSubview(userLocationButton)
        mapContainerView.addSubview(initialAreaSelectionButton)
        mapContainerView.addSubview(redoAreaSelectionButton)
        mapContainerView.addSubview(infoView)

        mapView.fillInSuperview()
        initialAreaSelectionOverlayView.fillInSuperview()

        configure(for: .initialAreaSelection)

        NSLayoutConstraint.activate([
            mapContainerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            mapContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .spacingM),
            mapContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.spacingM),
            mapContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.spacingS),

            userLocationButton.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.topAnchor, constant: .spacingS),
            userLocationButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -.spacingS),
            userLocationButton.widthAnchor.constraint(equalToConstant: CircleButton.width),
            userLocationButton.heightAnchor.constraint(equalTo: userLocationButton.widthAnchor),

            redoAreaSelectionButton.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.topAnchor, constant: .spacingS),
            redoAreaSelectionButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: .spacingS),
            redoAreaSelectionButton.widthAnchor.constraint(equalToConstant: CircleButton.width),
            redoAreaSelectionButton.heightAnchor.constraint(equalTo: redoAreaSelectionButton.widthAnchor),

            initialAreaSelectionButton.bottomAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.bottomAnchor, constant: -.spacingM),
            initialAreaSelectionButton.centerXAnchor.constraint(equalTo: centerXAnchor),

            infoView.bottomAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.bottomAnchor, constant: -.spacingM),
            infoView.centerXAnchor.constraint(equalTo: centerXAnchor),
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

    func location(for gesture: UILongPressGestureRecognizer) -> CGPoint {
        return gesture.location(in: mapView)
    }

    func point(for annotation: PolygonSearchAnnotation) -> CGPoint {
        return mapView.convert(annotation.coordinate, toPointTo: mapView)
    }

    func coordinate(for point: CGPoint) -> CLLocationCoordinate2D {
        return mapView.convert(point, toCoordinateFrom: mapView)
    }

    func centerOnCoordinate(_ coordinate: CLLocationCoordinate2D, regionDistance: CLLocationDistance? = nil) {
        mapView.setCenter(coordinate, animated: true)
        guard let distance = regionDistance else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: distance * 1.1, longitudinalMeters: distance * 1.1)
        mapView.setRegion(region, animated: true)
    }

    func centerOnUserLocation() {
        if let location = mapView.userLocation.location {
            centerOnCoordinate(location.coordinate)
        }
    }

    func configure(for state: State) {
        switch state {
        case .initialAreaSelection:
            mapView.removeAnnotations(mapView.annotations)
            if let polygon = polygon {
                mapView.removeOverlay(polygon)
            }
            polygon = nil
            initialAreaSelectionOverlayView.isHidden = false
            initialAreaSelectionButton.isHidden = false
            redoAreaSelectionButton.isHidden = true
            infoView.isHidden = true

        case .polygonSelection:
            redoAreaSelectionButton.isHidden = false
            initialAreaSelectionOverlayView.isHidden = true
            initialAreaSelectionButton.isHidden = true
            infoView.isHidden = false
        }
    }

    func drawPolygon(with annotations: [PolygonSearchAnnotation]) {
        drawPolygon(with: annotations.map { $0.coordinate })
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

    func removeAnnotation(_ annotation: PolygonSearchAnnotation) {
        mapView.removeAnnotation(annotation)
    }

    func removeAnnotations(_ annotations: [PolygonSearchAnnotation]) {
        mapView.removeAnnotations(annotations)
    }

    func selectAnnotation(_ annotation: PolygonSearchAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
    }

    func imageForAnnotation(ofType pointType: PolygonSearchAnnotation.PointType) -> UIImage {
        return pointType == .vertex ? vertexAnnotationImage : intermediateAnnotationImage
    }

    func polygonIsVisibleInMap() -> Bool {
        return visibleAnnotations().count > 0
    }

    func visibleAnnotations() -> [PolygonSearchAnnotation] {
        return mapView.annotations(in: mapView.visibleMapRect).compactMap { $0 as? PolygonSearchAnnotation }
    }

    func showInfoBox(with text: String, completion: (() -> Void)?) {
        infoView.show(with: text, completion: completion)
    }

    // MARK: - Private methods

    private func annotationImage(clickableAreaSize: CGFloat, diameter: CGFloat, borderWidth: CGFloat, alpha: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: clickableAreaSize, height: clickableAreaSize))
        return renderer.image { ctx in
            ctx.cgContext.setFillColor(MapPolygonFilterView.annotationFillColor)
            ctx.cgContext.setStrokeColor(MapPolygonFilterView.annotationBorderColor)
            ctx.cgContext.setLineWidth(borderWidth)
            ctx.cgContext.setAlpha(alpha)

            let margin = (clickableAreaSize - diameter) / 2
            let rectangle = CGRect(x: borderWidth + margin, y: borderWidth + margin, width: diameter - borderWidth * 2, height: diameter - borderWidth * 2)
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
    }

    private func setInitialRegion(animated: Bool = true) {
        let region = mapView.centeredRegion(for: Double(MapPolygonFilterView.defaultRadius) * 2.2)
        mapView.setRegion(region, animated: animated)
    }

    private func centerOnInitialCoordinate() {
        let userCoordinate = mapView.userLocation.location?.coordinate
        let centerCoordinate = userCoordinate ?? MapPolygonFilterView.defaultCenterCoordinate

        centerOnCoordinate(centerCoordinate)
    }

    private func initialAreaOverlayToCoordinates() -> [CLLocationCoordinate2D] {
        let offset = initialAreaSelectionOverlayView.width / 2
        return [
            coordinate(for: CGPoint(x: mapView.center.x - offset, y: mapView.center.y - offset)),
            coordinate(for: CGPoint(x: mapView.center.x + offset, y: mapView.center.y - offset)),
            coordinate(for: CGPoint(x: mapView.center.x + offset, y: mapView.center.y + offset)),
            coordinate(for: CGPoint(x: mapView.center.x - offset, y: mapView.center.y + offset)),
        ]
    }

    // MARK: - Actions

    @objc private func didTapLocateUserButton() {
        delegate?.mapPolygonFilterViewDidSelectLocationButton(self)
    }

    @objc private func didTapAreaSelectionButton() {
        delegate?.mapPolygonFilterViewDidSelectInitialAreaSelectionButton(self, coordinates: initialAreaOverlayToCoordinates())
    }

    @objc private func didTapRedoAreaSelectionButton() {
        delegate?.mapPolygonFilterViewDidSelectRedoAreaSelectionButton(self)
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

// MARK: - Private classes

private class CircleButton: UIButton {
    static let width: CGFloat = 46

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = Theme.mainBackground
        tintColor = .btnPrimary

        layer.cornerRadius = CircleButton.width / 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.5
    }
}
