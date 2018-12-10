//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public class MapFilterView: UIView {
    private class DistanceValueFormatter: ValueSliderFormatter {
        func displayText<ValueKind>(for value: ValueKind) -> String where ValueKind: Numeric {
            guard let value = value as? Int else {
                return ""
            }
            let useKm = value > 1500
            if useKm {
                let km = value / 1000
                return "\(km) km"
            } else {
                return "\(value) m"
            }
        }
    }

    var searchBar: UISearchBar? {
        didSet {
            setupSearchBar(searchBar)
        }
    }

    private lazy var mapView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ice
        return view
    }()

    private lazy var distanceSlider: ValueSliderWithLabelView<Int> = {
        let meterStepValues = [200, 300, 400, 500, 700, 1000, 1500, 2000, 5000, 10000, 20000, 30000, 50000, 75000, 100_000]
        let referenceIndexes = [1, Int(meterStepValues.count / 2), meterStepValues.count - 2]
        let slider = ValueSliderWithLabelView<Int>(range: meterStepValues, referenceIndexes: referenceIndexes, valueFormatter: DistanceValueFormatter())
        slider.translatesAutoresizingMaskIntoConstraints = false

        return slider
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
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
            mapView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: .mediumSpacing),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumSpacing),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumSpacing),
            mapView.heightAnchor.constraint(equalToConstant: 150),

            distanceSlider.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: .mediumLargeSpacing),
            distanceSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumSpacing),
            distanceSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumSpacing),
            distanceSlider.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -.mediumSpacing),
        ])
    }

    func setupSearchBar(_ searchBar: UISearchBar?) {
        guard let searchBar = searchBar else { return }
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.removeFromSuperview()
        addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor, constant: .mediumSpacing),
            searchBar.bottomAnchor.constraint(equalTo: mapView.topAnchor, constant: -.mediumSpacing),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumSpacing),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumSpacing),
        ])
    }
}
