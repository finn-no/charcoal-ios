//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol ValueSliderFormatter: AnyObject {
    func displayText<ValueKind: Numeric>(for value: ValueKind) -> String
}

protocol ValueSliderWithLabelViewDelegate: AnyObject {
    func valueSliderWithLabelView<ValueKind: ValueSliderControlValueKind>(_ valueSliderWithLabelView: ValueSliderWithLabelView<ValueKind>, didSetValue value: ValueKind)
}

final class ValueSliderWithLabelView<ValueKind: ValueSliderControlValueKind>: UIView {
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
            delegate?.valueSliderWithLabelView(self, didSetValue: currentValue)
        }
    }

    private let range: [StepValue<ValueKind>]
    private let valueFormatter: ValueSliderFormatter
    weak var delegate: ValueSliderWithLabelViewDelegate?

    init(range: [ValueKind], referenceIndexes: [Int], valueFormatter: ValueSliderFormatter) {
        self.range = type(of: self).createStepValues(range: range, referenceIndexes: referenceIndexes, valueFormatter: valueFormatter)
        guard let firstInRange = self.range.first else {
            fatalError("Must initialize with a range")
        }
        currentValue = firstInRange.value
        self.valueFormatter = valueFormatter
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

private extension ValueSliderWithLabelView {
    static func createStepValues<ValueKind: ValueSliderControlValueKind>(range: [ValueKind], referenceIndexes: [Int], valueFormatter: ValueSliderFormatter) -> [StepValue<ValueKind>] {
        let results = range.enumerated().map { (index, element) -> StepValue<ValueKind> in
            let stepValue = StepValue(value: element, displayText: valueFormatter.displayText(for: element), isReferenceValue: referenceIndexes.contains(index))
            return stepValue
        }
        return results
    }

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
        valueLabel.text = valueFormatter.displayText(for: value)
    }

    private func updateLabel(with value: SliderReferenceValue) {
        valueLabel.text = value.displayText
    }
}

extension ValueSliderWithLabelView: ValueSliderControlDelegate {
    func valueSliderControl<T: ValueSliderControlValueKind>(_ valueSliderControl: ValueSliderControl<T>, didChangeValue stepValue: StepValue<T>) {
        guard let value = stepValue.value as? ValueKind else {
            return
        }
        let didValueChange = currentValue != value
        if didValueChange {
            currentValue = value
            updateLabel(with: stepValue)
        }
    }
}
