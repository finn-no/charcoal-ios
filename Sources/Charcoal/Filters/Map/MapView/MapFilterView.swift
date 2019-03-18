//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit

protocol MapFilterViewDelegate: MKMapViewDelegate {
    func mapFilterViewDidSelectLocationButton(_ mapFilterView: MapFilterView)
    func mapFilterView(_ mapFilterView: MapFilterView, didChangeRadius radius: Int)
}

final class MapFilterView: UIView {
    static let defaultRadius = 40000
    private static let userLocationButtonWidth: CGFloat = 46

    weak var delegate: MapFilterViewDelegate? {
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

    var isUserLocatonButtonEnabled = false {
        didSet {
            userLocationButton.isHidden = !isUserLocatonButtonEnabled
            mapView.showsUserLocation = isUserLocatonButtonEnabled
        }
    }

    private(set) var radius: Int
    private let pulseAnimationKey = "LocateUserPulseAnimation"

    // MARK: - Subviews

    private var updateViewDispatchWorkItem: DispatchWorkItem? {
        didSet {
            oldValue?.cancel()
        }
    }

    private lazy var mapContainerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    private lazy var mapView: MKMapView = {
        let view = MKMapView(frame: .zero)
        view.isRotateEnabled = false
        view.isPitchEnabled = false
        view.isZoomEnabled = false
        return view
    }()

    private lazy var userLocationButton: UIButton = {
        let button = UIButton(withAutoLayout: true)
        button.backgroundColor = UIColor(white: 1, alpha: 0.8)
        button.tintColor = .primaryBlue
        button.layer.cornerRadius = MapFilterView.userLocationButtonWidth / 2
        button.setImage(UIImage(named: .locateUserOutlined), for: .normal)
        button.setImage(UIImage(named: .locateUserFilled), for: .highlighted)
        button.addTarget(self, action: #selector(didTapLocateUserButton), for: .touchUpInside)
        return button
    }()

    private lazy var radiusView = MapRadiusView(withAutoLayout: true)

    private lazy var distanceSlider: ValueSliderWithLabelView = {
        let meterStepValues = [200, 300, 400, 500, 700, 1000, 1500, 2000, 5000, 10000, 20000, 30000, 50000, 75000, 100_000]
        let referenceIndexes = [1, Int(meterStepValues.count / 2), meterStepValues.count - 2]
        let slider = ValueSliderWithLabelView(range: meterStepValues, referenceIndexes: referenceIndexes, valueFormatter: MapDistanceValueFormatter())

        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.delegate = self
        slider.setCurrentValue(radius)

        return slider
    }()

    // MARK: - Init

    init(radius: Int?) {
        self.radius = radius ?? MapFilterView.defaultRadius
        super.init(frame: CGRect(x: 0, y: 0, width: 250, height: 100))
        setup()
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

    func centerOnCoordinate(_ coordinate: CLLocationCoordinate2D, animated: Bool) {
        mapView.setCenter(coordinate, animated: animated)
    }

    func centerOnUserLocation() {
        if let location = mapView.userLocation.location {
            centerOnCoordinate(location.coordinate, animated: true)
        }
    }

    func startAnimatingLocationButton() {
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.fromValue = 0.6
        pulseAnimation.toValue = 1.0
        pulseAnimation.repeatCount = Float.greatestFiniteMagnitude
        pulseAnimation.autoreverses = true
        pulseAnimation.duration = 0.8

        userLocationButton.isHighlighted = true
        userLocationButton.layer.add(pulseAnimation, forKey: pulseAnimationKey)
    }

    func stopAnimatingLocationButton() {
        userLocationButton.isHighlighted = false
        userLocationButton.layer.removeAnimation(forKey: pulseAnimationKey)
    }

    func updateRadiusView() {
        let region = mapView.centeredRegion(for: Double(radius))
        radiusView.radius = mapView.convert(region, toRectTo: mapView).width
    }

    private func updateRegion(animated: Bool = true) {
        let region = mapView.centeredRegion(for: Double(radius) * 2.2)

        mapView.setRegion(region, animated: animated)
        updateRadiusView()
    }

    // MARK: - Actions

    @objc private func didTapLocateUserButton() {
        delegate?.mapFilterViewDidSelectLocationButton(self)
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .milk

        addSubview(mapContainerView)
        addSubview(distanceSlider)

        mapContainerView.addSubview(mapView)
        mapContainerView.addSubview(radiusView)

        mapView.addSubview(userLocationButton)
        mapView.fillInSuperview()

        NSLayoutConstraint.activate([
            mapContainerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            mapContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumLargeSpacing),
            mapContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumLargeSpacing),

            radiusView.centerXAnchor.constraint(equalTo: mapContainerView.centerXAnchor),
            radiusView.centerYAnchor.constraint(equalTo: mapContainerView.centerYAnchor),

            distanceSlider.topAnchor.constraint(equalTo: mapContainerView.bottomAnchor, constant: .mediumLargeSpacing),
            distanceSlider.leadingAnchor.constraint(equalTo: mapContainerView.leadingAnchor),
            distanceSlider.trailingAnchor.constraint(equalTo: mapContainerView.trailingAnchor),
            distanceSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.mediumSpacing),

            userLocationButton.topAnchor.constraint(equalTo: mapView.compatibleTopAnchor, constant: .mediumSpacing),
            userLocationButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -.mediumSpacing),
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
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumSpacing),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumSpacing),
        ])
    }
}

// MARK: - ValueSliderWithLabelViewDelegate

extension MapFilterView: ValueSliderWithLabelViewDelegate {
    func valueSliderWithLabelView(_ valueSliderWithLabelView: ValueSliderWithLabelView, didSetValue value: Int) {
        radius = value
        updateRegion()
        delegate?.mapFilterView(self, didChangeRadius: radius)
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
