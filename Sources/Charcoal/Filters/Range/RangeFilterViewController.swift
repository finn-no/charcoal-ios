//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class RangeFilterViewController: FilterViewController {

    // MARK: - Private properties

    private let lowValueFilter: Filter
    private let highValueFilter: Filter
    private let filterConfig: RangeFilterConfiguration

    private lazy var rangeFilterView: RangeFilterView = {
        let view = RangeFilterView(filterConfig: filterConfig)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    // MARK: - Init

    init(title: String, lowValueFilter: Filter, highValueFilter: Filter,
         filterConfig: RangeFilterConfiguration, selectionStore: FilterSelectionStore) {
        self.lowValueFilter = lowValueFilter
        self.highValueFilter = highValueFilter
        self.filterConfig = filterConfig
        super.init(title: title, selectionStore: selectionStore)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - RangeFilterViewDelegate

extension RangeFilterViewController: RangeFilterViewDelegate {
    func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetLowValue lowValue: Int?) {
        setValue(lowValue, forSubfilter: lowValueFilter)
    }

    func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetHighValue highValue: Int?) {
        setValue(highValue, forSubfilter: highValueFilter)
    }

    private func setValue(_ value: Int?, forSubfilter subfilter: Filter) {
        selectionStore.setValue(value, for: subfilter)
        delegate?.filterViewController(self, didSelectFilter: subfilter)
        showBottomButton(true, animated: true)
    }
}

private extension RangeFilterViewController {
    func setup() {
        bottomButton.buttonTitle = "applyButton".localized()

        let lowValue: Int? = selectionStore.value(for: lowValueFilter)
        rangeFilterView.setLowValue(lowValue, animated: false)

        let highValue: Int? = selectionStore.value(for: highValueFilter)
        rangeFilterView.setHighValue(highValue, animated: false)

        view.addSubview(rangeFilterView)

        NSLayoutConstraint.activate([
            rangeFilterView.topAnchor.constraint(equalTo: view.topAnchor, constant: 48),
            rangeFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rangeFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rangeFilterView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
        ])
    }
}
