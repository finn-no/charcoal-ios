//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class RangeFilterViewController: UIViewController, FilterChildViewController {
    public var controller: UIViewController {
        return self
    }

    public var filterSelectionDelegate: FilterChildViewControllerDelegate?

    lazy var rangeFilterView: RangeFilterView = {
        let range = RangeFilterView.InputRange(filterInfo.lowValue ... filterInfo.highValue)
        let referenceValues = [range.lowerBound, (range.lowerBound + range.count / 2), range.upperBound]
        let view = RangeFilterView(
            range: range,
            additionalLowerBoundOffset: 0,
            additionalUpperBoundOffset: 0,
            steps: filterInfo.steps,
            unit: filterInfo.unit,
            isValueCurrency: false,
            referenceValues: referenceValues,
            usesSmallNumberInputFont: false,
            displaysUnitInNumberInput: true
        )

        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(rangeFilterValueChanged(_:)), for: .valueChanged)

        return view
    }()

    let filterInfo: RangeFilterInfoType

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public required init?(filterInfo: FilterInfoType) {
        guard let rangeFilterInfo = filterInfo as? RangeFilterInfoType else {
            return nil
        }

        self.filterInfo = rangeFilterInfo
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    public required init?(string: String) {
        fatalError("init(string:) has not been implemented")
    }

    public func setSelectionValue(_ selectionValue: FilterSelectionValue) {
        guard case let .rangeSelection(lowValue, higValue) = selectionValue else {
            return
        }

        if let selectionLowValue = lowValue {
            rangeFilterView.setLowValue(selectionLowValue, animated: false)
        }

        if let selectionHighValue = higValue {
            rangeFilterView.setHighValue(selectionHighValue, animated: false)
        }
    }
}

private extension RangeFilterViewController {
    func setup() {
        view.backgroundColor = .milk
        title = filterInfo.name

        view.addSubview(rangeFilterView)

        NSLayoutConstraint.activate([
            rangeFilterView.topAnchor.constraint(equalTo: view.topAnchor),
            rangeFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rangeFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rangeFilterView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
        ])
    }

    @objc func rangeFilterValueChanged(_ sender: RangeFilterView) {
        filterSelectionDelegate?.filterChildViewController(filterChildViewController: self, didUpdateFilterSelectionValue: .rangeSelection(lowValue: rangeFilterView.lowValue, highValue: rangeFilterView.highValue))
    }
}
