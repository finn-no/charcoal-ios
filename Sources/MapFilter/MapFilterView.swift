//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit

public protocol MapFilterViewManagerDelegate: AnyObject {
    func mapFilterViewManagerDidChangeRegion(_ mapFilterViewManager: MapFilterViewManager, newCenterCoordinate: CLLocationCoordinate2D, userInitiated: Bool, animated: Bool)
    func mapFilterViewManagerDidChangeLocationName(_ mapFilterViewManager: MapFilterViewManager, newLocationName: String?)
}

public protocol MapFilterViewManager: AnyObject {
    var mapFilterViewManagerDelegate: MapFilterViewManagerDelegate? { get set }
    func mapViewLengthForMeters(_: Int) -> CGFloat
    func selectionRadiusChangedTo(_ radius: Int)
    func addMapView(toFillInside containerView: UIView)
    func centerOnUserLocation()
    var locationName: String? { get }
    func goToLocation(_ location: LocationInfo)
}

protocol MapFilterViewDelegate: AnyObject {
    func mapFilterView(_ mapFilterView: MapFilterView, didChangeRadius radius: Int)
    func mapFilterView(_ mapFilterView: MapFilterView, didChangeLocationCoordinate coordinate: CLLocationCoordinate2D?)
    func mapFilterView(_ mapFilterView: MapFilterView, didChangeLocationName locationName: String?)
}

final class MapFilterView: UIView {
    weak var delegate: MapFilterViewDelegate?

    var searchBar: UISearchBar? {
        didSet {
            setupSearchBar(searchBar)
        }
    }

    private let mapFilterViewManager: MapFilterViewManager
    private var currentRadius: Int
    private var centerPoint: CLLocationCoordinate2D?

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

    private lazy var mapSelectionCircleView: CircularView = {
        let view = CircularView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.primaryBlue.withAlphaComponent(0.2)
        view.layer.borderColor = .primaryBlue
        view.layer.borderWidth = 3
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var mapSelectionCircleCenterPointView: CircularView = {
        let view = CircularView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .milk
        view.isUserInteractionEnabled = false
        view.radius = 3
        return view
    }()

    private lazy var distanceSlider: ValueSliderWithLabelView = {
        let meterStepValues = [200, 300, 400, 500, 700, 1000, 1500, 2000, 5000, 10000, 20000, 30000, 50000, 75000, 100_000]
        let referenceIndexes = [1, Int(meterStepValues.count / 2), meterStepValues.count - 2]
        let slider = ValueSliderWithLabelView(range: meterStepValues, referenceIndexes: referenceIndexes, valueFormatter: MapDistanceValueFormatter())
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.delegate = self

        return slider
    }()

    // MARK: - Init

    init(mapFilterViewManager: MapFilterViewManager, radius: Int?, centerPoint: CLLocationCoordinate2D?) {
        self.mapFilterViewManager = mapFilterViewManager
        currentRadius = radius ?? 40000
        self.centerPoint = centerPoint

        super.init(frame: CGRect(x: 0, y: 0, width: 250, height: 100))

        setup()

        let searchBar = UISearchBar(frame: .zero)
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .milk
        setupSearchBar(UISearchBar(frame: .zero))
        distanceSlider.setCurrentValue(currentRadius)
        mapFilterViewManager.selectionRadiusChangedTo(currentRadius)
        showSelectionView()

        self.mapFilterViewManager.mapFilterViewManagerDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Update radius so it fits for new view sizes
        let updateViewWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else {
                return
            }
            self.mapSelectionCircleView.radius = self.mapFilterViewManager.mapViewLengthForMeters(self.currentRadius)
            self.mapFilterViewManager.selectionRadiusChangedTo(self.currentRadius)
        }
        updateViewDispatchWorkItem = updateViewWorkItem

        // Use a delay incase the view is being changed to new sizes by user
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: updateViewWorkItem)
    }
}

private extension MapFilterView {
    func setup() {
        backgroundColor = .milk
        mapFilterViewManager.addMapView(toFillInside: mapContainerView)
        mapContainerView.addSubview(mapSelectionCircleView)
        mapSelectionCircleView.addSubview(mapSelectionCircleCenterPointView)
        addSubview(mapContainerView)
        addSubview(distanceSlider)

        NSLayoutConstraint.activate([
            mapContainerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            mapContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumLargeSpacing),
            mapContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumLargeSpacing),

            mapSelectionCircleView.centerXAnchor.constraint(equalTo: mapContainerView.centerXAnchor),
            mapSelectionCircleView.centerYAnchor.constraint(equalTo: mapContainerView.centerYAnchor),

            mapSelectionCircleCenterPointView.centerXAnchor.constraint(equalTo: mapSelectionCircleView.centerXAnchor),
            mapSelectionCircleCenterPointView.centerYAnchor.constraint(equalTo: mapSelectionCircleView.centerYAnchor),

            distanceSlider.topAnchor.constraint(equalTo: mapContainerView.bottomAnchor, constant: .mediumLargeSpacing),
            distanceSlider.leadingAnchor.constraint(equalTo: mapContainerView.leadingAnchor),
            distanceSlider.trailingAnchor.constraint(equalTo: mapContainerView.trailingAnchor),
            distanceSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.mediumSpacing),
        ])
    }

    func setupSearchBar(_ searchBar: UISearchBar?) {
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

    func showSelectionView() {
        mapSelectionCircleView.isHidden = false
        mapSelectionCircleView.radius = mapFilterViewManager.mapViewLengthForMeters(currentRadius)
    }
}

extension MapFilterView: MapFilterViewManagerDelegate {
    func mapFilterViewManagerDidChangeLocationName(_ mapFilterViewManager: MapFilterViewManager, newLocationName: String?) {
        searchBar?.text = newLocationName
        delegate?.mapFilterView(self, didChangeLocationName: newLocationName)
    }

    func mapFilterViewManagerDidChangeRegion(_ mapFilterViewManager: MapFilterViewManager, newCenterCoordinate: CLLocationCoordinate2D, userInitiated: Bool, animated: Bool) {
        centerPoint = newCenterCoordinate
        mapSelectionCircleView.radius = mapFilterViewManager.mapViewLengthForMeters(currentRadius)
        if userInitiated {
            searchBar?.text = mapFilterViewManager.locationName
        }

        delegate?.mapFilterView(self, didChangeLocationCoordinate: newCenterCoordinate)
    }
}

extension MapFilterView: ValueSliderWithLabelViewDelegate {
    func valueSliderWithLabelView<ValueKind>(_ valueSliderWithLabelView: ValueSliderWithLabelView, didSetValue value: ValueKind) where ValueKind: Comparable, ValueKind: Numeric {
        guard let value = value as? Int else {
            return
        }
        currentRadius = value
        mapSelectionCircleView.radius = mapFilterViewManager.mapViewLengthForMeters(currentRadius)
        mapFilterViewManager.selectionRadiusChangedTo(currentRadius)

        delegate?.mapFilterView(self, didChangeRadius: currentRadius)
    }
}

private class CircularView: UIView {
    private var widthConstraint: NSLayoutConstraint?
    var radius: CGFloat = 5 {
        didSet {
            widthConstraint?.constant = radius * 2
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        let widthConstraint = widthAnchor.constraint(equalToConstant: radius * 2)
        self.widthConstraint = widthConstraint
        NSLayoutConstraint.activate([
            widthConstraint,
            heightAnchor.constraint(equalTo: widthAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width / 2.0
    }
}
