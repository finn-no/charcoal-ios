//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import MapKit
import UIKit

public protocol MapFilterViewManager {
    var mapView: UIView { get }
    func updateSelection(_ point: CLLocationCoordinate2D, radius: Int)
}

public class MapFilterView: UIView {
    var searchBar: UISearchBar? {
        didSet {
            setupSearchBar(searchBar)
        }
    }

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

        return slider
    }()

    private let mapFilterViewManager: MapFilterViewManager

    public init(mapFilterViewManager: MapFilterViewManager) {
        self.mapFilterViewManager = mapFilterViewManager
        super.init(frame: CGRect(x: 0, y: 0, width: 250, height: 100))
        setup()
        let searchBar = UISearchBar(frame: .zero)
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .milk
        setupSearchBar(UISearchBar(frame: .zero))
        distanceSlider.setCurrentValue(250)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MapFilterView {
    func setup() {
        backgroundColor = .milk
        addSubview(mapView)
        addSubview(distanceSlider)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),

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
