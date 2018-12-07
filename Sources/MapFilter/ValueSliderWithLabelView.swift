//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol ValueSliderViewDelegate: AnyObject {
    func valueSliderView<ValueKind: ValueSliderControlValueKind>(_ valueSliderView: ValueSliderAndInputView<ValueKind>, didSetValue value: ValueKind)
}

final class ValueSliderAndInputView<ValueKind: ValueSliderControlValueKind>: UIView {
    private lazy var valueLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .title2
        label.textColor = .licorice
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private lazy var sliderControl: ValueSliderControl<ValueKind> = {
        let sliderControl = ValueSliderControl<ValueKind>(range: range)
        sliderControl.translatesAutoresizingMaskIntoConstraints = false
        sliderControl.delegate = self
        return sliderControl
    }()

    var generatesHapticFeedbackOnSliderValueChange = true {
        didSet {
            sliderControl.generatesHapticFeedbackOnValueChange = generatesHapticFeedbackOnSliderValueChange
        }
    }

    var currentValue: ValueKind {
        didSet {
            updateLabel(with: currentValue)
            delegate?.valueSliderView(self, didSetValue: currentValue)
        }
    }

    private let range: [StepValue<ValueKind>]

    weak var delegate: ValueSliderViewDelegate?

    init(range: [StepValue<ValueKind>]) {
        self.range = range
        guard let firstInRange = range.first else {
            fatalError("Must initialize with a range")
        }
        currentValue = firstInRange.value
        super.init(frame: .zero)
        setup()
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

private extension ValueSliderAndInputView {
    func setup() {
        addSubview(valueLabel)
        addSubview(sliderControl)

        valueLabel.text = " "
        let labelHeight = valueLabel.sizeThatFits(CGSize(width: Double.greatestFiniteMagnitude, height: Double.greatestFiniteMagnitude)).height

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: .mediumSpacing),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -.mediumSpacing),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.heightAnchor.constraint(equalToConstant: labelHeight),

            sliderControl.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: .mediumSpacing),
            sliderControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumLargeSpacing),
            sliderControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumLargeSpacing),
            sliderControl.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func updateLabel(with value: ValueKind) {
        // TODO: proper to string convertion
        valueLabel.text = "\(value)"
    }
}

extension ValueSliderAndInputView: ValueSliderControlDelegate {
    func valueSliderControl<T: ValueSliderControlValueKind>(_ valueSliderControl: ValueSliderControl<T>, didChangeValue value: T) {
        guard let value = value as? ValueKind else {
            return
        }
        let didValueChange = currentValue != value
        if didValueChange {
            currentValue = value
        }
    }
}
