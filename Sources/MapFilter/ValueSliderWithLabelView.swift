//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol SliderValueFormatter: AnyObject {
    func title<ValueKind>(for value: ValueKind) -> String
}

protocol ValueSliderWithLabelViewDelegate: AnyObject {
    func valueSliderWithLabelView<ValueKind: SliderValueKind>(_ valueSliderWithLabelView: ValueSliderWithLabelView<ValueKind>, didSetValue value: ValueKind)
}

class ValueSliderWithLabelView<ValueKind: SliderValueKind>: UIView {
    private lazy var valueLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .title2
        label.textColor = .licorice
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private lazy var sliderView: ValueSliderView<ValueKind> = {
        let sliderView = ValueSliderView<ValueKind>(range: range, valueFormatter: valueFormatter)
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.delegate = self
        return sliderView
    }()

    var generatesHapticFeedbackOnSliderValueChange = true {
        didSet {
            sliderView.generatesHapticFeedbackOnValueChange = generatesHapticFeedbackOnSliderValueChange
        }
    }

    private var currentValue: ValueKind
    private let range: [StepValue<ValueKind>]
    private let valueFormatter: SliderValueFormatter
    weak var delegate: ValueSliderWithLabelViewDelegate?

    init(range: [ValueKind], referenceIndexes: [Int], valueFormatter: SliderValueFormatter) {
        self.range = type(of: self).createStepValues(range: range, referenceIndexes: referenceIndexes, valueFormatter: valueFormatter)
        guard let firstInRange = self.range.first else {
            fatalError("Must initialize with a range")
        }
        currentValue = firstInRange.value
        self.valueFormatter = valueFormatter
        super.init(frame: .zero)
        setup()
        updateLabel(with: firstInRange)
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
            sliderView.accessibilityFrame = accessibilityFrame
        }
    }

    func setCurrentValue(_ newValue: ValueKind) {
        sliderView.setCurrentValue(newValue, animated: true)
        updateLabel(with: newValue)
    }
}

private extension ValueSliderWithLabelView {
    static func createStepValues<ValueKind: SliderValueKind>(range: [ValueKind], referenceIndexes: [Int], valueFormatter: SliderValueFormatter) -> [StepValue<ValueKind>] {
        let results = range.enumerated().map { (index, element) -> StepValue<ValueKind> in
            let stepValue = StepValue(value: element, displayText: valueFormatter.title(for: element), isReferenceValue: referenceIndexes.contains(index))
            return stepValue
        }
        return results
    }

    func setup() {
        addSubview(valueLabel)
        addSubview(sliderView)

        valueLabel.text = " "
        let labelHeight = valueLabel.sizeThatFits(CGSize(width: Double.greatestFiniteMagnitude, height: Double.greatestFiniteMagnitude)).height

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: .mediumSpacing),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -.mediumSpacing),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.heightAnchor.constraint(equalToConstant: labelHeight),

            sliderView.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: .mediumSpacing),
            sliderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumLargeSpacing),
            sliderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumLargeSpacing),
            sliderView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func updateLabel(with value: ValueKind) {
        valueLabel.text = valueFormatter.title(for: value)
    }

    private func updateLabel(with value: SliderReferenceValue) {
        valueLabel.text = value.displayText
    }
}

extension ValueSliderWithLabelView: ValueSliderViewDelegate {
    func valueViewControl<T: SliderValueKind>(_ valueSliderView: ValueSliderView<T>, didChangeValue stepValue: StepValue<T>) {
        guard let value = stepValue.value as? ValueKind else {
            return
        }
        let didValueChange = currentValue != value
        if didValueChange {
            currentValue = value
            updateLabel(with: stepValue)
            delegate?.valueSliderWithLabelView(self, didSetValue: currentValue)
        }
    }
}
