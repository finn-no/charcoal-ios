//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public class MapFilterView: UIView {
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

    private lazy var distanceSlider: ValueSliderAndInputView = {
        let meterValues = [250, 350, 500, 700, 1000, 1500]
        var meterValueRange = [StepValue]()
        meterValues.forEach({
            meterValueRange.append(StepValue(value: $0, displayTitle: "\($0) m"))
        })

        let kmValues = [2, 5, 10, 20, 30, 50, 75, 100]
        var kmValueRange = [StepValue]()
        kmValues.forEach({
            kmValueRange.append(StepValue(value: $0 * 1000, displayTitle: "\($0) km"))
        })

        let range: [StepValue] = meterValueRange + kmValueRange
        let slider = ValueSliderAndInputView(range: range, referenceValueIndexes: [1, Int(range.count / 2), range.count - 1])
        slider.translatesAutoresizingMaskIntoConstraints = false

        return slider
    }()

    // MARK: - Setup

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupSearchBar(UISearchBar(frame: .zero))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MapFilterView {
    func setup() {
        addSubview(mapView)
        addSubview(distanceSlider)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: .mediumSpacing),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumSpacing),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumSpacing),

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
            searchBar.bottomAnchor.constraint(equalTo: mapView.topAnchor, constant: .mediumLargeSpacing),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumSpacing),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumSpacing),
        ])
    }
}
