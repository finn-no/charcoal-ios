//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

@testable import Charcoal

class StepperFilterDemoView: UIView {
    private var didSetConstant = false
    private lazy var topConstraint = stepperFilterView.centerYAnchor.constraint(equalTo: topAnchor)

    let filterInfo = RangeFilterInfo(
        kind: .stepper,
        lowValue: 0,
        highValue: 6,
        increment: 1,
        rangeBoundsOffsets: (hasLowerBoundOffset: false, hasUpperBoundOffset: true),
        unit: "stk",
        accesibilityValues: (stepIncrement: nil, valueSuffix: nil),
        appearanceProperties: (usesSmallNumberInputFont: false, displaysUnitInNumberInput: true, isCurrencyValueRange: true)
    )

    private lazy var stepperFilterView: StepperFilterView = {
        let view = StepperFilterView(filterInfo: filterInfo)
        view.addTarget(self, action: #selector(handleValueChange(sender:)), for: .valueChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stepperFilterView)
        NSLayoutConstraint.activate([
            topConstraint,
            stepperFilterView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stepperFilterView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !didSetConstant else { return }
        topConstraint.constant = frame.height / 2
        didSetConstant = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension StepperFilterDemoView {
    @objc func handleValueChange(sender: StepperFilterView) {
        print("Value:", sender.value)
    }
}
