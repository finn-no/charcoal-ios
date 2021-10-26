//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit
import MapKit

protocol MapRadiusFilterViewDelegate: MKMapViewDelegate {
    func mapRadiusFilterViewDidSelectLocationButton(_ mapRadiusFilterView: MapRadiusFilterView)
    func mapRadiusFilterView(_ mapRadiusFilterView: MapRadiusFilterView, didChangeRadius radius: Int)
}

final class MapRadiusFilterView: UIView {
    private static let defaultRadius = 40000
    private static let defaultCenterCoordinate = CLLocationCoordinate2D(latitude: 59.9171, longitude: 10.7275)
    private static let userLocationButtonWidth: CGFloat = 46

    weak var delegate: MapRadiusFilterViewDelegate? {
        didSet {
            mapView.delegate = delegate
        }
    }

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

    private var updateMapDispatchWorkItem: DispatchWorkItem? {
        willSet {
            updateMapDispatchWorkItem?.cancel()
        }
    }
    private var updateRegionDispatchWorkItem: DispatchWorkItem? {
        willSet {
            updateRegionDispatchWorkItem?.cancel()
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
        view.isZoomEnabled = false
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var userLocationButton: UIButton = {
        let button = UIButton(withAutoLayout: true)
        button.backgroundColor = Theme.mainBackground
        button.tintColor = .btnPrimary

        button.layer.cornerRadius = MapRadiusFilterView.userLocationButtonWidth / 2
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.5

        button.setImage(UIImage(named: .locateUserOutlined), for: .normal)
        button.setImage(UIImage(named: .locateUserFilled), for: .highlighted)
        button.addTarget(self, action: #selector(didTapLocateUserButton), for: .touchUpInside)

        return button
    }()

    private lazy var radiusOverlayView = MapRadiusOverlayView(withAutoLayout: true)

    private lazy var distanceSlider: ValueSliderWithLabelView = {
        let meterStepValues = [200, 300, 400, 500, 700, 1000, 1500, 2000, 3000, 5000, 7000, 10000, 20000, 30000, 50000, 75000, 100_000]
        let referenceIndexes = [1, Int(meterStepValues.count / 2), meterStepValues.count - 2]
        let slider = ValueSliderWithLabelView(range: meterStepValues, referenceIndexes: referenceIndexes, valueFormatter: MapDistanceValueFormatter())

        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.delegate = self
        slider.setCurrentValue(radius)

        return slider
    }()

    private lazy var bottomConstraint: NSLayoutConstraint = {
        distanceSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.spacingS)
    }()

    private lazy var mapContainerHeightConstraint: NSLayoutConstraint = {
        mapContainerView.heightAnchor.constraint(equalToConstant: 0)
    }()

    // MARK: - Init

    init(radius: Int?, centerCoordinate: CLLocationCoordinate2D?) {
        self.radius = radius ?? MapRadiusFilterView.defaultRadius
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
        let updateRegionWorkItem = DispatchWorkItem { [weak self] in
            self?.updateRegion()
        }
        updateRegionDispatchWorkItem = updateRegionWorkItem

        // Update map height
        let updateMapWorkItem = DispatchWorkItem { [weak self, updateRegionWorkItem] in
            guard let self = self else { return }
            self.mapContainerView.isHidden = false
            self.mapContainerHeightConstraint.constant = max(self.distanceSlider.frame.minY - .spacingM - self.mapContainerView.frame.minY, 0)
            // Requires a delay to get the correct region set
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: updateRegionWorkItem)
        }
        mapContainerView.isHidden = true
        updateMapDispatchWorkItem = updateMapWorkItem

        // Use a delay incase the view is being resized
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: updateMapWorkItem)

    }

    // MARK: - API

    func centerOnInitialCoordinate() {
        let userCoordinate = mapView.userLocation.location?.coordinate
        let centerCoordinate = initialCenterCoordinate ?? userCoordinate ?? MapRadiusFilterView.defaultCenterCoordinate

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
        let region = mapView.centeredRegion(for: Double(radius))
        radiusOverlayView.radius = mapView.convert(region, toRectTo: mapView).width
    }

    private func updateRegion(animated: Bool = true) {
        let region = mapView.centeredRegion(for: Double(radius) * 2.2)

        mapView.setRegion(region, animated: animated)
        updateRadiusView()
    }

    // MARK: - Actions

    @objc private func didTapLocateUserButton() {
        delegate?.mapRadiusFilterViewDidSelectLocationButton(self)
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = Theme.mainBackground

        addSubview(mapContainerView)
        addSubview(distanceSlider)

        mapContainerView.addSubview(mapView)
        mapContainerView.addSubview(radiusOverlayView)
        mapContainerView.addSubview(userLocationButton)

        mapView.fillInSuperview()
        radiusOverlayView.fillInSuperview()

        NSLayoutConstraint.activate([
            mapContainerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            mapContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .spacingM),
            mapContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.spacingM),
            mapContainerHeightConstraint,

            distanceSlider.leadingAnchor.constraint(equalTo: mapContainerView.leadingAnchor),
            distanceSlider.trailingAnchor.constraint(equalTo: mapContainerView.trailingAnchor),
            distanceSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.spacingS),

            userLocationButton.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.topAnchor, constant: .spacingS),
            userLocationButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -.spacingS),
            userLocationButton.widthAnchor.constraint(equalToConstant: 46),
            userLocationButton.heightAnchor.constraint(equalTo: userLocationButton.widthAnchor),
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

// MARK: - ValueSliderWithLabelViewDelegate

extension MapRadiusFilterView: ValueSliderWithLabelViewDelegate {
    func valueSliderWithLabelView(_ valueSliderWithLabelView: ValueSliderWithLabelView, didSetValue value: Int) {
        radius = value
        updateRegion()
        delegate?.mapRadiusFilterView(self, didChangeRadius: radius)
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
