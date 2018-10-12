//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol RangeFilterViewDelegate: AnyObject {
    func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetLowValue lowValue: Int?)
    func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetHighValue highValue: Int?)
}

public final class RangeFilterView: UIControl {
    private let formatter: RangeFilterValueFormatter

    private lazy var numberInputView: RangeNumberInputView = {
        let inputFontSize = usesSmallNumberInputFont ? RangeNumberInputView.InputFontSize.small : RangeNumberInputView.InputFontSize.large
        let rangeNumberInputView = RangeNumberInputView(range: range, unit: unit, formatter: formatter, inputFontSize: inputFontSize, displaysUnitInNumberInput: displaysUnitInNumberInput)
        rangeNumberInputView.translatesAutoresizingMaskIntoConstraints = false
        rangeNumberInputView.addTarget(self, action: #selector(numberInputValueChanged(_:)), for: .valueChanged)

        return rangeNumberInputView
    }()

    private lazy var sliderInputView: RangeSliderView = {
        let rangeSliderView = RangeSliderView(range: range, additionalLowerBoundOffset: additionalLowerBoundOffset, additionalUpperBoundOffset: additionalUpperBoundOffset, steps: steps)
        rangeSliderView.translatesAutoresizingMaskIntoConstraints = false
        rangeSliderView.delegate = self
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
    public var sliderAccessibilitySteps: Int? {
        get {
            guard let accessibilitySteps = _accessibilitySteps else {
                return steps
            }

            return accessibilitySteps
        }
        set {
            _accessibilitySteps = newValue
            sliderInputView.accessibilitySteps = newValue ?? steps
        }
    }

    private enum InputValue {
        case low, high
    }

    private var inputValues = [InputValue: RangeValue]()
    private var referenceValueViews = [RangeReferenceValueView]()

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
    let usesSmallNumberInputFont: Bool
    let displaysUnitInNumberInput: Bool

    public weak var delegate: RangeFilterViewDelegate?

    public init(range: InputRange, additionalLowerBoundOffset: RangeValue = 0, additionalUpperBoundOffset: RangeValue = 0, steps: Int, unit: String, isValueCurrency: Bool, referenceValues: [RangeValue], usesSmallNumberInputFont: Bool = false, displaysUnitInNumberInput: Bool = true) {
        self.range = range
        self.additionalLowerBoundOffset = additionalLowerBoundOffset
        self.additionalUpperBoundOffset = additionalUpperBoundOffset
        effectiveRange = RangeFilterView.effectiveRange(from: range, with: additionalLowerBoundOffset, and: additionalUpperBoundOffset)
        self.steps = steps
        self.unit = unit
        self.isValueCurrency = isValueCurrency
        self.referenceValues = referenceValues
        self.usesSmallNumberInputFont = usesSmallNumberInputFont
        self.displaysUnitInNumberInput = displaysUnitInNumberInput
        formatter = RangeFilterValueFormatter(isValueCurrency: isValueCurrency)
        super.init(frame: .zero)
        setup()
        setLowValue(effectiveRange.lowerBound, animated: false)
        setHighValue(effectiveRange.upperBound, animated: false)
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
        referenceValueViews.forEach({ view in
            let thumbRectForValue = sliderInputView.thumbRect(for: view.value)
            let leadingConstant = thumbRectForValue.midX - (view.frame.width / 2)
            view.leadingConstraint?.constant = leadingConstant
        })

        if shouldForceSmallFontSizeForNumberInput() {
            numberInputView.forceSmallInputFontSize()
        }
    }
}

extension RangeFilterView: RangeControl {
    public var lowValue: RangeValue? {
        return inputValues[.low]
    }

    public var highValue: RangeValue? {
        return inputValues[.high]
    }

    public func setLowValue(_ value: RangeValue, animated: Bool) {
        let lowValue = (value < range.lowerBound) ? effectiveRange.lowerBound : value
        updateNumberInput(for: .low, with: lowValue)
        updateSliderLowValue(with: lowValue)
        inputValues[.low] = lowValue
    }

    public func setHighValue(_ value: RangeValue, animated: Bool) {
        let highValue = (value > range.upperBound) ? effectiveRange.upperBound : value
        updateNumberInput(for: .high, with: highValue)
        updateSliderHighValue(with: highValue)
        inputValues[.high] = highValue
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

        referenceValueViews = referenceValues.map({ RangeReferenceValueView(value: $0, unit: unit, formatter: formatter) })

        referenceValueViews.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            referenceValuesContainer.addSubview(view)

            let leadingConstraint = view.leadingAnchor.constraint(equalTo: referenceValuesContainer.leadingAnchor)

            NSLayoutConstraint.activate([
                leadingConstraint,
                view.topAnchor.constraint(equalTo: referenceValuesContainer.topAnchor),
                view.bottomAnchor.constraint(equalTo: referenceValuesContainer.bottomAnchor),
            ])

            view.leadingConstraint = leadingConstraint
        }
    }

    @objc func numberInputValueChanged(_ sender: RangeNumberInputView) {
        if let lowValue = sender.lowValue {
            updateSliderLowValue(with: lowValue)
            numberInputView.setLowValueHint(text: "")
            inputValues[.low] = lowValue
            delegate?.rangeFilterView(self, didSetLowValue: lowValue)
        } else {
            delegate?.rangeFilterView(self, didSetLowValue: nil)
        }

        if let highValue = sender.highValue {
            updateSliderHighValue(with: highValue)
            numberInputView.setHighValueHint(text: "")
            inputValues[.high] = highValue
            delegate?.rangeFilterView(self, didSetHighValue: highValue)
        } else {
            delegate?.rangeFilterView(self, didSetHighValue: nil)
        }
    }

    func sliderInputValueChanged(_ sender: RangeSliderView) {
        if let lowValue = sender.lowValue {
            updateNumberInput(for: .low, with: lowValue)
            inputValues[.low] = lowValue
            if isSliderLowValueInValidRange(lowValue) {
                delegate?.rangeFilterView(self, didSetLowValue: lowValue)
            } else {
                delegate?.rangeFilterView(self, didSetLowValue: nil)
            }
        } else {
            delegate?.rangeFilterView(self, didSetLowValue: nil)
        }

        if let highValue = sender.highValue {
            inputValues[.high] = highValue
            updateNumberInput(for: .high, with: highValue)
            if isSliderHighValueInValidRange(highValue) {
                delegate?.rangeFilterView(self, didSetHighValue: highValue)
            } else {
                delegate?.rangeFilterView(self, didSetHighValue: nil)
            }
        } else {
            delegate?.rangeFilterView(self, didSetHighValue: nil)
        }
    }

    func isSliderLowValueInValidRange(_ lowValue: RangeValue) -> Bool {
        if lowValue >= range.lowerBound {
            if lowValue == 0 && range.lowerBound == 0 {
                return false
            }
            return true
        }
        return false
    }

    func isSliderHighValueInValidRange(_ highValue: RangeValue) -> Bool {
        return highValue <= range.upperBound
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

    private func updateNumberInput(for inputValue: InputValue, with value: RangeValue) {
        let isValueLowerThanRangeLowerBound = value < range.lowerBound
        let isValueIsHigherThaRangeUpperBound = value > range.upperBound
        let newValue: RangeValue
        let hintText: String

        if isValueLowerThanRangeLowerBound {
            newValue = range.lowerBound
            hintText = (value == effectiveRange.lowerBound) ? "Under" : ""
        } else if isValueIsHigherThaRangeUpperBound {
            newValue = range.upperBound
            hintText = (value == effectiveRange.upperBound) ? "Over" : ""
        } else {
            newValue = value
            hintText = ""
        }

        switch inputValue {
        case .low:
            numberInputView.setLowValueHint(text: hintText)
            numberInputView.setLowValue(newValue, animated: false)
        case .high:
            numberInputView.setHighValue(newValue, animated: false)
            numberInputView.setHighValueHint(text: hintText)
        }
    }

    func shouldForceSmallFontSizeForNumberInput() -> Bool {
        let iphone6ScreenWidth: CGFloat = 375

        return frame.width < iphone6ScreenWidth
    }

    static func effectiveRange(from range: InputRange, with lowerBoundOffset: RangeValue, and upperBoundOffset: RangeValue) -> InputRange {
        let newLowerBound = range.lowerBound - lowerBoundOffset
        let newUpperBound = range.upperBound + upperBoundOffset
        return InputRange(newLowerBound ... newUpperBound)
    }
}

extension RangeFilterView: RangeSliderViewDelegate {
    func rangeSliderViewDidChangeValue(_ rangeSliderView: RangeSliderView) {
        sliderInputValueChanged(rangeSliderView)
    }
}
