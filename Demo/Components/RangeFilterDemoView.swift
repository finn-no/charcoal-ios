//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal

public class RangeFilterDemoView: UIView {
    let filterConfig = RangeFilterConfiguration(
        minimumValue: 0,
        maximumValue: 30000,
        valueKind: .incremented(1000),
        hasLowerBoundOffset: false,
        hasUpperBoundOffset: true,
        unit: "kr",
        accessibilityValueSuffix: nil,
        usesSmallNumberInputFont: false,
        displaysUnitInNumberInput: true,
        isCurrencyValueRange: true
    )

    private lazy var rangeFilterView: RangeFilterView = {
        let rangeFilterView = RangeFilterView(filterConfig: filterConfig)
        rangeFilterView.translatesAutoresizingMaskIntoConstraints = false
        rangeFilterView.setLowValue(filterConfig.minimumValue, animated: false)
        rangeFilterView.setHighValue(filterConfig.maximumValue, animated: false)
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
}
