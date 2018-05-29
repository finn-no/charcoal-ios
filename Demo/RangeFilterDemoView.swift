//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FilterKit
import Foundation

public class RangeFilterDemoView: UIView {
    let lowValue: Int = 0
    let highValue: Int = 30000
    let steps: Int = 300
    let sliderAccessibilitySteps: Int = 30
    let unit = "kr"
    let accessabilityUnit = "kroner"

    private lazy var rangeFilterView: RangeFilterView = {
        let rangeFilterView = RangeFilterView(range: lowValue ... highValue, steps: steps, unit: unit)
        rangeFilterView.translatesAutoresizingMaskIntoConstraints = false
        rangeFilterView.sliderAccessibilitySteps = sliderAccessibilitySteps
        rangeFilterView.sliderAccessibilityValueSuffix = accessabilityUnit
        rangeFilterView.setLowValue(lowValue, animated: false)
        rangeFilterView.setHighValue(highValue, animated: false)
        rangeFilterView.addTarget(self, action: #selector(rangeFilterViewValueChanged(_:)), for: .valueChanged)

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
            rangeFilterView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumSpacing),
            rangeFilterView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumSpacing),
        ])
    }

    @objc func rangeFilterViewValueChanged(_ sender: RangeFilterView) {
        print("Lower value: \(sender.lowValue ?? 0) -  Upper value: \(sender.highValue ?? 0)")
    }
}
