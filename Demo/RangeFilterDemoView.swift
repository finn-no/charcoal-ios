//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal

public class RangeFilterDemoView: UIView {
    let filterInfo = RangeFilterInfo(
        parameterName: "range",
        title: "Range Filter",
        lowValue: 0,
        highValue: 30000,
        increment: 1000,
        rangeBoundsOffsets: (hasLowerBoundOffset: false, hasUpperBoundOffset: true),
        unit: "kr",
        accesibilityValues: (stepIncrement: nil, valueSuffix: nil),
        appearanceProperties: (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
    )

    private lazy var rangeFilterView: RangeFilterView = {
        let rangeFilterView = RangeFilterView(filterInfo: filterInfo)
        rangeFilterView.translatesAutoresizingMaskIntoConstraints = false
        rangeFilterView.setLowValue(filterInfo.sliderInfo.minimumValue, animated: false)
        rangeFilterView.setHighValue(filterInfo.sliderInfo.maximumValue, animated: false)
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
