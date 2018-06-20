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
        let rangeSliderView = RangeSliderView(range: range, additionalLowerBoundOffset: additionalLowerBoundOffset, additionalUpperBoundOffset: additionalUpperBoundOffset, steps: steps)
        rangeSliderView.translatesAutoresizingMaskIntoConstraints = false
        rangeSliderView.addTarget(self, action: #selector(sliderInputValueChanged(_:)), for: .valueChanged)
        return rangeSliderView
    }()

    private lazy var referenceValuesContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = false
        return view
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

    struct ReferenceValueLayout {
        let value: RangeValue
        let view: UIView

        var leadingConstraintIdentifier: String {
            return "ReferenceValueView-\(ObjectIdentifier(view))"
        }
    }

    private enum InputValue {
        case low, high
    }

    private var inputValues = [InputValue: RangeValue]()
    private var referenceValueLayouts = [ReferenceValueLayout]()

    public typealias RangeValue = Int
    public typealias InputRange = ClosedRange<RangeValue>
    let range: InputRange
    let additionalLowerBoundOffset: RangeValue
    let additionalUpperBoundOffset: RangeValue
    let effectiveRange: InputRange
    let steps: Int
    let unit: String
    let isValueCurrency: Bool
    let referenceValues: [RangeValue]

    public init(range: InputRange, additionalLowerBoundOffset: RangeValue = 0, additionalUpperBoundOffset: RangeValue = 0, steps: Int, unit: String, isValueCurrency: Bool, referenceValues: [RangeValue]) {
        self.range = range
        self.additionalLowerBoundOffset = additionalLowerBoundOffset
        self.additionalUpperBoundOffset = additionalUpperBoundOffset
        effectiveRange = RangeFilterView.effectiveRange(from: range, with: additionalLowerBoundOffset, and: additionalUpperBoundOffset)
        self.steps = steps
        self.unit = unit
        self.isValueCurrency = isValueCurrency
        self.referenceValues = referenceValues
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

    public override func layoutSubviews() {
        referenceValueLayouts.forEach({ layout in
            let thumbRectForValue = sliderInputView.thumbRect(for: layout.value)
            let leadingConstant = thumbRectForValue.midX - (layout.view.frame.width / 2)
            let leadingConstraint = referenceValuesContainer.constraints.first(where: { $0.identifier == layout.leadingConstraintIdentifier })
            leadingConstraint?.constant = leadingConstant
        })
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
        addSubview(numberInputView)
        addSubview(sliderInputView)
        addSubview(referenceValuesContainer)

        NSLayoutConstraint.activate([
            numberInputView.topAnchor.constraint(equalTo: topAnchor),
            numberInputView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: .mediumSpacing),
            numberInputView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -.mediumSpacing),
            numberInputView.centerXAnchor.constraint(equalTo: centerXAnchor),

            sliderInputView.topAnchor.constraint(equalTo: numberInputView.bottomAnchor, constant: 50),
            sliderInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumLargeSpacing),
            sliderInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumLargeSpacing),

            referenceValuesContainer.topAnchor.constraint(equalTo: sliderInputView.bottomAnchor, constant: .smallSpacing),
            referenceValuesContainer.leadingAnchor.constraint(equalTo: sliderInputView.leadingAnchor),
            referenceValuesContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            referenceValuesContainer.trailingAnchor.constraint(equalTo: sliderInputView.trailingAnchor),
        ])

        let referenceValueViews = referenceValues.map({ ReferenceValueView(value: $0, unit: unit, formatter: formatter) })
        referenceValueLayouts = referenceValueViews.map({ ReferenceValueLayout(value: $0.value, view: $0) })

        referenceValueLayouts.forEach { value in
            value.view.translatesAutoresizingMaskIntoConstraints = false
            referenceValuesContainer.addSubview(value.view)

            let leadingAnchor = value.view.leadingAnchor.constraint(equalTo: referenceValuesContainer.leadingAnchor)
            leadingAnchor.identifier = value.leadingConstraintIdentifier

            NSLayoutConstraint.activate([
                leadingAnchor,
                value.view.topAnchor.constraint(equalTo: referenceValuesContainer.topAnchor),
                value.view.bottomAnchor.constraint(equalTo: referenceValuesContainer.bottomAnchor),
            ])
        }
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

fileprivate final class ReferenceValueView: UIView {
    lazy var indicatorView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .sardine
        view.layer.cornerRadius = 2.0
        return view
    }()

    lazy var referenceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: FontType.light.rawValue, size: 12)
        label.textColor = .licorice
        label.textAlignment = .center

        return label
    }()

    let value: RangeFilterView.RangeValue
    let unit: String
    let formatter: NumberFormatter

    init(value: RangeFilterView.RangeValue, unit: String, formatter: NumberFormatter) {
        self.value = value
        self.unit = unit
        self.formatter = formatter
        super.init(frame: .zero)

        setup()
    }

    func setup() {
        referenceLabel.text = formatter.string(from: NSNumber(value: value))?.appending(" \(unit)")

        addSubview(indicatorView)
        addSubview(referenceLabel)

        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: topAnchor),
            indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicatorView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            indicatorView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            indicatorView.widthAnchor.constraint(equalToConstant: 4),
            indicatorView.heightAnchor.constraint(equalToConstant: 4),

            referenceLabel.topAnchor.constraint(equalTo: indicatorView.bottomAnchor, constant: .mediumSpacing),
            referenceLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            referenceLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            referenceLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
