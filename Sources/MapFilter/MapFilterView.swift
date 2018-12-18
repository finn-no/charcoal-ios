//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit

public protocol MapFilterManagerDelegate: AnyObject {
    func mapFilterViewManagerDidChangeZoom()
    func mapFilterViewManagerDidLoadMap()
}

public protocol MapFilterViewManager {
    var isMapLoaded: Bool { get }
    var mapView: UIView { get }
    func mapViewLengthForMeters(_: Int) -> CGFloat
    func pan(to point: CLLocationCoordinate2D, radius: Int)
}

public class MapFilterView: UIView {
    var searchBar: UISearchBar? {
        didSet {
            setupSearchBar(searchBar)
        }
    }

    private lazy var mapContainerView: UIView = {
        let view = UIView(frame: .zero)
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

    private lazy var mapView: UIView = {
        let view = mapFilterViewManager.mapView
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var distanceSlider: ValueSliderWithLabelView<Int> = {
        let meterStepValues = [200, 300, 400, 500, 700, 1000, 1500, 2000, 5000, 10000, 20000, 30000, 50000, 75000, 100_000]
        let referenceIndexes = [1, Int(meterStepValues.count / 2), meterStepValues.count - 2]
        let slider = ValueSliderWithLabelView<Int>(range: meterStepValues, referenceIndexes: referenceIndexes, valueFormatter: MapDistanceValueFormatter())
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.delegate = self

        return slider
    }()

    private let mapFilterViewManager: MapFilterViewManager
    private var currentRadius = 250

    public init(mapFilterViewManager: MapFilterViewManager) {
        self.mapFilterViewManager = mapFilterViewManager
        super.init(frame: CGRect(x: 0, y: 0, width: 250, height: 100))
        setup()
        let searchBar = UISearchBar(frame: .zero)
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .milk
        setupSearchBar(UISearchBar(frame: .zero))
        distanceSlider.setCurrentValue(currentRadius)
        if mapFilterViewManager.isMapLoaded {
            mapFilterViewManagerDidLoadMap()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MapFilterView {
    func setup() {
        backgroundColor = .milk
        mapContainerView.addSubview(mapView)
        mapContainerView.addSubview(mapSelectionCircleView)
        addSubview(mapContainerView)
        addSubview(distanceSlider)

        NSLayoutConstraint.activate([
            mapContainerView.topAnchor.constraint(equalTo: mapView.topAnchor),
            mapContainerView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor),
            mapContainerView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            mapContainerView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),

            mapView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),

            mapSelectionCircleView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            mapSelectionCircleView.centerYAnchor.constraint(equalTo: mapView.centerYAnchor),

            distanceSlider.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: .mediumLargeSpacing),
            distanceSlider.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            distanceSlider.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            distanceSlider.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    func setupSearchBar(_ searchBar: UISearchBar?) {
        guard let searchBar = searchBar else { return }
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.removeFromSuperview()
        addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: mapView.topAnchor, constant: -.mediumSpacing),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

extension MapFilterView: MapFilterManagerDelegate {
    public func mapFilterViewManagerDidChangeZoom() {
        mapSelectionCircleView.radius = mapFilterViewManager.mapViewLengthForMeters(currentRadius)
    }

    public func mapFilterViewManagerDidLoadMap() {
        mapSelectionCircleView.isHidden = false
        mapSelectionCircleView.radius = mapFilterViewManager.mapViewLengthForMeters(currentRadius)
    }
}

extension MapFilterView: ValueSliderWithLabelViewDelegate {
    func valueSliderWithLabelView<ValueKind>(_ valueSliderWithLabelView: ValueSliderWithLabelView<ValueKind>, didSetValue value: ValueKind) where ValueKind: Comparable, ValueKind: Numeric {
        guard let value = value as? Int else {
            return
        }
        currentRadius = value
        mapSelectionCircleView.radius = mapFilterViewManager.mapViewLengthForMeters(currentRadius)
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
