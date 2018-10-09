//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class RangeFilterViewController: UIViewController, FilterContainerViewController {
    public var controller: UIViewController {
        return self
    }

    public var filterSelectionDelegate: FilterContainerViewControllerDelegate?

    lazy var rangeFilterView: RangeFilterView = {
        let range = RangeFilterView.InputRange(filterInfo.lowValue ... filterInfo.highValue)
        let view = RangeFilterView(
            range: range,
            additionalLowerBoundOffset: filterInfo.additionalLowerBoundOffset,
            additionalUpperBoundOffset: filterInfo.additionalUpperBoundOffset,
            steps: filterInfo.steps,
            unit: filterInfo.unit,
            isValueCurrency: filterInfo.isCurrencyValueRange,
            referenceValues: filterInfo.referenceValues,
            usesSmallNumberInputFont: filterInfo.usesSmallNumberInputFont,
            displaysUnitInNumberInput: filterInfo.displaysUnitInNumberInput
        )

        view.sliderAccessibilitySteps = filterInfo.accessibilitySteps
        view.accessibilityValueSuffix = filterInfo.accessibilityValueSuffix

        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(rangeFilterValueChanged(_:)), for: .valueChanged)

        return view
    }()

    let filterInfo: RangeFilterInfoType
    private let selectionDataSource: FilterSelectionDataSource

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public required init?(filterInfo: FilterInfoType, selectionDataSource: FilterSelectionDataSource) {
        guard let rangeFilterInfo = filterInfo as? RangeFilterInfoType else {
            return nil
        }

        self.filterInfo = rangeFilterInfo
        self.selectionDataSource = selectionDataSource
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(string: String) {
        fatalError("init(string:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setup()

        if let selectionValue = selectionDataSource.rangeValue(for: filterInfo) {
            setSelectionValue(selectionValue)
        }
    }
}

private extension RangeFilterViewController {
    func setup() {
        view.backgroundColor = .milk
        title = filterInfo.title

        view.addSubview(rangeFilterView)

        NSLayoutConstraint.activate([
            rangeFilterView.topAnchor.constraint(equalTo: view.topAnchor, constant: 48),
            rangeFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rangeFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rangeFilterView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
        ])
    }

    func setSelectionValue(_ range: RangeValue) {
        switch range {
        case let .minimum(lowValue):
            rangeFilterView.setLowValue(lowValue, animated: false)
        case let .maximum(highValue):
            rangeFilterView.setHighValue(highValue, animated: false)
        case let .closed(lowValue, highValue):
            rangeFilterView.setLowValue(lowValue, animated: false)
            rangeFilterView.setHighValue(highValue, animated: false)
        }
    }

    @objc func rangeFilterValueChanged(_ sender: RangeFilterView) {
        let rangeValue: RangeValue?
        if let lowValue = rangeFilterView.lowValue {
            if let highValue = rangeFilterView.highValue {
                rangeValue = .closed(lowValue: lowValue, highValue: highValue)
            } else {
                rangeValue = .minimum(lowValue: lowValue)
            }
        } else if let highValue = rangeFilterView.highValue {
            rangeValue = .maximum(highValue: highValue)
        } else {
            rangeValue = nil
        }

        if let rangeValue = rangeValue {
            selectionDataSource.setValue(rangeValue, for: filterInfo)
        } else {
            selectionDataSource.clearAll(for: filterInfo)
        }
    }
}
