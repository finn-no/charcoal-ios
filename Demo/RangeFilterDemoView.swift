//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit
import Foundation

public class RangeFilterDemoView: UIView {
    let lowValue: Int = 0
    let highValue: Int = 30000
    let steps: Int = 320
    let sliderAccessibilitySteps: Int = 31
    let unit = "kr"
    let accessibilityUnit = "kroner"
    let referenceValues = [1000, 15000, 30000]

    private lazy var rangeFilterView: RangeFilterView = {
        let rangeFilterView = RangeFilterView(
            range: lowValue ... highValue,
            additionalLowerBoundOffset: 1000,
            additionalUpperBoundOffset: 1000,
            steps: steps,
            unit: unit,
            isValueCurrency: true,
            referenceValues: referenceValues,
            usesSmallNumberInputFont: false,
            displaysUnitInNumberInput: true
        )
        rangeFilterView.translatesAutoresizingMaskIntoConstraints = false
        rangeFilterView.sliderAccessibilitySteps = sliderAccessibilitySteps
        rangeFilterView.accessibilityValueSuffix = accessibilityUnit
        rangeFilterView.setSelectionValue(.rangeSelection(lowValue: 0, highValue: 30001))
        rangeFilterView.delegate = self

        return rangeFilterView
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        addSubview(rangeFilterView)

        NSLayoutConstraint.activate([
            rangeFilterView.topAnchor.constraint(equalTo: topAnchor, constant: 48),
            rangeFilterView.leadingAnchor.constraint(equalTo: leadingAnchor),
            rangeFilterView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

extension RangeFilterDemoView: FilterViewDelegate {
    public func filterView(filterView: FilterView, didUpdateFilterSelectionValue filterSelectionValue: FilterSelectionValue) {
        guard case let FilterSelectionValue.rangeSelection(lowValue, highValue) = filterSelectionValue else {
            return
        }

        print("Lower value: \(lowValue ?? 0) -  Upper value: \(highValue ?? 0)")
    }
}
