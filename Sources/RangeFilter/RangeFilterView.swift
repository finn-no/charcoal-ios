//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol RangeFilterViewDelegate: AnyObject {
    func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetLowValue lowValue: Int?)
    func rangeFilterView(_ rangeFilterView: RangeFilterView, didSetHighValue highValue: Int?)
}

public final class RangeFilterView: UIControl {
    public typealias RangeValue = Int

    private enum InputValue {
        case low, high
    }

    public weak var delegate: RangeFilterViewDelegate?

    private let filterInfo: RangeFilterInfoType
    private let formatter: RangeFilterValueFormatter
    private var inputValues = [InputValue: RangeValue]()
    private var referenceValueViews = [SliderReferenceValueView<RangeValue>]()

    public var generatesHapticFeedbackOnSliderValueChange = true {
        didSet {
            sliderInputView.generatesHapticFeedbackOnValueChange = generatesHapticFeedbackOnSliderValueChange
        }
    }

    private var sliderInfo: StepSliderInfo<RangeValue> {
        return filterInfo.sliderInfo
    }

    private lazy var numberInputView: RangeNumberInputView = {
        let inputFontSize: RangeNumberInputView.InputFontSize = filterInfo.usesSmallNumberInputFont ? .small : .large
        let rangeNumberInputView = RangeNumberInputView(
            minValue: sliderInfo.minimumValue,
            unit: filterInfo.unit,
            formatter: formatter,
            inputFontSize: inputFontSize,
            displaysUnitInNumberInput: filterInfo.displaysUnitInNumberInput
        )
        rangeNumberInputView.translatesAutoresizingMaskIntoConstraints = false
        rangeNumberInputView.addTarget(self, action: #selector(numberInputValueChanged(_:)), for: .valueChanged)

        return rangeNumberInputView
    }()

    private lazy var sliderInputView: RangeSliderView = {
        let rangeSliderView = RangeSliderView(sliderInfo: sliderInfo, formatter: formatter)
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

    // MARK: - Init

    public init(filterInfo: RangeFilterInfoType) {
        self.filterInfo = filterInfo
        formatter = RangeFilterValueFormatter(
            isValueCurrency: filterInfo.isCurrencyValueRange,
            unit: filterInfo.unit,
            accessibilityUnit: filterInfo.accessibilityValueSuffix ?? ""
        )
        super.init(frame: .zero)
        numberInputView.accessibilityValueSuffix = filterInfo.accessibilityValueSuffix
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

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
        updateSliderLowValue(with: value ?? sliderInfo.minimumValueWithOffset)
        inputValues[.low] = value
    }

    public func setHighValue(_ value: RangeValue?, animated: Bool) {
        updateNumberInput(for: .high, with: value, fromSlider: false)
        updateSliderHighValue(with: value ?? sliderInfo.maximumValueWithOffset)
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
            referenceValuesContainer.leadingAnchor.constraint(equalTo: sliderInputView.leadingAnchor,
                                                              constant: RangeSliderView.visibleThumbRadius),
            referenceValuesContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            referenceValuesContainer.trailingAnchor.constraint(equalTo: sliderInputView.trailingAnchor),
        ])

        referenceValueViews = sliderInfo.referenceValues.map({ referenceValue in
            return SliderReferenceValueView(
                value: referenceValue,
                displayText: formatter.string(from: referenceValue, isCurrency: filterInfo.isCurrencyValueRange) ?? ""
            )
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
        let newValue = value < sliderInfo.minimumValue ? sliderInfo.minimumValueWithOffset : value
        sliderInputView.setLowValue(newValue, animated: false)
    }

    func updateSliderHighValue(with value: RangeValue) {
        let newValue = value > sliderInfo.maximumValue ? sliderInfo.maximumValueWithOffset : value
        sliderInputView.setHighValue(newValue, animated: false)
    }

    private func updateNumberInput(for inputValue: InputValue, with value: RangeValue?, fromSlider: Bool) {
        let newValue: RangeValue
        let hintText: String

        if let value = value {
            if value < sliderInfo.minimumValue {
                newValue = sliderInfo.minimumValue
                hintText = "range_below_lower_bound_title".localized()
            } else if value > sliderInfo.maximumValue {
                newValue = sliderInfo.maximumValue
                hintText = "range_above_upper_bound_title".localized()
            } else {
                newValue = value
                hintText = ""
            }
        } else {
            if inputValue == .low {
                newValue = sliderInfo.minimumValue
                hintText = sliderInfo.hasLowerBoundOffset ? "range_below_lower_bound_title".localized() : ""
            } else {
                newValue = sliderInfo.maximumValue
                hintText = sliderInfo.hasUpperBoundOffset ? "range_above_upper_bound_title".localized() : ""
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
    func rangeSliderView(_ rangeSliderView: RangeSliderView,
                         didChangeLowValue value: RangeSliderView.RangeValue?,
                         didFinishSlideInteraction slideEnded: Bool) {
        handleSliderUpdates(for: .low, value: value, slideEnded: slideEnded)
    }

    func rangeSliderView(_ rangeSliderView: RangeSliderView,
                         didChangeHighValue value: RangeSliderView.RangeValue?,
                         didFinishSlideInteraction slideEnded: Bool) {
        handleSliderUpdates(for: .high, value: value, slideEnded: slideEnded)
    }

    private func handleSliderUpdates(for inputValue: InputValue, value: RangeSliderView.RangeValue?, slideEnded: Bool) {
        if let value = value {
            let didValueChange = inputValues[inputValue] != value
            if didValueChange {
                updateNumberInput(for: inputValue, with: value, fromSlider: true)
                inputValues[inputValue] = value
            }

            if slideEnded {
                let isValidRange = inputValue == .low ? sliderInfo.isLowValueInValidRange : sliderInfo.isHighValueInValidRange

                if isValidRange(value) {
                    didSetSliderValue(value, for: inputValue)
                } else {
                    didSetSliderValue(nil, for: inputValue)
                }
            }
        } else {
            updateNumberInput(for: inputValue, with: value, fromSlider: true)
            inputValues[inputValue] = nil

            if slideEnded {
                didSetSliderValue(nil, for: inputValue)
            }
        }
    }

    private func didSetSliderValue(_ value: RangeSliderView.RangeValue?, for inputValue: InputValue) {
        if inputValue == .low {
            delegate?.rangeFilterView(self, didSetLowValue: value)
        } else {
            delegate?.rangeFilterView(self, didSetHighValue: value)
        }
    }
}
