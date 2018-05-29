//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public final class RangeFilterView: UIControl {
    private lazy var numberInputView: RangeNumberInputView = {
        let rangeNumberInputView = RangeNumberInputView(range: range, unit: unit)
        rangeNumberInputView.translatesAutoresizingMaskIntoConstraints = false
        rangeNumberInputView.addTarget(self, action: #selector(numberInputValueChanged(_:)), for: .valueChanged)

        return rangeNumberInputView
    }()

    private lazy var sliderInputView: RangeSliderView = {
        let rangeSliderView = RangeSliderView(range: range, steps: steps)
        rangeSliderView.translatesAutoresizingMaskIntoConstraints = false
        rangeSliderView.addTarget(self, action: #selector(sliderInputValueChanged(_:)), for: .valueChanged)
        return rangeSliderView
    }()

    public var generatesHapticFeedbackOnSliderValueChange = true {
        didSet {
            sliderInputView.generatesHapticFeedbackOnValueChange = generatesHapticFeedbackOnSliderValueChange
        }
    }

    public var sliderAccessibilityValueSuffix: String? {
        didSet {
            sliderInputView.accessibilityValueSuffix = sliderAccessibilityValueSuffix
        }
    }

    private var _accessibilitySteps: RangeSliderView.Steps?
    public var sliderAccessibilitySteps: RangeSliderView.Steps {
        get {
            guard let accessibilitySteps = _accessibilitySteps else {
                return steps
            }

            return accessibilitySteps
        }
        set {
            _accessibilitySteps = newValue
            sliderInputView.accessibilitySteps = newValue
        }
    }

    private enum InputValue {
        case low, high
    }

    private var inputValues = [InputValue: RangeValue]()

    public typealias RangeValue = Int
    public typealias InputRange = ClosedRange<RangeValue>
    let range: InputRange
    let steps: Int
    let unit: String

    public init(range: InputRange, steps: Int, unit: String) {
        self.range = range
        self.steps = steps
        self.unit = unit
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RangeFilterView: RangeControl {
    public var lowValue: Int? {
        return inputValues[.low]
    }

    public var highValue: Int? {
        return inputValues[.high]
    }

    public func setLowValue(_ value: Int, animated: Bool) {
        numberInputView.setLowValue(value, animated: animated)
        sliderInputView.setLowValue(value, animated: animated)
    }

    public func setHighValue(_ value: Int, animated: Bool) {
        numberInputView.setHighValue(value, animated: animated)
        sliderInputView.setHighValue(value, animated: animated)
    }
}

private extension RangeFilterView {
    func setup() {
        let referenceValueLabelsContainer = UIStackView(frame: .zero)
        referenceValueLabelsContainer.translatesAutoresizingMaskIntoConstraints = false
        referenceValueLabelsContainer.distribution = .fillEqually

        let lowerBoundReferenceLabel = UILabel(text: "\(range.lowerBound) \(unit)", textAlignment: .left)
        let midBoundReferenceLabel = UILabel(text: "\(range.count / 2) \(unit)", textAlignment: .center)
        let upperBoundReferenceLabel = UILabel(text: "\(range.upperBound) \(unit)", textAlignment: .right)

        referenceValueLabelsContainer.addArrangedSubview(lowerBoundReferenceLabel)
        referenceValueLabelsContainer.addArrangedSubview(midBoundReferenceLabel)
        referenceValueLabelsContainer.addArrangedSubview(upperBoundReferenceLabel)

        addSubview(numberInputView)
        addSubview(sliderInputView)
        addSubview(referenceValueLabelsContainer)

        NSLayoutConstraint.activate([
            numberInputView.topAnchor.constraint(equalTo: topAnchor),
            numberInputView.leadingAnchor.constraint(equalTo: leadingAnchor),
            numberInputView.trailingAnchor.constraint(equalTo: trailingAnchor),

            sliderInputView.topAnchor.constraint(equalTo: numberInputView.bottomAnchor, constant: 50),
            sliderInputView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sliderInputView.trailingAnchor.constraint(equalTo: trailingAnchor),

            referenceValueLabelsContainer.topAnchor.constraint(equalTo: sliderInputView.bottomAnchor, constant: .mediumLargeSpacing),
            referenceValueLabelsContainer.leadingAnchor.constraint(equalTo: sliderInputView.leadingAnchor),
            referenceValueLabelsContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            referenceValueLabelsContainer.trailingAnchor.constraint(equalTo: sliderInputView.trailingAnchor),
        ])
    }

    @objc func numberInputValueChanged(_ sender: RangeNumberInputView) {
        if let lowValue = sender.lowValue {
            sliderInputView.setLowValue(lowValue, animated: true)
            inputValues[.low] = lowValue
        }

        if let highValue = sender.highValue {
            sliderInputView.setHighValue(highValue, animated: true)
            inputValues[.high] = highValue
        }

        sendActions(for: .valueChanged)
    }

    @objc func sliderInputValueChanged(_ sender: RangeSliderView) {
        if let lowValue = sender.lowValue {
            numberInputView.setLowValue(lowValue, animated: true)
            inputValues[.low] = lowValue
        }

        if let highValue = sender.highValue {
            numberInputView.setHighValue(highValue, animated: true)
            inputValues[.high] = highValue
        }

        sendActions(for: .valueChanged)
    }
}

private extension UILabel {
    convenience init(text: String, textAlignment: NSTextAlignment) {
        self.init(frame: .zero)
        self.text = text
        self.textAlignment = textAlignment

        font = .detail
        textColor = .licorice
    }
}
