//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol SliderValueFormatter: AnyObject {
    func title<ValueKind>(for value: ValueKind) -> String
    func accessibilityValue<ValueKind>(for value: ValueKind) -> String
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
        let sliderView = ValueSliderView<ValueKind>(range: range, referenceValueIndexes: referenceValueIndexes, valueFormatter: valueFormatter)
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
    private let range: [ValueKind]
    private let referenceValueIndexes: [Int]
    private let valueFormatter: SliderValueFormatter
    weak var delegate: ValueSliderWithLabelViewDelegate?

    init(range: [ValueKind], referenceIndexes: [Int], valueFormatter: SliderValueFormatter) {
        self.range = range
        referenceValueIndexes = referenceIndexes
        guard let firstInRange = self.range.first else {
            fatalError("Must initialize with a range")
        }
        currentValue = firstInRange
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
    func valueViewControl<T: SliderValueKind>(_ valueSliderView: ValueSliderView<T>, didChangeValue value: T) {
        guard let value = value as? ValueKind else {
            return
        }
        let didValueChange = currentValue != value
        if didValueChange {
            currentValue = value
            updateLabel(with: value)
            delegate?.valueSliderWithLabelView(self, didSetValue: currentValue)
        }
    }
}
