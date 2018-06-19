//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public final class RangeFilterView: UIControl {
    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = isValueCurrency ? .currency : .none
        formatter.currencySymbol = ""
        formatter.locale = Locale(identifier: "nb_NO")
        formatter.maximumFractionDigits = 0

        return formatter
    }()

    private lazy var numberInputView: RangeNumberInputView = {
        let rangeNumberInputView = RangeNumberInputView(range: range, unit: unit, formatter: formatter)
        rangeNumberInputView.translatesAutoresizingMaskIntoConstraints = false
        rangeNumberInputView.addTarget(self, action: #selector(numberInputValueChanged(_:)), for: .valueChanged)

        return rangeNumberInputView
    }()

    private lazy var sliderInputView: RangeSliderView = {
        let rangeSliderView = RangeSliderView(range: effectiveRange, steps: steps)
        rangeSliderView.translatesAutoresizingMaskIntoConstraints = false
        rangeSliderView.addTarget(self, action: #selector(sliderInputValueChanged(_:)), for: .valueChanged)
        return rangeSliderView
    }()

    public var generatesHapticFeedbackOnSliderValueChange = true {
        didSet {
            sliderInputView.generatesHapticFeedbackOnValueChange = generatesHapticFeedbackOnSliderValueChange
        }
    }

    public var accessibilityValueSuffix: String? {
        didSet {
            sliderInputView.accessibilityValueSuffix = accessibilityValueSuffix
            numberInputView.accessibilityValueSuffix = accessibilityValueSuffix
        }
    }

    private var _accessibilitySteps: Int?
    public var sliderAccessibilitySteps: Int {
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
    let additionalLowerBoundOffset: RangeValue
    let additionalUpperBoundOffset: RangeValue
    let effectiveRange: InputRange
    let steps: Int
    let unit: String
    let isValueCurrency: Bool

    public init(range: InputRange, additionalLowerBoundOffset: RangeValue = 0, additionalUpperBoundOffset: RangeValue = 0, steps: Int, unit: String, isValueCurrency: Bool) {
        self.range = range
        self.additionalLowerBoundOffset = additionalLowerBoundOffset
        self.additionalUpperBoundOffset = additionalUpperBoundOffset
        effectiveRange = RangeFilterView.effectiveRange(from: range, with: additionalLowerBoundOffset, and: additionalUpperBoundOffset)
        self.steps = steps
        self.unit = unit
        self.isValueCurrency = isValueCurrency
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard self.point(inside: point, with: event) else {
            if numberInputView.isFirstResponder {
                _ = numberInputView.resignFirstResponder()
            }

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

    public override var accessibilityFrame: CGRect {
        didSet {
            sliderInputView.accessibilityFrame = accessibilityFrame
        }
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
        updateNumberInputLowValue(with: value)
        updateSliderLowValue(with: value)
    }

    public func setHighValue(_ value: Int, animated: Bool) {
        updateNumberInputHighValue(with: value)
        updateSliderHighValue(with: value)
    }
}

private extension RangeFilterView {
    func setup() {
        let referenceValueLabelsContainer = UIStackView(frame: .zero)
        referenceValueLabelsContainer.translatesAutoresizingMaskIntoConstraints = false
        referenceValueLabelsContainer.distribution = .fillEqually

        let lowerBoundFormattedValue = formatter.string(from: NSNumber(value: range.lowerBound)) ?? ""
        let lowerBoundReferenceLabel = UILabel(text: "\(lowerBoundFormattedValue) \(unit)", textAlignment: .left)
        lowerBoundReferenceLabel.isAccessibilityElement = false

        let midBoundFormattedValue = formatter.string(from: NSNumber(value: range.count / 2)) ?? ""
        let midBoundReferenceLabel = UILabel(text: "\(midBoundFormattedValue) \(unit)", textAlignment: .center)
        midBoundReferenceLabel.isAccessibilityElement = false
        let upperBoundFormattedValue = formatter.string(from: NSNumber(value: range.upperBound)) ?? ""
        let upperBoundReferenceLabel = UILabel(text: "\(upperBoundFormattedValue) \(unit)", textAlignment: .right)
        upperBoundReferenceLabel.isAccessibilityElement = false

        referenceValueLabelsContainer.addArrangedSubview(lowerBoundReferenceLabel)
        referenceValueLabelsContainer.addArrangedSubview(midBoundReferenceLabel)
        referenceValueLabelsContainer.addArrangedSubview(upperBoundReferenceLabel)

        addSubview(numberInputView)
        addSubview(sliderInputView)
        addSubview(referenceValueLabelsContainer)

        NSLayoutConstraint.activate([
            numberInputView.topAnchor.constraint(equalTo: topAnchor),
            numberInputView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: .mediumSpacing),
            numberInputView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -.mediumSpacing),
            numberInputView.centerXAnchor.constraint(equalTo: centerXAnchor),

            sliderInputView.topAnchor.constraint(equalTo: numberInputView.bottomAnchor, constant: 50),
            sliderInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumLargeSpacing),
            sliderInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumLargeSpacing),

            referenceValueLabelsContainer.topAnchor.constraint(equalTo: sliderInputView.bottomAnchor, constant: .mediumLargeSpacing),
            referenceValueLabelsContainer.leadingAnchor.constraint(equalTo: sliderInputView.leadingAnchor),
            referenceValueLabelsContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            referenceValueLabelsContainer.trailingAnchor.constraint(equalTo: sliderInputView.trailingAnchor),
        ])
    }

    @objc func numberInputValueChanged(_ sender: RangeNumberInputView) {
        if let lowValue = sender.lowValue {
            updateSliderLowValue(with: lowValue)
            numberInputView.setLowValueHint(text: "")
            inputValues[.low] = lowValue
        }

        if let highValue = sender.highValue {
            updateSliderHighValue(with: highValue)
            numberInputView.setHighValueHint(text: "")
            inputValues[.high] = highValue
        }

        sendActions(for: .valueChanged)
    }

    @objc func sliderInputValueChanged(_ sender: RangeSliderView) {
        if let lowValue = sender.lowValue {
            updateNumberInputLowValue(with: lowValue)
            inputValues[.low] = lowValue
        }

        if let highValue = sender.highValue {
            inputValues[.high] = highValue
            updateNumberInputHighValue(with: highValue)
        }

        sendActions(for: .valueChanged)
    }

    func updateSliderLowValue(with value: RangeValue) {
        let isValueLowerThanRangeLowerBound = value < range.lowerBound
        let newValue = isValueLowerThanRangeLowerBound ? effectiveRange.lowerBound : value
        sliderInputView.setLowValue(newValue, animated: false)
    }

    func updateSliderHighValue(with value: RangeValue) {
        let isValueHigherThanRangeUpperBound = value > range.upperBound
        let newValue = isValueHigherThanRangeUpperBound ? effectiveRange.upperBound : value
        sliderInputView.setHighValue(newValue, animated: false)
    }

    func updateNumberInputLowValue(with value: RangeValue) {
        let isValueLowerThanRangeLowerBound = value < range.lowerBound
        let newValue = isValueLowerThanRangeLowerBound ? range.lowerBound : value
        let hintText = isValueLowerThanRangeLowerBound ? "Under" : ""
        numberInputView.setLowValueHint(text: hintText)
        numberInputView.setLowValue(newValue, animated: false)
    }

    func updateNumberInputHighValue(with value: RangeValue) {
        let isValueHigherThanRangeUpperBound = value > range.upperBound
        let newValue = isValueHigherThanRangeUpperBound ? range.upperBound : value
        let hintText = isValueHigherThanRangeUpperBound ? "Over" : ""
        numberInputView.setHighValue(newValue, animated: false)
        numberInputView.setHighValueHint(text: hintText)
    }

    static func effectiveRange(from range: InputRange, with lowerBoundOffset: RangeValue, and upperBoundOffset: RangeValue) -> InputRange {
        let newLowerBound = range.lowerBound - lowerBoundOffset
        let newUpperBound = range.upperBound + upperBoundOffset

        return InputRange(newLowerBound ... newUpperBound)
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
