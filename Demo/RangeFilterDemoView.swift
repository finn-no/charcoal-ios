//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import Foundation

public class RangeFilterDemoView: UIView {
    let lowValue: Int = 0
    let highValue: Int = 30000
    // let steps: Int = 320
    // let sliderAccessibilitySteps: Int = 31
    let unit = "kr"
    let accessibilityUnit = "kroner"
    let referenceValues = [1000, 15000, 30000]

    private lazy var sliderData: StepSliderData = {
        return StepSliderData(
            minimumValue: lowValue,
            maximumValue: highValue,
            stepValues: [1000, 15000, 30000],
            lowerBoundOffset: 1000,
            upperBoundOffset: 1000
        )
    }()

    private lazy var rangeFilterView: RangeFilterView = {
        let rangeFilterView = RangeFilterView(
            sliderData: sliderData,
            unit: unit,
            isValueCurrency: true,
            referenceValues: referenceValues,
            usesSmallNumberInputFont: false,
            displaysUnitInNumberInput: true
        )
        rangeFilterView.translatesAutoresizingMaskIntoConstraints = false
        rangeFilterView.sliderAccessibilitySteps = sliderData.steps
        rangeFilterView.accessibilityValueSuffix = accessibilityUnit
        rangeFilterView.setLowValue(lowValue, animated: false)
        rangeFilterView.setHighValue(highValue + 1, animated: false)
        rangeFilterView.addTarget(self, action: #selector(rangeFilterValueChanged(_:)), for: .valueChanged)

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

    @objc func rangeFilterValueChanged(_ sender: RangeFilterView) {
        print("Lower value: \(sender.lowValue ?? 0) -  Upper value: \(sender.highValue ?? 0)")
    }
}
