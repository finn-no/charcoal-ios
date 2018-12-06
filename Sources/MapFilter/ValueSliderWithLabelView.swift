//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol ValueSliderViewDelegate: AnyObject {
    func valueSliderView(_ valueSliderView: ValueSliderAndInputView, didSetValue value: Int)
}

final class ValueSliderAndInputView: UIView {
    private lazy var valueLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .title2
        label.textColor = .licorice
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = " "
        return label
    }()

    private lazy var sliderControl: ValueSliderControl = {
        let sliderControl = ValueSliderControl(range: range)
        sliderControl.translatesAutoresizingMaskIntoConstraints = false
        sliderControl.delegate = self
        return sliderControl
    }()

    var generatesHapticFeedbackOnSliderValueChange = true {
        didSet {
            sliderControl.generatesHapticFeedbackOnValueChange = generatesHapticFeedbackOnSliderValueChange
        }
    }

    var currentValue: ValueSliderControl.RangeValue {
        return currentStepValue?.value ?? 0
    }

    private(set) var currentStepValue: StepValue? {
        didSet {
            updateLabel(with: currentStepValue)
            delegate?.valueSliderView(self, didSetValue: currentStepValue?.value ?? 0)
        }
    }

    private let range: [StepValue]

    weak var delegate: ValueSliderViewDelegate?

    init(range: [StepValue]) {
        self.range = range
        super.init(frame: .zero)
        setup()
        currentStepValue = range.first
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard self.point(inside: point, with: event) else {
            return nil
        }

        for subview in subviews {
            let convertedPoint = subview.convert(point, from: self)
            if let hitView = subview.hitTest(convertedPoint, with: event) {
                return hitView
            }
        }

        return nil
    }

    override var accessibilityFrame: CGRect {
        didSet {
            sliderControl.accessibilityFrame = accessibilityFrame
        }
    }
}

extension ValueSliderAndInputView {
    func setValue(_ value: ValueSliderControl.RangeValue, animated: Bool) {
        guard let step = sliderControl.findClosestStepInRange(with: value) else {
            return
        }
        currentStepValue = step
    }
}

private extension ValueSliderAndInputView {
    func setup() {
        addSubview(valueLabel)
        addSubview(sliderControl)

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: .mediumSpacing),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -.mediumSpacing),
            valueLabel.heightAnchor.constraint(equalToConstant: 32),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            sliderControl.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: .mediumSpacing),
            sliderControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumLargeSpacing),
            sliderControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumLargeSpacing),
            sliderControl.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func updateLabel(with value: StepValue?) {
        guard let value = value else {
            valueLabel.text = ""
            return
        }
        valueLabel.text = value.displayTitle
    }
}

extension ValueSliderAndInputView: ValueSliderControlDelegate {
    func valueSliderControl(_ valueSliderControl: ValueSliderControl, didChangeValue value: StepValue?) {
        if let value = value {
            let didValueChange = currentValue != value.value
            if didValueChange {
                currentStepValue = value
                updateLabel(with: value)
                delegate?.valueSliderView(self, didSetValue: value.value)
            }
        } else {
            updateLabel(with: nil)
            delegate?.valueSliderView(self, didSetValue: 0)
        }
    }
}
