//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public final class RangeFilterViewController: FilterViewController {
    lazy var rangeFilterView: RangeFilterView = {
        let range = filterInfo.lowValue ... filterInfo.highValue
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
        view.delegate = self

        return view
    }()

    var currentRangeValue: RangeValue?
    let filterInfo: RangeFilterInfoType
    private let dataSource: FilterDataSource

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(filterInfo: RangeFilterInfoType, dataSource: FilterDataSource, selectionDataSource: FilterSelectionDataSource, navigator: FilterNavigator) {
        self.filterInfo = filterInfo
        self.dataSource = dataSource
        super.init(selectionDataSource: selectionDataSource, navigator: navigator)
        title = filterInfo.title
    }

    public required init?(string: String) {
        fatalError("init(string:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setSelectionValue(selectionDataSource.rangeValue(for: filterInfo))
        let showButton = selectionDataSource.rangeValue(for: filterInfo) != nil
        showApplyButton(showButton, animated: false)
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

    func setSelectionValue(_ range: RangeValue?) {
        currentRangeValue = range
        rangeFilterView.setLowValue(range?.lowValue, animated: false)
        rangeFilterView.setHighValue(range?.highValue, animated: false)
    }

    func updateSelectionDataSource() {
        if let rangeValue = currentRangeValue {
            selectionDataSource.setValue(rangeValue, for: filterInfo)
            showApplyButton(true)
        } else {
            selectionDataSource.clearAll(for: filterInfo)
        }
    }
}

extension RangeFilterViewController: RangeFilterViewDelegate {
    public func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetLowValue lowValue: Int?) {
        if lowValue != currentRangeValue?.lowValue {
            currentRangeValue = RangeValue.create(lowValue: lowValue, highValue: currentRangeValue?.highValue)
            updateSelectionDataSource()
        }
    }

    public func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetHighValue highValue: Int?) {
        if highValue != currentRangeValue?.highValue {
            currentRangeValue = RangeValue.create(lowValue: currentRangeValue?.lowValue, highValue: highValue)
            updateSelectionDataSource()
        }
    }
}
