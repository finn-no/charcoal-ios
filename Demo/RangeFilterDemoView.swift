//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Charcoal
import Foundation

public class RangeFilterDemoView: UIView {
    let unit = "kr"
    let accessibilityUnit = "kroner"

    private lazy var rangeFilterView: RangeFilterView = {
        let filterInfo = RangeFilterInfo()
        let rangeFilterView = RangeFilterView(filterInfo: filterInfo)
        rangeFilterView.translatesAutoresizingMaskIntoConstraints = false
        rangeFilterView.setLowValue(filterInfo.sliderInfo.minimumValue, animated: false)
        rangeFilterView.setHighValue(filterInfo.sliderInfo.maximumValueWithOffset, animated: false)
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

    private func setup() {
        addSubview(rangeFilterView)

        NSLayoutConstraint.activate([
            rangeFilterView.topAnchor.constraint(equalTo: topAnchor, constant: 48),
            rangeFilterView.leadingAnchor.constraint(equalTo: leadingAnchor),
            rangeFilterView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    @objc private func rangeFilterValueChanged(_ sender: RangeFilterView) {
        print("Lower value: \(sender.lowValue ?? 0) -  Upper value: \(sender.highValue ?? 0)")
    }
}

// MARK: - Private

private struct RangeFilterInfo: RangeFilterInfoType {
    let title = "Range filter"
    let unit = "kr"
    let isCurrencyValueRange = true
    let accessibilityValueSuffix: String? = nil
    let usesSmallNumberInputFont = false
    let displaysUnitInNumberInput = true
    var isContextFilter: Bool = false

    let sliderInfo = StepSliderInfo(
        minimumValue: 0,
        maximumValue: 30000,
        stepValues: [100, 500, 1000, 2000, 3000, 4000, 5000, 8000, 10000, 15000, 20000],
        hasLowerBoundOffset: true,
        hasUpperBoundOffset: true
    )
}
