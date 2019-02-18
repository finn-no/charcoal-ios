//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

final class RangeFilterViewController: FilterViewController {

    // MARK: - Private properties

    private let rangeFilter: RangeFilter
    private let viewModel: RangeFilterInfo

    private lazy var rangeFilterView: RangeFilterView = {
        let view = RangeFilterView(filterInfo: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    // MARK: - Init

    init(rangeFilter: RangeFilter, viewModel: RangeFilterInfo, selectionStore: FilterSelectionStore) {
        self.rangeFilter = rangeFilter
        self.viewModel = viewModel
        super.init(filter: rangeFilter, selectionStore: selectionStore)
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
        setValue(lowValue, forChild: rangeFilter.lowValueFilter)
    }

    func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetHighValue highValue: Int?) {
        setValue(highValue, forChild: rangeFilter.highValueFilter)
    }

    private func setValue(_ value: Int?, forChild filter: Filter) {
        selectionStore.setValue(value, for: filter)
        delegate?.filterViewController(self, didSelectFilter: filter)
        showBottomButton(true, animated: true)
    }
}

private extension RangeFilterViewController {
    func setup() {
        bottomButton.buttonTitle = "apply_button_title".localized()

        let lowValue: Int? = selectionStore.value(for: rangeFilter.lowValueFilter)
        rangeFilterView.setLowValue(lowValue, animated: false)

        let highValue: Int? = selectionStore.value(for: rangeFilter.highValueFilter)
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
