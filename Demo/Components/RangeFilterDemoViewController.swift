//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal

final class RangeFilterDemoViewController: DemoViewController {

    // MARK: - Private properties

    private let filterConfig = RangeFilterConfiguration(
        minimumValue: 0,
        maximumValue: 30000,
        valueKind: .incremented(1000),
        hasLowerBoundOffset: false,
        hasUpperBoundOffset: true,
        unit: .currency,
        usesSmallNumberInputFont: false
    )

    private lazy var rangeFilterView: RangeFilterView = {
        let rangeFilterView = RangeFilterView(filterConfig: filterConfig)
        rangeFilterView.translatesAutoresizingMaskIntoConstraints = false
        rangeFilterView.setLowValue(filterConfig.minimumValue, animated: false)
        rangeFilterView.setHighValue(filterConfig.maximumValue, animated: false)
        return rangeFilterView
    }()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(rangeFilterView)
        NSLayoutConstraint.activate([
            rangeFilterView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            rangeFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rangeFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
