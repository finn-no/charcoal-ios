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
        let rangeNumberInputView = RangeNumberInputView(minValue: sliderData.minimumValue, unit: unit, formatter: formatter, inputFontSize: inputFontSize, displaysUnitInNumberInput: displaysUnitInNumberInput)
        rangeNumberInputView.translatesAutoresizingMaskIntoConstraints = false
        rangeNumberInputView.addTarget(self, action: #selector(numberInputValueChanged(_:)), for: .valueChanged)

        return rangeNumberInputView
    }()

    private lazy var sliderInputView: RangeSliderView = {
        let rangeSliderView = RangeSliderView(data: sliderData, formatter: formatter)
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
                return sliderData.steps
            }

            return accessibilitySteps
        }
        set {
            _accessibilitySteps = newValue
            sliderInputView.accessibilitySteps = newValue ?? sliderData.steps
        }
    }

    private enum InputValue {
        case low, high
    }

    private var inputValues = [InputValue: RangeValue]()
    private var referenceValueViews = [SliderReferenceValueView<RangeValue>]()

    public typealias RangeValue = Int
    let sliderData: StepSliderData<RangeValue>
    let unit: String
    let isValueCurrency: Bool
    let referenceValues: [RangeValue]
    let usesSmallNumberInputFont: Bool
    let displaysUnitInNumberInput: Bool

    public weak var delegate: RangeFilterViewDelegate?

    public init(sliderData: StepSliderData<RangeValue>, unit: String, isValueCurrency: Bool, referenceValues: [RangeValue], usesSmallNumberInputFont: Bool = false, displaysUnitInNumberInput: Bool = true) {
        self.sliderData = sliderData
        self.unit = unit
        self.isValueCurrency = isValueCurrency
        self.referenceValues = referenceValues
        self.usesSmallNumberInputFont = usesSmallNumberInputFont
        self.displaysUnitInNumberInput = displaysUnitInNumberInput
        formatter = RangeFilterValueFormatter(isValueCurrency: isValueCurrency, unit: unit)
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

extension RangeFilterView {
    public var lowValue: RangeValue? {
        return inputValues[.low]
    }

    public var highValue: RangeValue? {
        return inputValues[.high]
    }

    public func setLowValue(_ value: RangeValue?, animated: Bool) {
        updateNumberInput(for: .low, with: value, fromSlider: false)
        updateSliderLowValue(with: value ?? sliderData.effectiveRange.lowerBound)
        inputValues[.low] = value
    }

    public func setHighValue(_ value: RangeValue?, animated: Bool) {
        updateNumberInput(for: .high, with: value, fromSlider: false)
        updateSliderHighValue(with: value ?? sliderData.effectiveRange.upperBound)
        inputValues[.high] = value
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

        referenceValueViews = referenceValues.map({ (referenceValue) -> SliderReferenceValueView<RangeValue> in
            return SliderReferenceValueView(value: referenceValue, displayText: formatter.string(from: referenceValue, isCurrency: isValueCurrency) ?? "")
        })

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

    func updateSliderLowValue(with value: RangeValue) {
        let newValue = value < sliderData.minimumValue ? sliderData.minimumValue : value
        sliderInputView.setLowValue(newValue, animated: false)
    }

    func updateSliderHighValue(with value: RangeValue) {
        let newValue = value > sliderData.maximumValue ? sliderData.maximumValue : value
        sliderInputView.setHighValue(newValue, animated: false)
    }

    private func updateNumberInput(for inputValue: InputValue, with value: RangeValue?, fromSlider: Bool) {
        let newValue: RangeValue
        let hintText: String

        if let value = value {
            if fromSlider {
                if value < sliderData.minimumValue {
                    newValue = sliderData.minimumValue
                    hintText = (value == sliderData.effectiveRange.lowerBound) ? "range_below_lower_bound_title".localized() : ""
                } else if value > sliderData.maximumValue {
                    newValue = sliderData.maximumValue
                    hintText = (value == sliderData.effectiveRange.upperBound) ? "range_above_upper_bound_title".localized() : ""
                } else {
                    newValue = value
                    hintText = ""
                }
            } else {
                newValue = value
                hintText = ""
            }
        } else {
            if inputValue == .low {
                newValue = sliderData.minimumValue
                hintText = (sliderData.minimumValue > sliderData.effectiveRange.lowerBound) ? "range_below_lower_bound_title".localized() : ""
            } else {
                newValue = sliderData.maximumValue
                hintText = (sliderData.maximumValue < sliderData.effectiveRange.upperBound) ? "range_above_upper_bound_title".localized() : ""
            }
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
}

extension RangeFilterView: RangeSliderViewDelegate {
    func rangeSliderView(_ rangeSliderView: RangeSliderView, didChangeLowValue lowValue: RangeSliderView.RangeValue?) {
        if let lowValue = lowValue {
            let didValueChange = inputValues[.low] != lowValue
            if didValueChange {
                updateNumberInput(for: .low, with: lowValue, fromSlider: true)
                inputValues[.low] = lowValue
                if sliderData.isLowValueInValidRange(lowValue) {
                    delegate?.rangeFilterView(self, didSetLowValue: lowValue)
                } else {
                    delegate?.rangeFilterView(self, didSetLowValue: nil)
                }
            }
        } else {
            updateNumberInput(for: .low, with: lowValue, fromSlider: true)
            delegate?.rangeFilterView(self, didSetLowValue: nil)
        }
    }

    func rangeSliderView(_ rangeSliderView: RangeSliderView, didChangeHighValue highValue: RangeSliderView.RangeValue?) {
        if let highValue = highValue {
            let didValueChange = inputValues[.high] != highValue
            if didValueChange {
                inputValues[.high] = highValue
                updateNumberInput(for: .high, with: highValue, fromSlider: true)
                if sliderData.isHighValueInValidRange(highValue) {
                    delegate?.rangeFilterView(self, didSetHighValue: highValue)
                } else {
                    delegate?.rangeFilterView(self, didSetHighValue: nil)
                }
            }
        } else {
            updateNumberInput(for: .high, with: highValue, fromSlider: true)
            delegate?.rangeFilterView(self, didSetHighValue: nil)
        }
    }
}
